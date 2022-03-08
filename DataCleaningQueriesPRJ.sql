/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject.dbo.NashvilleHousing

-------------------------------------------

--Standardize Date Format

Select SaleDate, Convert(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

--The Convert(Date,SaleDate) will show another column of the goal we are trying to achieve from the first column.

Update NashvilleHousing
Set SaleDate = Convert(Date,SaleDate)

--Try the top two first, but if they dont work to convert the date then create another column called SaleDateConverted

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)

--This will show the date that we are looking for

Select SaleDateConverted, Convert(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------

--Populate Properly Address Data

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is NULL
Order by ParcelID

Select a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

---------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is NULL
--Order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity  Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing



Select OwnerAddress
From PortfolioProject..NashvilleHousing

--Easier version than using substrings

Select
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.') , 2)
,PARSENAME(REPLACE(OwnerAddress,',','.') , 1)
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.') , 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.') , 1)

---------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field. Using a CASE statement

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE  When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE  When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		ELSE SoldAsVacant
		END

--------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE As(
Select *,
	ROW_NUMBER() Over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num


From PortfolioProject..NashvilleHousing
--Order by ParcelID
)
DELETE
--Select*
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

---------------------------------------------------------------------------

--Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDate