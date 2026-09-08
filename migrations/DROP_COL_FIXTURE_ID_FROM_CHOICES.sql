-- depends: ADD_FK_SCORES_ROUNDS

-- CHOICES.FIXTURE_ID has never been written: NULL on every row in every
-- schema, omitted by the API's pick insert and the engine's auto-assign,
-- and read by nothing. Dropping it loses only NULLs.

ALTER TABLE CHOICES DROP COLUMN FIXTURE_ID;
