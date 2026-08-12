import csv
import io

import streamlit as st

from db import get_connection


st.title("Reports")
st.write("View and export dealership management reports.")


# --------------------------------------------------
# REPORT SELECTION
# --------------------------------------------------

report_name = st.selectbox(
    "Select Report",
    options=[
        "Monthly Sales Summary",
        "Customer Sale Balances",
        "Salesperson Performance",
        "Available Vehicles",
        "Vehicle Service History",
    ],
)


connection = None
cursor = None
report_data = []

try:
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    # --------------------------------------------------
    # MONTHLY SALES SUMMARY
    # --------------------------------------------------

    if report_name == "Monthly Sales Summary":

        st.subheader("Monthly Sales Summary")

        cursor.execute(
            """
            SELECT DISTINCT sale_year
            FROM vw_monthly_sales_summary
            ORDER BY sale_year DESC
            """
        )

        years = [
            row["sale_year"]
            for row in cursor.fetchall()
        ]

        if years:

            selected_year = st.selectbox(
                "Year",
                options=years,
            )

            cursor.execute(
                """
                SELECT
                    sales_month AS Month,
                    completed_sales AS `Completed Sales`,
                    total_sales_revenue AS `Sales Revenue`,
                    total_discounts AS Discounts,
                    total_tax AS Tax,
                    average_sale_value AS `Average Sale Value`
                FROM vw_monthly_sales_summary
                WHERE sale_year = %s
                ORDER BY sale_month
                """,
                (selected_year,),
            )

            report_data = cursor.fetchall()

        else:
            st.info("No monthly sales information is available.")

    # --------------------------------------------------
    # CUSTOMER SALE BALANCES
    # --------------------------------------------------

    elif report_name == "Customer Sale Balances":

        st.subheader("Customer Sale Balances")

        payment_filter = st.selectbox(
            "Payment Status",
            options=[
                "All",
                "Unpaid",
                "Partially Paid",
                "Paid",
            ],
        )

        query = """
            SELECT
                sale_id AS `Sale ID`,
                customer_name AS Customer,
                sale_date AS `Sale Date`,
                total_amount AS `Sale Total`,
                amount_paid AS `Amount Paid`,
                outstanding_balance AS `Outstanding Balance`,
                sale_status AS `Sale Status`,
                payment_status AS `Payment Status`
            FROM vw_customer_sale_balance
            WHERE 1 = 1
        """

        parameters = []

        if payment_filter != "All":
            query += " AND payment_status = %s"
            parameters.append(payment_filter)

        query += " ORDER BY sale_id DESC"

        cursor.execute(
            query,
            tuple(parameters),
        )

        report_data = cursor.fetchall()

    # --------------------------------------------------
    # SALESPERSON PERFORMANCE
    # --------------------------------------------------

    elif report_name == "Salesperson Performance":

        st.subheader("Salesperson Performance")

        cursor.execute(
            """
            SELECT
                salesperson_id AS `Salesperson ID`,
                salesperson_name AS Salesperson,
                completed_sales AS `Completed Sales`,
                total_sales_value AS `Sales Value`,
                total_commission_earned AS `Commission Earned`,
                sales_target AS `Sales Target`,
                target_status AS `Target Status`
            FROM vw_salesperson_performance
            ORDER BY total_sales_value DESC
            """
        )

        report_data = cursor.fetchall()

    # --------------------------------------------------
    # AVAILABLE VEHICLES
    # --------------------------------------------------

    elif report_name == "Available Vehicles":

        st.subheader("Available Vehicles")

        cursor.execute(
            """
            SELECT DISTINCT manufacturer_name
            FROM vw_available_vehicles
            ORDER BY manufacturer_name
            """
        )

        manufacturers = [
            row["manufacturer_name"]
            for row in cursor.fetchall()
        ]

        manufacturer_filter = st.selectbox(
            "Manufacturer",
            options=["All"] + manufacturers,
        )

        query = """
            SELECT
                vehicle_id AS `Vehicle ID`,
                vin AS VIN,
                manufacturer_name AS Manufacturer,
                model_name AS Model,
                body_type AS `Body Type`,
                fuel_type AS `Fuel Type`,
                transmission AS Transmission,
                manufacture_year AS Year,
                colour AS Colour,
                mileage AS Mileage,
                selling_price AS `Selling Price`,
                vehicle_status AS Status
            FROM vw_available_vehicles
            WHERE 1 = 1
        """

        parameters = []

        if manufacturer_filter != "All":
            query += " AND manufacturer_name = %s"
            parameters.append(manufacturer_filter)

        query += """
            ORDER BY manufacturer_name, model_name
        """

        cursor.execute(
            query,
            tuple(parameters),
        )

        report_data = cursor.fetchall()

    # --------------------------------------------------
    # VEHICLE SERVICE HISTORY
    # --------------------------------------------------

    elif report_name == "Vehicle Service History":

        st.subheader("Vehicle Service History")

        service_status_filter = st.selectbox(
            "Service Status",
            options=[
                "All",
                "Scheduled",
                "In Progress",
                "Completed",
                "Cancelled",
            ],
        )

        query = """
            SELECT
                service_order_id AS `Service Order ID`,
                service_date AS `Service Date`,
                customer_name AS Customer,
                manufacturer_name AS Manufacturer,
                model_name AS Model,
                vin AS VIN,
                mechanic_name AS Mechanic,
                service_description AS Description,
                labour_charge AS `Labour Charge`,
                total_parts_cost AS `Parts Cost`,
                total_service_cost AS `Total Service Cost`,
                service_status AS Status
            FROM vw_vehicle_service_history
            WHERE 1 = 1
        """

        parameters = []

        if service_status_filter != "All":
            query += " AND service_status = %s"
            parameters.append(service_status_filter)

        query += """
            ORDER BY service_date DESC, service_order_id DESC
        """

        cursor.execute(
            query,
            tuple(parameters),
        )

        report_data = cursor.fetchall()


except Exception as error:

    st.error(
        f"Unable to load report: {error}"
    )

finally:

    if cursor is not None:
        cursor.close()

    if (
        connection is not None
        and connection.is_connected()
    ):
        connection.close()


# --------------------------------------------------
# DISPLAY REPORT
# --------------------------------------------------

if report_data:

    st.caption(
        f"{len(report_data)} record(s) found."
    )

    st.dataframe(
        report_data,
        width="stretch",
        hide_index=True,
    )


    # --------------------------------------------------
    # CSV EXPORT
    # --------------------------------------------------

    csv_buffer = io.StringIO()

    writer = csv.DictWriter(
        csv_buffer,
        fieldnames=report_data[0].keys(),
    )

    writer.writeheader()
    writer.writerows(report_data)

    file_name = (
        report_name
        .lower()
        .replace(" ", "_")
        + ".csv"
    )

    st.download_button(
        label="Download CSV",
        data=csv_buffer.getvalue(),
        file_name=file_name,
        mime="text/csv",
    )

else:

    st.info(
        "No records are available for this report."
    )