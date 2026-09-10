-- depends: SET_NOT_NULL_FIXTURES

-- PLAYERS.CREATED_AT holds the genuine signup time for the legacy players who
-- joined between 2025-07-01, when the column was added, and 2026-04-01, when
-- signup moved to USERS. The June 2026 import overwrote every USERS date with
-- the import date. Copy the earlier date back where one exists; players with
-- no recorded date keep the import date. 29 rows in FPG, 0 in UAT_FPG and
-- DEV_FPG on 2026-09-10. Runs before PLAYERS is dropped.

UPDATE USERS u
JOIN PLAYERS p ON p.PLAYER_ID = u.PLAYER_ID
SET u.CREATED_AT = p.CREATED_AT
WHERE p.CREATED_AT IS NOT NULL
  AND p.CREATED_AT < u.CREATED_AT;
