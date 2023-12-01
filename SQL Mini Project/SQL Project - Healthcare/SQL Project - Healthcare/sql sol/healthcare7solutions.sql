/*Problem Statement 1: 
Insurance companies want to know if a disease is claimed higher or lower than average. Write a stored procedure that returns
 “claimed higher than average” or “claimed lower than average” when the diseaseID is passed toit. 
Hint: Find average number of insurance claims for all the diseases.  If the number of claims for the passed disease is higher
 than the average return “claimed higher than average” otherwise “claimed lower than average”.*/
delimiter //
create procedure claimed_disease(in disID int)
begin 
with disease_claim as (select diseaseID,count(claimID) as cou from disease d join treatment t using(diseaseID)
 join claim c using(claimID) group by diseaseID ),
 avg_claim as (select avg(cou) as av from disease_claim)
select case 
when cou >(select av from avg_claim) then 'claimed higher than average'
when cou < (select av from avg_claim) then 'claimed lower than average'
else 'claimed as average' end as result
from (select cou from disease_claim where diseaseID=disID) a;
END //
delimiter ;
call claimed_disease(4);

/*Problem Statement 2:  
Joseph from Healthcare department has requested for an application which helps him get genderwise report for any disease. 
Write a stored procedure when passed a disease_id returns 4 columns,
disease_name, number_of_male_treated, number_of_female_treated, more_treated_gender
Where, more_treated_gender is either ‘male’ or ‘female’ based on which gender underwent more often for the disease,
if the number is same for both the genders, the value should be ‘same’.
*/
delimiter //
create procedure gender_wise(in disID int)
begin
select * ,case when number_of_male_treated>number_of_female_treated then 'male'
when number_of_male_treated<number_of_female_treated then 'female'
else 'same' end as more_treated_gender from(
select diseaseName,sum(case when gender='male' then 1 else 0 end) as number_of_male_treated,
 sum(case when gender='female' then 1 else 0 end) as number_of_female_treated
 from disease d join treatment t using(diseaseID)
 join patient pt using(patientID)
 join person p on pt.patientID=p.personID
 group by diseaseName having diseaseName=(select diseaseName from disease where diseaseID=disID)) a;
 end //
 delimiter ;
 call gender_wise(4);
 drop procedure gender_wise;
 
 /*Problem Statement 3:  
The insurance companies want a report on the claims of different insurance plans. 
Write a query that finds the top 3 most and top 3 least claimed insurance plans.
The query is expected to return the insurance plan name, the insurance company name which has that plan, 
and whether the plan is the most claimed or least claimed. */

with claimed_rank as (select planName,companyID,row_number() over(order by count(claimID) desc) as total_claimed_rank 
from claim c join insuranceplan using(uin) group by planName,companyID),
max_claimed as (select total_claimed_rank as maxi from claimed_rank order by maxi asc limit 3),
min_claimed as (select total_claimed_rank as mini from claimed_rank order by mini desc limit 3)

select * from(
select planName ,companyName,case when total_claimed_rank in (select maxi from max_claimed) then 'most_claimed'
when total_claimed_rank in (select mini from min_claimed) then 'least_claimed'
end as category from claimed_rank join insurancecompany ic using(companyID)
) a where category is not null;

/*Problem Statement 4: 
The healthcare department wants to know which category of patients is being affected the most by each disease.
Assist the department in creating a report regarding this.
Provided the healthcare department has categorized the patients into the following category.
YoungMale: Born on or after 1st Jan  2005  and gender male.
YoungFemale: Born on or after 1st Jan  2005  and gender female.
AdultMale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender male.
AdultFemale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender female.
MidAgeMale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender male.
MidAgeFemale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender female.
ElderMale: Born before 1st Jan 1970, and gender male.
ElderFemale: Born before 1st Jan 1970, and gender female*/

select diseaseName,age_category from(
select diseaseName,age_category,count(age_category) as cou,row_number() over(partition by diseaseName order by count(age_category) desc) as ranked 
from (
select patientID,diseaseName,case 
when dob>='2005-01-01' and gender='male' then 'YoungMale'
when dob>='2005-01-01' and gender='female' then 'YoungFemale'
when dob>='1985-01-01' and dob <'2005-01-01' and gender='male' then 'AdultMale'
when dob>='1985-01-01' and dob <'2005-01-01' and gender='female' then 'AdultFemale'
when dob between '1970-01-01' and '1984-12-31' and gender='male' then 'MidAgeMale'
when dob between '1970-01-01' and '1984-12-31' and gender='female' then 'MidAgeFemale'
when dob<'1970-01-01' and gender='male' then 'ElderMale'
when dob<'1970-01-01' and gender='female' then 'ElderFemale'
end as age_category
from disease d join treatment t using(diseaseID)
join patient pt using(patientID) 
join person p on p.personID=pt.patientID) a group by diseaseName,age_category order by diseaseName,age_category desc) bb
 where ranked=1;
 
 /*Problem Statement 5:  
Anna wants a report on the pricing of the medicine. She wants a list of the most expensive and most affordable medicines only. 
Assist anna by creating a report of all the medicines which are pricey and affordable, listing the companyName, productName, 
description, maxPrice, and the price category of each. Sort the list in descending order of the maxPrice.
Note: A medicine is considered to be “pricey” if the max price exceeds 1000 and “affordable” if the price is under 5. 
Write a query to find */
select companyName,productName,description,maxPrice,case when maxPrice>1000 then 'most_expensive' when maxPrice<5 then 'affordable' end as price_category
from medicine where maxPrice>1000 or maxPrice<5 order by maxPrice;

