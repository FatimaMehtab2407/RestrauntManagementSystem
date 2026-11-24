# surplusFoodDonationSystem
mysql> create database SurplusFoodDB;
Query OK, 1 row affected (0.00 sec)

mysql> use SurplusFoodDB;
Database changed
mysql> create table RESTAURANT(
    -> RestaurantID int primary key,
    -> Name varchar(100) not null,
    -> Location varchar(100),
    -> Contact varchar(15)
    -> );
Query OK, 0 rows affected (0.01 sec)

mysql> create table NGO(
    -> NGOID int primary key,
    -> NGOName varchar(100) not null,
    -> Location varchar(100),
    -> Contact varchar(15)
    -> );
Query OK, 0 rows affected (0.01 sec)

mysql> create table BENEFICIARY(
    -> BeneficiaryID int primary key,
    -> Name varchar(100) not null,
    -> Location varchar(100),
    -> Contact varchar(15)
    -> );
Query OK, 0 rows affected (0.00 sec)

mysql> create table FOOD_ITEM(
    -> FoodID int primary key,
    -> RestaurantID int not null,
    -> FoodName varchar(100) not null,
    -> Quantity int not null default 0,
    -> ExpiryDate date,
    -> Status varchar(30) not null,
    -> constraint chk_food_quantity
    -> check (Quantity>=0),
    -> constraint chk_food_status
    -> check (Status in ("Available","Not Available","Claimed","Expired")),
    -> constraint fk_food_restaurant
    -> foreign key (RestaurantID)
    -> references RESTAURANT(RestaurantID)
    -> on delete cascade
    -> on update cascade
    -> );
Query OK, 0 rows affected (0.01 sec)

mysql> create table DONATION(
    -> DonationID int primary key,
    -> FoodID int not null,
    -> NGOID int not null,
    -> DonationDate date not null,
    -> Quantity int not null,
    -> constraint fk_donation_food
    -> foreign key (FoodID)
    -> references FOOD_ITEM(FoodID)
    -> on delete cascade
    -> on update cascade,
    -> constraint fk_donation_ngo
    -> foreign key (NGOID)
    -> references NGO(NGOID)
    -> on delete cascade
    -> on update cascade
    -> );
Query OK, 0 rows affected (0.01 sec)

mysql> create table PICKUP(
    -> PickupID int primary key,
    -> DonationID int not null,
    -> PickupDate date,
    -> Status varchar(30) not null,
    -> constraint chk_pickup_status
    -> check (Status in ("Scheduled","Completed")),
    -> constraint fk_pickup_donation
    -> foreign key (DonationID)
    -> references DONATION(DonationID)
    -> on delete cascade
    -> on update cascade
    -> );
Query OK, 0 rows affected (0.01 sec)

mysql> create table DISTRIBUTION(
    -> DistributionID int primary key,
    -> DonationID int not null,
    -> BeneficiaryID int not null,
    -> DistributionDate date not null,
    -> Quantity int not null,
    -> constraint fk_distribution_donation
    -> foreign key (DonationID)
    -> references DONATION(DonationID)
    -> on delete cascade
    -> on update cascade,
    -> constraint fk_distribution_beneficiary
    -> foreign key (BeneficiaryID)
    -> references BENEFICIARY(BeneficiaryID)
    -> on delete cascade
    -> on update cascade
    -> );
Query OK, 0 rows affected (0.03 sec)

-- Q1. Total Food Quantity Donated Per Restaurant

SELECT R.RestaurantID,R.Name,
COALESCE(SUM(D.Quantity),0) AS TotalFoodDonated
FROM RESTAURANT R
LEFT JOIN FOOD_ITEM F ON R.RestaurantID=F.RestaurantID
LEFT JOIN DONATION D ON F.FoodID=D.FoodID
GROUP BY R.RestaurantID,R.Name
ORDER BY TotalFoodDonated DESC;


-- Q2. Top Receiving NGOs

SELECT N.NGOID,N.NGOName,
COUNT(D.DonationID) AS TotalDonations,
COALESCE(SUM(D.Quantity),0) AS TotalFoodReceived
FROM NGO N
LEFT JOIN DONATION D ON N.NGOID=D.NGOID
GROUP BY N.NGOID,N.NGOName
ORDER BY TotalDonations DESC,TotalFoodReceived DESC;


-- Q3. Total Food Reached Each Beneficiary

SELECT B.BeneficiaryID,B.Name,
COUNT(DI.DistributionID) AS TotalDistributions,
COALESCE(SUM(DI.Quantity),0) AS TotalFoodReceived
FROM BENEFICIARY B
LEFT JOIN DISTRIBUTION DI ON B.BeneficiaryID=DI.BeneficiaryID
GROUP BY B.BeneficiaryID,B.Name
ORDER BY TotalFoodReceived DESC;


-- Q4. Total Food Distributed By Each NGO

SELECT N.NGOID,N.NGOName,
COUNT(DI.DistributionID) AS TotalDistributions,
COALESCE(SUM(DI.Quantity),0) AS TotalFoodDistributed
FROM NGO N
JOIN DONATION D ON N.NGOID=D.NGOID
JOIN DISTRIBUTION DI ON D.DonationID=DI.DonationID
GROUP BY N.NGOID,N.NGOName
ORDER BY TotalFoodDistributed DESC;


-- Q5. Pickup Status Analysis

SELECT Status,
COUNT(PickupID) AS TotalPickups
FROM PICKUP
GROUP BY Status
ORDER BY TotalPickups DESC;


-- Q6. Pickup Completion Rate

SELECT COUNT(PickupID) AS TotalPickups,
SUM(Status='Completed') AS CompletedPickups,
SUM(Status='Scheduled') AS ScheduledPickups,
ROUND(SUM(Status='Completed')*100.0/
NULLIF(COUNT(PickupID),0),2) AS CompletionPercentage
FROM PICKUP;


-- Q7. Food Item Status Analysis

SELECT Status,
COUNT(FoodID) AS TotalFoodItems,
SUM(Quantity) AS TotalQuantity
FROM FOOD_ITEM
GROUP BY Status
ORDER BY TotalFoodItems DESC;


-- Q8. Monthly Donation Analysis

SELECT YEAR(DonationDate) AS DonationYear,
MONTH(DonationDate) AS DonationMonth,
COUNT(DonationID) AS TotalDonations,
SUM(Quantity) AS TotalFoodDonated
FROM DONATION
GROUP BY YEAR(DonationDate),MONTH(DonationDate)
ORDER BY DonationYear,DonationMonth;


-- Q9. Most Donated Food Items

SELECT F.FoodID,F.FoodName,
COUNT(D.DonationID) AS TotalDonations,
SUM(D.Quantity) AS TotalQuantityDonated
FROM FOOD_ITEM F
JOIN DONATION D ON F.FoodID=D.FoodID
GROUP BY F.FoodID,F.FoodName
ORDER BY TotalQuantityDonated DESC;


-- Q10. Donation-Wise Food Distribution Analysis

SELECT D.DonationID,
D.Quantity AS DonatedQuantity,
COALESCE(SUM(DI.Quantity),0) AS DistributedQuantity,
D.Quantity-COALESCE(SUM(DI.Quantity),0) AS RemainingQuantity
FROM DONATION D
LEFT JOIN DISTRIBUTION DI ON D.DonationID=DI.DonationID
GROUP BY D.DonationID,D.Quantity
ORDER BY D.DonationID;

