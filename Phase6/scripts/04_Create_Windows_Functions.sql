-- Window function to rank donors by total donations
SELECT 
    donor_id,
    first_name || ' ' || last_name AS donor_name,
    blood_type || rh_factor AS blood_group,
    total_donations,
    RANK() OVER (ORDER BY total_donations DESC) AS donation_rank,
    LAG(total_donations) OVER (ORDER BY total_donations DESC) AS prev_donor_donations,
    LEAD(total_donations) OVER (ORDER BY total_donations DESC) AS next_donor_donations,
    ROUND(AVG(total_donations) OVER (), 2) AS avg_donations_all_donors
FROM DONORS 
WHERE is_active = 'Y' AND status = 'Active'
ORDER BY donation_rank;

-- Window function to analyze monthly donations
SELECT 
    TO_CHAR(donation_date, 'YYYY-MM') AS donation_month,
    facility_id,
    COUNT(*) AS total_donations,
    SUM(COUNT(*)) OVER (PARTITION BY TO_CHAR(donation_date, 'YYYY-MM')) AS monthly_total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY TO_CHAR(donation_date, 'YYYY-MM')), 2) AS pct_of_monthly_total,
    RANK() OVER (PARTITION BY TO_CHAR(donation_date, 'YYYY-MM') ORDER BY COUNT(*) DESC) AS facility_rank
FROM DONATIONS 
WHERE donation_date >= ADD_MONTHS(SYSDATE, -6)
GROUP BY TO_CHAR(donation_date, 'YYYY-MM'), facility_id
ORDER BY donation_month DESC, facility_rank;
