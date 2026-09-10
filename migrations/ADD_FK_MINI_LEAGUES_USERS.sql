-- depends: ADD_FK_TOKENS_USERS

-- A league is created by a logged-in account. Restrict: an account that owns
-- a league cannot be deleted until the league is. Verified 0 orphans in all
-- three schemas on 2026-09-10; idx_created_by serves the key.

ALTER TABLE MINI_LEAGUES
  ADD CONSTRAINT fk_mini_leagues_user
  FOREIGN KEY (CREATED_BY) REFERENCES USERS (PLAYER_ID)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;
