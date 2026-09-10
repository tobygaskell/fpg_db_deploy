-- depends: ADD_FK_REFRESH_TOKENS_USERS

-- Expo push tokens belong to an account. A handful of rows reference player
-- ids that have no account (3 in FPG, all inactive; 3 in DEV_FPG; 0 in
-- UAT_FPG on 2026-09-10); a push token with no account behind it is useless,
-- so they go first. The primary key (player_id, token) serves the key.

DELETE FROM TOKENS
WHERE NOT EXISTS (SELECT 1 FROM USERS u WHERE u.PLAYER_ID = TOKENS.player_id);

ALTER TABLE TOKENS
  ADD CONSTRAINT fk_tokens_user
  FOREIGN KEY (player_id) REFERENCES USERS (PLAYER_ID)
  ON DELETE CASCADE
  ON UPDATE CASCADE;
