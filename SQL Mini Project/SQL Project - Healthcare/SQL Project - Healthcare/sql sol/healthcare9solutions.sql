/*Problem Statement 1: 
Brian, the healthcare department, has requested for a report that shows for each state how many people underwent treatment for the 
disease “Autism”.  He expects the report to show the data for each state as well as each gender and for each state and gender 
combination. 
Prepare a report for Brian for his requirement.*/
with cte9 as (select state,coalesce(gender,'Total') as gender,count(distinct(treatmentID)) as cou from address a left join person p using(addressID)
join patient pt on pt.patientID=p.personID
join treatment using(patientID) 
join disease using(diseaseID)
where diseaseName='Autism' group by state,gender with rollup)

select state,sum(male_cou) as male_count,sum(female_cou) as female_count,sum(total_cou) as total_count from (
select state,case when gender='male' then cou end as male_cou,case when gender='female' then cou end as female_cou,case when gender='Total' then cou
end as total_cou from cte9) a where a.state is not null group by state;

/*Problem Statement 2:  
Insurance companies want to evaluate the performance of different insurance plans they offer. 
Generate a report that shows each insurance plan, the company that issues the plan, and the number of treatments the plan was 
claimed for. The report would be more relevant if the data compares the performance for different years(2020, 2021 and 2022) and 
if the report also includes the total number of claims in the different years, as well as the total number of claims for each plan 
in all 3 years combined.*/

with cte10 as 
(select planName,companyName,year(date) as yea,count(claimID) as cou 
from insuranceplan ip join insurancecompany ic using(companyID)
join claim c using(uin)
join treatment t using(claimID) where year(date) in ('2021','2020','2022') group by planName,companyName,year(date) with rollup),

cte11 as (
select planName,companyName,case when yea='2020' then cou end 
as 'count_in_2020',case when yea='2021' then cou end as 'count_in_2021',case when yea='2022' then cou end as 'count_in_2022',
case when yea is null then cou end as total_cou from cte10)

select planName,companyName,sum(count_in_2020) as count_2020,sum(count_in_2021) as count_2021,sum(count_in_2022) as count_2022 
,sum(total_cou) as total_count_3years from cte11 group by planName,companyName having companyName is not null;

/*Problem Statement 3:  
Sarah, from the healthcare department, is trying to understand if some diseases are spreading in a particular region. 
Assist Sarah by creating a report which shows each state the number of the most and least treated diseases by the patients of 
that state in the year 2022. It would be helpful for Sarah if the aggregation for the different combinations is found as well.
 Assist Sarah to create this report. */
 
 with cte12 as (
 select state,diseaseName,count(treatmentID)as cou,row_number() over(partition by state order by count(treatmentID) desc) as highest_ranked,
 row_number() over(partition by state order by count(treatmentID) asc) as least_ranked
 from address a join person p using(addressID) 
 join patient pt on pt.patientID=p.personID
 join treatment t using(patientID)
 join disease d using(diseaseID)
 where year(date)='2022' group by state,diseaseName with rollup)
 
,


cte13 as (select ifnull(state,'for_all_states') as state,ifnull(diseaseName,'Total') as diseaseName,cou,highest_ranked,least_ranked from cte12
where diseaseName is null or (highest_ranked =2 or least_ranked=1))


select * from 
(select state,null as Most_treated_disease,null as Maximum_count,null as Least_treated_disease,null as Minimum_count,cou as total 
from cte13 where state like '%for_all_states%') aa 
union 
(select * from
(select state,diseaseName as Most_treated_disease,cou as Maximum_count
from cte13 where highest_ranked = 2)t1
join 
(select state,diseaseName as Least_treated_disease,cou as Minimum_count
from cte13 where least_ranked = 1)t2
using(state)
join 
(select state,cou as total
from cte13 where diseaseName = "total")t3
using(state)) ;
 
 /*Problem Statement 4: 
Jackson has requested a detailed pharmacy report that shows each pharmacy name, and how many prescriptions they have prescribed
 for each disease in the year 2022, along with this Jackson also needs to view how many prescriptions were prescribed by each 
 pharmacy, and the total number prescriptions were prescribed for each disease.
Assist Jackson to create this report.*/

with cte as (select pharmacyName,ifnull(diseaseName,'Total') as diseaseName,count(prescriptionID) as count from pharmacy join prescription using(pharmacyID)
join treatment using(treatmentID)
join disease using(diseaseID) where year(date)='2022' group by pharmacyName,diseaseName with rollup order by pharmacyName,diseaseName),
 cte2 as(
 select diseaseName,count(diseaseName) as total_disease_count from pharmacy join prescription using(pharmacyID)
join treatment using(treatmentID)
join disease using(diseaseID) where year(date)='2022' group by 1)
select * from cte left join cte2 using(diseaseName);
-- ifnull(pharmacyName,'Total count for all pharmacy') as 

/*Problem Statement 5:  
Praveen has requested for a report that finds for every disease how many males and females underwent treatment for each in the 
year 2022. It would be helpful for Praveen if the aggregation for the different combinations is found as well.
Assist Praveen to create this report. */

with cte as (select ifnull(diseaseName,'Total'),sum(case when gender='male' then 1 else 0 end) as male_count,
sum(case when gender='female' then 1 else 0 end) as female_count
from person p join patient pt on pt.patientID=p.personID
join treatment using(patientID) 
join disease using(diseaseID)
where year(date)='2022' group by diseaseName with rollup)
select * from cte;










 
 
 
 
 
 
 