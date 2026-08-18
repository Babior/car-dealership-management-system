import streamlit as st

from auth import (
    initialize_authentication,
    login_form,
    logout,
    has_permission,
)
from db import get_connection


# PAGE CONFIGURATION

st.set_page_config(
    page_title="Car Dealership Management System",
    page_icon="🚗",
    layout="wide",
)


# AUTHENTICATION

initialize_authentication()

if not st.session_state.authenticated:

    login_navigation = st.navigation(
        [
            st.Page(
                login_form,
                title="Login",
                icon="🔐",
            )
        ],
        position="hidden",
    )

    login_navigation.run()

    st.stop()


# BUILD ROLE-BASED NAVIGATION

pages = []


# Dashboard
if has_permission("dashboard"):

    pages.append(
        st.Page(
            "pages/dashboard.py",
            title="Dashboard",
            icon="🏠",
            default=True,
        )
    )


# Customers
if has_permission("customers"):

    pages.append(
        st.Page(
            "pages/customers.py",
            title="Customers",
            icon="👥",
        )
    )


# Sales & Payments
if has_permission("sales_payments"):

    pages.append(
        st.Page(
            "pages/sales_payments.py",
            title="Sales & Payments",
            icon="💳",
        )
    )


# Reports
if has_permission("reports"):

    pages.append(
        st.Page(
            "pages/reports.py",
            title="Reports",
            icon="📊",
        )
    )


# Vehicles
if has_permission("vehicles"):

    pages.append(
        st.Page(
            "pages/vehicles.py",
            title="Vehicles",
            icon="🚗",
        )
    )


# Service
if has_permission("service"):

    pages.append(
        st.Page(
            "pages/service.py",
            title="Service",
            icon="🔧",
        )
    )


# Employees
if has_permission("employees"):

    pages.append(
        st.Page(
            "pages/employees.py",
            title="Employees",
            icon="🧑‍💼",
        )
    )


navigation = st.navigation(
    pages,
    position="sidebar",
)


# SIDEBAR USER INFORMATION

with st.sidebar:

    st.markdown(
        "### User Session"
    )

    current_user = st.session_state.get(
        "current_user"
    )

    if current_user:

        st.success(
            "Authenticated"
        )

        if current_user.get("username"):

            st.write(
                f"**Username:** "
                f"{current_user['username']}"
            )

        if current_user.get("full_name"):

            st.write(
                f"**Employee:** "
                f"{current_user['full_name']}"
            )

        if current_user.get("role_title"):

            st.write(
                f"**Role:** "
                f"{current_user['role_title']}"
            )

    if st.button(
        "Log out",
        use_container_width=True,
    ):
        logout()


  
    # DATABASE STATUS

    st.divider()

    st.markdown(
        "### Database Status"
    )

    connection = None
    cursor = None

    try:
        connection = get_connection()
        cursor = connection.cursor()

        cursor.execute(
            """
            SELECT COUNT(*)
            FROM information_schema.tables
            WHERE table_schema = %s
            """,
            (
                st.secrets[
                    "mysql"
                ][
                    "database"
                ],
            ),
        )

        object_count = (
            cursor.fetchone()[0]
        )

        st.success(
            f"Connected successfully\n\n"
            f"{object_count} database objects detected."
        )

    except Exception as error:

        st.error(
            f"Database connection failed: {error}"
        )

    finally:

        if cursor is not None:
            cursor.close()

        if (
            connection is not None
            and connection.is_connected()
        ):
            connection.close()


# RUN SELECTED PAGE

navigation.run()