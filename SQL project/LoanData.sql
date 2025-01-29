
-- Average Loan Amount by State and Loan Purpose
SELECT 
    State, 
    LoanPurpose, 
    AVG(LoanAmount) AS AvgLoanAmount
FROM LoanTable
GROUP BY State, LoanPurpose
ORDER BY State, AvgLoanAmount DESC;

-- Loan Approval Rate by Employment Type
SELECT 
    EmploymentStatus, 
    COUNT(CASE WHEN LoanApproved = 1 THEN 1 END) * 100.0 / COUNT(*) AS ApprovalRate
FROM LoanTable
GROUP BY EmploymentStatus
ORDER BY ApprovalRate DESC;

-- Average Credit Score for Approved and Rejected Loans
SELECT 
    LoanApproved, 
    AVG(CreditScore) AS AvgCreditScore
FROM LoanTable
GROUP BY LoanApproved;

-- Monthly Loan Payment Burden Analysis
SELECT 
    LoanPurpose,
    AVG(MonthlyLoanPayment / MonthlyIncome) AS AvgPaymentBurden
FROM LoanTable
GROUP BY LoanPurpose
ORDER BY AvgPaymentBurden DESC;

-- Top 10 Applicants with the Highest Risk Score and Loan Amount
SELECT 
    ApplicantID, 
    Age, 
    LoanAmount, 
    RiskScore, 
    CreditScore
FROM LoanTable
ORDER BY RiskScore DESC, LoanAmount DESC
LIMIT 10;

--  Trends in Loan Applications Over Time
SELECT 
    DATE_TRUNC('month', ApplicationDate) AS ApplicationMonth,
    COUNT(*) AS TotalApplications,
    SUM(CASE WHEN LoanApproved = 1 THEN 1 ELSE 0 END) AS ApprovedLoans
FROM LoanTable
GROUP BY ApplicationMonth
ORDER BY ApplicationMonth;

--  Debt-to-Income Ratio Distribution
SELECT 
    CASE 
        WHEN DebtToIncomeRatio < 0.2 THEN 'Low (<20%)'
        WHEN DebtToIncomeRatio BETWEEN 0.2 AND 0.4 THEN 'Moderate (20%-40%)'
        WHEN DebtToIncomeRatio BETWEEN 0.4 AND 0.6 THEN 'High (40%-60%)'
        ELSE 'Critical (>60%)'
    END AS DebtToIncomeCategory,
    COUNT(*) AS ApplicantCount
FROM LoanTable
GROUP BY DebtToIncomeCategory
ORDER BY ApplicantCount DESC;

--  Average Interest Rate by Credit Score Range
SELECT 
    CASE 
        WHEN CreditScore < 600 THEN 'Poor (<600)'
        WHEN CreditScore BETWEEN 600 AND 699 THEN 'Fair (600-699)'
        WHEN CreditScore BETWEEN 700 AND 799 THEN 'Good (700-799)'
        ELSE 'Excellent (800+)'
    END AS CreditScoreRange,
    AVG(InterestRate) AS AvgInterestRate
FROM LoanTable
GROUP BY CreditScoreRange
ORDER BY CreditScoreRange;

--  Loan Defaults by Employment Status
SELECT 
    EmploymentStatus,
    COUNT(*) AS TotalDefaults,
    AVG(PreviousLoanDefaults) AS AvgDefaults
FROM LoanTable
WHERE PreviousLoanDefaults > 0
GROUP BY EmploymentStatus
ORDER BY TotalDefaults DESC;

--  Loan Purpose Contribution to Total Loan Amount
SELECT 
    LoanPurpose, 
    SUM(LoanAmount) AS TotalLoanAmount, 
    SUM(LoanAmount) * 100.0 / (SELECT SUM(LoanAmount) FROM LoanTable) AS PercentageContribution
FROM LoanTable
GROUP BY LoanPurpose
ORDER BY TotalLoanAmount DESC;



--  Predictive Insights: Loan Approval Likelihood by Income and Credit Score
SELECT 
    CASE 
        WHEN AnnualIncome < 50000 THEN 'Low Income (<50k)'
        WHEN AnnualIncome BETWEEN 50000 AND 100000 THEN 'Medium Income (50k-100k)'
        ELSE 'High Income (>100k)'
    END AS IncomeCategory,
    CASE 
        WHEN CreditScore < 600 THEN 'Poor (<600)'
        WHEN CreditScore BETWEEN 600 AND 699 THEN 'Fair (600-699)'
        WHEN CreditScore BETWEEN 700 AND 799 THEN 'Good (700-799)'
        ELSE 'Excellent (800+)'
    END AS CreditScoreRange,
    COUNT(CASE WHEN LoanApproved = 1 THEN 1 END) * 100.0 / COUNT(*) AS ApprovalRate
FROM LoanTable
GROUP BY IncomeCategory, CreditScoreRange
ORDER BY CreditScoreRange, IncomeCategory;

--  Correlation Between Loan Amount and Risk Score by Employment Type
SELECT 
    EmploymentStatus,
    CORR(LoanAmount, RiskScore) AS Correlation
FROM LoanTable
GROUP BY EmploymentStatus
HAVING COUNT(*) > 10; -- Ensure meaningful correlation with sufficient data

--  Default Likelihood Based on Credit Utilization and Debt-to-Income Ratio
SELECT 
    CASE 
        WHEN CreditCardUtilizationRate < 0.3 THEN 'Low Utilization (<30%)'
        WHEN CreditCardUtilizationRate BETWEEN 0.3 AND 0.6 THEN 'Moderate Utilization (30%-60%)'
        ELSE 'High Utilization (>60%)'
    END AS UtilizationCategory,
    CASE 
        WHEN DebtToIncomeRatio < 0.4 THEN 'Low DTI (<40%)'
        ELSE 'High DTI (>=40%)'
    END AS DTI_Category,
    AVG(PreviousLoanDefaults) AS AvgDefaults
FROM LoanTable
GROUP BY UtilizationCategory, DTI_Category
HAVING AVG(PreviousLoanDefaults) > 0.1
ORDER BY AvgDefaults DESC;

--  Loan Approval Trends Over Time by Age Group
SELECT 
    DATE_TRUNC('month', ApplicationDate) AS ApplicationMonth,
    CASE 
        WHEN Age < 25 THEN 'Young (<25)'
        WHEN Age BETWEEN 25 AND 40 THEN 'Adult (25-40)'
        WHEN Age BETWEEN 41 AND 60 THEN 'Middle-Aged (41-60)'
        ELSE 'Senior (>60)'
    END AS AgeGroup,
    COUNT(CASE WHEN LoanApproved = 1 THEN 1 END) AS ApprovedLoans,
    COUNT(*) AS TotalApplications,
    COUNT(CASE WHEN LoanApproved = 1 THEN 1 END) * 100.0 / COUNT(*) AS ApprovalRate
FROM LoanTable
GROUP BY ApplicationMonth, AgeGroup
ORDER BY ApplicationMonth, AgeGroup;

--  High-Risk Loan Analysis: Defaults and Utilization
SELECT 
    ApplicantID, 
    Age, 
    CreditScore, 
    LoanAmount, 
    RiskScore,
    CreditCardUtilizationRate,
    PreviousLoanDefaults
FROM LoanTable
WHERE RiskScore > 80 AND CreditCardUtilizationRate > 0.7
ORDER BY RiskScore DESC, CreditCardUtilizationRate DESC, LoanAmount DESC;
