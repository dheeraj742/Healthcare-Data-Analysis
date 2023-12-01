/*
Problem Statement 1:
The healthcare department has requested a system to analyze the performance of insurance companies and their plan.
For this purpose, create a stored procedure that returns the performance of different insurance plans of an insurance company.
 When passed the insurance company ID the procedure should generate and return all the insurance plan names the provided company 
 issues, the number of treatments the plan was claimed for, and the name of the disease the plan was claimed for the most. 
 The plans which are claimed more are expected to appear above the plans that are claimed less.*/
delimiter //
create procedure plans_disease_count(in cID int)
begin
with cte1 as 
(select planName,diseaseName,count(treatmentID) as count_of_claims from insurancecompany ic join insuranceplan ip using(companyID)
join claim c using(uin)
join treatment t using(claimID) 
join disease d using(diseaseID) where companyID=cID
group by planName,diseaseName) ,
cte2 as 
(select planName,diseaseName,count_of_claims,row_number() over(partition by planName order by count_of_claims desc) as most_claimed 
from cte1 group by planName,diseaseName)

select planName,diseaseName,count_of_claims from cte2 where most_claimed=1 order by count_of_claims desc; 
 end //
 delimiter ;
 call plans_disease_count(8799);
 drop procedure plans_disease_count;
 /*Problem Statement 2:
It was reported by some unverified sources that some pharmacies are more popular for certain diseases.
 The healthcare department wants to check the validity of this report.Create a stored procedure that takes a disease name as a 
 parameter and would return the top 3 pharmacies the patients are preferring for the treatment of that disease in 2021
 as well as for 2022.Check if there are common pharmacies in the top 3 list for a disease, in the years 2021 and the year 2022.
Call the stored procedure by passing the values “Asthma” and “Psoriasis” as disease names and draw a conclusion from the result.*/

delimiter //
create procedure top3_pharmacy(in dName varchar(50))
begin
with cte1 as(select diseaseName,pharmacyName,row_number() over(partition by diseaseName order by count(diseaseID)  desc) as ranked from disease d join treatment t using(diseaseID)
join prescription pr using(treatmentID)
join pharmacy ph using(pharmacyID) where year(date) = '2021' and diseaseName=dName group by diseaseName,pharmacyName),
cte2 as (select diseaseName,pharmacyName,row_number() over(partition by diseaseName order by count(diseaseID)  desc) as ranked from disease d join treatment t using(diseaseID)
join prescription pr using(treatmentID)
join pharmacy ph using(pharmacyID) where year(date) = '2022' and diseaseName=dName group by diseaseName,pharmacyName)
-- select pharmacyName from cte1 where ranked<4 order by ranked;
(select pharmacyName,ranked from cte1 where ranked<4 order by ranked)
union all
(select pharmacyName,ranked from cte2 where ranked<4 order by ranked);
end //
delimiter ;
call top3_pharmacy('Asthma');
drop procedure top3_pharmacy;
# for Asthama disease year 2021 we got Southside Family Pharmacy,Express Scripts,North East Pharmacy
# for Asthama disease year 2022 we got Discount Drugs,Health Harvest,Everyday Drugs
# for Psoriasis disease year 2021 we got Tru Script,PrecisionMed,Bartell Drugs
# for Psoriasis disease year 2022 we got Sunwest,Prescription Hope,HealthMart

/*Problem Statement 3:
Jacob, as a business strategist, wants to figure out if a state is appropriate for setting up an insurance company or not.
Write a stored procedure that finds the num_patients, num_insurance_companies, and insurance_patient_ratio, the stored procedure 
should also find the avg_insurance_patient_ratio and if the insurance_patient_ratio of the given state is less than the 
avg_insurance_patient_ratio then it Recommendation section can have the value “Recommended” otherwise the value
can be “Not Recommended”.
Description of the terms used:
num_patients: number of registered patients in the given state
num_insurance_companies:  The number of registered insurance companies in the given state
insurance_patient_ratio: The ratio of registered patients and the number of insurance companies in the given state
avg_insurance_patient_ratio: The average of the ratio of registered patients and the number of insurance for all the states.*/

with c as (select * from 
person p join patient pt on p.personID=pt.patientID
right join address a using(addressID)
left join insurancecompany using(addressID))
select state,count(personID) as num_patients,count(companyID) as num_insurance_companies,count(personID)/count(companyID) as insurance_patient_ratio from c group by state;

with c as(select state,count(patientID) as num_patients,count(companyID) as num_insurance_companies,count(patientID)/count(companyID) as insurance_patient_ratio 
from person p join patient pt on p.personID=pt.patientID
right join address a using(addressID) 
left join insurancecompany ic using(addressID)
group by state order by state),
cc as (select avg(insurance_patient_ratio) as avg_insurance_patient_ratio from c)

select *,case 
when insurance_patient_ratio<(select avg_insurance_patient_ratio from cc) then 'recommended'
when insurance_patient_ratio is null then 'zerocompanies'
else 'not recommended' end as reccomend_section
from c;

/*Problem Statement 4:
Currently, the data from every state is not in the database, The management has decided to add the data from other states and cities as well. It is felt by the management that it would be helpful if the date and time were to be stored whenever new city or state data is inserted.
The management has sent a requirement to create a PlacesAdded table if it doesn’t already exist, that has four attributes. placeID, placeName, placeType, and timeAdded.
Description
placeID: This is the primary key, it should be auto-incremented starting from 1
placeName: This is the name of the place which is added for the first time
placeType: This is the type of place that is added for the first time. The value can either be ‘city’ or ‘state’
timeAdded: This is the date and time when the new place is added

You have been given the responsibility to create a system that satisfies the requirements of the management. 
Whenever some data is inserted in the Address table that has a new city or state name, the PlacesAdded table should be updated with
 relevant data*/
 create table if not exists PlacesAdded(
 placeID int auto_increment primary key ,
 placeName varchar(50) unique,
 placeType ENUM('city', 'state') NOT NULL,
 timeAdded datetime not null);

delimiter //
 create trigger for_PlacesAdded
 after insert on address for each row
 begin
	insert into PlacesAdded(placeName,placeType,timeAdded) values(new.city,'city',now());
    insert into PlacesAdded(placeName,placeType,timeAdded) values(new.state,'state',now());
 end;
 //

delete from address where addressID=724329;
INSERT IGNORE INTO Address VALUES (724329,'21323 North 64th Avenue','Glendale','AZ',85308);
select * from placesAdded;
drop trigger for_PlacesAdded;
drop table placesAdded;

/*Problem Statement 5:
Some pharmacies suspect there is some discrepancy in their inventory management. The quantity in the ‘Keep’ is updated regularly 
and there is no record of it. They have requested to create a system that keeps track of all the transactions whenever the quantity 
inventory is updated.You have been given the responsibility to create a system that automatically updates a Keep_Log table which
has  the following fields:
id: It is a unique field that starts with 1 and increments by 1 for each new entry
medicineID: It is the medicineID of the medicine for which the quantity is updated.
quantity: The quantity of medicine which is to be added. If the quantity is reduced then the number can be negative.
For example:  If in Keep the old quantity was 700 and the new quantity to be updated is 1000, then in Keep_Log the quantity should 
be 300.
Example 2: If in Keep the old quantity was 700 and the new quantity to be updated is 100, then in Keep_Log the quantity should 
be -600.
*/
drop table keep_log;
create table if not exists Keep_Log(
id int auto_increment primary key,
medicineID int not null,
quantity int not null);
drop trigger update_log;
delimiter //
create trigger update_log
after update on keep for each row
begin
if old.quantity <> new.quantity then
	insert into Keep_Log(medicineID,quantity) values(new.medicineID,new.quantity-old.quantity);
end if;
end //
delimiter ;

update keep set keep.quantity= 5949 where (pharmacyID=1008 and medicineID=1111);
select * from Keep_Log;