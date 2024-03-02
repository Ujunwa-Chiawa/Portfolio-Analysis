select *
from [dbo].[NashvilleHousing]

--Standardize Dtae Format

select StandardSaleDate, CONVERT(Date, SaleDate)
from [dbo].[NashvilleHousing]

ALTER TABLE [dbo].[NashvilleHousing]
ADD StandardSaleDate Date;

UPDATE [dbo].[NashvilleHousing]
SET StandardSaleDate = CONVERT(Date, SaleDate)


---Populate Property Address

select *
from [dbo].[NashvilleHousing]
Order by ParcelID


select a.parcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)
from [dbo].[NashvilleHousing] as a
Join [dbo].[NashvilleHousing] as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
from [dbo].[NashvilleHousing] as a
Join [dbo].[NashvilleHousing] as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM [dbo].[NashvilleHousing]

ALTER TABLE [dbo].[NashvilleHousing]
ADD PropertySplitAddress NVARCHAR(255);

UPDATE [dbo].[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [dbo].[NashvilleHousing]
ADD PropertySplitCity NVARCHAR(255);


UPDATE [dbo].[NashvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM [dbo].[NashvilleHousing]

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
FROM [dbo].[NashvilleHousing]

ALTER TABLE [dbo].[NashvilleHousing]
ADD OwnerSplitAddress NVARCHAR(255);


UPDATE [dbo].[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [dbo].[NashvilleHousing]
ADD OwnerSplitCity NVARCHAR(255);

UPDATE [dbo].[NashvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [dbo].[NashvilleHousing]
ADD OwnerSplitState NVARCHAR(255);

UPDATE [dbo].[NashvilleHousing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Change Y and N to YES and NO in "Sold As Vacant"

Select Distinct(SoldAsVacant), count(SoldAsVacant)
FROM [dbo].[NashvilleHousing]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant ='Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
FROM [dbo].[NashvilleHousing]

UPDATE [dbo].[NashvilleHousing]
SET SoldAsVacant =
CASE WHEN SoldAsVacant ='Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END

--REMOVE DUPLICATES 

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
				UniqueID) AS
				row_num
FROM [dbo].[NashvilleHousing]
)

DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


--DELETE UNUSED COLUMNS
ALTER TABLE [dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

Select *
FROM [dbo].[NashvilleHousing]