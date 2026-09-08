-- depends: ADD_FK_CHOICES_ROUNDS

-- A score must belong to a round that exists. The engine deletes and
-- re-inserts SCORES rows per round, always for a round already in ROUNDS.
-- Verified 0 orphan (ROUND, SEASON) pairs in all three schemas on 2026-09-09.

ALTER TABLE SCORES
  ADD CONSTRAINT fk_scores_round
  FOREIGN KEY (ROUND, SEASON) REFERENCES ROUNDS (ROUND, SEASON)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;
