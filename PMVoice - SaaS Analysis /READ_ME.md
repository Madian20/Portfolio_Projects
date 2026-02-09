## Project Overview

**PMVoice** is a simulated SaaS analytics project designed to capture and analyze the Voice of Product Managers (PMs) and translate qualitative product feedback into structured, actionable data.

The project is based on a realistically generated dataset that reflects how PM discussions, sentiments, and recurring themes emerge across public platforms and influence product usage, churn behavior, and revenue within a SaaS environment.

The dataset was generated using **Python**, where multiple interrelated tables were created to model real-world SaaS entities, including users, themes, sources, usage events, and revenue events.

Before persistence, the data underwent **Exploratory Data Analysis (EDA)** and **data quality validation in Python** to assess distributions, relationships, and anomalies. This process included:
- Detecting and removing duplicate records  
- Identifying outliers and abnormal values  
- Validating logical consistency across related datasets  

The cleaned and validated data was then exported to **SQL Server**, where a relational schema was designed and implemented using **SQL**.  
An **Entity Relationship Diagram (ERD)** was created to clearly define table relationships and support analytical and reporting use cases.

In the final stage, the data was used to build an **interactive Power BI report** that analyzes sentiment patterns, recurring themes, and their relationship with product usage, churn risk, and revenue performance.

<img width="1024" height="1024" alt="image" src="https://github.com/user-attachments/assets/90d6f9fd-bd41-45ff-a542-3f9ffcd4a837" /> 

## North Star KPIs

### Business Metrics
- **Total Revenue** - Monetization effectiveness across platform integrations
- **Active Customers** - User adoption and engagement
- **ARPU** - Customer lifetime value

### Health Metrics
- **Pain Rate** - Percentage of pain-related sentiment in feedback
- **Churn Rate** - Customer retention health
- **Adoption Rate** - New user acquisition and platform growth
- **Sentiment Score** - Overall customer satisfaction and brand perception ( -1 : 1)

## Insights Deep Dive 

### Core Metrics
- **Financials:** Total Revenue $550.56K | Active Customers: 470 | ARPU: $1.17K  
- **Customer Metrics:** Total Mentions: 3K | Churn Rate: 29.27% | Adoption Rate: 61.89%
  
### Platform Sentiment:
 <img width="1372" height="690" alt="image" src="https://github.com/user-attachments/assets/d6b5f3b1-385f-4588-857d-18079ad222d9" />
  - Reddit: 27.66% pain (lowest → most positive)  
  - ProductHunt: 37.33% pain (highest → most critical)  
  - LinkedIn, Quora, Twitter: 32–33% pain (moderate)


### Revenue Vs Sentiment Stability (2024–2025)
<img width="1377" height="708" alt="image" src="https://github.com/user-attachments/assets/f4b63094-7dce-470e-8cfe-e8ebd79c8445" />

Monthly recurring revenue shows notable fluctuations across 2024–2025, with peaks and troughs that highlight instability in income. In contrast, average sentiment remains relatively stable around ≈0.051, rarely deviating far from neutral. However, sentiment volatility increased in 2025: four negative months compared to only one in 2024, including a recurring “August slump” and a sharp low of -0.045 in June. November 2024 marked the all-time high (0.152), but the inability to sustain positivity in 2025 signals rising churn risk and inconsistent user experience. The divergence between unstable revenue and nearly flat sentiment underscores a disconnect—customers are not markedly more negative, yet revenue performance continues to deteriorate.

### Pain Themes: Frequency vs. Strategic Impact
<img width="1377" height="713" alt="image" src="https://github.com/user-attachments/assets/31aa7130-acb6-4ede-8190-29f994d4ab93" />
Pain themes reveal a mismatch between frequency and strategic impact. While “better WLB” and “innovative company” are the most mentioned (74 and 72 mentions), their impact is moderate (≈2.0–2.5). In contrast, “no customer validation” and “project manager duties” are less mentioned (59 each) but carry higher strategic weight (≈2.7 and 2.2). This indicates that issues with validation and role clarity, though less frequently raised, pose greater long-term risk to product and organizational stability.









