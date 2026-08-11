# Car Dealership Management System
## Phase 7 Security Design and Implementation Plan

**Course:** Database Systems
**Project:** Car Dealership Management System
**Group:** 11
**DBMS:** MySQL
**Application Framework for Phase 8:** Streamlit
**Repository:** `Babior/car-dealership-management-system`
**Approved database baseline:** 20 relations/entities

---

## 1. Purpose

This document defines the security design for Phase 7 of the Car Dealership Management System.

The official project brief requires Phase 7 to cover:

- user roles;
- privileges;
- authentication strategy; and
- backup/recovery considerations.

This security design extends the existing project structure without adding new database entities.

The existing security-related design remains unchanged:

- `UserAccount` stores application login information;
- each `UserAccount` belongs to one `Employee`;
- `Employee.JobRole` determines application authorization;
- passwords are stored as hashes, never plain text;
- only selected employees have application accounts; and
- customers do not receive direct login access in version one.

---

## 2. Phase 7 Objectives

Phase 7 will:

1. define the dealership's application roles;
2. implement MySQL roles and database privileges;
3. apply the principle of least privilege;
4. define the authentication and authorization strategy for the Streamlit application;
5. protect sensitive employee, customer and financial information;
6. define backup and recovery procedures;
7. test both authorized and unauthorized database actions; and
8. produce an auditable security implementation before Phase 8 begins.

---

## 3. Security Architecture

The system uses two related security layers.

### 3.1 Application security

Application users authenticate through the `user_account` table.

Conceptual flow:

```text
Employee enters username and password
              |
              v
       Find UserAccount
              |
              v
  Confirm account_status = Active
              |
              v
Verify password against password_hash
              |
              v
        Retrieve Employee
              |
              v
         Retrieve JobRole
              |
              v
Create authenticated Streamlit session
              |
              v
Show only authorized pages/actions
```

Application authorization is based on `Employee.JobRole`.

### 3.2 Database security

MySQL roles provide an additional security layer.

The database roles are:

- `dealership_admin`
- `dealership_manager`
- `dealership_salesperson`
- `dealership_finance`
- `dealership_inventory`
- `dealership_service_advisor`
- `dealership_mechanic`

These roles are used to demonstrate and enforce least-privilege access at database level.

The Phase 8 Streamlit application may use a dedicated application database account stored securely in environment variables. Application-level permissions must still be enforced using `JobRole`; hiding interface elements alone is not sufficient security.

---

## 4. Approved Application Roles

| Role | Main responsibility |
|---|---|
| Administrator | Employees, accounts, organizational access and system administration |
| Manager | Operational monitoring, management reports and performance review |
| Salesperson | Vehicle/customer lookup and vehicle sales |
| Finance Officer | Payments, loans and loan installments |
| Inventory Officer | Manufacturers, models, vehicles and parts inventory |
| Service Advisor | Service orders, service parts, warranties and warranty claims |
| Mechanic | Assigned service work and limited service updates |

**Customer:** no direct application login in version one.

---

## 5. Security Principles

### 5.1 Least privilege

Each role receives only the permissions required to perform its duties.

### 5.2 Separation of duties

Sensitive operations are distributed across roles.

Examples:

- sales staff do not administer employee accounts;
- mechanics do not manage loans or payments;
- finance staff do not alter vehicle inventory;
- managers primarily receive broad reporting/read access rather than unrestricted transaction modification.

### 5.3 Preserve transaction history

Core transactional records should not normally be deleted.

Therefore, Phase 7 does not broadly grant `DELETE` privileges to operational roles.

### 5.4 Password protection

- no plain-text passwords;
- `password_hash` is required;
- hashes are never displayed to ordinary users;
- password verification occurs in application logic.

### 5.5 Secret management

Database credentials and other secrets must not be committed to GitHub.

Phase 8 should use environment variables or Streamlit secrets configuration.

### 5.6 Defense in depth

Security is enforced through multiple controls:

1. authentication;
2. active-account checking;
3. application role authorization;
4. parameterized SQL;
5. database roles and privileges;
6. restricted database credentials; and
7. backup/recovery.

---

## 6. Role-Privilege Summary

The full implementation matrix is maintained in `docs/phase7_role_privilege_matrix.md`.

High-level ownership is:

### Administrator
Primary database areas:

- `department`
- `job_role`
- `employee`
- `user_account`

### Manager
Broad read/reporting access across operational modules and Phase 6 reporting objects.

### Salesperson
Primary database areas:

- vehicle/model/manufacturer lookup;
- customer creation and updates;
- sales and sale items;
- payment-status lookup.

### Finance Officer
Primary database areas:

- customer/sale lookup;
- payments;
- loans;
- loan installments.

### Inventory Officer
Primary database areas:

- manufacturer;
- vehicle_model;
- vehicle;
- part.

### Service Advisor
Primary database areas:

- customer/vehicle lookup;
- mechanic lookup;
- service_order;
- service_part;
- part lookup;
- warranty;
- warranty_claim.

### Mechanic
Restricted access to service-related records, with only limited service updates.

---

## 7. Streamlit Authentication and Authorization Strategy

Phase 8 will use Streamlit.

The existing `user_account` table remains the authentication source.

### 7.1 Login process

1. User enters username and password.
2. Application queries `user_account` by username.
3. Application rejects missing, Locked or Disabled accounts.
4. Application verifies the supplied password against `password_hash`.
5. Application retrieves the associated Employee.
6. Application retrieves the Employee's JobRole.
7. Application stores the authenticated identity and role in session state.
8. Navigation and actions are generated according to role.

### 7.2 Authorization

Authorization must be checked before each protected operation.

Example:

```text
Salesperson -> Customers + Vehicles + Sales
Finance Officer -> Payments + Loans
Mechanic -> Service work only
Administrator -> Employees + Accounts
```

The application must not rely only on hidden buttons or hidden pages.

### 7.3 Session handling

The application should maintain at minimum:

- authenticated status;
- user ID;
- employee ID;
- username;
- job role.

Logout must clear authentication state.

---

## 8. Sensitive Data Classification

### Highly sensitive

- `user_account.password_hash`
- employee salary information
- database credentials
- backup files

### Sensitive business data

- customer records
- payments
- loans and installments
- sale financial information
- warranty claims

### General operational data

- manufacturer/model data
- vehicle availability
- parts catalog
- service status

Access to highly sensitive information must be especially restricted.

---

## 9. SQL Injection and Input Security

The Phase 8 application must:

- use parameterized SQL queries or SQLAlchemy;
- never build SQL by directly concatenating untrusted form input;
- validate required fields before database execution;
- retain database constraints as the final integrity layer.

---

## 10. Backup and Recovery Strategy

### 10.1 Backup objectives

Backups protect the database against:

- accidental deletion;
- data corruption;
- failed updates;
- hardware/software failure;
- major development mistakes.

### 10.2 Backup method

MySQL logical backups should be created using `mysqldump`.

Example form:

```bash
mysqldump -u <backup_user> -p car_dealership_db > car_dealership_backup.sql
```

Actual credentials must not be stored in documentation or committed to GitHub.

### 10.3 Recommended schedule

For the coursework environment:

- create a full backup before major schema/security/application changes;
- create a full backup before the final demonstration;
- maintain dated backup copies during active development.

For a production deployment, backups would be scheduled automatically and retained according to an organizational policy.

### 10.4 Backup storage

Backups should:

- be stored separately from the active database;
- not be committed to the public project repository;
- be accessible only to authorized administrators;
- be protected because they contain customer and financial data.

### 10.5 Restore procedure

Example form:

```bash
mysql -u <restore_user> -p car_dealership_db < car_dealership_backup.sql
```

A backup is not considered reliable until restoration has been tested.

### 10.6 Recovery test

The team should perform at least one test restoration before final submission and record:

- backup file used;
- restore command/process;
- whether schema objects were restored;
- whether records were restored;
- any errors encountered.

---

## 11. Database Security Implementation Files

```text
database/security/
├── 01_create_roles.sql
├── 02_jamal_sales_finance_manager_privileges.sql
├── 03_ean_admin_inventory_service_privileges.sql
├── 04_jamal_security_verification.sql
├── 05_ean_security_verification.sql
└── 99_full_security.sql
```

### Ean owns

- `01_create_roles.sql`
- `03_ean_admin_inventory_service_privileges.sql`
- `05_ean_security_verification.sql`

### Jamal owns

- `02_jamal_sales_finance_manager_privileges.sql`
- `04_jamal_security_verification.sql`
- `99_full_security.sql`

---

## 12. Implementation Responsibilities

### Ean

Implement:

- role creation;
- Administrator privileges;
- Inventory Officer privileges;
- Service Advisor privileges;
- Mechanic privileges;
- verification tests for those roles.

### Jamal

Implement:

- Salesperson privileges;
- Finance Officer privileges;
- Manager privileges;
- verification tests for those roles;
- final integrated `99_full_security.sql`;
- final Phase 7 integration review.

---

## 13. Verification Requirements

Security testing must prove both allowed and denied actions.

Examples:

- Salesperson can create a customer.
- Salesperson cannot update employee salary.
- Finance Officer can record a payment.
- Finance Officer cannot update vehicle inventory.
- Inventory Officer can update vehicle records.
- Inventory Officer cannot create a loan.
- Service Advisor can create a service order.
- Mechanic cannot manage user accounts.
- Manager can read management reports.
- Operational roles cannot perform unauthorized administrative actions.

`SHOW GRANTS` should be used as supporting evidence for each tested MySQL role.

---

## 14. Phase 7 Definition of Done

Phase 7 is complete when:

- [ ] seven database roles have been created;
- [ ] privileges match the agreed role matrix;
- [ ] least privilege is applied;
- [ ] operational roles are not broadly granted `DELETE`;
- [ ] authentication strategy is documented;
- [ ] Streamlit authorization strategy is documented;
- [ ] passwords are stored only as hashes;
- [ ] credentials are excluded from GitHub;
- [ ] backup procedure is documented;
- [ ] restore procedure is documented;
- [ ] at least one restore test is completed;
- [ ] authorized database operations succeed;
- [ ] unauthorized database operations fail;
- [ ] `SHOW GRANTS` evidence is checked;
- [ ] `99_full_security.sql` executes successfully after the database objects it depends on exist;
- [ ] Jamal and Ean complete the final Phase 7 audit.

---

## 15. Transition to Phase 8

After Phase 7 passes its audit, Phase 8 will implement the Streamlit application.

The security design established here will control:

- login;
- session management;
- page navigation;
- CRUD permissions;
- reporting access;
- protected administrative functions; and
- secure database connectivity.
