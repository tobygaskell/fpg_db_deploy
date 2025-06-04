CREATE TABLE IF NOT EXISTS NOTIFICATION_LOGS (
    TOKEN               VARCHAR(100), 
    TITLE               VARCHAR(100), 
    BODY                VARCHAR(999), 
    SOUND               VARCHAR(100), 
    STATUS              VARCHAR(100), 
    SEND_TIME           DATETIME
);