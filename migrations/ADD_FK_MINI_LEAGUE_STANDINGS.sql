-- depends: ADD_FK_MINI_LEAGUE_SCORES

-- Same three keys as MINI_LEAGUE_SCORES. The league cascade also covers what
-- the API's league delete forgets: it removes scores and members but not
-- standings. Verified 0 orphans for all three keys in every schema on
-- 2026-09-10.

ALTER TABLE MINI_LEAGUE_STANDINGS
  ADD CONSTRAINT fk_mini_league_standings_league
  FOREIGN KEY (LEAGUE_ID) REFERENCES MINI_LEAGUES (LEAGUE_ID)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE MINI_LEAGUE_STANDINGS
  ADD CONSTRAINT fk_mini_league_standings_user
  FOREIGN KEY (PLAYER_ID) REFERENCES USERS (PLAYER_ID)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;

ALTER TABLE MINI_LEAGUE_STANDINGS
  ADD CONSTRAINT fk_mini_league_standings_round
  FOREIGN KEY (ROUND, SEASON) REFERENCES ROUNDS (ROUND, SEASON)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;
