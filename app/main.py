import streamlit as st

from db import get_connection


st.set_page_config(
    page_title="Car Dealership Management System",
    page_icon="🚗",
    layout="wide",
)


# Application pages
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


# Database connection status in sidebar
with st.sidebar:
    st.markdown("### Database Status")

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
        if "cursor" in locals():
            cursor.close()

        if "connection" in locals() and connection.is_connected():
            connection.close()


navigation.run()
