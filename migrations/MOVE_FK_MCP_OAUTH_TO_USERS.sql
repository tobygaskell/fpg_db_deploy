-- depends: ALTER_USERS_CREATED_AT_DATETIME

-- The MCP and OAuth tables were keyed to PLAYERS(PLAYER_ID), the pre-June
-- import table that nothing reads and that every account created since
-- 2026-06-18 is missing from (54 in FPG on 2026-09-10). Those accounts were
-- refused an MCP token or an OAuth grant by the key. Re-point the four keys
-- at USERS, the account table. Verified 0 rows in any of the four tables
-- without a USERS row in FPG, UAT_FPG and DEV_FPG on 2026-09-10.

ALTER TABLE MCP_TOKENS DROP FOREIGN KEY fk_mcp_tokens_player;
ALTER TABLE MCP_TOKENS
  ADD CONSTRAINT fk_mcp_tokens_user
  FOREIGN KEY (player_id) REFERENCES USERS (PLAYER_ID)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE OAUTH_AUTH_CODES DROP FOREIGN KEY fk_oauth_codes_player;
ALTER TABLE OAUTH_AUTH_CODES
  ADD CONSTRAINT fk_oauth_codes_user
  FOREIGN KEY (player_id) REFERENCES USERS (PLAYER_ID)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE OAUTH_ACCESS_TOKENS DROP FOREIGN KEY fk_oauth_access_player;
ALTER TABLE OAUTH_ACCESS_TOKENS
  ADD CONSTRAINT fk_oauth_access_user
  FOREIGN KEY (player_id) REFERENCES USERS (PLAYER_ID)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE OAUTH_REFRESH_TOKENS DROP FOREIGN KEY fk_oauth_refresh_player;
ALTER TABLE OAUTH_REFRESH_TOKENS
  ADD CONSTRAINT fk_oauth_refresh_user
  FOREIGN KEY (player_id) REFERENCES USERS (PLAYER_ID)
  ON DELETE CASCADE
  ON UPDATE CASCADE;
