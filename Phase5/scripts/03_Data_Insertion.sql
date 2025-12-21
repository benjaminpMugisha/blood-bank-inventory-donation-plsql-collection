-- ============================================================
-- BLOOD BANK MANAGEMENT SYSTEM - DATA INSERTION (DML)
-- ============================================================
-- Phase V: Realistic Test Data (100-500+ rows per main table)
-- Oracle Database Compatible
-- ============================================================

-- ============================================================
-- 1. INSERT FACILITIES (50 records)
-- ============================================================
INSERT ALL
    INTO FACILITIES VALUES ('FAC001', 'Kigali Central Blood Bank', 'Blood Bank', 'LIC-BB-2020-001', '45 KN 4 Ave', 'Kigali', 'Gasabo', -1.9441, 30.0619, '+250788123001', 'info@kcbb.rw', 5000, '24/7', 'Accredited', DATE '2026-12-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC002', 'King Faisal Hospital', 'Hospital', 'LIC-HOS-2019-045', 'KG 544 St', 'Kigali', 'Gasabo', -1.9536, 30.0908, '+250788123002', 'blood@kfh.rw', 1500, '24/7', 'Accredited', DATE '2025-12-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC003', 'Rwanda Military Hospital', 'Hospital', 'LIC-HOS-2018-078', 'KG 7 Ave', 'Kigali', 'Kicukiro', -1.9659, 30.1046, '+250788123003', 'transfusion@rmh.rw', 1200, '24/7', 'Accredited', DATE '2026-06-30', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC004', 'Muhima District Hospital', 'Hospital', 'LIC-HOS-2020-092', 'KN 5 Rd', 'Kigali', 'Nyarugenge', -1.9578, 30.0622, '+250788123004', 'lab@muhima.rw', 800, '06:00-22:00', 'Accredited', DATE '2025-09-30', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC005', 'Butare University Hospital', 'Hospital', 'LIC-HOS-2017-034', 'Avenue de Butare', 'Huye', 'Huye', -2.5967, 29.7389, '+250788123005', 'blood@buth.rw', 1000, '24/7', 'Accredited', DATE '2026-03-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC006', 'Gisenyi Blood Collection Center', 'Collection Center', 'LIC-CC-2021-015', 'Beach Road', 'Rubavu', 'Rubavu', -1.7025, 29.2561, '+250788123006', 'collect@gisenyi.rw', 300, '08:00-18:00', 'Accredited', DATE '2026-08-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC007', 'Ruhengeri Regional Hospital', 'Hospital', 'LIC-HOS-2019-056', 'Musanze Road', 'Musanze', 'Musanze', -1.5008, 29.6344, '+250788123007', 'transfusion@rrh.rw', 700, '24/7', 'Accredited', DATE '2025-11-30', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC008', 'Mobile Blood Unit - North', 'Mobile Unit', 'LIC-MU-2022-003', 'N/A', 'Musanze', 'Musanze', -1.5008, 29.6344, '+250788123008', 'mobile.north@nbs.rw', 100, 'Variable', 'Accredited', DATE '2026-12-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC009', 'Kibagabaga Hospital', 'Hospital', 'LIC-HOS-2018-089', 'KG 11 Ave', 'Kigali', 'Gasabo', -1.9347, 30.1120, '+250788123009', 'lab@kibagabaga.rw', 600, '24/7', 'Accredited', DATE '2026-01-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC010', 'Nyamata District Hospital', 'Hospital', 'LIC-HOS-2020-067', 'Bugesera Road', 'Bugesera', 'Bugesera', -2.1431, 30.1167, '+250788123010', 'blood@nyamata.rw', 400, '06:00-20:00', 'Pending', NULL, 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC011', 'Kigali University Teaching Hospital', 'Hospital', 'LIC-HOS-2016-012', 'Nyarugenge District', 'Kigali', 'Nyarugenge', -1.9550, 30.0588, '+250788123011', 'transfusion@kuth.rw', 2000, '24/7', 'Accredited', DATE '2025-08-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC012', 'Rwamagana Provincial Hospital', 'Hospital', 'LIC-HOS-2019-078', 'Eastern Province', 'Rwamagana', 'Rwamagana', -1.9486, 30.4347, '+250788123012', 'lab@rwamagana.rw', 500, '24/7', 'Accredited', DATE '2026-04-30', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC013', 'Byumba District Hospital', 'Hospital', 'LIC-HOS-2020-091', 'Northern Province', 'Gicumbi', 'Gicumbi', -1.5761, 30.0672, '+250788123013', 'blood@byumba.rw', 450, '06:00-22:00', 'Accredited', DATE '2025-10-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC014', 'Kabutare District Hospital', 'Hospital', 'LIC-HOS-2018-045', 'Southern Province', 'Huye', 'Huye', -2.5967, 29.7389, '+250788123014', 'lab@kabutare.rw', 400, '06:00-20:00', 'Pending', NULL, 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC015', 'Mobile Blood Unit - South', 'Mobile Unit', 'LIC-MU-2022-005', 'N/A', 'Huye', 'Huye', -2.5967, 29.7389, '+250788123015', 'mobile.south@nbs.rw', 100, 'Variable', 'Accredited', DATE '2026-12-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC016', 'Nyagatare District Hospital', 'Hospital', 'LIC-HOS-2019-102', 'Eastern Province', 'Nyagatare', 'Nyagatare', -1.2989, 30.3256, '+250788123016', 'transfusion@nyagatare.rw', 550, '24/7', 'Accredited', DATE '2026-07-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC017', 'Gikongoro Blood Collection Center', 'Collection Center', 'LIC-CC-2021-008', 'Southern Province', 'Nyamagabe', 'Nyamagabe', -2.4833, 29.5667, '+250788123017', 'collect@gikongoro.rw', 250, '08:00-17:00', 'Pending', NULL, 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC018', 'Kabgayi Hospital', 'Hospital', 'LIC-HOS-2017-056', 'Southern Province', 'Muhanga', 'Muhanga', -2.0333, 29.8333, '+250788123018', 'blood@kabgayi.rw', 800, '24/7', 'Accredited', DATE '2025-12-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC019', 'Cyangugu District Hospital', 'Hospital', 'LIC-HOS-2020-078', 'Western Province', 'Rusizi', 'Rusizi', -2.4833, 28.9000, '+250788123019', 'lab@cyangugu.rw', 450, '06:00-22:00', 'Accredited', DATE '2026-05-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC020', 'Kibuye Hospital', 'Hospital', 'LIC-HOS-2018-123', 'Western Province', 'Karongi', 'Karongi', -2.0622, 29.3478, '+250788123020', 'transfusion@kibuye.rw', 500, '24/7', 'Accredited', DATE '2025-09-30', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC021', 'Ndera Neuropsychiatric Hospital', 'Hospital', 'LIC-HOS-2019-087', 'Gasabo District', 'Kigali', 'Gasabo', -1.9125, 30.1347, '+250788123021', 'blood@ndera.rw', 300, '24/7', 'Accredited', DATE '2026-02-28', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC022', 'Masaka District Hospital', 'Hospital', 'LIC-HOS-2020-055', 'Kicukiro District', 'Kigali', 'Kicukiro', -1.9875, 30.1125, '+250788123022', 'lab@masaka.rw', 400, '06:00-22:00', 'Pending', NULL, 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC023', 'Gahini Hospital', 'Hospital', 'LIC-HOS-2018-067', 'Eastern Province', 'Kayonza', 'Kayonza', -1.9667, 30.5167, '+250788123023', 'transfusion@gahini.rw', 350, '06:00-20:00', 'Accredited', DATE '2025-11-30', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC024', 'Kibirizi District Hospital', 'Hospital', 'LIC-HOS-2019-091', 'Southern Province', 'Ruhango', 'Ruhango', -2.2333, 29.7833, '+250788123024', 'blood@kibirizi.rw', 300, '06:00-18:00', 'Pending', NULL, 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC025', 'Mobile Blood Unit - East', 'Mobile Unit', 'LIC-MU-2022-007', 'N/A', 'Rwamagana', 'Rwamagana', -1.9486, 30.4347, '+250788123025', 'mobile.east@nbs.rw', 100, 'Variable', 'Accredited', DATE '2026-12-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
SELECT * FROM dual;

INSERT ALL
    INTO FACILITIES VALUES ('FAC026', 'Rwinkwavu Hospital', 'Hospital', 'LIC-HOS-2020-089', 'Eastern Province', 'Kayonza', 'Kayonza', -1.9667, 30.6833, '+250788123026', 'lab@rwinkwavu.rw', 400, '24/7', 'Accredited', DATE '2026-08-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC027', 'Nemba Hospital', 'Hospital', 'LIC-HOS-2019-076', 'Northern Province', 'Gakenke', 'Gakenke', -1.6833, 29.7667, '+250788123027', 'transfusion@nemba.rw', 350, '06:00-20:00', 'Pending', NULL, 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC028', 'Gitwe Hospital', 'Hospital', 'LIC-HOS-2018-098', 'Southern Province', 'Ruhango', 'Ruhango', -2.1833, 29.8167, '+250788123028', 'blood@gitwe.rw', 300, '06:00-18:00', 'Accredited', DATE '2025-10-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC029', 'Muhoza Health Center', 'Collection Center', 'LIC-CC-2021-012', 'Northern Province', 'Musanze', 'Musanze', -1.4833, 29.6333, '+250788123029', 'collect@muhoza.rw', 200, '08:00-17:00', 'Pending', NULL, 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC030', 'Shyira Hospital', 'Hospital', 'LIC-HOS-2019-104', 'Northern Province', 'Nyabihu', 'Nyabihu', -1.6500, 29.5167, '+250788123030', 'lab@shyira.rw', 450, '24/7', 'Accredited', DATE '2026-06-30', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC031', 'Kinihira Hospital', 'Hospital', 'LIC-HOS-2020-071', 'Eastern Province', 'Gatsibo', 'Gatsibo', -1.6167, 30.4167, '+250788123031', 'transfusion@kinihira.rw', 350, '06:00-22:00', 'Pending', NULL, 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC032', 'Kibungo Hospital', 'Hospital', 'LIC-HOS-2018-082', 'Eastern Province', 'Ngoma', 'Ngoma', -2.1667, 30.5333, '+250788123032', 'blood@kibungo.rw', 500, '24/7', 'Accredited', DATE '2025-12-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC033', 'Rulindo District Hospital', 'Hospital', 'LIC-HOS-2019-095', 'Northern Province', 'Rulindo', 'Rulindo', -1.7833, 30.0167, '+250788123033', 'lab@rulindo.rw', 350, '06:00-20:00', 'Pending', NULL, 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC034', 'Kaduha Hospital', 'Hospital', 'LIC-HOS-2020-086', 'Southern Province', 'Nyamagabe', 'Nyamagabe', -2.5667, 29.5333, '+250788123034', 'transfusion@kaduha.rw', 300, '06:00-18:00', 'Accredited', DATE '2026-04-30', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC035', 'Mobile Blood Unit - West', 'Mobile Unit', 'LIC-MU-2022-009', 'N/A', 'Rubavu', 'Rubavu', -1.7025, 29.2561, '+250788123035', 'mobile.west@nbs.rw', 100, 'Variable', 'Accredited', DATE '2026-12-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC036', 'Kibilizi Hospital', 'Hospital', 'LIC-HOS-2019-088', 'Southern Province', 'Gisagara', 'Gisagara', -2.5667, 29.8333, '+250788123036', 'blood@kibilizi.rw', 400, '24/7', 'Accredited', DATE '2025-11-30', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC037', 'Maternity Hospital Muhima', 'Hospital', 'LIC-HOS-2018-073', 'Nyarugenge District', 'Kigali', 'Nyarugenge', -1.9600, 30.0600, '+250788123037', 'lab@maternity.rw', 600, '24/7', 'Accredited', DATE '2026-03-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC038', 'Nyamasheke District Hospital', 'Hospital', 'LIC-HOS-2020-093', 'Western Province', 'Nyamasheke', 'Nyamasheke', -2.3167, 29.1000, '+250788123038', 'transfusion@nyamasheke.rw', 350, '06:00-22:00', 'Pending', NULL, 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC039', 'Rutongo Hospital', 'Hospital', 'LIC-HOS-2019-101', 'Northern Province', 'Rulindo', 'Rulindo', -1.8333, 30.0833, '+250788123039', 'blood@rutongo.rw', 300, '06:00-20:00', 'Accredited', DATE '2026-07-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC040', 'Remera Rukoma Health Center', 'Collection Center', 'LIC-CC-2021-018', 'Gasabo District', 'Kigali', 'Gasabo', -1.9458, 30.0994, '+250788123040', 'collect@remera.rw', 200, '08:00-18:00', 'Pending', NULL, 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC041', 'Ruli District Hospital', 'Hospital', 'LIC-HOS-2020-097', 'Northern Province', 'Gakenke', 'Gakenke', -1.7167, 29.8000, '+250788123041', 'lab@ruli.rw', 350, '06:00-22:00', 'Accredited', DATE '2026-01-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC042', 'Bushenge District Hospital', 'Hospital', 'LIC-HOS-2019-109', 'Western Province', 'Nyamasheke', 'Nyamasheke', -2.3500, 29.1167, '+250788123042', 'transfusion@bushenge.rw', 300, '06:00-18:00', 'Pending', NULL, 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC043', 'Munini Hospital', 'Hospital', 'LIC-HOS-2018-091', 'Northern Province', 'Burera', 'Burera', -1.4500, 29.8667, '+250788123043', 'blood@munini.rw', 300, '06:00-20:00', 'Accredited', DATE '2025-09-30', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC044', 'Ngoma District Hospital', 'Hospital', 'LIC-HOS-2020-103', 'Eastern Province', 'Ngoma', 'Ngoma', -2.1833, 30.5500, '+250788123044', 'lab@ngoma.rw', 400, '24/7', 'Accredited', DATE '2026-05-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC045', 'Kinazi Health Center', 'Collection Center', 'LIC-CC-2021-021', 'Southern Province', 'Ruhango', 'Ruhango', -2.2667, 29.7667, '+250788123045', 'collect@kinazi.rw', 150, '08:00-17:00', 'Pending', NULL, 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC046', 'Kabare District Hospital', 'Hospital', 'LIC-HOS-2019-112', 'Southern Province', 'Nyanza', 'Nyanza', -2.3500, 29.7500, '+250788123046', 'transfusion@kabare.rw', 350, '06:00-22:00', 'Accredited', DATE '2026-08-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC047', 'Kirehe District Hospital', 'Hospital', 'LIC-HOS-2020-108', 'Eastern Province', 'Kirehe', 'Kirehe', -2.2833, 30.7167, '+250788123047', 'blood@kirehe.rw', 400, '24/7', 'Pending', NULL, 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC048', 'Buhanda Health Center', 'Collection Center', 'LIC-CC-2021-024', 'Western Province', 'Rusizi', 'Rusizi', -2.5167, 28.9333, '+250788123048', 'collect@buhanda.rw', 150, '08:00-17:00', 'Pending', NULL, 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC049', 'Nyanza District Hospital', 'Hospital', 'LIC-HOS-2019-116', 'Southern Province', 'Nyanza', 'Nyanza', -2.3500, 29.7500, '+250788123049', 'lab@nyanzadh.rw', 450, '24/7', 'Accredited', DATE '2025-10-31', 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
    INTO FACILITIES VALUES ('FAC050', 'Rutsiro District Hospital', 'Hospital', 'LIC-HOS-2020-111', 'Western Province', 'Rutsiro', 'Rutsiro', -1.9833, 29.3500, '+250788123050', 'transfusion@rutsiro.rw', 300, '06:00-20:00', 'Pending', NULL, 'Y', SYSTIMESTAMP, SYSTIMESTAMP)
SELECT * FROM dual;

COMMIT;

-- ============================================================
-- 2. INSERT DONORS (500 records)
-- ============================================================
BEGIN
    FOR i IN 1..500 LOOP
        INSERT INTO DONORS VALUES (
            'DON' || LPAD(i, 3, '0'),
            '1' || TO_CHAR(1990000000 + TRUNC(DBMS_RANDOM.VALUE(0, 30000000)), 'FM000000000000000'),
            CASE MOD(i, 30)
                WHEN 0 THEN 'Emmanuel' WHEN 1 THEN 'Francine' WHEN 2 THEN 'Isaac' WHEN 3 THEN 'Josiane'
                WHEN 4 THEN 'Claude' WHEN 5 THEN 'Jeanne' WHEN 6 THEN 'Antoine' WHEN 7 THEN 'Beatrice'
                WHEN 8 THEN 'Olivier' WHEN 9 THEN 'Chantal' WHEN 10 THEN 'Fabrice' WHEN 11 THEN 'Louise'
                WHEN 12 THEN 'Gilbert' WHEN 13 THEN 'Consolee' WHEN 14 THEN 'Vincent' WHEN 15 THEN 'Agnes'
                WHEN 16 THEN 'Thierry' WHEN 17 THEN 'Nadine' WHEN 18 THEN 'Bernard' WHEN 19 THEN 'Vestine'
                WHEN 20 THEN 'Justin' WHEN 21 THEN 'Claudine' WHEN 22 THEN 'Pascal' WHEN 23 THEN 'Josephine'
                WHEN 24 THEN 'Andre' WHEN 25 THEN 'Marie' WHEN 26 THEN 'Jacques' WHEN 27 THEN 'Esperance'
                WHEN 28 THEN 'Felix' ELSE 'Christine'
            END,
            CASE MOD(i, 30)
                WHEN 0 THEN 'Rwabukwisi' WHEN 1 THEN 'Nyirahabimana' WHEN 2 THEN 'Kamanzi' WHEN 3 THEN 'Uwimana'
                WHEN 4 THEN 'Nsabimana' WHEN 5 THEN 'Murekatete' WHEN 6 THEN 'Uwizera' WHEN 7 THEN 'Nyiraneza'
                WHEN 8 THEN 'Hakizimana' WHEN 9 THEN 'Mukandayisenga' WHEN 10 THEN 'Niyomugabo' WHEN 11 THEN 'Uwimbabazi'
                WHEN 12 THEN 'Ndayisenga' WHEN 13 THEN 'Nyirarukundo' WHEN 14 THEN 'Nkundimana' WHEN 15 THEN 'Mukarusagara'
                WHEN 16 THEN 'Nsengimana' WHEN 17 THEN 'Uwamahoro' WHEN 18 THEN 'Habimana' WHEN 19 THEN 'Mukamana'
                WHEN 20 THEN 'Niyonsenga' WHEN 21 THEN 'Mukandori' WHEN 22 THEN 'Rwagasore' WHEN 23 THEN 'Nyiramana'
                WHEN 24 THEN 'Ntaganda' WHEN 25 THEN 'Mukantwali' WHEN 26 THEN 'Habyarimana' WHEN 27 THEN 'Nyirabahizi'
                WHEN 28 THEN 'Munyeshyaka' ELSE 'Uwera'
            END,
            ADD_MONTHS(SYSDATE, -(12 * (18 + TRUNC(DBMS_RANDOM.VALUE(0, 52))))),
            CASE WHEN MOD(i, 3) = 0 THEN 'F' ELSE 'M' END,  -- Removed 'O' since only 'M' and 'F' are allowed
            CASE MOD(i, 4) WHEN 0 THEN 'O' WHEN 1 THEN 'A' WHEN 2 THEN 'B' ELSE 'AB' END,
            CASE WHEN MOD(i, 8) < 2 THEN '-' ELSE '+' END,
            50 + TRUNC(DBMS_RANDOM.VALUE(0, 50)),  -- Changed from 48 to 50 to ensure >= 50 constraint
            '+25078' || LPAD(8000000 + i, 7, '0'),
            'donor' || i || '@email.rw',
            CASE MOD(i, 5)
                WHEN 0 THEN 'KN ' || TRUNC(DBMS_RANDOM.VALUE(1, 100)) || ' Ave'
                WHEN 1 THEN 'KG ' || TRUNC(DBMS_RANDOM.VALUE(1, 1000)) || ' St'
                WHEN 2 THEN 'KK ' || TRUNC(DBMS_RANDOM.VALUE(1, 500)) || ' Rd'
                ELSE 'Sector ' || TRUNC(DBMS_RANDOM.VALUE(1, 50))
            END,
            CASE MOD(i, 12)
                WHEN 0 THEN 'Kigali' WHEN 1 THEN 'Huye' WHEN 2 THEN 'Musanze' WHEN 3 THEN 'Rubavu'
                WHEN 4 THEN 'Rwamagana' WHEN 5 THEN 'Nyagatare' WHEN 6 THEN 'Muhanga' WHEN 7 THEN 'Rusizi'
                WHEN 8 THEN 'Ngoma' WHEN 9 THEN 'Bugesera' WHEN 10 THEN 'Nyanza' ELSE 'Karongi'
            END,
            CASE MOD(i, 12)
                WHEN 0 THEN 'Gasabo' WHEN 1 THEN 'Huye' WHEN 2 THEN 'Musanze' WHEN 3 THEN 'Rubavu'
                WHEN 4 THEN 'Rwamagana' WHEN 5 THEN 'Nyagatare' WHEN 6 THEN 'Muhanga' WHEN 7 THEN 'Rusizi'
                WHEN 8 THEN 'Ngoma' WHEN 9 THEN 'Bugesera' WHEN 10 THEN 'Nyanza' ELSE 'Karongi'
            END,
            'Emergency Contact ' || i,
            '+25078' || LPAD(9000000 + i, 7, '0'),
            TRUNC(DBMS_RANDOM.VALUE(0, 35)),  -- TOTAL_DONATIONS (>= 0 constraint satisfied)
            CASE 
                WHEN MOD(i, 4) = 0 THEN NULL 
                WHEN MOD(i, 3) = 0 THEN TRUNC(SYSDATE - DBMS_RANDOM.VALUE(90, 365))
                ELSE TRUNC(SYSDATE - DBMS_RANDOM.VALUE(30, 120))
            END,
            CASE MOD(i, 10)  -- STATUS column - ONLY 'Active', 'Deferred', or 'Inactive'
                WHEN 0 THEN 'Active'
                WHEN 1 THEN 'Active'
                WHEN 2 THEN 'Deferred'
                WHEN 3 THEN 'Deferred'
                WHEN 4 THEN 'Inactive'
                ELSE 'Active'
            END,
            'Y',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );
    END LOOP;
    COMMIT;
END;
/
-- ============================================================
-- BLOOD BANK - COMPLETE DATA INSERTION
-- ============================================================

-- ============================================================
-- 3. INSERT FACILITY_STAFF (200 records)
-- ============================================================
BEGIN
    FOR i IN 1..200 LOOP
        INSERT INTO FACILITY_STAFF VALUES (
            'STAFF' || LPAD(i, 3, '0'),
            'FAC' || LPAD(1 + MOD(i - 1, 50), 3, '0'),
            CASE MOD(i, 15)
                WHEN 0 THEN 'Jean' WHEN 1 THEN 'Marie' WHEN 2 THEN 'Paul' WHEN 3 THEN 'Claire'
                WHEN 4 THEN 'David' WHEN 5 THEN 'Sarah' WHEN 6 THEN 'Peter' WHEN 7 THEN 'Alice'
                WHEN 8 THEN 'James' WHEN 9 THEN 'Grace' WHEN 10 THEN 'Thomas' WHEN 11 THEN 'Rose'
                WHEN 12 THEN 'Robert' WHEN 13 THEN 'Jane' WHEN 14 THEN 'Michael' ELSE 'Elizabeth'
            END,
            CASE MOD(i, 15)
                WHEN 0 THEN 'Ndahayo' WHEN 1 THEN 'Uwase' WHEN 2 THEN 'Mugisha' WHEN 3 THEN 'Ineza'
                WHEN 4 THEN 'Habimana' WHEN 5 THEN 'Mukamana' WHEN 6 THEN 'Nzabandora' WHEN 7 THEN 'Umutoni'
                WHEN 8 THEN 'Rukundo' WHEN 9 THEN 'Uwimana' WHEN 10 THEN 'Hakizimana' WHEN 11 THEN 'Nyiraneza'
                WHEN 12 THEN 'Ndayisaba' WHEN 13 THEN 'Murekatete' WHEN 14 THEN 'Nsabimana' ELSE 'Uwamahoro'
            END,
            CASE MOD(i, 6)
                WHEN 0 THEN 'Phlebotomist' WHEN 1 THEN 'Lab Technician' WHEN 2 THEN 'Nurse'
                WHEN 3 THEN 'Doctor' WHEN 4 THEN 'Administrator' ELSE 'Manager'
            END,
            CASE MOD(i, 6)
                WHEN 0 THEN 'Certified Phlebotomy Technician' 
                WHEN 1 THEN 'Medical Laboratory Scientist'
                WHEN 2 THEN 'Registered Nurse'
                WHEN 3 THEN 'MD in Hematology'
                WHEN 4 THEN 'Health Administration Degree'
                ELSE 'Healthcare Management'
            END,
            'LIC-' || TO_CHAR(1000 + i, 'FM0000'),
            ADD_MONTHS(SYSDATE, 12 * TRUNC(DBMS_RANDOM.VALUE(1, 5))),
            '+25078' || LPAD(7000000 + i, 7, '0'),
            'staff' || i || '@bloodbank.rw',
            'Y',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );
    END LOOP;
    COMMIT;
END;
/

-- ============================================================
-- 4. INSERT EQUIPMENT (120 records)
-- ============================================================
BEGIN
    FOR i IN 1..120 LOOP
        INSERT INTO EQUIPMENT VALUES (
            'EQP' || LPAD(i, 3, '0'),
            'FAC' || LPAD(1 + MOD(i - 1, 50), 3, '0'),
            CASE MOD(i, 6)
                WHEN 0 THEN 'Blood Collection Monitor ' || i
                WHEN 1 THEN 'Refrigerated Centrifuge ' || i
                WHEN 2 THEN 'Blood Bank Refrigerator ' || i
                WHEN 3 THEN 'Blood Mixer ' || i
                WHEN 4 THEN 'ELISA Analyzer ' || i
                ELSE 'Autoclave ' || i
            END,
            CASE MOD(i, 6)
                WHEN 0 THEN 'Centrifuge' WHEN 1 THEN 'Refrigerator' WHEN 2 THEN 'Freezer'
                WHEN 3 THEN 'Blood Mixer' WHEN 4 THEN 'Testing Equipment' ELSE 'Sterilizer'
            END,
            'SN-' || TO_CHAR(2023000 + i, 'FM0000000'),
            TRUNC(SYSDATE - DBMS_RANDOM.VALUE(365, 1825)),
            TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 180)),
            TRUNC(SYSDATE + DBMS_RANDOM.VALUE(30, 365)),
            CASE MOD(i, 20)
                WHEN 0 THEN 'Maintenance' WHEN 1 THEN 'Out of Service' ELSE 'Operational'
            END,
            CASE MOD(i, 4)
                WHEN 0 THEN 'Haemonetics Corporation'
                WHEN 1 THEN 'Terumo BCT'
                WHEN 2 THEN 'Fresenius Kabi'
                ELSE 'Beckman Coulter'
            END,
            'Regular maintenance scheduled',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );
    END LOOP;
    COMMIT;
END;
/

-- ============================================================
-- 5. INSERT ELIGIBILITY_CHECKS (450 records)
-- ============================================================
BEGIN
    FOR i IN 1..450 LOOP
        INSERT INTO ELIGIBILITY_CHECKS VALUES (
            'CHECK' || LPAD(i, 4, '0'),
            'DON' || LPAD(1 + MOD(i - 1, 500), 3, '0'),
            'FAC' || LPAD(1 + MOD(i - 1, 50), 3, '0'),
            TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 365)),
            SYSTIMESTAMP - DBMS_RANDOM.VALUE(0, 365*24*60*60),
            CASE WHEN MOD(i, 20) = 0 THEN 'N' ELSE 'Y' END,
            CASE WHEN MOD(i, 20) = 0 THEN 
                CASE MOD(i, 4)
                    WHEN 0 THEN 'Low hemoglobin'
                    WHEN 1 THEN 'Recent travel to malaria zone'
                    WHEN 2 THEN 'High blood pressure'
                    ELSE 'Recent medication'
                END
            ELSE NULL END,
            CASE WHEN MOD(i, 20) = 0 THEN 
                TRUNC(SYSDATE + DBMS_RANDOM.VALUE(30, 180))
            ELSE NULL END,
            50 + TRUNC(DBMS_RANDOM.VALUE(0, 50)),
            12.0 + TRUNC(DBMS_RANDOM.VALUE(0, 8)),
            90 + TRUNC(DBMS_RANDOM.VALUE(0, 40)),
            60 + TRUNC(DBMS_RANDOM.VALUE(0, 20)),
            60 + TRUNC(DBMS_RANDOM.VALUE(0, 40)),
            36.0 + TRUNC(DBMS_RANDOM.VALUE(0, 15))/10,
            CASE WHEN MOD(i, 10) = 0 THEN 'Y' ELSE 'N' END,
            CASE WHEN MOD(i, 15) = 0 THEN 'Y' ELSE 'N' END,
            CASE WHEN MOD(i, 12) = 0 THEN 'Y' ELSE 'N' END,
            CASE WHEN MOD(i, 25) = 0 THEN 'Y' ELSE 'N' END,
            'No significant medical history noted',
            'STAFF' || LPAD(1 + MOD(i, 200), 3, '0'),
            SYSTIMESTAMP
        );
    END LOOP;
    COMMIT;
END;
/

-- ============================================================
-- 6. INSERT APPOINTMENTS (400 records)
-- ============================================================
BEGIN
    FOR i IN 1..400 LOOP
        INSERT INTO APPOINTMENTS VALUES (
            'APT' || LPAD(i, 4, '0'),
            'DON' || LPAD(1 + MOD(i - 1, 500), 3, '0'),
            'FAC' || LPAD(1 + MOD(i - 1, 50), 3, '0'),
            TRUNC(SYSDATE + DBMS_RANDOM.VALUE(0, 30)),
            SYSTIMESTAMP + DBMS_RANDOM.VALUE(0, 30*24*60*60),
            CASE MOD(i, 4)
                WHEN 0 THEN 'First Time' WHEN 1 THEN 'Regular' 
                WHEN 2 THEN 'Apheresis' ELSE 'Emergency'
            END,
            CASE MOD(i, 5)
                WHEN 0 THEN 'Scheduled' WHEN 1 THEN 'Confirmed'
                WHEN 2 THEN 'Completed' WHEN 3 THEN 'Cancelled' ELSE 'No Show'
            END,
            TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 30)),
            'STAFF' || LPAD(1 + MOD(i, 200), 3, '0'),
            CASE WHEN MOD(i, 5) = 3 THEN TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 7)) ELSE NULL END,
            CASE WHEN MOD(i, 5) = 3 THEN 'STAFF' || LPAD(1 + MOD(i+50, 200), 3, '0') ELSE NULL END,
            CASE WHEN MOD(i, 5) = 3 THEN 
                CASE MOD(i, 3)
                    WHEN 0 THEN 'Donor not feeling well'
                    WHEN 1 THEN 'Emergency at work'
                    ELSE 'Transport issues'
                END
            ELSE NULL END,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );
    END LOOP;
    COMMIT;
END;
/

-- ============================================================
-- 7. INSERT DONATIONS (350 records)
-- ============================================================
BEGIN
    FOR i IN 1..350 LOOP
        INSERT INTO DONATIONS VALUES (
            'DON_' || LPAD(i, 4, '0'),
            'DON' || LPAD(1 + MOD(i - 1, 500), 3, '0'),
            'FAC' || LPAD(1 + MOD(i - 1, 50), 3, '0'),
            TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 365)),
            SYSTIMESTAMP - DBMS_RANDOM.VALUE(0, 365*24*60*60),
            CASE MOD(i, 4)
                WHEN 0 THEN 'Whole Blood' WHEN 1 THEN 'Apheresis' 
                WHEN 2 THEN 'Platelet' ELSE 'Plasma'
            END,
            i,
            13.0 + TRUNC(DBMS_RANDOM.VALUE(0, 7)),
            110 + TRUNC(DBMS_RANDOM.VALUE(0, 30)),
            70 + TRUNC(DBMS_RANDOM.VALUE(0, 15)),
            70 + TRUNC(DBMS_RANDOM.VALUE(0, 30)),
            36.5 + TRUNC(DBMS_RANDOM.VALUE(0, 10))/10,
            450 + TRUNC(DBMS_RANDOM.VALUE(0, 50)),
            'BAG-' || TO_CHAR(2023000 + i, 'FM0000000'),
            'STAFF' || LPAD(1 + MOD(i, 200), 3, '0'),
            'Completed',
            'Donation completed successfully',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );
    END LOOP;
    COMMIT;
END;
/

-- ============================================================
-- 8. INSERT DONOR_DEFERRALS (50 records)
-- ============================================================
BEGIN
    FOR i IN 1..50 LOOP
        INSERT INTO DONOR_DEFERRALS VALUES (
            'DEF' || LPAD(i, 4, '0'),
            'DON' || LPAD(i*10, 3, '0'),
            CASE MOD(i, 4)
                WHEN 0 THEN 'Medical' WHEN 1 THEN 'Behavioral'
                WHEN 2 THEN 'Test Result' ELSE 'Administrative'
            END,
            CASE MOD(i, 4)
                WHEN 0 THEN 'Low hemoglobin level'
                WHEN 1 THEN 'Recent tattoo'
                WHEN 2 THEN 'Reactive test result'
                ELSE 'Administrative hold'
            END,
            TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 180)),
            CASE WHEN MOD(i, 10) = 0 THEN NULL ELSE
                TRUNC(SYSDATE + DBMS_RANDOM.VALUE(30, 365))
            END,
            'STAFF' || LPAD(1 + MOD(i, 200), 3, '0'),
            CASE WHEN MOD(i, 10) = 0 THEN 'Y' ELSE 'N' END,
            'Follow up required',
            SYSTIMESTAMP
        );
    END LOOP;
    COMMIT;
END;
/

-- ============================================================
-- 9. INSERT BLOOD_UNITS (450 records)
-- ============================================================
BEGIN
    FOR i IN 1..450 LOOP
        DECLARE
            v_donor_id VARCHAR2(20);
            v_blood_type VARCHAR2(3);
            v_rh_factor VARCHAR2(1);
        BEGIN
            v_donor_id := 'DON' || LPAD(1 + MOD(i - 1, 500), 3, '0');
            
            -- Get blood type from donor
            SELECT blood_type, rh_factor INTO v_blood_type, v_rh_factor
            FROM DONORS 
            WHERE donor_id = v_donor_id;
            
            INSERT INTO BLOOD_UNITS VALUES (
                'UNIT' || LPAD(i, 4, '0'),
                'DON_' || LPAD(1 + MOD(i - 1, 350), 4, '0'),
                'FAC' || LPAD(1 + MOD(i - 1, 50), 3, '0'),
                v_blood_type,
                v_rh_factor,
                CASE MOD(i, 5)
                    WHEN 0 THEN 'Whole Blood' WHEN 1 THEN 'Packed RBCs' 
                    WHEN 2 THEN 'Platelets' WHEN 3 THEN 'Fresh Frozen Plasma' 
                    ELSE 'Cryoprecipitate'
                END,
                CASE MOD(i, 5)
                    WHEN 0 THEN 450 WHEN 1 THEN 250 
                    WHEN 2 THEN 200 WHEN 3 THEN 275 
                    ELSE 75
                END,
                'UNIT-' || TO_CHAR(2023000 + i, 'FM0000000'),
                TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 180)),
                TRUNC(SYSDATE + DBMS_RANDOM.VALUE(14, 42)),
                CASE MOD(i, 7)
                    WHEN 0 THEN 'Quarantine' WHEN 1 THEN 'Available' WHEN 2 THEN 'Reserved'
                    WHEN 3 THEN 'Distributed' WHEN 4 THEN 'Expired' WHEN 5 THEN 'Discarded'
                    ELSE 'Testing'
                END,
                CASE WHEN MOD(i, 7) = 0 THEN 'Y' ELSE 'N' END,
                4.0 + TRUNC(DBMS_RANDOM.VALUE(0, 2)),
                'SHELF-' || LPAD(MOD(i, 100), 3, '0'),
                CASE WHEN MOD(i, 7) != 0 THEN TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 7)) ELSE NULL END,
                CASE WHEN MOD(i, 20) = 0 THEN 'REQ' || LPAD(1 + MOD(i, 150), 3, '0') ELSE NULL END,
                'Unit in good condition',
                SYSTIMESTAMP,
                SYSTIMESTAMP
            );
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- Use default values if donor not found
                INSERT INTO BLOOD_UNITS VALUES (
                    'UNIT' || LPAD(i, 4, '0'),
                    'DON_' || LPAD(1 + MOD(i - 1, 350), 4, '0'),
                    'FAC' || LPAD(1 + MOD(i - 1, 50), 3, '0'),
                    CASE MOD(i, 4) WHEN 0 THEN 'O' WHEN 1 THEN 'A' WHEN 2 THEN 'B' ELSE 'AB' END,
                    CASE WHEN MOD(i, 3) = 0 THEN '-' ELSE '+' END,
                    'Whole Blood',
                    450,
                    'UNIT-' || TO_CHAR(2023000 + i, 'FM0000000'),
                    TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 180)),
                    TRUNC(SYSDATE + DBMS_RANDOM.VALUE(14, 42)),
                    'Available',
                    'N',
                    4.0,
                    'SHELF-001',
                    TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 7)),
                    NULL,
                    'Unit in good condition',
                    SYSTIMESTAMP,
                    SYSTIMESTAMP
                );
        END;
    END LOOP;
    COMMIT;
END;
/

-- ============================================================
-- 10. INSERT DONATION_ADVERSE_EVENTS (40 records)
-- ============================================================
BEGIN
    FOR i IN 1..40 LOOP
        INSERT INTO DONATION_ADVERSE_EVENTS VALUES (
            'AE' || LPAD(i, 4, '0'),
            'DON_' || LPAD(1 + MOD(i - 1, 350), 4, '0'),
            CASE MOD(i, 6)
                WHEN 0 THEN 'Vasovagal Reaction' WHEN 1 THEN 'Hematoma'
                WHEN 2 THEN 'Nerve Injury' WHEN 3 THEN 'Arterial Puncture'
                WHEN 4 THEN 'Allergic Reaction' ELSE 'Other'
            END,
            CASE MOD(i, 4)
                WHEN 0 THEN 'Mild' WHEN 1 THEN 'Moderate' 
                WHEN 2 THEN 'Severe' ELSE 'Mild'
            END,
            CASE MOD(i, 6)
                WHEN 0 THEN 'Donor experienced brief loss of consciousness'
                WHEN 1 THEN 'Bruising at venipuncture site'
                WHEN 2 THEN 'Tingling sensation in arm'
                WHEN 3 THEN 'Arterial puncture noted'
                WHEN 4 THEN 'Allergic reaction to antiseptic'
                ELSE 'Other minor reaction'
            END,
            CASE MOD(i, 4)
                WHEN 0 THEN 'Rest and observation'
                WHEN 1 THEN 'Cold compress applied'
                WHEN 2 THEN 'Medical attention provided'
                ELSE 'Follow up scheduled'
            END,
            'STAFF' || LPAD(1 + MOD(i, 200), 3, '0'),
            TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 180)),
            SYSTIMESTAMP - DBMS_RANDOM.VALUE(0, 180*24*60*60),
            SYSTIMESTAMP
        );
    END LOOP;
    COMMIT;
END;
/

-- ============================================================
-- 11. INSERT TEST_RESULTS (900 records)
-- ============================================================
BEGIN
    FOR i IN 1..900 LOOP
        INSERT INTO TEST_RESULTS VALUES (
            'TEST' || LPAD(i, 4, '0'),
            'UNIT' || LPAD(1 + MOD(i - 1, 450), 4, '0'),
            CASE MOD(i, 8)
                WHEN 0 THEN 'HIV-1/2' WHEN 1 THEN 'HBsAg' WHEN 2 THEN 'Anti-HCV'
                WHEN 3 THEN 'Syphilis' WHEN 4 THEN 'Malaria' WHEN 5 THEN 'HTLV'
                WHEN 6 THEN 'Blood Typing' ELSE 'Antibody Screen'
            END,
            CASE MOD(i, 100)
                WHEN 0 THEN 'Positive'
                WHEN 1 THEN 'Reactive'
                WHEN 2 THEN 'Indeterminate'
                ELSE 'Negative'
            END,
            TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 180)),
            'STAFF' || LPAD(1 + MOD(i, 200), 3, '0'),
            'EQP' || LPAD(1 + MOD(i, 120), 3, '0'),
            'FAC' || LPAD(1 + MOD(i, 50), 3, '0'),
            CASE WHEN MOD(i, 100) IN (0,1,2) THEN 'N' ELSE 'Y' END,
            CASE WHEN MOD(i, 100) IN (0,1,2) THEN 'Requires confirmatory testing' ELSE NULL END,
            SYSTIMESTAMP
        );
    END LOOP;
    COMMIT;
END;
/

-- ============================================================
-- 12. INSERT REQUESTS (150 records)
-- ============================================================
BEGIN
    FOR i IN 1..150 LOOP
        INSERT INTO REQUESTS VALUES (
            'REQ' || LPAD(i, 3, '0'),
            'FAC' || LPAD(1 + MOD(i, 50), 3, '0'),
            'FAC' || LPAD(1 + MOD(i + 10, 50), 3, '0'),
            TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 90)),
            SYSTIMESTAMP - DBMS_RANDOM.VALUE(0, 90*24*60*60),
            CASE MOD(i, 4) WHEN 0 THEN 'O' WHEN 1 THEN 'A' WHEN 2 THEN 'B' ELSE 'AB' END,
            CASE WHEN MOD(i, 7) < 2 THEN '-' ELSE '+' END,
            'Red Blood Cells',
            TRUNC(DBMS_RANDOM.VALUE(1, 10)),
            CASE MOD(i, 5)
                WHEN 0 THEN 0
                WHEN 1 THEN TRUNC(DBMS_RANDOM.VALUE(1, 5))
                ELSE TRUNC(DBMS_RANDOM.VALUE(5, 10))
            END,
            CASE MOD(i, 4)
                WHEN 0 THEN 'Emergency' WHEN 1 THEN 'Urgent'
                WHEN 2 THEN 'Routine' ELSE 'Routine'
            END,
            'PAT-' || LPAD(i, 5, '0'),
            20 + TRUNC(DBMS_RANDOM.VALUE(0, 60)),
            50 + TRUNC(DBMS_RANDOM.VALUE(0, 70)),
            CASE MOD(i, 5)
                WHEN 0 THEN 'Trauma' WHEN 1 THEN 'Surgery'
                WHEN 2 THEN 'Anemia' WHEN 3 THEN 'Cancer'
                ELSE 'Maternal'
            END,
            CASE MOD(i, 5)
                WHEN 0 THEN 'Pending' WHEN 1 THEN 'Approved'
                WHEN 2 THEN 'Fulfilled' WHEN 3 THEN 'Partially Fulfilled'
                ELSE 'Cancelled'
            END,
            TRUNC(SYSDATE + DBMS_RANDOM.VALUE(1, 3)),
            SYSTIMESTAMP + DBMS_RANDOM.VALUE(1, 3)*24*60*60,
            CASE WHEN MOD(i, 5) IN (2,3) THEN TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 30)) ELSE NULL END,
            CASE WHEN MOD(i, 5) != 0 THEN 'STAFF' || LPAD(1 + MOD(i, 200), 3, '0') ELSE NULL END,
            CASE WHEN MOD(i, 5) = 0 THEN 'Waiting for approval' ELSE NULL END,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );
    END LOOP;
    COMMIT;
END;
/

-- ============================================================
-- 13. INSERT REQUEST_ITEMS (300 records)
-- ============================================================
BEGIN
    FOR i IN 1..300 LOOP
        INSERT INTO REQUEST_ITEMS VALUES (
            'RI' || LPAD(i, 4, '0'),
            'REQ' || LPAD(1 + MOD(i - 1, 150), 3, '0'),
            'UNIT' || LPAD(1 + MOD(i, 450), 4, '0'),
            CASE MOD(i, 4) WHEN 0 THEN 'O' WHEN 1 THEN 'A' WHEN 2 THEN 'B' ELSE 'AB' END,
            'Red Blood Cells',
            1,
            CASE MOD(i, 3)
                WHEN 0 THEN 'Allocated' WHEN 1 THEN 'Issued' ELSE 'Cancelled'
            END,
            TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 30)),
            SYSTIMESTAMP
        );
    END LOOP;
    COMMIT;
END;
/

-- ============================================================
-- 14. INSERT TRANSFERS (80 records)
-- ============================================================
BEGIN
    FOR i IN 1..80 LOOP
        INSERT INTO TRANSFERS VALUES (
            'TRF' || LPAD(i, 3, '0'),
            'FAC' || LPAD(1 + MOD(i, 50), 3, '0'),
            'FAC' || LPAD(1 + MOD(i + 15, 50), 3, '0'),
            CASE WHEN MOD(i, 3) = 0 THEN 'REQ' || LPAD(1 + MOD(i, 150), 3, '0') ELSE NULL END,
            TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 60)),
            SYSTIMESTAMP - DBMS_RANDOM.VALUE(0, 60*24*60*60),
            'Courier ' || MOD(i, 10),
            'VEH-' || LPAD(1000 + MOD(i, 50), 4, '0'),
            CASE MOD(i, 4)
                WHEN 0 THEN 'Ambulance' WHEN 1 THEN 'Refrigerated Van'
                WHEN 2 THEN 'Motorcycle' ELSE 'Courier Service'
            END,
            TRUNC(DBMS_RANDOM.VALUE(1, 8)),
            TRUNC(SYSDATE + DBMS_RANDOM.VALUE(0.1, 0.5)),
            SYSTIMESTAMP + DBMS_RANDOM.VALUE(0.1, 0.5)*24*60*60,
            CASE WHEN MOD(i, 20) != 0 THEN TRUNC(SYSDATE + DBMS_RANDOM.VALUE(0.1, 0.5)) ELSE NULL END,
            CASE WHEN MOD(i, 20) != 0 THEN SYSTIMESTAMP + DBMS_RANDOM.VALUE(0.1, 0.5)*24*60*60 ELSE NULL END,
            CASE MOD(i, 20)
                WHEN 0 THEN 'Scheduled'
                WHEN 1 THEN 'In Transit'
                WHEN 2 THEN 'Delivered'
                WHEN 3 THEN 'Cancelled'
                ELSE 'Delayed'
            END,
            'Y',
            4.0 + TRUNC(DBMS_RANDOM.VALUE(0, 2)),
            'STAFF' || LPAD(1 + MOD(i, 200), 3, '0'),
            CASE WHEN MOD(i, 20) IN (2,4) THEN 'STAFF' || LPAD(1 + MOD(i + 50, 200), 3, '0') ELSE NULL END,
            CASE WHEN MOD(i, 20) = 4 THEN 'Traffic delay' ELSE NULL END,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );
    END LOOP;
    COMMIT;
END;
/

-- ============================================================
-- 15. INSERT TRANSFER_ITEMS (200 records)
-- ============================================================
BEGIN
    FOR i IN 1..200 LOOP
        INSERT INTO TRANSFER_ITEMS VALUES (
            'TI' || LPAD(i, 4, '0'),
            'TRF' || LPAD(1 + MOD(i - 1, 80), 3, '0'),
            'UNIT' || LPAD(1 + MOD(i, 450), 4, '0'),
            CASE MOD(i, 4) WHEN 0 THEN 'O' WHEN 1 THEN 'A' WHEN 2 THEN 'B' ELSE 'AB' END,
            'Red Blood Cells',
            'Good',
            CASE MOD(i, 20)
                WHEN 0 THEN 'Good'
                WHEN 19 THEN 'Damaged'
                ELSE 'Acceptable'
            END,
            SYSTIMESTAMP
        );
    END LOOP;
    COMMIT;
END;
/

-- ============================================================
-- 16. INSERT BLOOD_UNIT_HISTORY (1200 records)
-- ============================================================
BEGIN
    FOR i IN 1..1200 LOOP
        INSERT INTO BLOOD_UNIT_HISTORY VALUES (
            'HIST' || LPAD(i, 4, '0'),
            'UNIT' || LPAD(1 + MOD(i - 1, 450), 4, '0'),
            CASE MOD(i, 8)
                WHEN 0 THEN 'Created' WHEN 1 THEN 'Tested' WHEN 2 THEN 'Moved'
                WHEN 3 THEN 'Reserved' WHEN 4 THEN 'Allocated' WHEN 5 THEN 'Transfused'
                WHEN 6 THEN 'Expired' ELSE 'Discarded'
            END,
            CASE MOD(i, 8)
                WHEN 0 THEN NULL WHEN 1 THEN 'Quarantine' WHEN 2 THEN 'Available'
                WHEN 3 THEN 'Available' WHEN 4 THEN 'Reserved' WHEN 5 THEN 'Allocated'
                ELSE 'Available'
            END,
            CASE MOD(i, 8)
                WHEN 0 THEN 'Quarantine' WHEN 1 THEN 'Available' WHEN 2 THEN 'Available'
                WHEN 3 THEN 'Reserved' WHEN 4 THEN 'Allocated' WHEN 5 THEN 'Transfused'
                WHEN 6 THEN 'Expired' ELSE 'Discarded'
            END,
            CASE MOD(i, 8)
                WHEN 2 THEN 'Storage-A' ELSE NULL
            END,
            CASE MOD(i, 8)
                WHEN 2 THEN 'Storage-B' ELSE NULL
            END,
            TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 180)),
            SYSTIMESTAMP - DBMS_RANDOM.VALUE(0, 180*24*60*60),
            'STAFF' || LPAD(1 + MOD(i, 200), 3, '0'),
            CASE MOD(i, 8)
                WHEN 0 THEN 'Blood unit created from donation'
                WHEN 1 THEN 'All mandatory tests completed'
                WHEN 2 THEN 'Unit moved to different storage location'
                WHEN 3 THEN 'Unit reserved for pending request'
                WHEN 4 THEN 'Unit allocated to specific request'
                WHEN 5 THEN 'Unit transfused to patient'
                WHEN 6 THEN 'Unit expired and removed from inventory'
                ELSE 'Unit discarded due to quality issues'
            END,
            SYSTIMESTAMP
        );
    END LOOP;
    COMMIT;
END;
/

-- ============================================================
-- 17. INSERT INVENTORY (200 records)
-- ============================================================
BEGIN
    FOR fac IN 1..50 LOOP
        FOR bt IN 1..4 LOOP
            FOR rh IN 1..2 LOOP
                INSERT INTO INVENTORY VALUES (
                    'INV-' || LPAD(fac, 3, '0') || '-' || 
                    CASE bt WHEN 1 THEN 'O' WHEN 2 THEN 'A' WHEN 3 THEN 'B' ELSE 'AB' END ||
                    CASE rh WHEN 1 THEN '+' ELSE '-' END,
                    'FAC' || LPAD(fac, 3, '0'),
                    CASE bt WHEN 1 THEN 'O' WHEN 2 THEN 'A' WHEN 3 THEN 'B' ELSE 'AB' END,
                    CASE rh WHEN 1 THEN '+' ELSE '-' END,
                    'Red Blood Cells',
                    TRUNC(DBMS_RANDOM.VALUE(0, 50)),
                    TRUNC(DBMS_RANDOM.VALUE(0, 10)),
                    TRUNC(DBMS_RANDOM.VALUE(0, 5)),
                    TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 7)),
                    SYSTIMESTAMP,
                    SYSTIMESTAMP
                );
            END LOOP;
        END LOOP;
    END LOOP;
    COMMIT;
END;
/

-- ============================================================
-- VERIFICATION
-- ============================================================
PROMPT Data insertion completed successfully!

SELECT 'FACILITIES' AS table_name, COUNT(*) AS row_count FROM FACILITIES
UNION ALL SELECT 'DONORS', COUNT(*) FROM DONORS
UNION ALL SELECT 'FACILITY_STAFF', COUNT(*) FROM FACILITY_STAFF
UNION ALL SELECT 'EQUIPMENT', COUNT(*) FROM EQUIPMENT
UNION ALL SELECT 'ELIGIBILITY_CHECKS', COUNT(*) FROM ELIGIBILITY_CHECKS
UNION ALL SELECT 'APPOINTMENTS', COUNT(*) FROM APPOINTMENTS
UNION ALL SELECT 'DONATIONS', COUNT(*) FROM DONATIONS
UNION ALL SELECT 'DONOR_DEFERRALS', COUNT(*) FROM DONOR_DEFERRALS
UNION ALL SELECT 'BLOOD_UNITS', COUNT(*) FROM BLOOD_UNITS
UNION ALL SELECT 'DONATION_ADVERSE_EVENTS', COUNT(*) FROM DONATION_ADVERSE_EVENTS
UNION ALL SELECT 'TEST_RESULTS', COUNT(*) FROM TEST_RESULTS
UNION ALL SELECT 'BLOOD_UNIT_HISTORY', COUNT(*) FROM BLOOD_UNIT_HISTORY
UNION ALL SELECT 'INVENTORY', COUNT(*) FROM INVENTORY
UNION ALL SELECT 'REQUESTS', COUNT(*) FROM REQUESTS
UNION ALL SELECT 'REQUEST_ITEMS', COUNT(*) FROM REQUEST_ITEMS
UNION ALL SELECT 'TRANSFERS', COUNT(*) FROM TRANSFERS
UNION ALL SELECT 'TRANSFER_ITEMS', COUNT(*) FROM TRANSFER_ITEMS
ORDER BY table_name;

COMMIT;
