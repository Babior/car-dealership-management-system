USE car_dealership_db;


-- PHASE 5: CHARLES - SALES AND PAYMENTS

-- 25 sales
-- 25 sale items
-- 30 payments
--
-- Vehicle IDs used:
-- 1-5, 7-13, 15-21, 23-28
--
-- Vehicle IDs intentionally left outside sales:
-- 6, 14, 22, 29, 30


START TRANSACTION;


-- SALES
-- total_amount = agreed_price - discount_amount + tax_amount
-- Tax used for this sample dataset: approximately 2.5%


INSERT INTO sale
(sale_id, customer_id, salesperson_id, sale_date,
 discount_amount, tax_amount, total_amount,
 commission_rate_applied, sale_status, payment_status)
VALUES
(1, 1, 1, '2025-01-18', 2500.00, 4625.00, 189625.00, 3.00, 'Completed', 'Paid'),
(2, 2, 2, '2025-02-07', 1500.00, 4200.00, 172200.00, 3.00, 'Completed', 'Paid'),
(3, 3, 3, '2025-03-12', 5000.00, 7600.00, 311600.00, 2.75, 'Completed', 'Paid'),
(4, 4, 4, '2025-04-04', 4000.00, 7137.50, 292637.50, 2.75, 'Completed', 'Paid'),
(5, 5, 5, '2025-05-16', 7500.00, 8937.50, 366437.50, 2.50, 'Completed', 'Paid'),
(6, 6, 6, '2025-06-09', 3000.00, 6275.00, 257275.00, 3.50, 'Completed', 'Paid'),

(7, 7, 1, '2025-07-21', 2000.00, 5175.00, 212175.00, 3.00, 'Completed', 'Paid'),
(8, 8, 2, '2025-08-14', 1000.00, 4500.00, 184500.00, 3.00, 'Completed', 'Paid'),
(9, 9, 3, '2025-09-05', 1500.00, 4950.00, 202950.00, 2.75, 'Completed', 'Paid'),
(10, 10, 4, '2025-10-17', 3500.00, 6887.50, 282387.50, 2.75, 'Completed', 'Paid'),
(11, 11, 5, '2025-11-08', 2500.00, 5787.50, 237287.50, 2.50, 'Completed', 'Paid'),
(12, 12, 6, '2025-12-03', 1000.00, 4325.00, 177325.00, 3.50, 'Completed', 'Paid'),

(13, 13, 1, '2026-01-15', 3000.00, 6450.00, 264450.00, 3.00, 'Completed', 'Paid'),

(14, 14, 2, '2026-02-11', 2500.00, 5962.50, 244462.50, 3.00, 'Completed', 'Partially Paid'),
(15, 15, 3, '2026-03-06', 6000.00, 9325.00, 382325.00, 2.75, 'Completed', 'Partially Paid'),
(16, 16, 4, '2026-04-10', 5000.00, 8600.00, 352600.00, 2.75, 'Completed', 'Partially Paid'),
(17, 17, 5, '2026-05-22', 4500.00, 7987.50, 327487.50, 2.50, 'Completed', 'Partially Paid'),
(18, 18, 6, '2026-06-18', 5000.00, 8800.00, 360800.00, 3.50, 'Completed', 'Partially Paid'),

(19, 19, 1, '2026-07-07', 5500.00, 9212.50, 377712.50, 3.00, 'Pending', 'Partially Paid'),
(20, 20, 2, '2026-07-18', 2500.00, 6087.50, 249587.50, 3.00, 'Pending', 'Partially Paid'),
(21, 21, 3, '2026-07-29', 2000.00, 5500.00, 225500.00, 2.75, 'Pending', 'Unpaid'),
(22, 22, 4, '2026-08-01', 2500.00, 6037.50, 247537.50, 2.75, 'Pending', 'Unpaid'),

(23, 23, 5, '2026-08-03', 1500.00, 5137.50, 210637.50, 2.50, 'Cancelled', 'Unpaid'),
(24, 24, 6, '2026-08-05', 2000.00, 6350.00, 260350.00, 3.50, 'Cancelled', 'Unpaid'),
(25, 25, 1, '2026-08-07', 3000.00, 6825.00, 279825.00, 3.00, 'Cancelled', 'Unpaid');


-- SALE ITEMS
-- One physical vehicle per sale in this dataset.
-- vehicle_id remains unique across sale_item.


INSERT INTO sale_item
(sale_id, vehicle_id, agreed_price)
VALUES
(1, 1, 187500.00),
(2, 2, 169500.00),
(3, 3, 309000.00),
(4, 4, 289500.00),
(5, 5, 365000.00),

(6, 7, 254000.00),
(7, 8, 209000.00),
(8, 9, 181000.00),
(9, 10, 199500.00),
(10, 11, 279000.00),
(11, 12, 234000.00),
(12, 13, 174000.00),

(13, 15, 261000.00),
(14, 16, 241000.00),
(15, 17, 379000.00),
(16, 18, 349000.00),
(17, 19, 324000.00),
(18, 20, 357000.00),

(19, 21, 374000.00),
(20, 23, 246000.00),
(21, 24, 222000.00),
(22, 25, 244000.00),

(23, 26, 207000.00),
(24, 27, 256000.00),
(25, 28, 276000.00);


-- PAYMENTS
-- Sales 1-13: fully paid with one confirmed payment.
-- Sales 14-18: three confirmed partial payments each.
-- Sales 19-20: deposits received.
-- Sales 21-25: no payment records.
-- Total payment rows = 30.


INSERT INTO payment
(payment_id, sale_id, payment_date, amount,
 payment_method, reference_number, payment_status)
VALUES
(1, 1, '2025-01-18 11:20:00', 189625.00, 'Transfer', 'PAY-2025-001', 'Confirmed'),
(2, 2, '2025-02-07 14:10:00', 172200.00, 'Card', 'PAY-2025-002', 'Confirmed'),
(3, 3, '2025-03-12 10:45:00', 311600.00, 'Transfer', 'PAY-2025-003', 'Confirmed'),
(4, 4, '2025-04-04 15:30:00', 292637.50, 'Mobile Money', 'PAY-2025-004', 'Confirmed'),
(5, 5, '2025-05-16 12:15:00', 366437.50, 'Transfer', 'PAY-2025-005', 'Confirmed'),
(6, 6, '2025-06-09 09:50:00', 257275.00, 'Card', 'PAY-2025-006', 'Confirmed'),
(7, 7, '2025-07-21 16:05:00', 212175.00, 'Transfer', 'PAY-2025-007', 'Confirmed'),
(8, 8, '2025-08-14 13:40:00', 184500.00, 'Mobile Money', 'PAY-2025-008', 'Confirmed'),
(9, 9, '2025-09-05 11:35:00', 202950.00, 'Card', 'PAY-2025-009', 'Confirmed'),
(10, 10, '2025-10-17 14:25:00', 282387.50, 'Transfer', 'PAY-2025-010', 'Confirmed'),
(11, 11, '2025-11-08 10:15:00', 237287.50, 'Mobile Money', 'PAY-2025-011', 'Confirmed'),
(12, 12, '2025-12-03 15:20:00', 177325.00, 'Card', 'PAY-2025-012', 'Confirmed'),
(13, 13, '2026-01-15 12:05:00', 264450.00, 'Transfer', 'PAY-2026-013', 'Confirmed'),

(14, 14, '2026-02-11 10:30:00', 61115.62, 'Transfer', 'PAY-2026-014', 'Confirmed'),
(15, 14, '2026-02-25 13:15:00', 48892.50, 'Mobile Money', 'PAY-2026-015', 'Confirmed'),
(16, 14, '2026-03-10 09:45:00', 36669.38, 'Transfer', 'PAY-2026-016', 'Confirmed'),

(17, 15, '2026-03-06 11:10:00', 95581.25, 'Transfer', 'PAY-2026-017', 'Confirmed'),
(18, 15, '2026-03-20 14:25:00', 76465.00, 'Card', 'PAY-2026-018', 'Confirmed'),
(19, 15, '2026-04-03 10:00:00', 57348.75, 'Mobile Money', 'PAY-2026-019', 'Confirmed'),

(20, 16, '2026-04-10 12:40:00', 88150.00, 'Transfer', 'PAY-2026-020', 'Confirmed'),
(21, 16, '2026-04-24 15:10:00', 70520.00, 'Card', 'PAY-2026-021', 'Confirmed'),
(22, 16, '2026-05-08 09:30:00', 52890.00, 'Transfer', 'PAY-2026-022', 'Confirmed'),

(23, 17, '2026-05-22 10:50:00', 81871.88, 'Mobile Money', 'PAY-2026-023', 'Confirmed'),
(24, 17, '2026-06-05 13:35:00', 65497.50, 'Transfer', 'PAY-2026-024', 'Confirmed'),
(25, 17, '2026-06-19 11:25:00', 49123.12, 'Card', 'PAY-2026-025', 'Confirmed'),

(26, 18, '2026-06-18 14:00:00', 90200.00, 'Transfer', 'PAY-2026-026', 'Confirmed'),
(27, 18, '2026-07-02 10:20:00', 72160.00, 'Mobile Money', 'PAY-2026-027', 'Confirmed'),
(28, 18, '2026-07-16 15:05:00', 54120.00, 'Transfer', 'PAY-2026-028', 'Confirmed'),

(29, 19, '2026-07-07 12:30:00', 75542.50, 'Transfer', 'PAY-2026-029', 'Confirmed'),
(30, 20, '2026-07-18 11:45:00', 49917.50, 'Mobile Money', 'PAY-2026-030', 'Confirmed');


-- SYNCHRONIZE VEHICLE STATUS WITH SALES


UPDATE vehicle
SET vehicle_status = 'Sold'
WHERE vehicle_id IN (
    1,2,3,4,5,
    7,8,9,10,11,12,13,
    15,16,17,18,19,20
);

UPDATE vehicle
SET vehicle_status = 'Reserved'
WHERE vehicle_id IN (21,23,24,25);

UPDATE vehicle
SET vehicle_status = 'Available'
WHERE vehicle_id IN (26,27,28);

COMMIT;


-- VERIFICATION


SELECT 'sale' AS table_name, COUNT(*) AS row_count FROM sale
UNION ALL
SELECT 'sale_item', COUNT(*) FROM sale_item
UNION ALL
SELECT 'payment', COUNT(*) FROM payment;

SELECT
    sale_id,
    total_amount,
    payment_status,
    COALESCE((
        SELECT SUM(p.amount)
        FROM payment p
        WHERE p.sale_id = sale.sale_id
          AND p.payment_status = 'Confirmed'
    ), 0) AS confirmed_payments
FROM sale
ORDER BY sale_id;
