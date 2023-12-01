/*Problem Statement 1:  Some complaints have been lodged by patients that they have been prescribed hospital-exclusive medicine
 that they can’t find elsewhere and facing problems due to that. Joshua, from the pharmacy management, wants to get a report of which
 pharmacies have prescribed hospital-exclusive medicines the most in the years 2021 and 2022. Assist Joshua to generate the report so
 that the pharmacies who prescribe hospital-exclusive medicine more often are advised to avoid such practice if possible.   */

select pharmacyID,pharmacyName,count(hospitalExclusive) as count from pharmacy ph 
join prescription pr using(pharmacyID)
join treatment t using(treatmentID)
join contain ct using(prescriptionID)
join medicine m using(medicineID) where year(date) between '2021' and '2022' and hospitalExclusive='S' group by pharmacyID;

/*Problem Statement 2: Insurance companies want to assess the performance of their insurance plans.
 Generate a report that shows each insurance plan, the company that issues the plan, 
 and the number of treatments the plan was claimed for.*/
 select planName,companyID,count(treatmentID) from
 treatment t join claim cl using(claimID)
 join insuranceplan ip using(UIN)
 join insurancecompany using(companyID) group by planName,companyID order by planName;
 
 /*Problem Statement 3: Insurance companies want to assess the performance of their insurance plans. 
 Generate a report that shows each insurance company's name with their most and least claimed insurance plans.*/
 
 select companyName,max(planName) as most_claimed_plan,min(planName) as leastt_claimed_plan from 
 insurancecompany ic left join insuranceplan ip using(companyID)
 left join claim cl using(UIN) group by companyName order by companyName;
 
/* Problem Statement 4:  The healthcare department wants a state-wise health report to assess which state requires 
more attention in the healthcare sector. Generate a report for them that shows the state name, number of registered
people in the state, number of registered patients in the state, and the people-to-patient ratio. 
sort the data by people-to-patient ratio*/

select state ,count(p.personID) as registered_persons ,count(pt.patientID) as registered_patients ,(count(p.personID)/count(pt.patientID)) as peoples_to_patients 
from person p left join patient pt on p.personID=pt.patientID
left join address a using(addressID) group by state; 


 
 /*Problem Statement 5:  Jhonny, from the finance department of Arizona(AZ), has requested a report that lists the 
 total quantity of medicine each pharmacy in his state has prescribed that falls under Tax criteria I for treatments
 that took place in 2021. Assist Jhonny in generating the report*/
 
 select ph.pharmacyName,count(m.medicineID) as counted 
 from address a join pharmacy ph using(addressID)
 join prescription pr using(pharmacyID)
 join contain ct using(prescriptionID)
 join medicine m using(medicineID)
 where state='AZ' and taxCriteria='I' group by ph.pharmacyName;
 
 
 
 
 
 
 
 
 
 
 
 
