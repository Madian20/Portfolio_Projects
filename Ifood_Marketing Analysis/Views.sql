USE MarketingCampaign_DB;
GO

-- ============================================================
-- VIEW 1: Customer — all personal & demographic info
-- ============================================================
CREATE OR ALTER VIEW vw_Customer AS
SELECT
    ID,
    Year_Birth,
    Age,
    AgeGroup,
    Education,
    Marital_Status,
    Income,
    Kidhome,
    Teenhome,
    HasChildren,
    Country,
    Dt_Customer,
    CustomerTenure
FROM MarketingCampaign;
GO

-- ============================================================
-- VIEW 2: Spending — all spending amounts by category
-- ============================================================
CREATE OR ALTER VIEW vw_Spending AS
SELECT
    ID,
    MntWines,
    MntFruits,
    MntMeatProducts,
    MntFishProducts,
    MntSweetProducts,
    MntGoldProds,
    TotalSpend
FROM MarketingCampaign;
GO

-- ============================================================
-- VIEW 3: Purchases — all purchase channel metrics
-- ============================================================
CREATE OR ALTER VIEW vw_Purchases AS
SELECT
    ID,
    NumDealsPurchases,
    NumWebPurchases,
    NumCatalogPurchases,
    NumStorePurchases,
    TotalPurchases,
    NumWebVisitsMonth
FROM MarketingCampaign;
GO

-- ============================================================
-- VIEW 4: Campaigns — all campaign & complaint data
-- ============================================================
CREATE OR ALTER VIEW vw_Campaigns AS
SELECT
    ID,
    AcceptedCmp1,
    AcceptedCmp2,
    AcceptedCmp3,
    AcceptedCmp4,
    AcceptedCmp5,
    Response,
    TotalCampaignsAccepted,
    Complain
FROM MarketingCampaign;
GO

-- ============================================================
-- VIEW 5: Segments — all classification & behavioral labels
-- ============================================================
CREATE OR ALTER VIEW vw_Segments AS
SELECT
    ID,
    IncomeSegment,
    AgeGroup,
    HasChildren,
    RecencySegment,
    RFM_Segment,
    Recency
FROM MarketingCampaign;
GO
