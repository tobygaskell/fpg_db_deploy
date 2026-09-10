-- depends: UPDATE_USERS_CREATED_AT_FROM_PLAYERS

-- The only TIMESTAMP column in the schema. Every other created_at is DATETIME
-- with a CURRENT_TIMESTAMP default; TIMESTAMP adds a 2038 ceiling and stores
-- in UTC behind a zone conversion. The conversion here runs through the
-- session zone, which is the server's (Europe/London), so every value keeps
-- the wall-clock reading clients see today. Inserts that omit the column
-- still get the default.

ALTER TABLE USERS
  MODIFY COLUMN CREATED_AT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP;
