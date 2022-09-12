/*
Cleaning data in SQL Queries
*/

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------

--Standardize date Format

SELECT SaleDate, CAST(saleDate as date)
FROM PortfolioProject.DBO.NashvilleHousing

ALTER TABLE nashvillehousing
ALTER column SaleDate Date

-----------------------------------------------------------------------

--Populate Property Address Data

SELECT *
FROM PortfolioProject.DBO.NashvilleHousing
WHERE  PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress , b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.DBO.NashvilleHousing a
JOIN PortfolioProject.DBO.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.DBO.NashvilleHousing a
JOIN PortfolioProject.DBO.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null

-----------------------------------------------------------------------

--Breaking out address into indivisual columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.DBO.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM PortfolioProject.DBO.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

SELECT *
FROM PortfolioProject.DBO.NashvilleHousing

SELECT OwnerAddress
FROM PortfolioProject.DBO.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.DBO.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject.DBO.NashvilleHousing

-----------------------------------------------------------------------

-- Change Y and N to Yes and NO in "SoldAsVacant" Field

SELECT Distinct(SoldAsVacant),count(SoldAsVacant)
FROM PortfolioProject.DBO.NashvilleHousing
Group By SoldAsVacant

SELECT SoldAsVacant,
	CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.DBO.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-----------------------------------------------------------------------

--Remove Duplicates

SELECT *
FROM PortfolioProject.DBO.NashvilleHousing

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelId,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				LegalReference
				ORDER BY
					UniqueID) row_num
FROM PortfolioProject.DBO.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

-----------------------------------------------------------------------
--Delete Unused Columns

SELECT *
FROM PortfolioProject.DBO.NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress,OwnerAddress

-----------------------------------------------------------------------