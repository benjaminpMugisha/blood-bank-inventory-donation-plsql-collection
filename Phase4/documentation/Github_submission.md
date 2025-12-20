GITHUB SUBMISSION - PHASE IV
Blood Donation Database Creation
________________________________________
📦 SUBMISSION PACKAGE
Student Information:
•	Name: Mugisha Prince Benjamin
•	Student ID: 26979
•	Group: Thursday Group D
•	Project: Blood Donation and Distribution Management System
•	Phase: IV - Database Creation
•	Date: December 19, 2025
Database Details:
•	Database Name: thur_26979_benjamin_blooddonation_db
•	Database Type: Oracle 19c Pluggable Database
•	Admin User: BENJAMIN_ADMIN
•	Admin Password: Benjamin
________________________________________
📁 SUBMITTED FILES
1. SQL Scripts (5 files)
✅ 01_create_pluggable_database.sql     (PDB creation)
✅ 02_create_tablespaces.sql           (7 tablespaces)
✅ 03_create_admin_user.sql            (Users and privileges)
✅ 04_configure_memory_parameters.sql  (SGA/PGA configuration)
✅ 05_enable_archive_logging.sql       (Backup and recovery)
2. Documentation (4 files)
✅ README.md                    (Setup guide with verification)
✅ PROJECT_STRUCTURE.md         (Complete project overview)
✅ GITHUB_SUBMISSION.md         (This file)
✅ INSTALLATION_GUIDE.pdf       (Optional: PDF version)
3. Verification Screenshots (Optional)
□ screenshot_pdb_created.png
□ screenshot_tablespaces.png
□ screenshot_users.png
□ screenshot_memory_config.png
□ screenshot_archive_mode.png
________________________________________
🚀 QUICK START GUIDE
For Instructors/Reviewers:
Step 1: Prerequisites Check
# Verify Oracle 19c is installed
sqlplus / as sysdba
SQL> SELECT * FROM V$VERSION;
Step 2: Run All Scripts
# Navigate to submission directory
cd Phase_IV_Database_Creation/scripts/

# Execute in order (each takes 1-5 minutes)
sqlplus / as sysdba @01_create_pluggable_database.sql
sqlplus sys/oracle@localhost:1521/thur_26979_benjamin_blooddonation_db as sysdba @02_create_tablespaces.sql
sqlplus sys/oracle@localhost:1521/thur_26979_benjamin_blooddonation_db as sysdba @03_create_admin_user.sql
sqlplus sys/oracle@localhost:1521/thur_26979_benjamin_blooddonation_db as sysdba @04_configure_memory_parameters.sql

# Create archive directories (as OS oracle user)
mkdir -p /u01/app/oracle/archive/thur_26979_benjamin_blooddonation_db
chmod 755 /u01/app/oracle/archive/thur_26979_benjamin_blooddonation_db

sqlplus sys/oracle@localhost:1521/thur_26979_benjamin_blooddonation_db as sysdba @05_enable_archive_logging.sql
Total Time: ~15 minutes
Step 3: Verify Installation
-- Connect as admin user
sqlplus BENJAMIN_ADMIN/Benjamin@localhost:1521/thur_26979_benjamin_blooddonation_db

-- Check database status
SELECT NAME, OPEN_MODE, LOG_MODE FROM V$DATABASE;

-- Check tablespaces
SELECT TABLESPACE_NAME, STATUS FROM DBA_TABLESPACES WHERE TABLESPACE_NAME LIKE 'BLOOD_BANK%';

-- Check users
SELECT USERNAME, ACCOUNT_STATUS FROM DBA_USERS WHERE USERNAME LIKE 'BENJAMIN%' OR USERNAME LIKE 'BLOOD_BANK%';
Expected Results:
•	Database: OPEN READ WRITE, ARCHIVELOG
•	Tablespaces: 7 tablespaces, all ONLINE
•	Users: 4 users, all OPEN
________________________________________
✅ DELIVERABLES CHECKLIST
Phase IV Requirements:
•	[x] Database Setup
o	[x] Naming format follows: thur_26979_benjamin_blooddonation_db
o	[x] Admin user: BENJAMIN_ADMIN with password Benjamin
o	[x] Super admin privileges granted
•	[x] Configuration
o	[x] 7 tablespaces created (DATA, INDEXES, LOB, TEMP, UNDO, ARCHIVE, BI)
o	[x] Data and index tablespaces separated
o	[x] Temporary tablespace configured
o	[x] Memory parameters set (SGA: 1.8GB, PGA: 704MB)
o	[x] Archive logging enabled with dual destinations
o	[x] Autoextend parameters configured
•	[x] GitHub Documentation
o	[x] Database creation scripts
o	[x] Tablespace configuration
o	[x] User setup documentation
o	[x] Project structure overview
o	[x] README with installation guide
________________________________________
📊 TECHNICAL SPECIFICATIONS
Database Configuration:
Parameter	Value	Notes
Database Name	thur_26979_benjamin_blooddonation_db	PDB name
Character Set	AL32UTF8	Unicode support
National Character Set	AL16UTF16	Unicode
Block Size	8KB	Standard
Archive Mode	ENABLED	For backup/recovery
Force Logging	ENABLED	For compliance
Tablespace Configuration:
Tablespace	Type	Initial	Max	Autoextend	Purpose
BLOOD_BANK_DATA	PERMANENT	500MB	10GB	YES	Tables
BLOOD_BANK_INDEXES	PERMANENT	300MB	5GB	YES	Indexes
BLOOD_BANK_LOB	PERMANENT	200MB	3GB	YES	LOBs
BLOOD_BANK_TEMP	TEMPORARY	300MB	5GB	YES	Sorts
BLOOD_BANK_UNDO	UNDO	200MB	2GB	YES	Rollback
BLOOD_BANK_ARCHIVE	PERMANENT	500MB	10GB	YES	Archive
BLOOD_BANK_BI	PERMANENT	1GB	20GB	YES	Analytics
Memory Configuration:
Component	Size	Percentage
SGA Target	1.8 GB	70%
- Database Buffer Cache	768 MB	43%
- Shared Pool	512 MB	28%
- Large Pool	256 MB	14%
- Java Pool	64 MB	4%
- Streams Pool	64 MB	4%
PGA Target	704 MB	30%
Total Oracle Memory	2.5 GB	100%
User Configuration:
Username	Role	Privileges	Tablespace
BENJAMIN_ADMIN	DBA	SYSDBA, DBA, ALL	BLOOD_BANK_DATA
BLOOD_BANK_DEV	Developer	CREATE, ALTER, DROP	BLOOD_BANK_DATA
BLOOD_BANK_APP	Application	SELECT, INSERT, UPDATE, DELETE	BLOOD_BANK_DATA
BLOOD_BANK_READONLY	Reporting	SELECT	BLOOD_BANK_BI
________________________________________
🧪 TESTING EVIDENCE
Test 1: PDB Creation
SELECT PDB_NAME, STATUS, OPEN_MODE 
FROM DBA_PDBS 
WHERE PDB_NAME = 'THUR_26979_BENJAMIN_BLOODDONATION_DB';
Expected: 1 row returned with STATUS='NORMAL', OPEN_MODE='READ WRITE'
Test 2: Tablespace Verification
SELECT COUNT(*) FROM DBA_TABLESPACES 
WHERE TABLESPACE_NAME LIKE 'BLOOD_BANK%';
Expected: 7
Test 3: User Login
sqlplus BENJAMIN_ADMIN/Benjamin@localhost:1521/thur_26979_benjamin_blooddonation_db
Expected: Successful connection
Test 4: Memory Configuration
SELECT NAME, DISPLAY_VALUE FROM V$PARAMETER 
WHERE NAME IN ('sga_target', 'pga_aggregate_target');
Expected: SGA=1856M, PGA=704M
Test 5: Archive Mode
SELECT LOG_MODE FROM V$DATABASE;
Expected: ARCHIVELOG
________________________________________
📸 SCREENSHOTS 

PDB Creation: Output of SELECT * FROM DBA_PDBS;
1.	Tablespaces: Output of SELECT * FROM DBA_TABLESPACES WHERE TABLESPACE_NAME LIKE 'BLOOD_BANK%';
2.	Users: Output of SELECT * FROM DBA_USERS WHERE USERNAME LIKE 'BENJAMIN%' OR USERNAME LIKE 'BLOOD_BANK%';
3.	Memory: Output of V$SGA and V$PARAMETER memory settings
4.	Archive Mode: Output showing LOG_MODE = ARCHIVELOG
________________________________________
🔍 GRADING CRITERIA MAPPING
Requirement	Location	Status
Naming Convention	01_create_pluggable_database.sql (Line 17)	✅ Complete
Admin User Creation	03_create_admin_user.sql (Line 21-35)	✅ Complete
Super Admin Privileges	03_create_admin_user.sql (Line 50-110)	✅ Complete
Tablespaces (Data/Index)	02_create_tablespaces.sql (Lines 15-140)	✅ Complete
Temporary Tablespace	02_create_tablespaces.sql (Lines 83-93)	✅ Complete
Memory Parameters	04_configure_memory_parameters.sql (Lines 60-160)	✅ Complete
Archive Logging	05_enable_archive_logging.sql (Lines 38-95)	✅ Complete
Autoextend	02_create_tablespaces.sql (All datafiles)	✅ Complete
GitHub Scripts	All 5 SQL files included	✅ Complete
README	README.md with full instructions	✅ Complete
Project Overview	PROJECT_STRUCTURE.md	✅ Complete
________________________________________
💡 ADDITIONAL FEATURES (Bonus)
Beyond requirements, this submission includes:
1.	Multiple Tablespaces: 7 specialized tablespaces (requirement: 2)
2.	Multiple Users: 4 users with different roles (requirement: 1)
3.	Custom Roles: 4 application-specific roles
4.	Password Policy: Complexity verification function
5.	Monitoring: Built-in views for tablespace and archive monitoring
6.	Dual Archive Destination: Redundancy for reliability
7.	Comprehensive Documentation: README, structure guide, installation guide
8.	Verification Scripts: All scripts include verification queries
9.	Logging: All scripts create spool logs
10.	Error Handling: PL/SQL blocks with exception handling
________________________________________
🎓 LEARNING OUTCOMES DEMONSTRATED
This project demonstrates understanding of:
•	✅ Oracle Multitenant Architecture (CDB/PDB)
•	✅ Tablespace Management (Permanent, Temporary, Undo)
•	✅ User and Privilege Management (Roles, System/Object Privileges)
•	✅ Memory Architecture (SGA, PGA, Shared Pool, Buffer Cache)
•	✅ Backup and Recovery (Archive Log Mode, RMAN readiness)
•	✅ Database Security (Password Policies, Least Privilege)
•	✅ Performance Optimization (Separate data/index, proper sizing)
•	✅ SQL*Plus Scripting (Automation, logging, verification)
•	✅ Technical Documentation (README, guides, comments)
•	✅ Best Practices (Naming conventions, standards compliance)
________________________________________
📝 SUBMISSION NOTES
For Reviewers:
1.	All scripts are self-contained - Can run independently if prerequisites met
2.	Idempotent where possible - Some scripts check for existing objects
3.	Comprehensive logging - All operations logged with SPOOL
4.	Verification included - Each script ends with verification queries
5.	Well documented - Extensive comments explaining each step
Known Limitations:
1.	File paths: Assume standard Oracle installation paths (adjust if needed)
2.	Memory settings: Optimized for 4GB RAM (scale for production)
3.	Archive directories: Must be created manually at OS level
4.	Password security: Default passwords should be changed in production
Future Enhancements (Next Phases):
•	[ ] Create all 17 operational tables
•	[ ] Create 9 BI/Analytics tables
•	[ ] Implement constraints and indexes
•	[ ] Develop PL/SQL packages
•	[ ] Load reference and sample data
•	[ ] Create views and materialized views
•	[ ] Implement ETL processes
•	[ ] Build BI reports and dashboards
________________________________________
📞 CONTACT & SUPPORT
Student Name:  Mugisha Prince Benjamin
Student ID: 26979
Email: mugishapriib@gmail.com
GitHub: https://github.com/benjaminpMugisha/blood-bank-inventory-donation-project-26979.git
For Questions:
•	Technical issues: See TROUBLESHOOTING section in README.md
•	Setup problems: See INSTALLATION_GUIDE.md
•	Verification: See VERIFICATION_GUIDE.md (if included)
________________________________________
✨ ACKNOWLEDGMENTS
Special thanks to:
•	Oracle Corporation for comprehensive documentation
•	Open-source community for best practices
•	Course instructors for guidance
•	Fellow students for collaboration
________________________________________
