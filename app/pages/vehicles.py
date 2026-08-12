import pandas as pd
import streamlit as st

from auth import require_permission
from db import get_connection

require_permission("vehicles")

st.title("Vehicle Management")
st.write("View, search, add and update dealership vehicles.")


# =====================================================
# LOAD VEHICLES
# =====================================================

def load_vehicles(search_text="", status_filter="All"):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    query = """
        SELECT
            v.vehicle_id,
            v.model_id,
            v.vin,
            m.manufacturer_name,
            vm.model_name,
            v.manufacture_year,
            v.colour,
            v.mileage,
            v.purchase_price,
            v.selling_price,
            v.vehicle_status
        FROM vehicle AS v
        INNER JOIN vehicle_model AS vm
            ON v.model_id = vm.model_id
        INNER JOIN manufacturer AS m
            ON vm.manufacturer_id = m.manufacturer_id
        WHERE 1 = 1
    """

    parameters = []

    if search_text:
        query += """
            AND (
                v.vin LIKE %s
                OR vm.model_name LIKE %s
                OR m.manufacturer_name LIKE %s
            )
        """

        search_value = f"%{search_text}%"

        parameters.extend([
            search_value,
            search_value,
            search_value
        ])

    if status_filter != "All":
        query += " AND v.vehicle_status = %s"
        parameters.append(status_filter)

    query += " ORDER BY v.vehicle_id"

    cursor.execute(query, parameters)
    records = cursor.fetchall()

    cursor.close()
    connection.close()

    return records


# =====================================================
# LOAD ONE VEHICLE
# =====================================================

def load_vehicle(vehicle_id):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    query = """
        SELECT
            vehicle_id,
            model_id,
            vin,
            manufacture_year,
            colour,
            mileage,
            purchase_price,
            selling_price,
            vehicle_status
        FROM vehicle
        WHERE vehicle_id = %s
    """

    cursor.execute(query, (vehicle_id,))
    vehicle = cursor.fetchone()

    cursor.close()
    connection.close()

    return vehicle


# =====================================================
# LOAD VEHICLE MODELS
# =====================================================

def load_vehicle_models():
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    query = """
        SELECT
            vm.model_id,
            m.manufacturer_name,
            vm.model_name
        FROM vehicle_model AS vm
        INNER JOIN manufacturer AS m
            ON vm.manufacturer_id = m.manufacturer_id
        ORDER BY m.manufacturer_name, vm.model_name
    """

    cursor.execute(query)
    models = cursor.fetchall()

    cursor.close()
    connection.close()

    return models


# =====================================================
# ADD VEHICLE
# =====================================================

def add_vehicle(
    model_id,
    vin,
    manufacture_year,
    colour,
    mileage,
    purchase_price,
    selling_price,
    vehicle_status
):
    connection = get_connection()
    cursor = connection.cursor()

    try:
        query = """
            INSERT INTO vehicle (
                model_id,
                vin,
                manufacture_year,
                colour,
                mileage,
                purchase_price,
                selling_price,
                vehicle_status
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """

        values = (
            model_id,
            vin,
            manufacture_year,
            colour,
            mileage,
            purchase_price,
            selling_price,
            vehicle_status
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
# UPDATE VEHICLE
# =====================================================

def update_vehicle(
    vehicle_id,
    model_id,
    vin,
    manufacture_year,
    colour,
    mileage,
    purchase_price,
    selling_price,
    vehicle_status
):
    connection = get_connection()
    cursor = connection.cursor()

    try:
        query = """
            UPDATE vehicle
            SET
                model_id = %s,
                vin = %s,
                manufacture_year = %s,
                colour = %s,
                mileage = %s,
                purchase_price = %s,
                selling_price = %s,
                vehicle_status = %s
            WHERE vehicle_id = %s
        """

        values = (
            model_id,
            vin,
            manufacture_year,
            colour,
            mileage,
            purchase_price,
            selling_price,
            vehicle_status,
            vehicle_id
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
# DELETE VEHICLE
# =====================================================

def delete_vehicle(vehicle_id):
    connection = get_connection()
    cursor = connection.cursor()

    try:
        query = """
            DELETE FROM vehicle
            WHERE vehicle_id = %s
        """

        cursor.execute(query, (vehicle_id,))
        connection.commit()

    except Exception:
        connection.rollback()
        raise

    finally:
        cursor.close()
        connection.close()


# =====================================================
# VEHICLE MODELS
# =====================================================

try:
    vehicle_models = load_vehicle_models()

    model_options = {
        f"{model['manufacturer_name']} - {model['model_name']}":
            model["model_id"]
        for model in vehicle_models
    }

    model_id_to_name = {
        model["model_id"]:
            f"{model['manufacturer_name']} - {model['model_name']}"
        for model in vehicle_models
    }

except Exception as error:
    vehicle_models = []
    model_options = {}
    model_id_to_name = {}

    st.error(
        f"Unable to load vehicle models: {error}"
    )


# =====================================================
# ADD VEHICLE FORM
# =====================================================

st.subheader("Add Vehicle")

if vehicle_models:

    with st.form("add_vehicle_form"):

        selected_model = st.selectbox(
            "Vehicle model",
            options=list(model_options.keys())
        )

        vin = st.text_input(
            "VIN",
            max_chars=17,
            placeholder="Enter 17-character VIN"
        )

        manufacture_year = st.number_input(
            "Manufacture year",
            min_value=1900,
            max_value=2100,
            step=1
        )

        colour = st.text_input(
            "Colour",
            max_chars=40
        )

        mileage = st.number_input(
            "Mileage",
            min_value=0,
            step=1
        )

        purchase_price = st.number_input(
            "Purchase price",
            min_value=0.0,
            step=100.0,
            format="%.2f"
        )

        selling_price = st.number_input(
            "Selling price",
            min_value=0.0,
            step=100.0,
            format="%.2f"
        )

        vehicle_status = st.selectbox(
            "Vehicle status",
            [
                "Available",
                "Reserved",
                "Sold",
                "In Service"
            ]
        )

        submit_vehicle = st.form_submit_button(
            "Add Vehicle"
        )

        if submit_vehicle:

            vin = vin.strip().upper()
            colour = colour.strip()

            if len(vin) != 17:
                st.error(
                    "VIN must contain exactly 17 characters."
                )

            elif not colour:
                st.error(
                    "Colour is required."
                )

            else:
                model_id = model_options[selected_model]

                try:
                    add_vehicle(
                        model_id,
                        vin,
                        int(manufacture_year),
                        colour,
                        int(mileage),
                        float(purchase_price),
                        float(selling_price),
                        vehicle_status
                    )

                    st.success(
                        f"Vehicle with VIN {vin} was added successfully."
                    )

                    st.rerun()

                except Exception:
                    st.error(
                        "Unable to add vehicle. "
                        "Check that the VIN is unique and "
                        "that all vehicle information is valid."
                    )

else:
    st.warning(
        "No vehicle models are available."
    )


# =====================================================
# VEHICLE SEARCH AND FILTER
# =====================================================

st.divider()
st.subheader("Vehicle Records")

search_column, status_column = st.columns(2)

with search_column:
    search_text = st.text_input(
        "Search",
        placeholder="Enter VIN, manufacturer, or model"
    )

with status_column:
    status_filter = st.selectbox(
        "Vehicle status",
        [
            "All",
            "Available",
            "Reserved",
            "Sold",
            "In Service"
        ],
        key="vehicle_record_status_filter"
    )


try:
    vehicles = load_vehicles(
        search_text,
        status_filter
    )

    if vehicles:

        display_vehicles = []

        for vehicle in vehicles:
            display_vehicle = vehicle.copy()

            display_vehicle.pop(
                "model_id",
                None
            )

            display_vehicles.append(
                display_vehicle
            )

        st.dataframe(
            pd.DataFrame(display_vehicles),
            use_container_width=True,
            hide_index=True
        )

        st.success(
            f"{len(vehicles)} vehicle record(s) found."
        )

    else:
        st.info(
            "No vehicle records matched your search."
        )

except Exception as error:
    vehicles = []

    st.error(
        f"Unable to load vehicles: {error}"
    )


# =====================================================
# EDIT VEHICLE
# =====================================================

st.divider()
st.subheader("Edit Vehicle")

try:
    all_vehicles = load_vehicles()

    if all_vehicles:

        vehicle_options = {
            f"{vehicle['vehicle_id']} - "
            f"{vehicle['vin']} - "
            f"{vehicle['manufacturer_name']} "
            f"{vehicle['model_name']}":
                vehicle["vehicle_id"]
            for vehicle in all_vehicles
        }

        selected_vehicle_label = st.selectbox(
            "Select vehicle to edit",
            options=list(vehicle_options.keys()),
            key="edit_vehicle_selector"
        )

        selected_vehicle_id = vehicle_options[
            selected_vehicle_label
        ]

        selected_vehicle = load_vehicle(
            selected_vehicle_id
        )

        current_model_name = model_id_to_name.get(
            selected_vehicle["model_id"]
        )

        model_names = list(
            model_options.keys()
        )

        if current_model_name in model_names:
            current_model_index = model_names.index(
                current_model_name
            )
        else:
            current_model_index = 0

        with st.form("edit_vehicle_form"):

            edit_model = st.selectbox(
                "Vehicle model",
                options=model_names,
                index=current_model_index
            )

            edit_vin = st.text_input(
                "VIN",
                value=selected_vehicle["vin"],
                max_chars=17
            )

            edit_year = st.number_input(
                "Manufacture year",
                min_value=1900,
                max_value=2100,
                value=int(
                    selected_vehicle[
                        "manufacture_year"
                    ]
                ),
                step=1
            )

            edit_colour = st.text_input(
                "Colour",
                value=selected_vehicle[
                    "colour"
                ],
                max_chars=40
            )

            edit_mileage = st.number_input(
                "Mileage",
                min_value=0,
                value=int(
                    selected_vehicle[
                        "mileage"
                    ]
                ),
                step=1
            )

            edit_purchase_price = st.number_input(
                "Purchase price",
                min_value=0.0,
                value=float(
                    selected_vehicle[
                        "purchase_price"
                    ]
                ),
                step=100.0,
                format="%.2f"
            )

            edit_selling_price = st.number_input(
                "Selling price",
                min_value=0.0,
                value=float(
                    selected_vehicle[
                        "selling_price"
                    ]
                ),
                step=100.0,
                format="%.2f"
            )

            status_values = [
                "Available",
                "Reserved",
                "Sold",
                "In Service"
            ]

            current_status_index = (
                status_values.index(
                    selected_vehicle[
                        "vehicle_status"
                    ]
                )
            )

            edit_status = st.selectbox(
                "Vehicle status",
                status_values,
                index=current_status_index
            )

            update_button = st.form_submit_button(
                "Update Vehicle"
            )

            if update_button:

                edit_vin = (
                    edit_vin.strip().upper()
                )

                edit_colour = (
                    edit_colour.strip()
                )

                if len(edit_vin) != 17:
                    st.error(
                        "VIN must contain exactly 17 characters."
                    )

                elif not edit_colour:
                    st.error(
                        "Colour is required."
                    )

                else:

                    edit_model_id = (
                        model_options[
                            edit_model
                        ]
                    )

                    try:
                        update_vehicle(
                            selected_vehicle_id,
                            edit_model_id,
                            edit_vin,
                            int(edit_year),
                            edit_colour,
                            int(edit_mileage),
                            float(
                                edit_purchase_price
                            ),
                            float(
                                edit_selling_price
                            ),
                            edit_status
                        )

                        st.success(
                            "Vehicle updated successfully."
                        )

                        st.rerun()

                    except Exception:
                        st.error(
                            "Unable to update vehicle. "
                            "Check the VIN and other "
                            "vehicle information."
                        )

    else:
        st.info(
            "No vehicles are available to edit."
        )

except Exception as error:
    st.error(
        f"Unable to load vehicle editing section: {error}"
    )


# =====================================================
# CONTROLLED DELETE
# =====================================================

st.divider()
st.subheader("Delete Vehicle")

st.info(
    "Vehicle deletion is restricted to Available vehicles. "
    "If a vehicle is linked to transaction or service history, "
    "the database may reject the deletion so historical records "
    "are preserved."
)

try:
    delete_candidates = load_vehicles(
        status_filter="Available"
    )

    if delete_candidates:

        delete_options = {
            f"{vehicle['vehicle_id']} - "
            f"{vehicle['vin']} - "
            f"{vehicle['manufacturer_name']} "
            f"{vehicle['model_name']}":
                vehicle["vehicle_id"]
            for vehicle in delete_candidates
        }

        delete_selection = st.selectbox(
            "Select available vehicle",
            options=list(
                delete_options.keys()
            ),
            key="delete_vehicle_selector"
        )

        confirm_delete = st.checkbox(
            "I understand that this action permanently deletes "
            "the vehicle if the database allows it."
        )

        if st.button(
            "Delete Vehicle",
            type="primary"
        ):

            if not confirm_delete:
                st.warning(
                    "Confirm the deletion before continuing."
                )

            else:

                vehicle_id_to_delete = (
                    delete_options[
                        delete_selection
                    ]
                )

                try:
                    delete_vehicle(
                        vehicle_id_to_delete
                    )

                    st.success(
                        "Vehicle deleted successfully."
                    )

                    st.rerun()

                except Exception:
                    st.error(
                        "This vehicle could not be deleted. "
                        "It may already be linked to sales, "
                        "service or other historical records. "
                        "The vehicle has been preserved."
                    )

    else:
        st.info(
            "There are no Available vehicles eligible "
            "for controlled deletion."
        )

except Exception as error:
    st.error(
        f"Unable to load delete section: {error}"
    )