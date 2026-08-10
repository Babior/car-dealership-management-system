/*
 CAR DEALERSHIP MANAGEMENT SYSTEM
 PHASE 6 - VIEWS
 JAMAL: SALES, CUSTOMER AND PERFORMANCE REPORTING
 */


USE car_dealership_db;

/*
 VIEW 1: CUSTOMER SALE BALANCE
 Purpose:
 Provides each sale with customer details, total confirmed
 payments received and the remaining outstanding balance.
 */

CREATE OR REPLACE VIEW vw_customer_sale_balance AS
SELECT
    s.sale_id,
    s.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    s.sale_date,
    s.total_amount,

    COALESCE(
        SUM(
            CASE
                WHEN p.payment_status = 'Confirmed'
                THEN p.amount
                ELSE 0
            END
        ),
        0
    ) AS amount_paid,

    s.total_amount -
    COALESCE(
        SUM(
            CASE
                WHEN p.payment_status = 'Confirmed'
                THEN p.amount
                ELSE 0
            END
        ),
        0
    ) AS outstanding_balance,

    s.sale_status,
    s.payment_status

FROM sale AS s
INNER JOIN customer AS c
    ON s.customer_id = c.customer_id
LEFT JOIN payment AS p
    ON s.sale_id = p.sale_id

GROUP BY
    s.sale_id,
    s.customer_id,
    c.first_name,
    c.last_name,
    s.sale_date,
    s.total_amount,
    s.sale_status,
    s.payment_status;


/*
 VIEW 2: MONTHLY SALES SUMMARY
 Purpose:
 Provides a reusable monthly management summary of completed
 sales and revenue.
 */


CREATE OR REPLACE VIEW vw_monthly_sales_summary AS
SELECT
    YEAR(s.sale_date) AS sale_year,
    MONTH(s.sale_date) AS sale_month,
    DATE_FORMAT(s.sale_date, '%Y-%m') AS sales_month,
    COUNT(s.sale_id) AS completed_sales,
    SUM(s.total_amount) AS total_sales_revenue,
    SUM(s.discount_amount) AS total_discounts,
    SUM(s.tax_amount) AS total_tax,
    AVG(s.total_amount) AS average_sale_value
FROM sale AS s
WHERE s.sale_status = 'Completed'
GROUP BY
    YEAR(s.sale_date),
    MONTH(s.sale_date),
    DATE_FORMAT(s.sale_date, '%Y-%m');


/*
 VIEW 3: SALESPERSON PERFORMANCE
 Purpose:
 Provides a reusable summary of salesperson activity,
 revenue, historical commission earned and target progress.
 */

CREATE OR REPLACE VIEW vw_salesperson_performance AS
SELECT
    sp.employee_id AS salesperson_id,
    CONCAT(e.first_name, ' ', e.last_name) AS salesperson_name,

    COUNT(
        CASE
            WHEN s.sale_status = 'Completed'
            THEN s.sale_id
        END
    ) AS completed_sales,

    COALESCE(
        SUM(
            CASE
                WHEN s.sale_status = 'Completed'
                THEN s.total_amount
                ELSE 0
            END
        ),
        0
    ) AS total_sales_value,

    COALESCE(
        SUM(
            CASE
                WHEN s.sale_status = 'Completed'
                THEN s.total_amount
                     * (s.commission_rate_applied / 100)
                ELSE 0
            END
        ),
        0
    ) AS total_commission_earned,

    sp.sales_target,

    CASE
        WHEN COALESCE(
            SUM(
                CASE
                    WHEN s.sale_status = 'Completed'
                    THEN s.total_amount
                    ELSE 0
                END
            ),
            0
        ) >= sp.sales_target
        THEN 'Target Achieved'
        ELSE 'Below Target'
    END AS target_status

FROM salesperson AS sp
INNER JOIN employee AS e
    ON sp.employee_id = e.employee_id
LEFT JOIN sale AS s
    ON sp.employee_id = s.salesperson_id

GROUP BY
    sp.employee_id,
    e.first_name,
    e.last_name,
    sp.sales_target;