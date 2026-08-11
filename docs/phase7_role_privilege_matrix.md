# Car Dealership Management System
## Phase 7 Role-Privilege Matrix

**Purpose:** Single source of truth for Phase 7 MySQL privilege implementation.

### Legend

- `C` = INSERT / Create
- `R` = SELECT / Read
- `U` = UPDATE
- `D` = DELETE
- `-` = No direct table privilege

Operational roles should normally not receive `DELETE`.

> Note: Stored procedures and views created in Phase 6 should receive `EXECUTE`/`SELECT` only after the team confirms their exact object names. Do not invent object names in the security scripts.

---

## 1. Table-Level Matrix

| Table | Admin | Manager | Salesperson | Finance | Inventory | Service Advisor | Mechanic |
|---|---|---|---|---|---|---|---|
| manufacturer | R | R | R | - | CRU | R | - |
| vehicle_model | R | R | R | - | CRU | R | - |
| vehicle | R | R | R | R | CRU | R | R |
| department | CRU | R | - | - | - | - | - |
| job_role | CRU | R | - | - | - | - | - |
| employee | CRU | R | - | - | - | R* | R* |
| salesperson | R | R | R | R | - | - | - |
| mechanic | R | R | - | - | - | R | R |
| user_account | CRU | - | - | - | - | - | - |
| customer | R | R | CRU | R | - | R | R* |
| sale | R | R | CRU | R | - | R | - |
| sale_item | R | R | CR | R | - | R | - |
| payment | R | R | R | CRU | - | - | - |
| loan | R | R | - | CRU | - | - | - |
| loan_installment | R | R | - | CRU | - | - | - |
| service_order | R | R | R | - | R | CRU | RU* |
| part | R | R | R | - | CRU | R | R |
| service_part | R | R | - | - | R | CRU | R |
| warranty | R | R | R | - | - | CRU | R |
| warranty_claim | R | R | R | - | - | CRU | R |

`*` indicates that the implementation should prefer restricted/column-level access where practical.

---

## 2. Important Restrictions

### Administrator

Administrator manages organizational/access data but does not receive unrestricted write access to all transactions.

Primary write tables:

- `department`
- `job_role`
- `employee`
- `user_account`

### Manager

Manager has broad read access for reporting and monitoring.

Manager should not automatically receive broad transaction write access.

### Salesperson

Salesperson may:

- read inventory information;
- create/update customers;
- create/update sales;
- add sale items;
- read payment status.

Salesperson may not:

- manage loans;
- manage employee accounts;
- modify parts inventory;
- administer warranties;
- change employee salaries.

### Finance Officer

Finance may:

- read customer/sale context;
- create/update payments;
- create/update loans;
- create/update loan installments.

Finance may not:

- update vehicle inventory;
- update parts inventory;
- manage employee/user accounts;
- modify service records.

### Inventory Officer

Inventory may create/read/update:

- manufacturers;
- vehicle models;
- vehicles;
- parts.

Inventory may not manage:

- sales transactions;
- payments;
- loans;
- user accounts.

### Service Advisor

Service Advisor may:

- read customers, vehicles and mechanics;
- create/update service orders;
- create/update service-part records;
- create/update warranties and claims;
- read part information.

Service Advisor does not manage payments, loans or user accounts.

### Mechanic

Mechanic is highly restricted.

Preferred access:

- read assigned service information;
- read vehicle and part information;
- update only permitted service-order fields.

Recommended column-level `UPDATE` on `service_order`:

- `service_status`
- `service_description`
- `current_mileage`

Do not grant mechanic direct update rights to financial fields such as `labour_charge` unless the team explicitly approves it.

---

## 3. Sensitive Columns

Where practical, restrict access to:

- `user_account.password_hash`
- `employee.salary`

Do not expose `password_hash` to ordinary operational roles.

For Manager access to Employee information, consider either:

1. a reporting view that excludes `password_hash` and other unnecessary fields; or
2. column-level `SELECT` privileges if the team chooses to implement them.

---

## 4. Phase 6 Objects

After confirming the exact implemented object names, add appropriate permissions for:

- reporting views -> usually `SELECT`;
- approved operational stored procedures -> usually `EXECUTE`;
- user-defined functions -> `EXECUTE` where required.

Triggers do not require end-user execution grants because they fire automatically.

---

## 5. Change Control

Any privilege change that differs from this matrix must be:

1. discussed by Jamal and Ean;
2. documented with a reason;
3. reflected in this matrix;
4. tested in the relevant verification script.
