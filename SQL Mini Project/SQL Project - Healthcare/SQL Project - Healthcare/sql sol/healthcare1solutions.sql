/*Problem Statement 1: 
 Jimmy, from the healthcare department, has requested a report that shows how the number of treatments each 
age category of patients has gone through in the year 2022. 
The age category is as follows, Children (00-14 years), Youth (15-24 years), Adults (25-64 years), and Seniors (65 years and over).
Assist Jimmy in generating the report. */
use miniproject;
select case
when (year(curdate())-year(pt.dob))<=14 then 'children'
when (year(curdate())-year(pt.dob)) between 15 and 24 then 'youth'
when (year(curdate())-year(pt.dob)) between 25 and 64 then 'Adults'
else 'senior'
end as age_category,count(patientID) as count
from 
patient pt join treatment t using(patientID) where year(t.date)=2022 group by age_category;

/*Problem statement 2
Jimmy, from the healthcare department, wants to know which disease is infecting people of which gender more often.
Assist Jimmy with this purpose by generating a report that shows for each disease the male-to-female ratio. Sort the data in a way that is helpful for Jimmy.
*/

select d.diseasename,(sum(case when gender='male' then 1 else 0 end)/sum(case when gender='female' then 1 else 0 end)) as male_to_female 
from treatment t join patient pt on t.patientID=pt.patientID
join person p on p.personID=pt.patientID
join disease d on d.diseaseID=t.diseaseID group by d.diseasename order by male_to_female desc;

/*Problem Statement 4:   The Healthcare department wants a report about the inventory of pharmacies. 
Generate a report on their behalf that shows how many units of medicine each pharmacy has in their inventory,
 the total maximum retail price of those medicines, and the total price of all the medicines after discount. 
Note: discount field in keep signifies the percentage of discount on the maximum price.*/

select pharmacyID,sum(quantity) as units,sum(maxPrice) as mPrice,sum(maxPrice*(100-discount)) as after_discount from medicine m join keep k on m.medicineID=k.medicineID group by pharmacyID;

/*Problem Statement 5:  
The healthcare department suspects that some pharmacies prescribe more medicines than others in a single prescription, for them,
 generate a report that finds for each pharmacy the maximum, minimum and average number of medicines prescribed in their 
 prescriptions. */
 
select pr.pharmacyId,max(c.quantity) as max,min(c.quantity) as min,avg(c.quantity) as avg from pharmacy ph join prescription pr on pr.pharmacyID=ph.pharmacyID
join contain c on c.prescriptionID=pr.prescriptionID
join medicine m on m.medicineID=c.medicineID group by pr.pharmacyID;













/*Write a stored procedure that takes an INT as input and returns the factorial of the number, 
if the number is prime. Else, it returns a comma-separated string of the divisors of the number*/

delimiter //
create procedure procedure1(in fact int)
begin
	declare i int default 2;
    declare result int default 1;
    declare result1 varchar(50) default '1, ';
	if isprime(fact)=1 then
		while fact>0 do
			set result=result*fact;
			set fact=fact-1;
		end while;
		set fact=result;
    else
    while i<=fact do
		if fact%i=0 then 
			set result1=concat(result1,i,', ');
        end if;
        set i=i+1;
	end while;
    end if;
    if (fact=0)
    then
		select fact;
    else
		select result1;
    end if;
end //
SET @input_num = 4;
CAll procedure1(@input_num);
-- SELECT @input_num,@result2;

drop procedure procedure1;

delimiter //
create function isprime(num int)
returns bool
deterministic
begin
	declare i int default 2;
    declare result bool default True;
    if num<=1 then 
		set result=False;
	else
		while i<=sqrt(num) do
			if num%i=0 then
				set result=False;
			end if;
            set i=i+1;
		end while;
	end if;
    return result;
end
//

DELIMITER ;


/*Write a stored procedure that takes an INT as input and returns "YES" if the number is pallindrome or "NO" 
if the number is not pallindrome*/
delimiter //
create procedure pal(num int)
begin 
	if num=reverse(cast(num as char)) then
		select 'Yes';
    else
		select 'No';
	end if;
end //
call pal(123);

/*Write a stored function called computeTax 
that calculates income tax based on the salary for every worker in the Worker table as follows:
10% - salary <= 75000
20% - 75000 < salary <= 150000
30% - salary > 150000
Write a query that displays all the details of a worker including their computedTax.*/

delimiter //
create function tax(sal int)
returns int
deterministic
begin 
	declare s int;
	if sal<=75000 then set s=sal*0.1;
	elseif sal>75000 and sal<=150000 then set s=sal*0.2;
	else set s=sal*0.3;
	end if;
return s;
end //
delimiter ;
/*Define a stored procedure that takes a salary as input and returns the calculated income tax amount for the input salary.
 Print the computed tax for an input salary from a calling program. 
(Hint - Use the computeTax stored function inside the stored procedure)
*/

delimiter //
create procedure income_tax()
begin 
	select tax(salary) as computedTax, salary from worker;
end //
    
-- Create a stored procedure
-- named getEmployees() to display the following employee and their office info: name, city, state, and country.
delimiter //
create procedure getEmployees()
begin 
	select e.name,o.city,o.state,o.country from employee e join office o on o.officecode=e.officecode;
end //


 -- Create a stored procedure named getPayments() that 
 --  prints the following customer and payment info:customerName, checkNumber, paymentDate, and amount.
delimiter //
 create procedure getpayments()
    begin
		select customername,checknumber,paymentdate,amount from customers inner join payments using (customernumber);
	end //
    







