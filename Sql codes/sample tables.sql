-- -- Contribution by Ishimwe Daniel: Created Sample Tables

CREATE TABLE auca_employee_data (
    employee_id NUMBER PRIMARY KEY,
    employee_name VARCHAR2(100),
    salary NUMBER,
    department VARCHAR2(50),
    last_updated DATE
);

-- violation logging table
CREATE TABLE auca_access_violations (
    violation_id NUMBER PRIMARY KEY,
    username VARCHAR2(50),
    attempt_time TIMESTAMP,
    attempted_action VARCHAR2(100),
    violation_reason VARCHAR2(200)
);

-- Sequence for violation IDs
CREATE SEQUENCE auca_violation_seq START WITH 1 INCREMENT BY 1;
