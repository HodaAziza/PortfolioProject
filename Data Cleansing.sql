Cleaning Data in SQL 

select *
From PortfolioProject.dbo.NashvilleHousing

--Standardise Date Format

Select SaleDateConverted, CONVERT (date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT (Date,SaleDate)

--If it doesn't update properly

Alter Table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT (Date,SaleDate)

--Populate Property Address Data

select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress )
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress )
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address,City, State)

select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING( PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1) as Address
, SUBSTRING (PropertyAddress,CHARINDEX (',', PropertyAddress) + 1, LEN (PropertyAddress)) as City

From PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
add PropertySplitAddress Nvarchar (255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1) 

Alter Table NashvilleHousing
add PropertySplitCity Nvarchar (255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING (PropertyAddress,CHARINDEX (',', PropertyAddress) +1, LEN (PropertyAddress)) 



Select *
From PortfolioProject.dbo.NashvilleHousing




Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME ( Replace (OwnerAddress,',', '.') ,3)
,PARSENAME ( Replace (OwnerAddress,',', '.') ,2)
,PARSENAME ( Replace (OwnerAddress,',', '.') ,1)
From PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
add OwnerSplitAddress Nvarchar (255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME ( Replace (OwnerAddress,',', '.') ,3)

Alter Table NashvilleHousing
add OwnerSplitCity Nvarchar (255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME ( Replace (OwnerAddress,',', '.') ,2)

Alter Table NashvilleHousing
add OwnerSplitState Nvarchar (255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME ( Replace (OwnerAddress,',', '.') ,1)


--Change Y and N to Yes and No in "sold as Vacant" field

Select Distinct(SoldAsVacant) , Count (soldAsvacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		END
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		END


--Remove Duplicates 

With RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	Partition BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				legalReference
				ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing


--Order by ParcelID

)
select * 
From RowNumCTE
where row_num > 1
order by PropertyAddress


Select *
From PortfolioProject.dbo.NashvilleHousing



--Delete Unused Columns

select *
From PortfolioProject.dbo.NashvilleHousing


Alter Table PortfolioProject.dbo.NashvilleHousing
DROP Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

