-- Car Dealership Management System
-- Phase 5 - Winfred Inventory Base Seed
-- Tables: manufacturer, vehicle_model, vehicle, part

USE car_dealership_db;

-- =====================================================
-- 1. MANUFACTURERS (10)
-- =====================================================

INSERT INTO manufacturer
(manufacturer_id, manufacturer_name, country)
VALUES
(1, 'Toyota', 'Japan'),
(2, 'Honda', 'Japan'),
(3, 'Nissan', 'Japan'),
(4, 'Hyundai', 'South Korea'),
(5, 'Kia', 'South Korea'),
(6, 'Mercedes-Benz', 'Germany'),
(7, 'BMW', 'Germany'),
(8, 'Ford', 'United States'),
(9, 'Volkswagen', 'Germany'),
(10, 'Peugeot', 'France');

-- =====================================================
-- 2. VEHICLE MODELS (15)
-- =====================================================

INSERT INTO vehicle_model
(model_id, manufacturer_id, model_name, body_type, fuel_type, transmission)
VALUES
(1, 1, 'Corolla', 'Sedan', 'Petrol', 'Automatic'),
(2, 1, 'RAV4', 'SUV', 'Petrol', 'Automatic'),
(3, 2, 'Civic', 'Sedan', 'Petrol', 'Automatic'),
(4, 2, 'CR-V', 'SUV', 'Petrol', 'Automatic'),
(5, 3, 'X-Trail', 'SUV', 'Petrol', 'Automatic'),
(6, 3, 'Sentra', 'Sedan', 'Petrol', 'Automatic'),
(7, 4, 'Tucson', 'SUV', 'Petrol', 'Automatic'),
(8, 4, 'Elantra', 'Sedan', 'Petrol', 'Automatic'),
(9, 5, 'Sportage', 'SUV', 'Petrol', 'Automatic'),
(10, 5, 'Cerato', 'Sedan', 'Petrol', 'Automatic'),
(11, 6, 'C-Class', 'Sedan', 'Petrol', 'Automatic'),
(12, 7, '3 Series', 'Sedan', 'Petrol', 'Automatic'),
(13, 8, 'Ranger', 'Pickup', 'Diesel', 'Automatic'),
(14, 9, 'Tiguan', 'SUV', 'Petrol', 'Automatic'),
(15, 10, '3008', 'SUV', 'Petrol', 'Automatic');

-- =====================================================
-- 3. VEHICLES (30)
-- All vehicles initially Available as required.
-- =====================================================

INSERT INTO vehicle
(vehicle_id, model_id, vin, manufacture_year, colour, mileage,
purchase_price, selling_price, vehicle_status)
VALUES
(1, 1, 'JTDBR32E720100001', 2022, 'White', 18200, 145000.00, 169500.00, 'Available'),
(2, 1, 'JTDBR32E720100002', 2023, 'Silver', 12100, 151000.00, 176500.00, 'Available'),
(3, 2, 'JTMRFREV5M1000003', 2021, 'Black', 28600, 198000.00, 229500.00, 'Available'),
(4, 2, 'JTMRFREV5M1000004', 2022, 'Grey', 21400, 205000.00, 238000.00, 'Available'),
(5, 3, '2HGFC2F59NH000005', 2023, 'Blue', 9800, 175000.00, 204500.00, 'Available'),
(6, 3, '2HGFC2F59NH000006', 2022, 'White', 16700, 169000.00, 198000.00, 'Available'),
(7, 4, '2HKRW2H48LH000007', 2021, 'Silver', 32400, 190000.00, 221000.00, 'Available'),
(8, 4, '2HKRW2H48LH000008', 2022, 'Black', 24100, 198000.00, 230000.00, 'Available'),
(9, 5, 'JN8AT3CB9MW000009', 2022, 'Red', 19700, 185000.00, 216500.00, 'Available'),
(10, 5, 'JN8AT3CB9MW000010', 2023, 'White', 11300, 192000.00, 224000.00, 'Available'),
(11, 6, '3N1AB8CV7MY000011', 2021, 'Grey', 35800, 132000.00, 154500.00, 'Available'),
(12, 6, '3N1AB8CV7MY000012', 2022, 'Blue', 22600, 139000.00, 162500.00, 'Available'),
(13, 7, 'KM8J3CA46NU000013', 2022, 'White', 18900, 178000.00, 208000.00, 'Available'),
(14, 7, 'KM8J3CA46NU000014', 2023, 'Black', 10200, 186000.00, 217500.00, 'Available'),
(15, 8, 'KMHD84LF5MU000015', 2021, 'Silver', 30200, 128000.00, 149500.00, 'Available'),
(16, 8, 'KMHD84LF5MU000016', 2022, 'Grey', 21500, 136000.00, 158500.00, 'Available'),
(17, 9, 'KNDPB3AC8P7000017', 2023, 'White', 8500, 181000.00, 211500.00, 'Available'),
(18, 9, 'KNDPB3AC8P7000018', 2022, 'Blue', 14600, 174000.00, 203500.00, 'Available'),
(19, 10, 'KNAF2417LM7000019', 2021, 'Black', 33400, 125000.00, 147000.00, 'Available'),
(20, 10, 'KNAF2417LM7000020', 2022, 'Red', 20700, 133000.00, 155500.00, 'Available'),
(21, 11, 'WDDWF8EB5NR000021', 2023, 'Black', 9200, 285000.00, 329500.00, 'Available'),
(22, 11, 'WDDWF8EB5NR000022', 2022, 'White', 18300, 267000.00, 309500.00, 'Available'),
(23, 12, 'WBA8E1C58M7000023', 2021, 'Grey', 29800, 255000.00, 295000.00, 'Available'),
(24, 12, 'WBA8E1C58M7000024', 2022, 'Blue', 19400, 270000.00, 312000.00, 'Available'),
(25, 13, '1FTFW1ET5NFA00025', 2022, 'White', 22500, 220000.00, 255000.00, 'Available'),
(26, 13, '1FTFW1ET5NFA00026', 2023, 'Black', 11800, 235000.00, 272500.00, 'Available'),
(27, 14, 'WVGZZZ5NZMW000027', 2021, 'Silver', 31500, 205000.00, 239500.00, 'Available'),
(28, 14, 'WVGZZZ5NZMW000028', 2022, 'Grey', 20400, 216000.00, 251500.00, 'Available'),
(29, 15, 'VF3MRHNS8NS000029', 2022, 'White', 16100, 178000.00, 207500.00, 'Available'),
(30, 15, 'VF3MRHNS8NS000030', 2023, 'Blue', 9700, 188000.00, 219500.00, 'Available');

-- =====================================================
-- 4. PARTS (20)
-- Stock values are the PRE-SERVICE stock levels.
-- The service_part trigger will deduct later usage.
-- =====================================================

INSERT INTO part
(part_id, part_name, part_number, unit_price,
quantity_in_stock, reorder_level)
VALUES
(1, 'Engine Oil Filter', 'TOY-OF-001', 85.00, 25, 8),
(2, 'Air Filter', 'TOY-AF-002', 120.00, 20, 6),
(3, 'Brake Pad Set', 'BRK-PAD-003', 650.00, 18, 6),
(4, 'Spark Plug Set', 'SPK-PLG-004', 280.00, 24, 8),
(5, 'Front Brake Disc', 'BRK-DIS-005', 850.00, 14, 5),
(6, 'Fuel Filter', 'FUE-FIL-006', 145.00, 16, 5),
(7, 'Cabin Air Filter', 'CAB-FIL-007', 110.00, 15, 5),
(8, 'Engine Coolant', 'COL-001-008', 95.00, 30, 10),
(9, 'Automatic Transmission Fluid', 'ATF-009', 140.00, 22, 8),
(10, 'Brake Fluid', 'BRF-010', 75.00, 18, 6),
(11, 'Battery 12V', 'BAT-12V-011', 950.00, 10, 4),
(12, 'Alternator Belt', 'ALT-BLT-012', 180.00, 12, 4),
(13, 'Timing Belt Kit', 'TIM-BLT-013', 780.00, 9, 3),
(14, 'Wiper Blade Set', 'WIP-BLD-014', 160.00, 20, 6),
(15, 'Radiator Hose', 'RAD-HOS-015', 130.00, 14, 5),
(16, 'Thermostat', 'THR-016', 210.00, 11, 4),
(17, 'Wheel Bearing', 'WHL-BRG-017', 420.00, 8, 3),
(18, 'Clutch Kit', 'CLT-KIT-018', 1250.00, 7, 2),
(19, 'Shock Absorber', 'SHK-ABS-019', 560.00, 12, 4),
(20, 'Headlamp Bulb', 'HLP-BLB-020', 90.00, 16, 5);
