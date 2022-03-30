/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProjecct..NashvileHousing

--Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProjecct..NashvileHousing

Update NashvileHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvileHousing
Add SaleDateConverted Date;

Update NashvileHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address Data

SELECT *
FROM PortfolioProjecct..NashvileHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjecct..NashvileHousing AS a
JOIN PortfolioProjecct..NashvileHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjecct..NashvileHousing AS a
JOIN PortfolioProjecct..NashvileHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProjecct..NashvileHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM PortfolioProjecct..NashvileHousing

ALTER TABLE NashvileHousing
Add PropertySplitAddress NVARCHAR(255);

Update NashvileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvileHousing
Add PropertySplitCity NVARCHAR(255);

Update NashvileHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT * 
FROM PortfolioProjecct..NashvileHousing



SELECT OwnerAddress
FROM PortfolioProjecct..NashvileHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProjecct..NashvileHousing

ALTER TABLE NashvileHousing
Add OwnerSplitAddress NVARCHAR(255);

Update NashvileHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvileHousing
Add OwnerSplitCity NVARCHAR(255);

Update NashvileHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvileHousing
Add OwnerSplitState NVARCHAR(255);

Update NashvileHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProjecct..NashvileHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant='Y' THEN 'Yes'
       WHEN SoldAsVacant='N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProjecct..NashvileHousing

UPDATE NashvileHousing
SET SoldAsVacant=CASE WHEN SoldAsVacant='Y' THEN 'Yes'
       WHEN SoldAsVacant='N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--Remove Duplicates

WITH RowNumCTE AS(
SELECT *, 
     ROW_NUMBER() OVER(
	 PARTITION BY ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY
				     UniqueID
					 ) Row_Num
				  
FROM PortfolioProjecct..NashvileHousing
)

DELETE
FROM RowNumCTE
WHERE Row_Num > 1


--Delete Unused Columns

SELECT * 
FROM PortfolioProjecct..NashvileHousing

ALTER TABLE PortfolioProjecct..NashvileHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

