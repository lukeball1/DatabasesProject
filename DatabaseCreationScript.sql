-- Drop tables in correct order(children first)
DROP TABLE IF EXISTS SortFilter;
DROP TABLE IF EXISTS RatesReview;
DROP TABLE IF EXISTS WritesRevAbt;
DROP TABLE IF EXISTS Review;
DROP TABLE IF EXISTS SpecialFeature;
DROP TABLE IF EXISTS Building;
DROP TABLE IF EXISTS Student;
DROP TABLE IF EXISTS Staff;
DROP TABLE IF EXISTS Visitor;
DROP TABLE IF EXISTS Reviewer;



-- Create tables
-- Reviewer table
CREATE TABLE Reviewer (
    ReviewerID CHAR(150) PRIMARY KEY,
    Fname CHAR(75),
    Lname CHAR(75),
    JoinDate CHAR(75),
    Password VARCHAR(255)
);

-- Student table
CREATE TABLE Student (
    StudentID CHAR(75) PRIMARY KEY,
    ReviewerID CHAR(75),
    GradYear INT,
    Major CHAR(75),
    HasGraduated BOOLEAN,
    Job_Internship CHAR(75),
    FOREIGN KEY (ReviewerID) REFERENCES Reviewer(ReviewerID)
);

-- Staff table
CREATE TABLE Staff (
    StaffID CHAR(75) PRIMARY KEY,
    ReviewerID CHAR(75),
    Department CHAR(75),
    Position CHAR(75),
    FOREIGN KEY (ReviewerID) REFERENCES Reviewer(ReviewerID)
);

-- Visitor table
CREATE TABLE Visitor (
    VisitorID CHAR(75) PRIMARY KEY,
    ReviewerID CHAR(75),
    Affiliation CHAR(75),
    FOREIGN KEY (ReviewerID) REFERENCES Reviewer(ReviewerID)
);

-- Building table
CREATE TABLE Building (
    BuildingName CHAR(75) PRIMARY KEY,
    Address CHAR(75),
    YearBuilt INT
);

-- SpecialFeature table
CREATE TABLE SpecialFeature (
    Name CHAR(75) PRIMARY KEY,
    BuildingName CHAR(75),
    Description CHAR(150),
    Type CHAR(75),
    Hours DECIMAL,
    FOREIGN KEY (BuildingName) REFERENCES Building(BuildingName)
);

-- Review table
CREATE TABLE Review (
    ReviewID CHAR(75) PRIMARY KEY,
    DateWritten DATETIME,
    NumStars INT,
    Description CHAR(150)
);

-- WritesRevAbt table
CREATE TABLE WritesRevAbt (
    ReviewerID CHAR(75),
    ReviewID CHAR(75),
    BuildingID CHAR(75),
    PRIMARY KEY (ReviewerID, ReviewID, BuildingID),
    FOREIGN KEY (ReviewerID) REFERENCES Reviewer(ReviewerID),
    FOREIGN KEY (ReviewID) REFERENCES Review(ReviewID),
    FOREIGN KEY (BuildingID) REFERENCES Building(BuildingName)
);

-- RatesReview table
CREATE TABLE RatesReview (
    ReviewerID CHAR(75),
    ReviewID CHAR(75),
    Rating CHAR(75),
    PRIMARY KEY (ReviewerID, ReviewID),
    FOREIGN KEY (ReviewerID) REFERENCES Reviewer(ReviewerID),
    FOREIGN KEY (ReviewID) REFERENCES Review(ReviewID)
);

-- SortFilter table
CREATE TABLE SortFilter (
    ReviewerID CHAR(75),
    ReviewID CHAR(75),
    SortBy CHAR(75),
    PRIMARY KEY (ReviewerID, ReviewID),
    FOREIGN KEY (ReviewerID) REFERENCES Reviewer(ReviewerID),
    FOREIGN KEY (ReviewID) REFERENCES Review(ReviewID)
);



-- Insert already known information (I think its just buildiing and special features)
-- Buildings
INSERT INTO Building (BuildingName, Address, YearBuilt)
VALUES
('Bertelsmeyer Hall', '1101 N. State St.', NULL),
('Butler-Carlton Civil Engineering Hall', '1401 N. Pine St.', NULL),
('Computer Science Building', '500 W. 15th St.', NULL),
('Emerson Electric Company Hall', '301 W. 16th St.', NULL),
('Harris Hall', '500 W. 13th St.', NULL),
('Fulton Hall', '301 W. 14th St.', NULL),
('Humanities and Social Science Building', '500 W. 14th St.', NULL),
('McNutt Hall', '1400 N. Bishop Ave.', NULL),
('Physics Building', '1315 N. Pine St.', NULL),
('Rolla Building', '400 W. 12th St.', NULL),
('Schrenk Hall', '400 W. 11th St.', NULL),
('Toomey Hall', '400 W. 13th St.', NULL),
('Curtis Laws Wilson Library', '400 W. 14th St.', NULL),
('Straumanis James Hall', '401 W. 16th St.', NULL),
('Residential Commons 1', '710 Tim Bradley Way', NULL),
('Residential Commons 2', '1575 Watts Dr.', NULL),
('University Commons', '810 Tim Bradley Way', NULL),
('Centennial Hall', '300 W. 12th St.', NULL),
('Havener Center', '1346 N. Bishop Ave.', NULL),
('Innovation Lab', '650 Tim Bradley Way', NULL),
('Norwood Hall', '320 W. 12th St.', NULL),
('Parker Hall', '300 W. 13th St.', NULL),
('University Police', '205 W. 12th St.', NULL),
('Welcome Center', '500 Tim Bradley Way', NULL);