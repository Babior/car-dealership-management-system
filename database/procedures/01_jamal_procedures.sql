
# CAR DEALERSHIP MANAGEMENT SYSTEM
# PHASE 6 - STORED PROCEDURES
# JAMAL: SALES AND PAYMENT PROCESSING


USE car_dealership_db;

DELIMITER $$



# PROCEDURE 1: COMPLETE SALE
# Purpose:
# Completes an existing sale and marks all vehicles belonging
# to that sale as Sold within one transaction.


DROP PROCEDURE IF EXISTS sp_complete_sale$$

CREATE PROCEDURE sp_complete_sale(
    IN p_sale_id INT
)
BEGIN
    DECLARE v_sale_exists INT DEFAULT 0;
    DECLARE v_sale_item_count INT DEFAULT 0;
    DECLARE v_invalid_vehicle_count INT DEFAULT 0;
    DECLARE v_sale_status VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    # Confirm that the sale exists.
    SELECT
        COUNT(*),
        MAX(sale_status)
    INTO
        v_sale_exists,
        v_sale_status
    FROM sale
    WHERE sale_id = p_sale_id;

    IF v_sale_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sale does not exist.';
    END IF;

    # A cancelled sale cannot be completed.
    IF v_sale_status = 'Cancelled' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cancelled sale cannot be completed.';
    END IF;

    # Prevent unnecessary repeat completion.
    IF v_sale_status = 'Completed' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sale is already completed.';
    END IF;

    # Every sale must contain at least one sale item.
    SELECT COUNT(*)
    INTO v_sale_item_count
    FROM sale_item
    WHERE sale_id = p_sale_id;

    IF v_sale_item_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sale must contain at least one vehicle.';
    END IF;

    # Ensure vehicles have not become unavailable before completion.
    SELECT COUNT(*)
    INTO v_invalid_vehicle_count
    FROM sale_item AS si
    INNER JOIN vehicle AS v
        ON si.vehicle_id = v.vehicle_id
    WHERE si.sale_id = p_sale_id
      AND v.vehicle_status <> 'Available';

    IF v_invalid_vehicle_count > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'One or more vehicles are not available for sale completion.';
    END IF;

    # Mark all vehicles in the sale as sold.
    UPDATE vehicle AS v
    INNER JOIN sale_item AS si
        ON v.vehicle_id = si.vehicle_id
    SET v.vehicle_status = 'Sold'
    WHERE si.sale_id = p_sale_id;

    # Complete the sale.
    UPDATE sale
    SET sale_status = 'Completed'
    WHERE sale_id = p_sale_id;

    COMMIT;
END$$



# PROCEDURE 2: RECORD PAYMENT
# Purpose:
# Records a confirmed payment, prevents overpayment and
# updates the payment status of the related sale.

DROP PROCEDURE IF EXISTS sp_record_payment$$

CREATE PROCEDURE sp_record_payment(
    IN p_sale_id INT,
    IN p_amount DECIMAL(12,2),
    IN p_payment_method VARCHAR(30),
    IN p_reference_number VARCHAR(100)
)
BEGIN
    DECLARE v_sale_total DECIMAL(12,2);
    DECLARE v_amount_paid DECIMAL(12,2) DEFAULT 0;
    DECLARE v_new_amount_paid DECIMAL(12,2);
    DECLARE v_sale_status VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    # Lock the sale row while the payment is being processed.
    SELECT
        total_amount,
        sale_status
    INTO
        v_sale_total,
        v_sale_status
    FROM sale
    WHERE sale_id = p_sale_id
    FOR UPDATE;

    # SELECT INTO returns NULL variables if no matching row was found.
    IF v_sale_total IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sale does not exist.';
    END IF;

    IF v_sale_status = 'Cancelled' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Payment cannot be recorded for a cancelled sale.';
    END IF;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Payment amount must be greater than zero.';
    END IF;

    IF p_payment_method NOT IN (
        'Cash',
        'Card',
        'Transfer',
        'Mobile Money'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid payment method.';
    END IF;

    # Calculate the total value of confirmed payments already received.
    SELECT COALESCE(SUM(amount), 0)
    INTO v_amount_paid
    FROM payment
    WHERE sale_id = p_sale_id
      AND payment_status = 'Confirmed';

    SET v_new_amount_paid = v_amount_paid + p_amount;

    # Prevent cumulative confirmed payments from exceeding the sale total.
    IF v_new_amount_paid > v_sale_total THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Payment would exceed the outstanding sale balance.';
    END IF;

    # Record the payment.
    INSERT INTO payment (
        sale_id,
        payment_date,
        amount,
        payment_method,
        reference_number,
        payment_status
    )
    VALUES (
        p_sale_id,
        NOW(),
        p_amount,
        p_payment_method,
        p_reference_number,
        'Confirmed'
    );

    # Synchronize the sale's payment status.
    IF v_new_amount_paid = v_sale_total THEN

        UPDATE sale
        SET payment_status = 'Paid'
        WHERE sale_id = p_sale_id;

    ELSE

        UPDATE sale
        SET payment_status = 'Partially Paid'
        WHERE sale_id = p_sale_id;

    END IF;

    COMMIT;
END$$


DELIMITER ;