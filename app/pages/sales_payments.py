import streamlit as st
import time

from db import get_connection


st.title("Sales & Payments")
st.write("View dealership sales, payment progress, and outstanding balances.")


# --------------------------------------------------
# SALES FILTERS
# --------------------------------------------------

st.subheader("Sales Records")

col1, col2, col3 = st.columns(3)

with col1:
    search_term = st.text_input(
        "Search",
        placeholder="Customer name or Sale ID",
    )

with col2:
    sale_status_filter = st.selectbox(
        "Sale Status",
        options=[
            "All",
            "Pending",
            "Completed",
            "Cancelled",
        ],
    )

with col3:
    payment_status_filter = st.selectbox(
        "Payment Status",
        options=[
            "All",
            "Unpaid",
            "Partially Paid",
            "Paid",
        ],
    )


# --------------------------------------------------
# LOAD SALES
# --------------------------------------------------

connection = None
cursor = None

try:
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    query = """
        SELECT
            sale_id AS `Sale ID`,
            customer_name AS Customer,
            sale_date AS `Sale Date`,
            total_amount AS `Total Amount`,
            amount_paid AS `Amount Paid`,
            outstanding_balance AS `Outstanding Balance`,
            sale_status AS `Sale Status`,
            payment_status AS `Payment Status`
        FROM vw_customer_sale_balance
        WHERE 1 = 1
    """

    parameters = []

    if search_term.strip():

        query += """
            AND (
                customer_name LIKE %s
                OR CAST(sale_id AS CHAR) LIKE %s
            )
        """

        search_value = f"%{search_term.strip()}%"

        parameters.extend(
            [
                search_value,
                search_value,
            ]
        )

    if sale_status_filter != "All":
        query += " AND sale_status = %s"
        parameters.append(sale_status_filter)

    if payment_status_filter != "All":
        query += " AND payment_status = %s"
        parameters.append(payment_status_filter)

    query += """
        ORDER BY sale_date DESC, sale_id DESC
    """

    cursor.execute(query, tuple(parameters))

    sales = cursor.fetchall()

    st.caption(f"{len(sales)} sale(s) found.")

    if sales:

        st.dataframe(
            sales,
            width="stretch",
            hide_index=True,
        )

    else:
        st.info("No sales match the selected filters.")

except Exception as error:
    st.error(f"Unable to load sales: {error}")

finally:

    if cursor is not None:
        cursor.close()

    if connection is not None and connection.is_connected():
        connection.close()


st.divider()

# --------------------------------------------------
# CREATE SALE
# --------------------------------------------------

st.subheader("Create Sale")

connection = None
cursor = None

try:
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    # Customers
    cursor.execute(
        """
        SELECT
            customer_id,
            first_name,
            last_name
        FROM customer
        ORDER BY first_name, last_name
        """
    )

    customers = cursor.fetchall()

    # Salespersons
    cursor.execute(
        """
        SELECT
            sp.employee_id,
            e.first_name,
            e.last_name,
            sp.commission_rate
        FROM salesperson AS sp
        INNER JOIN employee AS e
            ON sp.employee_id = e.employee_id
        ORDER BY e.first_name, e.last_name
        """
    )

    salespersons = cursor.fetchall()

    # Available vehicles
    cursor.execute(
        """
        SELECT
            v.vehicle_id,
            v.vin,
            v.selling_price,
            vm.model_name,
            m.manufacturer_name
        FROM vehicle AS v
        INNER JOIN vehicle_model AS vm
            ON v.model_id = vm.model_id
        INNER JOIN manufacturer AS m
            ON vm.manufacturer_id = m.manufacturer_id
        WHERE v.vehicle_status = 'Available'
          AND NOT EXISTS (
              SELECT 1
              FROM sale_item AS si
              INNER JOIN sale AS s
                  ON si.sale_id = s.sale_id
              WHERE si.vehicle_id = v.vehicle_id
                AND s.sale_status IN ('Pending', 'Completed')
          )
        ORDER BY m.manufacturer_name, vm.model_name
        """
    )

    available_vehicles = cursor.fetchall()

except Exception as error:
    customers = []
    salespersons = []
    available_vehicles = []

    st.error(
        f"Unable to load sale information: {error}"
    )

finally:

    if cursor is not None:
        cursor.close()

    if connection is not None and connection.is_connected():
        connection.close()


if customers and salespersons and available_vehicles:

    customer_labels = {
        f"{customer['customer_id']} - "
        f"{customer['first_name']} {customer['last_name']}": customer
        for customer in customers
    }

    salesperson_labels = {
        f"{salesperson['employee_id']} - "
        f"{salesperson['first_name']} "
        f"{salesperson['last_name']}": salesperson
        for salesperson in salespersons
    }

    vehicle_labels = {
        f"{vehicle['vehicle_id']} - "
        f"{vehicle['manufacturer_name']} "
        f"{vehicle['model_name']} - "
        f"{vehicle['vin']}": vehicle
        for vehicle in available_vehicles
    }

    selected_customer_label = st.selectbox(
        "Customer",
        options=list(customer_labels.keys()),
        key="sale_customer",
    )

    selected_salesperson_label = st.selectbox(
        "Salesperson",
        options=list(salesperson_labels.keys()),
        key="sale_salesperson",
    )

    selected_vehicle_label = st.selectbox(
        "Vehicle",
        options=list(vehicle_labels.keys()),
        key="sale_vehicle",
    )

    selected_customer = customer_labels[
        selected_customer_label
    ]

    selected_salesperson = salesperson_labels[
        selected_salesperson_label
    ]

    selected_vehicle = vehicle_labels[
        selected_vehicle_label
    ]

    vehicle_id = selected_vehicle["vehicle_id"]

    st.write(
        f"Listed Price: "
        f"GH₵ {selected_vehicle['selling_price']:,.2f}"
    )

    with st.form(f"create_sale_form_{vehicle_id}"):

        agreed_price = st.number_input(
            "Agreed Vehicle Price",
            min_value=0.00,
            value=float(selected_vehicle["selling_price"]),
            step=100.00,
            format="%.2f",
        )

        col1, col2 = st.columns(2)

        with col1:
            discount_amount = st.number_input(
                "Discount",
                min_value=0.00,
                value=0.00,
                step=100.00,
                format="%.2f",
            )

        with col2:
            tax_amount = st.number_input(
                "Tax",
                min_value=0.00,
                value=0.00,
                step=100.00,
                format="%.2f",
            )

        total_amount = (
            agreed_price
            - discount_amount
            + tax_amount
        )

        st.write(
            f"**Final Sale Total: GH₵ {total_amount:,.2f}**"
        )

        create_sale_submitted = st.form_submit_button(
            "Create Sale"
        )

        if create_sale_submitted:

            if agreed_price <= 0:
                st.error(
                    "Agreed price must be greater than zero."
                )

            elif discount_amount > agreed_price:
                st.error(
                    "Discount cannot exceed the agreed price."
                )

            elif total_amount <= 0:
                st.error(
                    "Final sale total must be greater than zero."
                )

            else:

                connection = None
                cursor = None

                try:
                    connection = get_connection()
                    cursor = connection.cursor()

                    # Create pending sale
                    cursor.execute(
                        """
                        INSERT INTO sale (
                            customer_id,
                            salesperson_id,
                            sale_date,
                            discount_amount,
                            tax_amount,
                            total_amount,
                            commission_rate_applied,
                            sale_status,
                            payment_status
                        )
                        VALUES (
                            %s,
                            %s,
                            CURDATE(),
                            %s,
                            %s,
                            %s,
                            %s,
                            'Pending',
                            'Unpaid'
                        )
                        """,
                        (
                            selected_customer["customer_id"],
                            selected_salesperson["employee_id"],
                            discount_amount,
                            tax_amount,
                            total_amount,
                            selected_salesperson[
                                "commission_rate"
                            ],
                        ),
                    )

                    sale_id = cursor.lastrowid

                    # Add the selected vehicle
                    cursor.execute(
                        """
                        INSERT INTO sale_item (
                            sale_id,
                            vehicle_id,
                            agreed_price
                        )
                        VALUES (%s, %s, %s)
                        """,
                        (
                            sale_id,
                            vehicle_id,
                            agreed_price,
                        ),
                    )

                    # Reserve the vehicle while the sale is pending
                    cursor.execute(
                        """
                        UPDATE vehicle
                        SET vehicle_status = 'Reserved'
                        WHERE vehicle_id = %s
                          AND vehicle_status = 'Available'
                        """,
                        (vehicle_id,),
                    )

                    if cursor.rowcount != 1:
                        raise ValueError(
                            "The selected vehicle could not be reserved."
                        )

                    connection.commit()

                    st.success(
                        f"Sale {sale_id} created successfully."
                    )

                    st.info(
                        "The sale is currently Pending. "
                        "Complete it below to mark the vehicle as Sold."
                    )
                    time.sleep(3)

                    st.rerun()

                except Exception as error:

                    if connection is not None:
                        connection.rollback()

                    st.error(
                        f"Unable to create sale: {error}"
                    )

                finally:

                    if cursor is not None:
                        cursor.close()

                    if (
                        connection is not None
                        and connection.is_connected()
                    ):
                        connection.close()

else:

    st.warning(
        "A sale cannot be created because customers, "
        "salespersons, or available vehicles are missing."
    )

    # --------------------------------------------------
# COMPLETE SALE
# --------------------------------------------------

with st.expander("Complete Pending Sale"):

    connection = None
    cursor = None

    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT
                s.sale_id,
                CONCAT(
                    c.first_name,
                    ' ',
                    c.last_name
                ) AS customer_name,
                s.total_amount
            FROM sale AS s
            INNER JOIN customer AS c
                ON s.customer_id = c.customer_id
            WHERE s.sale_status = 'Pending'
            ORDER BY s.sale_id DESC
            """
        )

        pending_sales = cursor.fetchall()

    except Exception as error:
        pending_sales = []

        st.error(
            f"Unable to load pending sales: {error}"
        )

    finally:

        if cursor is not None:
            cursor.close()

        if connection is not None and connection.is_connected():
            connection.close()


    if pending_sales:

        pending_sale_labels = {
            f"Sale {sale['sale_id']} - "
            f"{sale['customer_name']} - "
            f"GH₵ {sale['total_amount']:,.2f}": sale
            for sale in pending_sales
        }

        selected_pending_label = st.selectbox(
            "Select Pending Sale",
            options=list(pending_sale_labels.keys()),
            key="complete_sale_select",
        )

        selected_pending_sale = pending_sale_labels[
            selected_pending_label
        ]

        complete_sale_id = selected_pending_sale[
            "sale_id"
        ]

        confirm_complete = st.checkbox(
            "I confirm that this sale should be completed.",
            key=f"confirm_complete_{complete_sale_id}",
        )

        if st.button(
            "Complete Sale",
            disabled=not confirm_complete,
            key=f"complete_sale_{complete_sale_id}",
        ):

            connection = None
            cursor = None

            try:
                connection = get_connection()
                cursor = connection.cursor()

                cursor.callproc(
                    "sp_complete_sale",
                    (complete_sale_id,),
                )

                connection.commit()

                st.success(
                    f"Sale {complete_sale_id} "
                    f"completed successfully."
                )

                st.rerun()

            except Exception as error:

                if connection is not None:
                    connection.rollback()

                st.error(
                    f"Unable to complete sale: {error}"
                )

            finally:

                if cursor is not None:
                    cursor.close()

                if (
                    connection is not None
                    and connection.is_connected()
                ):
                    connection.close()

    else:

        st.info("There are no pending sales.")



# --------------------------------------------------
# RECORD PAYMENT
# --------------------------------------------------

st.subheader("Record Payment")

connection = None
cursor = None

try:
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute(
        """
        SELECT
            sale_id,
            customer_name,
            total_amount,
            amount_paid,
            outstanding_balance,
            sale_status,
            payment_status
        FROM vw_customer_sale_balance
        WHERE sale_status <> 'Cancelled'
          AND outstanding_balance > 0
        ORDER BY sale_id DESC
        """
    )

    payment_sales = cursor.fetchall()

except Exception as error:
    payment_sales = []
    st.error(f"Unable to load sales for payment: {error}")

finally:

    if cursor is not None:
        cursor.close()

    if connection is not None and connection.is_connected():
        connection.close()


if payment_sales:

    sale_labels = {
        f"Sale {sale['sale_id']} - {sale['customer_name']}": sale
        for sale in payment_sales
    }

    selected_sale_label = st.selectbox(
        "Select Sale",
        options=list(sale_labels.keys()),
        key="payment_sale_select",
    )

    selected_sale = sale_labels[selected_sale_label]

    sale_id = selected_sale["sale_id"]

    # Display current payment information
    col1, col2, col3 = st.columns(3)

    with col1:
        st.metric(
            "Sale Total",
            f"GH₵ {selected_sale['total_amount']:,.2f}",
        )

    with col2:
        st.metric(
            "Amount Paid",
            f"GH₵ {selected_sale['amount_paid']:,.2f}",
        )

    with col3:
        st.metric(
            "Outstanding Balance",
            f"GH₵ {selected_sale['outstanding_balance']:,.2f}",
        )

    with st.form(f"record_payment_form_{sale_id}"):

        payment_amount = st.number_input(
            "Payment Amount",
            min_value=0.00,
            step=100.00,
            format="%.2f",
        )

        payment_method = st.selectbox(
            "Payment Method",
            options=[
                "Cash",
                "Card",
                "Transfer",
                "Mobile Money",
            ],
        )

        reference_number = st.text_input(
            "Reference Number",
            placeholder="Optional for cash payments",
        )

        payment_submitted = st.form_submit_button(
            "Record Payment"
        )

        if payment_submitted:

            if payment_amount <= 0:
                st.error(
                    "Payment amount must be greater than zero."
                )

            elif payment_amount > selected_sale["outstanding_balance"]:
                st.error(
                    "Payment cannot exceed the outstanding balance."
                )

            else:

                connection = None
                cursor = None

                try:
                    connection = get_connection()
                    cursor = connection.cursor()

                    cursor.callproc(
                        "sp_record_payment",
                        (
                            sale_id,
                            payment_amount,
                            payment_method,
                            reference_number.strip()
                            if reference_number.strip()
                            else None,
                        ),
                    )

                    connection.commit()

                    st.success(
                        "Payment recorded successfully."
                    )

                    st.rerun()

                except Exception as error:

                    if connection is not None:
                        connection.rollback()

                    st.error(
                        f"Unable to record payment: {error}"
                    )

                finally:

                    if cursor is not None:
                        cursor.close()

                    if (
                        connection is not None
                        and connection.is_connected()
                    ):
                        connection.close()

else:
    st.info(
        "There are no outstanding sales available for payment."
    )

    st.divider()

# --------------------------------------------------
# PAYMENT HISTORY
# --------------------------------------------------

st.subheader("Payment History")

col1, col2 = st.columns(2)

with col1:
    payment_search = st.text_input(
        "Search Payments",
        placeholder="Customer name, Sale ID, or reference number",
        key="payment_history_search",
    )

with col2:
    payment_method_filter = st.selectbox(
        "Payment Method",
        options=[
            "All",
            "Cash",
            "Card",
            "Transfer",
            "Mobile Money",
        ],
        key="payment_history_method",
    )


connection = None
cursor = None

try:
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    query = """
        SELECT
            p.payment_id AS `Payment ID`,
            p.sale_id AS `Sale ID`,
            CONCAT(
                c.first_name,
                ' ',
                c.last_name
            ) AS Customer,
            p.payment_date AS `Payment Date`,
            p.amount AS Amount,
            p.payment_method AS `Payment Method`,
            p.reference_number AS `Reference Number`,
            p.payment_status AS Status
        FROM payment AS p
        INNER JOIN sale AS s
            ON p.sale_id = s.sale_id
        INNER JOIN customer AS c
            ON s.customer_id = c.customer_id
        WHERE 1 = 1
    """

    parameters = []

    if payment_search.strip():

        search_value = f"%{payment_search.strip()}%"

        query += """
            AND (
                CONCAT(
                    c.first_name,
                    ' ',
                    c.last_name
                ) LIKE %s
                OR CAST(p.sale_id AS CHAR) LIKE %s
                OR p.reference_number LIKE %s
            )
        """

        parameters.extend(
            [
                search_value,
                search_value,
                search_value,
            ]
        )

    if payment_method_filter != "All":
        query += """
            AND p.payment_method = %s
        """
        parameters.append(payment_method_filter)

    query += """
        ORDER BY p.payment_date DESC, p.payment_id DESC
    """

    cursor.execute(
        query,
        tuple(parameters),
    )

    payments = cursor.fetchall()

    st.caption(
        f"{len(payments)} payment(s) found."
    )

    if payments:

        st.dataframe(
            payments,
            width="stretch",
            hide_index=True,
        )

    else:

        st.info(
            "No payments match the selected criteria."
        )

except Exception as error:

    st.error(
        f"Unable to load payment history: {error}"
    )

finally:

    if cursor is not None:
        cursor.close()

    if (
        connection is not None
        and connection.is_connected()
    ):
        connection.close()