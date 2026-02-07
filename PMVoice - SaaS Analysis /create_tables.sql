-- =============================================
-- SECTION 1: DATABASE SETUP
-- =============================================

-- Switch to the system 'master' database to manage other databases
USE master;
GO

-- Check if the database 'ProductVOC_DB' already exists
-- If it exists, force close connections and DROP it to start fresh
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ProductVOC_DB')
BEGIN
    PRINT 'Database exists. Dropping...';
    ALTER DATABASE ProductVOC_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ProductVOC_DB;
END
GO

-- Create the new database
PRINT 'Creating new database: ProductVOC_DB';
CREATE DATABASE ProductVOC_DB;
GO

-- Switch to the new database
USE ProductVOC_DB;
GO

-- =============================================
-- SECTION 2: CLEANUP (DROP TABLES IF EXIST)
-- =============================================
-- We drop Fact tables first because they depend on Dimension tables (Foreign Keys)

PRINT 'Cleaning up old tables...';

DROP TABLE IF EXISTS Fact_Revenue_Events;
DROP TABLE IF EXISTS Fact_Usage_Events;
DROP TABLE IF EXISTS Fact_VOC_Mentions;
DROP TABLE IF EXISTS Dim_Users;
DROP TABLE IF EXISTS Dim_Themes;
DROP TABLE IF EXISTS Dim_Sources;
DROP TABLE IF EXISTS Dim_Calendar;
GO

-- =============================================
-- SECTION 3: CREATE DIMENSION TABLES
-- =============================================

PRINT 'Creating Dimension Tables...';

-- 1. Calendar Dimension
CREATE TABLE Dim_Calendar (
    Date DATE PRIMARY KEY,
    Year INT,
    Quarter INT,
    Month INT,
    MonthName NVARCHAR(20),
    Week INT,
    DayOfWeek NVARCHAR(20),
    IsCurrentMonth BIT
);

-- 2. Sources Dimension
CREATE TABLE Dim_Sources (
    SourceID INT PRIMARY KEY,
    SourceName NVARCHAR(100),
    PlatformType NVARCHAR(50)
);

-- 3. Themes Dimension
CREATE TABLE Dim_Themes (
    ThemeID INT PRIMARY KEY,
    ThemeName NVARCHAR(200),
    Category NVARCHAR(50),
    ImpactScore FLOAT
);

-- 4. Users Dimension
-- UserID is NVARCHAR because in Python we generated IDs like 'USR_0001'
CREATE TABLE Dim_Users (
    UserID NVARCHAR(50) PRIMARY KEY,
    Segment NVARCHAR(100),
    CompanySize NVARCHAR(50),
    PMExperienceYears INT,
    ChurnRiskScore FLOAT
);
GO

-- =============================================
-- SECTION 4: CREATE FACT TABLES
-- =============================================

PRINT 'Creating Fact Tables...';

-- 5. VOC Mentions Fact Table
CREATE TABLE Fact_VOC_Mentions (
    MentionID INT PRIMARY KEY,
    Date DATE NOT NULL,
    SourceID INT NOT NULL,
    ThemeID INT NOT NULL,
    UserID NVARCHAR(50) NOT NULL,
    Segment NVARCHAR(100),
    Type NVARCHAR(50), -- Pain, Dream, or Phrase
    SentimentScore FLOAT,
    FrequencyWeight INT,
    PhraseText NVARCHAR(MAX),
    
    -- Foreign Key Relationships
    CONSTRAINT FK_VOC_Date FOREIGN KEY (Date) REFERENCES Dim_Calendar(Date),
    CONSTRAINT FK_VOC_Source FOREIGN KEY (SourceID) REFERENCES Dim_Sources(SourceID),
    CONSTRAINT FK_VOC_Theme FOREIGN KEY (ThemeID) REFERENCES Dim_Themes(ThemeID),
    CONSTRAINT FK_VOC_User FOREIGN KEY (UserID) REFERENCES Dim_Users(UserID)
);

-- 6. Usage Events Fact Table
CREATE TABLE Fact_Usage_Events (
    EventID INT PRIMARY KEY,
    Date DATE NOT NULL,
    UserID NVARCHAR(50) NOT NULL,
    Feature NVARCHAR(100),
    EventType NVARCHAR(50), -- Adopt or Churn
    ChurnFlag INT, -- Using INT or BIT for 0/1 flag
    
    -- Foreign Key Relationships
    CONSTRAINT FK_Usage_Date FOREIGN KEY (Date) REFERENCES Dim_Calendar(Date),
    CONSTRAINT FK_Usage_User FOREIGN KEY (UserID) REFERENCES Dim_Users(UserID)
);

-- 7. Revenue Events Fact Table
CREATE TABLE Fact_Revenue_Events (
    RevenueID INT PRIMARY KEY,
    Date DATE NOT NULL,
    UserID NVARCHAR(50) NOT NULL,
    MRRAmount DECIMAL(10, 2), -- Money values should usually be DECIMAL
    GrowthMoM FLOAT,
    
    -- Foreign Key Relationships
    CONSTRAINT FK_Revenue_Date FOREIGN KEY (Date) REFERENCES Dim_Calendar(Date),
    CONSTRAINT FK_Revenue_User FOREIGN KEY (UserID) REFERENCES Dim_Users(UserID)
);
GO

PRINT 'Database and Tables created successfully.';


