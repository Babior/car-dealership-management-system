# CAR DEALERSHIP MANAGEMENT SYSTEM
# PHASE 7 - DATABASE SECURITY VERIFICATION
# JAMAL: SALESPERSON, FINANCE OFFICER AND MANAGER
#
# Purpose:
# Verifies that each role has the privileges required for its job
# and does not have unauthorized privileges.
#
# IMPORTANT:
# Expected-failure statements should be executed individually
# while connected as a test user assigned to the relevant role.


USE car_dealership_db;


# ============================================================
# SECTION 1: REVIEW ROLE GRANTS
# ============================================================

SHOW GRANTS FOR 'dealership_salesperson';
SHOW GRANTS FOR 'dealership_finance';
SHOW GRANTS FOR 'dealership_manager';


# ============================================================
# SECTION 2: SALESPERSON VERIFICATION
# ============================================================

# ------------------------------------------------------------
# EXPECTED TO SUCCEED
# ------------------------------------------------------------

# Read vehicle inventory
SELECT vehicle_id, vin, selling_price, vehicle_status
FROM vehicle
LIMIT 5;

# Read customers
SELECT customer_id, first_name, last_name, phone
FROM customer
LIMIT 5;

# Read sales
SELECT sale_id, customer_id, salesperson_id,
       sale_date, total_amount, sale_status
FROM sale
LIMIT 5;

# Read payment information
SELECT payment_id, sale_id, amount,
       payment_method, payment_status
FROM payment
LIMIT 5;


# ------------------------------------------------------------
# EXPECTED TO FAIL FOR SALESPERSON
# Run these individually as the Salesperson test user.
# ------------------------------------------------------------

# Must not access employee administration
SELECT salary
FROM employee
LIMIT 1;

# Must not administer user accounts
SELECT *
FROM user_account
LIMIT 1;

# Must not create loans
# Use a valid sale_id only during controlled testing.
#
# INSERT INTO loan (
#     sale_id,
#     lender_name,
#     principal_amount,
#     interest_rate,
#     term_months,
#     start_date,
#     end_date,
#     loan_status
# )
# VALUES (
#     <valid_sale_id>,
#     'SECURITY TEST',
#     1000.00,
#     5.00,
#     12,
#     CURDATE(),
#     DATE_ADD(CURDATE(), INTERVAL 12 MONTH),
#     'Pending'
# );

# Must not modify warranty claims
# UPDATE warranty_claim
# SET claim_status = 'Approved'
# WHERE claim_id = <valid_claim_id>;


# ============================================================
# SECTION 3: FINANCE OFFICER VERIFICATION
# ============================================================

# ------------------------------------------------------------
# EXPECTED TO SUCCEED
# ------------------------------------------------------------

# Read sales
SELECT sale_id, customer_id, total_amount, payment_status
FROM sale
LIMIT 5;

# Read payments
SELECT payment_id, sale_id, amount,
       payment_method, payment_status
FROM payment
LIMIT 5;

# Read loans
SELECT loan_id, sale_id, principal_amount,
       interest_rate, loan_status
FROM loan
LIMIT 5;

# Read loan installments
SELECT loan_id, installment_number,
       due_date, amount_due,
       amount_paid, installment_status
FROM loan_installment
LIMIT 5;


# ------------------------------------------------------------
# EXPECTED TO FAIL FOR FINANCE OFFICER
# Run these individually as the Finance test user.
# ------------------------------------------------------------

# Must not modify vehicle inventory
# UPDATE vehicle
# SET selling_price = selling_price + 1
# WHERE vehicle_id = <valid_vehicle_id>;

# Must not modify parts
# UPDATE part
# SET quantity_in_stock = quantity_in_stock + 1
# WHERE part_id = <valid_part_id>;

# Must not administer accounts
SELECT *
FROM user_account
LIMIT 1;

# Must not modify service records
# UPDATE service_order
# SET service_status = 'Completed'
# WHERE service_order_id = <valid_service_order_id>;


# ============================================================
# SECTION 4: MANAGER VERIFICATION
# ============================================================

# ------------------------------------------------------------
# EXPECTED TO SUCCEED
# ------------------------------------------------------------

# Read vehicle information
SELECT vehicle_id, vin, selling_price, vehicle_status
FROM vehicle
LIMIT 5;

# Read customer information
SELECT customer_id, first_name, last_name
FROM customer
LIMIT 5;

# Read sales information
SELECT sale_id, sale_date, total_amount,
       sale_status, payment_status
FROM sale
LIMIT 5;

# Read payment information
SELECT payment_id, sale_id, amount, payment_status
FROM payment
LIMIT 5;

# Read financing information
SELECT loan_id, sale_id, principal_amount, loan_status
FROM loan
LIMIT 5;

# Read service information
SELECT service_order_id, vehicle_id,
       mechanic_id, service_status
FROM service_order
LIMIT 5;

# Read warranty information
SELECT warranty_id, vehicle_id, warranty_status
FROM warranty
LIMIT 5;


# Manager may read approved Employee columns.
SELECT employee_id,
       department_id,
       job_role_id,
       first_name,
       last_name,
       phone,
       email,
       hire_date,
       employee_status
FROM employee
LIMIT 5;


# ------------------------------------------------------------
# EXPECTED TO FAIL FOR MANAGER
# ------------------------------------------------------------

# Salary was deliberately excluded from the Manager's
# column-level Employee SELECT permission.
SELECT salary
FROM employee
LIMIT 1;

# Manager must not administer application accounts.
SELECT *
FROM user_account
LIMIT 1;

# Manager must not perform unrestricted transaction changes.
#
# UPDATE payment
# SET amount = amount + 1
# WHERE payment_id = <valid_payment_id>;


# ============================================================
# SECTION 5: VERIFICATION RECORD
# ============================================================

# Record actual results separately during testing:
#
# Role                    Test                         Expected
# -------------------------------------------------------------
# Salesperson             SELECT vehicle              PASS
# Salesperson             SELECT customer             PASS
# Salesperson             SELECT payment              PASS
# Salesperson             SELECT employee.salary      DENIED
# Salesperson             SELECT user_account         DENIED
# Salesperson             INSERT loan                 DENIED
#
# Finance Officer         SELECT payment              PASS
# Finance Officer         SELECT loan                 PASS
# Finance Officer         SELECT loan_installment     PASS
# Finance Officer         UPDATE vehicle              DENIED
# Finance Officer         SELECT user_account         DENIED
#
# Manager                 SELECT operational data     PASS
# Manager                 SELECT employee columns     PASS
# Manager                 SELECT employee.salary      DENIED
# Manager                 SELECT user_account         DENIED
# Manager                 UPDATE payment              DENIED
#
# Final PASS requires:
# 1. Every authorized operation succeeds.
# 2. Every unauthorized operation is rejected by MySQL.