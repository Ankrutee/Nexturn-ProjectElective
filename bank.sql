DROP DATABASE IF EXISTS bank;
CREATE DATABASE bank;
-- Use the database
USE bank;

create table Employee (
	EmployeeID int primary key not null,
	EmployeeFirstName varchar(25) not null,
	EmployeeMiddleInitial char(1),
	EmployeeLastName varchar(25) not null,
	EmployeeIsManager bit
	);
insert into Employee values (1, 'Marc','A', 'Kambou',1);
insert into Employee values	(2, 'John','', 'Doe',0);
insert into Employee values	(3, 'Jane','', 'Smith',0);
insert into Employee values	(4, 'Max','', 'Maxwell',0);


	-- table user logins

create table UserLogins (
	UserLoginID int primary key not null,
	UserLogin char(15) not null,
	UserPassword varchar(20) not null
	);
insert into UserLogins values (1, 'abc123', 'password1');
insert into UserLogins values (2, 'abc456', 'password2');
insert into UserLogins values (3, 'cde123', 'password3');
insert into UserLogins values (4, 'cde456', 'password4');

	-- table user security questions

create table UserSecurityQuestions (
	UserSecurityQuestionID int primary key not null,
	UserSecurityQuestion varchar(50) not null
	);
insert into UserSecurityQuestions values (1, 'What is your first pet name?');
insert into UserSecurityQuestions values (2, 'What is your best friend name?');
insert into UserSecurityQuestions values (3, 'What was your first car color?');
insert into UserSecurityQuestions values (4, 'In which city were you born?');

	
	-- table account type

create table AccountType (
	AccountTypeID int primary key not null,
	AccountTypeName varchar(30) not null
	);
insert into AccountType values (1, 'Chequing');
insert into AccountType values (2, 'Savings');
insert into AccountType values (3, 'TFSA');
insert into AccountType values (4, 'RRSP');


	-- table Savings interest rates

create table SavingsInterestRates (
	InterestSavingsRateID int primary key not null,
	InterestRateValue float not null,
	InterestRateName varchar(20)
	);
insert into SavingsInterestRates values (1, 3.6, 'description 1');
insert into SavingsInterestRates values (2, 4.8, 'description 2');
insert into SavingsInterestRates values (3, 5.5, 'description 3');
insert into SavingsInterestRates values (4, 6.5, 'description 4');


create table AccountStatusType (
	AccountStatusTypeID int primary key not null,
	AccountStatusName varchar(30) not null
	);
insert into AccountStatusType values (1, 'Closed');
insert into AccountStatusType values (2, 'Open');

CREATE TABLE TransactionType (
    TransactionTypeID INT PRIMARY KEY NOT NULL,
    TransactionTypeName VARCHAR(10) NOT NULL,
    TransactionFeeAmount DECIMAL(10, 2) NOT NULL
);

INSERT INTO TransactionType VALUES (1, 'Transfer', 500.00);
INSERT INTO TransactionType VALUES (2, 'Bill', 80.00);
INSERT INTO TransactionType VALUES (3, 'Car', 250.00);
INSERT INTO TransactionType VALUES (4, 'Insurance', 300.00);


create table LoginErrorLog (
	ErrorLogID int primary key not null,
	ErrorTime text not null
	);
insert into LoginErrorLog values (1, '2018/05/03');
insert into LoginErrorLog values (2, '2018/11/23');
insert into LoginErrorLog values (3, '2019/03/27');
insert into LoginErrorLog values (4, '2019/06/21');


create table FailedTransactionErrorType (
	FailedTransactionErrorTypeID int primary key not null,
	FailedTransactionName varchar(50) not null
	);
insert into FailedTransactionErrorType values (1, 'Error type 1');
insert into FailedTransactionErrorType values (2, 'Error type 2');
insert into FailedTransactionErrorType values (3, 'Error type 3');
insert into FailedTransactionErrorType values (4, 'Error type 4');

CREATE TABLE FailedTransactionLog (
    FailedTransactionID INT PRIMARY KEY NOT NULL,
    FailedTransactionErrorTypeID INT NOT NULL,
    FailedTransactionErrorTime DATE NOT NULL,  -- Using DATE for date-only values
    FailedTransactionXML TEXT NOT NULL,
    FOREIGN KEY (FailedTransactionErrorTypeID) REFERENCES FailedTransactionErrorType(FailedTransactionErrorTypeID)
);

-- Insert values
INSERT INTO FailedTransactionLog VALUES (1, 3, '2018-10-15', 'Error log 1');
INSERT INTO FailedTransactionLog VALUES (5, 1, '2018-11-09', 'Error log 2');
INSERT INTO FailedTransactionLog VALUES (3, 4, '2019-02-20', 'Error log 3');
INSERT INTO FailedTransactionLog VALUES (4, 2, '2019-04-12', 'Error log 4');


DROP TABLE IF EXISTS AccountType;
DROP TABLE IF EXISTS AccountStatusType;
DROP TABLE IF EXISTS SavingsInterestRates;
DROP TABLE IF EXISTS UserLogins;
DROP TABLE IF EXISTS Account;
DROP TABLE IF EXISTS OverDraftLog;
DROP TABLE IF EXISTS Customer;

-- Table: AccountType
CREATE TABLE AccountType (
    AccountTypeID INT PRIMARY KEY NOT NULL,
    AccountTypeName VARCHAR(50) NOT NULL
);

-- Table: AccountStatusType
CREATE TABLE AccountStatusType (
    AccountStatusTypeID INT PRIMARY KEY NOT NULL,
    AccountStatusName VARCHAR(50) NOT NULL
);

-- Table: SavingsInterestRates
CREATE TABLE SavingsInterestRates (
    InterestSavingsRateID INT PRIMARY KEY NOT NULL,
    InterestRate DECIMAL(5, 2) NOT NULL
);

-- Table: UserLogins
CREATE TABLE UserLogins (
    UserLoginID INT PRIMARY KEY NOT NULL,
    UserName VARCHAR(50) NOT NULL
);

CREATE TABLE Account (
    AccountID INT PRIMARY KEY NOT NULL,
    CurrentBalance INT NOT NULL,
    AccountTypeID INT NOT NULL,
    AccountStatusTypeID INT NOT NULL,
    InterestSavingsRateID INT NOT NULL,
    FOREIGN KEY (AccountTypeID) REFERENCES AccountType(AccountTypeID),
    FOREIGN KEY (AccountStatusTypeID) REFERENCES AccountStatusType(AccountStatusTypeID),
    FOREIGN KEY (InterestSavingsRateID) REFERENCES SavingsInterestRates(InterestSavingsRateID)
);

CREATE TABLE OverDraftLog (
    AccountID INT PRIMARY KEY NOT NULL,
    OverDraftDate DATE NOT NULL,
    OverDraftAmount INT NOT NULL,
    OverDraftTransactionXML TEXT,
    FOREIGN KEY (AccountID) REFERENCES Account(AccountID)
);

CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY NOT NULL,
    CustomerAddress1 VARCHAR(30) NOT NULL,
    CustomerAddress2 VARCHAR(30),
    CustomerFirstName VARCHAR(30) NOT NULL,
    CustomerMiddleInitial CHAR(1),
    CustomerLastName VARCHAR(30) NOT NULL,
    City VARCHAR(20) NOT NULL,
    State CHAR(2) NOT NULL,
    ZipCode CHAR(10) NOT NULL,
    EmailAddress VARCHAR(40) NOT NULL,
    HomePhone CHAR(10) NOT NULL,
    CellPhone CHAR(10),
    WorkPhone CHAR(10),
    SSN CHAR(9),
    UserLoginID INT NOT NULL,
    FOREIGN KEY (UserLoginID) REFERENCES UserLogins(UserLoginID)
);

-- Insert into AccountType
INSERT INTO AccountType VALUES (1, 'Savings'), (2, 'Current'), (3, 'Fixed Deposit'), (4, 'Recurring Deposit');

-- Insert into AccountStatusType
INSERT INTO AccountStatusType VALUES (1, 'Active'), (2, 'Inactive');

-- Insert into SavingsInterestRates
INSERT INTO SavingsInterestRates VALUES (1, 4.5), (2, 5.0), (3, 6.0), (4, 7.0);

-- Insert into UserLogins
INSERT INTO UserLogins VALUES (1, 'johndoe'), (2, 'janedoe'), (3, 'robert'), (4, 'christine');

-- Insert into Account
INSERT INTO Account VALUES
(1, 6000, 1, 1, 4),
(2, 0, 3, 2, 3),
(3, 2500, 1, 1, 1),
(4, 1500, 1, 1, 2),
(5, 15000, 2, 1, 2),
(6, 12000, 2, 1, 2),
(7, 2225, 3, 1, 1),
(8, 4500, 4, 1, 3),
(9, 18250, 1, 1, 2);

-- Insert into OverDraftLog
INSERT INTO OverDraftLog VALUES
(1, '2018-04-25', 200, 'transaction 1'),
(2, '2018-11-30', 85, 'transaction 2'),
(3, '2019-02-18', 158, 'transaction 3'),
(4, '2019-05-02', 250, 'transaction 4');

-- Insert into Customer
INSERT INTO Customer VALUES
(1, '123 Main Street', '', 'John', 'A', 'Doe', 'Cityville', 'CA', '12333', 'abc@abc.com', '1234562211', '', '', '123456789', 1),
(2, '45 Factice Street', '', 'Jane', '', 'Noname', 'Libertyville', 'NY', '22456', 'cde@gmail.com', '5554446566', '', '', '555666111', 2),
(3, '1235 Ontario Street', 'Unit 4', 'Max', 'R', 'Ford', 'Deauville', 'AB', '13000', 'max@max.com', '2224567788', '', '', '234567891', 4),
(4, '789 Canada Street', 'Unit 78', 'Robert', '', 'Redford', 'Robertville', 'MA', '35456', 'robert@robert.com', '7894561213', '', '', '555777888', 3),
(5, '869 Ontario Street', '', 'Marc', '', 'Morrison', 'Cityville', 'ON', '11222', 'robert@robert.com', '2264451546', '', '', '555777888', 3),
(6, '86 Mississauga Road', '', 'Christine', 'N', 'Johannson', 'Mississauga', 'ON', '11122', 'christine@christine.com', '6472227879', '', '', '556789152', 4),
(7, '52 Quebec Street', '', 'Estelle', '', 'Robinson', 'Montreal', 'QC', '11323', 'estelle@estelle.com', '5142227879', '', '', '556516152', 2),
(8, '19 Fakestreet Road', '', 'Robin', '', 'Robinson', 'Ottawa', 'ON', '11345', 'robin@robin.com', '6132227879', '', '', '558656152', 1),
(9, '30 Independence Road', '', 'Soledad', 'R', 'Matteson', 'New York', 'NY', '12565', 'soledad@soledad.com', '2102242879', '', '', '554657123', 3);


-- Table: CustomerAccount
CREATE TABLE CustomerAccount (
    AccountID INT NOT NULL,
    CustomerID INT NOT NULL,
    FOREIGN KEY (AccountID) REFERENCES Account(AccountID),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);
INSERT INTO CustomerAccount VALUES (1, 2), (2, 4), (3, 1), (4, 3), (5, 6), (6, 8), (7, 3), (8, 4), (9, 5);

-- Table: LoginAccount
CREATE TABLE LoginAccount (
    UserLoginID INT NOT NULL,
    AccountID INT NOT NULL,
    FOREIGN KEY (UserLoginID) REFERENCES UserLogins(UserLoginID),
    FOREIGN KEY (AccountID) REFERENCES Account(AccountID)
);
INSERT INTO LoginAccount VALUES (1, 2), (2, 4), (3, 1), (4, 3);

-- Table: UserSecurityAnswers
CREATE TABLE UserSecurityAnswers (
    UserLoginID INT PRIMARY KEY NOT NULL,
    UserSecurityAnswer VARCHAR(25) NOT NULL,
    UserSecurityQuestionID INT NOT NULL,
    FOREIGN KEY (UserLoginID) REFERENCES UserLogins(UserLoginID),
    FOREIGN KEY (UserSecurityQuestionID) REFERENCES UserSecurityQuestions(UserSecurityQuestionID)
);
INSERT INTO UserSecurityAnswers VALUES 
(1, 'Rookie', 1),
(2, 'Toronto', 4),
(3, 'Robert', 2),
(4, 'Blue', 3);

-- Table: TransactionLog
CREATE TABLE TransactionLog (
    TransactionID INT PRIMARY KEY NOT NULL,
    TransactionDate DATETIME NOT NULL,
    TransactionTypeID INT NOT NULL,
    TransactionAmount INT NOT NULL,
    NewBalance INT NOT NULL,
    AccountID INT NOT NULL,
    CustomerID INT NOT NULL,
    EmployeeID INT NOT NULL,
    UserLoginID INT NOT NULL,
    FOREIGN KEY (TransactionTypeID) REFERENCES TransactionType(TransactionTypeID),
    FOREIGN KEY (AccountID) REFERENCES Account(AccountID),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
    FOREIGN KEY (UserLoginID) REFERENCES UserLogins(UserLoginID)
);
INSERT INTO TransactionLog VALUES 
(1, '2018-04-25 10:45:00', 1, 250, 1500, 1, 2, 1, 1),
(2, '2018-10-01 09:32:00', 2, 100, 3150, 3, 1, 2, 4),
(3, '2019-01-31 13:25:00', 4, 450, 4225, 2, 4, 3, 2),
(4, '2019-05-11 18:22:00', 3, 125, 2550, 4, 3, 4, 3);

CREATE TABLE IF NOT EXISTS queries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    description VARCHAR(255) NOT NULL,
    sql_query TEXT NOT NULL
);

INSERT INTO queries (description, sql_query) VALUES
('Get the total number of customers', 
 'SELECT COUNT(*) FROM Customer;'),

('Get the total balance across all accounts', 
 'SELECT SUM(CurrentBalance) FROM Account;'),

('Get the total transaction amount for a specific account', 
 'SELECT SUM(TransactionAmount) FROM TransactionLog WHERE AccountID = ?;'),

('List customers with their total transaction amounts', 
 'SELECT 
    c.CustomerID,
    CONCAT(c.CustomerFirstName, ' ', c.CustomerLastName) AS CustomerName,
    SUM(t.TransactionAmount) AS TotalTransactionAmount
FROM 
    Customer c
JOIN 
    CustomerAccount ca ON c.CustomerID = ca.CustomerID
JOIN 
    TransactionLog t ON ca.AccountID = t.AccountID
GROUP BY 
    c.CustomerID, 
    c.CustomerFirstName, 
    c.CustomerLastName
ORDER BY 
    TotalTransactionAmount DESC;'),

('List accounts with transaction counts greater than a threshold', 
 'SELECT T.AccountID, COUNT(T.TransactionID) AS TransactionCount
  FROM TransactionLog T
  GROUP BY T.AccountID
  HAVING COUNT(T.TransactionID) > ?;'),

('Get the details of all transactions made by a specific customer', 
 'SELECT T.TransactionTypeID, T.TransactionDate, T.TransactionAmount, T.NewBalance
  FROM TransactionLog T
  JOIN CustomerAccount CA ON T.AccountID = CA.AccountID
  WHERE CA.CustomerID = ?;'),

('Get employees with the total amount of transactions they handled', 
 'SELECT      e.EmployeeID,      SUM(t.TransactionAmount) AS TotalTransactionAmount FROM      TransactionLog t JOIN      Employee e ON t.EmployeeID = e.EmployeeID GROUP BY      e.EmployeeID
ORDER BY      TotalTransactionAmount DESC;'),

('List accounts with their latest transaction details', 
 'SELECT T.AccountID, T.TransactionDate AS LatestTransactionDate, T.TransactionAmount, T.NewBalance
FROM TransactionLog T
JOIN (
    SELECT AccountID, MAX(TransactionDate) AS LatestTransactionDate
    FROM TransactionLog
    GROUP BY AccountID
) AS LatestTransactions
ON T.AccountID = LatestTransactions.AccountID AND T.TransactionDate = LatestTransactions.LatestTransactionDate;
'),

('Get the total number of transactions and their sum grouped by transaction type', 
 'SELECT TT.TransactionTypeName, COUNT(T.TransactionID) AS TransactionCount, SUM(T.TransactionAmount) AS TotalAmount
  FROM TransactionType TT
  JOIN TransactionLog T ON TT.TransactionTypeID = T.TransactionTypeID
  GROUP BY TT.TransactionTypeName;'),

('Get the customers who made transactions above a certain amount', 
 'SELECT DISTINCT C.CustomerID, C.CustomerFirstName
  FROM Customer C
  JOIN CustomerAccount CA ON C.CustomerID = CA.CustomerID
  JOIN TransactionLog T ON CA.AccountID = T.AccountID
  WHERE T.TransactionAmount > ?;'),
  ('What is the most common failed transaction error type?',
  'SELECT FailedTransactionName, COUNT(*) as Count
    FROM FailedTransactionLog
    INNER JOIN FailedTransactionErrorType
        ON FailedTransactionLog.FailedTransactionErrorTypeID = FailedTransactionErrorType.FailedTransactionErrorTypeID
    GROUP BY FailedTransactionLog.FailedTransactionErrorTypeID, FailedTransactionName
    ORDER BY Count DESC
    LIMIT 1;')
  ;

