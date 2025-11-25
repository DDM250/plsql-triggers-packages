-- Contribution by Diego Gaju: Created Trigger 2

CREATE OR REPLACE TRIGGER auca_violation_logging_trigger
    AFTER SERVERERROR ON DATABASE
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_error_code NUMBER := ORA_SERVER_ERROR(1);
    v_username VARCHAR2(50);
    v_attempted_action VARCHAR2(100);
    v_reason VARCHAR2(200);
BEGIN
    -- Check if it's our access violation errors
    IF v_error_code IN (-20001, -20002) THEN
        -- Get current user
        v_username := USER;
        
        -- Determine the attempted action based on the calling context
        IF ORA_DICT_OBJ_NAME = 'AUCA_EMPLOYEE_DATA' THEN
            v_attempted_action := 'DML operation on AUCA_EMPLOYEE_DATA';
        ELSE
            v_attempted_action := 'Unknown operation';
        END IF;
        
        -- Set violation reason based on error code
        IF v_error_code = -20001 THEN
            v_reason := 'Sabbath access attempt';
        ELSIF v_error_code = -20002 THEN
            v_reason := 'Outside business hours access attempt';
        END IF;
        
        -- Log the violation
        INSERT INTO auca_access_violations (
            violation_id, username, attempt_time, 
            attempted_action, violation_reason
        ) VALUES (
            auca_violation_seq.NEXTVAL, v_username, SYSTIMESTAMP,
            v_attempted_action, v_reason
        );
        
        COMMIT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Prevent recursion if logging fails
END auca_violation_logging_trigger;
/
