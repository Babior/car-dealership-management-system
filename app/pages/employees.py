import pandas as pd
import streamlit as st

from auth import require_permission
from db import get_connection


# =====================================================
# ACCESS CONTROL
# =====================================================

require_permission("employees")


# =====================================================
# PAGE HEADER
# =====================================================

st.title("Employee & User Account Management")
st.write(
    "View employees, search employee records, and manage user account status."
)


# =====================================================
# LOAD EMPLOYEES
# =====================================================

def load_employees(search_text=""):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    query = """
        SELECT
            e.employee_id,
            e.first_name,
            e.last_name,
            e.phone,
            e.email,
            d.department_name,
            jr.role_title,
            e.hire_date,
            e.employee_status,
            ua.username,
            ua.account_status
        FROM employee AS e
        INNER JOIN department AS d
            ON e.department_id = d.department_id
        INNER JOIN job_role AS jr
            ON e.job_role_id = jr.job_role_id
        LEFT JOIN user_account AS ua
            ON e.employee_id = ua.employee_id
        WHERE 1 = 1
    """

    parameters = []

    if search_text:
        query += """
            AND (
                e.first_name LIKE %s
                OR e.last_name LIKE %s
                OR CONCAT(e.first_name, ' ', e.last_name) LIKE %s
                OR e.email LIKE %s
            )
        """

        search_value = f"%{search_text}%"

        parameters.extend(
            [
                search_value,
                search_value,
                search_value,
                search_value,
            ]
        )

    query += " ORDER BY e.employee_id"

    cursor.execute(query, parameters)
    employees = cursor.fetchall()

    cursor.close()
    connection.close()

    return employees


# =====================================================
# LOAD USER ACCOUNTS
# =====================================================

def load_user_accounts():
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    query = """
        SELECT
            ua.user_id,
            ua.employee_id,
            ua.username,
            ua.account_status,
            e.first_name,
            e.last_name
        FROM user_account AS ua
        INNER JOIN employee AS e
            ON ua.employee_id = e.employee_id
        ORDER BY e.first_name, e.last_name
    """

    cursor.execute(query)
    accounts = cursor.fetchall()

    cursor.close()
    connection.close()

    return accounts


# =====================================================
# UPDATE ACCOUNT STATUS
# =====================================================

def update_account_status(user_id, new_status):
    allowed_statuses = [
        "Active",
        "Locked",
        "Disabled",
    ]

    if new_status not in allowed_statuses:
        raise ValueError("Invalid account status.")

    # Sensitive action check:
    # only HR Officer may change user account status.
    user = st.session_state.get("current_user")

    if not user or user.get("role_title") != "HR Officer":
        raise PermissionError(
            "You are not authorized to change account status."
        )

    connection = get_connection()
    cursor = connection.cursor()

    try:
        query = """
            UPDATE user_account
            SET account_status = %s
            WHERE user_id = %s
        """

        cursor.execute(
            query,
            (
                new_status,
                user_id,
            ),
        )

        connection.commit()

    except Exception:
        connection.rollback()
        raise

    finally:
        cursor.close()
        connection.close()


# =====================================================
# EMPLOYEE RECORDS
# =====================================================

st.subheader("Employee Records")

search_text = st.text_input(
    "Search employees",
    placeholder="Enter employee name or email",
)

try:
    employees = load_employees(search_text)

    if employees:
        employee_dataframe = pd.DataFrame(employees)

        st.dataframe(
            employee_dataframe,
            use_container_width=True,
            hide_index=True,
        )

        st.success(
            f"{len(employees)} employee record(s) found."
        )

    else:
        st.info(
            "No employee records matched your search."
        )

except Exception as error:
    st.error(
        f"Unable to load employee records: {error}"
    )


# =====================================================
# USER ACCOUNT MANAGEMENT
# =====================================================

st.divider()

st.subheader("User Account Management")

st.write(
    "Select an employee account to change its account status."
)

try:
    accounts = load_user_accounts()

    if accounts:

        account_options = {
            (
                f"{account['first_name']} "
                f"{account['last_name']} "
                f"({account['username']})"
            ): account
            for account in accounts
        }

        with st.form("account_status_form"):

            selected_account_label = st.selectbox(
                "Employee account",
                options=list(account_options.keys()),
            )

            selected_account = account_options[
                selected_account_label
            ]

            st.write(
                f"Current status: "
                f"**{selected_account['account_status']}**"
            )

            status_values = [
                "Active",
                "Locked",
                "Disabled",
            ]

            current_status_index = status_values.index(
                selected_account["account_status"]
            )

            new_status = st.selectbox(
                "New account status",
                status_values,
                index=current_status_index,
            )

            update_status_button = st.form_submit_button(
                "Update Account Status"
            )

        if update_status_button:

            if (
                new_status
                == selected_account["account_status"]
            ):
                st.info(
                    "The account already has this status."
                )

            else:
                try:
                    update_account_status(
                        selected_account["user_id"],
                        new_status,
                    )

                    st.success(
                        "Account status updated successfully."
                    )

                    st.rerun()

                except Exception as error:
                    st.error(
                        f"Unable to update account status: {error}"
                    )

    else:
        st.info(
            "There are currently no user accounts to manage."
        )

except Exception as error:
    st.error(
        f"Unable to load user accounts: {error}"
    )