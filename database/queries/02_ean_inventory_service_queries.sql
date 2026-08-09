USE car_dealership_db;

USE car_dealership_db;

-- =========================================================
-- EAN PHASE 6: ADVANCED INVENTORY AND SERVICE QUERIES
-- =========================================================


-- =========================================================
-- QUERY 1: AVAILABLE VEHICLE INVENTORY
-- Lists every vehicle currently available for sale.
-- =========================================================

SELECT
    v.vehicle_id,
    v.vin,
    m.manufacturer_name,
    vm.model_name,
    vm.body_type,
    vm.fuel_type,
    vm.transmission,
    v.manufacture_year,
    v.colour,
    v.mileage,
    v.selling_price,
    v.vehicle_status
FROM vehicle AS v
INNER JOIN vehicle_model AS vm
    ON v.model_id = vm.model_id
INNER JOIN manufacturer AS m
    ON vm.manufacturer_id = m.manufacturer_id
WHERE v.vehicle_status = 'Available'
ORDER BY
    m.manufacturer_name,
    vm.model_name,
    v.selling_price;


-- =========================================================
-- QUERY 2: INVENTORY ANALYSIS
-- Summarises inventory by manufacturer, model and status.
-- =========================================================

SELECT
    m.manufacturer_name,
    vm.model_name,
    v.vehicle_status,
    COUNT(v.vehicle_id) AS number_of_vehicles,
    ROUND(AVG(v.selling_price), 2) AS average_selling_price,
    ROUND(SUM(v.selling_price), 2) AS total_inventory_value
FROM vehicle AS v
INNER JOIN vehicle_model AS vm
    ON v.model_id = vm.model_id
INNER JOIN manufacturer AS m
    ON vm.manufacturer_id = m.manufacturer_id
GROUP BY
    m.manufacturer_id,
    m.manufacturer_name,
    vm.model_id,
    vm.model_name,
    v.vehicle_status
HAVING COUNT(v.vehicle_id) > 0
ORDER BY
    m.manufacturer_name,
    vm.model_name,
    v.vehicle_status;


-- =========================================================
-- QUERY 3: COMPLETE VEHICLE SERVICE HISTORY
-- Shows the vehicle, customer, mechanic and service details.
-- =========================================================

SELECT
    so.service_order_id,
    so.service_date,
    v.vehicle_id,
    v.vin,
    vm.model_name,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    CONCAT(e.first_name, ' ', e.last_name) AS mechanic_name,
    so.current_mileage,
    so.service_description,
    so.labour_charge,
    so.service_status
FROM service_order AS so
INNER JOIN vehicle AS v
    ON so.vehicle_id = v.vehicle_id
INNER JOIN vehicle_model AS vm
    ON v.model_id = vm.model_id
INNER JOIN customer AS c
    ON so.customer_id = c.customer_id
INNER JOIN mechanic AS me
    ON so.mechanic_id = me.employee_id
INNER JOIN employee AS e
    ON me.employee_id = e.employee_id
ORDER BY
    so.service_date DESC,
    so.service_order_id DESC;


-- =========================================================
-- QUERY 4: PARTS USAGE AND LOW-STOCK ANALYSIS
-- Uses historical prices recorded when the parts were used.
-- =========================================================

SELECT
    p.part_id,
    p.part_number,
    p.part_name,
    COALESCE(SUM(sp.quantity_used), 0) AS total_quantity_used,
    ROUND(
        COALESCE(
            SUM(sp.quantity_used * sp.unit_price_at_use),
            0
        ),
        2
    ) AS historical_parts_cost,
    p.quantity_in_stock,
    p.reorder_level,
    CASE
        WHEN p.quantity_in_stock <= p.reorder_level
            THEN 'Reorder Required'
        ELSE 'Stock Sufficient'
    END AS stock_condition
FROM part AS p
LEFT JOIN service_part AS sp
    ON p.part_id = sp.part_id
LEFT JOIN service_order AS so
    ON sp.service_order_id = so.service_order_id
GROUP BY
    p.part_id,
    p.part_number,
    p.part_name,
    p.quantity_in_stock,
    p.reorder_level
ORDER BY
    total_quantity_used DESC,
    p.part_name;