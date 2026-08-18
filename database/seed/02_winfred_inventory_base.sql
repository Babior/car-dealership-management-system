USE car_dealership_db;

START TRANSACTION;

-- 1. MANUFACTURERS (10 records)
INSERT INTO manufacturer (manufacturer_name, country) VALUES
('Toyota', 'Japan'),
('Honda', 'Japan'),
('Nissan', 'Japan'),
('Ford', 'United States'),
('BMW', 'Germany'),
('Mercedes-Benz', 'Germany'),
('Hyundai', 'South Korea'),
('Kia', 'South Korea'),
('Volkswagen', 'Germany'),
('Chevrolet', 'United States');

-- 2. VEHICLE MODELS (15 records)
INSERT INTO vehicle_model
    (manufacturer_id, model_name, body_type, fuel_type, transmission)
VALUES
((SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Toyota'), 'Corolla', 'Sedan', 'Petrol', 'Automatic'),
((SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Toyota'), 'RAV4', 'SUV', 'Hybrid', 'Automatic'),
((SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Toyota'), 'Hilux', 'Pickup', 'Diesel', 'Automatic'),
((SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Toyota'), 'Camry', 'Sedan', 'Hybrid', 'Automatic'),
((SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Honda'), 'Civic', 'Sedan', 'Petrol', 'Automatic'),
((SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Honda'), 'CR-V', 'SUV', 'Petrol', 'Automatic'),
((SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Nissan'), 'Altima', 'Sedan', 'Petrol', 'Automatic'),
((SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Nissan'), 'X-Trail', 'SUV', 'Petrol', 'Automatic'),
((SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Ford'), 'Ranger', 'Pickup', 'Diesel', 'Automatic'),
((SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'BMW'), '3 Series', 'Sedan', 'Petrol', 'Automatic'),
((SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Mercedes-Benz'), 'C-Class', 'Sedan', 'Petrol', 'Automatic'),
((SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Hyundai'), 'Tucson', 'SUV', 'Petrol', 'Automatic'),
((SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Kia'), 'Sportage', 'SUV', 'Petrol', 'Automatic'),
((SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Volkswagen'), 'Tiguan', 'SUV', 'Petrol', 'Automatic'),
((SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Chevrolet'), 'Equinox', 'SUV', 'Petrol', 'Automatic');

-- 3. VEHICLES (30 records)
INSERT INTO vehicle
    (model_id, vin, manufacture_year, colour, mileage,
     purchase_price, selling_price, vehicle_status)
VALUES
((SELECT model_id FROM vehicle_model WHERE model_name = 'Corolla' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Toyota')), 'JTDBR32E720000001', 2022, 'White', 28500, 165000.00, 187500.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'Corolla' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Toyota')), 'JTDBR32E720000002', 2021, 'Silver', 41200, 148000.00, 169500.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'RAV4' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Toyota')), 'JTMRWRFV8N0000001', 2023, 'Black', 16500, 275000.00, 309000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'RAV4' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Toyota')), 'JTMRWRFV8N0000002', 2022, 'Blue', 23800, 258000.00, 289500.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'Hilux' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Toyota')), 'AHTBA3CD6P0000001', 2023, 'Grey', 19400, 325000.00, 365000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'Hilux' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Toyota')), 'AHTBA3CD6P0000002', 2021, 'White', 47600, 286000.00, 318000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'Camry' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Toyota')), '4T1G11AK5NU000001', 2022, 'Black', 22100, 225000.00, 254000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'Camry' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Toyota')), '4T1G11AK5NU000002', 2020, 'Red', 53400, 184000.00, 209000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'Civic' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Honda')), '2HGFC2F69MH000001', 2021, 'Blue', 38700, 158000.00, 181000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'Civic' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Honda')), '2HGFC2F69MH000002', 2022, 'White', 26900, 176000.00, 199500.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'CR-V' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Honda')), '5J6RW2H89NL000001', 2022, 'Silver', 24700, 248000.00, 279000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'CR-V' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Honda')), '5J6RW2H89NL000002', 2020, 'Black', 60100, 207000.00, 234000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'Altima' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Nissan')), '1N4BL4BV3MN000001', 2021, 'Grey', 35200, 152000.00, 174000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'Altima' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Nissan')), '1N4BL4BV3MN000002', 2020, 'White', 58900, 137000.00, 158000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'X-Trail' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Nissan')), 'JN1TBNT32Z0000001', 2022, 'Green', 29400, 232000.00, 261000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'X-Trail' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Nissan')), 'JN1TBNT32Z0000002', 2021, 'Silver', 44100, 214000.00, 241000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'Ranger' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Ford')), 'AFAPXXMJ2P0000001', 2023, 'Orange', 17300, 338000.00, 379000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'Ranger' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Ford')), 'AFAPXXMJ2P0000002', 2022, 'Black', 31600, 312000.00, 349000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = '3 Series' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'BMW')), 'WBA5R1C08LF000001', 2020, 'Blue', 48900, 285000.00, 324000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = '3 Series' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'BMW')), 'WBA5R1C08LF000002', 2021, 'Black', 37100, 315000.00, 357000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'C-Class' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Mercedes-Benz')), 'W1KWF8DB5MR000001', 2021, 'White', 33500, 329000.00, 374000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'C-Class' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Mercedes-Benz')), 'W1KWF8DB5MR000002', 2022, 'Grey', 21800, 356000.00, 402000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'Tucson' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Hyundai')), 'KM8JBCAE8NU000001', 2022, 'Red', 27800, 218000.00, 246000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'Tucson' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Hyundai')), 'KM8JBCAE8NU000002', 2021, 'White', 42600, 196000.00, 222000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'Sportage' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Kia')), 'KNDPMCAC9N7000001', 2022, 'Black', 25100, 216000.00, 244000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'Sportage' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Kia')), 'KNDPMCAC9N7000002', 2020, 'Silver', 55700, 182000.00, 207000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'Tiguan' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Volkswagen')), '3VV2B7AX4MM000001', 2021, 'Grey', 39800, 226000.00, 256000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'Tiguan' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Volkswagen')), '3VV2B7AX4MM000002', 2022, 'Blue', 26400, 244000.00, 276000.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'Equinox' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Chevrolet')), '3GNAXKEV6NL000001', 2022, 'White', 28700, 221000.00, 249500.00, 'Available'),
((SELECT model_id FROM vehicle_model WHERE model_name = 'Equinox' AND manufacturer_id = (SELECT manufacturer_id FROM manufacturer WHERE manufacturer_name = 'Chevrolet')), '3GNAXKEV6NL000002', 2021, 'Black', 45900, 198000.00, 225000.00, 'Available');

-- 4. PARTS (20 records)
-- Prices are expressed in Ghana cedis.
INSERT INTO part
    (part_name, part_number, unit_price, quantity_in_stock, reorder_level)
VALUES
('Engine Oil Filter', 'PRT-OIL-001', 180.00, 45, 10),
('Air Filter', 'PRT-AIR-002', 240.00, 32, 8),
('Cabin Air Filter', 'PRT-CAB-003', 275.00, 21, 6),
('Front Brake Pad Set', 'PRT-BRK-004', 950.00, 18, 5),
('Rear Brake Pad Set', 'PRT-BRK-005', 825.00, 16, 5),
('Brake Disc', 'PRT-BRK-006', 1350.00, 12, 4),
('Spark Plug Set', 'PRT-IGN-007', 620.00, 24, 6),
('12V Vehicle Battery', 'PRT-BAT-008', 1850.00, 14, 4),
('Alternator', 'PRT-ELC-009', 3200.00, 7, 3),
('Starter Motor', 'PRT-ELC-010', 2850.00, 6, 3),
('Radiator', 'PRT-CLG-011', 2600.00, 8, 3),
('Water Pump', 'PRT-CLG-012', 1450.00, 10, 3),
('Fuel Pump', 'PRT-FUL-013', 2100.00, 9, 3),
('Front Shock Absorber', 'PRT-SUS-014', 1750.00, 11, 4),
('Rear Shock Absorber', 'PRT-SUS-015', 1600.00, 9, 4),
('Timing Belt Kit', 'PRT-ENG-016', 1950.00, 8, 3),
('Serpentine Belt', 'PRT-ENG-017', 590.00, 15, 5),
('Wheel Bearing', 'PRT-WHL-018', 980.00, 13, 4),
('Wiper Blade Pair', 'PRT-BDY-019', 320.00, 28, 8),
('Headlamp Bulb', 'PRT-LGT-020', 210.00, 35, 10);

COMMIT;

-- VERIFICATION
SELECT 'manufacturer' AS table_name, COUNT(*) AS row_count FROM manufacturer
UNION ALL
SELECT 'vehicle_model', COUNT(*) FROM vehicle_model
UNION ALL
SELECT 'vehicle', COUNT(*) FROM vehicle
UNION ALL
SELECT 'part', COUNT(*) FROM part;

