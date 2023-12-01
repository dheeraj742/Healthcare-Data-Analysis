/*A company needs to set up 3 new pharmacies, they have come up with an idea that the 
pharmacy can be set up in cities where the pharmacy-to-prescription ratio is the lowest and
 the number of prescriptions should exceed 100.
 Assist the company to identify those cities where the pharmacy can be set up.*/
 select city from (SELECT a.city,
       COUNT(distinct p.pharmacyid) AS num_pharmacies,
       COUNT(distinct pr.prescriptionid) AS num_prescriptions,
       COUNT(DISTINCT p.pharmacyid) / COUNT(DISTINCT pr.prescriptionid) AS pharmacy_prescription_ratio
FROM address a
LEFT JOIN pharmacy p ON a.addressid = p.addressid
LEFT JOIN prescription pr ON p.pharmacyid = pr.pharmacyid
GROUP BY a.city
HAVING COUNT(DISTINCT pr.prescriptionid) > 100 order by pharmacy_prescription_ratio asc limit 3) a;

 
 
 
 
 
 select a.city ,count_phar/count_pres from (select city,count(distinct prescriptionID) as count_pres from address a left join pharmacy ph on ph.addressID=a.addressID
 left join prescription pr on pr.pharmacyID=ph.pharmacyID group by city having count(prescriptionID)>100) a
 join 
 (select city,count(distinct ph.pharmacyID) as count_phar from address a left join pharmacy ph on ph.addressID=a.addressID
 left join prescription pr on pr.pharmacyID=ph.pharmacyID group by city) b on a.city=b.city order by count_phar/count_pres asc limit 3
 ;
 
 /*Problem Statement 2: The State of Alabama (AL) is trying to manage its healthcare resources more efficiently. 
 For each city in their state, they need to identify the disease for which the maximum number of patients have gone for treatment. 
 Assist the state for this purpose. Note: The state of Alabama is represented as AL in Address Table*/
with cc as (select diseaseName,count(patientID)as counted,city,row_number() over(partition by city order by count(patientID) desc) as ranked from 
address a left join person p using(addressID)
join patient pt on pt.patientID=p.personID
join treatment t using(patientID)
join disease d using(diseaseID) 
where state='AL'
group by city,diseaseName
order by counted desc)
select * from cc having ranked=1;
#select diseaseName,counted,city from cc where counted=(select max(counted) from cc);

/*Problem Statement 3: The healthcare department needs a report about insurance plans. The report is required
 to include the insurance plan, which was claimed the most and least for each disease.  Assist to create such a report.*/
 
 with cte7 as (
 select diseaseName,planName from (select diseaseName,planName ,count(planName),row_number() over(partition by diseaseName order by count(planName) desc) as least_rank from disease d join treatment t using(diseaseID)
 join claim c using(claimID)
 join insuranceplan using(uin) group by diseaseName,planName) b where least_rank=1),
 
 cte8 as (select diseaseName,planName from (select diseaseName,planName ,count(planName),row_number() over(partition by diseaseName order by count(planName)) as highest_rank from disease d join treatment t using(diseaseID)
 join claim c using(claimID)
 join insuranceplan using(uin) group by diseaseName,planName) a where highest_rank=1)
 
select cte8.diseaseName,cte7.planName as most_claimed,cte8.planName as least_claimed from cte7 join cte8 using(diseaseName);


/*Problem Statement 4: The Healthcare department wants to know which disease is most likely to infect multiple people in the same 
household. For each disease find the number of households that has more than one patient with the same disease. */

select diseaseName,count(address1) as 'number of house holds having more than 1 patient' from(
select diseaseName,address1,count(personID) as count from address a join person p using(addressID)
join patient pt on pt.patientID=p.personID
join treatment t on pt.patientID=t.patientID
join disease d using(diseaseID) group by diseaseName,address1
having count>1) a group by diseaseName;




/*Problem Statement 5:  An Insurance company wants a state wise report of the treatments to claim ratio 
between 1st April 2021 and 31st March 2022 (days both included). Assist them to create such a report.*/
 
 select state,count(treatmentID),count(claimID) from
 address a join insurancecompany ic using(addressID)
 join insuranceplan ip using(companyID)
 join claim cl using(UIN)
 right join treatment t using(claimID)
 where date between '2021-04-01' and '2022-03-31'
 group by state;
 
select state,count(treatmentID)/count(claimID) 
from address a left join pharmacy ph using(addressID)
left join prescription pr using(pharmacyID)
left join treatment t using(treatmentID)
left join claim c using(claimID) 
where date between '2021-04-01' and '2022-03-31'
group by state order by state;

-- approach 2
select state,count(treatmentID)/count(claimID) 
from address a left join person p using(addressID)
left join patient pt on pt.patientID=p.personID
left join treatment t using(patientID)
left join claim c using(claimID) 
where date between '2021-04-01' and '2022-03-31'
group by state order by state;