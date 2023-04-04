USE Nashville 

GO

select *
FROM dbo.Nashville


------ Standarize Date Format


ALTER TABLE Nashville
ADD SaleDate2 Date;

UPDATE Nashville
SET SaleDate2 = CONVERT(Date,SaleDate)

ALTER TABLE NAshville
DROP COLUMN SaleDate


EXEC sp_rename 'dbo.Nashville.SaleDate2', 'SaleDate', 'COLUMN';

------ Populate Property Address Data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.Nashville a
JOIN dbo.Nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null
ORDER BY a.ParcelID

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.Nashville a
JOIN dbo.Nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null

------ Breaking out Address into Individual Columns  (Address, City, State)

-- Using Substring for Property Address
SELECT PropertyAddress
FROM dbo.Nashville

SELECT  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
		SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM dbo.Nashville

ALTER TABLE Nashville
ADD PropertySplitAddress Nvarchar(255);

UPDATE Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Nashville
ADD PropertySplitCity Nvarchar(255);

UPDATE Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- Using PARSENAME for OwnerAddress

Select  PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
		PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
		PARSENAME(REPLACE(OwnerAddress,',','.'), 1)		
FROM Nashville

ALTER TABLE Nashville
ADD OwnerSplitAddress Nvarchar(255);

UPDATE Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE Nashville
ADD OwnerSplitCity Nvarchar(255);

UPDATE Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE Nashville
ADD OwnerSplitState Nvarchar(255);

UPDATE Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

SELECT * from Nashville

-- Change Y and N to Yes and No in "Sold as Vacand" Field

SELECT DISTINCT(SoldasVacant), Count(SoldasVacant)
FROM Nashville
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldasVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Nashville

UPDATE Nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


-- REMOVE DUPLICATES

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

From Nashville
)
--DELETE
--From RowNumCTE
--Where row_num > 1

SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


------ Delete Unused Columns



