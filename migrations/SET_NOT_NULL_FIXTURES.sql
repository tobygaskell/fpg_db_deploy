-- depends: DROP_COL_FIXTURE_ID_FROM_CHOICES

-- A fixture is identified by its teams, kickoff, round and season, and every
-- read filters on them: the engine derives a round's cut-off from MIN(KICKOFF)
-- and finds a player's fixture by team name, round and season. DERBY is a
-- flag the engine casts with bool(); NULL means nothing for it. Only the
-- season load notebook writes this table, and it supplies every column.
--
-- The server runs with STRICT_TRANS_TABLES, so this ALTER fails with
-- "Invalid use of NULL value" if any row holds a NULL, rather than rewriting
-- it as '', 0 or a zero date. Verified 0 NULLs in all six columns across
-- 1,140 rows in FPG, UAT_FPG and DEV_FPG on 2026-09-10. LOCATION stays
-- nullable: 19 rows have no venue and nothing reads it.

ALTER TABLE FIXTURES
  MODIFY COLUMN HOME_TEAM VARCHAR(100) NOT NULL,
  MODIFY COLUMN AWAY_TEAM VARCHAR(100) NOT NULL,
  MODIFY COLUMN KICKOFF DATETIME NOT NULL,
  MODIFY COLUMN ROUND INT NOT NULL,
  MODIFY COLUMN SEASON INT NOT NULL,
  MODIFY COLUMN DERBY BOOLEAN NOT NULL DEFAULT FALSE;
