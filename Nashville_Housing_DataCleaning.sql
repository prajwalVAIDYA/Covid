SELECT *
FROM Nashville_Housing..Sheet1$


--Standardize Date Format

SELECT SaleDate, CONVERT(date,SaleDate)
FROM Nashville_Housing..Sheet1$

ALTER TABLE Sheet1$
ADD SalesDateConverted date;

Update Sheet1$
SET SalesDateConverted = CONVERT(date,SaleDate)


SELECT SalesDateConverted
FROM Nashville_Housing..Sheet1$


--Populate Property Address date

SELECT *
FROM Nashville_Housing..Sheet1$
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville_Housing..Sheet1$ a
JOIN Nashville_Housing..Sheet1$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville_Housing..Sheet1$ a
JOIN Nashville_Housing..Sheet1$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null	


-- Breaking out Address into Individual Columns (Address, City, State)
--Property Address using SUBSTRING

SELECT PropertyAddress
FROM Nashville_Housing..Sheet1$ 
WHERE PropertyAddress is null
ORDER BY ParcelID


SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as CITY
FROM Nashville_Housing..Sheet1$ 


ALTER TABLE Sheet1$
ADD PropertySplitAdd NVARCHAR(225);

Update Sheet1$
SET PropertySplitAdd  = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Sheet1$
ADD PropertySplitCity NVARCHAR(225);

Update Sheet1$
SET PropertySplitCity  = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT PropertySplitAdd, PropertySplitCity
FROM Nashville_Housing..Sheet1$ 

--Owners Addrress using PARSENAME

SELECT OwnerAddress
FROM Nashville_Housing..Sheet1$ 

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM Nashville_Housing..Sheet1$ 

ALTER TABLE Sheet1$
Add OwnerSplitAddress Nvarchar(255);

Update Sheet1$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Sheet1$
Add OwnerSplitCity Nvarchar(255);

Update Sheet1$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE Sheet1$
Add OwnerSplitState Nvarchar(255);

Update Sheet1$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
FROM Nashville_Housing..Sheet1$ 



-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Nashville_Housing..Sheet1$
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Nashville_Housing..Sheet1$


Update Sheet1$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

SELECT  SoldAsVacant, Count(SoldAsVacant)
From Nashville_Housing..Sheet1$
Group by SoldAsVacant



-- Remove Duplicates

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

From Nashville_Housing..Sheet1$
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


Select *
From Nashville_Housing..Sheet1$



-- Delete Unused Columns

ALTER TABLE Nashville_Housing..Sheet1$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From Nashville_Housing..Sheet1$