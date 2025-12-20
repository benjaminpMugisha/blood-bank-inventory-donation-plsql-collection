-- ============================================================================
-- Script: 05_enable_archive_logging.sql
-- Purpose: Enable and configure archive logging for backup and recovery
-- Author: Benjamin (Student ID: 26979)
-- Date: December 19, 2025
-- ============================================================================

-- Connect as SYSDBA
CONNECT sys/oracle@localhost:1521/thur_26979_benjamin_blooddonation_db AS SYSDBA

SET ECHO ON
SET SERVEROUTPUT ON
SPOOL enable_archivelog.log

PROMPT ============================================================
PROMPT Enabling Archive Logging for Blood Donation Database
PROMPT ============================================================

-- ============================================================================
-- STEP 1: CHECK CURRENT ARCHIVE LOG MODE
-- ============================================================================

PROMPT ============================================================
PROMPT Checking Current Archive Log Status
PROMPT ============================================================

SELECT 
    NAME,
    LOG_MODE,
    OPEN_MODE,
    DATABASE_ROLE
FROM V$DATABASE;

-- Check archive log destination
SELECT 
    DEST_ID,
    DEST_NAME,
    DESTINATION,
    STATUS,
    BINDING
FROM V$ARCHIVE_DEST
WHERE DEST_ID <=2;

-- ============================================================================
-- STEP 2: CONFIGURE ARCHIVE LOG DESTINATION
-- ============================================================================

PROMPT ============================================================
PROMPT Configuring Archive Log Destination
PROMPT ============================================================

-- Set primary archive log destination
ALTER SYSTEM SET LOG_ARCHIVE_DEST_1 = 
'LOCATION=C:/app/oradata/FREE/THUR_26979_BENJAMIN_BLOODDONATION_DB/ VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=THUR_26979_BENJAMIN_BLOODDONATION_DB'
SCOPE=BOTH;

-- Set secondary archive log destination (optional - for redundancy)
ALTER SYSTEM SET LOG_ARCHIVE_DEST_2 = 
'LOCATION=C:/app/oradata/FREE/THUR_26979_BENJAMIN_BLOODDONATION_DB_backup/ OPTIONAL VALID_FOR=(ALL_LOGFILES,ALL_ROLES)'
SCOPE=BOTH;

-- Set archive log format
ALTER SYSTEM SET LOG_ARCHIVE_FORMAT = 'arch_%t_%s_%r.arc' SCOPE=SPFILE;

-- Set minimum successful destinations
ALTER SYSTEM SET LOG_ARCHIVE_MIN_SUCCEED_DEST = 1 SCOPE=BOTH;

-- Enable archive log destination status
ALTER SYSTEM SET LOG_ARCHIVE_DEST_STATE_1 = ENABLE SCOPE=BOTH;
ALTER SYSTEM SET LOG_ARCHIVE_DEST_STATE_2 = ENABLE SCOPE=BOTH;

PROMPT Archive log destinations configured

-- ============================================================================
-- STEP 3: CONFIGURE ADDITIONAL ARCHIVE LOG PARAMETERS
-- ============================================================================

PROMPT ============================================================
PROMPT Configuring Additional Archive Log Parameters
PROMPT ============================================================

-- Archive lag target (in seconds) - force log switch every 30 minutes
ALTER SYSTEM SET ARCHIVE_LAG_TARGET = 1800 SCOPE=BOTH;

-- Log archive max processes
ALTER SYSTEM SET LOG_ARCHIVE_MAX_PROCESSES = 4 SCOPE=BOTH;

-- Log archive min log members
-- ALTER SYSTEM SET LOG_ARCHIVE_MIN_LOG_MEMBERS = 2 SCOPE=SPFILE;

-- Log archive trace
ALTER SYSTEM SET LOG_ARCHIVE_TRACE = 0 SCOPE=BOTH;

PROMPT Additional parameters configured

-- ============================================================================
-- STEP 4: CREATE ARCHIVE LOG DIRECTORY
-- ============================================================================

PROMPT ============================================================
PROMPT Creating Archive Log Directory (Run as OS user)
PROMPT ============================================================

-- Note: These commands must be run at OS level by oracle user:
-- mkdir -p /u01/app/oracle/archive/mon_26979_benjamin_blooddonation_db
-- mkdir -p /u01/app/oracle/archive/mon_26979_benjamin_blooddonation_db_backup
-- chown -R oracle:oinstall /u01/app/oracle/archive
-- chmod -R 755 /u01/app/oracle/archive

PROMPT Archive log directories should be created at OS level

-- ============================================================================
-- STEP 5: ENABLE ARCHIVE LOG MODE
-- ============================================================================

PROMPT ============================================================
PROMPT Enabling Archive Log Mode
PROMPT ============================================================

-- Shutdown database
SHUTDOWN IMMEDIATE;

-- Startup in mount mode
STARTUP MOUNT;

-- Enable archive log mode
ALTER DATABASE ARCHIVELOG;

-- Open database
ALTER DATABASE OPEN;

PROMPT Archive log mode enabled successfully

-- ============================================================================
-- STEP 6: VERIFY ARCHIVE LOG CONFIGURATION
-- ============================================================================

PROMPT ============================================================
PROMPT Verifying Archive Log Configuration
PROMPT ============================================================

-- Check archive log mode
SELECT 
    NAME AS DATABASE_NAME,
    LOG_MODE,
    FORCE_LOGGING
FROM V$DATABASE;

-- Check archive log destinations
SELECT 
    DEST_ID,
    DEST_NAME,
    DESTINATION,
    STATUS,
    BINDING,
    TARGET
FROM V$ARCHIVE_DEST
WHERE STATUS != 'INACTIVE'
ORDER BY DEST_ID;

-- Check archive log format
SELECT 
    NAME,
    VALUE
FROM V$PARAMETER
WHERE NAME LIKE 'log_archive%'
ORDER BY NAME;

-- Display current log files
SELECT 
    GROUP#,
    THREAD#,
    SEQUENCE#,
    BYTES/1024/1024 AS SIZE_MB,
    MEMBERS,
    ARCHIVED,
    STATUS
FROM V$LOG
ORDER BY GROUP#;

-- Display log file members
SELECT 
    L.GROUP#,
    LF.MEMBER,
    L.STATUS,
    L.ARCHIVED,
    LF.TYPE
FROM V$LOG L
JOIN V$LOGFILE LF ON L.GROUP# = LF.GROUP#
ORDER BY L.GROUP#, LF.MEMBER;

-- ============================================================================
-- STEP 7: CONFIGURE REDO LOG FILES
-- ============================================================================

PROMPT ============================================================
PROMPT Configuring Redo Log Files
PROMPT ============================================================

-- Add additional redo log groups for better performance
-- Recommendation: At least 3 groups with 2 members each

-- Check current redo log configuration
SELECT 
    GROUP#,
    THREAD#,
    SEQUENCE#,
    BYTES/1024/1024 AS SIZE_MB,
    MEMBERS,
    STATUS
FROM V$LOG
ORDER BY GROUP#;

-- Add new redo log groups (if needed)
BEGIN
    FOR rec IN (SELECT COUNT(*) AS CNT FROM V$LOG) LOOP
        IF rec.CNT < 3 THEN
            DBMS_OUTPUT.PUT_LINE('Adding additional redo log groups...');
            
            -- Add group 4
            EXECUTE IMMEDIATE 
            'ALTER DATABASE ADD LOGFILE GROUP 4 
            (''C:/app/oradata/FREE/THUR_26979_BENJAMIN_BLOODDONATION_DB/redo04a.log'',
             ''C:/app/oradata/FREE/THUR_26979_BENJAMIN_BLOODDONATION_DB/redo04b.log'')
            SIZE 100M';
            
            -- Add group 5
            EXECUTE IMMEDIATE 
            'ALTER DATABASE ADD LOGFILE GROUP 5 
            (''C:/app/oradata/FREE/THUR_26979_BENJAMIN_BLOODDONATION_DB/redo05a.log'',
             ''C:/app/oradata/FREE/THUR_26979_BENJAMIN_BLOODDONATION_DB/redo05b.log'')
            SIZE 100M';
            
            DBMS_OUTPUT.PUT_LINE('Additional redo log groups added successfully');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Sufficient redo log groups already exist');
        END IF;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Note: Additional redo log groups may already exist or path may differ');
END;
/

-- ============================================================================
-- STEP 8: FORCE LOG SWITCH AND CHECK ARCHIVING
-- ============================================================================

PROMPT ============================================================
PROMPT Testing Archive Log Functionality
PROMPT ============================================================

-- Force a log switch
ALTER SYSTEM SWITCH LOGFILE;

-- Wait for archiving
EXEC DBMS_LOCK.SLEEP(5);

-- Check archived logs
SELECT 
    SEQUENCE#,
    FIRST_TIME,
    NEXT_TIME,
    BLOCKS,
    BLOCK_SIZE,
    BLOCKS * BLOCK_SIZE / 1024 / 1024 AS SIZE_MB,
    ARCHIVED,
    APPLIED,
    DELETED,
    STATUS
FROM V$ARCHIVED_LOG
WHERE FIRST_TIME > SYSDATE - 1
ORDER BY SEQUENCE# DESC;

-- Count archived logs
SELECT 
    COUNT(*) AS TOTAL_ARCHIVED_LOGS,
    ROUND(SUM(BLOCKS * BLOCK_SIZE)/1024/1024/1024, 2) AS TOTAL_SIZE_GB
FROM V$ARCHIVED_LOG
WHERE DEST_ID = 1;

-- ============================================================================
-- STEP 9: CONFIGURE ARCHIVE LOG DELETION POLICY
-- ============================================================================

PROMPT ============================================================
PROMPT Configuring Archive Log Retention Policy
PROMPT ============================================================

-- Configure RMAN retention policy
-- Note: This requires RMAN connection
-- RMAN> CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;
-- RMAN> CONFIGURE ARCHIVELOG DELETION POLICY TO BACKED UP 1 TIMES TO DISK;

-- Create procedure to purge old archive logs
CREATE OR REPLACE PROCEDURE PURGE_OLD_ARCHIVE_LOGS(
    p_days_to_keep IN NUMBER DEFAULT 7
) AS
    v_date DATE;
BEGIN
    v_date := SYSDATE - p_days_to_keep;
    
    -- Delete obsolete archive logs (use RMAN for production)
    DBMS_OUTPUT.PUT_LINE('Archive logs older than ' || TO_CHAR(v_date, 'DD-MON-YYYY') || 
                        ' should be deleted using RMAN');
    DBMS_OUTPUT.PUT_LINE('Command: DELETE ARCHIVELOG UNTIL TIME ''SYSDATE-7'';');
END;
/

PROMPT Archive log retention policy configured

-- ============================================================================
-- STEP 10: ENABLE FORCE LOGGING
-- ============================================================================

PROMPT ============================================================
PROMPT Enabling Force Logging
PROMPT ============================================================

-- Enable force logging for the entire database
ALTER DATABASE FORCE LOGGING;

-- Verify force logging
SELECT 
    NAME,
    FORCE_LOGGING,
    LOG_MODE
FROM V$DATABASE;

PROMPT Force logging enabled

-- ============================================================================
-- STEP 11: CONFIGURE SUPPLEMENTAL LOGGING (For Data Guard/Streams)
-- ============================================================================

PROMPT ============================================================
PROMPT Configuring Supplemental Logging
PROMPT ============================================================

-- Enable supplemental logging
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;

-- Enable supplemental logging for primary keys
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (PRIMARY KEY) COLUMNS;

-- Enable supplemental logging for unique indexes
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (UNIQUE) COLUMNS;

-- Verify supplemental logging
SELECT 
    SUPPLEMENTAL_LOG_DATA_MIN,
    SUPPLEMENTAL_LOG_DATA_PK,
    SUPPLEMENTAL_LOG_DATA_UI
FROM V$DATABASE;

PROMPT Supplemental logging configured

-- ============================================================================
-- STEP 12: CREATE MONITORING VIEW
-- ============================================================================

PROMPT ============================================================
PROMPT Creating Archive Log Monitoring View
PROMPT ============================================================

CREATE OR REPLACE VIEW V_ARCHIVE_LOG_STATUS AS
SELECT 
    TO_CHAR(FIRST_TIME, 'YYYY-MM-DD') AS LOG_DATE,
    COUNT(*) AS ARCHIVE_COUNT,
    ROUND(SUM(BLOCKS * BLOCK_SIZE)/1024/1024, 2) AS TOTAL_MB,
    MIN(SEQUENCE#) AS MIN_SEQUENCE,
    MAX(SEQUENCE#) AS MAX_SEQUENCE
FROM V$ARCHIVED_LOG
WHERE DEST_ID = 1
  AND FIRST_TIME > SYSDATE - 30
GROUP BY TO_CHAR(FIRST_TIME, 'YYYY-MM-DD')
ORDER BY LOG_DATE DESC;

-- Grant access to admin user
GRANT SELECT ON V_ARCHIVE_LOG_STATUS TO BENJAMIN_ADMIN;

-- Query the view
SELECT * FROM V_ARCHIVE_LOG_STATUS WHERE ROWNUM <= 7;

PROMPT Monitoring view created

-- ============================================================================
-- STEP 13: DOCUMENT BACKUP AND RECOVERY PROCEDURES
-- ============================================================================

PROMPT ============================================================
PROMPT Backup and Recovery Procedures
PROMPT ============================================================

-- Create documentation table
CREATE TABLE BACKUP_RECOVERY_PROCEDURES (
    procedure_id NUMBER PRIMARY KEY,
    procedure_name VARCHAR2(100),
    procedure_type VARCHAR2(50),
    description CLOB,
    command_syntax CLOB,
    frequency VARCHAR2(50),
    created_date DATE DEFAULT SYSDATE
);

-- Insert backup procedures
INSERT INTO BACKUP_RECOVERY_PROCEDURES VALUES (
    1,
    'Full Database Backup',
    'RMAN BACKUP',
    'Complete backup of entire database including all datafiles, control files, and SPFile',
    'RMAN> BACKUP DATABASE PLUS ARCHIVELOG;',
    'Weekly',
    SYSDATE
);

INSERT INTO BACKUP_RECOVERY_PROCEDURES VALUES (
    2,
    'Incremental Backup',
    'RMAN BACKUP',
    'Incremental backup capturing only changed blocks since last backup',
    'RMAN> BACKUP INCREMENTAL LEVEL 1 DATABASE;',
    'Daily',
    SYSDATE
);

INSERT INTO BACKUP_RECOVERY_PROCEDURES VALUES (
    3,
    'Archive Log Backup',
    'RMAN BACKUP',
    'Backup of archive log files',
    'RMAN> BACKUP ARCHIVELOG ALL DELETE INPUT;',
    'Every 6 hours',
    SYSDATE
);

INSERT INTO BACKUP_RECOVERY_PROCEDURES VALUES (
    4,
    'Control File Backup',
    'RMAN BACKUP',
    'Backup of control file and SPFile',
    'RMAN> BACKUP CURRENT CONTROLFILE;',
    'Daily',
    SYSDATE
);

COMMIT;

-- Grant access
GRANT SELECT ON BACKUP_RECOVERY_PROCEDURES TO BENJAMIN_ADMIN;

-- Display procedures
SELECT 
    procedure_name,
    procedure_type,
    frequency
FROM BACKUP_RECOVERY_PROCEDURES
ORDER BY procedure_id;

PROMPT Backup procedures documented

-- ============================================================================
-- SCRIPT COMPLETION
-- ============================================================================

PROMPT ============================================================
PROMPT Archive Logging Configuration Completed Successfully!
PROMPT 
PROMPT Summary:
PROMPT   - Archive log mode: ENABLED
PROMPT   - Primary destination: C:/app/oradata/FREE/THUR_26979_BENJAMIN_BLOODDONATION_DB/
PROMPT   - Secondary destination: C:/app/oradata/FREE/THUR_26979_BENJAMIN_BLOODDONATION_DB_backup/
PROMPT   - Force logging: ENABLED
PROMPT   - Supplemental logging: ENABLED
PROMPT   - Archive lag target: 1800 seconds (30 minutes)
PROMPT 
PROMPT Next Steps:
PROMPT   1. Configure RMAN backup strategy
PROMPT   2. Schedule regular backups
PROMPT   3. Test recovery procedures
PROMPT   4. Monitor archive log space usage
PROMPT 
PROMPT Important Commands:
PROMPT   - Force log switch: ALTER SYSTEM SWITCH LOGFILE;
PROMPT   - Check archive status: SELECT * FROM V_ARCHIVE_LOG_STATUS;
PROMPT   - Monitor space: SELECT * FROM V$RECOVERY_FILE_DEST;
PROMPT ============================================================

SPOOL OFF;
EXIT;

