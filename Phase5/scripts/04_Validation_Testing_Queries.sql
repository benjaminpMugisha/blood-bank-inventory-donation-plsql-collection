-- ============================================================
-- BLOOD BANK MANAGEMENT SYSTEM - VALIDATION & TESTING QUERIES
-- ============================================================
-- Phase V: Data Integrity Verification and Testing
-- ============================================================

PROMPT ============================================================
PROMPT DATA COMPLETENESS VERIFICATION
PROMPT ============================================================

-- 1. Row Counts for All Tables
SELECT 'Row Count Summary' AS report_title FROM dual;
SELECT 
    table_name,
    TO_CHAR(num_rows, '999,999') AS row_count
FROM user_tables
WHERE table_name IN (
    'FACILITIES','DONORS','FACILITY_STAFF','EQUIPMENT',
    'ELIGIBILITY_CHECKS','APPOINTMENTS','DONATIONS','DONOR_DEFERRALS',
    'BLOOD_UNITS','DONATION_ADVERSE_EVENTS','TEST_RESULTS',
    'BLOOD_UNIT_HISTORY','INVENTORY','REQUESTS','REQUEST_ITEMS',
    'TRANSFERS','TRANSFER_ITEMS'
)
ORDER BY table_name;

-- 2. Check for NULL values in critical fields
PROMPT Checking for NULL values in critical fields...

SELECT 'Donors with missing critical data' AS check_type, COUNT(*) AS count
FROM DONORS
WHERE first_name IS NULL OR last_name IS NULL OR blood_type IS NULL OR rh_factor IS NULL
UNION ALL
SELECT 'Donations with missing facility', COUNT(*)
FROM DONATIONS WHERE facility_id IS NULL
UNION ALL
SELECT 'Blood units with missing donation reference', COUNT(*)
FROM BLOOD_UNITS WHERE donation_id IS NULL
UNION ALL
SELECT 'Requests with missing requesting facility', COUNT(*)
FROM REQUESTS WHERE requesting_facility_id IS NULL;

-- 3. Verify Foreign Key Integrity
PROMPT Checking foreign key integrity...

SELECT 'Orphaned donations (invalid donor_id)' AS integrity_check, COUNT(*) AS violations
FROM DONATIONS d
WHERE NOT EXISTS (SELECT 1 FROM DONORS WHERE donor_id = d.donor_id)
UNION ALL
SELECT 'Orphaned blood units (invalid donation_id)', COUNT(*)
FROM BLOOD_UNITS bu
WHERE NOT EXISTS (SELECT 1 FROM DONATIONS WHERE donation_id = bu.donation_id)
UNION ALL
SELECT 'Orphaned test results (invalid unit_id)', COUNT(*)
FROM TEST_RESULTS tr
WHERE NOT EXISTS (SELECT 1 FROM BLOOD_UNITS WHERE unit_id = tr.unit_id)
UNION ALL
SELECT 'Orphaned appointments (invalid donor_id)', COUNT(*)
FROM APPOINTMENTS a
WHERE NOT EXISTS (SELECT 1 FROM DONORS WHERE donor_id = a.donor_id);

PROMPT ============================================================
PROMPT BASIC RETRIEVAL QUERIES (SELECT *)
PROMPT ============================================================

-- 4. Sample data from each table
SELECT 'Sample Facilities Data' AS query_type FROM dual;
SELECT * FROM FACILITIES WHERE ROWNUM <= 5;

SELECT 'Sample Donors Data' AS query_type FROM dual;
SELECT * FROM DONORS WHERE ROWNUM <= 5;

SELECT 'Sample Donations Data' AS query_type FROM dual;
SELECT * FROM DONATIONS WHERE ROWNUM <= 5;

SELECT 'Sample Blood Units Data' AS query_type FROM dual;
SELECT * FROM BLOOD_UNITS WHERE ROWNUM <= 5;

SELECT 'Sample Requests Data' AS query_type FROM dual;
SELECT * FROM REQUESTS WHERE ROWNUM <= 5;

PROMPT ============================================================
PROMPT JOIN QUERIES (Multi-table)
PROMPT ============================================================

-- 5. Donors with their donation history
SELECT 'Donors with Donation History (Last 6 months)' AS report_title FROM dual;
SELECT 
    d.donor_id,
    d.first_name || ' ' || d.last_name AS donor_name,
    d.blood_type || d.rh_factor AS blood_group,
    d.total_donations,
    don.donation_id,
    don.donation_date,
    don.donation_type,
    f.facility_name
FROM DONORS d
JOIN DONATIONS don ON d.donor_id = don.donor_id
JOIN FACILITIES f ON don.facility_id = f.facility_id
WHERE don.donation_date >= ADD_MONTHS(SYSDATE, -6)
ORDER BY don.donation_date DESC
FETCH FIRST 20 ROWS ONLY;

-- 6. Blood units with test results
SELECT 'Blood Units with Test Results' AS report_title FROM dual;
SELECT 
    bu.unit_id,
    bu.unit_number,
    bu.blood_type || bu.rh_factor AS blood_group,
    bu.component_type,
    bu.status,
    f.facility_name,
    tr.test_type,
    tr.test_result,
    tr.test_date
FROM BLOOD_UNITS bu
JOIN FACILITIES f ON bu.facility_id = f.facility_id
JOIN TEST_RESULTS tr ON bu.unit_id = tr.unit_id
WHERE bu.status = 'Available'
ORDER BY bu.unit_id, tr.test_date
FETCH FIRST 20 ROWS ONLY;

-- 7. Requests with fulfillment details
SELECT 'Blood Requests with Fulfillment Status' AS report_title FROM dual;
SELECT 
    r.request_id,
    req_fac.facility_name AS requesting_facility,
    ful_fac.facility_name AS fulfilling_facility,
    r.blood_type || r.rh_factor AS blood_group,
    r.component_type,
    r.quantity_requested,
    r.quantity_fulfilled,
    r.urgency_level,
    r.status,
    r.request_date,
    r.required_by_date
FROM REQUESTS r
JOIN FACILITIES req_fac ON r.requesting_facility_id = req_fac.facility_id
LEFT JOIN FACILITIES ful_fac ON r.fulfilling_facility_id = ful_fac.facility_id
ORDER BY r.request_date DESC
FETCH FIRST 20 ROWS ONLY;

-- 8. Transfer tracking with items
SELECT 'Blood Transfer Tracking' AS report_title FROM dual;
SELECT 
    t.transfer_id,
    src.facility_name AS source_facility,
    dst.facility_name AS destination_facility,
    t.transfer_date,
    t.status,
    t.transport_method,
    ti.unit_id,
    ti.blood_type,
    ti.condition_on_departure,
    ti.condition_on_arrival
FROM TRANSFERS t
JOIN FACILITIES src ON t.source_facility_id = src.facility_id
JOIN FACILITIES dst ON t.destination_facility_id = dst.facility_id
LEFT JOIN TRANSFER_ITEMS ti ON t.transfer_id = ti.transfer_id
ORDER BY t.transfer_date DESC
FETCH FIRST 20 ROWS ONLY;

-- 9. Donation with eligibility check and adverse events
SELECT 'Donations with Pre-screening and Adverse Events' AS report_title FROM dual;
SELECT 
    d.donor_id,
    don.first_name || ' ' || don.last_name AS donor_name,
    ec.check_date,
    ec.is_eligible,
    d.donation_date,
    d.donation_type,
    d.status AS donation_status,
    ae.event_type,
    ae.severity
FROM DONATIONS d
JOIN DONORS don ON d.donor_id = don.donor_id
LEFT JOIN ELIGIBILITY_CHECKS ec ON d.donor_id = ec.donor_id 
    AND ec.check_date <= d.donation_date
LEFT JOIN DONATION_ADVERSE_EVENTS ae ON d.donation_id = ae.donation_id
WHERE d.donation_date >= ADD_MONTHS(SYSDATE, -3)
ORDER BY d.donation_date DESC
FETCH FIRST 20 ROWS ONLY;

PROMPT ============================================================
PROMPT AGGREGATION QUERIES (GROUP BY)
PROMPT ============================================================

-- 10. Blood type distribution among donors
SELECT 'Blood Type Distribution' AS report_title FROM dual;
SELECT 
    blood_type || rh_factor AS blood_group,
    COUNT(*) AS donor_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM DONORS), 2) AS percentage
FROM DONORS
WHERE is_active = 'Y'
GROUP BY blood_type, rh_factor
ORDER BY donor_count DESC;

-- 11. Donations by facility (top 10)
SELECT 'Top 10 Facilities by Donation Count' AS report_title FROM dual;
SELECT 
    f.facility_name,
    f.facility_type,
    f.city,
    COUNT(d.donation_id) AS total_donations,
    COUNT(CASE WHEN d.donation_date >= ADD_MONTHS(SYSDATE, -3) THEN 1 END) AS recent_donations
FROM FACILITIES f
LEFT JOIN DONATIONS d ON f.facility_id = d.facility_id
GROUP BY f.facility_id, f.facility_name, f.facility_type, f.city
ORDER BY total_donations DESC
FETCH FIRST 10 ROWS ONLY;

-- 12. Blood unit inventory summary
SELECT 'Blood Inventory by Type and Status' AS report_title FROM dual;
SELECT 
    blood_type || rh_factor AS blood_group,
    component_type,
    status,
    COUNT(*) AS unit_count,
    ROUND(AVG(volume_ml), 2) AS avg_volume_ml
FROM BLOOD_UNITS
GROUP BY blood_type, rh_factor, component_type, status
ORDER BY blood_group, component_type, status;

-- 13. Monthly donation trends (last 12 months)
SELECT 'Monthly Donation Trends' AS report_title FROM dual;
SELECT 
    TO_CHAR(donation_date, 'YYYY-MM') AS month,
    COUNT(*) AS donation_count,
    COUNT(DISTINCT donor_id) AS unique_donors,
    ROUND(AVG(volume_collected_ml), 2) AS avg_volume
FROM DONATIONS
WHERE donation_date >= ADD_MONTHS(SYSDATE, -12)
GROUP BY TO_CHAR(donation_date, 'YYYY-MM')
ORDER BY month DESC;

-- 14. Request fulfillment statistics
SELECT 'Request Fulfillment Statistics' AS report_title FROM dual;
SELECT 
    urgency_level,
    status,
    COUNT(*) AS request_count,
    SUM(quantity_requested) AS total_requested,
    SUM(quantity_fulfilled) AS total_fulfilled,
    ROUND(AVG(quantity_fulfilled * 100.0 / NULLIF(quantity_requested, 0)), 2) AS fulfillment_rate_pct
FROM REQUESTS
GROUP BY urgency_level, status
ORDER BY urgency_level, status;

-- 15. Donor activity analysis
SELECT 'Donor Activity Analysis' AS report_title FROM dual;
SELECT 
    CASE 
        WHEN total_donations = 0 THEN '0 donations'
        WHEN total_donations BETWEEN 1 AND 5 THEN '1-5 donations'
        WHEN total_donations BETWEEN 6 AND 10 THEN '6-10 donations'
        WHEN total_donations BETWEEN 11 AND 20 THEN '11-20 donations'
        ELSE '20+ donations'
    END AS donation_range,
    COUNT(*) AS donor_count,
    ROUND(AVG(total_donations), 2) AS avg_donations
FROM DONORS
WHERE is_active = 'Y'
GROUP BY 
    CASE 
        WHEN total_donations = 0 THEN '0 donations'
        WHEN total_donations BETWEEN 1 AND 5 THEN '1-5 donations'
        WHEN total_donations BETWEEN 6 AND 10 THEN '6-10 donations'
        WHEN total_donations BETWEEN 11 AND 20 THEN '11-20 donations'
        ELSE '20+ donations'
    END
ORDER BY MIN(total_donations);

PROMPT ============================================================
PROMPT SUBQUERY EXAMPLES
PROMPT ============================================================

-- 16. Donors who have donated more than average
SELECT 'Donors Above Average Donations' AS report_title FROM dual;
SELECT 
    donor_id,
    first_name || ' ' || last_name AS donor_name,
    blood_type || rh_factor AS blood_group,
    total_donations,
    city
FROM DONORS
WHERE total_donations > (SELECT AVG(total_donations) FROM DONORS)
ORDER BY total_donations DESC
FETCH FIRST 20 ROWS ONLY;

-- 17. Facilities with above-average inventory
SELECT 'Facilities with High Inventory Levels' AS report_title FROM dual;
SELECT 
    f.facility_name,
    f.city,
    SUM(i.quantity_available) AS total_units
FROM FACILITIES f
JOIN INVENTORY i ON f.facility_id = i.facility_id
GROUP BY f.facility_id, f.facility_name, f.city
HAVING SUM(i.quantity_available) > (
    SELECT AVG(total_qty) 
    FROM (
        SELECT SUM(quantity_available) AS total_qty
        FROM INVENTORY
        GROUP BY facility_id
    )
)
ORDER BY total_units DESC;

-- 18. Blood units nearing expiration
SELECT 'Blood Units Expiring Within 7 Days' AS report_title FROM dual;
SELECT 
    bu.unit_id,
    bu.unit_number,
    bu.blood_type || bu.rh_factor AS blood_group,
    bu.component_type,
    bu.expiration_date,
    f.facility_name,
    bu.expiration_date - TRUNC(SYSDATE) AS days_to_expire
FROM BLOOD_UNITS bu
JOIN FACILITIES f ON bu.facility_id = f.facility_id
WHERE bu.status = 'Available'
    AND bu.expiration_date BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE) + 7
ORDER BY bu.expiration_date;

-- 19. Donors eligible to donate (not deferred)
SELECT 'Eligible Donors (Not Currently Deferred)' AS report_title FROM dual;
SELECT 
    d.donor_id,
    d.first_name || ' ' || d.last_name AS donor_name,
    d.blood_type || d.rh_factor AS blood_group,
    d.last_donation_date,
    d.total_donations
FROM DONORS d
WHERE d.status = 'Active'
    AND d.is_active = 'Y'
    AND NOT EXISTS (
        SELECT 1 
        FROM DONOR_DEFERRALS df
        WHERE df.donor_id = d.donor_id
            AND (df.is_permanent = 'Y' OR df.deferred_until > SYSDATE)
    )
    AND (d.last_donation_date IS NULL OR d.last_donation_date <= SYSDATE - 56)
FETCH FIRST 20 ROWS ONLY;

-- 20. Requests that cannot be fulfilled (insufficient inventory)
SELECT 'Unfulfillable Requests (Insufficient Inventory)' AS report_title FROM dual;
SELECT 
    r.request_id,
    req_fac.facility_name,
    r.blood_type || r.rh_factor AS blood_group,
    r.component_type,
    r.quantity_requested,
    r.urgency_level,
    COALESCE((
        SELECT SUM(i.quantity_available)
        FROM INVENTORY i
        WHERE i.blood_type = r.blood_type
            AND i.rh_factor = r.rh_factor
            AND i.component_type = r.component_type
    ), 0) AS available_units
FROM REQUESTS r
JOIN FACILITIES req_fac ON r.requesting_facility_id = req_fac.facility_id
WHERE r.status = 'Pending'
    AND r.quantity_requested > COALESCE((
        SELECT SUM(i.quantity_available)
        FROM INVENTORY i
        WHERE i.blood_type = r.blood_type
            AND i.rh_factor = r.rh_factor
            AND i.component_type = r.component_type
    ), 0);

PROMPT ============================================================
PROMPT BUSINESS RULES VALIDATION
PROMPT ============================================================

-- 21. Check donation interval compliance (56 days for whole blood)
SELECT 'Donations Violating Minimum Interval Rule' AS validation_check FROM dual;
SELECT 
    d1.donor_id,
    d1.donation_id AS first_donation,
    d1.donation_date AS first_date,
    d2.donation_id AS second_donation,
    d2.donation_date AS second_date,
    d2.donation_date - d1.donation_date AS days_between
FROM DONATIONS d1
JOIN DONATIONS d2 ON d1.donor_id = d2.donor_id
WHERE d1.donation_date < d2.donation_date
    AND d2.donation_date - d1.donation_date < 56
    AND d1.donation_type = 'Whole Blood'
    AND d2.donation_type = 'Whole Blood'
ORDER BY days_between;

-- 22. Verify age compliance (18+)
SELECT 'Donors Below Minimum Age' AS validation_check FROM dual;
SELECT 
    donor_id,
    first_name || ' ' || last_name AS donor_name,
    date_of_birth,
    TRUNC(MONTHS_BETWEEN(SYSDATE, date_of_birth) / 12) AS age
FROM DONORS
WHERE MONTHS_BETWEEN(SYSDATE, date_of_birth) / 12 < 18;

-- 23. Check weight compliance (minimum 45kg)
SELECT 'Donations from Underweight Donors' AS validation_check FROM dual;
SELECT 
    d.donation_id,
    don.donor_id,
    don.first_name || ' ' || don.last_name AS donor_name,
    ec.weight_kg,
    d.donation_date
FROM DONATIONS d
JOIN DONORS don ON d.donor_id = don.donor_id
LEFT JOIN ELIGIBILITY_CHECKS ec ON d.donor_id = ec.donor_id 
    AND ec.check_date <= d.donation_date
WHERE ec.weight_kg < 45
FETCH FIRST 10 ROWS ONLY;

-- 24. Expired units still marked as available
SELECT 'Expired Units Still Available' AS validation_check FROM dual;
SELECT 
    unit_id,
    unit_number,
    blood_type || rh_factor AS blood_group,
    expiration_date,
    TRUNC(SYSDATE) - expiration_date AS days_expired,
    status
FROM BLOOD_UNITS
WHERE expiration_date < TRUNC(SYSDATE)
    AND status = 'Available';

PROMPT ============================================================
PROMPT PERFORMANCE AND SUMMARY STATISTICS
PROMPT ============================================================

-- 25. Overall system statistics
SELECT 'System Performance Dashboard' AS dashboard_title FROM dual;
SELECT 
    'Total Active Donors' AS metric,
    TO_CHAR(COUNT(*), '999,999') AS value
FROM DONORS WHERE status = 'Active'
UNION ALL
SELECT 'Total Donations (All Time)', TO_CHAR(COUNT(*), '999,999')
FROM DONATIONS
UNION ALL
SELECT 'Donations (Last 30 Days)', TO_CHAR(COUNT(*), '999,999')
FROM DONATIONS WHERE donation_date >= SYSDATE - 30
UNION ALL
SELECT 'Available Blood Units', TO_CHAR(COUNT(*), '999,999')
FROM BLOOD_UNITS WHERE status = 'Available'
UNION ALL
SELECT 'Pending Requests', TO_CHAR(COUNT(*), '999,999')
FROM REQUESTS WHERE status = 'Pending'
UNION ALL
SELECT 'Active Facilities', TO_CHAR(COUNT(*), '999,999')
FROM FACILITIES WHERE is_active = 'Y'
UNION ALL
SELECT 'Active Staff Members', TO_CHAR(COUNT(*), '999,999')
FROM FACILITY_STAFF WHERE is_active = 'Y';

PROMPT ============================================================
PROMPT VALIDATION COMPLETE
PROMPT ============================================================
