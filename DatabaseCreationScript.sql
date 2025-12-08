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
    Position CHAR(75),
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
    ReviewID CHAR(75) PRIMARY KEY,
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
    IN p_Extra2 VARCHAR(75), -- Major / Position / NULL
    IN p_HasGraduated BOOLEAN -- Only used for students
)
BEGIN
    INSERT INTO Reviewer (ReviewerID, Fname, Lname, JoinDate, Password)
    VALUES (p_Email, p_Fname, p_Lname, p_JoinDate, p_HashedPassword);

    IF p_Type = 'Student' THEN
        INSERT INTO Student (StudentID, ReviewerID, GradYear, Major, HasGraduated)
        VALUES (p_Email, p_Email, CAST(p_Extra1 AS UNSIGNED), p_Extra2, p_HasGraduated, TRUE);
    ELSEIF p_Type = 'Staff' THEN
        INSERT INTO Staff (StaffID, ReviewerID, Department, Position)
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