# Car Dealership Management System
## Project Design and Phase 4 Collaboration Guide

**Course:** Database Systems  
**Project:** Car Dealership Management System  
**Group:** 11  
**DBMS:** MySQL  
**Version control:** GitHub  
**Repository:** `Babior/car-dealership-management-system`  
**Current baseline:** 20 relations/entities  

---

## 1. Purpose of this document

This file is the team's single implementation guide for the Car Dealership Management System. It consolidates the approved requirements and conceptual design, the finalized Phase 3 logical design, and the implementation decisions needed for Phase 4.

Every team member should read this file before writing SQL. If a design choice in a personal branch conflicts with this guide, the guide takes priority unless the team explicitly approves a change and updates this document.

The official assignment requires Phase 4 to deliver SQL DDL scripts that create tables, constraints, indexes, and identity/auto-increment columns as appropriate. Phase 5 will populate the database, while Phase 6 will contain advanced queries, views, procedures, functions, and triggers.

---

## 2. Phase 4 Team Allocation and Ownership

This section is intentionally placed near the beginning of the guide so every member can immediately see what they are responsible for implementing.

The allocation follows three principles:

1. Every member implements exactly four of the twenty entities.
2. The most central and technically demanding entities are assigned to Ean and Jamal.
3. After Ean and Jamal, the next most important implementation work is assigned to Charles, then Winfred, then Nasir.

### 2.1 Allocation summary

| Member | Assigned entities | Count | Main role |
|---|---|---:|---|
| **Ean** | Manufacturer, VehicleModel, Vehicle, Employee | 4 | Core Database and Integrity Lead |
| **Jamal** | Salesperson, Sale, SaleItem, Payment | 4 | Sales and Database Integration Lead |
| **Charles** | Customer, Department, JobRole, UserAccount | 4 | Customer, Organization and Access Lead |
| **Winfred** | Mechanic, ServiceOrder, Part, ServicePart | 4 | Service and Parts Lead |
| **Nasir** | Loan, LoanInstallment, Warranty, WarrantyClaim | 4 | Financing and Warranty Lead |

### 2.2 Ean - Core Database and Integrity Lead

**Assigned entities:**

- Manufacturer
- VehicleModel
- Vehicle
- Employee

**Why these are important:** Vehicle is central to sales, service and warranties, while Employee is the parent structure required by the Salesperson and Mechanic subtypes.

**Implementation responsibilities:**

- implement the Manufacturer -> VehicleModel -> Vehicle dependency chain;
- implement Vehicle VIN uniqueness and vehicle-domain constraints;
- implement the Employee base table;
- ensure Employee keys are compatible with Salesperson and Mechanic;
- verify foundational foreign-key datatypes;
- assist Jamal with technically difficult constraint decisions;
- review Pull Requests with Jamal.

**Branch:** `phase4/ean-core-schema`  
**SQL file:** `database/schema/01_ean_core.sql`

### 2.3 Jamal - Sales and Database Integration Lead

**Assigned entities:**

- Salesperson
- Sale
- SaleItem
- Payment

**Why these are important:** these relations implement the central dealership transaction flow and connect Employee, Customer and Vehicle to payments and later financing.

**Implementation responsibilities:**

- implement Salesperson as an Employee subtype;
- implement Sale and its Customer/Salesperson foreign keys;
- implement SaleItem and its composite key;
- enforce the rule that a physical vehicle can appear in at most one SaleItem;
- implement Payment and its positive-amount/domain constraints;
- preserve `commission_rate_applied` for historical commission accuracy;
- coordinate naming and constraint conventions across all modules;
- integrate approved module SQL into `99_full_schema.sql`;
- define/review Phase 4 indexes;
- run full clean-build testing;
- review Pull Requests with Ean.

**Branch:** `phase4/jamal-sales-integration`  
**SQL file:** `database/schema/02_jamal_sales.sql`

### 2.4 Charles - Customer, Organization and Access Lead

**Assigned entities:**

- Customer
- Department
- JobRole
- UserAccount

**Why these are important:** Customer feeds both sales and service workflows, while Department, JobRole and UserAccount support employee organization and access control.

**Implementation responsibilities:**

- implement Customer identity/contact constraints;
- implement Department and JobRole reference structures;
- implement UserAccount and its one-account-per-Employee rule;
- enforce username uniqueness;
- ensure `password_hash` is required;
- coordinate Employee dependencies with Ean;
- coordinate Customer dependencies with Jamal and Winfred.

**Branch:** `phase4/charles-customer-access`  
**SQL file:** `database/schema/03_charles_customer_access.sql`

### 2.5 Winfred - Service and Parts Lead

**Assigned entities:**

- Mechanic
- ServiceOrder
- Part
- ServicePart

**Why these are important:** these relations implement the dealership's major post-sale operational workflow and connect Employee, Customer and Vehicle to parts inventory.

**Implementation responsibilities:**

- implement Mechanic as an Employee subtype;
- implement ServiceOrder with Customer, Vehicle and Mechanic foreign keys;
- implement Part inventory constraints;
- implement ServicePart with composite primary key;
- require positive `quantity_used`;
- preserve `unit_price_at_use` for historical accuracy;
- document stock-deduction behavior for later Phase 6 trigger/procedure work.

**Branch:** `phase4/winfred-service`  
**SQL file:** `database/schema/04_winfred_service.sql`

### 2.6 Nasir - Financing and Warranty Lead

**Assigned entities:**

- Loan
- LoanInstallment
- Warranty
- WarrantyClaim

**Why these are important:** these relations handle two major post-sale processes: financing and warranty support.

**Implementation responsibilities:**

- enforce at most one Loan per Sale using `UNIQUE(sale_id)`;
- implement LoanInstallment as the weak relation using `(loan_id, installment_number)`;
- implement financing domain constraints;
- implement Warranty including optional `provider_phone`;
- enforce warranty date/status constraints;
- implement WarrantyClaim;
- keep `WarrantyClaim.service_order_id` nullable.

**Branch:** `phase4/nasir-financing-warranty`  
**SQL file:** `database/schema/05_nasir_financing_warranty.sql`

### 2.7 Collaboration and review rules

- No member works directly on `main`.
- Every member implements exactly four entities.
- Each person works primarily in their assigned module file.
- Every implementation is submitted through a Pull Request.
- Jamal and Ean are the primary technical reviewers.
- Jamal owns the final integrated `database/schema/99_full_schema.sql`.
- A module is not complete until its SQL runs successfully in MySQL and the Pull Request is approved.

### 2.8 Cross-member dependencies

Because the workload is balanced by entity count, some parent/child relations cross module ownership. These dependencies are deliberate:

- Ean's Employee depends on Charles's Department and JobRole.
- Jamal's Salesperson depends on Ean's Employee.
- Charles's UserAccount depends on Ean's Employee.
- Winfred's Mechanic depends on Ean's Employee.
- Jamal's Sale depends on Charles's Customer and Jamal's Salesperson.
- Jamal's SaleItem depends on Ean's Vehicle.
- Winfred's ServiceOrder depends on Charles's Customer, Ean's Vehicle and Winfred's Mechanic.
- Nasir's Loan depends on Jamal's Sale.
- Nasir's Warranty depends on Ean's Vehicle.
- Nasir's WarrantyClaim may depend on Winfred's ServiceOrder.

The final creation order in Section 12, not the module file numbers, determines the order in which tables are created in `99_full_schema.sql`.

---

## 3. Project goal

The system will provide a centralized relational database for the principal operations of a single car dealership branch. It will support:

- vehicle inventory and vehicle models;
- customer registration and customer history;
- employee, department, job-role and user-account management;
- vehicle sales and sale items;
- full and partial sale payments;
- vehicle financing and loan installments;
- vehicle service orders and parts usage;
- warranties and warranty claims;
- salesperson commission calculation; and
- operational and management reporting.

The design aims to reduce duplicate data, enforce business rules, preserve historical values, protect sensitive data, and provide a reliable foundation for the later application phase.

---

## 4. Project scope

### 4.1 In scope

- Vehicle inventory
- Manufacturer and vehicle-model management
- Customer management
- Employee and user-account management
- Sales and sale items
- Payments
- Financing and loan installments
- Vehicle servicing and parts
- Warranties and warranty claims
- Salesperson commission calculation
- Reports
- Authentication and role-based access in the application phase

### 4.2 Out of scope for version one

- Multi-branch management
- Vehicle manufacturing and customs-clearance processes
- Government vehicle registration
- General accounting and payroll
- Insurance-policy administration
- Direct bank/payment-gateway integration
- GPS tracking
- Automatic SMS and email notifications
- Customer self-service portal
- Separate WarrantyProvider or FinancialInstitution administration
- AuditLog entity

---

## 5. Approved design baseline

The database uses exactly **20 relations**.

### Vehicle inventory
1. Manufacturer
2. VehicleModel
3. Vehicle

### Employees and access
4. Department
5. JobRole
6. Employee
7. Salesperson
8. Mechanic
9. UserAccount

### Customers and sales
10. Customer
11. Sale
12. SaleItem
13. Payment

### Financing
14. Loan
15. LoanInstallment

### Servicing
16. ServiceOrder
17. Part
18. ServicePart

### Warranties
19. Warranty
20. WarrantyClaim

---

## 6. Design decisions that must not change without group approval

1. The current baseline contains exactly 20 relations.
2. `payment_method` is an attribute of Payment; PaymentMethod is not a separate relation.
3. Commission is not stored in a separate Commission relation.
4. Historical commission is calculated from `Sale.total_amount` and `Sale.commission_rate_applied`.
5. Employee is the supertype.
6. Salesperson and Mechanic are partial, disjoint Employee subtypes.
7. LoanInstallment is the principal weak relation and uses `(loan_id, installment_number)` as its composite primary key.
8. SaleItem is the associative relation connecting Sale and Vehicle.
9. ServicePart is the associative relation connecting ServiceOrder and Part.
10. One physical vehicle can be sold only once.
11. A Sale may have at most one Loan.
12. A UserAccount belongs to at most one Employee.
13. JobRole will determine application authorization in version one.
14. `Sale.commission_rate_applied` must preserve the rate used at transaction time.
15. `ServicePart.unit_price_at_use` must preserve the part price used at service time.
16. The implementation DBMS for this project is MySQL.

---

## 7. Phase 3 refinements adopted for Phase 4

The revised logical-design document introduced several improvements that are now part of the implementation baseline.

### 7.1 ERD alignment corrections

The conceptual ERD should be updated so that it agrees with the logical model:

- Payment includes `sale_id`, `payment_date`, `amount`, and `reference_number`.
- Customer uses separate `first_name` and `last_name` attributes.
- Customer includes `registration_date`.
- Employee includes `email`.
- LoanInstallment includes `due_date`.
- Warranty includes the newly approved optional attribute `provider_phone`.

These are alignment corrections, not new relations.

### 7.2 Normalization baseline

The logical design now documents the path from UNF to 1NF, 2NF and 3NF and identifies the principal functional dependencies. The relations have also been assessed against BCNF. The implementation must not reintroduce repeating groups, partial dependencies or transitive dependencies that were removed during normalization.

### 7.3 Nullability and implementation-oriented data dictionary

Phase 4 should follow the nullability and MySQL-compatible data types listed in Section 10 of this guide.

### 7.4 Controlled status values

Status columns must use controlled values so that different developers do not insert inconsistent wording.

### 7.5 Deletion policy

Transactional records should normally be preserved. The team should prefer restrictive deletion for transactional parents such as Sale, Loan and ServiceOrder rather than cascading deletion that silently removes history.

---

## 8. Core business rules to enforce

1. Every Vehicle must have a unique 17-character VIN.
2. A physical Vehicle can be sold only once.
3. Every Sale belongs to exactly one Customer.
4. Every Sale is processed by exactly one Salesperson.
5. A Sale contains one or more SaleItems.
6. Payment amounts must be positive.
7. Cumulative payments must not exceed the outstanding Sale balance.
8. A Sale may have zero or one Loan.
9. Every approved Loan must have one or more LoanInstallments.
10. Loan principal must be positive.
11. Loan interest cannot be negative.
12. Loan term must be greater than zero.
13. Every ServiceOrder identifies one Customer, one Vehicle and one Mechanic.
14. ServiceOrder parts are optional.
15. Part stock and reorder levels cannot be negative.
16. Quantity used in a service must be greater than zero and cannot exceed available stock.
17. Warranty end date cannot be earlier than start date.
18. Every WarrantyClaim belongs to one Warranty.
19. `WarrantyClaim.service_order_id` is optional.
20. Passwords must be stored as hashes, never plain text.
21. Salesperson and Mechanic rows cannot exist without matching Employee rows.
22. In this design an Employee cannot simultaneously be both a Salesperson and a Mechanic.
23. Historical commission and service-part price values must not change when current rates/prices change later.

Some cross-row rules, such as preventing overpayment and automatically deducting stock, cannot be fully guaranteed by simple CHECK constraints. They will be implemented through procedures/triggers in Phase 6, while Phase 4 must create a schema that supports those rules.

---

## 9. SQL naming and coding standards

### 9.1 Naming

Use `snake_case` for tables, columns, constraints and indexes.

Examples:

- `vehicle_model`
- `employee_id`
- `commission_rate_applied`
- `fk_sale_customer`
- `idx_vehicle_status`

Use singular table names consistently.

### 9.2 Primary keys

Surrogate identifiers use:

```sql
INT AUTO_INCREMENT PRIMARY KEY
```

unless the relation uses an approved composite/subtype key.

### 9.3 Monetary values

Use:

```sql
DECIMAL(12,2)
```

Do not use FLOAT for money.

### 9.4 Percentages

Use:

```sql
DECIMAL(5,2)
```

and constrain values to the appropriate range.

### 9.5 Foreign-key naming

Use explicit names, for example:

```sql
CONSTRAINT fk_sale_customer
    FOREIGN KEY (customer_id)
    REFERENCES customer(customer_id)
```

### 9.6 Character set and engine

Use one consistent MySQL engine and character set for all tables. The integration lead will finalize these settings in `00_create_database.sql` and `99_full_schema.sql`.

---

## 10. Final logical schema and Phase 4 data dictionary

The following definitions are the baseline that developers should implement.

### 10.1 manufacturer

| Column | Type | Key / Constraint | Null | Notes |
|---|---|---|---|---|
| manufacturer_id | INT | PK, AUTO_INCREMENT | No | Unique manufacturer identifier |
| manufacturer_name | VARCHAR(100) | UNIQUE | No | Official manufacturer name |
| country | VARCHAR(80) | - | No | Country of origin |

### 10.2 vehicle_model

| Column | Type | Key / Constraint | Null | Notes |
|---|---|---|---|---|
| model_id | INT | PK, AUTO_INCREMENT | No | Model identifier |
| manufacturer_id | INT | FK -> manufacturer | No | Manufacturer |
| model_name | VARCHAR(100) | - | No | Commercial model name |
| body_type | VARCHAR(40) | - | No | SUV, Sedan, etc. |
| fuel_type | VARCHAR(30) | - | No | Petrol, Diesel, Electric, Hybrid |
| transmission | VARCHAR(30) | - | No | Transmission type |

### 10.3 vehicle

| Column | Type | Key / Constraint | Null | Notes |
|---|---|---|---|---|
| vehicle_id | INT | PK, AUTO_INCREMENT | No | Inventory vehicle identifier |
| model_id | INT | FK -> vehicle_model | No | Model |
| vin | VARCHAR(17) | UNIQUE | No | Unique VIN |
| manufacture_year | SMALLINT | CHECK | No | Valid manufacture year |
| colour | VARCHAR(40) | - | No | Vehicle colour |
| mileage | INT | CHECK >= 0 | No | Odometer reading |
| purchase_price | DECIMAL(12,2) | CHECK >= 0 | No | Dealer acquisition price |
| selling_price | DECIMAL(12,2) | CHECK >= 0 | No | Advertised selling price |
| vehicle_status | VARCHAR(20) | CHECK | No | Controlled status |

Allowed `vehicle_status` values: `Available`, `Reserved`, `Sold`, `In Service`.

### 10.4 department

| Column | Type | Key / Constraint | Null | Notes |
|---|---|---|---|---|
| department_id | INT | PK, AUTO_INCREMENT | No | Department identifier |
| department_name | VARCHAR(80) | UNIQUE | No | Unique department name |
| description | VARCHAR(255) | - | Yes | Department function |

### 10.5 job_role

| Column | Type | Key / Constraint | Null | Notes |
|---|---|---|---|---|
| job_role_id | INT | PK, AUTO_INCREMENT | No | Job role identifier |
| role_title | VARCHAR(80) | UNIQUE | No | Unique position title |
| description | VARCHAR(255) | - | Yes | Role duties |

### 10.6 employee

| Column | Type | Key / Constraint | Null | Notes |
|---|---|---|---|---|
| employee_id | INT | PK, AUTO_INCREMENT | No | Employee identifier |
| department_id | INT | FK -> department | No | Department |
| job_role_id | INT | FK -> job_role | No | Job role |
| first_name | VARCHAR(60) | - | No | Given name |
| last_name | VARCHAR(60) | - | No | Family name |
| phone | VARCHAR(20) | - | No | Contact number |
| email | VARCHAR(120) | UNIQUE | No | Unique work email |
| hire_date | DATE | - | No | Employment start date |
| salary | DECIMAL(12,2) | CHECK >= 0 | No | Base salary |
| employee_status | VARCHAR(20) | CHECK | No | Employment state |

Allowed `employee_status`: `Active`, `On Leave`, `Inactive`.

### 10.7 salesperson

| Column | Type | Key / Constraint | Null | Notes |
|---|---|---|---|---|
| employee_id | INT | PK, FK -> employee | No | Inherited employee identifier |
| commission_rate | DECIMAL(5,2) | CHECK 0-100 | No | Current commission percentage |
| sales_target | DECIMAL(12,2) | CHECK >= 0 | No | Sales target |

### 10.8 mechanic

| Column | Type | Key / Constraint | Null | Notes |
|---|---|---|---|---|
| employee_id | INT | PK, FK -> employee | No | Inherited employee identifier |
| specialization | VARCHAR(100) | - | No | Area of expertise |
| certification | VARCHAR(120) | - | Yes | Certification details |

### 10.9 user_account

| Column | Type | Key / Constraint | Null | Notes |
|---|---|---|---|---|
| user_id | INT | PK, AUTO_INCREMENT | No | Account identifier |
| employee_id | INT | FK -> employee, UNIQUE | No | One account at most per employee |
| username | VARCHAR(60) | UNIQUE | No | Sign-in name |
| password_hash | VARCHAR(255) | - | No | Hash only |
| account_status | VARCHAR(20) | CHECK | No | Account state |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | No | Creation time |
| last_login | DATETIME | - | Yes | Most recent successful login |

Allowed `account_status`: `Active`, `Locked`, `Disabled`.

### 10.10 customer

| Column | Type | Key / Constraint | Null | Notes |
|---|---|---|---|---|
| customer_id | INT | PK, AUTO_INCREMENT | No | Customer identifier |
| first_name | VARCHAR(60) | - | No | Given name |
| last_name | VARCHAR(60) | - | No | Family name |
| phone | VARCHAR(20) | - | No | Telephone number |
| email | VARCHAR(120) | UNIQUE | Yes | Optional email |
| address | VARCHAR(255) | - | Yes | Postal/residential address |
| registration_date | DATE | DEFAULT | No | Registration date |

### 10.11 sale

| Column | Type | Key / Constraint | Null | Notes |
|---|---|---|---|---|
| sale_id | INT | PK, AUTO_INCREMENT | No | Sale identifier |
| customer_id | INT | FK -> customer | No | Purchasing customer |
| salesperson_id | INT | FK -> salesperson(employee_id) | No | Responsible salesperson |
| sale_date | DATE | - | No | Transaction date |
| discount_amount | DECIMAL(12,2) | CHECK >= 0 | No | Discount |
| tax_amount | DECIMAL(12,2) | CHECK >= 0 | No | Tax |
| total_amount | DECIMAL(12,2) | CHECK >= 0 | No | Final payable amount |
| commission_rate_applied | DECIMAL(5,2) | CHECK 0-100 | No | Historical commission rate |
| sale_status | VARCHAR(20) | CHECK | No | Sale state |
| payment_status | VARCHAR(20) | CHECK | No | Payment state |

Allowed `sale_status`: `Pending`, `Completed`, `Cancelled`.  
Allowed `payment_status`: `Unpaid`, `Partially Paid`, `Paid`.

### 10.12 sale_item

| Column | Type | Key / Constraint | Null | Notes |
|---|---|---|---|---|
| sale_id | INT | PK, FK -> sale | No | Sale |
| vehicle_id | INT | PK, FK -> vehicle, UNIQUE | No | Vehicle; UNIQUE prevents resale |
| agreed_price | DECIMAL(12,2) | CHECK >= 0 | No | Agreed transaction price |

Implementation baseline: `PRIMARY KEY (sale_id, vehicle_id)` plus `UNIQUE(vehicle_id)`.

**Normalization note:** because `vehicle_id` is UNIQUE, it is also a candidate key for this relation. The composite PK is retained to preserve the associative-table design and the approved conceptual model. The BCNF discussion should recognize `vehicle_id` as an alternate candidate key rather than implying that only the composite key can determine the row.

### 10.13 payment

| Column | Type | Key / Constraint | Null | Notes |
|---|---|---|---|---|
| payment_id | INT | PK, AUTO_INCREMENT | No | Payment identifier |
| sale_id | INT | FK -> sale | No | Related sale |
| payment_date | DATETIME | - | No | Recorded date/time |
| amount | DECIMAL(12,2) | CHECK > 0 | No | Amount received |
| payment_method | VARCHAR(30) | CHECK | No | Payment method |
| reference_number | VARCHAR(100) | UNIQUE | Yes | External reference |
| payment_status | VARCHAR(20) | CHECK | No | Processing state |

Allowed `payment_method`: `Cash`, `Card`, `Transfer`, `Mobile Money`.  
Allowed `payment_status`: `Pending`, `Confirmed`, `Failed`, `Refunded`.

### 10.14 loan

| Column | Type | Key / Constraint | Null | Notes |
|---|---|---|---|---|
| loan_id | INT | PK, AUTO_INCREMENT | No | Loan identifier |
| sale_id | INT | FK -> sale, UNIQUE | No | One loan at most per sale |
| lender_name | VARCHAR(120) | - | No | Financing institution |
| principal_amount | DECIMAL(12,2) | CHECK > 0 | No | Amount borrowed |
| interest_rate | DECIMAL(5,2) | CHECK >= 0 | No | Interest percentage |
| term_months | SMALLINT | CHECK > 0 | No | Term length |
| start_date | DATE | - | No | Loan start |
| end_date | DATE | CHECK | No | Expected completion date |
| loan_status | VARCHAR(20) | CHECK | No | Loan state |

Allowed `loan_status`: `Pending`, `Active`, `Completed`, `Defaulted`.

### 10.15 loan_installment

| Column | Type | Key / Constraint | Null | Notes |
|---|---|---|---|---|
| loan_id | INT | PK, FK -> loan | No | Owner loan |
| installment_number | SMALLINT | PK, partial key | No | Sequence within loan |
| due_date | DATE | - | No | Scheduled date |
| amount_due | DECIMAL(12,2) | CHECK > 0 | No | Scheduled amount |
| amount_paid | DECIMAL(12,2) | CHECK >= 0 | No | Paid amount |
| payment_date | DATE | - | Yes | Actual payment date |
| installment_status | VARCHAR(20) | CHECK | No | Installment state |

Allowed `installment_status`: `Pending`, `Paid`, `Partially Paid`, `Overdue`.

### 10.16 service_order

| Column | Type | Key / Constraint | Null | Notes |
|---|---|---|---|---|
| service_order_id | INT | PK, AUTO_INCREMENT | No | Service-job identifier |
| customer_id | INT | FK -> customer | No | Requesting customer |
| vehicle_id | INT | FK -> vehicle | No | Vehicle serviced |
| mechanic_id | INT | FK -> mechanic(employee_id) | No | Assigned mechanic |
| service_date | DATE | - | No | Date opened/performed |
| current_mileage | INT | CHECK >= 0 | No | Mileage at service |
| service_description | VARCHAR(500) | - | No | Requested/completed work |
| labour_charge | DECIMAL(12,2) | CHECK >= 0 | No | Labour charge |
| service_status | VARCHAR(20) | CHECK | No | Service state |

Allowed `service_status`: `Scheduled`, `In Progress`, `Completed`, `Cancelled`.

### 10.17 part

| Column | Type | Key / Constraint | Null | Notes |
|---|---|---|---|---|
| part_id | INT | PK, AUTO_INCREMENT | No | Part identifier |
| part_name | VARCHAR(120) | - | No | Descriptive name |
| part_number | VARCHAR(80) | UNIQUE | No | Stock/manufacturer code |
| unit_price | DECIMAL(12,2) | CHECK >= 0 | No | Current unit price |
| quantity_in_stock | INT | CHECK >= 0 | No | Available stock |
| reorder_level | INT | CHECK >= 0 | No | Replenishment threshold |

### 10.18 service_part

| Column | Type | Key / Constraint | Null | Notes |
|---|---|---|---|---|
| service_order_id | INT | PK, FK -> service_order | No | Service order |
| part_id | INT | PK, FK -> part | No | Part used |
| quantity_used | INT | CHECK > 0 | No | Units consumed |
| unit_price_at_use | DECIMAL(12,2) | CHECK >= 0 | No | Historical price |

Primary key: `(service_order_id, part_id)`.

### 10.19 warranty

| Column | Type | Key / Constraint | Null | Notes |
|---|---|---|---|---|
| warranty_id | INT | PK, AUTO_INCREMENT | No | Warranty identifier |
| vehicle_id | INT | FK -> vehicle | No | Covered vehicle |
| provider_name | VARCHAR(120) | - | No | Coverage provider |
| provider_phone | VARCHAR(20) | - | Yes | Provider contact number |
| start_date | DATE | - | No | Coverage start |
| end_date | DATE | CHECK | No | Coverage end |
| coverage_description | VARCHAR(500) | - | No | Coverage details |
| warranty_status | VARCHAR(20) | CHECK | No | Warranty state |

Allowed `warranty_status`: `Active`, `Expired`, `Cancelled`, `Voided`.

### 10.20 warranty_claim

| Column | Type | Key / Constraint | Null | Notes |
|---|---|---|---|---|
| claim_id | INT | PK, AUTO_INCREMENT | No | Claim identifier |
| warranty_id | INT | FK -> warranty | No | Warranty used |
| service_order_id | INT | FK -> service_order | Yes | Optional supporting service job |
| claim_date | DATE | - | No | Submission date |
| claim_amount | DECIMAL(12,2) | CHECK >= 0 | No | Amount requested |
| claim_description | VARCHAR(500) | - | No | Fault/coverage request |
| claim_status | VARCHAR(20) | CHECK | No | Claim state |
| decision_date | DATE | - | Yes | Approval/rejection date |

Allowed `claim_status`: `Pending`, `Approved`, `Rejected`, `Paid`.

---

## 11. Foreign-key dependency map

- `vehicle_model.manufacturer_id` -> `manufacturer.manufacturer_id`
- `vehicle.model_id` -> `vehicle_model.model_id`
- `employee.department_id` -> `department.department_id`
- `employee.job_role_id` -> `job_role.job_role_id`
- `salesperson.employee_id` -> `employee.employee_id`
- `mechanic.employee_id` -> `employee.employee_id`
- `user_account.employee_id` -> `employee.employee_id`
- `sale.customer_id` -> `customer.customer_id`
- `sale.salesperson_id` -> `salesperson.employee_id`
- `sale_item.sale_id` -> `sale.sale_id`
- `sale_item.vehicle_id` -> `vehicle.vehicle_id`
- `payment.sale_id` -> `sale.sale_id`
- `loan.sale_id` -> `sale.sale_id`
- `loan_installment.loan_id` -> `loan.loan_id`
- `service_order.customer_id` -> `customer.customer_id`
- `service_order.vehicle_id` -> `vehicle.vehicle_id`
- `service_order.mechanic_id` -> `mechanic.employee_id`
- `service_part.service_order_id` -> `service_order.service_order_id`
- `service_part.part_id` -> `part.part_id`
- `warranty.vehicle_id` -> `vehicle.vehicle_id`
- `warranty_claim.warranty_id` -> `warranty.warranty_id`
- `warranty_claim.service_order_id` -> `service_order.service_order_id` (nullable)

---

## 12. Recommended table creation order

The integrated schema should create parent tables before dependent tables.

1. `manufacturer`
2. `vehicle_model`
3. `vehicle`
4. `department`
5. `job_role`
6. `employee`
7. `salesperson`
8. `mechanic`
9. `user_account`
10. `customer`
11. `sale`
12. `sale_item`
13. `payment`
14. `loan`
15. `loan_installment`
16. `part`
17. `service_order`
18. `service_part`
19. `warranty`
20. `warranty_claim`

The integration lead may adjust the exact file ordering as long as all foreign-key dependencies are respected.

---

## 13. Deletion and update policy

### 13.1 General rule

Do not use `ON DELETE CASCADE` for core transaction history unless the team explicitly approves a specific relationship.

### 13.2 Recommended behavior

- Reference/master data that is already used should normally be restricted from deletion.
- Sale, Payment, Loan, LoanInstallment, ServiceOrder, ServicePart, Warranty and WarrantyClaim history should be preserved.
- Status changes or archival are preferred to deletion for historical transactions.
- Subtype rows depend on Employee; subtype lifecycle behavior must be reviewed carefully during integration.

The final `ON DELETE` / `ON UPDATE` choices will be documented in the Phase 4 physical-design report and implemented consistently in the integrated schema.

---

## 14. Indexing plan for Phase 4

MySQL automatically indexes primary keys and UNIQUE constraints. Additional indexes should be added only where they support expected searches, filters or joins.

Initial indexes to consider:

- `vehicle(vehicle_status)`
- `vehicle(model_id)`
- `employee(department_id)`
- `employee(job_role_id)`
- `customer(last_name, first_name)`
- `sale(sale_date)`
- `sale(customer_id)`
- `sale(salesperson_id)`
- `payment(sale_id)`
- `loan(loan_status)`
- `loan_installment(due_date, installment_status)`
- `service_order(vehicle_id, service_date)`
- `service_order(mechanic_id, service_status)`
- `part(quantity_in_stock)` if useful for low-stock reporting
- `warranty(vehicle_id, warranty_status)`
- `warranty_claim(claim_status)`

The integration lead should review redundant indexes before merging the final schema.

---

## 15. Phase boundaries

### Phase 4 - Physical Design

Deliver:

- `CREATE DATABASE` / schema initialization;
- all 20 `CREATE TABLE` statements;
- PK, FK, UNIQUE, NOT NULL and CHECK constraints;
- AUTO_INCREMENT identifiers;
- indexes; and
- one integrated schema that runs from a clean MySQL database without errors.

### Phase 5 - Data Population

Deliver realistic DML data. Major entities should have approximately 20-30 records where realistic; smaller reference/subtype relations may contain fewer.

### Phase 6 - Database Programming

The assignment requires at minimum:

- 10 advanced SQL queries;
- 5 views;
- 3 stored procedures;
- 2 user-defined functions; and
- 3 triggers.

Do not prematurely place these objects inside Phase 4 module files unless the team agrees to stage them separately for later use.

---

## 16. Recommended Phase 6 business-rule objects

These are future targets, not Phase 4 deliverables.

### Views

1. Available vehicles with model/manufacturer details
2. Customer sale totals, payments and outstanding balances
3. Monthly sales/revenue summary
4. Salesperson performance and commission summary
5. Vehicle service history with mechanic and parts cost

### Procedures

1. Complete a sale and mark vehicles Sold in one transaction
2. Record a sale payment while preventing overpayment
3. Complete a service order and deduct parts stock

### Functions

1. Calculate outstanding sale balance
2. Calculate commission from total amount and stored commission rate

### Triggers

1. Reject a SaleItem for an unavailable/sold vehicle
2. Prevent parts usage above available stock
3. Enforce a selected warranty/sale-state business rule

---

## 17. Repository structure

```text
car-dealership-management-system/
|
|-- README.md
|-- docs/
|   |-- project_design.md
|   |-- phase1_requirements.md
|   |-- phase2_conceptual_design.md
|   |-- phase3_logical_design.md
|   `-- phase4_physical_design.md
|
|-- database/
|   |-- schema/
|   |   |-- 00_create_database.sql
|   |   |-- 01_vehicle_inventory.sql
|   |   |-- 02_employees.sql
|   |   |-- 03_customers_sales.sql
|   |   |-- 04_financing_warranty.sql
|   |   |-- 05_servicing.sql
|   |   `-- 99_full_schema.sql
|   |-- seed/
|   |-- queries/
|   |-- views/
|   |-- procedures/
|   |-- functions/
|   `-- triggers/
|
|-- diagrams/
|   |-- erd/
|   `-- relational_schema/
|
|-- app/
`-- tests/
```

---

## 18. Git and collaboration workflow

No one should develop directly on `main` after the shared setup is complete.

### Start work

```bash
git checkout main
git pull origin main
git checkout <your-branch>
git merge main
```

### Commit and push

```bash
git add .
git commit -m "Clear description of the work"
git push origin <your-branch>
```

Then open a Pull Request into `main`.

### Pull Request review

A Phase 4 PR should be reviewed by Jamal or Ean before merge.

Every PR description must state:

- tables/files implemented;
- keys and constraints added;
- dependencies on other modules;
- how the SQL was tested in MySQL;
- known limitations or Phase 6 rules not yet implemented.

---

## 19. File ownership during Phase 4

To reduce merge conflicts, every member owns one implementation file containing exactly their four assigned entities.

- Ean -> `database/schema/01_ean_core.sql`
  - manufacturer
  - vehicle_model
  - vehicle
  - employee

- Jamal -> `database/schema/02_jamal_sales.sql`
  - salesperson
  - sale
  - sale_item
  - payment

- Charles -> `database/schema/03_charles_customer_access.sql`
  - customer
  - department
  - job_role
  - user_account

- Winfred -> `database/schema/04_winfred_service.sql`
  - mechanic
  - service_order
  - part
  - service_part

- Nasir -> `database/schema/05_nasir_financing_warranty.sql`
  - loan
  - loan_installment
  - warranty
  - warranty_claim

Jamal owns `database/schema/00_create_database.sql` and the final integrated `database/schema/99_full_schema.sql`.

Team members should not independently edit another member's module file or `99_full_schema.sql` unless that change has been agreed during review.

---

## 20. Phase 4 definition of done

A member's module is complete only when all applicable items are satisfied:

- [ ] Every assigned table is implemented.
- [ ] Column names match this guide.
- [ ] Data types match this guide.
- [ ] Primary keys are correct.
- [ ] Foreign keys are correct.
- [ ] Composite keys are correct.
- [ ] UNIQUE constraints are correct.
- [ ] NOT NULL / nullable decisions match the data dictionary.
- [ ] CHECK constraints are implemented where appropriate.
- [ ] AUTO_INCREMENT is applied where appropriate.
- [ ] Controlled status values are implemented consistently.
- [ ] Delete/update behavior is explicit or intentionally uses MySQL's restrictive default.
- [ ] SQL executes successfully in MySQL.
- [ ] The developer tested the file from a clean state or against the required parent schema.
- [ ] No Phase 3 relation or attribute was silently renamed/removed.
- [ ] Any proposed design change is documented and approved before merge.
- [ ] Pull Request submitted.
- [ ] Pull Request reviewed.
- [ ] Requested fixes completed.
- [ ] Pull Request merged into `main`.

The overall Phase 4 is complete only when `database/schema/99_full_schema.sql` creates the entire database from scratch without errors and the resulting schema matches the approved 20-relation design.

---

## 21. Testing checklist for integration

Jamal and Ean should verify at minimum:

1. all 20 tables exist;
2. duplicate VIN is rejected;
3. duplicate username is rejected;
4. a second UserAccount for one Employee is rejected;
5. a second Loan for one Sale is rejected;
6. duplicate SaleItem vehicle usage is rejected;
7. invalid negative monetary/quantity values are rejected where Phase 4 constraints can enforce them;
8. invalid status values are rejected;
9. Warranty end date before start date is rejected;
10. subtype rows cannot reference nonexistent Employees;
11. WarrantyClaim can be created with a NULL service_order_id;
12. foreign-key references to nonexistent parents are rejected;
13. indexes exist as approved;
14. the full schema can be dropped/recreated cleanly for testing.

Cross-row transaction rules such as overpayment prevention and stock deduction are to be tested when the relevant Phase 6 programming objects are implemented.

---

## 22. Pending alignment work before final submission

The team should still update the Phase 2 ERD to reflect the finalized logical design:

- Payment: add `sale_id`, `payment_date`, `amount`, `reference_number` if absent.
- Customer: use `first_name`, `last_name`; add `registration_date` if absent.
- Employee: add `email` if absent.
- LoanInstallment: add `due_date` if absent.
- Warranty: add optional `provider_phone`.

The entity count and relationships remain unchanged.

---

## 23. Change-control rule

Any proposed change to an entity, attribute, key, datatype, relationship or business rule must be raised in the group before implementation if it contradicts this guide.

After agreement:

1. update `docs/project_design.md` first;
2. update affected Phase 2/3 documentation if necessary;
3. implement the SQL change in a branch;
4. submit a PR explaining the reason for the design change.

This prevents the documentation and database implementation from drifting apart.

---

## 24. Immediate next milestone

1. Commit this revised `project_design.md` to `main`.
2. Make the small ERD attribute-alignment edits identified in Phase 3.
3. Create all five Phase 4 feature branches.
4. Ean begins `01_ean_core.sql` with Manufacturer, VehicleModel, Vehicle and Employee.
5. Jamal begins `02_jamal_sales.sql` with Salesperson, Sale, SaleItem and Payment.
6. Charles begins `03_charles_customer_access.sql` with Customer, Department, JobRole and UserAccount.
7. Winfred begins `04_winfred_service.sql` with Mechanic, ServiceOrder, Part and ServicePart.
8. Nasir begins `05_nasir_financing_warranty.sql` with Loan, LoanInstallment, Warranty and WarrantyClaim.
9. Each member tests their module in MySQL and submits a Pull Request.
10. Jamal and Ean review the Pull Requests for naming, datatype, key and constraint consistency.
11. Jamal integrates approved definitions into `99_full_schema.sql`.
12. Jamal and Ean run full clean-build testing.
13. Complete `docs/phase4_physical_design.md` with implementation choices and evidence.
