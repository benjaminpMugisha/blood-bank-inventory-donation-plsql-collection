-- ============================================================
-- BLOOD BANK MANAGEMENT SYSTEM - BUSINESS INTELLIGENCE
-- Phase VIII: Analytics Queries, KPIs, Dashboard Data
-- ============================================================

-- ============================================================
-- SECTION 1: EXECUTIVE DASHBOARD - KEY PERFORMANCE INDICATORS
-- ============================================================

-- KPI 1: Overall System Statistics
SELECT 
    'System Overview' AS metric_category,
    (SELECT COUNT(*) FROM DONORS WHERE is_active = 'Y') AS total_active_donors,
    (SELECT COUNT(*) FROM DONATIONS WHERE donation_date >= ADD_MONTHS(SYSDATE, -1)) AS donations_last_30_days,
    (SELECT COUNT(*) FROM BLOOD_UNITS WHERE status = 'Available') AS available_units,
    (SELECT COUNT(*) FROM REQUESTS WHERE status = 'Pending') AS pending_requests,
    (SELECT COUNT(*) FROM FACILITIES WHERE is_active = 'Y') AS active_facilities
FROM DUAL;

-- KPI 2: Blood Inventory Status by Type
SELECT 
    blood_type || rh_factor AS blood_group,
    component_type,
    SUM(quantity_available) AS available_units,
    SUM(quantity_reserved) AS reserved_units,
    SUM(quantity_expired) AS expired_units,
    ROUND(SUM(quantity_available) * 100.0 / NULLIF(SUM(quantity_available + quantity_reserved + quantity_expired), 0), 2) AS availability_percentage
FROM INVENTORY
GROUP BY blood_type, rh_factor, component_type
ORDER BY blood_type, rh_factor, component_type;

-- KPI 3: Donation Trends (Last 12 Months with Window Functions)
SELECT 
    month_year,
    total_donations,
    total_donors,
    AVG(total_donations) OVER (ORDER BY month_num ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3months,
    total_donations - LAG(total_donations, 1) OVER (ORDER BY month_num) AS month_over_month_change,
    ROUND((total_donations - LAG(total_donations, 1) OVER (ORDER BY month_num)) * 100.0 / 
          NULLIF(LAG(total_donations, 1) OVER (ORDER BY month_num), 0), 2) AS pct_change
FROM (
    SELECT 
        TO_CHAR(donation_date, 'YYYY-MM') AS month_year,
        TO_NUMBER(TO_CHAR(donation_date, 'YYYYMM')) AS month_num,
        COUNT(*) AS total_donations,
        COUNT(DISTINCT donor_id) AS total_donors
    FROM DONATIONS
    WHERE donation_date >= ADD_MONTHS(TRUNC(SYSDATE), -12)
    GROUP BY TO_CHAR(donation_date, 'YYYY-MM'), TO_NUMBER(TO_CHAR(donation_date, 'YYYYMM'))
)
ORDER BY month_num DESC;

-- KPI 4: Facility Performance Ranking
SELECT 
    facility_id,
    facility_name,
    facility_type,
    total_donations,
    available_units,
    fulfilled_requests,
    RANK() OVER (ORDER BY total_donations DESC) AS donation_rank,
    DENSE_RANK() OVER (ORDER BY fulfilled_requests DESC) AS fulfillment_rank,
    ROUND(fulfilled_requests * 100.0 / NULLIF(total_requests, 0), 2) AS fulfillment_rate
FROM (
    SELECT 
        f.facility_id,
        f.facility_name,
        f.facility_type,
        COUNT(DISTINCT d.donation_id) AS total_donations,
        (SELECT SUM(quantity_available) FROM INVENTORY i WHERE i.facility_id = f.facility_id) AS available_units,
        (SELECT COUNT(*) FROM REQUESTS r WHERE r.requesting_facility_id = f.facility_id) AS total_requests,
        (SELECT COUNT(*) FROM REQUESTS r WHERE r.requesting_facility_id = f.facility_id AND r.status = 'Fulfilled') AS fulfilled_requests
    FROM FACILITIES f
    LEFT JOIN DONATIONS d ON f.facility_id = d.facility_id
    WHERE f.is_active = 'Y'
    GROUP BY f.facility_id, f.facility_name, f.facility_type
)
ORDER BY donation_rank;

-- ============================================================
-- SECTION 2: DONOR ANALYTICS
-- ============================================================

-- Analytics 1: Donor Demographics and Activity
SELECT 
    age_group,
    gender,
    blood_type || rh_factor AS blood_group,
    COUNT(*) AS donor_count,
    ROUND(AVG(total_donations), 2) AS avg_donations,
    SUM(total_donations) AS total_donations,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM (
    SELECT 
        CASE 
            WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, date_of_birth)/12) BETWEEN 18 AND 25 THEN '18-25'
            WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, date_of_birth)/12) BETWEEN 26 AND 35 THEN '26-35'
            WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, date_of_birth)/12) BETWEEN 36 AND 45 THEN '36-45'
            WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, date_of_birth)/12) BETWEEN 46 AND 55 THEN '46-55'
            ELSE '56+'
        END AS age_group,
        gender,
        blood_type,
        rh_factor,
        total_donations
    FROM DONORS
    WHERE is_active = 'Y'
)
GROUP BY age_group, gender, blood_type, rh_factor
ORDER BY age_group, gender, blood_group;

-- Analytics 2: Top Donors (Hero Donors)
SELECT 
    donor_id,
    first_name || ' ' || last_name AS donor_name,
    blood_type || rh_factor AS blood_group,
    total_donations,
    last_donation_date,
    TRUNC(SYSDATE - last_donation_date) AS days_since_last,
    ROW_NUMBER() OVER (ORDER BY total_donations DESC) AS hero_rank,
    NTILE(4) OVER (ORDER BY total_donations DESC) AS donor_quartile,
    CASE 
        WHEN total_donations >= 20 THEN 'Platinum'
        WHEN total_donations >= 10 THEN 'Gold'
        WHEN total_donations >= 5 THEN 'Silver'
        ELSE 'Bronze'
    END AS donor_tier
FROM DONORS
WHERE is_active = 'Y' AND total_donations > 0
ORDER BY total_donations DESC
FETCH FIRST 50 ROWS ONLY;

-- Analytics 3: Donor Retention Analysis
SELECT 
    donation_year,
    first_time_donors,
    repeat_donors,
    total_donors,
    ROUND(repeat_donors * 100.0 / total_donors, 2) AS retention_rate,
    LAG(repeat_donors) OVER (ORDER BY donation_year) AS prev_year_repeat,
    repeat_donors - LAG(repeat_donors) OVER (ORDER BY donation_year) AS yoy_change
FROM (
    SELECT 
        EXTRACT(YEAR FROM donation_date) AS donation_year,
        COUNT(DISTINCT CASE WHEN donation_number = 1 THEN donor_id END) AS first_time_donors,
        COUNT(DISTINCT CASE WHEN donation_number > 1 THEN donor_id END) AS repeat_donors,
        COUNT(DISTINCT donor_id) AS total_donors
    FROM DONATIONS
    WHERE donation_date >= ADD_MONTHS(TRUNC(SYSDATE), -36)
    GROUP BY EXTRACT(YEAR FROM donation_date)
)
ORDER BY donation_year DESC;

-- ============================================================
-- SECTION 3: INVENTORY & SUPPLY CHAIN ANALYTICS
-- ============================================================

-- Analytics 4: Blood Unit Lifecycle Analysis
SELECT 
    component_type,
    status,
    COUNT(*) AS unit_count,
    ROUND(AVG(TRUNC(SYSDATE) - collection_date), 2) AS avg_age_days,
    MIN(collection_date) AS oldest_unit,
    MAX(collection_date) AS newest_unit,
    SUM(CASE WHEN expiration_date < SYSDATE THEN 1 ELSE 0 END) AS expired_count,
    SUM(CASE WHEN expiration_date BETWEEN SYSDATE AND SYSDATE + 7 THEN 1 ELSE 0 END) AS expiring_7days
FROM BLOOD_UNITS
GROUP BY component_type, status
ORDER BY component_type, status;

-- Analytics 5: Critical Inventory Alerts
SELECT 
    f.facility_name,
    i.blood_type || i.rh_factor AS blood_group,
    i.component_type,
    i.quantity_available,
    i.quantity_reserved,
    CASE 
        WHEN i.quantity_available = 0 THEN 'CRITICAL - OUT OF STOCK'
        WHEN i.quantity_available < 10 THEN 'URGENT - LOW STOCK'
        WHEN i.quantity_available < 20 THEN 'WARNING - BELOW THRESHOLD'
        ELSE 'NORMAL'
    END AS alert_level,
    (SELECT COUNT(*) FROM REQUESTS r 
     WHERE r.requesting_facility_id = f.facility_id 
     AND r.blood_type = i.blood_type 
     AND r.rh_factor = i.rh_factor
     AND r.status = 'Pending') AS pending_requests
FROM INVENTORY i
JOIN FACILITIES f ON i.facility_id = f.facility_id
WHERE i.quantity_available < 20
ORDER BY i.quantity_available, f.facility_name;

-- Analytics 6: Expiration Management
SELECT 
    facility_id,
    blood_type || rh_factor AS blood_group,
    component_type,
    unit_id,
    unit_number,
    collection_date,
    expiration_date,
    TRUNC(expiration_date - SYSDATE) AS days_to_expiry,
    CASE 
        WHEN TRUNC(expiration_date - SYSDATE) <= 0 THEN 'EXPIRED'
        WHEN TRUNC(expiration_date - SYSDATE) <= 3 THEN 'CRITICAL (0-3 days)'
        WHEN TRUNC(expiration_date - SYSDATE) <= 7 THEN 'URGENT (4-7 days)'
        WHEN TRUNC(expiration_date - SYSDATE) <= 14 THEN 'WARNING (8-14 days)'
        ELSE 'NORMAL (15+ days)'
    END AS expiry_status,
    RANK() OVER (PARTITION BY facility_id, blood_type, rh_factor 
                 ORDER BY expiration_date) AS expiry_rank
FROM BLOOD_UNITS
WHERE status = 'Available'
  AND expiration_date <= SYSDATE + 14
ORDER BY days_to_expiry, facility_id;

-- ============================================================
-- SECTION 4: OPERATIONAL EFFICIENCY METRICS
-- ============================================================

-- Analytics 7: Request Fulfillment Performance
SELECT 
    urgency_level,
    status,
    COUNT(*) AS request_count,
    ROUND(AVG(CASE WHEN fulfilled_date IS NOT NULL 
              THEN fulfilled_date - request_date END), 2) AS avg_fulfillment_days,
    MIN(CASE WHEN fulfilled_date IS NOT NULL 
        THEN fulfilled_date - request_date END) AS min_fulfillment_days,
    MAX(CASE WHEN fulfilled_date IS NOT NULL 
        THEN fulfilled_date - request_date END) AS max_fulfillment_days,
    ROUND(AVG(quantity_fulfilled * 100.0 / NULLIF(quantity_requested, 0)), 2) AS avg_fulfillment_rate
FROM REQUESTS
WHERE request_date >= ADD_MONTHS(TRUNC(SYSDATE), -6)
GROUP BY urgency_level, status
ORDER BY urgency_level, status;

-- Analytics 8: Appointment Completion Rates
SELECT 
    appointment_type,
    status,
    COUNT(*) AS appointment_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY appointment_type), 2) AS percentage,
    ROUND(AVG(CASE WHEN status = 'Completed' 
              THEN appointment_date - scheduled_date END), 2) AS avg_lead_time_days
FROM APPOINTMENTS
WHERE appointment_date >= ADD_MONTHS(TRUNC(SYSDATE), -3)
GROUP BY appointment_type, status
ORDER BY appointment_type, 
         CASE status 
             WHEN 'Completed' THEN 1
             WHEN 'Scheduled' THEN 2
             WHEN 'Confirmed' THEN 3
             WHEN 'Cancelled' THEN 4
             ELSE 5
         END;

-- Analytics 9: Adverse Events Analysis
SELECT 
    event_type,
    severity,
    COUNT(*) AS event_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage_of_total,
    COUNT(DISTINCT donation_id) AS affected_donations,
    ROUND(AVG(EXTRACT(HOUR FROM event_time)), 2) AS avg_hour_of_day
FROM DONATION_ADVERSE_EVENTS
WHERE event_date >= ADD_MONTHS(TRUNC(SYSDATE), -12)
GROUP BY event_type, severity
ORDER BY event_count DESC;

-- ============================================================
-- SECTION 5: AUDIT & COMPLIANCE DASHBOARD
-- ============================================================

-- Analytics 10: Security Audit Summary
SELECT 
    TO_CHAR(attempted_at, 'YYYY-MM-DD') AS audit_date,
    table_name,
    operation_type,
    is_allowed,
    COUNT(*) AS operation_count,
    COUNT(DISTINCT attempted_by) AS unique_users,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY TO_CHAR(attempted_at, 'YYYY-MM-DD')), 2) AS pct_of_daily_ops
FROM AUDIT_LOG
WHERE attempted_at >= TRUNC(SYSDATE) - 30
GROUP BY TO_CHAR(attempted_at, 'YYYY-MM-DD'), table_name, operation_type, is_allowed
ORDER BY audit_date DESC, operation_count DESC;

-- Analytics 11: Restriction Compliance Report
SELECT 
    TO_CHAR(attempted_at, 'DAY') AS day_of_week,
    table_name,
    operation_type,
    SUM(CASE WHEN is_allowed = 'Y' THEN 1 ELSE 0 END) AS allowed_operations,
    SUM(CASE WHEN is_allowed = 'N' THEN 1 ELSE 0 END) AS denied_operations,
    COUNT(*) AS total_attempts,
    ROUND(SUM(CASE WHEN is_allowed = 'N' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS denial_rate
FROM AUDIT_LOG
WHERE attempted_at >= TRUNC(SYSDATE) - 30
GROUP BY TO_CHAR(attempted_at, 'DAY'), table_name, operation_type
ORDER BY TO_CHAR(attempted_at, 'DAY'), denial_rate DESC;

-- ============================================================
-- SECTION 6: PREDICTIVE ANALYTICS & INSIGHTS
-- ============================================================

-- Analytics 12: Blood Demand Forecasting
SELECT 
    blood_type || rh_factor AS blood_group,
    component_type,
    TRUNC(request_date, 'MM') AS month,
    COUNT(*) AS request_count,
    SUM(quantity_requested) AS total_units_requested,
    AVG(quantity_requested) AS avg_units_per_request,
    ROUND(AVG(SUM(quantity_requested)) OVER (
        PARTITION BY blood_type, rh_factor, component_type 
        ORDER BY TRUNC(request_date, 'MM')
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_demand,
    LEAD(SUM(quantity_requested), 1) OVER (
        PARTITION BY blood_type, rh_factor, component_type 
        ORDER BY TRUNC(request_date, 'MM')
    ) - SUM(quantity_requested) AS next_month_change
FROM REQUESTS
WHERE request_date >= ADD_MONTHS(TRUNC(SYSDATE), -12)
GROUP BY blood_type, rh_factor, component_type, TRUNC(request_date, 'MM')
ORDER BY blood_group, component_type, month DESC;

-- Analytics 13: Donor Engagement Scorecard
SELECT 
    donor_id,
    first_name || ' ' || last_name AS donor_name,
    blood_type || rh_factor AS blood_group,
    total_donations,
    TRUNC(MONTHS_BETWEEN(SYSDATE, last_donation_date)) AS months_since_last,
    (SELECT COUNT(*) FROM APPOINTMENTS a 
     WHERE a.donor_id = d.donor_id AND a.status = 'No-Show') AS no_show_count,
    (SELECT COUNT(*) FROM APPOINTMENTS a 
     WHERE a.donor_id = d.donor_id AND a.status = 'Cancelled') AS cancelled_count,
    CASE 
        WHEN total_donations >= 10 AND TRUNC(MONTHS_BETWEEN(SYSDATE, last_donation_date)) <= 6 THEN 'Highly Engaged'
        WHEN total_donations >= 5 AND TRUNC(MONTHS_BETWEEN(SYSDATE, last_donation_date)) <= 12 THEN 'Engaged'
        WHEN total_donations >= 3 AND TRUNC(MONTHS_BETWEEN(SYSDATE, last_donation_date)) <= 24 THEN 'Moderately Engaged'
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, last_donation_date)) > 24 THEN 'At Risk'
        ELSE 'New Donor'
    END AS engagement_level,
    ROUND(total_donations * 1.0 / NULLIF(TRUNC(MONTHS_BETWEEN(SYSDATE, created_at)), 0), 2) AS donations_per_month
FROM DONORS d
WHERE is_active = 'Y'
ORDER BY total_donations DESC;

-- Analytics 14: Geographic Distribution Analysis
SELECT 
    city,
    district,
    COUNT(DISTINCT donor_id) AS total_donors,
    COUNT(DISTINCT CASE WHEN status = 'Active' THEN donor_id END) AS active_donors,
    (SELECT COUNT(*) FROM FACILITIES f WHERE f.city = d.city) AS facilities_in_city,
    SUM(total_donations) AS total_donations_from_city,
    ROUND(AVG(total_donations), 2) AS avg_donations_per_donor,
    DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT donor_id) DESC) AS city_rank
FROM DONORS d
GROUP BY city, district
ORDER BY total_donors DESC;

-- ============================================================
-- SECTION 7: WINDOW FUNCTIONS SHOWCASE
-- ============================================================

-- Advanced Analytics: Running Totals and Percentiles
SELECT 
    donation_date,
    donation_id,
    donor_id,
    volume_collected_ml,
    SUM(volume_collected_ml) OVER (
        ORDER BY donation_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_volume,
    AVG(volume_collected_ml) OVER (
        ORDER BY donation_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg_7days,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY volume_collected_ml) 
        OVER (PARTITION BY TRUNC(donation_date, 'MM')) AS median_volume_month,
    PERCENT_RANK() OVER (
        PARTITION BY TRUNC(donation_date, 'MM') 
        ORDER BY volume_collected_ml
    ) AS percentile_rank,
    NTILE(4) OVER (
        PARTITION BY TRUNC(donation_date, 'MM') 
        ORDER BY volume_collected_ml
    ) AS quartile
FROM DONATIONS
WHERE donation_date >= ADD_MONTHS(TRUNC(SYSDATE), -3)
ORDER BY donation_date DESC;

-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================

-- Final Statistics Summary
SELECT 'Database Statistics' AS report_type FROM DUAL;

SELECT 'Total Tables' AS metric, COUNT(*) AS value
FROM user_tables
WHERE table_name IN (
    'FACILITIES','DONORS','DONATIONS','ELIGIBILITY_CHECKS','APPOINTMENTS',
    'DONOR_DEFERRALS','BLOOD_UNITS','DONATION_ADVERSE_EVENTS','TEST_RESULTS',
    'BLOOD_UNIT_HISTORY','INVENTORY','REQUESTS','REQUEST_ITEMS','TRANSFERS',
    'TRANSFER_ITEMS','FACILITY_STAFF','EQUIPMENT','PUBLIC_HOLIDAYS','AUDIT_LOG'
)
UNION ALL
SELECT 'Total Procedures' AS metric, COUNT(*) AS value
FROM user_procedures
WHERE object_type = 'PROCEDURE'
UNION ALL
SELECT 'Total Functions' AS metric, COUNT(*) AS value
FROM user_procedures
WHERE object_type = 'FUNCTION'
UNION ALL
SELECT 'Total Triggers' AS metric, COUNT(*) AS value
FROM user_triggers
WHERE status = 'ENABLED'
UNION ALL
SELECT 'Total Donors' AS metric, COUNT(*) AS value FROM DONORS
UNION ALL
SELECT 'Total Donations' AS metric, COUNT(*) AS value FROM DONATIONS
UNION ALL
SELECT 'Total Blood Units' AS metric, COUNT(*) AS value FROM BLOOD_UNITS
UNION ALL
SELECT 'Total Facilities' AS metric, COUNT(*) AS value FROM FACILITIES
UNION ALL
SELECT 'Audit Log Entries' AS metric, COUNT(*) AS value FROM AUDIT_LOG;

COMMIT;
