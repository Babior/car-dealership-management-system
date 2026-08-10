# CAR DEALERSHIP MANAGEMENT SYSTEM
# PHASE 6 - USER-DEFINED FUNCTIONS
# JAMAL: SALES AND COMMISSION CALCULATIONS

USE car_dealership_db;

DELIMITER $$

# FUNCTION 1: OUTSTANDING SALE BALANCE
# Purpose:
# Returns the amount still owed on a sale after subtracting
# all Confirmed payments from the sale total.

DROP FUNCTION IF EXISTS fn_outstanding_sale_balance$$

CREATE FUNCTION fn_outstanding_sale_balance(
    p_sale_id INT
)
RETURNS DECIMAL(12,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_sale_total DECIMAL(12,2);
    DECLARE v_amount_paid DECIMAL(12,2) DEFAULT 0;

    # Get the total amount for the requested sale.
    SELECT total_amount
    INTO v_sale_total
    FROM sale
    WHERE sale_id = p_sale_id;

    # If the sale does not exist, return NULL.
    IF v_sale_total IS NULL THEN
        RETURN NULL;
    END IF;

    # Add only successful/confirmed payments.
    SELECT COALESCE(SUM(amount), 0)
    INTO v_amount_paid
    FROM payment
    WHERE sale_id = p_sale_id
      AND payment_status = 'Confirmed';

    RETURN v_sale_total - v_amount_paid;
END$$


# FUNCTION 2: CALCULATE COMMISSION
# Purpose:
# Calculates salesperson commission from a sale amount and
# the commission rate that was stored on the Sale record.

DROP FUNCTION IF EXISTS fn_calculate_commission$$

CREATE FUNCTION fn_calculate_commission(
    p_total_amount DECIMAL(12,2),
    p_commission_rate DECIMAL(5,2)
)
RETURNS DECIMAL(12,2)
DETERMINISTIC
NO SQL
BEGIN
    IF p_total_amount IS NULL
       OR p_commission_rate IS NULL THEN
        RETURN NULL;
    END IF;

    IF p_total_amount < 0
       OR p_commission_rate < 0
       OR p_commission_rate > 100 THEN
        RETURN NULL;
    END IF;

    RETURN ROUND(
        p_total_amount * (p_commission_rate / 100),
        2
    );
END$$


DELIMITER ;