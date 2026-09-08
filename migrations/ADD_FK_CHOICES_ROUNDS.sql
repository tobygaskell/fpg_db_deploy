-- depends: ADD_MCP_LOGS_TOKEN_KIND

-- A pick must belong to a round that exists. ROUNDS rows are never deleted
-- or renumbered, and the engine inserts the round before any pick for it
-- can be made, so RESTRICT never fires in normal operation.
--
-- Adding the key makes InnoDB check every existing row; the migration fails
-- if any (ROUND, SEASON) in CHOICES is missing from ROUNDS. Verified 0 such
-- rows in FPG, UAT_FPG and DEV_FPG on 2026-09-09.

ALTER TABLE CHOICES
  ADD CONSTRAINT fk_choices_round
  FOREIGN KEY (ROUND, SEASON) REFERENCES ROUNDS (ROUND, SEASON)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;
