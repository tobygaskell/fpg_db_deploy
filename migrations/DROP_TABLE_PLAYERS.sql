-- depends: MOVE_FK_MCP_OAUTH_TO_USERS

-- PLAYERS was the account table before the June 2026 re-signup import. It has
-- had no writer since the API switched signup to USERS on 2026-04-01, no reader
-- in the API, engine, analytics or the call_log_sessions view, and every row
-- has a USERS row. The only data USERS lacked, 29 signup dates, was copied by
-- UPDATE_USERS_CREATED_AT_FROM_PLAYERS. The nightly backup keeps the rows.
-- The PLAYER_IDS sequence is separate and stays.

DROP TABLE PLAYERS;
