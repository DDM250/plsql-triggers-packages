-- Contribution by Diego Gaju: Created Trigger 1
CREATE OR REPLACE TRIGGER auca_access_restriction_trigger
    BEFORE INSERT OR UPDATE OR DELETE ON auca_employee_data
DECLARE
    v_current_day VARCHAR2(10);
    v_current_hour NUMBER;
    v_current_minute NUMBER;
BEGIN
    -- Get current day and time
    v_current_day := TO_CHAR(SYSDATE, 'DY');
    v_current_hour := TO_NUMBER(TO_CHAR(SYSDATE, 'HH24'));
    v_current_minute := TO_NUMBER(TO_CHAR(SYSDATE, 'MI'));
    
    -- Check if it's Sabbath (Saturday or Sunday)
    IF v_current_day IN ('SAT', 'SUN') THEN
        RAISE_APPLICATION_ERROR(-20001, 
            'Access prohibited: System unavailable on Sabbath (Saturday and Sunday)');
    END IF;
    
    -- Check if outside business hours (8:00 AM to 5:00 PM)
    IF v_current_hour < 8 OR v_current_hour >= 17 THEN
        RAISE_APPLICATION_ERROR(-20002, 
            'Access prohibited: System available only from 8:00 AM to 5:00 PM Monday-Friday');
    END IF;
    
    -- Check if it's exactly 5:00 PM (should block at 5:00 PM, not 5:01 PM)
    IF v_current_hour = 17 AND v_current_minute > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 
            'Access prohibited: System available only from 8:00 AM to 5:00 PM Monday-Friday');
    END IF;
END auca_access_restriction_trigger;
/
