-- depends: ADD_FK_MINI_LEAGUES_USERS

-- A membership needs its league and its account. Both cascade: deleting a
-- league removes its members (the API already does this by hand), and an
-- account's memberships go with it. Verified 0 orphans on either side in all
-- three schemas on 2026-09-10.

ALTER TABLE MINI_LEAGUE_MEMBERS
  ADD CONSTRAINT fk_mini_league_members_league
  FOREIGN KEY (LEAGUE_ID) REFERENCES MINI_LEAGUES (LEAGUE_ID)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE MINI_LEAGUE_MEMBERS
  ADD CONSTRAINT fk_mini_league_members_user
  FOREIGN KEY (PLAYER_ID) REFERENCES USERS (PLAYER_ID)
  ON DELETE CASCADE
  ON UPDATE CASCADE;
