-- Drop tables in correct order (children first)
DROP TABLE IF EXISTS RatesReview;
DROP TABLE IF EXISTS WritesRevAbt;
DROP TABLE IF EXISTS Review;
DROP TABLE IF EXISTS SpecialFeature;
DROP TABLE IF EXISTS Building;
DROP TABLE IF EXISTS Student;
DROP TABLE IF EXISTS Staff;
DROP TABLE IF EXISTS Visitor;
DROP TABLE IF EXISTS Reviewer;
DROP TABLE IF EXISTS AuthToken;

-- Create tables
CREATE TABLE Reviewer (
    ReviewerID VARCHAR(150) PRIMARY KEY,
    Fname CHAR(75),
    Lname CHAR(75),
    JoinDate CHAR(75),
    Password VARCHAR(255)
);

CREATE TABLE AuthToken (
    ReviewerID VARCHAR(150) NOT NULL,
    Token VARCHAR(255) NOT NULL,
    PRIMARY KEY(ReviewerID),
    FOREIGN KEY(ReviewerID) REFERENCES Reviewer(ReviewerID) ON DELETE CASCADE
);

CREATE TABLE Student (
    StudentID CHAR(75) PRIMARY KEY,
    ReviewerID VARCHAR(150),
    GradYear INT,
    Major CHAR(75),
    HasGraduated BOOLEAN,
    FOREIGN KEY (ReviewerID) REFERENCES Reviewer(ReviewerID)
);

CREATE TABLE Staff (
    StaffID CHAR(75) PRIMARY KEY,
    ReviewerID VARCHAR(150),
    Department CHAR(75),
    OfficeNumber CHAR(75),
    FOREIGN KEY (ReviewerID) REFERENCES Reviewer(ReviewerID)
);

CREATE TABLE Visitor (
    VisitorID CHAR(75) PRIMARY KEY,
    ReviewerID VARCHAR(150),
    Affiliation CHAR(75),
    FOREIGN KEY (ReviewerID) REFERENCES Reviewer(ReviewerID)
);

CREATE TABLE Building (
    BuildingName CHAR(75) PRIMARY KEY,
    Address CHAR(75),
    YearBuilt INT
);

CREATE TABLE SpecialFeature (
    Name CHAR(75) PRIMARY KEY,
    BuildingName CHAR(75),
    Description CHAR(150),
    Type CHAR(75),
    Hours CHAR(15),
    FOREIGN KEY (BuildingName) REFERENCES Building(BuildingName)
);

CREATE TABLE Review (
    ReviewID CHAR(75) PRIMARY KEY ON DELETE CASCADE,
    DateWritten DATETIME,
    NumStars INT,
    Description CHAR(150)
);

CREATE TABLE WritesRevAbt (
    ReviewerID VARCHAR(150),
    ReviewID CHAR(75),
    BuildingID CHAR(75),
    PRIMARY KEY (ReviewerID, ReviewID, BuildingID),
    FOREIGN KEY (ReviewerID) REFERENCES Reviewer(ReviewerID),
    FOREIGN KEY (ReviewID) REFERENCES Review(ReviewID),
    FOREIGN KEY (BuildingID) REFERENCES Building(BuildingName)
);

CREATE TABLE RatesReview (
    ReviewerID VARCHAR(150),
    ReviewID CHAR(75),
    Rating CHAR(75),
    PRIMARY KEY (ReviewerID, ReviewID),
    FOREIGN KEY (ReviewerID) REFERENCES Reviewer(ReviewerID),
    FOREIGN KEY (ReviewID) REFERENCES Review(ReviewID)
);

-- Procedures
DROP PROCEDURE IF EXISTS AddAccount;
DROP PROCEDURE IF EXISTS AddReview;
DROP PROCEDURE IF EXISTS RateReview;
DROP PROCEDURE IF EXISTS AddBuilding;
DROP PROCEDURE IF EXISTS AddSpecialFeature;

DELIMITER $$

CREATE PROCEDURE AddAccount (
    IN p_Email VARCHAR(255),
    IN p_HashedPassword VARCHAR(255),
    IN p_Fname CHAR(75),
    IN p_Lname CHAR(75),
    IN p_JoinDate CHAR(75),
    IN p_Type CHAR(20),
    IN p_Extra1 VARCHAR(75), -- GradYear / Department / Affiliation
    IN p_Extra2 VARCHAR(75), -- Major / OfficeNumber / NULL
    IN p_Extra3 VARCHAR(75), -- StudentID
    IN p_HasGraduated BOOLEAN -- Only used for students
)
BEGIN
    INSERT INTO Reviewer (ReviewerID, Fname, Lname, JoinDate, Password)
    VALUES (p_Email, p_Fname, p_Lname, p_JoinDate, p_HashedPassword);

    IF p_Type = 'Student' THEN
        INSERT INTO Student (StudentID, ReviewerID, GradYear, Major, HasGraduated)
        VALUES (p_Extra3, p_Email, CAST(p_Extra1 AS UNSIGNED), p_Extra2, p_HasGraduated);
    ELSEIF p_Type = 'Staff' THEN
        INSERT INTO Staff (StaffID, ReviewerID, Department, OfficeNumber)
        VALUES (p_Email, p_Email, p_Extra1, p_Extra2);
    ELSEIF p_Type = 'Visitor' THEN
        INSERT INTO Visitor (VisitorID, ReviewerID, Affiliation)
        VALUES (p_Email, p_Email, p_Extra1);
    END IF;
END$$

CREATE PROCEDURE AddToken(
    IN p_ReviewerID VARCHAR(255),
    IN p_Token VARCHAR(255)
)
BEGIN
    INSERT INTO AuthToken(ReviewerID, Token)
    VALUES (p_ReviewerID, p_Token);
END$$

CREATE PROCEDURE AddReview(
    IN p_ReviewID VARCHAR(255),
    IN p_DateWritten DATETIME,
    IN p_NumStars INT,
    IN p_Description CHAR(150),
    IN p_ReviewerID VARCHAR(150),
    IN p_BuildingName CHAR(75)
)
BEGIN
    INSERT INTO Review (ReviewID, DateWritten, NumStars, Description)
    VALUES (p_ReviewID, p_DateWritten, p_NumStars, p_Description);

    INSERT INTO WritesRevAbt (ReviewerID, ReviewID, BuildingID)
    VALUES (p_ReviewerID, p_ReviewID, p_BuildingName);
END$$

CREATE PROCEDURE RateReview(
    IN p_ReviewerID VARCHAR(255),
    IN p_ReviewID VARCHAR(255),
    IN p_Rating CHAR(75)
)
BEGIN
    IF EXISTS (SELECT 1 FROM RatesReview 
               WHERE ReviewerID = p_ReviewerID AND ReviewID = p_ReviewID) THEN
        UPDATE RatesReview
        SET Rating = p_Rating
        WHERE ReviewerID = p_ReviewerID AND ReviewID = p_ReviewID;
    ELSE
        INSERT INTO RatesReview (ReviewerID, ReviewID, Rating)
        VALUES (p_ReviewerID, p_ReviewID, p_Rating);
    END IF;
END$$

CREATE PROCEDURE AddBuilding(
    IN p_BuildingName VARCHAR(255),
    IN p_Address VARCHAR(255),
    IN p_YearBuilt INT
)
BEGIN
    INSERT INTO Building (BuildingName, Address, YearBuilt)
    VALUES (p_BuildingName, p_Address, p_YearBuilt);
END$$

CREATE PROCEDURE AddSpecialFeature(
    IN p_Name VARCHAR(255),
    IN p_BuildingName VARCHAR(255),
    IN p_Description VARCHAR(255),
    IN p_Type VARCHAR(75),
    IN p_Hours CHAR(15)
)
BEGIN
    INSERT INTO SpecialFeature (Name, BuildingName, Description, Type, Hours)
    VALUES (p_Name, p_BuildingName, p_Description, p_Type, p_Hours);
END$$

DELIMITER ;

-- Insert buildings
INSERT INTO Building (BuildingName, Address, YearBuilt)
VALUES
('Bertelsmeyer Hall', '1101 N. State St.', 2014),
('Butler-Carlton Civil Engineering Hall', '1401 N. Pine St.', 1959),
('Computer Science Building', '500 W. 15th St.', 2000),
('Emerson Electric Company Hall', '301 W. 16th St.', 1958),
('Harris Hall', '500 W. 13th St.', 1940),
('Fulton Hall', '301 W. 14th St.', 1923),
('Humanities and Social Science Building', '500 W. 14th St.', 1975),
('McNutt Hall', '1400 N. Bishop Ave.', 1965),
('Physics Building', '1315 N. Pine St.', 1963),
('Rolla Building', '400 W. 12th St.', 1871),
('Schrenk Hall', '400 W. 11th St.', 1938),
('Toomey Hall', '400 W. 13th St.', 1990),
('Curtis Laws Wilson Library', '400 W. 14th St.', 1970),
('Straumanis James Hall', '401 W. 16th St.', 1975),
('Residential Commons 1', '710 Tim Bradley Way', 2005),
('Residential Commons 2', '1575 Watts Dr.', 2005),
('University Commons', '810 Tim Bradley Way', 2000),
('Centennial Hall', '300 W. 12th St.', 1975),
('Havener Center', '1346 N. Bishop Ave.', 1994),
('Innovation Lab', '650 Tim Bradley Way', 2020),
('Norwood Hall', '320 W. 12th St.', 1903),
('Parker Hall', '300 W. 13th St.', 1912),
('University Police', '205 W. 12th St.', 1980),
('Welcome Center', '500 Tim Bradley Way', 2000);

-- Add Special Features
CALL AddSpecialFeature('Main Lecture Hall', 'Bertelsmeyer Hall', 'Large lecture hall with multimedia support', 'Lecture', '08:00-18:00');
CALL AddSpecialFeature('Civil Lab', 'Butler-Carlton Civil Engineering Hall', 'Structural testing lab', 'Lab', '09:00-17:00');
CALL AddSpecialFeature('Computer Lab', 'Computer Science Building', 'High-performance computing lab', 'Lab', '08:30-20:00');
CALL AddSpecialFeature('Electronics Lab', 'Emerson Electric Company Hall', 'Electrical engineering lab', 'Lab', '08:00-18:00');
CALL AddSpecialFeature('History Archive', 'Harris Hall', 'Historical documents and reference library', 'Archive', '09:00-16:00');
CALL AddSpecialFeature('Mechanical Workshop', 'Fulton Hall', 'Workshop for mechanical engineering projects', 'Workshop', '07:30-16:30');
CALL AddSpecialFeature('Humanities Seminar Room', 'Humanities and Social Science Building', 'Seminar and discussion room', 'Seminar', '08:00-17:00');
CALL AddSpecialFeature('Chemistry Lab', 'McNutt Hall', 'General chemistry laboratory', 'Lab', '08:00-18:00');
CALL AddSpecialFeature('Physics Lab', 'Physics Building', 'Physics experiments and demonstrations', 'Lab', '08:00-17:30');
CALL AddSpecialFeature('Engineering Exhibit', 'Rolla Building', 'Engineering displays and models', 'Exhibit', '10:00-16:00');
CALL AddSpecialFeature('Research Lab', 'Schrenk Hall', 'Advanced research facility', 'Lab', '08:30-19:00');
CALL AddSpecialFeature('Classroom A', 'Toomey Hall', 'Standard classroom', 'Classroom', '08:00-17:00');
CALL AddSpecialFeature('Library Reading Room', 'Curtis Laws Wilson Library', 'Quiet study space with computers', 'Library', '08:00-22:00');
CALL AddSpecialFeature('Seminar Room', 'Straumanis James Hall', 'Seminar room with projector', 'Seminar', '08:00-18:00');
CALL AddSpecialFeature('Dorm Lounge', 'Residential Commons 1', 'Student lounge and social area', 'Lounge', '07:00-23:00');
CALL AddSpecialFeature('Dorm Kitchen', 'Residential Commons 2', 'Shared kitchen for residents', 'Kitchen', '06:30-23:30');
CALL AddSpecialFeature('Student Center', 'University Commons', 'Meeting rooms and student activities', 'Center', '08:00-20:00');
CALL AddSpecialFeature('Auditorium', 'Centennial Hall', 'Large auditorium for events', 'Auditorium', '09:00-22:00');
CALL AddSpecialFeature('Gymnasium', 'Havener Center', 'Sports and recreation gym', 'Gym', '06:00-23:00');
CALL AddSpecialFeature('Innovation Lab', 'Innovation Lab', 'Makerspace with 3D printers and tools', 'Lab', '08:00-20:00');
CALL AddSpecialFeature('Lecture Hall', 'Norwood Hall', 'Lecture hall for engineering classes', 'Lecture', '08:00-18:00');
CALL AddSpecialFeature('Classroom B', 'Parker Hall', 'Standard classroom', 'Classroom', '08:00-17:00');
CALL AddSpecialFeature('Police Office', 'University Police', 'Campus police station', 'Office', '00:00-24:00');
CALL AddSpecialFeature('Visitor Center', 'Welcome Center', 'Information desk and guides', 'Center', '08:00-18:00');

-- =============================
-- Reviewers & AuthTokens
-- =============================

CALL AddAccount('emma.johnson@example.com', 'hashed_pw_1', 'Emma', 'Johnson', '2022-08-12', 'Student', '2025', 'Computer Science', '100000000001', FALSE);
CALL AddToken('emma.johnson@example.com', 'tok_ab91f1c8c34e4a99');

CALL AddAccount('noah.williams@example.com', 'hashed_pw_4', 'Noah', 'Williams', '2020-03-10', 'Student', '2024', 'Mechanical Engineering', '100000000002', TRUE);
CALL AddToken('noah.williams@example.com', 'tok_0091bda771abcc91');

CALL AddAccount('sophia.davis@example.com', 'hashed_pw_7', 'Sophia', 'Davis', '2023-02-02', 'Student', '2026', 'Physics', '100000000003', FALSE);
CALL AddToken('sophia.davis@example.com', 'tok_3391b7d991defa33');

CALL AddAccount('ethan.moore@example.com', 'hashed_pw_10', 'Ethan', 'Moore', '2023-03-12', 'Student', '2027', 'Civil Engineering', '100000000004', FALSE);
CALL AddToken('ethan.moore@example.com', 'tok_cc77e12a90bb1311');

CALL AddAccount('liam.smith@example.com', 'hashed_pw_2', 'Liam', 'Smith', '2023-01-20', 'Visitor', 'Local Resident', NULL, NULL, NULL);
CALL AddToken('liam.smith@example.com', 'tok_71fde5b8332bfa11');

CALL AddAccount('ava.brown@example.com', 'hashed_pw_5', 'Ava', 'Brown', '2022-09-14', 'Visitor', 'Alumni', NULL, NULL, NULL);
CALL AddToken('ava.brown@example.com', 'tok_91aa221eaf772300');

CALL AddAccount('olivia.martin@example.com', 'hashed_pw_3', 'Olivia', 'Martin', '2021-11-05', 'Staff', 'IT Services', '102', NULL, NULL);
CALL AddToken('olivia.martin@example.com', 'tok_ae33f22c998d00d4');

CALL AddAccount('will.jones@example.com', 'hashed_pw_6', 'William', 'Jones', '2021-06-30', 'Staff', 'Chemistry Dept.', '103', NULL, NULL);
CALL AddToken('will.jones@example.com', 'tok_ab11cd772e01aa14');

CALL AddAccount('mia.wilson@example.com', 'hashed_pw_9', 'Mia', 'Wilson', '2021-04-21', 'Staff', 'Library Services', '104', NULL, NULL);
CALL AddToken('mia.wilson@example.com', 'tok_33ddaa1190e3f522');

CALL AddAccount('james.miller@example.com', 'hashed_pw_8', 'James', 'Miller', '2021-02-21', 'Visitor', 'Mother', NULL, NULL, NULL);
CALL AddToken('james.miller@example.com', 'tok_33ddaa1190c998d0');

-- ================================================
-- 96 REVIEWS FOR ALL BUILDINGS
-- Reviewer cycle: 10 reviewers repeating
-- ReviewIDs: REV001 - REV096
-- ================================================


-- ================================================
-- Bertelsmeyer Hall (REV001–REV004)
-- ================================================
CALL AddReview('REV001','2023-04-12 10:15:00',5,'Great modern classrooms and clean facilities.','emma.johnson@example.com','Bertelsmeyer Hall');
CALL AddReview('REV002','2025-01-22 14:33:00',3,'A solid building with reliable lecture rooms.','liam.smith@example.com','Bertelsmeyer Hall');
CALL AddReview('REV003','2024-07-08 09:40:00',4,'The equipment here works well and is easy to use.','olivia.martin@example.com','Bertelsmeyer Hall');
CALL AddReview('REV004','2023-10-18 16:22:00',2,'Good layout but some rooms get crowded.','noah.williams@example.com','Bertelsmeyer Hall');

-- ================================================
-- Butler-Carlton Civil Engineering Hall (REV005–REV008)
-- ================================================
CALL AddReview('REV005','2024-02-14 11:11:00',4,'Strong engineering environment with useful labs.','ava.brown@example.com','Butler-Carlton Civil Engineering Hall');
CALL AddReview('REV006','2023-03-27 15:00:00',1,'Some of the older rooms feel worn out.','will.jones@example.com','Butler-Carlton Civil Engineering Hall');
CALL AddReview('REV007','2025-05-19 13:25:00',5,'Excellent place for structural testing work.','sophia.davis@example.com','Butler-Carlton Civil Engineering Hall');
CALL AddReview('REV008','2024-09-04 09:03:00',3,'Overall a reliable building for engineering classes.','james.miller@example.com','Butler-Carlton Civil Engineering Hall');

-- ================================================
-- Computer Science Building (REV009–REV012)
-- ================================================
CALL AddReview('REV009','2023-12-01 08:45:00',5,'The computer labs are fast and well organized.','mia.wilson@example.com','Computer Science Building');
CALL AddReview('REV010','2025-02-09 12:14:00',4,'Nice quiet spaces for coding and studying.','ethan.moore@example.com','Computer Science Building');
CALL AddReview('REV011','2024-05-21 10:30:00',2,'Some PCs run slow during busy hours.','emma.johnson@example.com','Computer Science Building');
CALL AddReview('REV012','2023-07-27 16:18:00',3,'Pretty good building with helpful staff.','liam.smith@example.com','Computer Science Building');

-- ================================================
-- Emerson Electric Company Hall (REV013–REV016)
-- ================================================
CALL AddReview('REV013','2024-03-13 14:05:00',4,'The electronics lab is well equipped and spacious.','olivia.martin@example.com','Emerson Electric Company Hall');
CALL AddReview('REV014','2025-06-01 09:52:00',1,'Some equipment seems outdated.','noah.williams@example.com','Emerson Electric Company Hall');
CALL AddReview('REV015','2023-09-22 11:47:00',5,'Great place for hands-on electrical projects.','ava.brown@example.com','Emerson Electric Company Hall');
CALL AddReview('REV016','2024-11-30 15:09:00',3,'A decent building but parking is difficult.','will.jones@example.com','Emerson Electric Company Hall');

-- ================================================
-- Harris Hall (REV017–REV020)
-- ================================================
CALL AddReview('REV017','2023-02-10 10:55:00',4,'A quiet building with a nice historical feel.','sophia.davis@example.com','Harris Hall');
CALL AddReview('REV018','2024-04-20 14:40:00',2,'Some rooms are cold during winter.','james.miller@example.com','Harris Hall');
CALL AddReview('REV019','2025-07-07 09:18:00',5,'Great place for studying and research.','mia.wilson@example.com','Harris Hall');
CALL AddReview('REV020','2023-11-29 13:12:00',3,'Decent building but could use more seating.','ethan.moore@example.com','Harris Hall');

-- ================================================
-- Fulton Hall (REV021–REV024)
-- ================================================
CALL AddReview('REV021','2024-02-16 08:33:00',5,'Excellent workshop area with useful tools.','emma.johnson@example.com','Fulton Hall');
CALL AddReview('REV022','2025-03-28 10:50:00',4,'Strong engineering environment overall.','liam.smith@example.com','Fulton Hall');
CALL AddReview('REV023','2023-04-14 12:05:00',2,'Some hallways feel cramped.','olivia.martin@example.com','Fulton Hall');
CALL AddReview('REV024','2025-08-01 16:20:00',3,'Good classrooms but ventilation could improve.','noah.williams@example.com','Fulton Hall');

-- ================================================
-- Humanities and Social Science Building (REV025–REV028)
-- ================================================
CALL AddReview('REV025','2024-07-30 09:34:00',4,'Comfortable rooms ideal for discussions.','ava.brown@example.com','Humanities and Social Science Building');
CALL AddReview('REV026','2023-06-25 14:17:00',3,'Good seminar spaces with solid tech.','will.jones@example.com','Humanities and Social Science Building');
CALL AddReview('REV027','2025-05-12 11:49:00',5,'Pleasant atmosphere and well-lit hallways.','sophia.davis@example.com','Humanities and Social Science Building');
CALL AddReview('REV028','2024-10-03 08:25:00',2,'The seats can be uncomfortable during long classes.','james.miller@example.com','Humanities and Social Science Building');

-- ================================================
-- McNutt Hall (REV029–REV032)
-- ================================================
CALL AddReview('REV029','2023-03-09 13:14:00',3,'The chemistry labs work fine but feel a bit old.','mia.wilson@example.com','McNutt Hall');
CALL AddReview('REV030','2025-01-18 09:10:00',5,'A reliable building for science classes.','ethan.moore@example.com','McNutt Hall');
CALL AddReview('REV031','2024-06-09 16:32:00',1,'Too many crowded areas during peak hours.','emma.johnson@example.com','McNutt Hall');
CALL AddReview('REV032','2023-12-21 11:55:00',4,'Solid labs with helpful staff.','liam.smith@example.com','McNutt Hall');

-- ================================================
-- Physics Building (REV033–REV036)
-- ================================================
CALL AddReview('REV033','2024-08-13 15:44:00',5,'Fun demonstrations make the place great.','olivia.martin@example.com','Physics Building');
CALL AddReview('REV034','2023-09-29 10:00:00',4,'Good labs with plenty of space.','noah.williams@example.com','Physics Building');
CALL AddReview('REV035','2025-02-01 13:23:00',3,'A functional building but not very modern.','ava.brown@example.com','Physics Building');
CALL AddReview('REV036','2023-05-08 09:41:00',2,'Some rooms echo too much during lectures.','will.jones@example.com','Physics Building');

-- ================================================
-- Rolla Building (REV037–REV040)
-- ================================================
CALL AddReview('REV037','2025-06-15 16:10:00',4,'Historic feel but still very functional.','sophia.davis@example.com','Rolla Building');
CALL AddReview('REV038','2023-01-12 11:05:00',3,'Interesting architecture but limited seating.','james.miller@example.com','Rolla Building');
CALL AddReview('REV039','2024-09-26 15:35:00',5,'Great exhibits make it worth visiting.','mia.wilson@example.com','Rolla Building');
CALL AddReview('REV040','2023-10-07 08:57:00',1,'Feels outdated compared to newer buildings.','ethan.moore@example.com','Rolla Building');

-- ================================================
-- Schrenk Hall (REV041–REV044)
-- ================================================
CALL AddReview('REV041','2024-02-22 13:50:00',5,'Excellent labs for advanced research.','emma.johnson@example.com','Schrenk Hall');
CALL AddReview('REV042','2023-07-19 16:44:00',2,'Hallways get confusing to navigate.','liam.smith@example.com','Schrenk Hall');
CALL AddReview('REV043','2025-03-02 09:18:00',4,'A strong science building with good equipment.','olivia.martin@example.com','Schrenk Hall');
CALL AddReview('REV044','2024-12-11 12:33:00',3,'Some rooms are too warm in summer.','noah.williams@example.com','Schrenk Hall');

-- ================================================
-- Toomey Hall (REV045–REV048)
-- ================================================
CALL AddReview('REV045','2023-04-04 10:22:00',4,'Good classrooms with plenty of space.','ava.brown@example.com','Toomey Hall');
CALL AddReview('REV046','2025-08-19 15:31:00',5,'A nice environment for engineering lectures.','will.jones@example.com','Toomey Hall');
CALL AddReview('REV047','2024-03-15 08:12:00',3,'Solid facilities but parking nearby is tough.','sophia.davis@example.com','Toomey Hall');
CALL AddReview('REV048','2023-11-10 14:48:00',2,'The lighting feels dim in some rooms.','james.miller@example.com','Toomey Hall');

-- ================================================
-- Curtis Laws Wilson Library (REV049–REV052)
-- ================================================
CALL AddReview('REV049','2024-06-02 09:30:00',5,'Great quiet spaces ideal for studying.','mia.wilson@example.com','Curtis Laws Wilson Library');
CALL AddReview('REV050','2025-03-21 13:12:00',4,'Lots of good resources available.','ethan.moore@example.com','Curtis Laws Wilson Library');
CALL AddReview('REV051','2023-07-18 10:05:00',3,'Comfortable but sometimes crowded.','emma.johnson@example.com','Curtis Laws Wilson Library');
CALL AddReview('REV052','2024-01-28 15:40:00',2,'Not enough outlets in some areas.','liam.smith@example.com','Curtis Laws Wilson Library');

-- ================================================
-- Straumanis James Hall (REV053–REV056)
-- ================================================
CALL AddReview('REV053','2023-05-19 09:17:00',4,'Nice seminar rooms with reliable equipment.','olivia.martin@example.com','Straumanis James Hall');
CALL AddReview('REV054','2024-12-06 16:20:00',1,'Some seats are uncomfortable.','noah.williams@example.com','Straumanis James Hall');
CALL AddReview('REV055','2025-04-09 11:08:00',5,'Excellent lighting and layout.','ava.brown@example.com','Straumanis James Hall');
CALL AddReview('REV056','2023-09-03 14:44:00',3,'A functional building but lacks personality.','will.jones@example.com','Straumanis James Hall');

-- ================================================
-- Residential Commons 1 (REV057–REV060)
-- ================================================
CALL AddReview('REV057','2024-02-12 12:09:00',5,'A great place for socializing and relaxing.','sophia.davis@example.com','Residential Commons 1');
CALL AddReview('REV058','2023-08-26 09:35:00',3,'Nice lounge but gets busy at night.','james.miller@example.com','Residential Commons 1');
CALL AddReview('REV059','2025-06-14 15:28:00',4,'Comfortable and quiet during the day.','mia.wilson@example.com','Residential Commons 1');
CALL AddReview('REV060','2024-11-19 11:22:00',2,'Could use more seating options.','ethan.moore@example.com','Residential Commons 1');

-- ================================================
-- Residential Commons 2 (REV061–REV064)
-- ================================================
CALL AddReview('REV061','2023-01-16 10:12:00',4,'Useful shared kitchen with good appliances.','emma.johnson@example.com','Residential Commons 2');
CALL AddReview('REV062','2025-07-23 13:05:00',3,'Gets crowded during dinner hours.','liam.smith@example.com','Residential Commons 2');
CALL AddReview('REV063','2024-05-02 08:57:00',2,'Some appliances break down too often.','olivia.martin@example.com','Residential Commons 2');
CALL AddReview('REV064','2023-10-30 16:41:00',5,'Very clean and convenient for students.','noah.williams@example.com','Residential Commons 2');

-- ================================================
-- University Commons (REV065–REV068)
-- ================================================
CALL AddReview('REV065','2024-03-11 09:49:00',5,'Great multi-use space for events and study.','ava.brown@example.com','University Commons');
CALL AddReview('REV066','2025-02-14 14:13:00',4,'Nice atmosphere with plenty of rooms.','will.jones@example.com','University Commons');
CALL AddReview('REV067','2023-06-07 11:31:00',3,'Gets loud during peak times.','sophia.davis@example.com','University Commons');
CALL AddReview('REV068','2024-09-10 16:26:00',2,'Some of the meeting rooms feel cramped.','james.miller@example.com','University Commons');

-- ================================================
-- Centennial Hall (REV069–REV072)
-- ================================================
CALL AddReview('REV069','2023-04-08 13:55:00',4,'The auditorium is spacious and comfortable.','mia.wilson@example.com','Centennial Hall');
CALL AddReview('REV070','2025-05-16 10:40:00',3,'Good venue but needs better sound.','ethan.moore@example.com','Centennial Hall');
CALL AddReview('REV071','2024-01-05 15:12:00',5,'Great building for events and gatherings.','emma.johnson@example.com','Centennial Hall');
CALL AddReview('REV072','2023-07-28 09:48:00',2,'Acoustics could be improved.','liam.smith@example.com','Centennial Hall');

-- ================================================
-- Havener Center (REV073–REV076)
-- ================================================
CALL AddReview('REV073','2024-06-17 08:33:00',5,'The gym area is always clean and well maintained.','olivia.martin@example.com','Havener Center');
CALL AddReview('REV074','2023-09-24 15:19:00',4,'A great central place for student life.','noah.williams@example.com','Havener Center');
CALL AddReview('REV075','2025-03-03 10:50:00',3,'Food court is decent but can be slow.','ava.brown@example.com','Havener Center');
CALL AddReview('REV076','2024-12-29 14:37:00',1,'Gets extremely crowded at lunchtime.','will.jones@example.com','Havener Center');

-- ================================================
-- Innovation Lab (REV077–REV080)
-- ================================================
CALL AddReview('REV077','2023-05-06 11:14:00',5,'Excellent tools for prototyping and projects.','sophia.davis@example.com','Innovation Lab');
CALL AddReview('REV078','2024-09-17 16:22:00',3,'A solid makerspace but equipment can be booked.','james.miller@example.com','Innovation Lab');
CALL AddReview('REV079','2025-06-09 10:01:00',4,'Modern layout with great lighting.','mia.wilson@example.com','Innovation Lab');
CALL AddReview('REV080','2023-12-02 08:59:00',2,'Some machines require long wait times.','ethan.moore@example.com','Innovation Lab');

-- ================================================
-- Norwood Hall (REV081–REV084)
-- ================================================
CALL AddReview('REV081','2024-04-16 11:22:00',4,'Classic architecture with good lecture spaces.','emma.johnson@example.com','Norwood Hall');
CALL AddReview('REV082','2023-02-11 14:33:00',3,'Charming building but a bit drafty.','liam.smith@example.com','Norwood Hall');
CALL AddReview('REV083','2025-08-05 10:44:00',5,'Great place for engineering classes.','olivia.martin@example.com','Norwood Hall');
CALL AddReview('REV084','2024-01-09 16:09:00',1,'Feels too outdated in some areas.','noah.williams@example.com','Norwood Hall');

-- ================================================
-- Parker Hall (REV085–REV088)
-- ================================================
CALL AddReview('REV085','2024-07-19 09:51:00',4,'A reliable building for many general classes.','ava.brown@example.com','Parker Hall');
CALL AddReview('REV086','2025-02-27 13:58:00',3,'Some classrooms need newer desks.','will.jones@example.com','Parker Hall');
CALL AddReview('REV087','2023-10-14 11:30:00',5,'Great acoustics and lighting inside.','sophia.davis@example.com','Parker Hall');
CALL AddReview('REV088','2024-03-31 15:10:00',2,'The hallways get crowded quickly.','james.miller@example.com','Parker Hall');

-- ================================================
-- University Police (REV089–REV092)
-- ================================================
CALL AddReview('REV089','2023-08-22 12:44:00',4,'Staff is helpful and professional.','mia.wilson@example.com','University Police');
CALL AddReview('REV090','2024-10-18 09:27:00',5,'Very responsive and friendly service.','ethan.moore@example.com','University Police');
CALL AddReview('REV091','2025-01-07 16:39:00',3,'The lobby is small but organized.','emma.johnson@example.com','University Police');
CALL AddReview('REV092','2023-11-05 11:18:00',2,'Parking around the building is limited.','liam.smith@example.com','University Police');

-- ================================================
-- Welcome Center (REV093–REV096)
-- ================================================
CALL AddReview('REV093','2024-06-15 14:22:00',5,'Friendly atmosphere and very helpful staff.','olivia.martin@example.com','Welcome Center');
CALL AddReview('REV094','2025-04-02 09:33:00',4,'A welcoming place with good information.','noah.williams@example.com','Welcome Center');
CALL AddReview('REV095','2023-02-25 10:55:00',3,'Nice building but gets busy on tour days.','ava.brown@example.com','Welcome Center');
CALL AddReview('REV096','2024-12-12 16:47:00',1,'Long waits during peak hours.','will.jones@example.com','Welcome Center');
