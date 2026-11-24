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
