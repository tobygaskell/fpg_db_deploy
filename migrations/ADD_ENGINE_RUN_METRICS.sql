-- depends: ADD_FK_GAME_TABLES_USERS

-- The engine times each section of a run but only logs it, and the CronJob
-- keeps one successful pod, so the numbers survive about an hour. One row per
-- timed section here makes a run comparable with every run before it.
--
-- RUN_ID is a uuid the engine generates at the start of a run and writes to
-- both tables. It is not LOGS.ID because utils.connect_sql opens a new
-- connection per query, which makes LAST_INSERT_ID() useless: a second query
-- would read a fresh connection and return 0, attaching every metric to
-- nothing with no error. A generated id also lets each section be written as
-- it finishes, so a run that dies mid-way still leaves its timings.
--
-- Deliberately no foreign key to LOGS: a crashed run writes metrics and never
-- writes its LOGS row, and a key would forbid exactly the rows worth having.
-- LOGS.RUN_ID is nullable; the rows written before this are not backfilled,
-- because there is nothing to backfill them with.

ALTER TABLE LOGS ADD COLUMN RUN_ID CHAR(36) NULL;

CREATE INDEX idx_logs_run_id ON LOGS (RUN_ID);

CREATE TABLE ENGINE_RUN_METRICS (
    ID          BIGINT       NOT NULL AUTO_INCREMENT,
    RUN_ID      CHAR(36)     NOT NULL,
    SECTION     VARCHAR(50)  NOT NULL,
    DURATION_MS INT          NOT NULL,
    ITEMS       INT          NULL,
    DETAILS     VARCHAR(255) NULL,
    ROUND       INT          NULL,
    SEASON      INT          NULL,
    CREATED_AT  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ID),
    INDEX idx_engine_run_metrics_run (RUN_ID),
    -- The index the table exists for: how long has this section been taking.
    INDEX idx_engine_run_metrics_section_created (SECTION, CREATED_AT)
);
