import hashlib

import streamlit as st

from db import get_connection


def hash_password(password):
    """Convert a password into the same SHA-256 format used in MySQL."""
    return hashlib.sha256(password.encode("utf-8")).hexdigest()


def authenticate_user(username, password):
    """Check the supplied login details against user_account."""
    connection = None
    cursor = None

    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT
                ua.user_id,
                ua.employee_id,
                ua.username,
                ua.account_status,
                e.first_name,
                e.last_name,
                jr.role_title
            FROM user_account AS ua
            INNER JOIN employee AS e
                ON ua.employee_id = e.employee_id
            INNER JOIN job_role AS jr
                ON e.job_role_id = jr.job_role_id
            WHERE ua.username = %s
              AND ua.password_hash = %s
            """,
            (username.strip(), hash_password(password)),
        )

        user = cursor.fetchone()

        if user and user["account_status"] == "Active":
            cursor.execute(
                """
                UPDATE user_account
                SET last_login = CURRENT_TIMESTAMP
                WHERE user_id = %s
                """,
                (user["user_id"],),
            )
            connection.commit()
            return user

        return None

    finally:
        if cursor is not None:
            cursor.close()

        if connection is not None and connection.is_connected():
            connection.close()


def initialize_authentication():
    """Create login session variables."""
    if "authenticated" not in st.session_state:
        st.session_state.authenticated = False

    if "current_user" not in st.session_state:
        st.session_state.current_user = None


def login_form():
    """Display and process the login form."""
    initialize_authentication()

    st.title("Car Dealership Login")

    with st.form("login_form"):
        username = st.text_input("Username")
        password = st.text_input("Password", type="password")
        submitted = st.form_submit_button("Log in")

    if submitted:
        try:
            user = authenticate_user(username, password)

            if user:
                st.session_state.authenticated = True
                st.session_state.current_user = user
                st.success("Login successful.")
                st.rerun()
            else:
                st.error("Invalid username, password, or inactive account.")

        except Exception as error:
            st.error(f"Login failed: {error}")


def logout():
    """End the current application session."""
    st.session_state.authenticated = False
    st.session_state.current_user = None
    st.rerun()