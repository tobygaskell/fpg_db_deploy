# CLAUDE.md

Guidance for Claude Code when working in this repository. This file is the source of truth for how the schema is managed today; design history lives in `FPG-APP/fpg-docs`.

Before feature work, check `INDEX.md` and the issues in `FPG-APP/fpg-docs`. Work that spans repos or changes the schema, scoring, auth, or player-visible behaviour needs a design and a plan there first. Branch names and PR titles start with the initiative slug (for example `blog-automation/ghost-draft-cli`); PR bodies link `FPG-APP/fpg-docs#<issue>`. When your change goes live, update that initiative's status card in the same session.

## What this repo does

Owns the schema of the FPG database: MariaDB 11.8 on the Raspberry Pi `fpg-database` (LAN `192.168.0.161`), with one schema per environment: `FPG` (production), `UAT_FPG` (testing), `DEV_FPG` (development). Changes are plain SQL files applied with [Yoyo Migrations](https://ollycope.com/software/yoyo/latest/), by GitHub Actions on push or by hand.

## Commands

```bash
uv sync --locked
uv run yoyo list                              # applied / pending
uv run yoyo apply                             # apply pending (add -b for non-interactive)
uv run yoyo reapply --revision populate_dev   # re-run the local dev refresh script; only ever against DEV_FPG
```

The database is LAN-only. From a laptop, open the tunnel first (`db-tunnel` in `~/.zshrc`, or `ssh -L 3306:127.0.0.1:3306 database`) and point `yoyo.ini` at `127.0.0.1`. Inside the cluster the host is the `mariadb` service.

## Configuration

`yoyo.ini` is gitignored because it carries credentials. Create it locally:

```ini
[DEFAULT]
sources = migrations migrations/TABLES
database = mysql://USER:PASS@127.0.0.1/DEV_FPG     # or UAT_FPG / FPG
batch_mode = off
verbosity = 2
```

CI generates the same file from GitHub environment secrets and sets `batch_mode = on`. Batch mode only suppresses prompts; MariaDB auto-commits DDL, so a failed run leaves earlier migrations applied. Yoyo tracks state in `_yoyo_migration`, `_yoyo_log`, `_yoyo_version` and `yoyo_lock`; never edit those by hand.

## Layout

```
.
├── migrations/               # ALTER, index, constraint, sequence and data migrations, plus two CREATE TABLE files
│   └── TABLES/               # 21 base CREATE TABLE migrations, lowercase file names
├── .github/
│   ├── workflows/            # deploy_db_testing.yml (develop), deploy_db_prod.yml (main); both also workflow_dispatch
│   └── actions/yoyo_deploy/  # composite action shared by both
├── pyproject.toml, uv.lock   # uv-managed; Python 3.11
└── README.md
```

## Authoring a migration

- File names are descriptive, no dates or sequence numbers. Root files are `UPPERCASE_VERB_OBJECT.sql` (`ADD_COL_ACTIVE_TO_TOKENS.sql`); `TABLES/` files are the bare lowercase table name (`mini_leagues.sql`). `populate_dev.sql`, the gitignored local file described under Gotchas, is the one exception.
- Start every new file with `-- depends: <current chain tail>` so Yoyo orders it after everything else. The chain tail is `ADD_FK_GAME_TABLES_USERS`, the last of an eleven-file chain that starts at `UPDATE_USERS_CREATED_AT_FROM_PLAYERS` (which depends on `SET_NOT_NULL_FIXTURES`). About twenty older files have no header and rely on scan order; do not add to that set.
- New tables have recently been created from root files (`ADD_MCP_TOKENS_AND_LOGS.sql`, `ADD_OAUTH_TABLES.sql`) rather than `TABLES/`. Either location works; the depends header is what matters.
- No rollback files exist, so `yoyo rollback` does nothing. Recovery is a forward migration or a restore from the nightly backup.
- Migrations that touch data before adding constraints (`ADD_UNIQUE_USERS_EMAIL`, `ADD_UNIQUE_USERS_USERNAME`, `ADD_FK_TOKENS_USERS`) fail on duplicates or orphans; check the data first.

## Schema

Twenty-eight tables, one sequence and one hand-made view exist in production today.

| Table | Purpose |
|---|---|
| `USERS` | Auth and profile: email, Argon2 hash, username, full name, fav team, `IS_DISABLED`, `EMAIL_OPT_OUT`; `CREATED_AT` is the signup time for accounts since 2025-07-01 and the June 2026 import date for older ones. Parent of every player foreign key |
| `PLAYER_IDS` | Sequence for new player IDs (created by `SEQ_PLAYER_IDS.sql`, starts at 4001) |
| `TEAMS` | Premier League teams per season |
| `FIXTURES`, `RESULTS` | Per-round schedule and results. `FIXTURES` teams, `KICKOFF`, `ROUND`, `SEASON` and `DERBY` are NOT NULL (`SET_NOT_NULL_FIXTURES`); `LOCATION` is not. `RESULTS` (`HOME_GOALS`, `AWAY_GOALS`, `WINNER`, `GAME_STATUS`) holds a row for every fixture of a closed round, with NULL goals and `WINNER` when the match was not finished |
| `ROUNDS` | Round metadata: `CUT_OFF`, `DP_ROUND`, `DMM_ROUND` |
| `CURRENT_ROUND` | Singleton: `ROUND_ID`, `SEASON`, `OFF_SEASON`, `NEXT_SEASON_DATE` |
| `CHOICES` | One pick per player per round; `METHOD` marks auto-assigned picks; `(ROUND, SEASON)` is a foreign key to `ROUNDS` |
| `SCORES` | Per-player per-round points with every modifier column; `SUBTOTAL` is post-doubling; `(ROUND, SEASON)` is a foreign key to `ROUNDS` |
| `STANDINGS` | Season standings written by the engine |
| `MINI_LEAGUES`, `MINI_LEAGUE_MEMBERS`, `MINI_LEAGUE_SCORES`, `MINI_LEAGUE_STANDINGS` | Mini-leagues |
| `REFRESH_TOKENS` | Hashed JWT refresh tokens with expiry |
| `PASSWORD_RESET_TOKENS` | Password reset flow |
| `TOKENS` | Expo push tokens (`ACTIVE`, `CREATED_AT`) |
| `MCP_TOKENS`, `MCP_LOGS` | MCP personal access tokens and audit log |
| `OAUTH_CLIENTS`, `OAUTH_AUTH_CODES`, `OAUTH_ACCESS_TOKENS`, `OAUTH_REFRESH_TOKENS` | OAuth for MCP clients |
| `CALL_LOGS` | One row per authenticated API request; `STATUS_CODE`, `DURATION_MS`, `PLATFORM` are NULL before their migration |
| `LOGS`, `NOTIFICATION_LOGS`, `ERROR_LOGS` | Engine run log, push sends, caught exceptions |

Most game tables carry a `SEASON` column. Foreign keys: `RESULTS` to `FIXTURES`; `CHOICES`, `SCORES`, `MINI_LEAGUE_SCORES` and `MINI_LEAGUE_STANDINGS` to `ROUNDS` on `(ROUND, SEASON)`; `MINI_LEAGUE_MEMBERS`, `MINI_LEAGUE_SCORES` and `MINI_LEAGUE_STANDINGS` to `MINI_LEAGUES`; and `PLAYER_ID` keys to `USERS` from `CHOICES`, `SCORES`, `STANDINGS`, `MINI_LEAGUES` (`CREATED_BY`), the three mini-league child tables, `REFRESH_TOKENS`, `TOKENS`, `MCP_TOKENS` and the three OAuth token tables. Delete rule: sessions and memberships (`REFRESH_TOKENS`, `TOKENS`, MCP and OAuth tokens, `MINI_LEAGUE_MEMBERS`) cascade from `USERS`, and league children cascade from `MINI_LEAGUES`; game history and league ownership restrict, so an account with picks cannot be deleted. Nothing deletes accounts today; deactivation sets `IS_DISABLED`. There is no key from `FIXTURES` to `ROUNDS`, because a season's fixtures are loaded up front while the engine creates each round's row as it opens.

Time columns are `DATETIME` with whole seconds; `TIMESTAMP` is not used. Audit columns (`created_at`, `expires_at`, `LOGS.TIME_ADDED`, `CALL_LOGS.call_time` and the like) are filled by `CURRENT_TIMESTAMP` or `NOW()` in the server's time zone, which is `SYSTEM` (Europe/London). `FIXTURES.KICKOFF` and `ROUNDS.CUT_OFF` are UTC as api-football supplies them, and the API sends them out without a zone; that mismatch and its consequences are FPG-APP/fpg-docs#64.

`call_log_sessions` is a view in `FPG` only, created by hand for fpg-analytics; it is in no migration and does not exist in `UAT_FPG`.

## Deployment

| Branch | Workflow | Target |
|---|---|---|
| `develop` | `deploy_db_testing.yml` | `UAT_FPG` |
| `main` | `deploy_db_prod.yml` | `FPG` |

Both run on the self-hosted runner (the database is not reachable from GitHub's runners), use GitHub environments `development` and `production`, and call the composite action: `astral-sh/setup-uv`, `uv sync --locked`, write `yoyo.ini` from secrets and vars, `uv run yoyo list`, `uv run yoyo apply` in batch mode. Pushing to the branch is the deploy.

## Backups

A CronJob in fpg-k8s (`db-backup-cron`, prod namespace, 02:00 daily) runs `mysqldump --all-databases --single-transaction --routines --triggers --events`, gzips it and uploads to Cloudflare R2. No restore has been rehearsed yet.

## Gotchas in the migration history

- `populate_dev.sql` is not in the repo: it is gitignored beside `yoyo.ini` and exists only on the laptop and as an applied row in `DEV_FPG._yoyo_migration`. It truncates seventeen tables (`USERS`, `TOKENS` and the four mini-league tables among them) and copies `FPG.*` into the current schema inside a `SET FOREIGN_KEY_CHECKS = 0` / `= 1` pair, because a parent of a foreign key cannot be truncated otherwise, then deletes rows in the session tables it does not copy (`REFRESH_TOKENS`, `MCP_TOKENS`, the OAuth tables) whose account is not in the copied `USERS`, so the keys to `USERS` hold; the `CHOICES` copy names its columns since `FIXTURE_ID` was dropped. It is otherwise column-order dependent and would wipe production if ever applied to `FPG`; only reapply it against `DEV_FPG`.
- `DROP_FK_CHOICES_SCORES_PLAYERS` drops foreign keys whose `ADD_*` files were deleted from the repo; dev and testing carry orphaned `_yoyo_migration` rows for them, production never had them. The keys came back in September 2026 pointing at `USERS` (`ADD_FK_GAME_TABLES_USERS`) once every legacy player had a `USERS` row, and `PLAYERS` was dropped (`DROP_TABLE_PLAYERS`) after its 29 recorded signup dates were copied into `USERS.CREATED_AT`.
- `INSERT_TOBY_INTO_USERS` seeds a real account in every schema. `INIT_ROUND_1_2025`, `UPDATE_CURRENT_ROUND_2025` and `INSERT_2024_INTO_SEASONS` are season data scripts (the last is an UPDATE; there is no `SEASONS` table).
- `ADD_COLS_STANDINGS` renames `OVERALL_TOTAL` to `SCORE` and assumes an empty table.
- A stale `venv/` (Python 3.13, built for an old path) sits beside the real `.venv/`; both are ignored. Use `uv`.
