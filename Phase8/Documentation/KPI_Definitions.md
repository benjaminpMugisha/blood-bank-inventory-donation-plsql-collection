# Key Performance Indicator (KPI) Definitions
## Blood Bank Management System

---

## 1. Donor Management KPIs

### 1.1 Active Donor Count
**Definition:** Total number of donors with status = 'Active' and is_active = 'Y'

**SQL Query:**
```sql
SELECT COUNT(*) AS active_donor_count
FROM DONORS
WHERE status = 'Active' AND is_active = 'Y';
```

**Business Rules:**
- Updated: Real-time
- Target: 10,000+
- Alert Threshold: < 8,000 (Critical), < 9,000 (Warning)
- Reporting: Daily dashboard card

---

### 1.2 New Donor Acquisition Rate
**Definition:** Number of new donors registered in the current month

**SQL Query:**
```sql
SELECT COUNT(*) AS new_donors_this_month
FROM DONORS
WHERE TRUNC(created_at, 'MM') = TRUNC(SYSDATE, 'MM');
```

**Business Rules:**
- Updated: Daily
- Target: 500+ per month
- Calculation Period: Calendar month
- Trend Analysis: Compare to previous 3 months

---

### 1.3 Donor Retention Rate
**Definition:** Percentage of donors who have donated more than once

**SQL Query:**
```sql
SELECT 
    ROUND(
        COUNT(CASE WHEN total_donations > 1 THEN 1 END) * 100.0 / 
        COUNT(*), 2
    ) AS retention_rate_pct
FROM DONORS
WHERE total_donations > 0;
```

**Business Rules:**
- Updated: Monthly
- Target: ≥ 70%
- Industry Benchmark: 60-75%
- Action Required: If < 65%, review engagement programs

---

### 1.4 Average Donations per Donor
**Definition:** Mean number of lifetime donations across all active donors

**SQL Query:**
```sql
SELECT 
    ROUND(AVG(total_donations), 2) AS avg_donations_per_donor
FROM DONORS
WHERE is_active = 'Y' AND total_donations > 0;
```

**Business Rules:**
- Updated: Quarterly
- Target: ≥ 3 donations
- Excellence Threshold: > 5 donations
- Segmentation: Calculate separately for different donor tiers

---

### 1.5 Donor No-Show Rate
**Definition:** Percentage of scheduled appointments where donor did not appear

**SQL Query:**
```sql
SELECT 
    ROUND(
        COUNT(CASE WHEN status = 'No-Show' THEN 1 END) * 100.0 / 
        COUNT(*), 2
    ) AS no_show_rate_pct
FROM APPOINTMENTS
WHERE appointment_date >= ADD_MONTHS(TRUNC(SYSDATE), -1);
```

**Business Rules:**
- Updated: Weekly
- Target: < 15%
- Critical Threshold: > 20%
- Actions: SMS reminders, follow-up calls

---

## 2. Inventory Management KPIs

### 2.1 Blood Units Available
**Definition:** Total count of blood units with status = 'Available'

**SQL Query:**
```sql
SELECT 
    COUNT(*) AS total_available_units,
    SUM(volume_ml) AS total_volume_ml
FROM BLOOD_UNITS
WHERE status = 'Available' AND expiration_date > SYSDATE;
```

**Business Rules:**
- Updated: Real-time
- Target: 3,000+ units
- Critical Alert: < 1,500 units
- Distribution: Monitor by blood type and facility

---

### 2.2 Days of Supply
**Definition:** Number of days current inventory will last at average usage rate

**SQL Query:**
```sql
WITH avg_daily_usage AS (
    SELECT COUNT(*) / 30 AS daily_usage
    FROM BLOOD_UNITS
    WHERE status = 'Transfused'
      AND updated_at >= SYSDATE - 30
)
SELECT 
    ROUND(
        (SELECT COUNT(*) FROM BLOOD_UNITS WHERE status = 'Available') /
        NULLIF((SELECT daily_usage FROM avg_daily_usage), 0),
        1
    ) AS days_of_supply
FROM DUAL;
```

**Business Rules:**
- Updated: Daily
- Target: > 7 days
- Warning: < 5 days
- Critical: < 3 days
- Action: Initiate urgent collection campaigns

---

### 2.3 Inventory Turnover Rate
**Definition:** Number of times inventory is completely used and replenished per year

**SQL Query:**
```sql
WITH yearly_stats AS (
    SELECT 
        COUNT(*) AS units_used,
        (SELECT AVG(quantity_available) FROM INVENTORY) AS avg_inventory
    FROM BLOOD_UNITS
    WHERE status = 'Transfused'
      AND EXTRACT(YEAR FROM updated_at) = EXTRACT(YEAR FROM SYSDATE)
)
SELECT 
    ROUND(units_used / NULLIF(avg_inventory, 0), 2) AS turnover_rate
FROM yearly_stats;
```

**Business Rules:**
- Updated: Monthly
- Target: 8-12 times per year
- Too High (>15): Risk of stock-outs
- Too Low (<6): Excess inventory, high wastage risk

---

### 2.4 Wastage Rate
**Definition:** Percentage of blood units that expired or were discarded

**SQL Query:**
```sql
WITH total_units AS (
    SELECT COUNT(*) AS total
    FROM BLOOD_UNITS
    WHERE TRUNC(created_at, 'MM') = ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -1)
),
wasted_units AS (
    SELECT COUNT(*) AS wasted
    FROM BLOOD_UNITS
    WHERE status IN ('Expired', 'Discarded')
      AND TRUNC(updated_at, 'MM') = ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -1)
)
SELECT 
    ROUND(
        (SELECT wasted FROM wasted_units) * 100.0 / 
        NULLIF((SELECT total FROM total_units), 0), 2
    ) AS wastage_rate_pct
FROM DUAL;
```

**Business Rules:**
- Updated: Monthly
- Target: < 3%
- Industry Standard: 3-5%
- Excellence: < 2%
- Root Cause Analysis required if > 5%

---

### 2.5 Stock-out Incidents
**Definition:** Number of times a blood type had zero available units

**SQL Query:**
```sql
SELECT 
    blood_type || rh_factor AS blood_group,
    COUNT(*) AS stockout_count,
    MAX(last_updated) AS last_stockout_date
FROM INVENTORY
WHERE quantity_available = 0
  AND last_updated >= ADD_MONTHS(SYSDATE, -1)
GROUP BY blood_type, rh_factor
ORDER BY stockout_count DESC;
```

**Business Rules:**
- Updated: Real-time
- Target: 0 incidents
- Critical Alert: Any stock-out of O-, AB+
- Action: Emergency procurement protocol

---

## 3. Request Fulfillment KPIs

### 3.1 Fulfillment Rate
**Definition:** Percentage of requests marked as 'Fulfilled'

**SQL Query:**
```sql
SELECT 
    ROUND(
        COUNT(CASE WHEN status = 'Fulfilled' THEN 1 END) * 100.0 / 
        COUNT(*), 2
    ) AS fulfillment_rate_pct
FROM REQUESTS
WHERE request_date >= ADD_MONTHS(TRUNC(SYSDATE), -1);
```

**Business Rules:**
- Updated: Daily
- Target: ≥ 95%
- Critical Threshold: < 90%
- Exclude cancelled requests from calculation

---

### 3.2 Average Fulfillment Time
**Definition:** Mean time from request submission to fulfillment (in hours)

**SQL Query:**
```sql
SELECT 
    ROUND(
        AVG(
            EXTRACT(HOUR FROM (fulfilled_date - request_date) * 24) +
            EXTRACT(MINUTE FROM (fulfilled_date - request_date) * 24) / 60
        ), 2
    ) AS avg_fulfillment_hours
FROM REQUESTS
WHERE status = 'Fulfilled'
  AND fulfilled_date IS NOT NULL
  AND request_date >= ADD_MONTHS(SYSDATE, -1);
```

**Business Rules:**
- Updated: Daily
- Target: < 4 hours (routine)
- Emergency Target: < 1 hour
- Urgent Target: < 2 hours

---

### 3.3 Emergency Request Response Time
**Definition:** Average time to fulfill emergency requests

**SQL Query:**
```sql
SELECT 
    urgency_level,
    COUNT(*) AS request_count,
    ROUND(AVG((fulfilled_date - request_date) * 24), 2) AS avg_hours,
    MIN((fulfilled_date - request_date) * 24) AS min_hours,
    MAX((fulfilled_date - request_date) * 24) AS max_hours
FROM REQUESTS
WHERE status = 'Fulfilled'
  AND urgency_level = 'Emergency'
  AND request_date >= ADD_MONTHS(SYSDATE, -1)
GROUP BY urgency_level;
```

**Business Rules:**
- Updated: Real-time
- Target: < 1 hour
- SLA Compliance: 100% within 1 hour
- Escalation: If > 1 hour, notify director

---

### 3.4 Partial Fulfillment Rate
**Definition:** Percentage of requests where quantity fulfilled < quantity requested

**SQL Query:**
```sql
SELECT 
    ROUND(
        COUNT(CASE WHEN quantity_fulfilled < quantity_requested THEN 1 END) * 100.0 / 
        NULLIF(COUNT(*), 0), 2
    ) AS partial_fulfillment_pct
FROM REQUESTS
WHERE status IN ('Partially Fulfilled', 'Fulfilled')
  AND request_date >= ADD_MONTHS(SYSDATE, -1);
```

**Business Rules:**
- Updated: Weekly
- Target: < 10%
- Warning: > 15%
- Root Cause: Inventory shortage vs. distribution issues

---

## 4. Quality & Safety KPIs

### 4.1 Adverse Event Rate
**Definition:** Adverse events per 1,000 donations

**SQL Query:**
```sql
WITH donations AS (
    SELECT COUNT(*) AS total_donations
    FROM DONATIONS
    WHERE donation_date >= ADD_MONTHS(TRUNC(SYSDATE), -1)
),
events AS (
    SELECT COUNT(*) AS total_events
    FROM DONATION_ADVERSE_EVENTS
    WHERE event_date >= ADD_MONTHS(TRUNC(SYSDATE), -1)
)
SELECT 
    ROUND(
        (SELECT total_events FROM events) * 1000.0 / 
        NULLIF((SELECT total_donations FROM donations), 0), 2
    ) AS adverse_events_per_1000
FROM DUAL;
```

**Business Rules:**
- Updated: Weekly
- Target: < 10 per 1,000 donations (< 1%)
- Industry Benchmark: 5-15 per 1,000
- Severity-based escalation protocols

---

### 4.2 Test Positive Rate
**Definition:** Percentage of blood units testing positive for transmissible diseases

**SQL Query:**
```sql
SELECT 
    test_type,
    COUNT(*) AS total_tests,
    COUNT(CASE WHEN test_result IN ('Positive', 'Reactive') THEN 1 END) AS positive_tests,
    ROUND(
        COUNT(CASE WHEN test_result IN ('Positive', 'Reactive') THEN 1 END) * 100.0 / 
        COUNT(*), 4
    ) AS positive_rate_pct
FROM TEST_RESULTS
WHERE test_date >= ADD_MONTHS(TRUNC(SYSDATE), -1)
GROUP BY test_type;
```

**Business Rules:**
- Updated: Monthly
- Target: < 0.5%
- Regulatory Reporting: Required for rates > 1%
- Donor deferral and follow-up protocols activated

---

### 4.3 Unit Quarantine Rate
**Definition:** Percentage of blood units placed in quarantine

**SQL Query:**
```sql
SELECT 
    ROUND(
        COUNT(CASE WHEN is_quarantined = 'Y' THEN 1 END) * 100.0 / 
        COUNT(*), 2
    ) AS quarantine_rate_pct
FROM BLOOD_UNITS
WHERE TRUNC(created_at, 'MM') = ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -1);
```

**Business Rules:**
- Updated: Weekly
- Target: < 2%
- Investigation Required: If > 5%
- Trend Analysis: Monthly comparison

---

### 4.4 Donation Completion Rate
**Definition:** Percentage of scheduled donations that were completed

**SQL Query:**
```sql
SELECT 
    ROUND(
        COUNT(CASE WHEN status = 'Completed' THEN 1 END) * 100.0 / 
        COUNT(*), 2
    ) AS completion_rate_pct
FROM DONATIONS
WHERE donation_date >= ADD_MONTHS(TRUNC(SYSDATE), -1);
```

**Business Rules:**
- Updated: Daily
- Target: > 90%
- Exclusions: Donor deferrals (medical reasons)
- Track reasons for incomplete donations

---

## 5. Compliance KPIs

### 5.1 Audit Trail Completeness
**Definition:** Percentage of database operations that were logged

**SQL Query:**
```sql
WITH expected_logs AS (
    SELECT 
        (SELECT COUNT(*) FROM DONORS WHERE created_at >= TRUNC(SYSDATE)) +
        (SELECT COUNT(*) FROM DONATIONS WHERE created_at >= TRUNC(SYSDATE)) +
        (SELECT COUNT(*) FROM BLOOD_UNITS WHERE created_at >= TRUNC(SYSDATE))
        AS expected_count
    FROM DUAL
),
actual_logs AS (
    SELECT COUNT(*) AS actual_count
    FROM AUDIT_LOG
    WHERE attempted_at >= TRUNC(SYSDATE)
)
SELECT 
    (SELECT actual_count FROM actual_logs) AS logged_operations,
    (SELECT expected_count FROM expected_logs) AS expected_operations,
    ROUND(
        (SELECT actual_count FROM actual_logs) * 100.0 / 
        NULLIF((SELECT expected_count FROM expected_logs), 0), 2
    ) AS completeness_pct
FROM DUAL;
```

**Business Rules:**
- Updated: Real-time
- Target: 100%
- Critical Alert: If < 100%
- Regulatory Requirement: Complete audit trail mandatory

---

### 5.2 Restriction Compliance Rate
**Definition:** Percentage of restricted operations that were successfully blocked

**SQL Query:**
```sql
WITH restricted_attempts AS (
    SELECT COUNT(*) AS total_restricted
    FROM AUDIT_LOG
    WHERE denial_reason IS NOT NULL
      AND attempted_at >= ADD_MONTHS(SYSDATE, -1)
),
denied_operations AS (
    SELECT COUNT(*) AS total_denied
    FROM AUDIT_LOG
    WHERE is_allowed = 'N'
      AND denial_reason IS NOT NULL
      AND attempted_at >= ADD_MONTHS(SYSDATE, -1)
)
SELECT 
    (SELECT total_denied FROM denied_operations) AS operations_blocked,
    (SELECT total_restricted FROM restricted_attempts) AS should_be_blocked,
    ROUND(
        (SELECT total_denied FROM denied_operations) * 100.0 / 
        NULLIF((SELECT total_restricted FROM restricted_attempts), 0), 2
    ) AS compliance_rate_pct
FROM DUAL;
```

**Business Rules:**
- Updated: Daily
- Target: 100%
- Critical Issue: Any operation allowed when should be blocked
- Monthly compliance report required

---

### 5.3 License Compliance Rate
**Definition:** Percentage of facilities with valid, non-expired licenses

**SQL Query:**
```sql
SELECT 
    COUNT(*) AS total_facilities,
    COUNT(CASE WHEN accreditation_status = 'Accredited' 
               AND accreditation_expiry > SYSDATE THEN 1 END) AS compliant_facilities,
    ROUND(
        COUNT(CASE WHEN accreditation_status = 'Accredited' 
                   AND accreditation_expiry > SYSDATE THEN 1 END) * 100.0 / 
        COUNT(*), 2
    ) AS license_compliance_pct
FROM FACILITIES
WHERE is_active = 'Y';
```

**Business Rules:**
- Updated: Monthly
- Target: 100%
- Warning: 30 days before expiry
- Action Required: If < 100%, halt operations at non-compliant facilities

---

### 5.4 Equipment Calibration Compliance
**Definition:** Percentage of equipment with current calibration

**SQL Query:**
```sql
SELECT 
    equipment_type,
    COUNT(*) AS total_equipment,
    COUNT(CASE WHEN next_calibration_date >= SYSDATE 
               AND status = 'Operational' THEN 1 END) AS calibrated_equipment,
    ROUND(
        COUNT(CASE WHEN next_calibration_date >= SYSDATE 
                   AND status = 'Operational' THEN 1 END) * 100.0 / 
        COUNT(*), 2
    ) AS calibration_compliance_pct
FROM EQUIPMENT
WHERE status IN ('Operational', 'Under Maintenance')
GROUP BY equipment_type;
```

**Business Rules:**
- Updated: Weekly
- Target: 100%
- Warning: 14 days before due date
- Non-compliant equipment: Must be taken out of service

---

## 6. KPI Thresholds & Alert Rules

### 6.1 Critical Alerts (Immediate Action)
| KPI | Critical Threshold | Alert Method | Recipient |
|-----|-------------------|--------------|-----------|
| Blood Units Available | < 1,500 | SMS + Email + Dashboard | Director, Medical Officers |
| Stock-out Incidents | Any O- or AB+ | SMS + Phone | All stakeholders |
| Emergency Request Time | > 1 hour | SMS | Director, On-call manager |
| Audit Trail Completeness | < 100% | Email + System Alert | IT, Compliance Officer |
| License Compliance | < 100% | Email | Director, Compliance |

### 6.2 Warning Alerts (Action within 24 hours)
| KPI | Warning Threshold | Alert Method | Recipient |
|-----|------------------|--------------|-----------|
| Days of Supply | < 5 days | Email + Dashboard | Medical Officers |
| Fulfillment Rate | < 92% | Email | Operations Manager |
| Donor Retention | < 65% | Email | Donor Coordinators |
| Wastage Rate | > 4% | Email | Lab Manager |
| Adverse Event Rate | > 12 per 1000 | Email | Medical Director |

### 6.3 Informational Alerts (Weekly review)
| KPI | Informational Threshold | Alert Method | Recipient |
|-----|------------------------|--------------|-----------|
| New Donor Acquisition | Trend analysis | Weekly Report | Marketing Team |
| Inventory Turnover | Outside 8-12 range | Weekly Report | Supply Chain |
| Partial Fulfillment Rate | > 12% | Weekly Report | Operations |

---

## 7. KPI Calculation Schedule

| KPI Category | Calculation Frequency | Cache Duration | Peak Load Time |
|--------------|----------------------|----------------|----------------|
| Real-time KPIs | Every 1 minute | 1 minute | 8AM-6PM |
| Operational KPIs | Every 15 minutes | 15 minutes | 8AM-10PM |
| Daily KPIs | 12:00 AM daily | 24 hours | Off-peak |
| Weekly KPIs | Monday 6:00 AM | 7 days | Weekend |
| Monthly KPIs | 1st day, 6:00 AM | 30 days | Weekend |

---

## 8. KPI Visualization Guidelines

### 8.1 KPI Cards
- **Font Size:** Title (14pt), Value (28pt bold), Change (12pt)
- **Colors:** Green (good), Yellow (warning), Red (critical)
- **Trend Indicator:** Up/down arrow with percentage
- **Sparkline:** Mini 30-day trend chart

### 8.2 Gauges
- **Range:** 0-100% (or custom range)
- **Zones:** Green (target met), Yellow (warning), Red (critical)
- **Needle:** Current value with label
- **Threshold Lines:** Target and critical thresholds marked

### 8.3 Charts
- **Colors:** Consistent brand palette
- **Labels:** Clear, no abbreviations
- **Tooltips:** Detailed information on hover
- **Export:** Always provide CSV export option

---

## Appendix: SQL Query Library

All KPI queries are available in:
- `/queries/kpi_queries.sql`
- `/queries/alert_queries.sql`
- `/queries/dashboard_queries.sql`

Queries are optimized with proper indexing and execution plans documented.
