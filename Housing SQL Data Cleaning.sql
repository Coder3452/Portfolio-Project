

--Cleaning Data in SQL Queries
------------------------------------------------------------------------------------------------

--Standardize Date Format


SELECT SaleDate, CONVERT(Date, SaleDate)
FROM [Portfolio Project]..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate date;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

UPDATE NashvilleHousing
SET SalesDateConverted = SaleDate

SELECT SalesDateConverted FROM [Portfolio Project]..NashvilleHousing

------------------------------------------------------------------------------------------------

--Populate Property Address Data


SELECT *
FROM [Portfolio Project]..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] < > b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] < > b.[UniqueID ]
WHERE a.PropertyAddress is null

------------------------------------------------------------------------------------------------

--Breaking Out Address Into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM [Portfolio Project]..NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

FROM [Portfolio Project].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT * FROM [Portfolio Project]..NashvilleHousing

SELECT OwnerAddress
FROM [Portfolio Project]..NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


SELECT * FROM [Portfolio Project]..NashvilleHousing

-------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM [Portfolio Project]..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-------------------------------------------------------------------------------------------------

--Remove Duplicates


WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID) row_num
FROM [Portfolio Project]..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

SELECT * FROM [Portfolio Project]..NashvilleHousing

-------------------------------------------------------------------------------------------------

--Delete Unused Columns


SELECT * FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN SaleDate

-------------------------------------------------------------------------------------------------