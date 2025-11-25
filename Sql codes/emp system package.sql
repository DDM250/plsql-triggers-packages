CREATE OR REPLACE PACKAGE auca_hr_package 
AUTHID CURRENT_USER  -- Invoker's rights - uses privileges of calling user
AS
    -- Function to calculate RSSB tax and net salary
    FUNCTION calculate_net_salary(
        p_employee_id IN NUMBER
    ) RETURN NUMBER;
    
    -- Function to calculate RSSB tax amount only
    FUNCTION calculate_rssb_tax(
        p_gross_salary IN NUMBER
    ) RETURN NUMBER;
    
    -- Dynamic procedure for various HR operations
    PROCEDURE dynamic_hr_operation(
        p_operation_type IN VARCHAR2,
        p_employee_id IN NUMBER DEFAULT NULL,
        p_new_salary IN NUMBER DEFAULT NULL
    );
    
    -- Bulk processing procedure (Optional Challenge)
    PROCEDURE update_department_salaries(
        p_department IN VARCHAR2,
        p_percentage_raise IN NUMBER
    );
    
END auca_hr_package;
/

CREATE OR REPLACE PACKAGE BODY auca_hr_package AS

    -- RSSB tax rate (example: 5%)
    g_rssb_tax_rate CONSTANT NUMBER := 0.05;
    
    -- FUNCTION: Calculate RSSB tax amount
    FUNCTION calculate_rssb_tax(
        p_gross_salary IN NUMBER
    ) RETURN NUMBER 
    IS
    BEGIN
        RETURN p_gross_salary * g_rssb_tax_rate;
    END calculate_rssb_tax;
    
    -- FUNCTION: Calculate net salary after RSSB tax deduction
    FUNCTION calculate_net_salary(
        p_employee_id IN NUMBER
    ) RETURN NUMBER 
    IS
        v_gross_salary NUMBER;
        v_net_salary NUMBER;
    BEGIN
        -- Get employee's gross salary
        SELECT salary INTO v_gross_salary
        FROM auca_employee_data
        WHERE employee_id = p_employee_id;
        
        -- Calculate net salary (gross - RSSB tax)
        v_net_salary := v_gross_salary - calculate_rssb_tax(v_gross_salary);
        
        RETURN v_net_salary;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20003, 'Employee not found: ' || p_employee_id);
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20004, 'Error calculating net salary: ' || SQLERRM);
    END calculate_net_salary;
    
    -- PROCEDURE: Dynamic HR operation using dynamic SQL
    PROCEDURE dynamic_hr_operation(
        p_operation_type IN VARCHAR2,
        p_employee_id IN NUMBER DEFAULT NULL,
        p_new_salary IN NUMBER DEFAULT NULL
    ) 
    IS
        v_sql_stmt VARCHAR2(1000);
        v_user_name VARCHAR2(100);
        v_current_user VARCHAR2(100);
    BEGIN
        /*
        Difference between USER and CURRENT_USER:
        - USER: Always returns the schema owner name (definer of the package)
        - CURRENT_USER: Returns the current database user executing the code
          With AUTHID CURRENT_USER, CURRENT_USER shows the invoking user's identity
        */
        
        v_user_name := USER;  -- Schema owner (package definer)
        v_current_user := SYS_CONTEXT('USERENV', 'SESSION_USER');  -- Current session user
        
        DBMS_OUTPUT.PUT_LINE('Package Definer (USER): ' || v_user_name);
        DBMS_OUTPUT.PUT_LINE('Current Session User (CURRENT_USER): ' || v_current_user);
        
        -- Dynamic SQL based on operation type
        CASE UPPER(p_operation_type)
            WHEN 'UPDATE_SALARY' THEN
                IF p_employee_id IS NULL OR p_new_salary IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20005, 'Employee ID and new salary required for update');
                END IF;
                
                v_sql_stmt := 'UPDATE auca_employee_data SET salary = :1, last_updated = SYSDATE WHERE employee_id = :2';
                EXECUTE IMMEDIATE v_sql_stmt USING p_new_salary, p_employee_id;
                DBMS_OUTPUT.PUT_LINE('Salary updated for employee: ' || p_employee_id);
                
            WHEN 'INSERT_EMP' THEN
                v_sql_stmt := 'INSERT INTO auca_employee_data (employee_id, employee_name, salary, department, last_updated) ' ||
                             'VALUES (:1, :2, :3, :4, SYSDATE)';
                -- Example values - in real scenario, these would be parameters
                EXECUTE IMMEDIATE v_sql_stmt USING 100, 'Test Employee', 50000, 'HR';
                DBMS_OUTPUT.PUT_LINE('New employee inserted');
                
            WHEN 'REPORT' THEN
                v_sql_stmt := 'SELECT employee_id, employee_name, salary, department FROM auca_employee_data';
                -- For demonstration - in real scenario, you'd process the results
                DBMS_OUTPUT.PUT_LINE('Employee report generated');
                
            ELSE
                RAISE_APPLICATION_ERROR(-20006, 'Invalid operation type: ' || p_operation_type);
        END CASE;
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20007, 'Dynamic operation failed: ' || SQLERRM);
    END dynamic_hr_operation;
    
    -- PROCEDURE: Bulk update salaries by department (Optional Challenge)
    PROCEDURE update_department_salaries(
        p_department IN VARCHAR2,
        p_percentage_raise IN NUMBER
    ) 
    IS
        CURSOR dept_emp_cursor IS
            SELECT employee_id, salary 
            FROM auca_employee_data 
            WHERE department = p_department
            FOR UPDATE;
            
        v_new_salary NUMBER;
        v_updated_count NUMBER := 0;
    BEGIN
        FOR emp_rec IN dept_emp_cursor LOOP
            -- Calculate new salary with raise
            v_new_salary := emp_rec.salary * (1 + p_percentage_raise/100);
            
            -- Update employee salary
            UPDATE auca_employee_data 
            SET salary = v_new_salary, 
                last_updated = SYSDATE
            WHERE employee_id = emp_rec.employee_id;
            
            v_updated_count := v_updated_count + 1;
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('Updated ' || v_updated_count || ' employees in department: ' || p_department);
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20008, 'Bulk update failed: ' || SQLERRM);
    END update_department_salaries;
    
END auca_hr_package;
/
