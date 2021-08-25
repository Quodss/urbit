import React, { MouseEvent, useCallback } from 'react';
import { MatchItem } from '../nav/Nav';
import { useRecentsStore } from '../nav/search/Home';
import { Docket } from '../state/docket-types';
import { AppLink, AppLinkProps } from './AppLink';

type AppListProps = {
  apps: Docket[];
  labelledBy: string;
  matchAgainst?: MatchItem;
  onClick?: (e: MouseEvent<HTMLAnchorElement>, app: Docket) => void;
} & Omit<AppLinkProps, 'app' | 'onClick'>;

export function appMatches(target: Docket, match?: MatchItem): boolean {
  if (!match) {
    return false;
  }

  const matchValue = match.display || match.value;
  return target.title === matchValue || target.base === matchValue;
}

export const AppList = ({ apps, labelledBy, matchAgainst, onClick, ...props }: AppListProps) => {
  const addRecentApp = useRecentsStore((state) => state.addRecentApp);
  const selected = useCallback((app: Docket) => appMatches(app, matchAgainst), [matchAgainst]);

  return (
    <ul className="space-y-8" aria-labelledby={labelledBy}>
      {apps.map((app) => (
        <li key={app.base} id={app.base} role="option" aria-selected={selected(app)}>
          <AppLink
            {...props}
            app={app}
            selected={selected(app)}
            onClick={(e) => {
              addRecentApp(app);
              onClick && onClick(e, app);
            }}
          />
        </li>
      ))}
    </ul>
  );
};
