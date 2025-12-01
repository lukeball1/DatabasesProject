DROP PROCEDURE IF EXISTS AddAccount;
DROP PROCEDURE IF EXISTS AddReview;
DROP PROCEDURE IF EXISTS RateReview;
DROP PROCEDURE IF EXISTS AddBuilding;
DROP PROCEDURE IF EXISTS AddSpecialFeature;

DELIMITER $$
-- Procedure to add a account
CREATE PROCEDURE AddAccount (
    IN p_HashedEmail VARCHAR(255),
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
    -- Insert into Reviewer using hashed email as the ReviewerID
    INSERT INTO Reviewer (ReviewerID, Fname, Lname, JoinDate, Password)
    VALUES (p_HashedEmail, p_Fname, p_Lname, p_JoinDate, p_HashedPassword);

    -- Insert into correct subtype table
    IF p_Type = 'Student' THEN
        INSERT INTO Student (StudentID, ReviewerID, GradYear, Major, HasGraduated, Job_Internship)
        VALUES (p_HashedEmail, p_HashedEmail, CAST(p_Extra1 AS UNSIGNED), p_Extra2, p_HasGraduated, TRUE);
    ELSEIF p_Type = 'Staff' THEN
        INSERT INTO Staff (StaffID, ReviewerID, Department, Position)
        VALUES (p_HashedEmail, p_HashedEmail, p_Extra1, p_Extra2);
    ELSEIF p_Type = 'Visitor' THEN
        INSERT INTO Visitor (VisitorID, ReviewerID, Affiliation)
        VALUES (p_HashedEmail, p_HashedEmail, p_Extra1);
    END IF;
END$$


-- Procedure to add a Review
CREATE PROCEDURE AddReview(
    IN p_ReviewID VARCHAR(255),
    IN p_DateWritten DATETIME,
    IN p_NumStars INT,
    IN p_Description CHAR(150),
    IN p_ReviewerID CHAR(75),
    IN p_BuildingName CHAR(75)
)
BEGIN
    -- Insert review
    INSERT INTO Review (ReviewID, DateWritten, NumStars, Description)
    VALUES (p_ReviewID, p_DateWritten, p_NumStars, p_Description);

    -- Link review to reviewer and building
    INSERT INTO WritesRevAbt (ReviewerID, ReviewID, BuildingID)
    VALUES (p_ReviewerID, p_ReviewID, p_BuildingName);
END$$


-- Procedure to add review rating
CREATE PROCEDURE RateReview(
    IN p_ReviewerID VARCHAR(255),
    IN p_ReviewID VARCHAR(255),
    IN p_Rating CHAR(75)  -- e.g., 'Upvote', 'Downvote', or a string-based rating
)
BEGIN
    -- Check if this reviewer has already rated this review
    IF EXISTS (SELECT 1 FROM RatesReview 
               WHERE ReviewerID = p_ReviewerID AND ReviewID = p_ReviewID) THEN
        -- Update existing rating
        UPDATE RatesReview
        SET Rating = p_Rating
        WHERE ReviewerID = p_ReviewerID AND ReviewID = p_ReviewID;
    ELSE
        -- Insert new rating
        INSERT INTO RatesReview (ReviewerID, ReviewID, Rating)
        VALUES (p_ReviewerID, p_ReviewID, p_Rating);
    END IF;
END$$


-- Procedure to add a Building
CREATE PROCEDURE AddBuilding(
    IN p_BuildingName VARCHAR(255),
    IN p_Address VARCHAR(255),
    IN p_YearBuilt INT
)
BEGIN
    INSERT INTO Building (BuildingName, Address, YearBuilt)
    VALUES (p_BuildingName, p_Address, p_YearBuilt);
END$$


-- Procedure to add a Special Feature
CREATE PROCEDURE AddSpecialFeature(
    IN p_Name VARCHAR(255),
    IN p_BuildingName VARCHAR(255),
    IN p_Description VARCHAR(255),
    IN p_Type VARCHAR(75),
    IN p_Hours DECIMAL(10,2)
)
BEGIN
    INSERT INTO SpecialFeature (Name, BuildingName, Description, Type, Hours)
    VALUES (p_Name, p_BuildingName, p_Description, p_Type, p_Hours);
END$$

DELIMITER ;