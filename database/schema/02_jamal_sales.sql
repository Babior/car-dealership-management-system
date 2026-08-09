/* Car Dealership Management System
Phase 4 Physical Design
Owner: Jamal
Module: Sales and Payments
Entities:
Salesperson
Sale
SaleItem
Payment
*/

USE car_dealership_db;


# 1. SALESPERSON
# Employee subtype containing sales-specific information

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



# 2. SALE
# Main vehicle sale transaction

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

# 3. SALE_ITEM
# Associates sales with physical vehicles


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

# 4. PAYMENT
# Records payments made toward sales

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
