# CAR DEALERSHIP MANAGEMENT SYSTEM
# PHASE 6 - ADVANCED SQL QUERIES
# JAMAL: SALES, CUSTOMER, PAYMENT AND FINANCING REPORTING


USE car_dealership_db;


# QUERY 1: CUSTOMER PURCHASE HISTORY
# Purpose:
# Shows the vehicles purchased by each customer together with
# sale details, vehicle information and the agreed sale price.


SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    s.sale_id,
    s.sale_date,
    m.manufacturer_name,
    vm.model_name,
    v.vin,
    si.agreed_price,
    s.total_amount AS sale_total,
    s.sale_status,
    s.payment_status
FROM customer AS c
INNER JOIN sale AS s
    ON c.customer_id = s.customer_id
INNER JOIN sale_item AS si
    ON s.sale_id = si.sale_id
INNER JOIN vehicle AS v
    ON si.vehicle_id = v.vehicle_id
INNER JOIN vehicle_model AS vm
    ON v.model_id = vm.model_id
INNER JOIN manufacturer AS m
    ON vm.manufacturer_id = m.manufacturer_id
ORDER BY
    c.customer_id,
    s.sale_date DESC,
    s.sale_id DESC;
    

# QUERY 2: SALES, PAYMENTS AND OUTSTANDING BALANCES
# Purpose:
# Summarizes each sale, the amount successfully paid,
# and the remaining outstanding balance.
# Only Confirmed payments contribute to the amount paid.

SELECT
    s.sale_id,
    s.sale_date,
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
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

    COUNT(
        CASE
            WHEN p.payment_status = 'Confirmed'
            THEN 1
        END
    ) AS confirmed_payment_count,

    s.payment_status
FROM sale AS s
INNER JOIN customer AS c
    ON s.customer_id = c.customer_id
LEFT JOIN payment AS p
    ON s.sale_id = p.sale_id
GROUP BY
    s.sale_id,
    s.sale_date,
    c.customer_id,
    c.first_name,
    c.last_name,
    s.total_amount,
    s.payment_status
ORDER BY
    outstanding_balance DESC,
    s.sale_date DESC;
    
/*
 QUERY 3: MONTHLY SALES AND REVENUE SUMMARY
 Purpose:
 Gives management a monthly summary of completed sales,
 revenue, discounts, tax and average transaction value.
*/

SELECT
    YEAR(s.sale_date) AS sale_year,
    MONTH(s.sale_date) AS sale_month,
    DATE_FORMAT(s.sale_date, '%Y-%m') AS sales_month,
    COUNT(s.sale_id) AS completed_sales,
    SUM(s.total_amount) AS total_sales_revenue,
    SUM(s.discount_amount) AS total_discounts,
    SUM(s.tax_amount) AS total_tax,
    AVG(s.total_amount) AS average_sale_value,
    MAX(s.total_amount) AS highest_sale_value,
    MIN(s.total_amount) AS lowest_sale_value
FROM sale AS s
WHERE s.sale_status = 'Completed'
GROUP BY
    YEAR(s.sale_date),
    MONTH(s.sale_date),
    DATE_FORMAT(s.sale_date, '%Y-%m')
ORDER BY
    sale_year DESC,
    sale_month DESC;


/*
 QUERY 4: SALESPERSON PERFORMANCE AND COMMISSION ANALYSIS
 Purpose:
 Measures completed sales, revenue generated and commission
 earned by each salesperson using the historical commission
 rate stored on each Sale.
*/

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
        AVG(
            CASE
                WHEN s.sale_status = 'Completed'
                THEN s.total_amount
            END
        ),
        0
    ) AS average_sale_value,

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
    sp.sales_target
ORDER BY
    total_sales_value DESC;


/*
 QUERY 5: LOAN AND OVERDUE INSTALLMENT ANALYSIS
 Purpose:
 Shows loan repayment performance and identifies loans
 containing unpaid installments whose due dates have passed.
*/

SELECT
    l.loan_id,
    l.sale_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    l.lender_name,
    l.principal_amount,
    l.interest_rate,
    l.term_months,
    l.loan_status,

    COUNT(li.installment_number) AS total_installments,

    SUM(
        CASE
            WHEN li.installment_status = 'Paid'
            THEN 1
            ELSE 0
        END
    ) AS paid_installments,

    SUM(
        CASE
            WHEN li.due_date < CURDATE()
                 AND li.installment_status <> 'Paid'
            THEN 1
            ELSE 0
        END
    ) AS overdue_installments,

    COALESCE(SUM(li.amount_due), 0) AS total_amount_due,

    COALESCE(SUM(li.amount_paid), 0) AS total_amount_paid,

    COALESCE(SUM(li.amount_due - li.amount_paid), 0)
        AS remaining_installment_balance

FROM loan AS l
INNER JOIN sale AS s
    ON l.sale_id = s.sale_id
INNER JOIN customer AS c
    ON s.customer_id = c.customer_id
LEFT JOIN loan_installment AS li
    ON l.loan_id = li.loan_id
GROUP BY
    l.loan_id,
    l.sale_id,
    c.first_name,
    c.last_name,
    l.lender_name,
    l.principal_amount,
    l.interest_rate,
    l.term_months,
    l.loan_status
ORDER BY
    overdue_installments DESC,
    remaining_installment_balance DESC;



/* QUERY 6: PAYMENT METHOD AND PAYMENT STATUS ANALYSIS
 Purpose:
 Analyses how customers pay and how much money is associated
 with each payment method and processing status.
*/

SELECT
    p.payment_method,
    p.payment_status,
    COUNT(*) AS number_of_payments,
    SUM(p.amount) AS total_payment_value,
    AVG(p.amount) AS average_payment_value,
    MIN(p.amount) AS smallest_payment,
    MAX(p.amount) AS largest_payment,

    ROUND(
        100.0 * SUM(p.amount)
        / NULLIF(
            (
                SELECT SUM(p2.amount)
                FROM payment AS p2
            ),
            0
        ),
        2
    ) AS percentage_of_all_payment_value

FROM payment AS p
GROUP BY
    p.payment_method,
    p.payment_status
ORDER BY
    total_payment_value DESC;