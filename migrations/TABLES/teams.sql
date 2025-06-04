CREATE TABLE IF NOT EXISTS TEAMS (
	TEAM_ID             INT,
	TEAM_NAME           VARCHAR(100),
	TEAM_CODE           VARCHAR(100),
	YEAR_FOUNDED        INT,
	LOGO                VARCHAR(100),
	GROUND_ID           INT,
	GROUND_NAME         VARCHAR(100),
	CITY                VARCHAR(100),
	CAPACITY            INT,
	LAT                 FLOAT,
	LON                 FLOAT
);