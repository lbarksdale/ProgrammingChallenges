/*
 Created by Levi Barksdale in Sept 2023 for the PMG Data Analytics track programming challenge

 This SQL file contains several queries that answer questions posed within the README.md file in the same folder.
 I used the SQLite dialect to answer each query.

 A brief explanation of each query is given before the actual query.
 */


--Problem 1
--Returns the sum of impressions by day
--To me, the data output is not useful without some context, so I sorted by date and showed that in the output
SELECT
    date, SUM(impressions)
FROM
    marketing_data
GROUP BY
    date
ORDER BY
    date;


--Problem 2
--Gets the top 3 revenue generating states and outputs what state it is, along with the revenue generated
SELECT
    state, sum(revenue)         -- Remove the sum(revenue) to simply get the list of states
FROM
    website_revenue
GROUP BY
    state
ORDER BY
    sum(revenue)
DESC limit 3;
--Running this query reveals that Ohio was the 3rd top revenue generating state, with a revenue of 37577


-- Problem 3
-- Shows cost, clicks, impressions, and revenue of all campaigns
SELECT c.name, m.total_cost, m.total_impressions, m.total_clicks, w.total_revenue
FROM campaign_info AS c
INNER JOIN  --Subquery to get the appropriate data from marketing_data table
    (SELECT sum(cost) AS total_cost,
            sum(impressions) AS total_impressions,
            sum(clicks) AS total_clicks,
            campaign_id
     FROM marketing_data
     GROUP BY campaign_id
     ) AS m
ON c.id = m.campaign_id
INNER JOIN  --Subquery to get appropriate data from website_revenue table
    (SELECT sum(revenue) AS total_revenue,
            campaign_id
     FROM website_revenue
     GROUP BY campaign_id
     ) AS w
ON c.id = w.campaign_id
GROUP BY c.name;


-- Query to get the number of conversions from Campaign5 by state
-- I used the geographic data in the marketing_data table, as it was specific up to state. Additionally, the data entries
-- in the website_revenue table, which does include state, do not match the entries in the marketing_data table, which
-- lists number of conversions.
SELECT m.geo, sum(m.conversions)
FROM (SELECT * FROM campaign_info WHERE name='Campaign5') AS c
INNER JOIN
    (SELECT campaign_id, conversions, geo FROM marketing_data) AS m
ON m.campaign_id = c.id
GROUP BY m.geo;

-- According to this query, Georgia generated the most conversions.

/*
 This is actually raising some concerns for me - although the marketing_data table only has information from Georgia
 and Ohio, I notice that in the website_revenue table there is revenue being generated from New York, despite there
 being no recorded conversions in New York. This means that there is likely data missing from the dataset, or otherwise
 a complication that I am missing.

 In fact, despite both the marketing_data and website_revenue tables having 30 rows, these rows do not match each other.
 Dates are different, as are the number of entries associated with each campaign.
 */


-- Problem 5
/*
 There are numerous ways to quantify efficiency, depending on the goals of the campaign. If the campaign goal is simply
 to increase visibility of a product, but not necessarily make more sales, then efficiency could be measured by
 impressions per dollar, or by conversion rate. If the campaign goal is to make the most money, then efficiency could
 be determined by overall rate of return on investment (i.e. the ratio of how much was spent to how much was made). This
 is the metric I elected to use to determine efficiency.

 I think that Campaign 5 was actually the most efficient. While it did not have the most conversions (in fact it had
 the least), it returned the greatest amount of revenue when compared to the initial cost. Quality of conversions counts
 here, not necessarily quantity.

 That being said, Campaigns 2 and 4 were also quite good, as each had a high rate of conversions per dollar spent, and
 both had a very good return on investment.
 */


--This query shows the total conversions, cost, and revenue for each campaign, along with the number of conversions
--per cost dollar and the revenue generated per cost dollar. Revenue generated per cost is what was used to determine
--efficiency
SELECT
    c.name,
    m.total_conversions,
    m.total_cost,
    w.total_revenue,
    m.total_conversions / m.total_cost AS conversions_per_dollar,
    w.total_revenue / m.total_cost AS return_per_dollar
FROM campaign_info AS c
INNER JOIN
(SELECT campaign_id,
        sum(conversions) AS total_conversions,
        sum(cost) AS total_cost
    FROM marketing_data
    GROUP BY campaign_id) AS m
ON m.campaign_id = c.id
INNER JOIN
    (SELECT campaign_id,
            sum(revenue) AS total_revenue
     FROM website_revenue
     GROUP BY campaign_id) AS w
ON w.campaign_id = c.id
GROUP BY c.name;


--Bonus Question: Problem 6

--Showcases the best day of the week to run ads
--Note: substr(date, 1, 10) extracts just the date from the datetime value,
--and the strftime function pulls the day of the week from that.
SELECT
    case cast (strftime('%w', substr(date, 1, 10)) as integer)
        when 0 then 'Sunday'
        when 1 then 'Monday'
        when 2 then 'Tuesday'
        when 3 then 'Wednesday'
        when 4 then 'Thursday'
        when 5 then 'Friday'
        else 'Saturday'
           end as weekday,
    sum(impressions) / sum(cost) AS impression_efficiency,
    sum(clicks) / sum(cost) AS click_efficiency,
    sum(conversions) / sum(cost) AS conversion_efficiency
FROM marketing_data GROUP BY strftime('%w', substr(date, 1, 10));

/*
 Based on this query, the best day to run ads is Wednesday, followed closely by Friday. On Wednesday, the number of
 clicks per advertising dollar spent is maximized, as is the number of conversions per advertising dollar. Additionally,
 the impression rate is almost peak on this day.

 It should be noted that because there is no data present for Tuesday, it is possible that Tuesday is a better day to
 run an advertisement.
 */