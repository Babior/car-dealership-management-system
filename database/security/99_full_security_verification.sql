-- =====================================================
-- CAR DEALERSHIP MANAGEMENT SYSTEM
-- PHASE 7 - FINAL INTEGRATED SECURITY VERIFICATION
-- =====================================================

USE car_dealership_db;

-- =====================================================
-- TEST 1: ALL SEVEN ROLES EXIST
-- =====================================================

SELECT
    'All seven dealership roles exist' AS security_test,
    CASE
        WHEN (
            SELECT COUNT(*)
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
        ) = 7
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result

UNION ALL

-- =====================================================
-- TEST 2: NO DATABASE-WIDE PRIVILEGES
-- =====================================================

SELECT
    'No dealership role has schema-wide privileges',
    CASE
        WHEN NOT EXISTS (
            SELECT 1
            FROM information_schema.SCHEMA_PRIVILEGES
            WHERE TABLE_SCHEMA = 'car_dealership_db'
              AND GRANTEE IN (
                '''dealership_admin''@''%''',
                '''dealership_manager''@''%''',
                '''dealership_salesperson''@''%''',
                '''dealership_finance''@''%''',
                '''dealership_inventory''@''%''',
                '''dealership_service_advisor''@''%''',
                '''dealership_mechanic''@''%'''
              )
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

-- =====================================================
-- TEST 3: SALESPERSON AUTHORIZED ACCESS
-- =====================================================

SELECT
    'Salesperson can process sales and customers',
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_salesperson''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'sale'
              AND PRIVILEGE_TYPE = 'INSERT'
        )
        AND EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_salesperson''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'customer'
              AND PRIVILEGE_TYPE = 'UPDATE'
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

-- =====================================================
-- TEST 4: SALESPERSON RESTRICTED ACCESS
-- =====================================================

SELECT
    'Salesperson cannot access employee accounts or loans',
    CASE
        WHEN NOT EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_salesperson''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME IN ('employee', 'user_account', 'loan', 'loan_installment')
        )
        AND NOT EXISTS (
            SELECT 1
            FROM information_schema.COLUMN_PRIVILEGES
            WHERE GRANTEE = '''dealership_salesperson''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME IN ('employee', 'user_account')
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

-- =====================================================
-- TEST 5: FINANCE AUTHORIZED ACCESS
-- =====================================================

SELECT
    'Finance can manage payments and loans',
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_finance''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'payment'
              AND PRIVILEGE_TYPE = 'UPDATE'
        )
        AND EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_finance''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'loan'
              AND PRIVILEGE_TYPE = 'INSERT'
        )
        AND EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_finance''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'loan_installment'
              AND PRIVILEGE_TYPE = 'UPDATE'
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

-- =====================================================
-- TEST 6: FINANCE RESTRICTED ACCESS
-- =====================================================

SELECT
    'Finance cannot modify inventory or administer accounts',
    CASE
        WHEN NOT EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_finance''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME IN ('vehicle', 'part', 'user_account')
              AND PRIVILEGE_TYPE IN ('INSERT', 'UPDATE', 'DELETE')
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

-- =====================================================
-- TEST 7: INVENTORY AUTHORIZED ACCESS
-- =====================================================

SELECT
    'Inventory can manage vehicles and parts',
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_inventory''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'vehicle'
              AND PRIVILEGE_TYPE = 'UPDATE'
        )
        AND EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_inventory''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'part'
              AND PRIVILEGE_TYPE = 'INSERT'
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

-- =====================================================
-- TEST 8: INVENTORY RESTRICTED ACCESS
-- =====================================================

SELECT
    'Inventory cannot modify sales or payments',
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
    END

UNION ALL

-- =====================================================
-- TEST 9: SERVICE ADVISOR ACCESS
-- =====================================================

SELECT
    'Service Advisor can manage service and warranty records',
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_service_advisor''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'service_order'
              AND PRIVILEGE_TYPE = 'UPDATE'
        )
        AND EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_service_advisor''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'warranty_claim'
              AND PRIVILEGE_TYPE = 'INSERT'
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

-- =====================================================
-- TEST 10: MECHANIC LIMITED UPDATE
-- =====================================================

SELECT
    'Mechanic has only approved service-order update columns',
    CASE
        WHEN (
            SELECT COUNT(*)
            FROM information_schema.COLUMN_PRIVILEGES
            WHERE GRANTEE = '''dealership_mechanic''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'service_order'
              AND PRIVILEGE_TYPE = 'UPDATE'
              AND COLUMN_NAME IN (
                  'current_mileage',
                  'service_description',
                  'service_status'
              )
        ) = 3
        AND NOT EXISTS (
            SELECT 1
            FROM information_schema.COLUMN_PRIVILEGES
            WHERE GRANTEE = '''dealership_mechanic''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'service_order'
              AND PRIVILEGE_TYPE = 'UPDATE'
              AND COLUMN_NAME NOT IN (
                  'current_mileage',
                  'service_description',
                  'service_status'
              )
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

-- =====================================================
-- TEST 11: MECHANIC FINANCIAL RESTRICTION
-- =====================================================

SELECT
    'Mechanic cannot access payments or loans',
    CASE
        WHEN NOT EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_mechanic''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME IN ('payment', 'loan', 'loan_installment')
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

-- =====================================================
-- TEST 12: MANAGER READ-ONLY ACCESS
-- =====================================================

SELECT
    'Manager has read-only operational access',
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_manager''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'sale'
              AND PRIVILEGE_TYPE = 'SELECT'
        )
        AND EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_manager''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'payment'
              AND PRIVILEGE_TYPE = 'SELECT'
        )
        AND EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_manager''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'loan'
              AND PRIVILEGE_TYPE = 'SELECT'
        )
        AND EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_manager''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'service_order'
              AND PRIVILEGE_TYPE = 'SELECT'
        )
        AND NOT EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_manager''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND PRIVILEGE_TYPE IN ('INSERT', 'UPDATE', 'DELETE')
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

-- =====================================================
-- TEST 13: MANAGER SENSITIVE DATA RESTRICTION
-- =====================================================

SELECT
    'Manager cannot read salary or user-account data',
    CASE
        WHEN NOT EXISTS (
            SELECT 1
            FROM information_schema.COLUMN_PRIVILEGES
            WHERE GRANTEE = '''dealership_manager''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'employee'
              AND COLUMN_NAME = 'salary'
        )
        AND NOT EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE GRANTEE = '''dealership_manager''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'user_account'
        )
        AND NOT EXISTS (
            SELECT 1
            FROM information_schema.COLUMN_PRIVILEGES
            WHERE GRANTEE = '''dealership_manager''@''%'''
              AND TABLE_SCHEMA = 'car_dealership_db'
              AND TABLE_NAME = 'user_account'
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

-- =====================================================
-- TEST 14: ADMIN PASSWORD HASH PROTECTION
-- =====================================================

SELECT
    'Administrator SELECT excludes password_hash',
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
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

-- =====================================================
-- TEST 15: NO DELETE PRIVILEGES
-- =====================================================

SELECT
    'No dealership role has DELETE privilege',
    CASE
        WHEN NOT EXISTS (
            SELECT 1
            FROM information_schema.TABLE_PRIVILEGES
            WHERE TABLE_SCHEMA = 'car_dealership_db'
              AND GRANTEE LIKE '%dealership_%'
              AND PRIVILEGE_TYPE = 'DELETE'
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END;
