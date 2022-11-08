/// @file saga.c
///
/// Epoch-backed event log.
///
/// Consists of a list of epochs, each containing a contiguous slice of events.
/// Events can be committed synchronously or asynchronously. When the most
/// recent epoch fills up (i.e. reaches the maximum number of committed events),
/// a new epoch is automatically created and rolled over to.
///
/// As an example, the directory layout of an event log containing epochs N
/// through M, inclusive, is:
/// ```console
/// <epoch_N>/
/// <epoch_N+1>/
/// ...
/// <epoch_M>/
/// ```
/// Note that the epoch directory names are ommitted because they are an
/// implementation detail of the epoc module.

#include "vere/saga.h"

#include "all.h"

//==============================================================================
// Constants
//==============================================================================

/// Minimum number of events per epoch.
static const size_t epo_len_i = 50000;

/// Maximum number of events in a single batch commit.
#define max_batch_size 100

/// Size of the `d_name` field of `struct dirent`.
#define dname_size     sizeof(((struct dirent*)NULL)->d_name)

//==============================================================================
// Types
//==============================================================================

/// Event log. Typedefed to `u3_saga`.
struct _u3_saga {
  /// Path to event log directory.
  c3_path* pax_u;

  /// ID of youngest event.
  c3_d eve_d;

  /// Epochs.
  struct {
    /// List of epochs (front is oldest, back is youngest).
    c3_list* lis_u;

    /// Current epoch.
    u3_epoc* cur_u;
  } epo_u;

  /// Events pending commit.
  struct {
    /// List of events pending commit.
    c3_list* lis_u;

    /// Number of events in commit request.
    size_t req_i;
  } eve_u;

  /// Histogram of commit batch size.
  size_t his_w[max_batch_size];

  /// Active commit flag.
  c3_t act_t;

  /// Async commit context.
  struct {
    /// libuv event loop.
    uv_loop_t* lup_u;

    /// libuv work queue handle.
    uv_work_t req_u;

    /// Callback invoked upon commit completion.
    u3_saga_news com_f;

    /// User context passed to `com_f`.
    void* ptr_v;

    /// Commit success flag.
    c3_t suc_t;
  } asy_u;
};

//==============================================================================
// Static functions
//==============================================================================

/// Boot from a snapshot.
///
/// Upon successful completion, `u3A->eve_d` represents the most recent event
/// represented by the epoch's snapshot.
///
/// @param[in] poc_u  Epoch whose snapshot should be used to boot.
///
/// @return 0  The epoch was `NULL`.
/// @return 1  Successfully booted from the epoch's snapshot.
static c3_t
_boot_from_epoc_snapshot(const u3_epoc* const poc_u);

/// Compare two epoch directory names. Used as the comparison function for
/// qsort().
///
/// @param[in] lef_v  Pointer to character array representing left epoch
///                   directory name.
/// @param[in] rih_v  Pointer to character array representing right epoch
///                   directory name.
///
/// @return <0  The left epoch is older than the right epoch.
/// @return  0  The left epoch and right epoch are the same age (i.e. the same
///             epoch).
/// @return >0  The left epoch is younger than the right epoch.
static inline c3_i
_cmp_epocs(const void* lef_v, const void* rih_v);

/// Search an event log's list of epochs for the epoch that contains the given
/// event ID. Runs in O(n) where n is the length of the list of epochs.
///
/// @param[in] log_u  Event log handle.
/// @param[in] ide_d  Event ID to search for.
///
/// @return NULL  `ide_d` does not belong to any epoch in `log_u`.
/// @return       Epoch handle of epoch containing `ide_d`.
static u3_epoc*
_find_epoc(u3_saga* const log_u, const c3_d ide_d);

/// Determine if a string is a valid epoch directory name.
///
/// @param[in] nam_c  Name.
///
/// @return 1  `nam_c` is a valid epoch directory name.
/// @return 0  Otherwise.
static inline c3_t
_is_epoc_dir(const c3_c* const nam_c);

/// Migrate from old non-epoch-based event log to epoch-based event log.
///
/// @param[in]  log_u  Event log handle.
///
/// @return 1  Migration succeeded.
/// @return 0  Otherwise.
static c3_t
_migrate(u3_saga* const log_u);

/// Discover epoch directories in a given directory.
///
/// @param[in]  dir_c  Directory to search for epoch directories.
/// @param[out] ent_c  Pointer to array of 256-byte arrays.
/// @param[out] ent_i  Pointer to number of elements in `*ent_c`.
///
/// @return 1  Discovered one or more epoch directories.
/// @return 0  Otherwise.
static c3_t
_read_epoc_dirs(const c3_c* const dir_c,
                c3_c (**ent_c)[dname_size],
                size_t* ent_i);

/// Remove events that were committed in the last commit request from an event
/// log's pending commits list.
///
/// @param[in] log_u  Event log handle.
static inline void
_remove_committed_events(u3_saga* const log_u);

/// Invoke user callback after batch async commit.
///
/// @note Runs on main thread.
///
/// @param[in] req_u  libuv work handle.
/// @param[in] sas_i  libuv return status.
static void
_uv_commit_after_cb(uv_work_t* req_u, c3_i sas_i);

/// Initiate async batch commit.
///
/// @note Runs off main thread.
///
/// @param[in] req_u  libuv work handle.
static void
_uv_commit_cb(uv_work_t* req_u);

static c3_t
_boot_from_epoc_snapshot(const u3_epoc* const poc_u)
{
  if ( !poc_u ) {
    return 0;
  }

  u3e_load(u3_epoc_path_str(poc_u));
  u3m_pave(c3n);
  // Place the guard page.
  u3e_init();
  u3j_boot(c3n);
  u3j_ream();
  u3n_ream();

  return 1;
}

static inline c3_i
_cmp_epocs(const void* lef_v, const void* rih_v)
{
  const c3_c*   lef_c = *(const c3_c(*)[dname_size])lef_v;
  const c3_c*   rih_c = *(const c3_c(*)[dname_size])rih_v;
  const ssize_t len_i = (ssize_t)strlen(lef_c);
  const ssize_t ren_i = (ssize_t)strlen(rih_c);
  return len_i == ren_i ? strcmp(lef_c, rih_c) : len_i - ren_i;
}

static inline c3_t
_is_epoc_dir(const c3_c* const nam_c)
{
  return 0 == strncmp(nam_c, epo_pre_c, strlen(epo_pre_c));
}

static c3_t
_migrate(u3_saga* const log_u)
{
  u3_epoc* poc_u = u3_epoc_migrate(log_u->pax_u, log_u->pax_u, u3A->eve_d);
  if ( !poc_u ) {
    goto fail;
  }

  log_u->eve_d = u3_epoc_last_commit(poc_u);

  { // Push the newly created epoch from migration onto the epoch list.
    try_list(log_u->epo_u.lis_u = c3_list_init(C3_LIST_COPY), goto fail);
    c3_list_pushb(log_u->epo_u.lis_u, poc_u, epo_siz_i);
    c3_free(poc_u);
  }

  // Immediately rollover to a new epoch.
  if ( !u3_saga_rollover(log_u) ) {
    fprintf(stderr,
            "saga: failed to rollover to new epoch after migrating\r\n");
    goto fail;
  }

  try_list(log_u->eve_u.lis_u = c3_list_init(C3_LIST_TRANSFER), goto fail);

  goto succeed;

fail:
  return 0;

succeed:
  return 1;
}

static c3_t
_read_epoc_dirs(const c3_c* const dir_c, c3_c (**ent_c)[], size_t* ent_i)
{
  DIR* dir_u;
  if ( !dir_c || !ent_c || !ent_i || !(dir_u = opendir(dir_c)) ) {
    return 0;
  }

  *ent_c = NULL;
  *ent_i = 0;

  struct dirent* ent_u;
  // Arbitrarily choose 16 as the initial guess at the max number of epochs.
  size_t cap_i             = 16;
  c3_c(*dst_c)[dname_size] = c3_malloc(cap_i * dname_size);
  size_t dst_i             = 0;
  while ( (ent_u = readdir(dir_u)) ) {
    if ( !_is_epoc_dir(ent_u->d_name) ) {
      continue;
    }
    if ( dst_i == cap_i ) {
      cap_i *= 2;
      dst_c = c3_realloc(dst_c, cap_i * dname_size);
    }
    strcpy(dst_c[dst_i++], ent_u->d_name);
  }
  if ( 0 == dst_i ) {
    c3_free(dst_c);
    return 0;
  }
  qsort(dst_c, dst_i, dname_size, _cmp_epocs);
  *ent_c = dst_c;
  *ent_i = dst_i;
  return 1;
}

static inline void
_remove_committed_events(u3_saga* const log_u)
{
  c3_list* eve_u = log_u->eve_u.lis_u;
  size_t   len_i = log_u->eve_u.req_i;
  for ( size_t idx_i = 0; idx_i < len_i; idx_i++ ) {
    c3_lode* nod_u = c3_list_popf(eve_u);
    c3_free(c3_lode_data(nod_u));
    c3_free(nod_u);
  }
}

static void
_uv_commit_after_cb(uv_work_t* req_u, c3_i sas_i)
{
  u3_saga* log_u = req_u->data;
  log_u->act_t   = 0;

  c3_t suc_t = log_u->asy_u.suc_t;
  if ( suc_t ) {
    _remove_committed_events(log_u);
  }

  c3_d las_d = u3_epoc_last_commit(log_u->epo_u.cur_u);
  log_u->asy_u.com_f(log_u->asy_u.ptr_v, las_d, suc_t);

  // Attempt to commit events that were enqueued after the commit began.
  if ( UV_ECANCELED != sas_i ) {
    u3_saga_commit_async(log_u, NULL, 0);
  }
}

static void
_uv_commit_cb(uv_work_t* req_u)
{
  u3_saga* log_u     = req_u->data;
  u3_epoc* poc_u     = log_u->epo_u.cur_u;
  c3_lode* nod_u     = c3_list_peekf(log_u->eve_u.lis_u);
  size_t   len_i     = log_u->eve_u.req_i;
  log_u->asy_u.suc_t = u3_epoc_commit(poc_u, nod_u, len_i);
}

static u3_epoc*
_find_epoc(u3_saga* const log_u, const c3_d ide_d)
{
  c3_lode* nod_u = c3_list_peekb(log_u->epo_u.lis_u);
  u3_epoc* poc_u;
  while ( nod_u ) {
    poc_u = c3_lode_data(nod_u);
    if ( u3_epoc_has(poc_u, ide_d) ) {
      break;
    }
    nod_u = c3_lode_prev(nod_u);
  }
  return nod_u ? poc_u : NULL;
}

//==============================================================================
// Functions
//==============================================================================

u3_saga*
u3_saga_new(const c3_path* const pax_u)
{
  u3_saga* log_u = c3_calloc(sizeof(*log_u));
  if ( !(log_u->pax_u = c3_path_fp(pax_u)) ) {
    goto free_event_log;
  }
  mkdir(c3_path_str(log_u->pax_u), 0700);

  { // Create first epoch.
    try_list(log_u->epo_u.lis_u = c3_list_init(C3_LIST_COPY),
             goto free_event_log);
    u3_epoc* poc_u;
    try_epoc(poc_u = u3_epoc_new(log_u->pax_u, epo_min_d),
             goto free_event_log,
             "failed to create first epoch in %s\r\n",
             c3_path_str(log_u->pax_u));
    c3_list_pushb(log_u->epo_u.lis_u, poc_u, epo_siz_i);
    c3_free(poc_u);
    log_u->epo_u.cur_u = c3_lode_data(c3_list_peekb(log_u->epo_u.lis_u));
  }

  try_list(log_u->eve_u.lis_u = c3_list_init(C3_LIST_TRANSFER),
           goto free_event_log);

  goto succeed;

free_event_log:
  u3_saga_close(log_u);
  c3_free(log_u);
  return NULL;

succeed:
  return log_u;
}

u3_saga*
u3_saga_open(const c3_path* const pax_u, c3_w* const len_w)
{
  u3_saga* log_u = c3_calloc(sizeof(*log_u));
  if ( !(log_u->pax_u = c3_path_fp(pax_u)) ) {
    goto free_event_log;
  }

  { // Attempt to migrate old non-epoch-based event log.
    c3_path_push(log_u->pax_u, "data.mdb");
    c3_i ret_i = access(c3_path_str(log_u->pax_u), R_OK | W_OK);
    c3_path_pop(log_u->pax_u);
    if ( 0 == ret_i ) {
      if ( !_migrate(log_u) ) {
        fprintf(stderr,
                "saga: failed to create first "
                "epoch from existing event log\r\n");
        goto free_event_log;
      }
      goto succeed;
    }
  }

  c3_c(*ent_c)[dname_size];
  size_t ent_i;
  if ( !_read_epoc_dirs(c3_path_str(log_u->pax_u), &ent_c, &ent_i) ) {
    goto free_event_log;
  }

  try_list(log_u->epo_u.lis_u = c3_list_init(C3_LIST_COPY),
           goto free_dir_entries);
  u3_epoc *poc_u, *pre_u;
  for ( size_t idx_i = 0; idx_i < ent_i; idx_i++ ) {
    c3_path_push(log_u->pax_u, ent_c[idx_i]);
    // The two most recent epochs must be mapped into memory. It'd be nice to
    // map only the most recent epoch, but the second most recent epoch is also
    // required when relaunching after boot because the second most recent epoch
    // is needed to replay the boot sequence.
    try_epoc(poc_u = u3_epoc_open(log_u->pax_u,
                                  ent_i > 2 && idx_i < ent_i - 2,
                                  idx_i == 0 ? len_w : NULL),
             goto free_dir_entries);
    c3_path_pop(log_u->pax_u);
    c3_list_pushb(log_u->epo_u.lis_u, poc_u, epo_siz_i);
    c3_free(poc_u);
  }

  log_u->epo_u.cur_u = c3_lode_data(c3_list_peekb(log_u->epo_u.lis_u));
  log_u->eve_d       = u3_epoc_last_commit(log_u->epo_u.cur_u);

  try_list(log_u->eve_u.lis_u = c3_list_init(C3_LIST_TRANSFER),
           goto free_dir_entries);

  c3_free(ent_c);
  goto succeed;

free_dir_entries:
  c3_free(ent_c);
free_event_log:
  u3_saga_close(log_u);
  c3_free(log_u);
  return NULL;

succeed:
  return log_u;
}

c3_d
u3_saga_last_commit(const u3_saga* const log_u)
{
  return u3_epoc_last_commit(log_u->epo_u.cur_u);
}

c3_t
u3_saga_needs_rollover(const u3_saga* const log_u)
{
  return u3_epoc_len(log_u->epo_u.cur_u) >= epo_len_i;
}

c3_t
u3_saga_needs_bootstrap(const u3_saga* const log_u)
{
  c3_assert(log_u);
  const u3_epoc* const poc_u = c3_lode_data(c3_list_peekf(log_u->epo_u.lis_u));
  const size_t         len_i = c3_list_len(log_u->epo_u.lis_u);
  // Bootstrap is needed if the only epoch present is the first epoch.
  return u3_epoc_is_first(poc_u) && 1 == len_i;
}

c3_t
u3_saga_commit_sync(u3_saga* const log_u, c3_y* const byt_y, const size_t byt_i)
{
  c3_list* const eve_u = log_u->eve_u.lis_u;
  c3_list_pushb(eve_u, byt_y, byt_i);
  log_u->eve_d++;

  // There should never be more than one event on the pending commits queue
  // (i.e. the one we just added), let alone `max_batch_size` (100) commits.
  log_u->eve_u.req_i = c3_min(c3_list_len(eve_u), max_batch_size);
  log_u->his_w[log_u->eve_u.req_i]++;

  c3_lode* const nod_u = c3_list_peekf(eve_u);

  log_u->act_t = 1;
  c3_t suc_t   = u3_epoc_commit(log_u->epo_u.cur_u, nod_u, log_u->eve_u.req_i);
  _remove_committed_events(log_u);
  log_u->act_t = 0;

  return suc_t;
}

void
u3_saga_set_async_ctx(u3_saga*         log_u,
                      uv_loop_t* const lup_u,
                      u3_saga_news     com_f,
                      void*            ptr_v)
{
  if ( !log_u ) {
    return;
  }
  log_u->asy_u.lup_u      = lup_u;
  log_u->asy_u.req_u.data = log_u;
  log_u->asy_u.com_f      = com_f;
  log_u->asy_u.ptr_v      = ptr_v;
}

c3_t
u3_saga_commit_async(u3_saga* const log_u,
                     c3_y* const    byt_y,
                     const size_t   byt_i)
{
  c3_list* const eve_u = log_u->eve_u.lis_u;
  // A NULL event can be passed to invoke another commit batch.
  if ( byt_y ) {
    c3_list_pushb(eve_u, byt_y, byt_i);
    log_u->eve_d++;
  }

  // Schedule another commit batch if there are scheduled events to be committed
  // and no batch is already in progress.
  if ( c3_list_len(eve_u) > 0 && !log_u->act_t ) {
    log_u->eve_u.req_i = c3_min(c3_list_len(eve_u), max_batch_size);
    log_u->his_w[log_u->eve_u.req_i]++;

    log_u->act_t = 1;
    uv_queue_work(log_u->asy_u.lup_u,
                  &log_u->asy_u.req_u,
                  _uv_commit_cb,
                  _uv_commit_after_cb);
  }

  return 1;
}

c3_t
u3_saga_rollover(u3_saga* const log_u)
{
  // Rollover should not be allowed if Arvo's current event ID doesn't match the
  // most recently committed event ID.
  if ( !log_u || log_u->eve_d != u3A->eve_d ) {
    goto fail;
  }
  u3_epoc* const poc_u = u3_epoc_new(log_u->pax_u, log_u->eve_d + 1);
  if ( !poc_u ) {
    goto fail;
  }

  c3_list_pushb(log_u->epo_u.lis_u, poc_u, epo_siz_i);
  c3_free(poc_u);
  log_u->epo_u.cur_u = c3_lode_data(c3_list_peekb(log_u->epo_u.lis_u));

  goto succeed;

fail:
  return 0;

succeed:
  return 1;
}

c3_t
u3_saga_truncate(u3_saga* const log_u, size_t cnt_i)
{
  if ( !log_u ) {
    return 0;
  }

  c3_list* const epo_u = log_u->epo_u.lis_u;

  size_t len_i = c3_list_len(epo_u);
  c3_assert(len_i > 0);
  cnt_i = (0 == cnt_i) ? len_i - 1 : c3_min(cnt_i, len_i - 1);

  for ( size_t idx_i = 0; idx_i < cnt_i; idx_i++ ) {
    c3_lode* nod_u = c3_list_popf(epo_u);
    u3_epoc* poc_u = c3_lode_data(nod_u);
    if ( !u3_epoc_delete(poc_u) ) {
      fprintf(stderr,
              "saga: failed to delete epoch %s\r\n",
              u3_epoc_path_str(poc_u));
      return 0;
    }
    u3_epoc_close(poc_u);
    c3_free(nod_u);
  }
  return 1;
}

/// Replay by restoring the latest epoch's snapshot and then replaying that
/// epoch's events.
///
/// @attention This implementation assumes that the loom has already been
///            initialized by calling u3m_boot(). This assumption is necessary
///            to enable the application of the most recent epoch's snapshot to
///            the loom.
c3_t
u3_saga_replay(u3_saga* const log_u,
               c3_d           cur_d,
               c3_d           las_d,
               u3_saga_play   pla_f,
               void*          ptr_v)
{
  c3_t suc_t = 0;

  if ( 0 == las_d ) {
    las_d = u3_epoc_last_commit(log_u->epo_u.cur_u);
  }

  if ( las_d <= cur_d ) {
    suc_t = 1;
    goto end;
  }

  u3_epoc* poc_u;
  try_saga(poc_u = _find_epoc(log_u, las_d),
           goto end,
           "no epoch has event %" PRIu64,
           las_d);

  if ( !u3_epoc_is_first(poc_u) ) {
    if ( u3A->eve_d < u3_epoc_num(poc_u) ) {
      try_saga(_boot_from_epoc_snapshot(poc_u),
               goto end,
               "failed to boot from %s snapshot\r\n",
               u3_epoc_path_str(poc_u));
    }
    cur_d = u3A->eve_d;
  }

  cur_d++;

  try_epoc(u3_epoc_iter_open(poc_u, cur_d), goto take_snapshot);
  while ( cur_d <= las_d ) {
    c3_y*  byt_y;
    size_t byt_i;
    try_epoc(u3_epoc_iter_step(poc_u, &byt_y, &byt_i), goto close_iterator);
    if ( !pla_f(ptr_v, cur_d, las_d, byt_y, byt_i) ) {
      goto close_iterator;
    }
    cur_d++;
  }
  suc_t = 1;

close_iterator:
  u3_epoc_iter_close(poc_u);
take_snapshot:
  u3e_save();
end:
  return suc_t;
}

void
u3_saga_info(const u3_saga* const log_u)
{
  if ( !log_u ) {
    return;
  }

  fprintf(stderr,
          "\r\nsaga: last commit: %" PRIu64 "\r\n",
          u3_saga_last_commit(log_u));

  fprintf(stderr,
          "  events pending commit: %lu\r\n",
          c3_list_len(log_u->eve_u.lis_u));

  c3_lode* nod_u = c3_list_peekf(log_u->epo_u.lis_u);
  while ( nod_u ) {
    u3_epoc* poc_u = c3_lode_data(nod_u);
    u3_epoc_info(poc_u);
    nod_u = c3_lode_next(nod_u);
  }

  fprintf(stderr, "  histogram of commit sizes:\r\n");
  fprintf(stderr, "    (number of events in commit): (number of commits)\r\n");
  for ( size_t idx_i = 0; idx_i < max_batch_size; idx_i++ ) {
    fprintf(stderr, "    %lu: %lu\r\n", idx_i, log_u->his_w[idx_i]);
  }
}

void
u3_saga_close(u3_saga* const log_u)
{
  if ( !log_u ) {
    return;
  }

  // Cancel thread that is performing async commits, short-circuiting clean-up
  // if we can't cancel the thread.
  if ( log_u->act_t && uv_cancel((uv_req_t*)&log_u->asy_u.req_u) < 0 ) {
    fprintf(stderr, "saga: could not cancel libuv write thread\r\n");
    return;
  }

  if ( log_u->pax_u ) {
    c3_path_free(log_u->pax_u);
  }

  { // Free epochs.
    c3_list* epo_u = log_u->epo_u.lis_u;
    if ( epo_u ) {
      c3_lode* nod_u;
      while ( (nod_u = c3_list_popf(epo_u)) ) {
        u3_epoc* poc_u = c3_lode_data(nod_u);
        u3_epoc_close(poc_u);
        c3_free(nod_u);
      }
      c3_free(epo_u);
    }
  }

  { // Free events pending commit.
    c3_list* eve_u = log_u->eve_u.lis_u;
    if ( eve_u ) {
      c3_lode* nod_u;
      while ( (nod_u = c3_list_popf(eve_u)) ) {
        c3_free(c3_lode_data(nod_u));
        c3_free(nod_u);
      }
      c3_free(eve_u);
    }
  }
}

#undef max_batch_size
#undef dname_size
