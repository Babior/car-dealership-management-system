-- Car Dealership Management System
-- Phase 5: Winfred Service Records
-- Contains only records whose parent data is currently available.
-- Records: 6 mechanics, 25 service orders, 35 service-part rows.
-- Loans and installments are intentionally excluded until sale records exist.

USE car_dealership_db;

START TRANSACTION;

-- =====================================================
-- PREREQUISITE CHECKS
-- Expected parent records:
-- employees 7-12, customers 1-25, vehicles 1-25, parts 1-20
-- =====================================================
SELECT COUNT(*) AS required_employees_found
FROM employee
WHERE employee_id BETWEEN 7 AND 12;

SELECT COUNT(*) AS required_customers_found
FROM customer
WHERE customer_id BETWEEN 1 AND 25;

SELECT COUNT(*) AS required_vehicles_found
FROM vehicle
WHERE vehicle_id BETWEEN 1 AND 25;

SELECT COUNT(*) AS required_parts_found
FROM part
WHERE part_id BETWEEN 1 AND 20;

-- =====================================================
-- 1. MECHANIC SUBTYPE (6 records)
-- Employee IDs 7-12 are the technicians reserved by the shared ID contract.
-- =====================================================
INSERT INTO mechanic (employee_id, specialization, certification) VALUES
(7,  'Engine Diagnostics and Repair',       'ASE Engine Repair Certification'),
(8,  'Electrical and Electronic Systems',   'Automotive Electrical Systems Certificate'),
(9,  'Brake and Suspension Systems',        'ASE Brakes and Suspension Certification'),
(10, 'Transmission and Drivetrain',          'Automatic Transmission Service Certificate'),
(11, 'Cooling and Air-Conditioning Systems', 'Automotive HVAC Service Certificate'),
(12, 'General Maintenance and Inspection',   'Vehicle Inspection and Maintenance Certificate');

-- =====================================================
-- 2. SERVICE ORDERS (25 records)
-- Each order references an existing customer, vehicle and mechanic.
-- =====================================================
INSERT INTO service_order
    (service_order_id, customer_id, vehicle_id, mechanic_id,
     service_date, current_mileage, service_description,
     labour_charge, service_status)
VALUES
(1,  1,  1,  7,  '2025-01-08', 29200, 'Routine engine-oil service and oil-filter replacement',                  450.00,  'Completed'),
(2,  2,  2,  8,  '2025-01-21', 42150, 'Battery and charging-system inspection',                                  380.00,  'Completed'),
(3,  3,  3,  9,  '2025-02-03', 17280, 'Front brake inspection and brake-pad replacement',                        650.00,  'Completed'),
(4,  4,  4,  10, '2025-02-17', 24520, 'Transmission-fluid inspection and drivetrain diagnosis',                  720.00,  'Completed'),
(5,  5,  5,  11, '2025-03-04', 20150, 'Cooling-system pressure test and radiator inspection',                     600.00,  'Completed'),
(6,  6,  6,  12, '2025-03-18', 48850, 'Scheduled maintenance, filters and general safety inspection',             520.00,  'Completed'),
(7,  7,  7,  7,  '2025-04-02', 22940, 'Engine tune-up and spark-plug replacement',                                580.00,  'Completed'),
(8,  8,  8,  8,  '2025-04-16', 54210, 'Starter-motor and electrical-system diagnosis',                            750.00,  'Completed'),
(9,  9,  9,  9,  '2025-05-01', 39480, 'Brake-pad and wheel-bearing inspection',                                   680.00,  'Completed'),
(10, 10, 10, 10, '2025-05-14', 27620, 'Transmission performance inspection and road test',                        700.00,  'Completed'),
(11, 11, 11, 11, '2025-06-03', 25590, 'Cooling-system service and water-pump inspection',                         620.00,  'Completed'),
(12, 12, 12, 12, '2025-06-19', 61250, 'Routine maintenance and cabin-filter replacement',                         480.00,  'Completed'),
(13, 13, 13, 7,  '2025-07-07', 36140, 'Fuel-system diagnosis and fuel-pump test',                                  690.00,  'Completed'),
(14, 14, 14, 8,  '2025-07-23', 59830, 'Alternator output test and battery inspection',                             540.00,  'Completed'),
(15, 15, 15, 9,  '2025-08-11', 30720, 'Suspension noise diagnosis and shock-absorber inspection',                  660.00,  'Completed'),
(16, 16, 16, 10, '2025-08-27', 45280, 'Drivetrain vibration diagnosis and transmission inspection',               760.00,  'Completed'),
(17, 17, 17, 11, '2025-09-09', 18440, 'Radiator and coolant-system inspection',                                    570.00,  'Completed'),
(18, 18, 18, 12, '2025-09-25', 32950, 'General inspection, oil service and wiper replacement',                     500.00,  'Completed'),
(19, 19, 19, 7,  '2025-10-13', 50120, 'Timing-belt inspection and engine performance check',                       820.00,  'Completed'),
(20, 20, 20, 8,  '2025-10-29', 38340, 'Headlamp and electrical-circuit inspection',                                360.00,  'Completed'),
(21, 21, 21, 9,  '2025-11-12', 34760, 'Rear brake and suspension inspection',                                      640.00,  'Completed'),
(22, 22, 22, 10, '2025-11-26', 23170, 'Transmission warning-light diagnosis',                                      690.00,  'In Progress'),
(23, 23, 23, 11, '2025-12-08', 29150, 'Air-conditioning and cooling-system diagnosis',                             610.00,  'Completed'),
(24, 24, 24, 12, '2026-01-14', 43780, 'Scheduled maintenance and multi-point inspection',                          490.00,  'Scheduled'),
(25, 25, 25, 7,  '2026-02-06', 26650, 'Engine warning-light diagnosis and tune-up',                                730.00,  'Scheduled');

-- =====================================================
-- 3. SERVICE PARTS (35 records)
-- unit_price_at_use preserves the historical selling price of each part.
-- If trg_service_part_manage_stock is installed, it will deduct stock.
-- =====================================================
INSERT INTO service_part
    (service_order_id, part_id, quantity_used, unit_price_at_use)
VALUES
(1,  1, 1, 180.00),
(1,  2, 1, 240.00),
(2,  8, 1, 1850.00),
(3,  4, 1, 950.00),
(3,  6, 2, 1350.00),
(4,  17, 1, 590.00),
(5,  11, 1, 2600.00),
(5,  12, 1, 1450.00),
(6,  1, 1, 180.00),
(6,  3, 1, 275.00),
(7,  7, 1, 620.00),
(7,  2, 1, 240.00),
(8,  10, 1, 2850.00),
(9,  4, 1, 950.00),
(9,  18, 1, 980.00),
(10, 17, 1, 590.00),
(11, 12, 1, 1450.00),
(12, 1, 1, 180.00),
(12, 3, 1, 275.00),
(13, 13, 1, 2100.00),
(14, 9, 1, 3200.00),
(14, 8, 1, 1850.00),
(15, 14, 2, 1750.00),
(16, 17, 1, 590.00),
(17, 11, 1, 2600.00),
(18, 1, 1, 180.00),
(18, 19, 1, 320.00),
(19, 16, 1, 1950.00),
(20, 20, 2, 210.00),
(21, 5, 1, 825.00),
(21, 15, 2, 1600.00),
(22, 17, 1, 590.00),
(23, 3, 1, 275.00),
(23, 12, 1, 1450.00),
(20, 8, 1, 1850.00);

COMMIT;

-- =====================================================
-- VERIFICATION
-- =====================================================
SELECT 'mechanic' AS table_name, COUNT(*) AS row_count FROM mechanic
UNION ALL
SELECT 'service_order', COUNT(*) FROM service_order
UNION ALL
SELECT 'service_part', COUNT(*) FROM service_part;
