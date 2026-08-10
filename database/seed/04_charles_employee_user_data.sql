USE car_dealership;

-- Employee records
INSERT INTO employee
(department_id, job_role_id, first_name, last_name, phone, email, hire_date, salary, employee_status)
VALUES
(1, 1, 'John', 'Mensah', '0244000001', 'john.mensah@cardealer.com', '2023-01-15', 6500.00, 'Active'),
(2, 2, 'Ama', 'Owusu', '0244000002', 'ama.owusu@cardealer.com', '2023-03-10', 7200.00, 'Active'),
(3, 3, 'Kwame', 'Boateng', '0244000003', 'kwame.boateng@cardealer.com', '2022-06-20', 5800.00, 'Active'),
(4, 4, 'Akosua', 'Asante', '0244000004', 'akosua.asante@cardealer.com', '2024-01-08', 5000.00, 'Active'),
(5, 5, 'Kofi', 'Adjei', '0244000005', 'kofi.adjei@cardealer.com', '2023-08-14', 5500.00, 'Active'),
(6, 6, 'Abena', 'Mensah', '0244000006', 'abena.mensah@cardealer.com', '2022-11-01', 6200.00, 'Active'),
(7, 7, 'Yaw', 'Asare', '0244000007', 'yaw.asare@cardealer.com', '2024-02-12', 4800.00, 'Active'),
(8, 8, 'Esi', 'Owusu', '0244000008', 'esi.owusu@cardealer.com', '2023-05-22', 5200.00, 'Active');

-- User account records
INSERT INTO user_account
(employee_id, username, password_hash, account_status)
VALUES
(1, 'john.mensah', SHA2('Password123!', 256), 'Active'),
(2, 'ama.owusu', SHA2('Password123!', 256), 'Active'),
(3, 'kwame.boateng', SHA2('Password123!', 256), 'Active'),
(4, 'akosua.asante', SHA2('Password123!', 256), 'Active'),
(5, 'kofi.adjei', SHA2('Password123!', 256), 'Active'),
(6, 'abena.mensah', SHA2('Password123!', 256), 'Active'),
(7, 'yaw.asare', SHA2('Password123!', 256), 'Active'),
(8, 'esi.owusu', SHA2('Password123!', 256), 'Active');