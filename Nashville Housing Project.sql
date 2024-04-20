-- CLEANING DATA IN SQL QUERIES
select *
from nashville_housing_data ;

-- Standarize Date Format
SELECT saledate, STR_TO_DATE(saledate, '%d-%b-%y') 
AS converted_date
FROM nashville_housing_data;

update nashville_housing_data 
set saledate = STR_TO_DATE(saledate, '%d-%b-%y');

-- Populate Property Address Data
select propertyaddress
from nashville_housing_data 
-- where propertyaddress is Null;
order by parcelid ;

SELECT apple.parcelid, apple.propertyAddress, b.parcelid, b.propertyaddress,
ifnull(apple.propertyaddress, b.propertyaddress)
FROM nashville_housing_data as apple
JOIN nashville_housing_data as b
    ON apple.parcelid = b.parcelid 
    AND apple.uniqueid <> b.uniqueid
where apple.propertyaddress is null;

update apple
set propertyAddress = ifnull(apple.propertyaddress, b.propertyaddress)
FROM nashville_housing_data as apple
JOIN nashville_housing_data as b
    ON apple.parcelid = b.parcelid 
    AND apple.uniqueid <> b.uniqueid
where apple.propertyaddress is null;


-- Breaking out Address into Individual Columns (Address, City, States)

select propertyaddress 
from nashville_housing_data;

select 
substring(propertyaddress,1,locate(',', propertyaddress)-1)
as address,
substring(propertyaddress,locate(',', propertyaddress)+1, length(propertyaddress)) 
as City
from nashville_housing_data;

alter table nashville_housing_data 
add PropertySplitAddress Varchar(255);

update nashville_housing_data 
set PropertySplitAddress = substring(propertyaddress,1,locate(',', propertyaddress)-1)


alter table nashville_housing_data 
add PropertySplitCity Varchar(255);

update nashville_housing_data 
set PropertySplitCity = substring(propertyaddress,locate(',', propertyaddress)+1, length(propertyaddress)) 

select *
from nashville_housing_data ;

select owneraddress 
from nashville_housing_data ;

SELECT
    substring_index(SUBSTRING_INDEX(REPLACE(owneraddress, ',', '.'), '.', 1),'.',-1),
    substring_index(SUBSTRING_INDEX(REPLACE(owneraddress, ',', '.'), '.', 2),'.',-1),
    substring_index(REPLACE(owneraddress, ',', '.'), '.', -1)
FROM nashville_housing_data;




alter table nashville_housing_data 
add OwnerSplitAddress Varchar(255);

update nashville_housing_data 
set OwnerSplitAddress = substring_index(SUBSTRING_INDEX(REPLACE(owneraddress, ',', '.'), '.', 1),'.',-1)
 


alter table nashville_housing_data 
add OwnerSplitCity Varchar(255);

update nashville_housing_data 
set OwnerSplitCity = substring_index(SUBSTRING_INDEX(REPLACE(owneraddress, ',', '.'), '.', 2),'.',-1)


alter table nashville_housing_data 
add OwnerSplitState Varchar(255);

update nashville_housing_data 
set OwnerSplitState =     substring_index(REPLACE(owneraddress, ',', '.'), '.', -1)


select *
from nashville_housing_data ;


-- Change Y and N to Yes and No in 'Sold as Vacant' column

select distinct(soldasvacant),count(soldasvacant) 
from nashville_housing_data 
group by soldasvacant 
order by soldasvacant  ;

select soldasvacant, 
	case when soldasvacant ='Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else soldasvacant
	END
from nashville_housing_data;

update nashville_housing_data 
set soldasvacant =
case when soldasvacant ='Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else soldasvacant
	end
	
/*
-- Remove Duplicate
with RowNumCTE AS(
select *,
	ROW_NUMBER() OVER(
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				legalReference
				order by 
				Uniqueid
				) row_number 
from nashville_housing_data
)
delete
from RowNumCTE
where row_number > 1
-- order by PropertyAddress
*/
	
DELETE FROM nashville_housing_data
WHERE Uniqueid IN (
    SELECT Uniqueid
    FROM (
        SELECT Uniqueid,
            ROW_NUMBER() OVER (
                PARTITION BY ParcelID,
                             PropertyAddress,
                             SalePrice,
                             SaleDate,
                             legalReference
                ORDER BY Uniqueid
            ) AS row_number
        FROM nashville_housing_data
    ) AS RowNumCTE
    WHERE row_number > 1
);

select *
from RowNumCTE
where row_number > 1
order by PropertyAddress;


-- Delete unused Columns

select *
from nashville_housing_data;


	

