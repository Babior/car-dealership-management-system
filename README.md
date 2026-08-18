# Car Dealership Management System

**Course:** CS323 Database Systems
**University:** Ashesi University
**Group:** 11

---

## 1. Project Name

**Car Dealership Management System**

The Car Dealership Management System is a database-driven application developed to support the major operations of a car dealership.

The system manages:

* Vehicle inventory
* Customers
* Employees
* Sales
* Payments
* Vehicle financing
* Loan instalments
* Vehicle servicing
* Parts inventory
* Warranties
* Warranty claims
* Sales reports
* User authentication and role-based access

The application provides a user-friendly interface for interacting with a relational MySQL database while database constraints, procedures, functions, views, and triggers help maintain data integrity and enforce business rules.

---

## 2. Group Members

Jamal Kwesi Gbana 
Paa Ekow Ean Ackon 
Charles Okai 
Nasir Kobby Koranteng 
Winfred Nana Kwasi Asantey 


---

## 3. Technologies Used

The project was developed using the following technologies:

| Component                  | Technology                           |
| -------------------------- | ------------------------------------ |
| Database Management System | MySQL                                |
| Database Language          | SQL                                  |
| Programming Language       | Python                               |
| Application Framework      | Streamlit                            |
| Database Connectivity      | MySQL Connector for Python           |
| Version Control            | Git                                  |
| Repository Hosting         | GitHub                               |
| Development Environment    | Visual Studio Code / Terminal        |
| Database Administration    | MySQL Command Line / MySQL Workbench |

---

## 4. Database Management System

The project uses **MySQL** as the Database Management System.

The database is named:

```text
car_dealership_db
```

The final database contains **20 relational tables** covering the main dealership operations.

The database implementation includes:

* Primary keys
* Foreign keys
* Unique constraints
* Check constraints
* Indexes
* Views
* Stored procedures
* User-defined functions
* Triggers
* Database roles and privileges

---

## 5. Programming Language and Framework

The application was developed using:

* **Python**
* **Streamlit**

Python handles the application logic and database interaction, while Streamlit provides the web-based user interface.

The main application entry point is:

```text
app/main.py
```

---

# Installation

## 6. Prerequisites

Before installing the application, make sure the following are installed:

* Python 3
* MySQL Server
* Git
* A GitHub account with access to the project repository

Optional tools:

* Visual Studio Code
* MySQL Workbench

You can verify the installations using:

```bash
python3 --version
mysql --version
git --version
```

---

## 7. Clone the Repository

Clone the repository from GitHub:

```bash
git clone https://github.com/Babior/car-dealership-management-system.git
```

Move into the project folder:

```bash
cd car-dealership-management-system
```

Make sure you are using the latest version of the `main` branch:

```bash
git switch main
git pull origin main
```

---

## 8. Create a Virtual Environment

### macOS / Linux

Create the virtual environment:

```bash
python3 -m venv .venv
```

Activate it:

```bash
source .venv/bin/activate
```

### Windows

Create the virtual environment:

```powershell
python -m venv .venv
```

Activate it:

```powershell
.venv\Scripts\Activate.ps1
```

---

## 9. Install Application Dependencies

Install the required Python packages:

```bash
pip install -r requirements.txt
```

---

# Database Setup

## 10. Create the Database

Make sure the MySQL server is running.

From the project root folder, run:

```bash
mysql -u root -p < database/schema/00_create_database.sql
```

Enter your local MySQL password when prompted.

This creates the project database:

```text
car_dealership_db
```

---

## 11. Create the Database Tables

Run the complete database schema:

```bash
mysql -u root -p car_dealership_db < database/schema/99_full_schema.sql
```

The full schema creates the project's 20 relational tables and their main constraints.

To verify that the tables were created:

```bash
mysql -u root -p -D car_dealership_db -e "SHOW TABLES;"
```

---

# Database Population

## 12. Populate the Database

The sample data is stored inside:

```text
database/seed/
```

The seed files should be executed in numerical order because later files depend on records created by earlier files.

Run:

```bash
mysql -u root -p car_dealership_db < database/seed/01_charles_people_customers.sql
```

Then:

```bash
mysql -u root -p car_dealership_db < database/seed/02_winfred_inventory_base.sql
```

Then:

```bash
mysql -u root -p car_dealership_db < database/seed/03_charles_sales_payments.sql
```

Then:

```bash
mysql -u root -p car_dealership_db < database/seed/04_winfred_service_records.sql
```

Finally:

```bash
mysql -u root -p car_dealership_db < database/seed/05_financing_warranty_records.sql
```

After loading the seed data, the database will contain fictional dealership records for testing and demonstration.

---

# Additional Database Objects

## 13. Load Views

Run the view scripts:

```bash
mysql -u root -p car_dealership_db < database/views/01_jamal_views.sql
mysql -u root -p car_dealership_db < database/views/02_ean_views.sql
```

---

## 14. Load Stored Procedures

Run:

```bash
mysql -u root -p car_dealership_db < database/procedures/01_jamal_procedures.sql
mysql -u root -p car_dealership_db < database/procedures/02_ean_procedures.sql
```

---

## 15. Load User-Defined Functions

Run:

```bash
mysql -u root -p car_dealership_db < database/functions/01_jamal_functions.sql
```

---

## 16. Load Triggers

Run:

```bash
mysql -u root -p car_dealership_db < database/triggers/01_business_rule_triggers.sql
```

The triggers help enforce business rules such as transaction validation and data-integrity requirements.

---

## 17. Load Database Security

Run the complete security configuration:

```bash
mysql -u root -p car_dealership_db < database/security/99_full_security.sql
```

The security scripts define database roles and privileges used by the project.

---

# Application Configuration

## 18. Configure the Database Connection

The Streamlit application uses a local secrets file to connect to MySQL.

The repository contains:

```text
.streamlit/secrets.toml.example
```

Create your own local secrets file:

```bash
cp .streamlit/secrets.toml.example .streamlit/secrets.toml
```

Update it with your local MySQL credentials.

Example:

```toml
[mysql]
host = "localhost"
port = 3306
user = "root"
password = "YOUR_MYSQL_PASSWORD"
database = "car_dealership_db"
```

Replace:

```text
YOUR_MYSQL_PASSWORD
```

with the MySQL password configured on your computer.


---

# Running the Application

## 19. Start the Application

Make sure:

1. MySQL Server is running.
2. The database has been created.
3. The schema has been loaded.
4. The seed data has been loaded.
5. The database views, procedures, functions, and triggers have been created.
6. The Python virtual environment is active.

Start the Streamlit application with:

```bash
python -m streamlit run app/main.py
```

Streamlit should automatically open the application in your browser.

If it does not open automatically, visit:

```text
http://localhost:8501
```

To stop the application, press:

```text
Ctrl + C
```

---

# Test Accounts

## 20. Test Account Credentials



| Username                | Password                | Role                 |
| ----------------------- | ----------------------- | -------------------- |
| `john.mensah`           | `Password123!`          | Sales Consultant     |
| `abena.mensah`          | `Password123`           | Sales Manager        |
| `yaw.asare`             | `Password123`           |  Technician          |

---

# Quick Start Summary

For an already configured project, the normal startup process is:

```bash
cd car-dealership-management-system
```

Activate the virtual environment:

```bash
source .venv/bin/activate
```

Make sure MySQL is running, then start the application:

```bash
python -m streamlit run app/main.py
```

---

