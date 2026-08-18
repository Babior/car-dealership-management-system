

USE car_dealership_db;
-- 1. CREATE ROLES

CREATE ROLE IF NOT EXISTS
    'dealership_admin',
    'dealership_manager',
    'dealership_salesperson',
    'dealership_finance',
    'dealership_inventory',
    'dealership_service_advisor',
    'dealership_mechanic';

-- 2. ADMINISTRATOR PRIVILEGES
-- Manages employees, departments, job roles and accounts.
-- Transactional tables are read-only for this role.

GRANT SELECT, INSERT, UPDATE
ON car_dealership_db.department
TO 'dealership_admin';

GRANT SELECT, INSERT, UPDATE
ON car_dealership_db.job_role
TO 'dealership_admin';

GRANT SELECT, INSERT, UPDATE
ON car_dealership_db.employee
TO 'dealership_admin';

GRANT SELECT
ON car_dealership_db.salesperson
TO 'dealership_admin';

GRANT SELECT
ON car_dealership_db.mechanic
TO 'dealership_admin';

-- The administrator can create and update accounts.
GRANT INSERT, UPDATE
ON car_dealership_db.user_account
TO 'dealership_admin';

-- Password hashes are excluded from ordinary SELECT results.
GRANT SELECT (
    user_id,
    employee_id,
    username,
    account_status,
    created_at,
    last_login
)
ON car_dealership_db.user_account
TO 'dealership_admin';

GRANT SELECT
ON car_dealership_db.manufacturer
TO 'dealership_admin';

GRANT SELECT
ON car_dealership_db.vehicle_model
TO 'dealership_admin';

GRANT SELECT
ON car_dealership_db.vehicle
TO 'dealership_admin';

GRANT SELECT
ON car_dealership_db.customer
TO 'dealership_admin';

GRANT SELECT
ON car_dealership_db.sale
TO 'dealership_admin';

GRANT SELECT
ON car_dealership_db.sale_item
TO 'dealership_admin';

GRANT SELECT
ON car_dealership_db.payment
TO 'dealership_admin';

GRANT SELECT
ON car_dealership_db.loan
TO 'dealership_admin';

GRANT SELECT
ON car_dealership_db.loan_installment
TO 'dealership_admin';

GRANT SELECT
ON car_dealership_db.service_order
TO 'dealership_admin';

GRANT SELECT
ON car_dealership_db.part
TO 'dealership_admin';

GRANT SELECT
ON car_dealership_db.service_part
TO 'dealership_admin';

GRANT SELECT
ON car_dealership_db.warranty
TO 'dealership_admin';

GRANT SELECT
ON car_dealership_db.warranty_claim
TO 'dealership_admin';


-- 6. INVENTORY OFFICER PRIVILEGES

GRANT SELECT, INSERT, UPDATE
ON car_dealership_db.manufacturer
TO 'dealership_inventory';

GRANT SELECT, INSERT, UPDATE
ON car_dealership_db.vehicle_model
TO 'dealership_inventory';

GRANT SELECT, INSERT, UPDATE
ON car_dealership_db.vehicle
TO 'dealership_inventory';

GRANT SELECT, INSERT, UPDATE
ON car_dealership_db.part
TO 'dealership_inventory';

GRANT SELECT
ON car_dealership_db.service_order
TO 'dealership_inventory';

GRANT SELECT
ON car_dealership_db.service_part
TO 'dealership_inventory';

-- 7. SERVICE ADVISOR PRIVILEGES

GRANT SELECT
ON car_dealership_db.manufacturer
TO 'dealership_service_advisor';

GRANT SELECT
ON car_dealership_db.vehicle_model
TO 'dealership_service_advisor';

GRANT SELECT
ON car_dealership_db.vehicle
TO 'dealership_service_advisor';

-- Salary is deliberately excluded.
GRANT SELECT (
    employee_id,
    department_id,
    job_role_id,
    first_name,
    last_name,
    phone,
    email,
    hire_date,
    employee_status
)
ON car_dealership_db.employee
TO 'dealership_service_advisor';

GRANT SELECT
ON car_dealership_db.mechanic
TO 'dealership_service_advisor';

GRANT SELECT
ON car_dealership_db.customer
TO 'dealership_service_advisor';

GRANT SELECT
ON car_dealership_db.sale
TO 'dealership_service_advisor';

GRANT SELECT
ON car_dealership_db.sale_item
TO 'dealership_service_advisor';

GRANT SELECT, INSERT, UPDATE
ON car_dealership_db.service_order
TO 'dealership_service_advisor';

GRANT SELECT
ON car_dealership_db.part
TO 'dealership_service_advisor';

GRANT SELECT, INSERT, UPDATE
ON car_dealership_db.service_part
TO 'dealership_service_advisor';

GRANT SELECT, INSERT, UPDATE
ON car_dealership_db.warranty
TO 'dealership_service_advisor';

GRANT SELECT, INSERT, UPDATE
ON car_dealership_db.warranty_claim
TO 'dealership_service_advisor';

-- 8. MECHANIC PRIVILEGES

GRANT SELECT
ON car_dealership_db.vehicle
TO 'dealership_mechanic';

-- Salary and unrelated employee information are excluded.
GRANT SELECT (
    employee_id,
    first_name,
    last_name,
    phone,
    employee_status
)
ON car_dealership_db.employee
TO 'dealership_mechanic';

GRANT SELECT
ON car_dealership_db.mechanic
TO 'dealership_mechanic';

-- Only basic customer contact details are available.
GRANT SELECT (
    customer_id,
    first_name,
    last_name,
    phone
)
ON car_dealership_db.customer
TO 'dealership_mechanic';

GRANT SELECT
ON car_dealership_db.service_order
TO 'dealership_mechanic';

-- Mechanics may update only operational service fields.
GRANT UPDATE (
    service_status,
    service_description,
    current_mileage
)
ON car_dealership_db.service_order
TO 'dealership_mechanic';

GRANT SELECT
ON car_dealership_db.part
TO 'dealership_mechanic';

GRANT SELECT
ON car_dealership_db.service_part
TO 'dealership_mechanic';

GRANT SELECT
ON car_dealership_db.warranty
TO 'dealership_mechanic';

GRANT SELECT
ON car_dealership_db.warranty_claim
TO 'dealership_mechanic';

-- 9. DISPLAY ROLE GRANTS

SHOW GRANTS FOR 'dealership_admin';
SHOW GRANTS FOR 'dealership_manager';
SHOW GRANTS FOR 'dealership_salesperson';
SHOW GRANTS FOR 'dealership_finance';
SHOW GRANTS FOR 'dealership_inventory';
SHOW GRANTS FOR 'dealership_service_advisor';
SHOW GRANTS FOR 'dealership_mechanic';
