CREATE TABLE department ( department_id INT AUTO_INCREMENT PRIMARY KEY,
 department_name VARCHAR(80) NOT NULL UNIQUE, description VARCHAR(255)
);

CREATE TABLE job_role ( job_role_id INT AUTO_INCREMENT PRIMARY KEY,
role_title VARCHAR(80) NOT NULL UNIQUE, description VARCHAR(255)
);

CREATE TABLE customer (customer_id INT AUTO_INCREMENT PRIMARY KEY,
first_name VARCHAR(60) NOT NULL, last_name VARCHAR(60) NOT NULL,
phone VARCHAR(20) NOT NULL, email VARCHAR(120) UNIQUE,
address VARCHAR(255), registration_date DATE NOT NULL DEFAULT (CURRENT_DATE)
);

CREATE TABLE user_account ( user_id INT AUTO_INCREMENT PRIMARY KEY,
employee_id INT NOT NULL UNIQUE, username VARCHAR(60) NOT NULL UNIQUE,
password_hash VARCHAR(255) NOT NULL, account_status VARCHAR(20) NOT NULL,
created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, last_login DATETIME,
    
CONSTRAINT fk_user_account_employee
FOREIGN KEY (employee_id)
REFERENCES employee(employee_id),
CONSTRAINT chk_user_account_status
CHECK (account_status IN ('Active', 'Locked', 'Disabled'))
);
