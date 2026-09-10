-- depends: ADD_FK_MINI_LEAGUE_STANDINGS

-- Keys from the game tables to players were dropped in June 2026
-- (DROP_FK_CHOICES_SCORES_PLAYERS) because the re-signup import was under way
-- and 162 legacy picks had no parent row. Every legacy player now has a USERS
-- row: verified 0 CHOICES, SCORES or STANDINGS rows without one in FPG and
-- UAT_FPG on 2026-09-10 (DEV_FPG matches once populate_dev copies USERS).
-- Restrict: game history is never cascaded away. The API writes picks for the
-- logged-in account and the engine writes scores and standings for accounts
-- in USERS. The CHOICES and SCORES primary keys lead with PLAYER_ID; InnoDB
-- creates the index STANDINGS needs.

ALTER TABLE CHOICES
  ADD CONSTRAINT fk_choices_user
  FOREIGN KEY (PLAYER_ID) REFERENCES USERS (PLAYER_ID)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;

ALTER TABLE SCORES
  ADD CONSTRAINT fk_scores_user
  FOREIGN KEY (PLAYER_ID) REFERENCES USERS (PLAYER_ID)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;

ALTER TABLE STANDINGS
  ADD CONSTRAINT fk_standings_user
  FOREIGN KEY (PLAYER_ID) REFERENCES USERS (PLAYER_ID)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;
