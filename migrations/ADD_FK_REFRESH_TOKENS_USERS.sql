-- depends: DROP_TABLE_PLAYERS

-- A refresh token is issued to a logged-in account, so its player must exist.
-- Cascade: an account's sessions go with it. Verified 0 orphans in FPG,
-- UAT_FPG and DEV_FPG on 2026-09-10; idx_player already serves the key.

ALTER TABLE REFRESH_TOKENS
  ADD CONSTRAINT fk_refresh_tokens_user
  FOREIGN KEY (player_id) REFERENCES USERS (PLAYER_ID)
  ON DELETE CASCADE
  ON UPDATE CASCADE;
