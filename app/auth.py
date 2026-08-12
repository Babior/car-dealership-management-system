import hashlib

import streamlit as st

from db import get_connection


# =====================================================
# PASSWORD HASHING
# =====================================================

def hash_password(password):
    """Convert a password into the SHA-256 format used in MySQL."""
    return hashlib.sha256(
        password.encode("utf-8")
    ).hexdigest()


# =====================================================
# AUTHENTICATE USER
# =====================================================

def authenticate_user(username, password):
    """Check login details against user_account."""

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
            (
                username.strip(),
                hash_password(password),
            ),
        )

        user = cursor.fetchone()

        if user and user["account_status"] == "Active":

            user["full_name"] = (
                f"{user['first_name']} "
                f"{user['last_name']}"
            )

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

        if (
            connection is not None
            and connection.is_connected()
        ):
            connection.close()


# =====================================================
# SESSION INITIALIZATION
# =====================================================

def initialize_authentication():
    """Create Streamlit authentication session variables."""

    if "authenticated" not in st.session_state:
        st.session_state.authenticated = False

    if "current_user" not in st.session_state:
        st.session_state.current_user = None


# =====================================================
# LOGIN FORM
# =====================================================

def login_form():
    """Display and process the login form."""

    initialize_authentication()

    st.title("Car Dealership Login")

    with st.form("login_form"):

        username = st.text_input(
            "Username"
        )

        password = st.text_input(
            "Password",
            type="password"
        )

        submitted = st.form_submit_button(
            "Log in"
        )

    if submitted:

        try:
            user = authenticate_user(
                username,
                password
            )

            if user:
                st.session_state.authenticated = True
                st.session_state.current_user = user

                st.success(
                    "Login successful."
                )

                st.rerun()

            else:
                st.error(
                    "Invalid username, password, "
                    "or inactive account."
                )

        except Exception as error:
            st.error(
                f"Login failed: {error}"
            )


# =====================================================
# LOGOUT
# =====================================================

def logout():
    """End the current application session."""

    st.session_state.authenticated = False
    st.session_state.current_user = None

    st.rerun()


# =====================================================
# CURRENT USER HELPERS
# =====================================================

def get_current_user():
    """Return the current logged-in user."""

    return st.session_state.get(
        "current_user"
    )


def get_current_role():
    """Return the current user's role title."""

    user = get_current_user()

    if not user:
        return None

    return user.get("role_title")


# =====================================================
# ROLE PERMISSIONS
# =====================================================

ROLE_PERMISSIONS = {

    "Sales Consultant": {
        "dashboard",
        "customers",
        "sales_payments",
        "vehicles",
    },

    "Sales Manager": {
        "dashboard",
        "customers",
        "sales_payments",
        "vehicles",
        "reports",
    },

    "Finance Officer": {
        "dashboard",
        "sales_payments",
        "reports",
    },

    "Service Advisor": {
        "dashboard",
        "vehicles",
        "service",
    },

    "Technician": {
        "dashboard",
        "service",
    },

    "HR Officer": {
        "dashboard",
        "employees",
    },

    "IT Support Officer": {
        "dashboard",
    },

    "Branch Manager": {
        "dashboard",
        "customers",
        "sales_payments",
        "vehicles",
        "service",
        "reports",
    },

    "Inventory Officer": {
        "dashboard",
        "vehicles",
    },
}


# =====================================================
# PERMISSION CHECKS
# =====================================================

def has_permission(permission):
    """Return True if the current role has a permission."""

    role = get_current_role()

    permissions = ROLE_PERMISSIONS.get(
        role,
        set()
    )

    return permission in permissions


def require_permission(permission):
    """
    Stop the page if the current user does not have
    permission to access the requested feature.
    """

    if not st.session_state.get(
        "authenticated"
    ):
        st.error(
            "You must be logged in to access this page."
        )
        st.stop()

    if not has_permission(permission):
        st.error(
            "Access denied. Your account does not "
            "have permission to access this section."
        )
        st.stop()