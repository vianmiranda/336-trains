table = '''USE trains;\n'''

clearTable = '''SET FOREIGN_KEY_CHECKS=0; 
TRUNCATE TABLE Answers;
TRUNCATE TABLE Questions;
TRUNCATE TABLE Customer;
TRUNCATE TABLE Manages;
TRUNCATE TABLE Employee;
TRUNCATE TABLE Stop;
TRUNCATE TABLE TransitLine;
TRUNCATE TABLE Train;
TRUNCATE TABLE Station;
SET FOREIGN_KEY_CHECKS=1;
'''

customerFormat = '''INSERT INTO Customer (customerId, firstName, lastName, username, password, email) 
VALUES
    (1, 'Alice', 'Green', 'aliceg', 'securepass1', 'alice@example.com'),
    (2, 'Bob', 'White', 'bobw', 'securepass2', 'bob@example.com'),
    (3, 'Charlie', 'Black', 'charlieb', 'securepass3', 'charlie@example.com'),
    (4, 'Daisy', 'Brown', 'daisyb', 'securepass4', 'daisy@example.com'),
    (5, 'Evan', 'Gray', 'evang', 'securepass5', 'evan@example.com');
'''
employeeFormat = '''INSERT INTO Employee (ssn, firstName, lastName, username, password, role) 
VALUES
    ('111-11-1111', 'employee', 'one', 'emp1', 'emp1', 'Representative'),
    ('123-45-6789', 'John', 'Doe', 'jdoe', 'password123', 'Manager'),
    ('222-22-2222', 'manager', 'one', 'mgr1', 'mgr1', 'Manager'),
    ('321-65-9874', 'Michael', 'Johnson', 'mjohnson', 'passwordabc', 'Manager'),
    ('456-78-9012', 'Emily', 'Brown', 'ebrown', 'password789', 'Representative'),
    ('654-32-1098', 'Sarah', 'Taylor', 'staylor', 'passwordxyz', 'Representative'),
    ('987-65-4321', 'Jane', 'Smith', 'jsmith', 'password456', 'Representative');
'''

managesFormat = '''INSERT INTO Manages (manager_ssn, representative_ssn) 
VALUES
    ('123-45-6789', '111-11-1111'),
    ('123-45-6789', '987-65-4321'),
    ('222-22-2222', '456-78-9012'),
    ('321-65-9874', '654-32-1098');
'''

questionsFormat = '''INSERT INTO Questions (questionId, customerId, questionText, questionDate) 
VALUES
    (1, 1, 'What are the available discounts?', '2024-12-08 02:19:27'),
    (2, 2, 'Are pets allowed on trains?', '2024-12-08 02:19:27'),
    (3, 3, 'Can I reschedule my reservation?', '2024-12-08 02:19:27'),
    (4, 4, 'What are the COVID-19 precautions?', '2024-12-08 02:19:27'),
    (5, 5, 'How can I book a round trip?', '2024-12-08 02:19:27');
'''

answersFormat = '''INSERT INTO Answers (answerId, questionId, employeeSSN, answerText, answerDate) 
VALUES
    (1, 1, '987-65-4321', 'Yes, students get 10% off.', '2024-12-08 02:20:25'),
    (2, 2, '456-78-9012', 'Yes, small pets are allowed with a carrier.', '2024-12-08 02:20:25'),
    (3, 3, '987-65-4321', 'You can reschedule up to 24 hours in advance.', '2024-12-08 02:20:25'),
    (4, 4, '654-32-1098', 'We sanitize regularly and enforce mask-wearing.', '2024-12-08 02:20:25'),
    (5, 5, '987-65-4321', 'Select the round-trip option during booking.', '2024-12-08 02:20:25');
'''

src = '''-- source: https://www.njtransit.com/pdf/rail/r0070.pdf'''

stationFormat = '''INSERT INTO Station (name, city, state)
VALUES 
    ("Trenton Transit Center", "Trenton", "NJ"),
    ("Hamilton", "Hamilton", "NJ"),
    ("Princeton Junction", "Princeton", "NJ"),
    ("Jersey Avenue", "New Brunswick", "NJ"),
    ("New Brunswick", "New Brunswick", "NJ"),
    ("Edison", "Edison", "NJ"),
    ("Metuchen", "Metuchen", "NJ"),
    ("Metropark", "Iselin", "NJ"),
    ("Rahway", "Rahway", "NJ"),
    ("Linden", "Linden", "NJ"),
    ("Elizabeth", "Elizabeth", "NJ"),
    ("North Elizabeth", "Elizabeth", "NJ"),
    ("Newark Int'l Airport", "Newark", "NJ"),
    ("Newark Penn Station", "Newark", "NJ"),
    ("Secaucus Junction", "Secaucus", "NJ"),
    ("New York Penn Station", "New York", "NY");
'''

trainFormat = '''INSERT INTO Train (trainId)
VALUES
    (3818),
    (3828),
    (3830),
    (3861),
    (3725),
    (3873);
'''

lineFormat = '''INSERT INTO TransitLine (lineName, trainId, origin, destination, departureDateTime, arrivalDateTime, fare)
VALUES '''
for i in range(0, 31):
    lineFormat += f'''        
    -- 2024-12-{(i+1):02d}
    ("NJ Northeast Corridor 8AM", 3818, 1, 16, "2024-12-{(i+1):02d} 06:11", "2024-12-{(i+1):02d} 07:50", 80.00),
    ("NJ Northeast Corridor 9AM", 3828, 1, 16, "2024-12-{(i+1):02d} 07:23", "2024-12-{(i+1):02d} 09:06", 100.00),
    ("NJ Northeast Corridor 10AM", 3830, 1, 16, "2024-12-{(i+1):02d} 08:00", "2024-12-{(i+1):02d} 09:37", 100.00),
    ("NJ Northeast Corridor 4PM", 3861, 16, 1, "2024-12-{(i+1):02d} 16:30", "2024-12-{(i+1):02d} 18:04", 100.00),
    ("NJ Northeast Corridor 5PM", 3725, 16, 4, "2024-12-{(i+1):02d} 17:08", "2024-12-{(i+1):02d} 18:13", 90.00),
    ("NJ Northeast Corridor 6PM", 3873, 16, 1, "2024-12-{(i+1):02d} 18:14", "2024-12-{(i+1):02d} 19:43", 80.00),
    '''
lineFormat = lineFormat[:-6] + ';\n'


stopFormat = '''INSERT INTO Stop (stopStation, stopLine, departureDateTime, arrivalDateTime)
VALUES'''
for i in range(0, 31):
    stopFormat += f'''         
-- 2024-12-{(i+1):02d}
    -- 3818 to NY (7:50 AM)
    (1, {i * 6 + 1}, "2024-12-{(i+1):02d} 06:12", "2024-12-{(i+1):02d} 06:11"),
    (2, {i * 6 + 1}, "2024-12-{(i+1):02d} 06:18", "2024-12-{(i+1):02d} 06:17"),
    (3, {i * 6 + 1}, "2024-12-{(i+1):02d} 06:26", "2024-12-{(i+1):02d} 06:25"),
    (5, {i * 6 + 1}, "2024-12-{(i+1):02d} 06:41", "2024-12-{(i+1):02d} 06:40"),
    (6, {i * 6 + 1}, "2024-12-{(i+1):02d} 06:46", "2024-12-{(i+1):02d} 06:45"),
    (7, {i * 6 + 1}, "2024-12-{(i+1):02d} 06:51", "2024-12-{(i+1):02d} 06:50"),
    (8, {i * 6 + 1}, "2024-12-{(i+1):02d} 06:56", "2024-12-{(i+1):02d} 06:55"),
    (9, {i * 6 + 1}, "2024-12-{(i+1):02d} 07:04", "2024-12-{(i+1):02d} 07:03"),
    (10, {i * 6 + 1}, "2024-12-{(i+1):02d} 07:09", "2024-12-{(i+1):02d} 07:08"),
    (11, {i * 6 + 1}, "2024-12-{(i+1):02d} 07:15", "2024-12-{(i+1):02d} 07:14"),
    (12, {i * 6 + 1}, "2024-12-{(i+1):02d} 07:18", "2024-12-{(i+1):02d} 07:17"),
    (13, {i * 6 + 1}, "2024-12-{(i+1):02d} 07:23", "2024-12-{(i+1):02d} 07:22"),
    (14, {i * 6 + 1}, "2024-12-{(i+1):02d} 07:30", "2024-12-{(i+1):02d} 07:29"),
    (15, {i * 6 + 1}, "2024-12-{(i+1):02d} 07:38", "2024-12-{(i+1):02d} 07:37"),
    (16, {i * 6 + 1}, "2024-12-{(i+1):02d} 07:50", "2024-12-{(i+1):02d} 07:50"),
    
    -- 3828 to NY (9:06 AM)
    (1, {i * 6 + 2}, "2024-12-{(i+1):02d} 07:24", "2024-12-{(i+1):02d} 07:23"),
    (2, {i * 6 + 2}, "2024-12-{(i+1):02d} 07:30", "2024-12-{(i+1):02d} 07:29"),
    (3, {i * 6 + 2}, "2024-12-{(i+1):02d} 07:37", "2024-12-{(i+1):02d} 07:36"),
    (5, {i * 6 + 2}, "2024-12-{(i+1):02d} 07:55", "2024-12-{(i+1):02d} 07:54"),
    (6, {i * 6 + 2}, "2024-12-{(i+1):02d} 08:00", "2024-12-{(i+1):02d} 07:59"),
    (7, {i * 6 + 2}, "2024-12-{(i+1):02d} 08:05", "2024-12-{(i+1):02d} 08:04"),
    (8, {i * 6 + 2}, "2024-12-{(i+1):02d} 08:10", "2024-12-{(i+1):02d} 08:09"),
    (9, {i * 6 + 2}, "2024-12-{(i+1):02d} 08:19", "2024-12-{(i+1):02d} 08:18"),
    (10, {i * 6 + 2}, "2024-12-{(i+1):02d} 08:24", "2024-12-{(i+1):02d} 08:23"),
    (11, {i * 6 + 2}, "2024-12-{(i+1):02d} 08:33", "2024-12-{(i+1):02d} 08:32"),
    (12, {i * 6 + 2}, "2024-12-{(i+1):02d} 08:36", "2024-12-{(i+1):02d} 08:35"),
    (13, {i * 6 + 2}, "2024-12-{(i+1):02d} 08:39", "2024-12-{(i+1):02d} 08:38"),
    (14, {i * 6 + 2}, "2024-12-{(i+1):02d} 08:45", "2024-12-{(i+1):02d} 08:44"),
    (15, {i * 6 + 2}, "2024-12-{(i+1):02d} 08:54", "2024-12-{(i+1):02d} 08:53"),
    (16, {i * 6 + 2}, "2024-12-{(i+1):02d} 09:06", "2024-12-{(i+1):02d} 09:06"),
    
    -- 3830 to NY (9:37 AM)
    (1, {i * 6 + 3}, "2024-12-{(i+1):02d} 08:01", "2024-12-{(i+1):02d} 08:00"),
    (2, {i * 6 + 3}, "2024-12-{(i+1):02d} 08:08", "2024-12-{(i+1):02d} 08:07"),
    (3, {i * 6 + 3}, "2024-12-{(i+1):02d} 08:15", "2024-12-{(i+1):02d} 08:14"),
    (5, {i * 6 + 3}, "2024-12-{(i+1):02d} 08:36", "2024-12-{(i+1):02d} 08:35"),
    (6, {i * 6 + 3}, "2024-12-{(i+1):02d} 08:40", "2024-12-{(i+1):02d} 08:39"),
    (7, {i * 6 + 3}, "2024-12-{(i+1):02d} 08:45", "2024-12-{(i+1):02d} 08:44"),
    (8, {i * 6 + 3}, "2024-12-{(i+1):02d} 08:49", "2024-12-{(i+1):02d} 08:48"),
    (9, {i * 6 + 3}, "2024-12-{(i+1):02d} 08:55", "2024-12-{(i+1):02d} 08:54"),
    (10, {i * 6 + 3}, "2024-12-{(i+1):02d} 08:59", "2024-12-{(i+1):02d} 08:58"),
    (11, {i * 6 + 3}, "2024-12-{(i+1):02d} 09:05", "2024-12-{(i+1):02d} 09:04"),
    (12, {i * 6 + 3}, "2024-12-{(i+1):02d} 09:08", "2024-12-{(i+1):02d} 09:07"),
    (13, {i * 6 + 3}, "2024-12-{(i+1):02d} 09:12", "2024-12-{(i+1):02d} 09:11"),
    (14, {i * 6 + 3}, "2024-12-{(i+1):02d} 09:17", "2024-12-{(i+1):02d} 09:16"),
    (15, {i * 6 + 3}, "2024-12-{(i+1):02d} 09:25", "2024-12-{(i+1):02d} 09:24"),
    (16, {i * 6 + 3}, "2024-12-{(i+1):02d} 09:37", "2024-12-{(i+1):02d} 09:37"),
    
    -- 3861 from NY (4:30 PM)
    (16, {i * 6 + 4}, "2024-12-{(i+1):02d} 16:31", "2024-12-{(i+1):02d} 16:30"),
    (15, {i * 6 + 4}, "2024-12-{(i+1):02d} 16:41", "2024-12-{(i+1):02d} 16:40"),
    (14, {i * 6 + 4}, "2024-12-{(i+1):02d} 16:50", "2024-12-{(i+1):02d} 16:49"),
    (13, {i * 6 + 4}, "2024-12-{(i+1):02d} 16:56", "2024-12-{(i+1):02d} 16:55"),
    (12, {i * 6 + 4}, "2024-12-{(i+1):02d} 17:00", "2024-12-{(i+1):02d} 16:59"),
    (11, {i * 6 + 4}, "2024-12-{(i+1):02d} 17:03", "2024-12-{(i+1):02d} 17:02"),
    (10, {i * 6 + 4}, "2024-12-{(i+1):02d} 17:08", "2024-12-{(i+1):02d} 17:07"),
    (9, {i * 6 + 4}, "2024-12-{(i+1):02d} 17:12", "2024-12-{(i+1):02d} 17:11"),
    (8, {i * 6 + 4}, "2024-12-{(i+1):02d} 17:17", "2024-12-{(i+1):02d} 17:16"),
    (7, {i * 6 + 4}, "2024-12-{(i+1):02d} 17:22", "2024-12-{(i+1):02d} 17:21"),
    (6, {i * 6 + 4}, "2024-12-{(i+1):02d} 17:26", "2024-12-{(i+1):02d} 17:25"),
    (5, {i * 6 + 4}, "2024-12-{(i+1):02d} 17:30", "2024-12-{(i+1):02d} 17:29"),
    (3, {i * 6 + 4}, "2024-12-{(i+1):02d} 17:46", "2024-12-{(i+1):02d} 17:45"),
    (2, {i * 6 + 4}, "2024-12-{(i+1):02d} 17:53", "2024-12-{(i+1):02d} 17:52"),
    (1, {i * 6 + 4}, "2024-12-{(i+1):02d} 18:04", "2024-12-{(i+1):02d} 18:04"),
    
    -- 3725 from NY (5:08 PM)
    (16, {i * 6 + 5}, "2024-12-{(i+1):02d} 17:09", "2024-12-{(i+1):02d} 17:08"),
    (15, {i * 6 + 5}, "2024-12-{(i+1):02d} 17:29", "2024-12-{(i+1):02d} 17:18"),
    (14, {i * 6 + 5}, "2024-12-{(i+1):02d} 17:30", "2024-12-{(i+1):02d} 17:29"),
    (13, {i * 6 + 5}, "2024-12-{(i+1):02d} 17:36", "2024-12-{(i+1):02d} 17:35"),
    (8, {i * 6 + 5}, "2024-12-{(i+1):02d} 17:50", "2024-12-{(i+1):02d} 17:49"),
    (7, {i * 6 + 5}, "2024-12-{(i+1):02d} 17:55", "2024-12-{(i+1):02d} 17:54"),
    (6, {i * 6 + 5}, "2024-12-{(i+1):02d} 18:00", "2024-12-{(i+1):02d} 17:59"),
    (5, {i * 6 + 5}, "2024-12-{(i+1):02d} 18:04", "2024-12-{(i+1):02d} 18:04"),
    (4, {i * 6 + 5}, "2024-12-{(i+1):02d} 18:13", "2024-12-{(i+1):02d} 18:13"),
    
    -- 3873 from NY (6:14 PM)
    (16, {i * 6 + 6}, "2024-12-{(i+1):02d} 18:15", "2024-12-{(i+1):02d} 18:14"),
    (14, {i * 6 + 6}, "2024-12-{(i+1):02d} 18:31", "2024-12-{(i+1):02d} 18:30"),
    (13, {i * 6 + 6}, "2024-12-{(i+1):02d} 18:37", "2024-12-{(i+1):02d} 18:36"),
    (9, {i * 6 + 6}, "2024-12-{(i+1):02d} 18:47", "2024-12-{(i+1):02d} 18:46"),
    (8, {i * 6 + 6}, "2024-12-{(i+1):02d} 18:53", "2024-12-{(i+1):02d} 18:52"),
    (7, {i * 6 + 6}, "2024-12-{(i+1):02d} 18:58", "2024-12-{(i+1):02d} 18:57"),
    (6, {i * 6 + 6}, "2024-12-{(i+1):02d} 19:04", "2024-12-{(i+1):02d} 19:03"),
    (5, {i * 6 + 6}, "2024-12-{(i+1):02d} 19:08", "2024-12-{(i+1):02d} 19:07"),
    (4, {i * 6 + 6}, "2024-12-{(i+1):02d} 19:13", "2024-12-{(i+1):02d} 19:12"),
    (3, {i * 6 + 6}, "2024-12-{(i+1):02d} 19:25", "2024-12-{(i+1):02d} 19:24"),
    (2, {i * 6 + 6}, "2024-12-{(i+1):02d} 19:32", "2024-12-{(i+1):02d} 19:31"),
    (1, {i * 6 + 6}, "2024-12-{(i+1):02d} 19:43", "2024-12-{(i+1):02d} 19:43"),
    '''
stopFormat = stopFormat[:-6] + ';'

with open('tests/sql/table_data.sql', 'w') as f:
    print(table, file=f)
    print(clearTable, file=f)
    print(customerFormat, file=f)
    print(employeeFormat, file=f)
    print(managesFormat, file=f)
    print(questionsFormat, file=f)
    print(answersFormat, file=f)
    print(src, file=f)
    print(stationFormat, file=f)
    print(trainFormat, file=f)
    print(lineFormat, file=f)
    print(stopFormat, file=f)