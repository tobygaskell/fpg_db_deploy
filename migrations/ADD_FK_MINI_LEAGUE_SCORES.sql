-- depends: ADD_FK_MINI_LEAGUE_MEMBERS

-- League scores belong to a league, an account and a round. Deleting the
-- league removes them (the API already does this by hand); an account with
-- scores cannot be deleted; a round is never deleted. No key to
-- MINI_LEAGUE_MEMBERS on purpose: leaving a league removes only the
-- membership and a player who rejoins picks their history back up.
-- Verified 0 orphans for all three keys in every schema on 2026-09-10.
-- InnoDB creates the PLAYER_ID and (ROUND, SEASON) indexes the keys need.

ALTER TABLE MINI_LEAGUE_SCORES
  ADD CONSTRAINT fk_mini_league_scores_league
  FOREIGN KEY (LEAGUE_ID) REFERENCES MINI_LEAGUES (LEAGUE_ID)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE MINI_LEAGUE_SCORES
  ADD CONSTRAINT fk_mini_league_scores_user
  FOREIGN KEY (PLAYER_ID) REFERENCES USERS (PLAYER_ID)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;

ALTER TABLE MINI_LEAGUE_SCORES
  ADD CONSTRAINT fk_mini_league_scores_round
  FOREIGN KEY (ROUND, SEASON) REFERENCES ROUNDS (ROUND, SEASON)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;
