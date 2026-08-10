CREATE TABLE manufacturer (
    manufacturer_id INT NOT NULL AUTO_INCREMENT,
    manufacturer_name VARCHAR(100) NOT NULL,
    country VARCHAR(80) NOT NULL,

    CONSTRAINT pk_manufacturer
        PRIMARY KEY (manufacturer_id),

    CONSTRAINT uk_manufacturer_name
        UNIQUE (manufacturer_name)
);

-- =====================================================
-- vehicle_model
-- =====================================================
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

-- =====================================================
-- vehicle
-- =====================================================
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

-- =====================================================
-- department
-- =====================================================
CREATE TABLE salesperson (
    employee_id INT NOT NULL,
    commission_rate DECIMAL(5,2) NOT NULL,
    sales_target DECIMAL(12,2) NOT NULL,

    CONSTRAINT pk_salesperson
        PRIMARY KEY (employee_id),

    CONSTRAINT chk_salesperson_commission_rate
        CHECK (commission_rate BETWEEN 0 AND 100),

    CONSTRAINT chk_salesperson_sales_target
        CHECK (sales_target >= 0),

    CONSTRAINT fk_salesperson_employee
        FOREIGN KEY (employee_id)
        REFERENCES employee(employee_id)
);

-- =====================================================
-- mechanic
-- =====================================================
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

-- =====================================================
-- user_account
-- =====================================================
CREATE TABLE sale (
    sale_id INT AUTO_INCREMENT,
    customer_id INT NOT NULL,
    salesperson_id INT NOT NULL,
    sale_date DATE NOT NULL,
    discount_amount DECIMAL(12,2) NOT NULL,
    tax_amount DECIMAL(12,2) NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    commission_rate_applied DECIMAL(5,2) NOT NULL,
    sale_status VARCHAR(20) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,

    CONSTRAINT pk_sale
        PRIMARY KEY (sale_id),

    CONSTRAINT chk_sale_discount
        CHECK (discount_amount >= 0),

    CONSTRAINT chk_sale_tax
        CHECK (tax_amount >= 0),

    CONSTRAINT chk_sale_total
        CHECK (total_amount >= 0),

    CONSTRAINT chk_sale_commission_rate
        CHECK (commission_rate_applied BETWEEN 0 AND 100),

    CONSTRAINT chk_sale_status
        CHECK (sale_status IN ('Pending', 'Completed', 'Cancelled')),

    CONSTRAINT chk_sale_payment_status
        CHECK (payment_status IN ('Unpaid', 'Partially Paid', 'Paid')),

    CONSTRAINT fk_sale_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id),

    CONSTRAINT fk_sale_salesperson
        FOREIGN KEY (salesperson_id)
        REFERENCES salesperson(employee_id),

    INDEX idx_sale_date (sale_date),
    INDEX idx_sale_customer (customer_id),
    INDEX idx_sale_salesperson (salesperson_id)
);

-- =====================================================
-- sale_item
-- =====================================================
CREATE TABLE sale_item (
    sale_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    agreed_price DECIMAL(12,2) NOT NULL,

    CONSTRAINT pk_sale_item
        PRIMARY KEY (sale_id, vehicle_id),

    CONSTRAINT uq_sale_item_vehicle
        UNIQUE (vehicle_id),

    CONSTRAINT chk_sale_item_agreed_price
        CHECK (agreed_price >= 0),

    CONSTRAINT fk_sale_item_sale
        FOREIGN KEY (sale_id)
        REFERENCES sale(sale_id),

    CONSTRAINT fk_sale_item_vehicle
        FOREIGN KEY (vehicle_id)
        REFERENCES vehicle(vehicle_id)
);

-- =====================================================
-- payment
-- =====================================================
CREATE TABLE payment (
    payment_id INT AUTO_INCREMENT,
    sale_id INT NOT NULL,
    payment_date DATETIME NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    reference_number VARCHAR(100) NULL,
    payment_status VARCHAR(20) NOT NULL,

    CONSTRAINT pk_payment
        PRIMARY KEY (payment_id),

    CONSTRAINT uq_payment_reference
        UNIQUE (reference_number),

    CONSTRAINT chk_payment_amount
        CHECK (amount > 0),

    CONSTRAINT chk_payment_method
        CHECK (
            payment_method IN (
                'Cash',
                'Card',
                'Transfer',
                'Mobile Money'
            )
        ),

    CONSTRAINT chk_payment_status
        CHECK (
            payment_status IN (
                'Pending',
                'Confirmed',
                'Failed',
                'Refunded'
            )
        ),

    CONSTRAINT fk_payment_sale
        FOREIGN KEY (sale_id)
        REFERENCES sale(sale_id),

    INDEX idx_payment_sale (sale_id)
);

-- =====================================================
-- loan
-- =====================================================
CREATE TABLE loan (
    loan_id INT NOT NULL AUTO_INCREMENT,
    sale_id INT NOT NULL,
    lender_name VARCHAR(120) NOT NULL,
    principal_amount DECIMAL(12,2) NOT NULL,
    interest_rate DECIMAL(5,2) NOT NULL,
    term_months SMALLINT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    loan_status VARCHAR(20) NOT NULL,

    CONSTRAINT pk_loan
        PRIMARY KEY (loan_id),

    CONSTRAINT uk_loan_sale
        UNIQUE (sale_id),

    CONSTRAINT fk_loan_sale
        FOREIGN KEY (sale_id)
        REFERENCES sale(sale_id),

    CONSTRAINT chk_loan_principal
        CHECK (principal_amount > 0),

    CONSTRAINT chk_loan_interest
        CHECK (interest_rate >= 0),

    CONSTRAINT chk_loan_term
        CHECK (term_months > 0),

    CONSTRAINT chk_loan_status
        CHECK (loan_status IN (
            'Pending',
            'Active',
            'Completed',
            'Defaulted'
        ))
);

-- =====================================================
-- loan_installment
-- =====================================================
CREATE TABLE loan_installment (
    loan_id INT NOT NULL,
    installment_number SMALLINT NOT NULL,
    due_date DATE NOT NULL,
    amount_due DECIMAL(12,2) NOT NULL,
    amount_paid DECIMAL(12,2) NOT NULL,
    payment_date DATE NULL,
    installment_status VARCHAR(20) NOT NULL,

    CONSTRAINT pk_loan_installment
        PRIMARY KEY (loan_id, installment_number),

    CONSTRAINT fk_loan_installment_loan
        FOREIGN KEY (loan_id)
        REFERENCES loan(loan_id),

    CONSTRAINT chk_installment_due
        CHECK (amount_due > 0),

    CONSTRAINT chk_installment_paid
        CHECK (amount_paid >= 0),

    CONSTRAINT chk_installment_status
        CHECK (installment_status IN (
            'Pending',
            'Paid',
            'Partially Paid',
            'Overdue'
        ))
);

-- =====================================================
-- part
-- =====================================================
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

-- =====================================================
-- service_order
-- =====================================================
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

-- =====================================================
-- service_part
-- =====================================================
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

-- =====================================================
-- warranty
-- =====================================================
CREATE TABLE warranty (
    warranty_id INT NOT NULL AUTO_INCREMENT,
    vehicle_id INT NOT NULL,
    provider_name VARCHAR(120) NOT NULL,
    provider_phone VARCHAR(20) NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    coverage_description VARCHAR(500) NOT NULL,
    warranty_status VARCHAR(20) NOT NULL,

    CONSTRAINT pk_warranty
        PRIMARY KEY (warranty_id),

    CONSTRAINT fk_warranty_vehicle
        FOREIGN KEY (vehicle_id)
        REFERENCES vehicle(vehicle_id),

    CONSTRAINT chk_warranty_dates
        CHECK (end_date >= start_date),

    CONSTRAINT chk_warranty_status
        CHECK (warranty_status IN (
            'Active',
            'Expired',
            'Cancelled',
            'Voided'
        ))
);

-- =====================================================
-- warranty_claim
-- =====================================================
CREATE TABLE warranty_claim (
    claim_id INT NOT NULL AUTO_INCREMENT,
    warranty_id INT NOT NULL,
    service_order_id INT NULL,
    claim_date DATE NOT NULL,
    claim_amount DECIMAL(12,2) NOT NULL,
    claim_description VARCHAR(500) NOT NULL,
    claim_status VARCHAR(20) NOT NULL,
    decision_date DATE NULL,

    CONSTRAINT pk_warranty_claim
        PRIMARY KEY (claim_id),

    CONSTRAINT fk_warranty_claim_warranty
        FOREIGN KEY (warranty_id)
        REFERENCES warranty(warranty_id),

    CONSTRAINT fk_warranty_claim_service_order
        FOREIGN KEY (service_order_id)
        REFERENCES service_order(service_order_id),

    CONSTRAINT chk_warranty_claim_amount
        CHECK (claim_amount >= 0),

    CONSTRAINT chk_warranty_claim_status
        CHECK (claim_status IN (
            'Pending',
            'Approved',
            'Rejected',
            'Paid'
        ))
);

