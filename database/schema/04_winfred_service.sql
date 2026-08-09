USE car_dealership_db;

CREATE TABLE mechanic (
    employee_id INT NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    certification VARCHAR(120) NULL,

    CONSTRAINT pk_mechanic
        PRIMARY KEY (employee_id),

    CONSTRAINT fk_mechanic_employee
        FOREIGN KEY (employee_id)
        REFERENCES employee(employee_id)
);

CREATE TABLE part (
    part_id INT NOT NULL AUTO_INCREMENT,
    part_name VARCHAR(120) NOT NULL,
    part_number VARCHAR(80) NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    quantity_in_stock INT NOT NULL,
    reorder_level INT NOT NULL,

    CONSTRAINT pk_part
        PRIMARY KEY (part_id),

    CONSTRAINT uk_part_number
        UNIQUE (part_number),

    CONSTRAINT chk_part_unit_price
        CHECK (unit_price >= 0),

    CONSTRAINT chk_part_stock
        CHECK (quantity_in_stock >= 0),

    CONSTRAINT chk_part_reorder
        CHECK (reorder_level >= 0)
);

CREATE TABLE service_order (
    service_order_id INT NOT NULL AUTO_INCREMENT,
    customer_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    mechanic_id INT NOT NULL,
    service_date DATE NOT NULL,
    current_mileage INT NOT NULL,
    service_description VARCHAR(500) NOT NULL,
    labour_charge DECIMAL(12,2) NOT NULL,
    service_status VARCHAR(20) NOT NULL,

    CONSTRAINT pk_service_order
        PRIMARY KEY (service_order_id),

    CONSTRAINT fk_service_order_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id),

    CONSTRAINT fk_service_order_vehicle
        FOREIGN KEY (vehicle_id)
        REFERENCES vehicle(vehicle_id),

    CONSTRAINT fk_service_order_mechanic
        FOREIGN KEY (mechanic_id)
        REFERENCES mechanic(employee_id),

    CONSTRAINT chk_service_order_mileage
        CHECK (current_mileage >= 0),

    CONSTRAINT chk_service_order_labour
        CHECK (labour_charge >= 0),

    CONSTRAINT chk_service_order_status
        CHECK (
            service_status IN (
                'Scheduled',
                'In Progress',
                'Completed',
                'Cancelled'
            )
        )
);

CREATE TABLE service_part (
    service_order_id INT NOT NULL,
    part_id INT NOT NULL,
    quantity_used INT NOT NULL,
    unit_price_at_use DECIMAL(12,2) NOT NULL,

    CONSTRAINT pk_service_part
        PRIMARY KEY (service_order_id, part_id),

    CONSTRAINT fk_service_part_order
        FOREIGN KEY (service_order_id)
        REFERENCES service_order(service_order_id),

    CONSTRAINT fk_service_part_part
        FOREIGN KEY (part_id)
        REFERENCES part(part_id),

    CONSTRAINT chk_service_part_quantity
        CHECK (quantity_used > 0),

    CONSTRAINT chk_service_part_price
        CHECK (unit_price_at_use >= 0)
);