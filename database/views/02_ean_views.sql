USE car_dealership_db;

-- EAN PHASE 6: INVENTORY AND SERVICE VIEWS


-- VIEW 1: AVAILABLE VEHICLES
-- Provides reusable information about vehicles that are
-- currently available for sale.

CREATE OR REPLACE VIEW vw_available_vehicles AS
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
    v.purchase_price,
    v.selling_price,
    v.vehicle_status
FROM vehicle AS v
INNER JOIN vehicle_model AS vm
    ON v.model_id = vm.model_id
INNER JOIN manufacturer AS m
    ON vm.manufacturer_id = m.manufacturer_id
WHERE v.vehicle_status = 'Available';


-- VIEW 2: VEHICLE SERVICE HISTORY
-- Provides vehicle, customer, mechanic, service and
-- historical parts-cost information.
--
-- LEFT JOIN is used for service_part because a service
-- order may be valid even when no parts were used.

CREATE OR REPLACE VIEW vw_vehicle_service_history AS
SELECT
    so.service_order_id,
    so.service_date,
    so.service_status,
    so.service_description,
    so.current_mileage,
    so.labour_charge,

    v.vehicle_id,
    v.vin,
    v.manufacture_year,
    v.colour,

    m.manufacturer_name,
    vm.model_name,

    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.phone AS customer_phone,

    me.employee_id AS mechanic_id,
    CONCAT(e.first_name, ' ', e.last_name) AS mechanic_name,
    me.specialization,

    COALESCE(SUM(sp.quantity_used), 0) AS total_parts_used,

    ROUND(
        COALESCE(
            SUM(sp.quantity_used * sp.unit_price_at_use),
            0
        ),
        2
    ) AS total_parts_cost,

    ROUND(
        so.labour_charge +
        COALESCE(
            SUM(sp.quantity_used * sp.unit_price_at_use),
            0
        ),
        2
    ) AS total_service_cost

FROM service_order AS so

INNER JOIN vehicle AS v
    ON so.vehicle_id = v.vehicle_id

INNER JOIN vehicle_model AS vm
    ON v.model_id = vm.model_id

INNER JOIN manufacturer AS m
    ON vm.manufacturer_id = m.manufacturer_id

INNER JOIN customer AS c
    ON so.customer_id = c.customer_id

INNER JOIN mechanic AS me
    ON so.mechanic_id = me.employee_id

INNER JOIN employee AS e
    ON me.employee_id = e.employee_id

LEFT JOIN service_part AS sp
    ON so.service_order_id = sp.service_order_id

GROUP BY
    so.service_order_id,
    so.service_date,
    so.service_status,
    so.service_description,
    so.current_mileage,
    so.labour_charge,
    v.vehicle_id,
    v.vin,
    v.manufacture_year,
    v.colour,
    m.manufacturer_name,
    vm.model_name,
    c.customer_id,
    c.first_name,
    c.last_name,
    c.phone,
    me.employee_id,
    e.first_name,
    e.last_name,
    me.specialization;