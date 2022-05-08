Select * from Houses

--------------------------------------------------------------------------------------------------------------------------------------
-- Date

Alter Table Houses add SaleDate_Updated Date
update Houses set SaleDate_Updated = CONVERT(Date,SaleDate)
Select SaleDate_Updated from Houses
alter table Houses drop column SaleDate 

--------------------------------------------------------------------------------------------------------------------------------------
-- Address

Select * from Houses
--where [PropertyAddress] is null
order by [ParcelID]

-- if first and sec include null
Select a.ParcelID as firstID, a.PropertyAddress as firstADD, b.ParcelID as secID, b.PropertyAddress as secADD 
from Houses a join Houses b 
on a.ParcelID=b.ParcelID where a.[UniqueID ] <> b.[UniqueID ] --and (a.PropertyAddress is null or b.PropertyAddress is null)

-- fix first
Select a.ParcelID as firstID, a.PropertyAddress as firstADD, b.ParcelID as secID, b.PropertyAddress as secADD, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Houses a join Houses b 
on a.ParcelID=b.ParcelID where a.[UniqueID ] <> b.[UniqueID ] and a.PropertyAddress is null

update a 
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Houses a join Houses b 
on a.ParcelID=b.ParcelID where a.[UniqueID ] <> b.[UniqueID ] and a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------------------
-- Address

-- [PropertyAddress]
select 
SUBSTRING([PropertyAddress],1,CHARINDEX(',',[PropertyAddress])-1) As Address, 
SUBSTRING([PropertyAddress], CHARINDEX(',',[PropertyAddress])+1,len([PropertyAddress])) As City
from Houses


Alter Table Houses add Property_Address nvarchar(255)
Alter Table Houses add Property_City nvarchar(255)
update Houses set Property_Address = SUBSTRING([PropertyAddress],1,CHARINDEX(',',[PropertyAddress])-1)
update Houses set Property_City = SUBSTRING([PropertyAddress], CHARINDEX(',',[PropertyAddress])+1,len([PropertyAddress]))

select Property_Address, Property_City from Houses
alter table Houses drop column [PropertyAddress]

-- [OwnerAddress]
select [OwnerAddress] from Houses

select
PARSENAME(replace([OwnerAddress],',','.'),3),
PARSENAME(replace([OwnerAddress],',','.'),2),
PARSENAME(replace([OwnerAddress],',','.'),1)
from Houses

Alter Table Houses add Owner_Address nvarchar(255)
Alter Table Houses add Owner_City nvarchar(255)
Alter Table Houses add Owner_State nvarchar(255)

update Houses set Owner_Address = PARSENAME(replace([OwnerAddress],',','.'),3)
update Houses set Owner_City = PARSENAME(replace([OwnerAddress],',','.'),2)
update Houses set Owner_State = PARSENAME(replace([OwnerAddress],',','.'),1)

select Owner_Address, Owner_City, Owner_State from Houses
alter table Houses drop column OwnerAddress

--------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No 

select [SoldAsVacant] from Houses where [SoldAsVacant] = 'Y' or [SoldAsVacant] = 'N' --451 row

select distinct([SoldAsVacant]), COUNT([SoldAsVacant])
from Houses group by [SoldAsVacant]

update Houses 
set [SoldAsVacant] = case when [SoldAsVacant] = 'Y' then 'Yes'
                          when [SoldAsVacant] = 'N' then 'No' 
						  else [SoldAsVacant] end

--------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

with Duplicate As(
select *, ROW_NUMBER() over( partition by [ParcelID], [Property_Address], [SalePrice], [SaleDate_Updated], [LegalReference]
                          order by [UniqueID ]) row_Num
from Houses)
delete from Duplicate where row_Num>1