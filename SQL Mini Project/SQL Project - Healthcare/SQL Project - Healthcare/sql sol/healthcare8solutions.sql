/*SELECT timestampdiff(year,dob,curdate()) as age,
count(*) AS numTreatments
FROM Person
JOIN Patient ON Patient.patientID = Person.personID
JOIN Treatment ON Treatment.patientID = Patient.patientID
group by timestampdiff(year,dob,curdate())
order by numTreatments desc;*/
select age, count(*) as numTreatments
from (
    select
        timestampdiff(year, dob, curdate()) AS age,
        pt.patientID
    from Person p
    join Patient pt on pt.patientID = p.personID
    join Treatment t using(patientID)
) as subquery
group by age
order by numTreatments desc;

/*
drop table if exists T1;
drop table if exists T2;
drop table if exists T3;

select Address.city, count(Pharmacy.pharmacyID) as numPharmacy
into T1
from Pharmacy right join Address on Pharmacy.addressID = Address.addressID
group by city
order by count(Pharmacy.pharmacyID) desc;

select Address.city, count(InsuranceCompany.companyID) as numInsuranceCompany
into T2
from InsuranceCompany right join Address on InsuranceCompany.addressID = Address.addressID
group by city
order by count(InsuranceCompany.companyID) desc;

select Address.city, count(Person.personID) as numRegisteredPeople
into T3
from Person right join Address on Person.addressID = Address.addressID
group by city
order by count(Person.personID) desc;

select T1.city, T3.numRegisteredPeople, T2.numInsuranceCompany, T1.numPharmacy
from T1, T2, T3
where T1.city = T2.city and T2.city = T3.city
order by numRegisteredPeople desc;
*/

with phcou as (
    select
        city,
        count(pharmacyID) as num_pharmacy
    from
        pharmacy ph
    right join
        address a using(addressID)
    group by
        city
),
insurancecompany_count as (
    select
        a.city,
        count(ic.companyID) as num_insurancecompany
    from
        insurancecompany ic
    right join
        address a using(addressID)
    group by
        city
),
registered_people_count as (
    select
        a.city,
        count(p.personID) as num_registeredpeople
    from
        person p
    right join
        address a using(addressID)
    group by
        city
)
select
    pc.city,
    rc.num_registeredpeople,
    ic.num_insurancecompany,
    pc.num_pharmacy
from phcou pc join insurancecompany_count ic using(city)
join registered_people_count rc using(city)
order by rc.num_registeredpeople desc;

/*select Pharmacy.pharmacyID, Prescription.prescriptionID, sum(quantity) as totalQuantity
into T1
from Pharmacy
join Prescription on Pharmacy.pharmacyID = Prescription.pharmacyID
join Contain on Contain.prescriptionID = Prescription.prescriptionID
join Medicine on Medicine.medicineID = Contain.medicineID
join Treatment on Treatment.treatmentID = Prescription.treatmentID
where YEAR(date) = 2022
group by Pharmacy.pharmacyID, Prescription.prescriptionID
order by Pharmacy.pharmacyID, Prescription.prescriptionID;

select * from T1
where totalQuantity > (select avg(totalQuantity) from T1);
*/

with t1 as (
    select
        pharmacy.pharmacyid,
        prescription.prescriptionid,
        sum(quantity) as totalquantity
    from
        pharmacy
    join
        prescription on pharmacy.pharmacyid = prescription.pharmacyid
    join
        contain on contain.prescriptionid = prescription.prescriptionid
    join
        medicine on medicine.medicineid = contain.medicineid
    join
        treatment on treatment.treatmentid = prescription.treatmentid
    where
        year(date) = 2022
    group by
        pharmacy.pharmacyid,
        prescription.prescriptionid
)
select * from t1 where totalquantity > (select avg(totalquantity) from t1);

 /*SELECT Disease.diseaseName, COUNT(*) as numClaims
FROM Disease
JOIN Treatment ON Disease.diseaseID = Treatment.diseaseID
JOIN Claim On Treatment.claimID = Claim.claimID
WHERE diseaseName IN (SELECT diseaseName from Disease where diseaseName LIKE '%p%')
GROUP BY diseaseName;
*/
with cte as (select diseaseName from disease where diseaseName like '%p%')
select d.diseaseName,COUNT(*) AS num_Claims
from disease d join treatment t using(diseaseID)
join claim c using(claimID)
join cte using(diseaseName)
group by d.diseaseName;
