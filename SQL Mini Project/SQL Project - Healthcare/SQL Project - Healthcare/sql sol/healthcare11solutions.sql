/*Problem Statement 1:
Patients are complaining that it is often difficult to find some medicines. They move from pharmacy to pharmacy to get the 
required medicine. A system is required that finds the pharmacies and their contact number that have the required medicine in their 
inventory. So that the patients can contact the pharmacy and order the required medicine.
Create a stored procedure that can fix the issue.*/
delimiter //
create procedure order_medicine(in mID int)
begin
select distinct pharmacyName,phone from pharmacy ph left join keep k using(pharmacyID) where medicineID=mID;
end //
delimiter ;
call order_medicine(1266);
drop procedure order_medicine;

/*
Problem Statement 2:
The pharmacies are trying to estimate the average cost of all the prescribed medicines per prescription, 
for all the prescriptions they have prescribed in a particular year. Create a stored function that will return the required 
value when the pharmacyID and year are passed to it. Test the function with multiple values.*/

delimiter //
create function avg_cost(yID varchar(4) ,pID int)
returns int
deterministic
begin
declare result int;
with cte5 as (
select avg(quantity*maxPrice) as  avg_cost_all_medicines from treatment t join prescription pr using(treatmentID)
join contain c using(prescriptionID)
join medicine m using(medicineID) where year(date)=yID and pharmacyID=pID group by prescriptionID)
select round(avg(avg_cost_all_medicines)) into result from cte5;
return result;
end //
delimiter ;
select avg_cost('2021',1008);

/*Problem Statement 3:
The healthcare department has requested an application that finds out the disease that was spread the most in a state for a given
 year. So that they can use the information to compare the historical data and gain some insight.Create a stored function that 
 returns the name of the disease for which the patients from a particular state had the most number of treatments for a particular
 year. Provided the name of the state and year is passed to the stored function.*/
 
delimiter //
create function disease_state(y varchar(4),st varchar(2))
returns varchar(50)
deterministic
begin 
declare result varchar(50);
with cte6 as (select state,diseaseName,count(diseaseID),row_number() over(partition by state order by count(diseaseID) desc) as ranked from disease d join treatment t using(diseaseID)
join patient pt using(patientID)
join person p on pt.patientID=p.personID
join address a using(addressID) where year(date)='2021' group by state,diseaseName having state='AK')
select diseaseName into result from cte6 where ranked=1;
return result;
end //
select disease_state(2021,'AK');

/*Problem Statement 4:
The representative of the pharma union, Aubrey, has requested a system that she can use to find how many people in a specific 
city have been treated for a specific disease in a specific year.Create a stored function for this purpose.*/
delimiter //
create function count_patients(c varchar(50),dName varchar(50),y varchar(4))
returns int
deterministic
begin
declare result int;
select count(patientID) into result
from disease d join treatment t using(diseaseID)
join patient pt using(patientID)
join person p on pt.patientID=p.personID
join address a using(addressID) where city='Washington' and year(date)='2021' and diseaseName='Atherosclerosis';
return result;
end //
delimiter ;
select count_patients('Washington','Atherosclerosis','2021');
drop function count_patients;

/*Problem Statement 5:
The representative of the pharma union, Aubrey, is trying to audit different aspects of the pharmacies. 
She has requested a system that can be used to find the average balance for claims submitted by a specific insurance company 
in the year 2022. Create a stored function that can be used in the requested application. */

delimiter //
create function avg_balance(cID int,y varchar(4))
returns float
deterministic
begin 
declare result float;
select avg(balance) into result from treatment t join claim c using(claimID)
join insuranceplan ip using(uin)
join insurancecompany ic using(companyID) where companyID=cID and year(date)=y;
return result;
end //
delimiter ;
select avg_balance(1583,'2021');


