/* Q1: What is the total freight revenue generated to date?
Business Impact: Shows overall logistics revenue and business health.
*/
SELECT SUM(FreightCost_INR) AS Total_Revenue_INR
FROM Shipments;


/* Q2: Who are the top 5 clients by total freight revenue?
Business Impact: Identifies high value clients for retention, upsell, and credit risk assessment.
*/
SELECT s.ClientID, c.ClientName, SUM(s.FreightCost_INR) AS Revenue
FROM Shipments s
JOIN Clients c ON s.ClientID = c.ClientID
GROUP BY s.ClientID, c.ClientName
ORDER BY Revenue DESC
LIMIT 5;


/* Q3: How much revenue does each client region generate?
Business Impact: Reveals top performing regions and supports expansion or partnership decisions.
*/
SELECT c.ClientRegion, SUM(s.FreightCost_INR) AS Revenue
FROM Shipments s
JOIN Clients c ON s.ClientID = c.ClientID
GROUP BY c.ClientRegion
ORDER BY Revenue DESC;


/* Q4: What is the average freight per active shipment (excluding cancellations)?
Business Impact: Helps in pricing strategy and forecasting expected revenue per shipment.
*/
SELECT ROUND(AVG(FreightCost_INR), 2) AS Avg_Freight_Per_Shipment
FROM Shipments
WHERE Status <> 'Cancelled';


/* Q5: What are the shipment counts and total revenue by transport mode?
Business Impact: Highlights which transport modes drive the most business guides investment and partnerships.
*/
SELECT Mode, COUNT(*) AS Num_Shipments, SUM(FreightCost_INR) AS Total_Revenue
FROM Shipments
GROUP BY Mode
ORDER BY Num_Shipments DESC;


/* Q6: What is the ontime vs delayed vs cancelled shipment performance?
Business Impact: Measures operational reliability and customer experience for performance improvement.
*/
SELECT
  Status,
  COUNT(*) AS Count,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM Shipments), 2) AS Percent
FROM Shipments
GROUP BY Status;


/* Q7: How many shipments were cancelled and what percentage of total does this represent?
Business Impact: High cancellations indicate inefficiencies, customer dissatisfaction, or process issues.
*/
SELECT COUNT(*) AS Cancelled_Count,
       ROUND(100.0 * SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Cancelled_Percent
FROM Shipments;


/* Q8: How does domestic revenue compare with international shipments?
Business Impact: Reveals contribution of international business to total revenue and informs resource planning.
*/
SELECT IsInternational, SUM(FreightCost_INR) AS Revenue, COUNT(*) AS Num_Shipments
FROM Shipments
GROUP BY IsInternational;


/* Q9: What is the average transit time (in days) by mode of transport?
Business Impact: Helps in setting SLAs and optimizing mode selection for urgent deliveries.
*/
SELECT Mode, ROUND(AVG(DATEDIFF(DeliveryDate, PickupDate)), 2) AS Avg_Transit_Days
FROM Shipments
WHERE Status <> 'Cancelled'
GROUP BY Mode
ORDER BY Avg_Transit_Days;


/* Q10: Which 10 vehicles handled the most shipments and revenue?
Business Impact: Identifies top performing fleet assets for optimization and maintenance planning.
*/
SELECT s.VehicleID, v.VehicleType, v.CarrierName,
       COUNT(*) AS Num_Shipments,
       SUM(s.FreightCost_INR) AS Revenue
FROM Shipments s
JOIN Vehicles v ON s.VehicleID = v.VehicleID
GROUP BY s.VehicleID, v.VehicleType, v.CarrierName
ORDER BY Num_Shipments DESC
LIMIT 10;


/* Q11: Which vehicles generate the highest revenue per maintenance cost?
Business Impact: Assesses vehicle cost efficiency to guide capital allocation and replacements.
*/
SELECT u.VehicleID,
       u.Num_Shipments,
       u.Revenue,
       v.MaintenanceCost_INR,
       ROUND(u.Revenue / NULLIF(v.MaintenanceCost_INR, 0), 2) AS Revenue_per_Maint
FROM (
  SELECT VehicleID, COUNT(*) AS Num_Shipments, SUM(FreightCost_INR) AS Revenue
  FROM Shipments
  GROUP BY VehicleID
) u
JOIN Vehicles v ON u.VehicleID = v.VehicleID
ORDER BY Revenue_per_Maint DESC
LIMIT 10;


/* Q12: Which clients are close to or exceeding their credit limit?
Business Impact: Detects potential financial risk and credit exposure for proactive management.
*/
SELECT c.ClientID, c.ClientName, c.CreditLimit_INR,
       COALESCE(SUM(s.FreightCost_INR), 0) AS TotalSpend,
       ROUND(100.0 * COALESCE(SUM(s.FreightCost_INR), 0) / NULLIF(c.CreditLimit_INR, 0), 2) AS Percent_of_Credit
FROM Clients c
LEFT JOIN Shipments s ON c.ClientID = s.ClientID
GROUP BY c.ClientID, c.ClientName, c.CreditLimit_INR
ORDER BY Percent_of_Credit DESC
LIMIT 10;


/* Q13: What are the monthly revenue trends?
Business Impact: Identifies seasonal demand patterns, revenue growth, and capacity forecasting.
*/
SELECT DATE_FORMAT(PickupDate, '%Y-%m') AS Month,
       SUM(FreightCost_INR) AS Revenue,
       COUNT(*) AS Num_Shipments
FROM Shipments
GROUP BY DATE_FORMAT(PickupDate, '%Y-%m')
ORDER BY Month;


/* Q14: Which origin destination routes generate the most revenue?
Business Impact: Reveals top performing routes for route optimization and partnership negotiations.
*/
SELECT OriginCity, DestinationCity, COUNT(*) AS Num_Shipments, SUM(FreightCost_INR) AS Revenue
FROM Shipments
GROUP BY OriginCity, DestinationCity
ORDER BY Revenue DESC
LIMIT 10;


/*
End of GEM Logistics SQL Business Insights Project.
This dataset is synthetic and demonstrates analytical and business acumen
in logistics performance, fleet utilization, and client profitability.
*/
