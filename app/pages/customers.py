from datetime import date

import streamlit as st

from db import get_connection


st.title("Customer Management")
st.write("Add, view, and search dealership customers.")


# --------------------------------------------------
# ADD CUSTOMER
# --------------------------------------------------

with st.expander("Add New Customer"):

    with st.form("add_customer_form"):

        col1, col2 = st.columns(2)

        with col1:
            first_name = st.text_input("First Name *")
            phone = st.text_input("Phone *")
            address = st.text_input("Address")

        with col2:
            last_name = st.text_input("Last Name *")
            email = st.text_input("Email")
            registration_date = st.date_input(
                "Registration Date",
                value=date.today(),
            )

        submitted = st.form_submit_button("Add Customer")

        if submitted:

            # Basic validation
            if not first_name.strip():
                st.error("First name is required.")

            elif not last_name.strip():
                st.error("Last name is required.")

            elif not phone.strip():
                st.error("Phone number is required.")

            elif email.strip() and "@" not in email:
                st.error("Please enter a valid email address.")

            else:
                connection = None
                cursor = None

                try:
                    connection = get_connection()
                    cursor = connection.cursor()

                    query = """
                        INSERT INTO customer (
                            first_name,
                            last_name,
                            phone,
                            email,
                            address,
                            registration_date
                        )
                        VALUES (%s, %s, %s, %s, %s, %s)
                    """

                    cursor.execute(
                        query,
                        (
                            first_name.strip(),
                            last_name.strip(),
                            phone.strip(),
                            email.strip() if email.strip() else None,
                            address.strip() if address.strip() else None,
                            registration_date,
                        ),
                    )

                    connection.commit()

                    st.success(
                        f"Customer {first_name.strip()} "
                        f"{last_name.strip()} added successfully."
                    )

                except Exception as error:

                    if connection is not None:
                        connection.rollback()

                    st.error(f"Unable to add customer: {error}")

                finally:

                    if cursor is not None:
                        cursor.close()

                    if (
                        connection is not None
                        and connection.is_connected()
                    ):
                        connection.close()


st.divider()


# --------------------------------------------------
# EDIT CUSTOMER
# --------------------------------------------------

with st.expander("Edit Customer"):

    connection = None
    cursor = None

    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT
                customer_id,
                first_name,
                last_name,
                phone,
                email,
                address,
                registration_date
            FROM customer
            ORDER BY first_name, last_name
            """
        )

        customer_options = cursor.fetchall()

    except Exception as error:
        customer_options = []
        st.error(f"Unable to load customers for editing: {error}")

    finally:
        if cursor is not None:
            cursor.close()

        if connection is not None and connection.is_connected():
            connection.close()

    if customer_options:

        customer_labels = {
            f"{customer['customer_id']} - "
            f"{customer['first_name']} {customer['last_name']}": customer
            for customer in customer_options
        }

        selected_label = st.selectbox(
            "Select Customer",
            options=list(customer_labels.keys()),
            key="edit_customer_select",
        )

        selected_customer = customer_labels[selected_label]

        # Get the ID of the customer currently selected
        customer_id = selected_customer["customer_id"]

        # Give each customer's form its own unique key
        with st.form(f"edit_customer_form_{customer_id}"):

            col1, col2 = st.columns(2)

            with col1:
                edit_first_name = st.text_input(
                    "First Name *",
                    value=selected_customer["first_name"],
                    key=f"edit_first_name_{customer_id}",
                )

                edit_phone = st.text_input(
                    "Phone *",
                    value=selected_customer["phone"],
                    key=f"edit_phone_{customer_id}",
                )

                edit_address = st.text_input(
                    "Address",
                    value=selected_customer["address"] or "",
                    key=f"edit_address_{customer_id}",
                )

            with col2:
                edit_last_name = st.text_input(
                    "Last Name *",
                    value=selected_customer["last_name"],
                    key=f"edit_last_name_{customer_id}",
                )

                edit_email = st.text_input(
                    "Email",
                    value=selected_customer["email"] or "",
                    key=f"edit_email_{customer_id}",
                )

                edit_registration_date = st.date_input(
                    "Registration Date",
                    value=selected_customer["registration_date"],
                    key=f"edit_registration_date_{customer_id}",
                )

            update_submitted = st.form_submit_button("Update Customer")

            if update_submitted:

                if not edit_first_name.strip():
                    st.error("First name is required.")

                elif not edit_last_name.strip():
                    st.error("Last name is required.")

                elif not edit_phone.strip():
                    st.error("Phone number is required.")

                elif edit_email.strip() and "@" not in edit_email:
                    st.error("Please enter a valid email address.")

                else:
                    connection = None
                    cursor = None

                    try:
                        connection = get_connection()
                        cursor = connection.cursor()

                        cursor.execute(
                            """
                            UPDATE customer
                            SET
                                first_name = %s,
                                last_name = %s,
                                phone = %s,
                                email = %s,
                                address = %s,
                                registration_date = %s
                            WHERE customer_id = %s
                            """,
                            (
                                edit_first_name.strip(),
                                edit_last_name.strip(),
                                edit_phone.strip(),
                                edit_email.strip()
                                if edit_email.strip()
                                else None,
                                edit_address.strip()
                                if edit_address.strip()
                                else None,
                                edit_registration_date,
                                customer_id,
                            ),
                        )

                        connection.commit()

                        st.success("Customer updated successfully.")

                    except Exception as error:

                        if connection is not None:
                            connection.rollback()

                        st.error(f"Unable to update customer: {error}")

                    finally:
                        if cursor is not None:
                            cursor.close()

                        if (
                            connection is not None
                            and connection.is_connected()
                        ):
                            connection.close()


# --------------------------------------------------
# DELETE CUSTOMER
# --------------------------------------------------

with st.expander("Delete Customer"):

    connection = None
    cursor = None

    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)

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

        delete_customer_options = cursor.fetchall()

    except Exception as error:
        delete_customer_options = []
        st.error(f"Unable to load customers for deletion: {error}")

    finally:
        if cursor is not None:
            cursor.close()

        if connection is not None and connection.is_connected():
            connection.close()

    if delete_customer_options:

        delete_customer_labels = {
            f"{customer['customer_id']} - "
            f"{customer['first_name']} {customer['last_name']}": customer
            for customer in delete_customer_options
        }

        selected_delete_label = st.selectbox(
            "Select Customer to Delete",
            options=list(delete_customer_labels.keys()),
            key="delete_customer_select",
        )

        selected_delete_customer = delete_customer_labels[
            selected_delete_label
        ]

        delete_customer_id = selected_delete_customer["customer_id"]

        connection = None
        cursor = None

        try:
            connection = get_connection()
            cursor = connection.cursor(dictionary=True)

            cursor.execute(
                """
                SELECT COUNT(*) AS sale_count
                FROM sale
                WHERE customer_id = %s
                """,
                (delete_customer_id,),
            )

            sale_count = cursor.fetchone()["sale_count"]

            cursor.execute(
                """
                SELECT COUNT(*) AS service_count
                FROM service_order
                WHERE customer_id = %s
                """,
                (delete_customer_id,),
            )

            service_count = cursor.fetchone()["service_count"]

        except Exception as error:
            sale_count = 0
            service_count = 0
            st.error(
                f"Unable to check customer transaction history: {error}"
            )

        finally:
            if cursor is not None:
                cursor.close()

            if connection is not None and connection.is_connected():
                connection.close()

        if sale_count > 0 or service_count > 0:

            st.warning(
                "This customer cannot be deleted because they have "
                "existing sales or service history."
            )

            st.write(
                f"Sales records: {sale_count} | "
                f"Service records: {service_count}"
            )

        else:

            st.warning(
                "This customer has no sales or service history. "
                "Deleting the customer will permanently remove the record."
            )

            confirm_delete = st.checkbox(
                "I confirm that I want to delete this customer.",
                key=f"confirm_delete_{delete_customer_id}",
            )

            if st.button(
                "Delete Customer",
                type="primary",
                disabled=not confirm_delete,
                key=f"delete_customer_{delete_customer_id}",
            ):

                connection = None
                cursor = None

                try:
                    connection = get_connection()
                    cursor = connection.cursor()

                    cursor.execute(
                        """
                        DELETE FROM customer
                        WHERE customer_id = %s
                        """,
                        (delete_customer_id,),
                    )

                    connection.commit()

                    st.success("Customer deleted successfully.")
                    st.rerun()

                except Exception as error:

                    if connection is not None:
                        connection.rollback()

                    st.error(f"Unable to delete customer: {error}")

                finally:
                    if cursor is not None:
                        cursor.close()

                    if (
                        connection is not None
                        and connection.is_connected()
                    ):
                        connection.close()

# --------------------------------------------------
# VIEW AND SEARCH CUSTOMERS
# --------------------------------------------------

st.subheader("Customer Records")

search_term = st.text_input(
    "Search customers",
    placeholder="Enter a name, phone number, or email",
)


connection = None
cursor = None

try:
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    if search_term.strip():

        search_value = f"%{search_term.strip()}%"

        query = """
            SELECT
                customer_id AS ID,
                first_name AS `First Name`,
                last_name AS `Last Name`,
                phone AS Phone,
                email AS Email,
                address AS Address,
                registration_date AS `Registration Date`
            FROM customer
            WHERE first_name LIKE %s
               OR last_name LIKE %s
               OR phone LIKE %s
               OR email LIKE %s
            ORDER BY customer_id DESC
        """

        cursor.execute(
            query,
            (
                search_value,
                search_value,
                search_value,
                search_value,
            ),
        )

    else:

        query = """
            SELECT
                customer_id AS ID,
                first_name AS `First Name`,
                last_name AS `Last Name`,
                phone AS Phone,
                email AS Email,
                address AS Address,
                registration_date AS `Registration Date`
            FROM customer
            ORDER BY customer_id DESC
        """

        cursor.execute(query)

    customers = cursor.fetchall()

    st.caption(f"{len(customers)} customer(s) found.")

    if customers:
        st.dataframe(
            customers,
            width="stretch",
            hide_index=True,
        )

    else:
        st.info("No customers found.")

except Exception as error:
    st.error(f"Unable to load customers: {error}")

finally:

    if cursor is not None:
        cursor.close()

    if connection is not None and connection.is_connected():
        connection.close()