USE car_dealership_db;


-- EAN PHASE 6: STORED PROCEDURE
-- Procedure: sp_complete_service_order
--
-- Purpose:
-- Safely changes a valid service order to Completed.
--
-- Important:
-- This procedure does not deduct part inventory.
-- The trg_service_part_manage_stock trigger already deducts
-- stock when service_part records are inserted.


DROP PROCEDURE IF EXISTS sp_complete_service_order;

DELIMITER $$

CREATE PROCEDURE sp_complete_service_order(
    IN p_service_order_id INT
)
BEGIN
    DECLARE v_order_count INT DEFAULT 0;
    DECLARE v_current_status VARCHAR(30);
    DECLARE v_invalid_parts INT DEFAULT 0;

    -- Roll back the transaction if any SQL error occurs.
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Check whether the service order exists.
    SELECT COUNT(*)
    INTO v_order_count
    FROM service_order
    WHERE service_order_id = p_service_order_id;

    IF v_order_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The selected service order does not exist';
    END IF;

    -- Lock the service order while it is being completed.
    SELECT service_status
    INTO v_current_status
    FROM service_order
    WHERE service_order_id = p_service_order_id
    FOR UPDATE;

    -- Prevent an already completed order from being completed again.
    IF v_current_status = 'Completed' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The service order is already completed';
    END IF;

    -- A cancelled service order cannot be completed.
    IF v_current_status = 'Cancelled' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A cancelled service order cannot be completed';
    END IF;

    -- Confirm that any service-part records have valid quantities
    -- and valid historical prices.
    SELECT COUNT(*)
    INTO v_invalid_parts
    FROM service_part
    WHERE service_order_id = p_service_order_id
      AND (
          quantity_used <= 0
          OR unit_price_at_use < 0
      );

    IF v_invalid_parts > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The service order contains invalid part records';
    END IF;

    -- Complete the service order.
    UPDATE service_order
    SET service_status = 'Completed'
    WHERE service_order_id = p_service_order_id;

    COMMIT;

    -- Return confirmation.
    SELECT
        service_order_id,
        service_status,
        'Service order completed successfully' AS result_message
    FROM service_order
    WHERE service_order_id = p_service_order_id;
END$$

DELIMITER ;
