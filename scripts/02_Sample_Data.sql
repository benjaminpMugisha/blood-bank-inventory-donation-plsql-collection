
INSERT INTO donors VALUES (donor_seq.NEXTVAL, 'John', 'Smith', 'O+', '555-0101', 'john.smith@email.com', TO_DATE('1985-05-15', 'YYYY-MM-DD'), NULL, 'Active');
INSERT INTO donors VALUES (donor_seq.NEXTVAL, 'Maria', 'Garcia', 'A-', '555-0102', 'maria.garcia@email.com', TO_DATE('1990-12-20', 'YYYY-MM-DD'), TO_DATE('2025-10-15', 'YYYY-MM-DD'), 'Active');
INSERT INTO donors VALUES (donor_seq.NEXTVAL, 'David', 'Johnson', 'B+', '555-0103', 'david.johnson@email.com', TO_DATE('1978-08-30', 'YYYY-MM-DD'), TO_DATE('2025-09-20', 'YYYY-MM-DD'), 'Active');
INSERT INTO donors VALUES (donor_seq.NEXTVAL, 'Lisa', 'Chen', 'AB+', '555-0104', 'lisa.chen@email.com', TO_DATE('1988-03-10', 'YYYY-MM-DD'), NULL, 'Active');
INSERT INTO donors VALUES (donor_seq.NEXTVAL, 'Robert', 'Brown', 'O-', '555-0105', 'robert.brown@email.com', TO_DATE('1975-11-25', 'YYYY-MM-DD'), TO_DATE('2025-10-10', 'YYYY-MM-DD'), 'Active');


INSERT INTO blood_units VALUES (unit_seq.NEXTVAL, 1002, 'A-', TO_DATE('2025-11-10', 'YYYY-MM-DD'), TO_DATE('2025-12-22', 'YYYY-MM-DD'), 450, 'Passed', 'Main Bank', 'Available');
INSERT INTO blood_units VALUES (unit_seq.NEXTVAL, 1003, 'B+', TO_DATE('2025-11-12', 'YYYY-MM-DD'), TO_DATE('2025-12-24', 'YYYY-MM-DD'), 450, 'Passed', 'Main Bank', 'Available');
INSERT INTO blood_units VALUES (unit_seq.NEXTVAL, 1005, 'O-', TO_DATE('2025-11-15', 'YYYY-MM-DD'), TO_DATE('2025-12-27', 'YYYY-MM-DD'), 450, 'Passed', 'Emergency Stock', 'Available');


INSERT INTO blood_requests VALUES (request_seq.NEXTVAL, 'City General Hospital', 'O+', 5, 'High', TO_DATE('2025-11-16', 'YYYY-MM-DD'), 'Pending');
INSERT INTO blood_requests VALUES (request_seq.NEXTVAL, 'Central Medical', 'A-', 2, 'Critical', TO_DATE('2025-11-16', 'YYYY-MM-DD'), 'Pending');

COMMIT;
