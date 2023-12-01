/*Problem Statement 1: 
Johansson is trying to prepare a report on patients who have gone through treatments more than once.
 Help Johansson prepare a report that shows the patient's name, the number of treatments they have undergone, and their age, 
 Sort the data in a way that the patients who have undergone more treatments appear on top.*/

with cte2 as (select patientID,count(treatmentID) as count_of_treatments from treatment group by patientID)
select personName,year(now())-year(dob) as age ,count_of_treatments from cte2 join patient pt using(patientID)
join person p on pt.patientID=p.personID;

/*Problem Statement 2:  
Bharat is researching the impact of gender on different diseases, He wants to analyze if a certain disease is
more likely to infect a certain gender or not.Help Bharat analyze this by creating a report showing for every disease 
how many males and females underwent treatment for each in the year 2021. It would also be helpful for Bharat if the male-to-female
ratio is also shown.*/

delimiter //
create procedure gender_count(in gen varchar(10))
begin
select diseaseName,count(gender) as male_count
from disease d join treatment t using(diseaseID)
join patient pt using(patientID)
join person p on pt.patientID=p.personID where year(date)='2021' and gender=gen group by diseaseName ;
end //
delimiter ;
call gender_count('male');
-- method 2
select diseaseName,male_count,female_count,(male_count/female_count) as ratio from(select diseaseName,sum(case when gender='male' then 1 else 0 end) as male_count,sum(case when gender='female' then 1 else 0 end) as female_count
from disease d join treatment t using(diseaseID)
join patient pt using(patientID)
join person p on pt.patientID=p.personID where year(date)='2021' group by diseaseName) a;

/*Problem Statement 3:  
Kelly, from the Fortis Hospital management, has requested a report that shows for each disease, 
the top 3 cities that had the most number treatment for that disease.Generate a report for Kelly’s requirement.*/
select diseaseName,city from(
select diseaseName,city,row_number() over(partition by diseaseName order by count(treatmentID) desc) as city_ranked from 
disease d join treatment t using(diseaseID) 
join patient pt using(patientID)
join person p on pt.patientID=p.personID
join address a using(addressID) group by diseaseName,city) a where city_ranked in (1,2,3);

/*Problem Statement 4: 
Brooke is trying to figure out if patients with a particular disease are preferring some pharmacies over others or not, 
For this purpose, she has requested a detailed pharmacy report that shows each pharmacy name, and how many prescriptions
 they have prescribed for each disease in 2021 and 2022, She expects the number of prescriptions prescribed in 2021 and 2022 
 be displayed in two separate columns.Write a query for Brooke’s requirement.*/
 select pharmacyName ,diseaseName, count(prescriptionID) as prescription_count ,
 sum(case when year(date)='2021' then 1 else 0 end) as prescription_count_2021,
 sum(case when year(date)='2022' then 1 else 0 end) as prescription_count_2022
 from
 pharmacy ph join prescription pr using(pharmacyID)
 join treatment t using(treatmentID)
 join disease d using(diseaseID) where year(date) in ('2021','2022') group by pharmacyName,diseaseName order by pharmacyName,diseaseName;

/*Problem Statement 5:  
Walde, from Rock tower insurance, has sent a requirement for a report that presents which insurance company is targeting the 
patients of which state the most. Write a query for Walde that fulfills the requirement of Walde.
Note: We can assume that the insurance company is targeting a region more if the patients of that region are claiming more 
insurance of that company.*/
select companyName,state from (select companyName,state,rank() over(partition by companyName,state order by count(claimID) desc) as ranked_city
from address a join insurancecompany ic using(addressID)
join insuranceplan ip using(companyID)
join claim using(uin) group by companyName,state) a where ranked_city=1;

select * from insurancecompany;
