BLOOD DONATION AND DISTRIBUTION MANAGEMENT SYSTEM
Oracle Database Setup Guide
________________________________________
📋 PROJECT INFORMATION
•	Project Name: Blood Donation and Distribution Management System
•	Student Name: Mugisha Prince Benjamin
•	Student ID: 26979
•	Group Name: Thursday Group D
•	Database Name: thur_26979_benjamin_blooddonation_db
•	Database Type: Oracle 19c Pluggable Database (PDB)
•	Phase: IV - Database Creation
________________________________________
🎯 PROJECT OVERVIEW
This database supports a comprehensive blood donation and distribution management system that handles:
•	Donor Management: Registration, eligibility screening, donation history
•	Blood Collection: Donation sessions, health checks, phlebotomist tracking
•	Laboratory Testing: Blood typing, disease screening, quality control
•	Inventory Management: Stock levels, expiration tracking, FEFO allocation
•	Request Processing: Hospital requests, urgency handling, fulfillment
•	Transfer Management: Inter-facility blood unit transfers, cold chain monitoring
•	Analytics & BI: Fact tables, dimension tables, predictive analytics
________________________________________
🏗️ DATABASE ARCHITECTURE
Database Structure:
CDB (Container Database): ORCL
└── PDB (Pluggable Database): mon_26979_benjamin_blooddonation_db
    ├── Tablespaces (7)
    ├── Users (4)
    ├── Operational Tables (17)
    ├── BI Tables (9)
    └── Supporting Objects (Views, Procedures, Triggers)
Tablespaces:
Tablespace Name	Purpose	Initial Size	Max Size	Files
BLOOD_BANK_DATA	Application data tables	500 MB	10 GB	2
BLOOD_BANK_INDEXES	Database indexes	300 MB	5 GB	1
BLOOD_BANK_LOB	Large objects (BLOB/CLOB)	200 MB	3 GB	1
BLOOD_BANK_TEMP	Temporary operations	300 MB	5 GB	1
BLOOD_BANK_UNDO	Transaction rollback	200 MB	2 GB	1
BLOOD_BANK_ARCHIVE	Historical/audit data	500 MB	10 GB	1
BLOOD_BANK_BI	Data warehouse tables	1 GB	20 GB	2
Database Users:
Username	Role	Default Tablespace	Purpose
BENJAMIN_ADMIN	Super Admin (SYSDBA)	BLOOD_BANK_DATA	Database administration
BLOOD_BANK_DEV	Developer	BLOOD_BANK_DATA	Development activities
BLOOD_BANK_APP	Application User	BLOOD_BANK_DATA	Application connections
BLOOD_BANK_READONLY	Read-Only	BLOOD_BANK_BI	Reporting and analytics
________________________________________
📦 INSTALLATION INSTRUCTIONS
Prerequisites:
1.	Oracle Database 19c installed and running
2.	Oracle Client tools (SQL*Plus, SQL Developer)
3.	Operating System: Linux/Unix or Windows
4.	Memory: Minimum 4GB RAM (8GB recommended)
5.	Disk Space: Minimum 20GB free space
6.	User Permissions: SYSDBA privileges
Step-by-Step Installation:
Step 1: Verify Oracle Installation
# Check Oracle version
sqlplus / as sysdba

SQL> SELECT * FROM V$VERSION;
Step 2: Create PDB
# Navigate to scripts directory
cd /path/to/scripts

# Run PDB creation script
sqlplus / as sysdba @01_create_pluggable_database.sql
Expected Output:
Pluggable Database Creation Completed Successfully!
Database Name: thur_26979_benjamin_blooddonation_db
Admin User: BENJAMIN_ADMIN
Status: OPEN and READY
Step 3: Create Tablespaces
sqlplus sys/oracle@localhost:1521/mon_26979_benjamin_blooddonation_db as sysdba @02_create_tablespaces.sql
Expected Output:
Tablespace Creation Completed Successfully!
Created Tablespaces:
  1. BLOOD_BANK_DATA (Primary Data)
  2. BLOOD_BANK_INDEXES (Indexes)
  3. BLOOD_BANK_LOB (Large Objects)
  4. BLOOD_BANK_TEMP (Temporary)
  5. BLOOD_BANK_UNDO (Undo)
  6. BLOOD_BANK_ARCHIVE (Archive Data)
  7. BLOOD_BANK_BI (Business Intelligence)
Step 4: Create Users and Grant Privileges
sqlplus sys/oracle@localhost:1521/mon_26979_benjamin_blooddonation_db as sysdba @03_create_admin_user.sql
Expected Output:
User Creation Completed Successfully!
Created Users:
  1. BENJAMIN_ADMIN (Super Admin)
  2. BLOOD_BANK_DEV (Developer)
  3. BLOOD_BANK_APP (Application User)
  4. BLOOD_BANK_READONLY (Read-Only User)
Step 5: Configure Memory
sqlplus sys/oracle@localhost:1521/mon_26979_benjamin_blooddonation_db as sysdba @04_configure_memory_parameters.sql
Expected Output:
Memory Configuration Completed!
Configured Parameters:
  - Memory Target: 2.5GB
  - SGA Target: 1.8GB
  - PGA Target: 700MB
  - Processes: 300
  - Sessions: 500
Note: Database restart required for memory changes.
Step 6: Enable Archive Logging
# IMPORTANT: Create archive log directories first (as oracle user)
mkdir -p /u01/app/oracle/archive/mon_26979_benjamin_blooddonation_db
mkdir -p /u01/app/oracle/archive/mon_26979_benjamin_blooddonation_db_backup
chown -R oracle:oinstall /u01/app/oracle/archive
chmod -R 755 /u01/app/oracle/archive

# Run script
sqlplus sys/oracle@localhost:1521/mon_26979_benjamin_blooddonation_db as sysdba @05_enable_archive_logging.sql
 Output:
Archive Logging Configuration Completed Successfully!
Summary:
  - Archive log mode: ENABLED
  - Primary destination: C:/app/oradata/archive/thur_26979_benjamin_blooddonation_db/
  - Force logging: ENABLED
  - Supplemental logging: ENABLED
Step 7: Restart Database (if needed)
CONNECT / AS SYSDBA

-- Shutdown database
SHUTDOWN IMMEDIATE;

-- Startup database
STARTUP;

-- Open PDB
ALTER PLUGGABLE DATABASE thur_26979_benjamin_blooddonation_db OPEN;

-- Verify
SELECT NAME, OPEN_MODE FROM V$PDBS;
________________________________________
✅ VERIFICATION
Verify PDB Creation:
CONNECT sys/oracle@localhost:1521/ORCL AS SYSDBA

SELECT 
    PDB_NAME, 
    STATUS, 
    OPEN_MODE 
FROM DBA_PDBS 
WHERE PDB_NAME = 'THUR_26979_BENJAMIN_BLOODDONATION_DB';
Expected Result:
PDB_NAME                          STATUS    OPEN_MODE
--------------------------------- --------- ----------
THUR_26979_BENJAMIN_BLOODDONATION_DB NORMAL    READ WRITE
Verify Tablespaces:
CONNECT sys/oracle@localhost:1521/mon_26979_benjamin_blooddonation_db AS SYSDBA

SELECT 
    TABLESPACE_NAME,
    STATUS,
    CONTENTS,
    ROUND(SUM(BYTES)/1024/1024, 2) AS SIZE_MB
FROM DBA_DATA_FILES
WHERE TABLESPACE_NAME LIKE 'BLOOD_BANK%'
GROUP BY TABLESPACE_NAME, STATUS, CONTENTS
ORDER BY TABLESPACE_NAME;
Verify Users:
SELECT 
    USERNAME,
    ACCOUNT_STATUS,
    DEFAULT_TABLESPACE,
    CREATED
FROM DBA_USERS
WHERE USERNAME LIKE 'BENJAMIN%' OR USERNAME LIKE 'BLOOD_BANK%'
ORDER BY CREATED;
Verify Memory Configuration:
SELECT 
    NAME,
    DISPLAY_VALUE
FROM V$PARAMETER
WHERE NAME IN ('memory_target', 'sga_target', 'pga_aggregate_target')
ORDER BY NAME;
Verify Archive Log Mode:
SELECT 
    NAME,
    LOG_MODE,
    FORCE_LOGGING
FROM V$DATABASE;
Result:
NAME                    LOG_MODE     FORCE_LOGGING
----------------------- ------------ -------------
THUR_26979_BENJAMIN_...  ARCHIVELOG   YES
________________________________________
🔐 CONNECTION STRINGS
SQL*Plus Connections:
# As SYSDBA
sqlplus sys/oracle@localhost:1521/thur_26979_benjamin_blooddonation_db as sysdba

# As Admin User
sqlplus BENJAMIN_ADMIN/Benjamin@localhost:1521/thur_26979_benjamin_blooddonation_db

# As Developer
sqlplus BLOOD_BANK_DEV/Dev123@localhost:1521/thur_26979_benjamin_blooddonation_db

# As Application User
sqlplus BLOOD_BANK_APP/App123@localhost:1521/thur_26979_benjamin_blooddonation_db

# As Read-Only User
sqlplus BLOOD_BANK_READONLY/ReadOnly123@localhost:1521/thur_26979_benjamin_blooddonation_db
JDBC Connection String:
jdbc:oracle:thin:@localhost:1521/mon_26979_benjamin_blooddonation_db
ODBC/OCI Connection:
localhost:1521/thur_26979_benjamin_blooddonation_db
________________________________________
📊 MEMORY CONFIGURATION DETAILS
Recommended Memory Allocation (4GB System):
Component	Size	Percentage	Purpose
Total Oracle Memory	2.5 GB	60% of RAM	Total allocated to Oracle
SGA Target	1.8 GB	70% of Oracle	Shared memory structures
├─ Database Buffer Cache	768 MB	43% of SGA	Data block caching
├─ Shared Pool	512 MB	28% of SGA	SQL, PL/SQL, dictionary
├─ Large Pool	256 MB	14% of SGA	Backup, parallel ops
├─ Java Pool	64 MB	4% of SGA	Java procedures
└─ Streams Pool	64 MB	4% of SGA	Data replication
PGA Target	704 MB	30% of Oracle	Session private memory
Operating System	1.5 GB	40% of RAM	OS and other processes
Scalability Guidelines:
For systems with different memory:
•	8GB RAM: Memory Target = 5GB, SGA = 3.5GB, PGA = 1.5GB
•	16GB RAM: Memory Target = 10GB, SGA = 7GB, PGA = 3GB
•	32GB RAM: Memory Target = 20GB, SGA = 14GB, PGA = 6GB
________________________________________
🔧 TROUBLESHOOTING
Issue 1: Cannot connect to PDB
Symptom:
ORA-12154: TNS:could not resolve the connect identifier specified
Solution:
-- Check PDB status
SELECT NAME, OPEN_MODE FROM V$PDBS;

-- Open PDB if closed
ALTER PLUGGABLE DATABASE thur_26979_benjamin_blooddonation_db OPEN;

-- Check listener status
lsnrctl status

-- Add to tnsnames.ora if needed
thur_26979_benjamin_blooddonation_db =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = thur_26979_benjamin_blooddonation_db)
    )
  )
Issue 2: Insufficient Memory
Symptom:
ORA-00845: MEMORY_TARGET not supported on this system
Solution:
# Increase /dev/shm size (Linux)
sudo mount -o remount,size=4G /dev/shm

# Or reduce MEMORY_TARGET
ALTER SYSTEM SET MEMORY_TARGET = 1G SCOPE=SPFILE;
Issue 3: Tablespace Full
Symptom:
ORA-01653: unable to extend table in tablespace BLOOD_BANK_DATA
Solution:
-- Add datafile
ALTER TABLESPACE BLOOD_BANK_DATA ADD DATAFILE
'C:/app/oradata/free/free/thur_26979_benjamin_blooddonation_db /blood_bank_data03.dbf'
SIZE 500M AUTOEXTEND ON NEXT 100M MAXSIZE 10G;

-- Or resize existing datafile
ALTER DATABASE DATAFILE 
'C:/app/oradata/free/free/thur_26979_benjamin_blooddonation_db/blood_bank_data01.dbf'
RESIZE 2G;
Issue 4: Archive Log Space Full
Symptom:
ORA-00257: archiver error, connect internal only until freed
Solution:
# Delete old archive logs (use RMAN)
rman target /
RMAN> DELETE ARCHIVELOG UNTIL TIME 'SYSDATE-7';

# Or increase archive log space
df -h /u01/app/oracle/archive
________________________________________
📚 MAINTENANCE TASKS
Daily Tasks:
-- Check database status
SELECT NAME, OPEN_MODE FROM V$DATABASE;
SELECT NAME, OPEN_MODE FROM V$PDBS;

-- Check alert log
tail -f C:\app\diag\rdbms\free\free\trace\alert_free.log

-- Monitor tablespace usage
SELECT 
    TABLESPACE_NAME,
    ROUND(USED_PERCENT, 2) AS USED_PCT
FROM DBA_TABLESPACE_USAGE_METRICS
WHERE TABLESPACE_NAME LIKE 'BLOOD_BANK%'
ORDER BY USED_PERCENT DESC;

-- Check archive log generation
SELECT TO_CHAR(FIRST_TIME, 'YYYY-MM-DD'), COUNT(*)
FROM V$ARCHIVED_LOG
WHERE FIRST_TIME > SYSDATE - 1
GROUP BY TO_CHAR(FIRST_TIME, 'YYYY-MM-DD');
Weekly Tasks:
-- Gather database statistics
EXEC DBMS_STATS.GATHER_DATABASE_STATS(estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE);

-- Check invalid objects
SELECT OWNER, OBJECT_TYPE, COUNT(*)
FROM DBA_OBJECTS
WHERE STATUS = 'INVALID'
GROUP BY OWNER, OBJECT_TYPE;

-- Backup database (RMAN)
-- RMAN> BACKUP DATABASE PLUS ARCHIVELOG;
Monthly Tasks:
-- Review and purge old audit logs
-- Review and archive old data
-- Performance tuning based on AWR reports
-- Update maintenance window if needed
________________________________________
📖 ADDITIONAL RESOURCES
•	Oracle Documentation: https://docs.oracle.com/en/database/oracle/oracle-database/19/
•	SQL*Plus User Guide: https://docs.oracle.com/en/database/oracle/oracle-database/19/sqpug/
•	RMAN User Guide: https://docs.oracle.com/en/database/oracle/oracle-database/19/bradv/
•	Performance Tuning Guide: https://docs.oracle.com/en/database/oracle/oracle-database/19/tgdba/
________________________________________
👤 CONTACT INFORMATION
•	Student: Benjamin Prince Mugisha
•	Student ID: 26979
•	Group: Thursday Group D
•	Project: Blood Donation and Distribution Management System
•	Date: December 19, 2025
________________________________________
📝 NOTES
1.	Password Security: Default passwords should be changed immediately in production
2.	Backup Strategy: Implement regular RMAN backups before production use
3.	Performance Tuning: Adjust memory parameters based on actual workload
4.	Monitoring: Set up Oracle Enterprise Manager or custom monitoring
5.	High Availability: Consider Data Guard for production deployment
Other additional notes:
Design Decision: Chose SMALLFILE tablespaces over BIGFILE for better I/O distribution
Performance Optimization: Created multiple datafiles for parallel I/O operations
Troubleshooting: Resolved ORA-32771 error by understanding BIGFILE vs SMALLFILE limitations
Database Administration: Properly managed default tablespace changes

Archive Logging Configuration
What Was Configured:

Supplemental Logging: Enabled for data integrity and replication
Monitoring Infrastructure: Created views and tables for backup management
Documentation: Complete backup procedures documented

CDB-Level Requirements (Noted for Production):

Archive logging must be enabled at CDB level by DBA
Archive destinations configured globally
RMAN backup strategies implemented at CDB level

What's Ready for Production:

Database design supports archiving when enabled
Monitoring views in place
Backup procedures documented
Supplemental logging enabled for data integrity
