USE ProductVOC_DB;
GO


-- What are the most frequent "Pain" themes mentioned by users?
SELECT TOP 5 
    t.ThemeName, 
    COUNT(v.MentionID) AS MentionCount
FROM Fact_VOC_Mentions v
INNER JOIN Dim_Themes t ON v.ThemeID = t.ThemeID
WHERE t.Category = 'Pain'
GROUP BY t.ThemeName
ORDER BY MentionCount DESC;


-- Which customer segment has the lowest average sentiment (most unhappy)?
SELECT 
    u.Segment, 
    ROUND(AVG(v.SentimentScore), 3) AS AvgSentiment
FROM Fact_VOC_Mentions v
INNER JOIN Dim_Users u ON v.UserID = u.UserID
GROUP BY u.Segment
ORDER BY AvgSentiment ASC;


-- How is customer sentiment changing month over month?
SELECT 
    c.Year, 
    c.Month, 
    c.MonthName, 
    ROUND(AVG(v.SentimentScore), 3) AS AvgSentiment
FROM Fact_VOC_Mentions v
INNER JOIN Dim_Calendar c ON v.Date = c.Date
GROUP BY c.Year, c.Month, c.MonthName
ORDER BY c.Year, c.Month;

/* 
ANALYSIS NOTE: 
   Sentiment trend reveals concerning volatility with no sustained growth trajectory. 
   Performance deteriorated YoY: 2025 recorded four negative months (reaching a low 
   of -0.045 in June) compared to only one in 2024. A recurring "August Slump" 
   (negative in both years) suggests a seasonal operational or product reliability 
   issue. While Nov '24 marked the all-time high (0.152), the inability to maintain 
   positive sentiment in 2025 indicates rising churn risk and inconsistent user experience.
*/


-- Did users who churned have a lower sentiment score before leaving compared to active users?
SELECT 
    CASE 
        WHEN fe.UserID IS NOT NULL THEN 'Churned Users'
        ELSE 'Active Users'
    END AS UserStatus,
    ROUND(AVG(v.SentimentScore), 3) AS AvgSentiment,
    COUNT(DISTINCT u.UserID) AS UserCount
FROM Fact_VOC_Mentions v
INNER JOIN Dim_Users u ON v.UserID = u.UserID
LEFT JOIN (
    SELECT DISTINCT UserID 
    FROM Fact_Usage_Events 
    WHERE ChurnFlag = 1
) fe ON u.UserID = fe.UserID
GROUP BY CASE 
    WHEN fe.UserID IS NOT NULL THEN 'Churned Users'
    ELSE 'Active Users'
END;


-- Which customer segment contributes the most to Total MRR (Monthly Recurring Revenue)? 
SELECT 
    u.Segment, 
    SUM(r.MRRAmount) AS TotalRevenue
FROM Fact_Revenue_Events r
INNER JOIN Dim_Users u ON r.UserID = u.UserID
GROUP BY u.Segment
ORDER BY TotalRevenue DESC;


-- Which platform generates the highest volume of feedback?
SELECT 
    s.SourceName, 
    COUNT(v.MentionID) AS FeedbackVolume
FROM Fact_VOC_Mentions v
INNER JOIN Dim_Sources s ON v.SourceID = s.SourceID
GROUP BY s.SourceName
ORDER BY FeedbackVolume DESC;


-- What are the most adopted features based on usage events?
SELECT 
    Feature, 
    COUNT(EventID) AS AdoptionCount
FROM Fact_Usage_Events
WHERE EventType = 'Adopt'
GROUP BY Feature
ORDER BY AdoptionCount DESC;

-- Which company size has the highest average churn risk score?
SELECT 
    CompanySize, 
    ROUND(AVG(ChurnRiskScore), 3) AS AvgRiskScore
FROM Dim_Users
GROUP BY CompanySize
ORDER BY AvgRiskScore DESC;

/* 
ANALYSIS NOTE: 
   Risk profile varies non-linearly across company sizes. 
   Micro-firms (1–10 employees) exhibit the highest average risk (0.311), 
   reflecting structural fragility and limited operational buffers. 
   Mid-sized firms (11–50 employees) show the lowest risk (0.285), 
   suggesting a "stability sweet spot" where scale balances agility and resilience. 
   Larger organizations (51–200, 201–1000, 1000+) cluster closely (0.287–0.294), 
   indicating consistent but moderate risk levels tied to complexity rather than size. 
   Overall, the U-shaped distribution highlights elevated vulnerability at the smallest scale, 
   improved stability in early growth, and plateaued risk in mature enterprises. 
*/

-- Are more experienced Product Managers (PMs) more negative in their feedback?
SELECT 
    u.PMExperienceYears, 
    ROUND(AVG(v.SentimentScore), 3) AS AvgSentiment,
    COUNT(v.MentionID) AS Mentions
FROM Fact_VOC_Mentions v
 INNER JOIN Dim_Users u ON v.UserID = u.UserID
GROUP BY u.PMExperienceYears
ORDER BY u.PMExperienceYears;

/* 
ANALYSIS NOTE: 
   Feedback sentiment declines as PMs gain experience, supporting the hypothesis 
   that more seasoned Product Managers are more critical in their evaluations. 
   Entry-level PMs (0 years) show the highest positivity (0.145), but sentiment drops 
   sharply after year 1 (0.036) and stabilizes at consistently low levels (≈0.05–0.06) 
   through years 2–6. Beyond year 7, sentiment deteriorates further, reaching neutral 
   (0.0 at year 9) and even negative (-0.014 at year 8). 
   The volume of mentions also peaks in mid-career (years 3–5, >400 mentions), 
   suggesting that the most engaged PMs are simultaneously the most critical. 
   Overall, the trajectory indicates that experience correlates with heightened scrutiny, 
   reduced optimism, and a greater tendency to highlight product shortcomings. 
*/

-- Which themes appear frequently AND have a high strategic impact score?
SELECT TOP 10
    t.ThemeName,
    t.Category,
    COUNT(v.MentionID) AS Frequency,
    MAX(t.ImpactScore) AS StrategicImpact
FROM Fact_VOC_Mentions v
 INNER JOIN Dim_Themes t ON v.ThemeID = t.ThemeID
GROUP BY t.ThemeName, t.Category
ORDER BY Frequency DESC, StrategicImpact DESC;
