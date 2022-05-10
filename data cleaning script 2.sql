--data cleaning on the nashville hosuing dataset

select *
from data_cleaningdb..nashville;



--1. change the format of SaleDate
select SaleDate, CONVERT(Date,SaleDate) as convertedSaleDate
from data_cleaningdb..nashville;

alter table nashville
add saleDateConverted Date;

update nashville
set saleDateConverted=Convert(Date,SaleDate)

--------------------------------------------------------------------------------

--2 populate property address

update a
set PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
from data_cleaningdb..nashville a
join data_cleaningdb..nashville b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

------------------------------------------------------------------------------------

--3 breaking the property address into address, city, state

alter table nashville
add propertyhomeaddress nvarchar(255)

alter table nashville
add propertyaddresscity nvarchar(255)

update nashville
set propertyhomeaddress= substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)

update nashville
set propertyaddresscity=substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))

select propertyhomeaddress, propertyaddresscity
from data_cleaningdb..nashville

--breaking owner address into address,city,state
select OwnerAddress
from data_cleaningdb..nashville

alter table nashville
add ownerhomeaddress nvarchar(255)

alter table nashville
add owneraddresscity nvarchar(255)

--alter table nashville
--drop column owneraddressstate

alter table nashville
add owneraddressstate nvarchar(255)

update nashville
set ownerhomeaddress= parsename(replace(OwnerAddress,',','.'),3)

update nashville
set owneraddresscity=parsename(replace(OwnerAddress,',','.'),2)

update nashville
set owneraddressstate= parsename(replace(OwnerAddress,',','.'),1)

select ownerhomeaddress, owneraddresscity,owneraddressstate
from data_cleaningdb..nashville

--------------------------------------------------------------------------------------------

--4 y to yes and n to no in SoldAsVacant

select distinct(SoldAsVacant), count(SoldAsVacant)
from data_cleaningdb..nashville
group by SoldAsVacant

update nashville
set SoldAsVacant =case when SoldAsVacant='Y' then 'Yes'
     when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end

-----------------------------------------------------------------------------------------------

--5 removing duplicates
--using cte

with rowNumCTE as (
select *,ROW_NUMBER() over (
partition by ParcelID,
PropertyAddress,
SaleDate,
SalePrice,
LegalReference
order by UniqueID
) rownum
from data_cleaningdb..nashville
)

delete
from rowNumCTE
where rownum>1



-------------------------------------------------------------------------------------------------
--6 delete unused data

alter table data_cleaningdb..nashville
drop column TaxDistrict,OwnerAddress,PropertyAddress

alter table data_cleaningdb..nashville
drop column SaleDate





-------------------------------------   END   -------------------------------------------------------
