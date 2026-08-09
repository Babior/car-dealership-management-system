USE car_dealership_db;


-- ==========================================
-- 1. MANUFACTURER
-- ==========================================

CREATE TABLE manufacturer (
    manufacturer_id INT NOT NULL AUTO_INCREMENT,
    manufacturer_name VARCHAR(100) NOT NULL,
    country VARCHAR(80) NOT NULL,

    CONSTRAINT pk_manufacturer
        PRIMARY KEY (manufacturer_id),

    CONSTRAINT uk_manufacturer_name
        UNIQUE (manufacturer_name)
);


-- ==========================================
-- 2. VEHICLE MODEL
-- ==========================================

CREATE TABLE vehicle_model (
    model_id INT NOT NULL AUTO_INCREMENT,
    manufacturer_id INT NOT NULL,
    model_name VARCHAR(100) NOT NULL,
    body_type VARCHAR(40) NOT NULL,
    fuel_type VARCHAR(30) NOT NULL,
    transmission VARCHAR(30) NOT NULL,

    CONSTRAINT pk_vehicle_model
        PRIMARY KEY (model_id),

    CONSTRAINT fk_vehicle_model_manufacturer
        FOREIGN KEY (manufacturer_id)
        REFERENCES manufacturer(manufacturer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


-- ==========================================
-- 3. VEHICLE
-- ==========================================

CREATE TABLE vehicle (
    vehicle_id INT NOT NULL AUTO_INCREMENT,
    model_id INT NOT NULL,
    vin VARCHAR(17) NOT NULL,
    manufacture_year SMALLINT NOT NULL,
    colour VARCHAR(40) NOT NULL,
    mileage INT NOT NULL,
    purchase_price DECIMAL(12,2) NOT NULL,
    selling_price DECIMAL(12,2) NOT NULL,
    vehicle_status VARCHAR(20) NOT NULL,

    CONSTRAINT pk_vehicle
        PRIMARY KEY (vehicle_id),

    CONSTRAINT uk_vehicle_vin
        UNIQUE (vin),

    CONSTRAINT fk_vehicle_model
        FOREIGN KEY (model_id)
        REFERENCES vehicle_model(model_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_vehicle_vin_length
        CHECK (CHAR_LENGTH(vin) = 17),

    CONSTRAINT chk_vehicle_mileage
        CHECK (mileage >= 0),

    CONSTRAINT chk_vehicle_purchase_price
        CHECK (purchase_price >= 0),

    CONSTRAINT chk_vehicle_selling_price
        CHECK (selling_price >= 0),

    CONSTRAINT chk_vehicle_status
        CHECK (
            vehicle_status IN (
                'Available',
                'Reserved',
                'Sold',
                'In Service'
            )
        )
);


-- ==========================================
-- 4. EMPLOYEE
-- ==========================================

CREATE TABLE employee (
    employee_id INT NOT NULL AUTO_INCREMENT,
    department_id INT NOT NULL,
    job_role_id INT NOT NULL,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(120) NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(12,2) NOT NULL,
    employee_status VARCHAR(20) NOT NULL,

    CONSTRAINT pk_employee
        PRIMARY KEY (employee_id),

    CONSTRAINT uk_employee_email
        UNIQUE (email),

    CONSTRAINT fk_employee_department
        FOREIGN KEY (department_id)
        REFERENCES department(department_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_employee_job_role
        FOREIGN KEY (job_role_id)
        REFERENCES job_role(job_role_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_employee_salary
        CHECK (salary >= 0),

    CONSTRAINT chk_employee_status
        CHECK (
            employee_status IN (
                'Active',
                'On Leave',
                'Inactive'
            )
        )
);


-- ==========================================
-- INDEX
-- ==========================================

CREATE INDEX idx_vehicle_status
ON vehicle(vehicle_status);