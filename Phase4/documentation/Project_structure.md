BLOOD DONATION MANAGEMENT SYSTEM
PROJECT STRUCTURE OVERVIEW
________________________________________
📁 DIRECTORY STRUCTURE
thur_26979_benjamin_blooddonation/
│
├── Phase_III_Logical_Model/
│   ├── ER_Diagram.md                    # Entity-Relationship Diagram (Mermaid)
│   ├── Data_Dictionary.md               # Complete data dictionary
│   ├── Normalization_Documentation.md   # 1NF, 2NF, 3NF process
│   ├── BI_Considerations.md             # Fact/Dimension tables design
│   └── Assumptions_Constraints.md       # Business and technical assumptions
│
├── Phase_IV_Database_Creation/
│   ├── scripts/
│   │   ├── 01_create_pluggable_database.sql
│   │   ├── 02_create_tablespaces.sql
│   │   ├── 03_create_admin_user.sql
│   │   ├── 04_configure_memory_parameters.sql
│   │   ├── 05_enable_archive_logging.sql
│   │   ├── 06_create_operational_tables.sql      # (Next phase)
│   │   ├── 07_create_bi_tables.sql               # (Next phase)
│   │   ├── 08_create_constraints.sql             # (Next phase)
│   │   ├── 09_create_indexes.sql                 # (Next phase)
│   │   ├── 10_create_sequences.sql               # (Next phase)
│   │   ├── 11_create_views.sql                   # (Next phase)
│   │   ├── 12_create_procedures.sql              # (Next phase)
│   │   ├── 13_create_triggers.sql                # (Next phase)
│   │   ├── 14_insert_reference_data.sql          # (Next phase)
│   │   └── 15_insert_sample_data.sql             # (Next phase)
│   │
│   ├── logs/
│   │   ├── create_pluggable_database.log
│   │   ├── create_tablespaces.log
│   │   ├── create_admin_user.log
│   │   ├── configure_memory.log
│   │   └── enable_archivelog.log
│   │
│   ├── backups/
│   │   ├── rman/                        # RMAN backup files
│   │   └── exports/                     # Data Pump exports
│   │
│   └── documentation/
│       ├── README.md                    # Setup guide
│       ├── PROJECT_STRUCTURE.md         # This file
│       ├── INSTALLATION_GUIDE.md        # Detailed installation steps
│       └── VERIFICATION_GUIDE.md        # Testing and verification
│
├── Phase_V_Data_Population/             
│   ├── reference_data/
│   ├── sample_data/
│   └── test_data/
│
├── Phase_VI_PLSQL_Development/          
│   ├── packages/
│   ├── procedures/
│   ├── functions/
│   └── triggers/
│
└── Phase_VII_BI_Analytics/              
    ├── etl_scripts/
    ├── reports/
    └── dashboards/
________________________________________
📊 DATABASE OBJECTS HIERARCHY
Level 1: Database Foundation
CDB: ORCL
  └── PDB: thur_26979_benjamin_blooddonation_db
Level 2: Storage Structure
Tablespaces (7):
  1. BLOOD_BANK_DATA          (Primary application data)
  2. BLOOD_BANK_INDEXES       (Database indexes)
  3. BLOOD_BANK_LOB           (Large objects)
  4. BLOOD_BANK_TEMP          (Temporary operations)
  5. BLOOD_BANK_UNDO          (Transaction management)
  6. BLOOD_BANK_ARCHIVE       (Historical data)
  7. BLOOD_BANK_BI            (Data warehouse)
Level 3: Security Layer
Users (4):
  1. BENJAMIN_ADMIN           (DBA)
  2. BLOOD_BANK_DEV           (Developer)
  3. BLOOD_BANK_APP           (Application)
  4. BLOOD_BANK_READONLY      (Reporting)

Roles (4):
  1. BLOOD_BANK_ADMIN_ROLE
  2. BLOOD_BANK_DEVELOPER_ROLE
  3. BLOOD_BANK_APP_USER_ROLE
  4. BLOOD_BANK_READONLY_ROLE
Level 4: Data Objects
Operational Tables (17):
  Core Entities:
    • DONORS
    • DONATIONS
    • BLOOD_UNITS
    • TEST_RESULTS
    • FACILITIES
    • REQUESTS
    • TRANSFERS
  
  Supporting Entities:
    • REQUEST_ITEMS
    • TRANSFER_ITEMS
    • ELIGIBILITY_CHECKS
    • APPOINTMENTS
    • INVENTORY
    • DONOR_DEFERRALS
    • BLOOD_UNIT_HISTORY
    • DONATION_ADVERSE_EVENTS
    • FACILITY_STAFF
    • EQUIPMENT

BI/Analytics Tables (9):
  Fact Tables:
    • FACT_DONATIONS
    • FACT_BLOOD_UNITS
    • FACT_REQUESTS
    • FACT_TRANSFERS
  
  Dimension Tables:
    • DIM_DATE
    • DIM_DONOR
    • DIM_FACILITY
    • DIM_BLOOD_TYPE
    • DIM_STAFF
  
  Aggregate Tables:
    • AGG_DAILY_INVENTORY
    • AGG_MONTHLY_DONOR_STATS
    • AGG_FACILITY_PERFORMANCE
  
  Audit Tables:
    • AUDIT_LOG
Level 5: Database Objects
Sequences (~20):
  • DONOR_SEQ
  • DONATION_SEQ
  • BLOOD_UNIT_SEQ
  • REQUEST_SEQ
  • TRANSFER_SEQ
  • (etc.)

Indexes (~50):
  Primary Key Indexes
  Foreign Key Indexes
  Unique Indexes
  Composite Indexes
  Function-based Indexes

Views (~15):
  • V_AVAILABLE_INVENTORY
  • V_DONOR_HISTORY
  • V_REQUEST_STATUS
  • V_ARCHIVE_LOG_STATUS
  • (etc.)

Constraints (~100):
  Primary Keys (17)
  Foreign Keys (~50)
  Check Constraints (~30)
  Unique Constraints (~10)

Triggers (~10):
  • TRG_AUDIT_BLOOD_UNITS
  • TRG_UPDATE_INVENTORY
  • TRG_GENERATE_ORDER_NUMBER
  • (etc.)

Procedures (~20):
  • SP_CREATE_DONATION
  • SP_ASSIGN_DRIVER (adapted for blood)
  • SP_PROCESS_REQUEST
  • (etc.)

Functions (~10):
  • FN_CALCULATE_AGE
  • FN_DAYS_UNTIL_EXPIRATION
  • FN_BLOOD_TYPE_COMPATIBLE
  • (etc.)

Packages (~5):
  • PKG_DONOR_MANAGEMENT
  • PKG_INVENTORY_MANAGEMENT
  • PKG_REQUEST_PROCESSING
  • PKG_BI_ANALYTICS
  • PKG_UTILITY
________________________________________
🗂️ FILE DESCRIPTIONS
Phase III Files:
File	Description	Size	Lines
ER_Diagram.md	Complete Entity-Relationship diagram in Mermaid format	~5KB	~200
Data_Dictionary.md	Full data dictionary with all tables, columns, types, constraints	~50KB	~2000
Normalization_Documentation.md	Documentation of 1NF, 2NF, 3NF process with examples	~15KB	~600
BI_Considerations.md	Fact/Dimension table design, SCD strategy, aggregations	~20KB	~800
Assumptions_Constraints.md	Business assumptions, technical constraints, regulations	~10KB	~400
Phase IV Files:
File	Description	Execution Time	Prerequisites
01_create_pluggable_database.sql	Creates PDB and configures basic settings	~5 min	SYSDBA access
02_create_tablespaces.sql	Creates 7 tablespaces with proper configuration	~2 min	PDB created
03_create_admin_user.sql	Creates users, roles, and grants privileges	~3 min	Tablespaces exist
04_configure_memory_parameters.sql	Sets SGA, PGA, and other memory parameters	~1 min	Users created
05_enable_archive_logging.sql	Enables archive log mode and configures archiving	~3 min	Memory configured
________________________________________
🔄 DATA FLOW ARCHITECTURE
Operational Data Flow:
Donor Registration
    ↓
Eligibility Check
    ↓
Donation Scheduling (Appointment)
    ↓
Donation Collection
    ↓
Blood Unit Creation (Component Separation)
    ↓
Laboratory Testing
    ↓
Inventory Addition (if tests pass)
    ↓
Request Processing
    ↓
Transfer (if needed)
    ↓
Distribution to Hospital
    ↓
Transfusion (external to system)
Analytics Data Flow:
Operational Tables (OLTP)
    ↓
ETL Process (Nightly)
    ↓
Fact & Dimension Tables (OLAP)
    ↓
Aggregate Tables (Pre-calculated)
    ↓
BI Reports & Dashboards
    ↓
Decision Making
________________________________________
🎯 KEY METRICS & KPIs
Operational Metrics:
•	Blood Units Collected: Daily/Weekly/Monthly counts
•	Inventory Levels: Current stock by blood type
•	Request Fulfillment Rate: % of requests fulfilled on time
•	Donor Retention Rate: % of donors who return
•	Wastage Rate: % of units expired or discarded
•	Average Test Turnaround Time: Hours from collection to availability
Quality Metrics:
•	Adverse Event Rate: Events per 1000 donations
•	Positive Test Rate: % of units testing positive
•	Donor Deferral Rate: % of donors deferred
•	On-Time Delivery Rate: % of requests fulfilled within SLA
Financial Metrics:
•	Cost Per Unit Collected: Total cost / Units collected
•	Revenue Per Unit Distributed: Revenue / Units distributed
•	Inventory Carrying Cost: Cost to store blood
•	Wastage Cost: Value of wasted units
________________________________________
📈 SCALABILITY CONSIDERATIONS
Current Capacity (Initial Setup):
•	Storage: 3.5GB initial, 60GB maximum
•	Memory: 2.5GB (suitable for 100+ concurrent users)
•	Throughput: ~1000 transactions/minute
•	Data Volume: Up to 10 million records
Growth Projections:
Year	Donors	Donations/Year	Blood Units	Storage Needed
Year 1	10,000	50,000	150,000	5 GB
Year 2	20,000	100,000	300,000	10 GB
Year 3	30,000	150,000	450,000	15 GB
Year 5	50,000	250,000	750,000	25 GB
Scaling Strategies:
1.	Horizontal Scaling: Add more datafiles to tablespaces
2.	Vertical Scaling: Increase memory allocation
3.	Partitioning: Implement table partitioning for large tables
4.	Archive Strategy: Move old data to archive tablespace
5.	Read Replicas: Set up Data Guard for reporting queries
________________________________________
🔐 SECURITY ARCHITECTURE
Defense in Depth:
Layer 1: Network Security
  • Firewall rules
  • VPN access
  • IP whitelisting

Layer 2: Database Authentication
  • Strong password policy
  • Account lockout policy
  • Password expiration

Layer 3: Authorization
  • Role-based access control
  • Least privilege principle
  • Segregation of duties

Layer 4: Data Encryption
  • TLS for data in transit
  • TDE for data at rest (optional)
  • Encrypted backups

Layer 5: Auditing
  • All access logged
  • Failed login attempts tracked
  • Data changes audited
  • Compliance reporting

Layer 6: Monitoring
  • Real-time alerts
  • Anomaly detection
  • Performance monitoring
________________________________________
🔧 MAINTENANCE SCHEDULE
Daily (Automated):
•	[x] Archive log backup
•	[x] Alert log monitoring
•	[x] Tablespace usage check
•	[x] Database health check
Weekly (Semi-automated):
•	[ ] Incremental backup (RMAN)
•	[ ] Statistics gathering
•	[ ] Invalid objects check
•	[ ] Performance review
Monthly (Manual):
•	[ ] Full database backup
•	[ ] Security audit
•	[ ] Capacity planning review
•	[ ] Patch assessment
Quarterly (Manual):
•	[ ] DR test
•	[ ] Performance tuning
•	[ ] Archive log purge
•	[ ] Access review
Annually (Manual):
•	[ ] Major version upgrade assessment
•	[ ] Hardware capacity review
•	[ ] Security audit (external)
•	[ ] Business continuity test
________________________________________
📞 SUPPORT CONTACTS
Technical Support:
•	DBA: Mugisha Prince Benjamin (Student ID: 26979)
•	Email: mugishapriib@gmail.com
•	Database Name: thur_26979_benjamin_blooddonation_db
________________________________________
📅 PROJECT TIMELINE
Completed Phases:
•	[x] Phase I: Requirements Gathering (Complete)
•	[x] Phase II: System Analysis (Complete)
•	[x] Phase III: Logical Model Design (Complete)
•	[x] Phase IV: Database Creation (Complete)
Upcoming Phases:
•	[ ] Phase V: Table Creation & Constraints (Week 1)
•	[ ] Phase VI: Data Population (Week 2)
•	[ ] Phase VII: PL/SQL Development (Week 3-4)
•	[ ] Phase VIII: BI/Analytics Implementation (Week 5)
•	[ ] Phase IX: Testing & Optimization (Week 6)
•	[ ] Phase X: Deployment & Go-Live (Week 7)
________________________________________
📚 REFERENCES
Technical Documentation:
•	Oracle Database 19c Documentation
•	Oracle Database Administrator's Guide
•	Oracle Database Performance Tuning Guide
•	Oracle Database Backup and Recovery User's Guide
Standards:
•	ISO 15189 (Medical Laboratories)
•	AABB Standards (Blood Banking)
•	WHO Guidelines (Blood Safety)
•	ISO 27001 (Information Security)
Project Documents:
•	Requirements Specification (Phase III)
•	Logical Data Model (Phase III)
•	Installation Guide (Phase IV)
•	User Manual (Future)
•	Operations Manual (Future)
________________________________________
🏆 PROJECT ACHIEVEMENTS
•	✅ Database Created: Oracle 19c PDB successfully created
•	✅ Storage Configured: 7 tablespaces with 60GB max capacity
•	✅ Security Implemented: 4-tier user access control
•	✅ Memory Optimized: Configured for 4GB RAM system
•	✅ Archive Enabled: Full backup and recovery capability
•	✅ Documentation Complete: Comprehensive guides and README
________________________________________
Project Status: Phase IV Complete ✅
Next Phase: Create Database Tables (Phase V)
Last Updated: December 19, 2025
Version: 1.0
________________________________________
END OF PROJECT STRUCTURE OVERVIEW
