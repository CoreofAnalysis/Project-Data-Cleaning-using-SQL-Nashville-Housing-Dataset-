/*
Cleaning Data in SQL queries 
*/

SELECT *
FROM PortfolioProject..[Nashville Housing Data]

--===========================================
-- Standardize data Format :
--===========================================

SELECT SaleDate, SaleDateConverted
FROM PortfolioProject..[Nashville Housing Data]

UPDATE [Nashville Housing Data]
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE [Nashville Housing Data]
Add SaleDateConverted Date;

SELECT SaleDateConverted
FROM PortfolioProject..[Nashville Housing Data]

UPDATE [Nashville Housing Data]
SET SaleDateConverted = CONVERT(Date, SaleDate)

--===========================================
-- Populate Property Address Data :
--===========================================

SELECT *
FROM PortfolioProject..[Nashville Housing Data]
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

-------
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..[Nashville Housing Data] a
JOIN PortfolioProject..[Nashville Housing Data] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null
----------
----------
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..[Nashville Housing Data] a
JOIN PortfolioProject..[Nashville Housing Data] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


----------------------------------
-- Breaking out Address into Individual
-- Columns (Address, City, State):

--===========================================
-- SPLIT PropertyAddress USING SUBSTRING()
--===========================================

SELECT *
FROM PortfolioProject..[Nashville Housing Data]
--WHERE PropertyAddress is null
--  order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' ,PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',' ,PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..[Nashville Housing Data]
--==================================

ALTER TABLE [Nashville Housing Data]
ADD PropertySplitAddress nVARCHAR(255),
	PropertySplitCity nVARCHAR(255);

UPDATE [Nashville Housing Data]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' ,PropertyAddress) -1);
	
UPDATE [Nashville Housing Data]
SET	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' ,PropertyAddress) +1, LEN(PropertyAddress)) ;
-----
-----
SELECT PropertySplitAddress, PropertySplitCity
FROM PortfolioProject..[Nashville Housing Data]

-----------------------------------------------
-----------------------------------------------
SELECT OwnerAddress
FROM PortfolioProject..[Nashville Housing Data]

--===========================================
-- SPLIT OWNERADDRESS USING PARSENAME()
--===========================================

SELECT 
--REPLACE(OwnerAddress,'-',',')
PARSENAME(REPLACE(OwnerAddress, ',', '.'),  3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),  2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),  1)
FROM PortfolioProject..[Nashville Housing Data]

ALTER TABLE [Nashville Housing Data]
ADD OwnerSplitAddress nVARCHAR(255),
	OwneSplitCity nVARCHAR(255),
	OwneSplitState nVARCHAR(255);

UPDATE [Nashville Housing Data]
SET	OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),  3),
	OwneSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),  2),
	OwneSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),  1)

SELECT *
FROM PortfolioProject..[Nashville Housing Data]


---------------------------------------------
--===========================================
/* Changing Y and N to 'Yes'/'NO' 
from 'SOld as vacant' column */

--===========================================

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..[Nashville Housing Data]
GROUP BY SoldasVacant
ORDER BY 2
-------------------------------

SELECT SoldAsVacant
	,CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM PortfolioProject..[Nashville Housing Data]
--------

UPDATE [Nashville Housing Data]
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

--===============================================
-- Removing Duplicates 
--===============================================

WITH RowNumCTE as(
SELECT *,	
		ROW_NUMBER() OVER (
		PARTITION  BY ParcelID,
					  PropertyAddress,
					  SalePrice,
					  SaleDate,
					  LegalReference
					  ORDER BY UniqueID
		) row_num
FROM PortfolioProject..[Nashville Housing Data]
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

--===============================================
-- DELETE UNUSED COLUMNS
--===============================================


SELECT *
FROM PortfolioProject..[Nashville Housing Data]

ALTER TABLE [Nashville Housing Data]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Nashville Housing Data]
DROP COLUMN SaleDate