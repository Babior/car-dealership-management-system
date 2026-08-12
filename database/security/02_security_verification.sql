-- =====================================================
-- CAR DEALERSHIP MANAGEMENT SYSTEM
-- PHASE 7: SECURITY VERIFICATION
-- Owner: Ean
-- DBMS: MySQL 8.0+
-- =====================================================

USE car_dealership_db;

-- =====================================================
-- TEST 01: CONFIRM THAT ALL SEVEN ROLES EXIST
-- Expected: 7 rows
-- =====================================================

SELECT
    user AS role_name,
    host,
    account_locked
FROM mysql.user
WHERE user IN (
    'dealership_admin',
    'dealership_manager',
    'dealership_salesperson',
    'dealership_finance',
    'dealership_inventory',
    'dealership_service_advisor',
    'dealership_mechanic'
)
ORDER BY user;

-- =====================================================
-- TEST 02: DISPLAY GRANTS FOR EACH ROLE
-- Expected: Grants created in 01_roles_privileges.sql
-- =====================================================

SHOW GRANTS FOR 'dealership_admin';
SHOW GRANTS FOR 'dealership_manager';
SHOW GRANTS FOR 'dealership_salesperson';
SHOW GRANTS FOR 'dealership_finance';
SHOW GRANTS FOR 'dealership_inventory';
SHOW GRANTS FOR 'dealership_service_advisor';
SHOW GRANTS FOR 'dealership_mechanic';

-- =====================================================
-- TEST 03: DISPLAY ALL TABLE-LEVEL PRIVILEGES
-- Expected: Only privileges approved in the matrix
-- =====================================================

SELECT
    GRANTEE,
    TABLE_NAME,
    PRIVILEGE_TYPE
FROM information_schema.TABLE_PRIVILEGES
WHERE TABLE_SCHEMA = 'car_dealership_db'
  AND GRANTEE LIKE '%dealership_%'
ORDER BY GRANTEE, TABLE_NAME, PRIVILEGE_TYPE;

-- =====================================================
-- TEST 04: DISPLAY COLUMN-LEVEL PRIVILEGES
-- Expected:
-- Admin restricted SELECT on user_account
-- Service Advisor restricted employee SELECT
-- Mechanic restricted employee/customer SELECT
-- Mechanic restricted service_order UPDATE
-- =====================================================

SELECT
    GRANTEE,
    TABLE_NAME,
    COLUMN_NAME,
    PRIVILEGE_TYPE
FROM information_schema.COLUMN_PRIVILEGES
WHERE TABLE_SCHEMA = 'car_dealership_db'
  AND GRANTEE LIKE '%dealership_%'
ORDER BY GRANTEE, TABLE_NAME, COLUMN_NAME, PRIVILEGE_TYPE;

-- =====================================================
-- TEST 05: SALESPERSON AUTHORIZED ACCESS
-- Salesperson must be able to read vehicle information.
-- Expected: PASS
-- =====================================================

SELECT
    'Salesperson can read vehicles' AS security_test,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_salesperson''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'vehicle'
              AND PRIVILEGE_TYPE = 'SELECT'
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result;

-- =====================================================
-- TEST 06: SALESPERSON UNAUTHORIZED ACCESS
-- Salesperson must not update employee administration.
-- Expected: PASS, meaning UPDATE privilege is absent.
-- =====================================================

SELECT
    'Salesperson cannot update employees' AS security_test,
    CASE
        WHEN NOT EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_salesperson''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'employee'
              AND PRIVILEGE_TYPE = 'UPDATE'
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result;

-- =====================================================
-- TEST 07: FINANCE AUTHORIZED ACCESS
-- Finance must be able to manage loans.
-- Expected: PASS
-- =====================================================

SELECT
    'Finance can manage loans' AS security_test,
    CASE
        WHEN (
            SELECT COUNT(DISTINCT PRIVILEGE_TYPE)
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_finance''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'loan'
              AND PRIVILEGE_TYPE IN ('SELECT', 'INSERT', 'UPDATE')
        ) = 3
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result;

-- =====================================================
-- TEST 08: FINANCE UNAUTHORIZED ACCESS
-- Finance must not update vehicle inventory.
-- Expected: PASS, meaning UPDATE privilege is absent.
-- =====================================================

SELECT
    'Finance cannot update vehicle inventory' AS security_test,
    CASE
        WHEN NOT EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_finance''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'vehicle'
              AND PRIVILEGE_TYPE = 'UPDATE'
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result;

-- =====================================================
-- TEST 09: INVENTORY AUTHORIZED ACCESS
-- Inventory must be able to manage vehicles.
-- Expected: PASS
-- =====================================================

SELECT
    'Inventory can manage vehicles' AS security_test,
    CASE
        WHEN (
            SELECT COUNT(DISTINCT PRIVILEGE_TYPE)
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_inventory''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'vehicle'
              AND PRIVILEGE_TYPE IN ('SELECT', 'INSERT', 'UPDATE')
        ) = 3
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result;

-- =====================================================
-- TEST 10: INVENTORY UNAUTHORIZED ACCESS
-- Inventory must not modify sales or payments.
-- Expected: PASS
-- =====================================================

SELECT
    'Inventory cannot modify sales or payments' AS security_test,
    CASE
        WHEN NOT EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_inventory''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME IN ('sale', 'sale_item', 'payment')
              AND PRIVILEGE_TYPE IN ('INSERT', 'UPDATE', 'DELETE')
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result;

-- =====================================================
-- TEST 11: MECHANIC AUTHORIZED COLUMN UPDATE
-- Mechanic may update only approved service-order fields.
-- Expected: PASS
-- =====================================================

SELECT
    'Mechanic has limited service update access' AS security_test,
    CASE
        WHEN (
            SELECT COUNT(DISTINCT COLUMN_NAME)
            FROM information_schema.COLUMN_PRIVILEGES
            WHERE GRANTEE = '''dealership_mechanic''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'service_order'
              AND PRIVILEGE_TYPE = 'UPDATE'
              AND COLUMN_NAME IN (
                  'service_status',
                  'service_description',
                  'current_mileage'
              )
        ) = 3
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result;

-- =====================================================
-- TEST 12: MECHANIC UNAUTHORIZED FINANCE ACCESS
-- Mechanic must not access loans or payments.
-- Expected: PASS
-- =====================================================

SELECT
    'Mechanic cannot access loans or payments' AS security_test,
    CASE
        WHEN NOT EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_mechanic''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME IN ('loan', 'loan_installment', 'payment')
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result;

-- =====================================================
-- TEST 13: MANAGER REPORTING ACCESS
-- Manager has database-level SELECT for reporting.
-- Expected: PASS
-- =====================================================

SELECT
    'Manager has read-only reporting access' AS security_test,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM information_schema.SCHEMA_PRIVILEGES
            WHERE GRANTEE = '''dealership_manager''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND PRIVILEGE_TYPE = 'SELECT'
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result;

-- =====================================================
-- TEST 14: PASSWORD HASH PROTECTION
-- Administrator must not receive password_hash through SELECT.
-- Expected: PASS
-- =====================================================

SELECT
    'Password hash is excluded from administrator SELECT' AS security_test,
    CASE
        WHEN NOT EXISTS (
            SELECT 1
            FROM information_schema.COLUMN_PRIVILEGES
            WHERE GRANTEE = '''dealership_admin''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'user_account'
              AND COLUMN_NAME = 'password_hash'
              AND PRIVILEGE_TYPE = 'SELECT'
        )
        AND NOT EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_admin''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'user_account'
              AND PRIVILEGE_TYPE = 'SELECT'
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result;

-- =====================================================
-- TEST 15: EMPLOYEE SALARY PROTECTION
-- Service Advisor and Mechanic must not select salary.
-- Expected: PASS
-- =====================================================

SELECT
    'Salary protected from service roles' AS security_test,
    CASE
        WHEN NOT EXISTS (
            SELECT 1
            FROM information_schema.COLUMN_PRIVILEGES
            WHERE GRANTEE IN (
                '''dealership_service_advisor''@''%''',
                '''dealership_mechanic''@''%'''
            )
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'employee'
              AND COLUMN_NAME = 'salary'
              AND PRIVILEGE_TYPE = 'SELECT'
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result;

-- =====================================================
-- TEST 16: TRANSACTION HISTORY PROTECTION
-- No dealership role should have DELETE privileges.
-- Expected: PASS
-- =====================================================

SELECT
    'No operational role has DELETE privilege' AS security_test,
    CASE
        WHEN NOT EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE TABLE_SCHEMA = 'car_dealership_db'
              AND GRANTEE LIKE '%dealership_%'
              AND PRIVILEGE_TYPE = 'DELETE'
        )
        AND NOT EXISTS (
            SELECT 1
            FROM information_schema.SCHEMA_PRIVILEGES
            WHERE TABLE_SCHEMA = 'car_dealership_db'
              AND GRANTEE LIKE '%dealership_%'
              AND PRIVILEGE_TYPE = 'DELETE'
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result;

-- =====================================================
-- END OF SECURITY VERIFICATION
-- All security tests should return PASS.
--
-- Runtime permission-denied tests must be performed using
-- separate MySQL test accounts assigned to individual roles.
-- Do not perform those tests through the root account because
-- root privileges would bypass the role restrictions.
-- =====================================================