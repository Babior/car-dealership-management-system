import streamlit as st

from db import get_connection


st.set_page_config(
    page_title="Car Dealership Management System",
    layout="wide",
)

st.title("Car Dealership Management System")
st.write("Welcome to the Car Dealership Management System.")

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

    table_count = cursor.fetchone()[0]

    st.success(
        f"Connected to car_dealership_db successfully. "
        f"{table_count} tables detected."
    )

except Exception as error:
    st.error(f"Database connection failed: {error}")

finally:
    if "cursor" in locals():
        cursor.close()

    if "connection" in locals() and connection.is_connected():
        connection.close()