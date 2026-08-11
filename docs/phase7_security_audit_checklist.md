# Car Dealership Management System
## Phase 7 Security Audit Checklist

**Purpose:** Final audit before Phase 7 is declared complete.

Use this checklist only after Jamal and Ean have merged their Phase 7 security implementation.

---

## A. Files and Repository Structure

- [ ] `docs/phase7_security.md` exists.
- [ ] `docs/phase7_role_privilege_matrix.md` exists.
- [ ] Jamal implementation guide exists.
- [ ] Ean implementation guide exists.
- [ ] `database/security/01_create_roles.sql` exists.
- [ ] `database/security/02_jamal_sales_finance_manager_privileges.sql` exists.
- [ ] `database/security/03_ean_admin_inventory_service_privileges.sql` exists.
- [ ] `database/security/04_jamal_security_verification.sql` exists.
- [ ] `database/security/05_ean_security_verification.sql` exists.
- [ ] `database/security/99_full_security.sql` exists.

---

## B. Role Creation

Confirm all seven roles exist:

- [ ] `dealership_admin`
- [ ] `dealership_manager`
- [ ] `dealership_salesperson`
- [ ] `dealership_finance`
- [ ] `dealership_inventory`
- [ ] `dealership_service_advisor`
- [ ] `dealership_mechanic`

- [ ] no accidental duplicate/conflicting roles exist.

---

## C. Least Privilege

- [ ] no operational role receives unnecessary `ALL PRIVILEGES`.
- [ ] Salesperson cannot administer employees/accounts.
- [ ] Salesperson cannot manage loans.
- [ ] Finance cannot modify inventory.
- [ ] Finance cannot administer user accounts.
- [ ] Inventory cannot modify payments/loans.
- [ ] Service Advisor cannot administer accounts.
- [ ] Mechanic cannot access financial-management operations.
- [ ] Mechanic update rights are restricted.
- [ ] Manager is primarily read/reporting.
- [ ] broad `DELETE` privileges are not granted to operational roles.

---

## D. Sensitive Information

- [ ] `user_account` access is restricted.
- [ ] ordinary roles cannot retrieve `password_hash`.
- [ ] employee salary access is appropriately restricted.
- [ ] no database passwords are committed.
- [ ] no backup files containing real data are committed.
- [ ] secrets are intended to be stored using environment variables/Streamlit secrets in Phase 8.

---

## E. Salesperson Tests

Expected success:

- [ ] read vehicle inventory.
- [ ] read/create/update customer.
- [ ] create sale.
- [ ] add sale item.
- [ ] read payment status.

Expected denial:

- [ ] cannot update employee salary.
- [ ] cannot administer user accounts.
- [ ] cannot create loan.
- [ ] cannot manage warranty claim.

---

## F. Finance Tests

Expected success:

- [ ] read sale/customer context.
- [ ] create payment.
- [ ] update payment.
- [ ] create/update loan.
- [ ] create/update loan installment.

Expected denial:

- [ ] cannot update vehicle.
- [ ] cannot update part.
- [ ] cannot administer user account.
- [ ] cannot alter service order.

---

## G. Manager Tests

- [ ] can read approved operational tables.
- [ ] can query approved Phase 6 reporting views.
- [ ] cannot perform unauthorized administrative changes.
- [ ] cannot perform unrestricted transaction writes.

---

## H. Administrator Tests

- [ ] can manage department.
- [ ] can manage job_role.
- [ ] can manage employee.
- [ ] can manage user_account.
- [ ] does not receive unnecessary unrestricted transaction writes.

---

## I. Inventory Tests

Expected success:

- [ ] manage manufacturer.
- [ ] manage vehicle_model.
- [ ] manage vehicle.
- [ ] manage part.

Expected denial:

- [ ] cannot create payment.
- [ ] cannot create loan.
- [ ] cannot administer user accounts.

---

## J. Service Advisor Tests

Expected success:

- [ ] read customer/vehicle/mechanic context.
- [ ] create/update service order.
- [ ] create/update service part.
- [ ] create/update warranty.
- [ ] create/update warranty claim.

Expected denial:

- [ ] cannot manage user accounts.
- [ ] cannot create loan.
- [ ] cannot create payment.
- [ ] cannot update employee salary.

---

## K. Mechanic Tests

Expected success:

- [ ] read permitted service information.
- [ ] read vehicle/parts required for service work.
- [ ] update only approved service-order fields.

Expected denial:

- [ ] cannot insert payment.
- [ ] cannot update loan.
- [ ] cannot administer user accounts.
- [ ] cannot alter sales.

---

## L. SHOW GRANTS Evidence

- [ ] Admin grants reviewed.
- [ ] Manager grants reviewed.
- [ ] Salesperson grants reviewed.
- [ ] Finance grants reviewed.
- [ ] Inventory grants reviewed.
- [ ] Service Advisor grants reviewed.
- [ ] Mechanic grants reviewed.

---

## M. Integrated Security Script

- [ ] `99_full_security.sql` contains role creation first.
- [ ] Jamal grants appear after role creation.
- [ ] Ean grants appear after role creation.
- [ ] verification tests are not mixed into the integrated setup script.
- [ ] integrated security script runs without SQL errors.
- [ ] integrated security script uses the correct database/schema name.
- [ ] referenced Phase 6 views/procedures/functions actually exist.

---

## N. Authentication Documentation

- [ ] `UserAccount -> Employee -> JobRole` flow documented.
- [ ] only active accounts can authenticate.
- [ ] password hashing documented.
- [ ] Streamlit session strategy documented.
- [ ] backend authorization checks documented.
- [ ] parameterized-query requirement documented.

---

## O. Backup and Recovery

- [ ] backup method documented.
- [ ] restore method documented.
- [ ] backup storage considerations documented.
- [ ] backups excluded from the public repository.
- [ ] at least one backup created.
- [ ] at least one restore test performed.
- [ ] restored schema verified.
- [ ] restored sample data verified.

---

## P. Git and Quality Checks

Run:

```bash
git status
git diff --check
```

- [ ] working tree is clean before final Phase 7 merge.
- [ ] no accidental generated/credential files are tracked.
- [ ] both Jamal and Ean PRs were reviewed.
- [ ] final Phase 7 commit is on `main`.

---

# Final Decision

### Phase 7 PASS

Mark PASS only if:

- all required roles and privileges are implemented;
- authorized operations succeed;
- unauthorized operations are denied;
- authentication strategy is documented;
- backup/recovery is documented and restore-tested;
- the integrated security script runs successfully.

**Final status:** ______________________

**Audited by:** ______________________

**Date:** ______________________
