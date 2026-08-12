USE car_dealership_db;

-- =====================================================
-- PHASE 5: CHARLES - PEOPLE, ORGANIZATION AND CUSTOMERS
-- =====================================================
-- Shared ID contract:
-- departments: 1-6
-- job roles: 1-9
-- employees: 1-18
-- salespersons: employees 1-6
-- mechanics: employees 7-12 (mechanic subtype rows added by Winfred)
-- user accounts: 1-12
-- customers: 1-30
-- =====================================================

START TRANSACTION;

-- =====================================================
-- DEPARTMENTS
-- =====================================================

INSERT INTO department
(department_id, department_name, description)
VALUES
(1, 'Sales', 'Handles vehicle sales and customer purchases'),
(2, 'Finance', 'Handles financing, payments and loan administration'),
(3, 'Service', 'Handles vehicle servicing, repairs and maintenance'),
(4, 'Human Resources', 'Handles employee administration and staff welfare'),
(5, 'IT', 'Manages dealership information systems and technical support'),
(6, 'Administration', 'Oversees general dealership administration and management');

-- =====================================================
-- JOB ROLES
-- =====================================================

INSERT INTO job_role
(job_role_id, role_title, description)
VALUES
(1, 'Sales Consultant', 'Assists customers with vehicle selection and purchases'),
(2, 'Sales Manager', 'Supervises the dealership sales team'),
(3, 'Finance Officer', 'Handles payments, loans and financing records'),
(4, 'Service Advisor', 'Coordinates customer vehicle service requests'),
(5, 'Technician', 'Performs vehicle inspection, maintenance and repair work'),
(6, 'HR Officer', 'Handles employee administration and human-resource activities'),
(7, 'IT Support Officer', 'Provides technical and information-system support'),
(8, 'Branch Manager', 'Oversees dealership operations and performance'),
(9, 'Inventory Officer', 'Manages vehicle and parts inventory');

-- =====================================================
-- EMPLOYEES
-- =====================================================
-- Employees 1-6 are salespersons.
-- Employees 7-12 will become mechanic subtype records
-- in Winfred's Phase 5 file.
-- Employees 13-18 are other dealership staff.
-- =====================================================

INSERT INTO employee
(employee_id, department_id, job_role_id, first_name, last_name,
 phone, email, hire_date, salary, employee_status)
VALUES
(1, 1, 1, 'John', 'Mensah', '0244000001',
 'john.mensah@cardealer.com', '2022-02-14', 6500.00, 'Active'),

(2, 1, 1, 'Ama', 'Owusu', '0244000002',
 'ama.owusu@cardealer.com', '2022-08-08', 6400.00, 'Active'),

(3, 1, 1, 'Kwame', 'Boateng', '0244000003',
 'kwame.boateng@cardealer.com', '2023-01-16', 6100.00, 'Active'),

(4, 1, 1, 'Akosua', 'Asante', '0244000004',
 'akosua.asante@cardealer.com', '2023-05-22', 6000.00, 'Active'),

(5, 1, 1, 'Kofi', 'Adjei', '0244000005',
 'kofi.adjei@cardealer.com', '2023-09-04', 5900.00, 'Active'),

(6, 1, 2, 'Abena', 'Mensah', '0244000006',
 'abena.mensah@cardealer.com', '2021-06-07', 8500.00, 'Active'),

(7, 3, 5, 'Yaw', 'Asare', '0244000007',
 'yaw.asare@cardealer.com', '2022-04-11', 5700.00, 'Active'),

(8, 3, 5, 'Esi', 'Owusu', '0244000008',
 'esi.owusu@cardealer.com', '2022-10-03', 5600.00, 'Active'),

(9, 3, 5, 'Kojo', 'Appiah', '0244000009',
 'kojo.appiah@cardealer.com', '2023-02-20', 5450.00, 'Active'),

(10, 3, 5, 'Mavis', 'Agyeman', '0244000010',
 'mavis.agyeman@cardealer.com', '2023-07-10', 5400.00, 'Active'),

(11, 3, 5, 'Kweku', 'Addo', '0244000011',
 'kweku.addo@cardealer.com', '2024-01-15', 5200.00, 'Active'),

(12, 3, 5, 'Selina', 'Kusi', '0244000012',
 'selina.kusi@cardealer.com', '2024-03-18', 5100.00, 'Active'),

(13, 2, 3, 'Daniel', 'Arthur', '0244000013',
 'daniel.arthur@cardealer.com', '2022-05-09', 6800.00, 'Active'),

(14, 3, 4, 'Priscilla', 'Kwarteng', '0244000014',
 'priscilla.kwarteng@cardealer.com', '2023-04-17', 6200.00, 'Active'),

(15, 4, 6, 'Emmanuel', 'Tetteh', '0244000015',
 'emmanuel.tetteh@cardealer.com', '2021-11-01', 6600.00, 'Active'),

(16, 5, 7, 'Rita', 'Asiedu', '0244000016',
 'rita.asiedu@cardealer.com', '2023-06-12', 6400.00, 'Active'),

(17, 6, 8, 'Samuel', 'Kwakye', '0244000017',
 'samuel.kwakye@cardealer.com', '2020-08-03', 9800.00, 'Active'),

(18, 2, 3, 'Adwoa', 'Frimpong', '0244000018',
 'adwoa.frimpong@cardealer.com', '2024-02-05', 6000.00, 'Active');

-- =====================================================
-- SALESPERSON SUBTYPE
-- =====================================================

INSERT INTO salesperson
(employee_id, commission_rate, sales_target)
VALUES
(1, 3.00, 900000.00),
(2, 3.00, 850000.00),
(3, 2.75, 800000.00),
(4, 2.75, 800000.00),
(5, 2.50, 750000.00),
(6, 3.50, 1200000.00);

-- =====================================================
-- USER ACCOUNTS
-- =====================================================
-- Only selected employees receive accounts.
-- Passwords are stored as hashes, not plaintext.
-- =====================================================

INSERT INTO user_account
(user_id, employee_id, username, password_hash, account_status)
VALUES
(1, 1, 'john.mensah', SHA2('Password123!', 256), 'Active'),
(2, 2, 'ama.owusu', SHA2('Password123!', 256), 'Active'),
(3, 3, 'kwame.boateng', SHA2('Password123!', 256), 'Active'),
(4, 4, 'akosua.asante', SHA2('Password123!', 256), 'Active'),
(5, 5, 'kofi.adjei', SHA2('Password123!', 256), 'Active'),
(6, 6, 'abena.mensah', SHA2('Password123!', 256), 'Active'),
(7, 7, 'yaw.asare', SHA2('Password123!', 256), 'Active'),
(8, 8, 'esi.owusu', SHA2('Password123!', 256), 'Active'),
(9, 9, 'kojo.appiah', SHA2('Password123!', 256), 'Active'),
(10, 10, 'mavis.agyeman', SHA2('Password123!', 256), 'Active'),
(11, 11, 'kweku.addo', SHA2('Password123!', 256), 'Active'),
(12, 12, 'selina.kusi', SHA2('Password123!', 256), 'Active');

-- =====================================================
-- CUSTOMERS
-- =====================================================

INSERT INTO customer
(customer_id, first_name, last_name, phone, email, address, registration_date)
VALUES
(1, 'Kwame', 'Mensah', '0244101001',
 'kwame.mensah@example.com', '12 Independence Avenue, Accra', '2024-01-15'),

(2, 'Ama', 'Owusu', '0244101002',
 'ama.owusu@example.com', '25 Oxford Street, Osu', '2024-01-26'),

(3, 'Kofi', 'Asante', '0244101003',
 'kofi.asante@example.com', '8 Ring Road Central, Accra', '2024-02-08'),

(4, 'Abena', 'Boateng', '0244101004',
 'abena.boateng@example.com', '41 Liberation Road, Accra', '2024-02-21'),

(5, 'Yaw', 'Ofori', '0244101005',
 'yaw.ofori@example.com', '17 East Legon, Accra', '2024-03-12'),

(6, 'Akosua', 'Adjei', '0244101006',
 'akosua.adjei@example.com', '33 Spintex Road, Accra', '2024-03-29'),

(7, 'Kojo', 'Appiah', '0244101007',
 'kojo.appiah@example.com', '6 Osu Oxford Street, Accra', '2024-04-10'),

(8, 'Esi', 'Amoah', '0244101008',
 'esi.amoah@example.com', '19 Labone Crescent, Accra', '2024-04-23'),

(9, 'Kwesi', 'Darko', '0244101009',
 'kwesi.darko@example.com', '27 Cantonments Road, Accra', '2024-05-04'),

(10, 'Adwoa', 'Frimpong', '0244101010',
 'adwoa.frimpong@example.com', '14 East Legon Hills, Accra', '2024-05-18'),

(11, 'Kwadwo', 'Bonsu', '0244101011',
 'kwadwo.bonsu@example.com', '52 Accra Central, Accra', '2024-06-03'),

(12, 'Afia', 'Sarpong', '0244101012',
 'afia.sarpong@example.com', '9 Dansoman Estate, Accra', '2024-06-20'),

(13, 'Nana', 'Yeboah', '0244101013',
 'nana.yeboah@example.com', '21 Airport Residential Area, Accra', '2024-07-02'),

(14, 'Mavis', 'Agyeman', '0244101014',
 'mavis.agyeman@example.com', '37 Teshie Road, Accra', '2024-07-19'),

(15, 'Fiifi', 'Quaye', '0244101015',
 'fiifi.quaye@example.com', '11 Kaneshie Main Road, Accra', '2024-08-05'),

(16, 'Akua', 'Acheampong', '0244101016',
 'akua.acheampong@example.com', '44 Madina Road, Accra', '2024-08-27'),

(17, 'Kweku', 'Addo', '0244101017',
 'kweku.addo@example.com', '16 Adenta Housing, Accra', '2024-09-11'),

(18, 'Maame', 'Gyasi', '0244101018',
 'maame.gyasi@example.com', '29 Taifa Road, Accra', '2024-09-25'),

(19, 'Selina', 'Kusi', '0244101019',
 'selina.kusi@example.com', '7 Achimota Avenue, Accra', '2024-10-14'),

(20, 'Daniel', 'Arthur', '0244101020',
 'daniel.arthur@example.com', '23 Tesano Road, Accra', '2024-11-01'),

(21, 'Michael', 'Aidoo', '0244101021',
 'michael.aidoo@example.com', '35 Dzorwulu Road, Accra', '2024-11-19'),

(22, 'Priscilla', 'Kwarteng', '0244101022',
 'priscilla.kwarteng@example.com', '18 North Legon, Accra', '2024-12-06'),

(23, 'Emmanuel', 'Tetteh', '0244101023',
 'emmanuel.tetteh@example.com', '46 Nungua Road, Accra', '2025-01-13'),

(24, 'Rita', 'Asiedu', '0244101024',
 'rita.asiedu@example.com', '10 Ashaley Botwe, Accra', '2025-02-04'),

(25, 'Samuel', 'Kwakye', '0244101025',
 'samuel.kwakye@example.com', '31 Haatso Road, Accra', '2025-03-17'),

(26, 'Naana', 'Adu', '0244101026',
 'naana.adu@example.com', '22 Community 12, Tema', '2025-04-09'),

(27, 'Joseph', 'Annan', '0244101027',
 'joseph.annan@example.com', '15 Sakumono Estate, Tema', '2025-05-22'),

(28, 'Patricia', 'Osei', '0244101028',
 'patricia.osei@example.com', '28 Atomic Hills, Accra', '2025-07-08'),

(29, 'Richard', 'Amankwah', '0244101029',
 'richard.amankwah@example.com', '40 Lakeside Estate, Accra', '2025-09-16'),

(30, 'Gifty', 'Agyapong', '0244101030',
 'gifty.agyapong@example.com', '13 Community 25, Tema', '2026-01-20');

COMMIT;
