import streamlit as st

from auth import initialize_authentication, login_form, logout
from db import get_connection


st.set_page_config(
    page_title="Car Dealership Management System",
    page_icon="🚗",
    layout="wide",
)


# -----------------------------------------------------
# AUTHENTICATION
# -----------------------------------------------------

initialize_authentication()

# Prevent access to the application until login succeeds.
if not st.session_state.authenticated:
    login_navigation = st.navigation(
        [st.Page(login_form, title="Login", icon="🔐")],
        position="hidden",
    )
    login_navigation.run()
    st.stop()


# -----------------------------------------------------
# APPLICATION PAGES
# -----------------------------------------------------

pages = [
    st.Page(
        "pages/dashboard.py",
        title="Dashboard",
        icon="🏠",
        default=True,
    ),
    st.Page(
        "pages/customers.py",
        title="Customers",
        icon="👥",
    ),
    st.Page(
        "pages/sales_payments.py",
        title="Sales & Payments",
        icon="💳",
    ),
    st.Page(
        "pages/reports.py",
        title="Reports",
        icon="📊",
    ),
    st.Page(
        "pages/vehicles.py",
        title="Vehicles",
        icon="🚗",
    ),
    st.Page(
        "pages/service.py",
        title="Service",
        icon="🔧",
    ),
    st.Page(
        "pages/employees.py",
        title="Employees",
        icon="🧑‍💼",
    ),
]

navigation = st.navigation(pages)


# -----------------------------------------------------
# SIDEBAR
# -----------------------------------------------------

with st.sidebar:
    st.markdown("### User Session")

    current_user = st.session_state.get("current_user")

    if current_user:
        st.success("Authenticated")

        # Display information only when it exists.
        if current_user.get("username"):
            st.write(f"**Username:** {current_user['username']}")

        if current_user.get("full_name"):
            st.write(f"**Employee:** {current_user['full_name']}")

        if current_user.get("role_title"):
            st.write(f"**Role:** {current_user['role_title']}")

    if st.button("Log out", use_container_width=True):
        logout()

    st.divider()
    st.markdown("### Database Status")

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
            (st.secrets["mysql"]["database"],),
        )

        object_count = cursor.fetchone()[0]

        st.success(
            f"Connected successfully\n\n"
            f"{object_count} database objects detected."
        )

    except Exception as error:
        st.error(f"Database connection failed: {error}")

    finally:
        if cursor is not None:
            cursor.close()

        if connection is not None and connection.is_connected():
            connection.close()


# Display the selected page.
navigation.run()