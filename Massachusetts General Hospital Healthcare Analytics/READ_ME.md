# MGH Analytics
 
## Project Overview
 
**MGH Analytics** is a comprehensive healthcare data analytics project that examines how **Massachusetts General Hospital (MGH)** operates across patient encounters, clinical procedures, payer coverage, and patient outcomes. The project covers **974 registered patients · 28K total encounters · 43K procedures · 9 insurance companies**, sourced from **Maven Analytics** spanning **2011–2022**, with a focus on identifying patterns in clinical utilization, cost distribution, insurance coverage gaps, and readmission rates across patient demographics and encounter types.

---

## Project Phases
 
1. **Data Search** — Searched for the appropriate data.
2. **Initial Data Checking** 
3. **ETL Process** — ETL process mainly using SQL and loading the data via Python.
4. **Exploratory Data Analysis (EDA)** — EDA in SQL.
5. **Dashboard** — Final dashboard in Power BI.

---

## Data Model & Relationships
<img width="1540" height="1492" alt="image" src="https://github.com/user-attachments/assets/1237a7ec-071f-44fb-84c6-6170dfc8881d" />

---

## Final Dashboard

### Patient Overview
<img width="1300" height="732" alt="image" src="https://github.com/user-attachments/assets/737efc11-f5e2-4610-9b26-a538d435cefa" />


<img width="1304" height="736" alt="image" src="https://github.com/user-attachments/assets/7d66159b-d19a-43d9-b523-e06dda62edb5" />

### Encounters 
<img width="1300" height="729" alt="image" src="https://github.com/user-attachments/assets/997983c1-ebb3-4696-b151-79c5290013fd" />

### Procedures & Cost
<img width="1303" height="729" alt="image" src="https://github.com/user-attachments/assets/1b7cd151-71c0-439c-9e79-c3fff9a5a532" />

### Outcomes 
<img width="1296" height="733" alt="image" src="https://github.com/user-attachments/assets/af9ee080-365b-4eca-a716-289607a6496c" />

---

## Key Insights
 
- **~31% of patients have no insurance coverage.** The 50–64 age group has the highest insured rate at 23.3%, while the 65+ group is the least insured. Notably,     around 30% of younger patients also lack coverage, highlighting a cross-generational gap in insurance access.
  
- **Anthem presents a clear trade-off.** It records the lowest readmission rate among all insurers at 32% and one of the lowest mortality rates at 3.94%. However,   its patients carry the highest out-of-pocket costs after the uninsured, suggesting that lower clinical risk comes at a higher financial burden to the patient.
  
- **The overall mortality rate of ~15.81% is heavily skewed by the 65+ age group**, which alone accounts for a 23.5% mortality rate. All other age groups fall       between 4–5%, and no deaths were recorded for patients under 18.
  
- **Encounter volume spiked notably in 2014 and 2021**, yet both years showed lower average costs
  
- **Inpatient encounters have the highest average length of stay**, while urgentcare sits at the opposite end. Paradoxically, urgentcare also has the highest        readmission rate at 74%, raising questions about care continuity and whether patients are being discharged prematurely or without adequate follow-up.
  
- **Mortality is influenced not just by age but also by insurance type.** Medicaid patients stand out with one of the highest mortality rates across all age         groups, suggesting that insurance type may be a proxy for access to care quality, care continuity, or socioeconomic factors that affect health outcomes.

---

## Code Highlights

### Cleaning

#### Delete encounters that started after the patient's death
```{SQL}
DELETE e
FROM encounters e
INNER JOIN patients p ON p.Id = e.Patient
WHERE p.DeathDate IS NOT NULL AND e.Start > p.DeathDate;
GO
```
#### Delete procedures that started before their encounter
```{SQL}
DELETE FROM procedures
WHERE Encounter IN (
    SELECT pr.Encounter
    FROM procedures pr
    JOIN encounters e ON e.Id = pr.Encounter
    WHERE pr.Start < e.Start
);
GO
```
### Create PKs & FKs

#### encounters PK
```{SQL}
ALTER TABLE encounters    ADD CONSTRAINT PK_encounters     PRIMARY KEY (Id);
GO
```
#### encounters FKs
```{SQL}
-- encounters → patients
ALTER TABLE encounters
    ADD CONSTRAINT FK_encounters_patients
    FOREIGN KEY (Patient) REFERENCES patients(Id);
 
-- encounters → organizations
ALTER TABLE encounters
    ADD CONSTRAINT FK_encounters_organizations
    FOREIGN KEY (Organization) REFERENCES organizations(Id);
 
-- encounters → payers
ALTER TABLE encounters
    ADD CONSTRAINT FK_encounters_payers
    FOREIGN KEY (Payer) REFERENCES payers(Id);
```
### Calculeted Columns 

#### Create Age & Age group Columns
```{sql}
    DATEDIFF(YEAR, BirthDate, (SELECT MAX(Stop) FROM encounters)) AS Age,
    CASE
        WHEN DATEDIFF(YEAR, BirthDate, (SELECT MAX(Stop) FROM encounters)) < 18 THEN 'Under 18'
        WHEN DATEDIFF(YEAR, BirthDate, (SELECT MAX(Stop) FROM encounters)) < 35 THEN '18-34'
        WHEN DATEDIFF(YEAR, BirthDate, (SELECT MAX(Stop) FROM encounters)) < 50 THEN '35-49'
        WHEN DATEDIFF(YEAR, BirthDate, (SELECT MAX(Stop) FROM encounters)) < 65 THEN '50-64'
        ELSE '65+'
    END AS AgeGroup
```
#### create InsuranceCoverage_Pct Column 
```{sql}
    CASE
        WHEN e.Total_Claim_Cost = 0 THEN 0
        ELSE ROUND(e.Payer_Coverage / e.Total_Claim_Cost * 100, 2)
    END                                             AS InsuranceCoverage_Pct
```
### DAX Measures 

#### Create Mortality rate Measure 
```{DAX}
% Mortality Rate = 
DIVIDE(
    CALCULATE(
        DISTINCTCOUNT( vw_encounter_enriched[Patient] ),
        vw_encounter_enriched[Patient] IN
            CALCULATETABLE(
                VALUES( vw_patient_base[Id] ),
                vw_patient_base[IsDead] = 1
            )
    ),
    DISTINCTCOUNT( vw_encounter_enriched[Patient] ),
    0
) 
```
#### Create Readmission Rate Measure
```{DAX}
Readmission Rate % = 
DIVIDE(
    SUMX( vw_readmission, vw_readmission[IsReadmitted] ),
    COUNTROWS( vw_readmission ),
    0
)
```
