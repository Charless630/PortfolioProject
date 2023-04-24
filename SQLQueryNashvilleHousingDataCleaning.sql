select *
from PortfolioProject.dbo.NashvilleHousing

------------------------------------------------

--Standardize Date Format

Select SaleDateConverted--, CONVERT(date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date, SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(Date, SaleDate)

-------------------------------------------------

--Populate Property Address

Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.parcelID = b.parcelID
	and a.uniqueID <> b.uniqueID
where a.propertyaddress is null

update a
set propertyaddress = ISNULL(a.propertyaddress, b.propertyaddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.parcelID = b.parcelID
	and a.uniqueID <> b.uniqueID
where a.propertyaddress is null

-----------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(propertyaddress, 1, charindex(',', PropertyAddress)-1) as Address
, SUBSTRING(propertyaddress, charindex(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(propertyaddress, 1, charindex(',', PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(propertyaddress, charindex(',', PropertyAddress)+1, LEN(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing





select owneraddress
from PortfolioProject.dbo.NashvilleHousing


select
PARSENAME(replace(Owneraddress, ',', '.'), 3)
, PARSENAME(replace(Owneraddress, ',', '.'), 2)
, PARSENAME(replace(Owneraddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(Owneraddress, ',', '.'), 3)


alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(Owneraddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(Owneraddress, ',', '.'), 1)

------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, case when SoldAsVacant ='Y' then 'Yes'
	   when SoldAsVacant ='N' then 'No'
	   else SoldAsVacant
	   end
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant ='Y' then 'Yes'
	   when SoldAsVacant ='N' then 'No'
	   else SoldAsVacant
	   end

---------------------------------------------------------------
--Remove Duplicates


with RowNumCTE as (
select *,
ROW_NUMBER() over (
partition by parcelID, propertyaddress, saleprice,saledate,legalreference order by uniqueID
) row_num


from PortfolioProject.dbo.NashvilleHousing
--order by parcelID
)
select *
From RowNumCTE
where row_num>1
order by PropertyAddress

-----------------------------------------------------------------------------
--Delete Unused Columns

select *
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress

alter table PortfolioProject.dbo.NashvilleHousing
drop column saledate