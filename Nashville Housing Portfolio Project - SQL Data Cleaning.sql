-- View table
SELECT 
    *
FROM [PorfolioProject].[dbo].[NashvilleHousing1]
ORDER BY UniqueID


-- Populate property address data (some of the cells are empty)
SELECT 
    n1.ParcelID
    ,n1.PropertyAddress
    ,n2.ParcelID
    ,n2.PropertyAddress
    ,ISNULL(n1.PropertyAddress, n2.PropertyAddress)
FROM [PorfolioProject].[dbo].[NashvilleHousing1] n1
JOIN [PorfolioProject].[dbo].[NashvilleHousing1] n2
    ON n1.ParcelID = n2.ParcelID
    AND n1.UniqueID <> n2.UniqueID
WHERE n1.PropertyAddress IS NULL

UPDATE n1
SET PropertyAddress = ISNULL(n1.PropertyAddress, n2.PropertyAddress)
FROM [PorfolioProject].[dbo].[NashvilleHousing1] n1
JOIN [PorfolioProject].[dbo].[NashvilleHousing1] n2
    ON n1.ParcelID = n2.ParcelID
    AND n1.UniqueID <> n2.UniqueID
WHERE n1.PropertyAddress IS NULL

-- Breaking out PropertyAddress column into individual columns (Address, City, State)
SELECT 
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as PropertySplitAddress
    ,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as PropertySplitCity
FROM [PorfolioProject].[dbo].[NashvilleHousing1]

ALTER TABLE [NashvilleHousing1]
ADD PropertySplitAddress nvarchar(255);

UPDATE [NashvilleHousing1]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE [NashvilleHousing1]
ADD PropertySplitCity nvarchar(255);

UPDATE [NashvilleHousing1] 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


-- Breaking out OwnerAddress column into individual columns (Address, City, State)
SELECT
    PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
    ,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
    ,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM [PorfolioProject].[dbo].[NashvilleHousing1]

ALTER TABLE NashvilleHousing1
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing1
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing1
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing1
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing1
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing1
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


-- Change Y and N to Yes ad No in "SoldAsVacant" column
SELECT 
    DISTINCT(SoldAsVacant)
    ,COUNT(SoldAsVacant)
FROM [PorfolioProject].[dbo].[NashvilleHousing1]
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant)

SELECT
SoldAsVacant
,CASE 
    WHEN SoldAsVacant = 'Y' THEN 'YES'
    WHEN SoldAsVacant =  'N' THEN 'NO'
    ELSE SoldAsVacant
    END
FROM [PorfolioProject].[dbo].[NashvilleHousing1]

UPDATE NashvilleHousing1
SET SoldAsVacant = CASE 
    WHEN SoldAsVacant = 'Y' THEN 'YES'
    WHEN SoldAsVacant =  'N' THEN 'NO'
    ELSE SoldAsVacant
    END


-- Remove duplicates
WITH RowNumCTE AS 
    (
    SELECT 
        *
        ,ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
    FROM [PorfolioProject].[dbo].[NashvilleHousing1]
    -- ORDER BY ParcelID
    )

DELETE
FROM RowNumCTE
WHERE row_num > 1


-- Delete unused columns
ALTER TABLE NashvilleHousing1
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict
