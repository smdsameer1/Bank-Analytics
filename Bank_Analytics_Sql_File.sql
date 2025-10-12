DESCRIBE bank;
SHOW COLUMNS FROM bank;
---- Total loan amount ---
SELECT
  SUM(`Funded Amount`) AS total_loan_amount_funded
FROM bank;
--- Total Loan ---
SELECT
  COUNT(`Client id`) AS total_loans
FROM bank;
--- total collection --
SELECT
  SUM(COALESCE(`Total Rec Prncp`, 0) + COALESCE(`Total Rrec int`, 0)) AS total_collection
FROM bank;
---- total interest ---
SELECT
  SUM(COALESCE(`Total Rrec int`, 0)) AS total_interest_revenue
FROM bank;
---- branch wise performance ---
SELECT
  `Branch Name` AS branch,
  SUM(COALESCE(`Total Rrec int`, 0)) AS total_interest,
  SUM(COALESCE(`Total Fees`, 0)
      + COALESCE(`Total Rec Late fee`, 0)
      + COALESCE(`Recoveries`, 0)
      + COALESCE(`Collection Recovery fee`, 0)
     ) AS total_fees_and_revenue,
  SUM(
    COALESCE(`Total Rec Prncp`, 0)
    + COALESCE(`Total Rrec int`, 0)
    + COALESCE(`Total Fees`, 0)
    + COALESCE(`Total Rec Late fee`, 0)
    + COALESCE(`Recoveries`, 0)
    + COALESCE(`Collection Recovery fee`, 0)
  ) AS total_collection
FROM bank
GROUP BY `Branch Name`
ORDER BY total_collection DESC;
---- state wise loan ---
SELECT
  `State Abbr` AS state,
  COUNT(`Client id`) AS total_loans,
  SUM(COALESCE(`Funded Amount`, 0)) AS total_funded_amount
FROM bank
GROUP BY `State Abbr`
ORDER BY total_loans DESC;
---- religion wise loan ---
SELECT
  `Religion` AS religion,
  COUNT(`Client id`) AS total_loans,
  SUM(COALESCE(`Funded Amount`, 0)) AS total_funded_amount
FROM bank
GROUP BY `Religion`
ORDER BY total_loans DESC;
------- product group - wise loan ---
SELECT
  `Product Code` AS product_group,
  COUNT(`Client id`) AS total_loans,
  SUM(COALESCE(`Funded Amount`, 0)) AS total_funded_amount
FROM bank
GROUP BY `Product Code`
ORDER BY total_loans DESC;
----- Disbursement Trend ----
SELECT
  DATE_FORMAT(STR_TO_DATE(`Disbursement Date`, '%Y-%m-%d'), '%Y-%m') AS month,
  COUNT(`Client id`)       AS total_loans_issued,
  SUM(COALESCE(`Funded Amount`, 0)) AS total_funded_amount
FROM bank
GROUP BY month
ORDER BY month;
--- Grade-Wise Loan ------
SELECT
  `Grrade` AS grade,
  COUNT(`Client id`) AS loan_count,
  ROUND(AVG(`Funded Amount`), 0) AS avg_loan_amount,
  ROUND(AVG(`Int Rate`), 4) * 100 AS avg_interest_rate_pct,
  
  ROUND( SUM(CASE WHEN `Loan Status` = 'Fully Paid' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2 ) AS pct_fully_paid,
  ROUND( SUM(CASE WHEN `Is Default Loan` = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2 ) AS pct_default
FROM bank
GROUP BY `Grrade`
ORDER BY grade;
--- default loan_count ---
SELECT
  COUNT(*) AS default_loan_count
FROM bank
WHERE `Is Default Loan` = 'Yes';
--- Delinquent Client Count ---
SELECT
  COUNT(DISTINCT `Client id`) AS delinquent_client_count
FROM bank
WHERE `Is Delinquent Loan` = 'Yes';
--- Delinquent Loan Rate ---
SELECT
  ROUND(
    100.0 * SUM(CASE WHEN `Is Delinquent Loan` = 'Yes' THEN 1 ELSE 0 END)
    / NULLIF(COUNT(`Client id`), 0),
    2
  ) AS delinquent_loan_rate_pct
FROM bank;
--- Default Loan Rate ---
SELECT
  ROUND(
    100.0 * SUM(CASE WHEN `Is Default Loan` = 'Yes' THEN 1 ELSE 0 END)
    / NULLIF(COUNT(`Client id`), 0),
    2
  ) AS default_loan_rate_pct
FROM bank;
------ Loan Status-Wise Loan -----
SELECT
  `Loan Status`,
  COUNT(*) AS total_loans,
  ROUND(
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank),
    2
  ) AS loan_status_percentage
FROM bank
GROUP BY `Loan Status`
ORDER BY total_loans DESC;
----- Age Group-Wise Loan ----
SELECT
  CASE
    WHEN TIMESTAMPDIFF(YEAR, `DateOf Birth`, CURDATE()) BETWEEN 18 AND 25 THEN '18–25'
    WHEN TIMESTAMPDIFF(YEAR, `DateOf Birth`, CURDATE()) BETWEEN 26 AND 35 THEN '26–35'
    WHEN TIMESTAMPDIFF(YEAR, `DateOf Birth`, CURDATE()) BETWEEN 36 AND 45 THEN '36–45'
    WHEN TIMESTAMPDIFF(YEAR, `DateOf Birth`, CURDATE()) BETWEEN 46 AND 55 THEN '46–55'
    WHEN TIMESTAMPDIFF(YEAR, `DateOf Birth`, CURDATE()) BETWEEN 56 AND 65 THEN '56–65'
    WHEN TIMESTAMPDIFF(YEAR, `DateOf Birth`, CURDATE()) > 65 THEN '65+'
    ELSE 'Unknown'
  END AS age_group,
  COUNT(*) AS total_loans
FROM bank
GROUP BY age_group
ORDER BY total_loans DESC;
---- loan maturity ---
SELECT
  `Loan Amount`,
  `Int Rate`,
  `Term`,
  -- Assuming 'Term' represents the loan term in years
  `Loan Amount` / (12 * `Term`) AS `Monthly Payment`
FROM bank;
---- non verfied loan ---
SELECT
  `Client id`,
  `Loan Amount`,
  `Disbursement Date`,
  `Verification Status`
FROM bank
WHERE `Verification Status` IS NULL OR `Verification Status` = ''
ORDER BY `Disbursement Date` DESC
LIMIT 0, 1000;



  





















