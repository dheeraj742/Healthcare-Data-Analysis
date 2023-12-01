/*Problem Statement 1: 
The healthcare department wants a pharmacy report on the percentage of hospital-exclusive medicine prescribed in the year 2022.
Assist the healthcare department to view for each pharmacy, the pharmacy id, pharmacy name, total quantity of medicine prescribed 
in 2022, total quantity of hospital-exclusive medicine prescribed by the pharmacy in 2022, and the percentage of hospital-exclusive
 medicine to the total medicine prescribed in 2022.Order the result in descending order of the percentage found. */
 select pharmacyID,pharmacyName,sum(quantity) as total,sum(case when hospitalExclusive='S' then quantity else 0 end) as hos_exclusive_count,
 (sum(case when hospitalExclusive='S' then quantity else 0 end)/sum(quantity))*100 as percentage_of_hos_to_total
 from pharmacy ph join prescription pr using(pharmacyID)
 join treatment t using(treatmentID)
 join contain c using(prescriptionID)
 join medicine m using(medicineID) where year(date)='2022' group by pharmacyID,pharmacyName order by percentage_of_hos_to_total desc;

/*Problem Statement 2:  
Sarah, from the healthcare department, has noticed many people do not claim insurance for their treatment. 
She has requested a state-wise report of the percentage of treatments that took place without claiming insurance. 
Assist Sarah by creating a report as per her requirement.*/

select state,count(treatmentID) as state_wise_treatments from treatment t left join claim c using(claimID) 
join prescription pr using(treatmentID)
join pharmacy ph using(pharmacyID)
join address a using(addressID) where claimID is null group by state;

/*Problem Statement 3:  
Sarah, from the healthcare department, is trying to understand if some diseases are spreading in a particular region.
 Assist Sarah by creating a report which shows for each state, the number of the most and least treated diseases by the 
 patients of that state in the year 2022. */
 with State_Disease_Treatment_Count as(
select state,diseaseName,count(treatmentID) as cou
 from disease d join treatment using(diseaseID)
 join patient pt using(patientID)
 join person p on pt.patientID=p.personID
 join address a using(addressID)
 where year(date)='2022'
 group by state,diseaseName order by state) ,
 Ranking_Treatment_Count_In_State as
(
	select *,row_number() over(partition by state order by cou desc) as ranks1,
    row_number() over(partition by state order by cou) as ranks2
    from State_Disease_Treatment_Count
)
select * from 
(select state,diseaseName as Most_Treated_Disease,cou from Ranking_Treatment_Count_In_State where ranks1 = 1)t1
join
(select state,diseaseName as Lease_Treated_Disease,cou from Ranking_Treatment_Count_In_State where ranks2 = 1)t2
using(state);
 
 
 
 
 
 /*Problem Statement 4: 
Manish, from the healthcare department, wants to know how many registered people are registered as patients as well, in each city.
 Generate a report that shows each city that has 10 or more registered people belonging to it and the number of patients from that 
 city as well as the percentage of the patient with respect to the registered people.*/
 select city,sum(case when patientID is not null then 1 else 0 end) as patients_count,
 count(personID) as registered_count
 from person p left join patient pt on pt.patientID=p.personID
 join address a using(addressID) group by city having registered_count>=10;
 
 /*Problem Statement 5:  
It is suspected by healthcare research department that the substance “ranitidine” might be causing some side effects. 
Find the top 3 companies using the substance in their medicine so that they can be informed about it.*/
select companyName,count(medicineID) as count from medicine where substanceName like '%ranitidina%'
group by companyName order by count desc limit 3;
 
 
