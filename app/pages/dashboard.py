import streamlit as st

from db import get_connection


st.title("Dashboard")
st.write("Quick overview of dealership operations.")


def format_currency(value):
    value = float(value)

    if value >= 1_000_000:
        return f"GH₵ {value / 1_000_000:.2f}M"

    if value >= 1_000:
        return f"GH₵ {value / 1_000:.2f}K"

    return f"GH₵ {value:,.2f}"


connection = None
cursor = None

try:
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    # Available vehicles
    cursor.execute(
        """
        SELECT COUNT(*) AS total
        FROM vehicle
        WHERE vehicle_status = 'Available'
        """
    )
    available_vehicles = cursor.fetchone()["total"]

    # Total customers
    cursor.execute(
        """
        SELECT COUNT(*) AS total
        FROM customer
        """
    )
    total_customers = cursor.fetchone()["total"]

    # Completed sales
    cursor.execute(
        """
        SELECT COUNT(*) AS total
        FROM sale
        WHERE sale_status = 'Completed'
        """
    )
    completed_sales = cursor.fetchone()["total"]

    # Completed sales revenue
    cursor.execute(
        """
        SELECT COALESCE(SUM(total_amount), 0) AS total
        FROM sale
        WHERE sale_status = 'Completed'
        """
    )
    total_revenue = cursor.fetchone()["total"]

    # Outstanding sale balances
    cursor.execute(
        """
        SELECT COALESCE(SUM(outstanding_balance), 0) AS total
        FROM vw_customer_sale_balance
        WHERE sale_status <> 'Cancelled'
        """
    )
    outstanding_balance = cursor.fetchone()["total"]

    # Open service orders
    cursor.execute(
        """
        SELECT COUNT(*) AS total
        FROM service_order
        WHERE service_status IN ('Scheduled', 'In Progress')
        """
    )
    open_services = cursor.fetchone()["total"]

    # Overdue loan installments
    cursor.execute(
        """
        SELECT COUNT(*) AS total
        FROM loan_installment
        WHERE installment_status = 'Overdue'
        """
    )
    overdue_installments = cursor.fetchone()["total"]

    # Low-stock parts
    cursor.execute(
        """
        SELECT COUNT(*) AS total
        FROM part
        WHERE quantity_in_stock <= reorder_level
        """
    )
    low_stock_parts = cursor.fetchone()["total"]


    # --------------------------------------------------
    # DISPLAY METRICS
    # --------------------------------------------------

    row1_col1, row1_col2, row1_col3, row1_col4 = st.columns(4)

    with row1_col1:
        st.metric(
            "Available Vehicles",
            available_vehicles,
        )

    with row1_col2:
        st.metric(
            "Customers",
            total_customers,
        )

    with row1_col3:
        st.metric(
            "Completed Sales",
            completed_sales,
        )

    with row1_col4:
        st.metric(
            "Sales Revenue",
            format_currency(total_revenue),
        )


    row2_col1, row2_col2, row2_col3, row2_col4 = st.columns(4)

    with row2_col1:
        st.metric(
            "Outstanding Balance",
            format_currency(outstanding_balance),
        )

    with row2_col2:
        st.metric(
            "Open Services",
            open_services,
        )

    with row2_col3:
        st.metric(
            "Overdue Instalments",
            overdue_installments,
        )

    with row2_col4:
        st.metric(
            "Low-Stock Parts",
            low_stock_parts,
        )


    # --------------------------------------------------
    # RECENT SALES
    # --------------------------------------------------

    st.divider()
    st.subheader("Recent Sales")

    cursor.execute(
        """
        SELECT
            sale_id AS `Sale ID`,
            customer_name AS Customer,
            sale_date AS `Sale Date`,
            total_amount AS `Total Amount`,
            payment_status AS `Payment Status`
        FROM vw_customer_sale_balance
        ORDER BY sale_date DESC, sale_id DESC
        LIMIT 5
        """
    )

    recent_sales = cursor.fetchall()

    if recent_sales:
        st.dataframe(
            recent_sales,
            width="stretch",
            hide_index=True,
        )
    else:
        st.info("No sales records are available.")


except Exception as error:
    st.error(
        f"Unable to load dashboard: {error}"
    )

finally:
    if cursor is not None:
        cursor.close()

    if (
        connection is not None
        and connection.is_connected()
    ):
        connection.close()