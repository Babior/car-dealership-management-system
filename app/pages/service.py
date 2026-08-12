import pandas as pd
import streamlit as st

from auth import require_permission
from db import get_connection

require_permission("service")


st.title("Service Management")
st.write("Create, view, filter and update dealership service orders.")


# =====================================================
# LOAD CUSTOMERS
# =====================================================

def load_customers():
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    query = """
        SELECT
            customer_id,
            first_name,
            last_name
        FROM customer
        ORDER BY first_name, last_name
    """

    cursor.execute(query)
    customers = cursor.fetchall()

    cursor.close()
    connection.close()

    return customers


# =====================================================
# LOAD VEHICLES
# =====================================================

def load_vehicles():
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    query = """
        SELECT
            v.vehicle_id,
            v.vin,
            m.manufacturer_name,
            vm.model_name
        FROM vehicle AS v
        INNER JOIN vehicle_model AS vm
            ON v.model_id = vm.model_id
        INNER JOIN manufacturer AS m
            ON vm.manufacturer_id = m.manufacturer_id
        ORDER BY v.vehicle_id
    """

    cursor.execute(query)
    vehicles = cursor.fetchall()

    cursor.close()
    connection.close()

    return vehicles


# =====================================================
# LOAD MECHANICS
# =====================================================

def load_mechanics():
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    query = """
        SELECT
            me.employee_id,
            e.first_name,
            e.last_name,
            me.specialization
        FROM mechanic AS me
        INNER JOIN employee AS e
            ON me.employee_id = e.employee_id
        ORDER BY e.first_name, e.last_name
    """

    cursor.execute(query)
    mechanics = cursor.fetchall()

    cursor.close()
    connection.close()

    return mechanics


# =====================================================
# LOAD SERVICE ORDERS
# =====================================================

def load_service_orders(status_filter="All"):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    query = """
        SELECT
            so.service_order_id,
            CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
            v.vin,
            CONCAT(mf.manufacturer_name, ' ', vm.model_name) AS vehicle,
            CONCAT(e.first_name, ' ', e.last_name) AS mechanic_name,
            so.service_date,
            so.current_mileage,
            so.service_description,
            so.labour_charge,
            so.service_status
        FROM service_order AS so
        INNER JOIN customer AS c
            ON so.customer_id = c.customer_id
        INNER JOIN vehicle AS v
            ON so.vehicle_id = v.vehicle_id
        INNER JOIN vehicle_model AS vm
            ON v.model_id = vm.model_id
        INNER JOIN manufacturer AS mf
            ON vm.manufacturer_id = mf.manufacturer_id
        INNER JOIN mechanic AS me
            ON so.mechanic_id = me.employee_id
        INNER JOIN employee AS e
            ON me.employee_id = e.employee_id
        WHERE 1 = 1
    """

    parameters = []

    if status_filter != "All":
        query += " AND so.service_status = %s"
        parameters.append(status_filter)

    query += " ORDER BY so.service_order_id"

    cursor.execute(query, parameters)
    records = cursor.fetchall()

    cursor.close()
    connection.close()

    return records


# =====================================================
# LOAD ONE SERVICE ORDER
# =====================================================

def load_service_order(service_order_id):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    query = """
        SELECT
            service_order_id,
            customer_id,
            vehicle_id,
            mechanic_id,
            service_date,
            current_mileage,
            service_description,
            labour_charge,
            service_status
        FROM service_order
        WHERE service_order_id = %s
    """

    cursor.execute(query, (service_order_id,))
    record = cursor.fetchone()

    cursor.close()
    connection.close()

    return record


# =====================================================
# CREATE SERVICE ORDER
# =====================================================

def create_service_order(
    customer_id,
    vehicle_id,
    mechanic_id,
    service_date,
    current_mileage,
    service_description,
    labour_charge,
    service_status
):
    connection = get_connection()
    cursor = connection.cursor()

    try:
        query = """
            INSERT INTO service_order (
                customer_id,
                vehicle_id,
                mechanic_id,
                service_date,
                current_mileage,
                service_description,
                labour_charge,
                service_status
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """

        values = (
            customer_id,
            vehicle_id,
            mechanic_id,
            service_date,
            current_mileage,
            service_description,
            labour_charge,
            service_status
        )

        cursor.execute(query, values)
        connection.commit()

    except Exception:
        connection.rollback()
        raise

    finally:
        cursor.close()
        connection.close()


# =====================================================
# UPDATE SERVICE ORDER
# =====================================================

def update_service_order(
    service_order_id,
    customer_id,
    vehicle_id,
    mechanic_id,
    service_date,
    current_mileage,
    service_description,
    labour_charge,
    service_status
):
    connection = get_connection()
    cursor = connection.cursor()

    try:
        query = """
            UPDATE service_order
            SET
                customer_id = %s,
                vehicle_id = %s,
                mechanic_id = %s,
                service_date = %s,
                current_mileage = %s,
                service_description = %s,
                labour_charge = %s,
                service_status = %s
            WHERE service_order_id = %s
        """

        values = (
            customer_id,
            vehicle_id,
            mechanic_id,
            service_date,
            current_mileage,
            service_description,
            labour_charge,
            service_status,
            service_order_id
        )

        cursor.execute(query, values)
        connection.commit()

    except Exception:
        connection.rollback()
        raise

    finally:
        cursor.close()
        connection.close()


# =====================================================
# LOAD LOOKUP DATA
# =====================================================

try:
    customers = load_customers()
    vehicles = load_vehicles()
    mechanics = load_mechanics()

    customer_options = {
        f"{customer['customer_id']} - "
        f"{customer['first_name']} {customer['last_name']}":
            customer["customer_id"]
        for customer in customers
    }

    vehicle_options = {
        f"{vehicle['vehicle_id']} - "
        f"{vehicle['vin']} - "
        f"{vehicle['manufacturer_name']} {vehicle['model_name']}":
            vehicle["vehicle_id"]
        for vehicle in vehicles
    }

    mechanic_options = {
        f"{mechanic['employee_id']} - "
        f"{mechanic['first_name']} {mechanic['last_name']} - "
        f"{mechanic['specialization']}":
            mechanic["employee_id"]
        for mechanic in mechanics
    }

except Exception as error:
    customers = []
    vehicles = []
    mechanics = []

    customer_options = {}
    vehicle_options = {}
    mechanic_options = {}

    st.error(
        f"Unable to load service lookup data: {error}"
    )


# =====================================================
# CREATE SERVICE ORDER FORM
# =====================================================

st.subheader("Create Service Order")

if customers and vehicles and mechanics:

    with st.form("create_service_order_form"):

        selected_customer = st.selectbox(
            "Customer",
            options=list(customer_options.keys())
        )

        selected_vehicle = st.selectbox(
            "Vehicle",
            options=list(vehicle_options.keys())
        )

        selected_mechanic = st.selectbox(
            "Mechanic",
            options=list(mechanic_options.keys())
        )

        service_date = st.date_input(
            "Service date"
        )

        current_mileage = st.number_input(
            "Current mileage",
            min_value=0,
            step=1
        )

        service_description = st.text_area(
            "Service description",
            max_chars=500,
            placeholder="Describe the service work required"
        )

        labour_charge = st.number_input(
            "Labour charge",
            min_value=0.0,
            step=50.0,
            format="%.2f"
        )

        service_status = st.selectbox(
            "Service status",
            [
                "Scheduled",
                "In Progress",
                "Completed",
                "Cancelled"
            ]
        )

        create_button = st.form_submit_button(
            "Create Service Order"
        )

        if create_button:

            service_description = (
                service_description.strip()
            )

            if not service_description:
                st.error(
                    "Service description is required."
                )

            else:

                customer_id = (
                    customer_options[
                        selected_customer
                    ]
                )

                vehicle_id = (
                    vehicle_options[
                        selected_vehicle
                    ]
                )

                mechanic_id = (
                    mechanic_options[
                        selected_mechanic
                    ]
                )

                try:
                    create_service_order(
                        customer_id,
                        vehicle_id,
                        mechanic_id,
                        service_date,
                        int(current_mileage),
                        service_description,
                        float(labour_charge),
                        service_status
                    )

                    st.success(
                        "Service order created successfully."
                    )

                    st.rerun()

                except Exception as error:
                    st.error(
                        f"Unable to create service order: {error}"
                    )

else:
    st.warning(
        "Customer, vehicle and mechanic records "
        "must exist before creating a service order."
    )


# =====================================================
# SERVICE ORDER LIST AND FILTER
# =====================================================

st.divider()
st.subheader("Service Orders")

status_filter = st.selectbox(
    "Filter by service status",
    [
        "All",
        "Scheduled",
        "In Progress",
        "Completed",
        "Cancelled"
    ],
    key="service_status_filter"
)

try:
    service_orders = load_service_orders(
        status_filter
    )

    if service_orders:

        st.dataframe(
            pd.DataFrame(service_orders),
            use_container_width=True,
            hide_index=True
        )

        st.success(
            f"{len(service_orders)} service order(s) found."
        )

    else:
        st.info(
            "No service orders matched the selected status."
        )

except Exception as error:
    service_orders = []

    st.error(
        f"Unable to load service orders: {error}"
    )


# =====================================================
# EDIT SERVICE ORDER
# =====================================================

st.divider()
st.subheader("Edit Service Order")

try:
    all_service_orders = load_service_orders()

    if all_service_orders:

        order_options = {
            f"Order {order['service_order_id']} - "
            f"{order['customer_name']} - "
            f"{order['vehicle']}":
                order["service_order_id"]
            for order in all_service_orders
        }

        selected_order_label = st.selectbox(
            "Select service order",
            options=list(order_options.keys()),
            key="edit_service_order_selector"
        )

        selected_order_id = (
            order_options[
                selected_order_label
            ]
        )

        selected_order = load_service_order(
            selected_order_id
        )

        customer_labels = list(
            customer_options.keys()
        )

        vehicle_labels = list(
            vehicle_options.keys()
        )

        mechanic_labels = list(
            mechanic_options.keys()
        )

        customer_ids = list(
            customer_options.values()
        )

        vehicle_ids = list(
            vehicle_options.values()
        )

        mechanic_ids = list(
            mechanic_options.values()
        )

        current_customer_index = (
            customer_ids.index(
                selected_order["customer_id"]
            )
        )

        current_vehicle_index = (
            vehicle_ids.index(
                selected_order["vehicle_id"]
            )
        )

        current_mechanic_index = (
            mechanic_ids.index(
                selected_order["mechanic_id"]
            )
        )

        status_values = [
            "Scheduled",
            "In Progress",
            "Completed",
            "Cancelled"
        ]

        current_status_index = (
            status_values.index(
                selected_order["service_status"]
            )
        )

        with st.form("edit_service_order_form"):

            edit_customer = st.selectbox(
                "Customer",
                options=customer_labels,
                index=current_customer_index
            )

            edit_vehicle = st.selectbox(
                "Vehicle",
                options=vehicle_labels,
                index=current_vehicle_index
            )

            edit_mechanic = st.selectbox(
                "Mechanic",
                options=mechanic_labels,
                index=current_mechanic_index
            )

            edit_service_date = st.date_input(
                "Service date",
                value=selected_order[
                    "service_date"
                ]
            )

            edit_mileage = st.number_input(
                "Current mileage",
                min_value=0,
                value=int(
                    selected_order[
                        "current_mileage"
                    ]
                ),
                step=1
            )

            edit_description = st.text_area(
                "Service description",
                value=selected_order[
                    "service_description"
                ],
                max_chars=500
            )

            edit_labour_charge = st.number_input(
                "Labour charge",
                min_value=0.0,
                value=float(
                    selected_order[
                        "labour_charge"
                    ]
                ),
                step=50.0,
                format="%.2f"
            )

            edit_status = st.selectbox(
                "Service status",
                status_values,
                index=current_status_index
            )

            update_button = st.form_submit_button(
                "Update Service Order"
            )

            if update_button:

                edit_description = (
                    edit_description.strip()
                )

                if not edit_description:
                    st.error(
                        "Service description is required."
                    )

                else:

                    edit_customer_id = (
                        customer_options[
                            edit_customer
                        ]
                    )

                    edit_vehicle_id = (
                        vehicle_options[
                            edit_vehicle
                        ]
                    )

                    edit_mechanic_id = (
                        mechanic_options[
                            edit_mechanic
                        ]
                    )

                    try:
                        update_service_order(
                            selected_order_id,
                            edit_customer_id,
                            edit_vehicle_id,
                            edit_mechanic_id,
                            edit_service_date,
                            int(edit_mileage),
                            edit_description,
                            float(
                                edit_labour_charge
                            ),
                            edit_status
                        )

                        st.success(
                            "Service order updated successfully."
                        )

                        st.rerun()

                    except Exception as error:
                        st.error(
                            f"Unable to update service order: {error}"
                        )

    else:
        st.info(
            "No service orders are available to edit."
        )

except Exception as error:
    st.error(
        f"Unable to load service editing section: {error}"
    )