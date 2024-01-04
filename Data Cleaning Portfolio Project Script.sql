-- Previewing the datasets

select * 
from PortfolioProject..NashvileHousing ;

-- Standardize Date format from datetime to date

select SaleDate , CONVERT(Date, SaleDate)
from PortfolioProject..NashvileHousing ;

UPDATE NashvileHousing
SET SaleDate =  CONVERT(Date, SaleDate)

ALTER TABLE NashVileHousing
ADD SaleDateConverted Date;

UPDATE NashvileHousing
SET SaleDateConverted =  CONVERT(Date, SaleDate)

select SaleDateConverted
from PortfolioProject..NashvileHousing ;

-- Populate Property address data

select ParcelID, PropertyAddress
from PortfolioProject..NashvileHousing
WHERE PropertyAddress is null
ORDER BY ParcelID ;

--Dealing with the null PropertyAddress

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvileHousing as a
JOIN PortfolioProject..NashvileHousing as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null ;

-- Updating the column PropertyAddress to replace Null with Property address

UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvileHousing as a
JOIN PortfolioProject..NashvileHousing as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null ;


-- Breaking out Owner Adrress column into Address, City, State Columns
-- Separate using the ',' as the delimiter 

select PropertyAddress, OwnerAddress
from PortfolioProject..NashvileHousing ;

Select PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
from PortfolioProject..NashvileHousing

ALTER TABLE NashvileHousing
Add OwnerAdrress Nvarchar(250)

Update NashvileHousing
Set OwnerAdrress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvileHousing
Add OwnerCity Nvarchar(250)

Update NashvileHousing
Set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvileHousing
Add OwnerState Nvarchar(250)

Update NashvileHousing
Set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

-- Change Y and N to YES and NO in Sold as Vacant column

select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvileHousing 
GROUP BY SoldAsVacant
order by 2;

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'NO'
		ELSE SoldAsVacant
		END
from PortfolioProject..NashvileHousing ;

Update NashvileHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'NO'
		ELSE SoldAsVacant
		END ;

-- Removing Duplicates
-- Using Row_Number to indentify where we have duplicates
-- We have 104 duplicates 

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject..NashvileHousing

)
Delete -- Deleting all the duplicates
From RowNumCTE
Where row_num > 1 ;


-- Deleting Unused Columns 

Select *
From PortfolioProject..NashvileHousing

Alter Table PortfolioProject..NashvileHousing
Drop Column OwnerAddress, SaleDate, PropertyAddress, TaxDistrict ;

