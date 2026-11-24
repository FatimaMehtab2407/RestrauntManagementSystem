
USE SurplusFoodDB;

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
