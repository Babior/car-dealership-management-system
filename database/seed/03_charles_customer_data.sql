USE car_dealership;

PHASE 5: REFERENCE DATA


Departments
INSERT INTO department (department_name, description) VALUES
('Sales', 'Handles vehicle sales and customer purchases'),
('Finance', 'Handles financing and payment-related activities'),
('Service', 'Handles vehicle servicing and maintenance'),
('Human Resources', 'Handles employee administration and welfare'),
('Marketing', 'Handles advertising and promotional activities'),
('Administration', 'Handles general administrative activities'),
('Customer Service', 'Handles customer enquiries and support'),
('IT', 'Manages information systems and technical support');

Job Roles
INSERT INTO job_role (role_title, description) VALUES
('Sales Consultant', 'Assists customers with vehicle purchases'),
('Sales Manager', 'Manages the dealership sales team'),
('Finance Officer', 'Handles vehicle financing and payment arrangements'),
('Service Advisor', 'Coordinates customer vehicle service requests'),
('Technician', 'Performs vehicle inspections and repairs'),
('HR Officer', 'Handles employee administration and HR activities'),
('Marketing Officer', 'Manages marketing and promotional activities'),
('Customer Service Officer', 'Handles customer enquiries and complaints'),
('IT Support Officer', 'Provides technical and system support'),
('Branch Manager', 'Oversees dealership operations');

Customer Records
INSERT INTO customer
(first_name, last_name, phone, email, address)
VALUES
('Kwame', 'Mensah', '0244001001', 'kwame.mensah@example.com', '12 Independence Avenue'),
('Ama', 'Owusu', '0244001002', 'ama.owusu@example.com', '25 Oxford Street'),
('Kofi', 'Asante', '0244001003', 'kofi.asante@example.com', '8 Ring Road'),
('Abena', 'Boateng', '0244001004', 'abena.boateng@example.com', '41 Liberation Road'),
('Yaw', 'Ofori', '0244001005', 'yaw.ofori@example.com', '17 Nii Nortei Nyanchi Street'),
('Akosua', 'Adjei', '0244001006', 'akosua.adjei@example.com', '33 Spintex Road'),
('Kojo', 'Appiah', '0244001007', 'kojo.appiah@example.com', '6 Osu Oxford Street'),
('Esi', 'Amoah', '0244001008', 'esi.amoah@example.com', '19 Labone Crescent'),
('Kwesi', 'Darko', '0244001009', 'kwesi.darko@example.com', '27 Cantonments Road'),
('Adwoa', 'Frimpong', '0244001010', 'adwoa.frimpong@example.com', '14 East Legon Hills'),
('Kwadwo', 'Bonsu', '0244001011', 'kwadwo.bonsu@example.com', '52 Accra Central'),
('Afia', 'Sarpong', '0244001012', 'afia.sarpong@example.com', '9 Dansoman Estate'),
('Nana', 'Yeboah', '0244001013', 'nana.yeboah@example.com', '21 Airport Residential Area'),
('Mavis', 'Agyeman', '0244001014', 'mavis.agyeman@example.com', '37 Teshie Road'),
('Fiifi', 'Quaye', '0244001015', 'fiifi.quaye@example.com', '11 Kaneshie Main Road'),
('Akua', 'Acheampong', '0244001016', 'akua.acheampong@example.com', '44 Madina Road'),
('Kweku', 'Addo', '0244001017', 'kweku.addo@example.com', '16 Adenta Housing'),
('Maame', 'Gyasi', '0244001018', 'maame.gyasi@example.com', '29 Taifa Road'),
('Selina', 'Kusi', '0244001019', 'selina.kusi@example.com', '7 Achimota Avenue'),
('Daniel', 'Arthur', '0244001020', 'daniel.arthur@example.com', '23 Tesano Road'),
('Michael', 'Aidoo', '0244001021', 'michael.aidoo@example.com', '35 Dzorwulu Road'),
('Priscilla', 'Kwarteng', '0244001022', 'priscilla.kwarteng@example.com', '18 North Legon'),
('Emmanuel', 'Tetteh', '0244001023', 'emmanuel.tetteh@example.com', '46 Nungua Road'),
('Rita', 'Asiedu', '0244001024', 'rita.asiedu@example.com', '10 Ashaley Botwe'),
('Samuel', 'Kwakye', '0244001025', 'samuel.kwakye@example.com', '31 Haatso Road');