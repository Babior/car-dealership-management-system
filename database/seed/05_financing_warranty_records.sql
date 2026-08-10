USE car_dealership_db;

START TRANSACTION;

-- =====================================================
-- 1. LOANS: 10 RECORDS
-- One loan per sale because sale_id is UNIQUE in loan.
-- =====================================================

INSERT INTO loan
(
    loan_id,
    sale_id,
    lender_name,
    principal_amount,
    interest_rate,
    term_months,
    start_date,
    end_date,
    loan_status
)
VALUES
(1, 11, 'GCB Bank PLC',             180000.00, 10.00, 4, '2025-11-10', '2026-03-10', 'Completed'),
(2, 12, 'Ecobank Ghana PLC',        130000.00,  9.50, 4, '2025-12-05', '2026-04-05', 'Completed'),
(3, 13, 'Absa Bank Ghana Limited',  200000.00, 11.00, 5, '2026-01-20', '2026-06-20', 'Completed'),
(4, 14, 'Stanbic Bank Ghana',       180000.00, 12.00, 5, '2026-02-15', '2026-07-15', 'Active'),
(5, 15, 'Fidelity Bank Ghana',      280000.00, 12.00, 5, '2026-03-10', '2026-08-10', 'Active'),
(6, 16, 'Republic Bank Ghana',      260000.00, 10.50, 5, '2026-04-15', '2026-09-15', 'Active'),
(7, 17, 'CalBank PLC',              240000.00, 10.00, 5, '2026-05-25', '2026-10-25', 'Active'),
(8, 18, 'Access Bank Ghana',        270000.00, 11.50, 5, '2026-06-20', '2026-11-20', 'Active'),
(9, 19, 'First Atlantic Bank',      300000.00, 12.00, 5, '2026-07-10', '2026-12-10', 'Pending'),
(10, 20, 'Prudential Bank Limited', 190000.00, 11.00, 5, '2026-07-20', '2026-12-20', 'Pending');


-- =====================================================
-- 2. LOAN INSTALLMENTS: 48 RECORDS
-- Loans 1-2 have 4 installments each.
-- Loans 3-10 have 5 installments each.
-- Total: 8 + 40 = 48.
-- =====================================================

INSERT INTO loan_installment
(
    loan_id,
    installment_number,
    due_date,
    amount_due,
    amount_paid,
    payment_date,
    installment_status
)
VALUES
-- Loan 1: completed
(1, 1, '2025-12-10', 49500.00, 49500.00, '2025-12-09', 'Paid'),
(1, 2, '2026-01-10', 49500.00, 49500.00, '2026-01-10', 'Paid'),
(1, 3, '2026-02-10', 49500.00, 49500.00, '2026-02-08', 'Paid'),
(1, 4, '2026-03-10', 49500.00, 49500.00, '2026-03-10', 'Paid'),

-- Loan 2: completed
(2, 1, '2026-01-05', 35587.50, 35587.50, '2026-01-05', 'Paid'),
(2, 2, '2026-02-05', 35587.50, 35587.50, '2026-02-04', 'Paid'),
(2, 3, '2026-03-05', 35587.50, 35587.50, '2026-03-05', 'Paid'),
(2, 4, '2026-04-05', 35587.50, 35587.50, '2026-04-03', 'Paid'),

-- Loan 3: completed
(3, 1, '2026-02-20', 44400.00, 44400.00, '2026-02-20', 'Paid'),
(3, 2, '2026-03-20', 44400.00, 44400.00, '2026-03-19', 'Paid'),
(3, 3, '2026-04-20', 44400.00, 44400.00, '2026-04-20', 'Paid'),
(3, 4, '2026-05-20', 44400.00, 44400.00, '2026-05-18', 'Paid'),
(3, 5, '2026-06-20', 44400.00, 44400.00, '2026-06-20', 'Paid'),

-- Loan 4: active
(4, 1, '2026-03-15', 40320.00, 40320.00, '2026-03-15', 'Paid'),
(4, 2, '2026-04-15', 40320.00, 40320.00, '2026-04-14', 'Paid'),
(4, 3, '2026-05-15', 40320.00, 40320.00, '2026-05-15', 'Paid'),
(4, 4, '2026-06-15', 40320.00, 20000.00, '2026-06-15', 'Partially Paid'),
(4, 5, '2026-07-15', 40320.00,     0.00, NULL,         'Overdue'),

-- Loan 5: active
(5, 1, '2026-04-10', 62720.00, 62720.00, '2026-04-10', 'Paid'),
(5, 2, '2026-05-10', 62720.00, 62720.00, '2026-05-09', 'Paid'),
(5, 3, '2026-06-10', 62720.00, 30000.00, '2026-06-10', 'Partially Paid'),
(5, 4, '2026-07-10', 62720.00,     0.00, NULL,         'Overdue'),
(5, 5, '2026-08-10', 62720.00,     0.00, NULL,         'Pending'),

-- Loan 6: active
(6, 1, '2026-05-15', 57460.00, 57460.00, '2026-05-15', 'Paid'),
(6, 2, '2026-06-15', 57460.00, 57460.00, '2026-06-14', 'Paid'),
(6, 3, '2026-07-15', 57460.00,     0.00, NULL,         'Overdue'),
(6, 4, '2026-08-15', 57460.00,     0.00, NULL,         'Pending'),
(6, 5, '2026-09-15', 57460.00,     0.00, NULL,         'Pending'),

-- Loan 7: active
(7, 1, '2026-06-25', 52800.00, 52800.00, '2026-06-25', 'Paid'),
(7, 2, '2026-07-25', 52800.00,     0.00, NULL,         'Overdue'),
(7, 3, '2026-08-25', 52800.00,     0.00, NULL,         'Pending'),
(7, 4, '2026-09-25', 52800.00,     0.00, NULL,         'Pending'),
(7, 5, '2026-10-25', 52800.00,     0.00, NULL,         'Pending'),

-- Loan 8: active
(8, 1, '2026-07-20', 60210.00, 60210.00, '2026-07-20', 'Paid'),
(8, 2, '2026-08-20', 60210.00,     0.00, NULL,         'Pending'),
(8, 3, '2026-09-20', 60210.00,     0.00, NULL,         'Pending'),
(8, 4, '2026-10-20', 60210.00,     0.00, NULL,         'Pending'),
(8, 5, '2026-11-20', 60210.00,     0.00, NULL,         'Pending'),

-- Loan 9: pending
(9, 1, '2026-08-10', 67200.00, 0.00, NULL, 'Pending'),
(9, 2, '2026-09-10', 67200.00, 0.00, NULL, 'Pending'),
(9, 3, '2026-10-10', 67200.00, 0.00, NULL, 'Pending'),
(9, 4, '2026-11-10', 67200.00, 0.00, NULL, 'Pending'),
(9, 5, '2026-12-10', 67200.00, 0.00, NULL, 'Pending'),

-- Loan 10: pending
(10, 1, '2026-08-20', 42180.00, 0.00, NULL, 'Pending'),
(10, 2, '2026-09-20', 42180.00, 0.00, NULL, 'Pending'),
(10, 3, '2026-10-20', 42180.00, 0.00, NULL, 'Pending'),
(10, 4, '2026-11-20', 42180.00, 0.00, NULL, 'Pending'),
(10, 5, '2026-12-20', 42180.00, 0.00, NULL, 'Pending');


-- =====================================================
-- 3. WARRANTIES: 15 RECORDS
-- =====================================================

INSERT INTO warranty
(
    warranty_id,
    vehicle_id,
    provider_name,
    provider_phone,
    start_date,
    end_date,
    coverage_description,
    warranty_status
)
VALUES
(1, 1, 'Toyota Ghana Limited',      '0302220011', '2025-01-18', '2028-01-18', 'Engine, transmission and manufacturer defects', 'Active'),
(2, 2, 'Toyota Ghana Limited',      '0302220011', '2025-02-07', '2028-02-07', 'Powertrain and electrical system coverage', 'Active'),
(3, 3, 'Toyota Ghana Limited',      '0302220011', '2025-03-12', '2028-03-12', 'Engine, transmission and drivetrain coverage', 'Active'),
(4, 4, 'Toyota Ghana Limited',      '0302220011', '2025-04-04', '2028-04-04', 'Manufacturer defects and electrical components', 'Active'),
(5, 5, 'Toyota Ghana Limited',      '0302220011', '2025-05-16', '2028-05-16', 'Powertrain, suspension and electrical coverage', 'Active'),
(6, 6, 'Honda Ghana Limited',       '0302230012', '2025-06-01', '2028-06-01', 'Engine and transmission coverage', 'Active'),
(7, 7, 'Honda Ghana Limited',       '0302230012', '2025-06-09', '2028-06-09', 'Manufacturer defects and drivetrain coverage', 'Active'),
(8, 8, 'Honda Ghana Limited',       '0302230012', '2025-07-21', '2028-07-21', 'Powertrain and electrical system coverage', 'Active'),
(9, 9, 'Nissan Ghana Limited',      '0302240013', '2025-08-14', '2028-08-14', 'Engine, gearbox and electrical components', 'Active'),
(10, 10, 'Nissan Ghana Limited',    '0302240013', '2025-09-05', '2028-09-05', 'Manufacturer defects and powertrain coverage', 'Active'),
(11, 11, 'Ford Ghana Limited',      '0302250014', '2025-10-17', '2028-10-17', 'Engine, transmission and suspension coverage', 'Active'),
(12, 12, 'Ford Ghana Limited',      '0302250014', '2025-11-08', '2028-11-08', 'Drivetrain and electrical component coverage', 'Active'),
(13, 13, 'BMW Ghana Limited',       '0302260015', '2025-12-03', '2028-12-03', 'Powertrain and electronic systems coverage', 'Active'),
(14, 14, 'BMW Ghana Limited',       '0302260015', '2026-01-05', '2029-01-05', 'Engine, transmission and electronic systems', 'Active'),
(15, 15, 'Mercedes-Benz Ghana Ltd', '0302270016', '2026-01-15', '2029-01-15', 'Powertrain, safety and electronic systems', 'Active');


-- =====================================================
-- 4. WARRANTY CLAIMS: 10 RECORDS
-- Each service order corresponds to the same vehicle as
-- its warranty in these records.
-- =====================================================

INSERT INTO warranty_claim
(
    claim_id,
    warranty_id,
    service_order_id,
    claim_date,
    claim_amount,
    claim_description,
    claim_status,
    decision_date
)
VALUES
(1, 1, 1, '2025-04-12',  3200.00, 'Replacement of a defective engine sensor',       'Paid',     '2025-04-18'),
(2, 2, 2, '2025-05-20',  4800.00, 'Repair of a transmission control component',     'Approved', '2025-05-25'),
(3, 3, 3, '2025-06-15',  2750.00, 'Replacement of a faulty alternator',             'Paid',     '2025-06-21'),
(4, 4, 4, '2025-07-08',  5100.00, 'Repair of an electrical control module',         'Rejected', '2025-07-14'),
(5, 5, 5, '2025-08-19',  3900.00, 'Replacement of a defective suspension part',     'Approved', '2025-08-24'),
(6, 6, 6, '2025-09-11',  2400.00, 'Repair of a manufacturer-related oil leak',      'Paid',     '2025-09-17'),
(7, 7, 7, '2025-10-06',  6200.00, 'Transmission system repair under warranty',      'Approved', '2025-10-12'),
(8, 8, 8, '2025-11-15',  1850.00, 'Replacement of a defective battery controller', 'Rejected', '2025-11-20'),
(9, 9, 9, '2026-01-09',  4500.00, 'Repair of a faulty engine control unit',         'Pending',  NULL),
(10, 10, 10, '2026-02-13', 3350.00, 'Replacement of a defective fuel pump',         'Pending',  NULL);

COMMIT;


-- =====================================================
-- VERIFICATION
-- Expected: loan 10, installment 48,
-- warranty 15, warranty_claim 10
-- =====================================================

SELECT 'loan' AS table_name, COUNT(*) AS row_count
FROM loan

UNION ALL

SELECT 'loan_installment', COUNT(*)
FROM loan_installment

UNION ALL

SELECT 'warranty', COUNT(*)
FROM warranty

UNION ALL

SELECT 'warranty_claim', COUNT(*)
FROM warranty_claim;


-- Check every loan and its installment total
SELECT
    l.loan_id,
    l.sale_id,
    l.lender_name,
    l.principal_amount,
    l.loan_status,
    COUNT(li.installment_number) AS installment_count,
    SUM(li.amount_due) AS total_amount_due,
    SUM(li.amount_paid) AS total_amount_paid
FROM loan AS l
LEFT JOIN loan_installment AS li
    ON l.loan_id = li.loan_id
GROUP BY
    l.loan_id,
    l.sale_id,
    l.lender_name,
    l.principal_amount,
    l.loan_status
ORDER BY l.loan_id;