USE car_dealership_db;

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
