# US Healthcare Cost Analysis
 
## Project Overview
 
**US Healthcare Cost Analysis** is a data analytics project that examines how treatment costs vary across hospitals and states in America — and whether those costs are affordable relative to local household income. The pipeline covers **2,906 hospitals · 540 DRG codes · 51 states**, sourced from the Centers for Medicare & Medicaid Services (CMS) 2024 inpatient dataset, with a focus on identifying the most financially stressed communities in the country.
 
---

## Motivation & Goal

Healthcare in America is one of the most debated and consequential issues the country faces. The dataset released by the **Centers for Medicare & Medicaid Services (CMS)** captures real inpatient payment data across thousands of hospitals — making it a rare window into what treatment actually costs at the ground level.

The question this project started with was simple: how can this data be used in the most impactful way possible — one that genuinely helps the average American make informed decisions about where and how they seek care?

The goal was to transform raw government data into a clear, accessible tool that answers the questions people actually ask: *What will my treatment cost? Where is it cheaper? And can I realistically afford it where I live?*

---


## Project Phases

<img width="680" height="866" alt="image" src="https://github.com/user-attachments/assets/246f411f-5b8f-4bc2-84d6-013eecc89bb2" />

---

## Code Highlights

### Creating vw_healthcare_analysis

```sql
CREATE VIEW vw_healthcare_analysis AS
SELECT
    h.[Rndrng_Prvdr_CCN],
    h.[Rndrng_Prvdr_Org_Name],
    h.[Rndrng_Prvdr_City],
    h.[Rndrng_Prvdr_St],
    h.[Rndrng_Prvdr_State_FIPS],
    h.[Rndrng_Prvdr_Zip5],
    h.[Rndrng_Prvdr_State_Abrvtn],
    h.[Rndrng_Prvdr_RUCA],
    h.[Rndrng_Prvdr_RUCA_Desc],
    h.[DRG_Cd],
    h.[DRG_Desc],
    h.[Tot_Dschrgs],
    h.[Avg_Submtd_Cvrd_Chrg],
    h.[Avg_Tot_Pymt_Amt],
    h.[Avg_Mdcr_Pymt_Amt],
    i.[State],
    i.[Official_Median_Income_2024]
FROM hospital_charges h
INNER JOIN household_income i
    ON h.Rndrng_Prvdr_State_Abrvtn = i.State_Abbreviation
WHERE
    h.Rndrng_Prvdr_Org_Name      IS NOT NULL
    AND h.Rndrng_Prvdr_State_Abrvtn IS NOT NULL
    AND h.DRG_Desc                IS NOT NULL
    AND h.Tot_Dschrgs             IS NOT NULL
    AND h.Avg_Mdcr_Pymt_Amt       IS NOT NULL
    AND i.Official_Median_Income_2024 IS NOT NULL;
GO
```

### Creating Affordability DAX MEASURE

```DAX
Affordability Ratio =
DIVIDE(
    AVERAGE(vw_healthcare_analysis[Avg_Tot_Pymt_Amt]),
    AVERAGE(vw_healthcare_analysis[Official_Median_Income_2024])
)
```
### Creating Calculated Area Type Column in DAX

```DAX
Area Type =
VAR ruca = VALUE(vw_healthcare_analysis[Rndrng_Prvdr_RUCA])
RETURN
    SWITCH(
        TRUE(),
        ruca >= 1  && ruca < 4,  "Metropolitan",
        ruca >= 4  && ruca < 7,  "Micropolitan",
        ruca >= 7  && ruca < 10, "Small Town",
        ruca >= 10 && ruca < 99, "Rural",
        "Unknown"
    )
```


---
