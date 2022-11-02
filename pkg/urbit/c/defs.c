/// @file defs.c

#include "c/defs.h"

/* c3_pread(): full positioned read(), retrying errors where appropriate.
*/
ssize_t
c3_pread(c3_i fid_i, void* buf_v, size_t len_i, off_t off_i)
{
  c3_w    max_w = 128;
  c3_w    try_w = 0;
  size_t  rem_i = len_i;
  ssize_t ret_i;

  do {
    if (  (0 > (ret_i = pread(fid_i, buf_v, rem_i, off_i)))
       && (  (++try_w == max_w)
          || (  (EINTR       != errno)
             && (EAGAIN      != errno)
             && (EWOULDBLOCK != errno) )))
    {
      return -1;
    }
    else if ( 0 == ret_i ) {
      break;
    }
    else {
      buf_v  = (void*)((c3_c*)buf_v + ret_i);
      rem_i -= ret_i;
      off_i += ret_i;
    }

  }
  while ( rem_i );

  return len_i - rem_i;
}

/* c3_pwrite(): full positioned write(), retrying errors where appropriate.
*/
ssize_t
c3_pwrite(c3_i fid_i, const void* buf_v, size_t len_i, off_t off_i)
{
  c3_w    max_w = 128;
  c3_w    try_w = 0;
  size_t  rem_i = len_i;
  ssize_t ret_i;

  do {
    if (  (0 > (ret_i = pwrite(fid_i, buf_v, rem_i, off_i)))
       && (  (++try_w == max_w)
          || (  (EINTR       != errno)
             && (EAGAIN      != errno)
             && (EWOULDBLOCK != errno) )))
    {
      return -1;
    }
    else {
      buf_v  = (void*)((c3_c*)buf_v + ret_i);
      rem_i -= ret_i;
      off_i += ret_i;
    }
  }
  while ( rem_i );

  return len_i;
}

ssize_t
c3_write(c3_i fd_i, const void* const data_v, const size_t data_len_i)
{
  static const size_t max_attempts_i    = 100;
  size_t              attempts_i        = 0;
  const c3_y*         ptr_y             = data_v;
  ssize_t             bytes_remaining_i = data_len_i;
  do {
    attempts_i++;
    ssize_t bytes_written_i = write(fd_i, ptr_y, bytes_remaining_i);
    if ( -1 == bytes_written_i ) {
      // Attempt to read again if we were interrupted by a signal.
      if ( (EINTR == errno || EAGAIN == errno || EWOULDBLOCK == errno)
           && attempts_i <= max_attempts_i )
      {
        continue;
      }
      else {
        return -errno;
      }
    }
    else {
      ptr_y += bytes_written_i;
      bytes_remaining_i -= bytes_written_i;
      attempts_i = 0;
    }
  } while ( bytes_remaining_i > 0 );

  return data_len_i - bytes_remaining_i;
}
