USE car_dealership_db;
-- CAR DEALERSHIP MANAGEMENT SYSTEM
-- SIX BUSINESS-RULE TRIGGERS


-- TRIGGER 1: Prevent the sale of an unavailable vehicle
-- Table: sale_item

DROP TRIGGER IF EXISTS trg_sale_item_check_vehicle;

DELIMITER $$

CREATE TRIGGER trg_sale_item_check_vehicle
BEFORE INSERT ON sale_item
FOR EACH ROW
BEGIN
    DECLARE current_vehicle_status VARCHAR(20);
    DECLARE active_sale_count INT DEFAULT 0;

    SELECT vehicle_status
    INTO current_vehicle_status
    FROM vehicle
    WHERE vehicle_id = NEW.vehicle_id;

    IF current_vehicle_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The selected vehicle does not exist';

    ELSEIF current_vehicle_status <> 'Available' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The selected vehicle is not available for sale';
    END IF;

    SELECT COUNT(*)
    INTO active_sale_count
    FROM sale_item AS si
    INNER JOIN sale AS s
        ON si.sale_id = s.sale_id
    WHERE si.vehicle_id = NEW.vehicle_id
      AND s.sale_status IN ('Pending', 'Completed');

    IF active_sale_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The selected vehicle is already assigned to an active sale';
    END IF;
END$$

DELIMITER ;


-- TRIGGER 2: Prevent payment over a sale's total amount
-- Table: payment

DROP TRIGGER IF EXISTS trg_payment_prevent_overpayment;

DELIMITER $$

CREATE TRIGGER trg_payment_prevent_overpayment
BEFORE INSERT ON payment
FOR EACH ROW
BEGIN
    DECLARE sale_total DECIMAL(12,2);
    DECLARE confirmed_total DECIMAL(12,2);

    SELECT total_amount
    INTO sale_total
    FROM sale
    WHERE sale_id = NEW.sale_id
    FOR UPDATE;

    IF sale_total IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The selected sale does not exist';
    END IF;

    SELECT COALESCE(SUM(amount), 0)
    INTO confirmed_total
    FROM payment
    WHERE sale_id = NEW.sale_id
      AND payment_status = 'Confirmed';

    IF NEW.payment_status = 'Confirmed'
       AND confirmed_total + NEW.amount > sale_total THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Payment rejected because it would exceed the sale total';
    END IF;
END$$

DELIMITER ;


-- TRIGGER 3: Check and deduct part inventory
-- Table: service_part

DROP TRIGGER IF EXISTS trg_service_part_manage_stock;

DELIMITER $$

CREATE TRIGGER trg_service_part_manage_stock
BEFORE INSERT ON service_part
FOR EACH ROW
BEGIN
    DECLARE available_stock INT;

    IF NEW.quantity_used <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity used must be greater than zero';
    END IF;

    SELECT quantity_in_stock
    INTO available_stock
    FROM part
    WHERE part_id = NEW.part_id
    FOR UPDATE;

    IF available_stock IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The selected part does not exist';

    ELSEIF available_stock < NEW.quantity_used THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient part quantity in stock';

    ELSE
        UPDATE part
        SET quantity_in_stock = quantity_in_stock - NEW.quantity_used
        WHERE part_id = NEW.part_id;
    END IF;
END$$

DELIMITER ;


-- TRIGGER 4: Validate a loan installment
-- Table: loan_installment

DROP TRIGGER IF EXISTS trg_installment_validate;

DELIMITER $$

CREATE TRIGGER trg_installment_validate
BEFORE INSERT ON loan_installment
FOR EACH ROW
BEGIN
    DECLARE loan_term INT;
    DECLARE loan_start DATE;
    DECLARE loan_end DATE;

    SELECT term_months, start_date, end_date
    INTO loan_term, loan_start, loan_end
    FROM loan
    WHERE loan_id = NEW.loan_id;

    IF loan_term IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The selected loan does not exist';
    END IF;

    IF NEW.installment_number < 1
       OR NEW.installment_number > loan_term THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Installment number is outside the loan term';
    END IF;

    IF NEW.payment_date IS NOT NULL
       AND (NEW.payment_date < loan_start
            OR NEW.payment_date > loan_end) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Installment payment date is outside the loan period';
    END IF;

    IF NEW.amount_due < 0 OR NEW.amount_paid < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Installment amounts cannot be negative';
    END IF;

    IF NEW.amount_paid > NEW.amount_due THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Amount paid cannot exceed the amount due';
    END IF;
END$$

DELIMITER ;


-- TRIGGER 5: Complete a loan when all installments are paid
-- Table: loan_installment

DROP TRIGGER IF EXISTS trg_loan_update_status;

DELIMITER $$

CREATE TRIGGER trg_loan_update_status
AFTER UPDATE ON loan_installment
FOR EACH ROW
BEGIN
    DECLARE unpaid_installments INT DEFAULT 0;

    IF NEW.installment_status = 'Paid'
       AND OLD.installment_status <> 'Paid' THEN

        SELECT COUNT(*)
        INTO unpaid_installments
        FROM loan_installment
        WHERE loan_id = NEW.loan_id
          AND installment_status <> 'Paid';

        IF unpaid_installments = 0 THEN
            UPDATE loan
            SET loan_status = 'Completed'
            WHERE loan_id = NEW.loan_id;
        END IF;
    END IF;
END$$

DELIMITER ;


-- TRIGGER 6: Validate warranty claims
-- Table: warranty_claim

DROP TRIGGER IF EXISTS trg_warranty_claim_validate;

DELIMITER $$

CREATE TRIGGER trg_warranty_claim_validate
BEFORE INSERT ON warranty_claim
FOR EACH ROW
BEGIN
    DECLARE current_warranty_status VARCHAR(20);
    DECLARE coverage_start DATE;
    DECLARE coverage_end DATE;

    SELECT warranty_status, start_date, end_date
    INTO current_warranty_status, coverage_start, coverage_end
    FROM warranty
    WHERE warranty_id = NEW.warranty_id;

    IF current_warranty_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The selected warranty does not exist';
    END IF;

    IF current_warranty_status <> 'Active' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A claim can only be submitted for an active warranty';
    END IF;

    IF NEW.claim_date < coverage_start
       OR NEW.claim_date > coverage_end THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Claim date is outside the warranty coverage period';
    END IF;

    IF NEW.claim_amount < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Warranty claim amount cannot be negative';
    END IF;
END$$

DELIMITER ;



SHOW TRIGGERS FROM car_dealership_db;