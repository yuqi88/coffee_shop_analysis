# The Analysis
## 1. Sales & Revenue Performance
During Feburary of 2026, the coffee shop generated $159,301.80 in total revenue across 6481 orders, resulting in an average order value (AOV) of $24.58. 
### 1.1 Revenue Distribution by Time Period
#### Peak Hour Identification
![traffic distirbution over time](images/Traffic%20distribution%20over%20time.svg)
To understand how revenue is distributed throughout the day, operating hours were segmented into peak and non-peak periods based on customer demand.

Peak hours were identified by the least-squares method. Hours with observed order counts above the trendline were classified as peak periods, while all remaining hours were classified as non-peak periods. This approach identified 10 peak operating hours and 74 non-peak operating hours. Additionally, peak hours on weekends differ from weekdays according to the difference of traffic patterns.

Therefore, the peak hours are
- Weekday 08 - 09, 11 - 12, 16 - 17
- Weekend 10 - 11, 14 - 15

Figure X illustrates the hourly order distribution and the trendline used to classify peak and non-peak periods.

#### Revenue By Time
To understand when revenue is generated, sales performance was analyzed across peak and non-peak periods.

| Period   | Revenue     | Hours | Revenue per Hour |
|----------|----------   |-------|------------------|
| Non-Peak | $24,734.55  | 74    | $334.25          |
| Peak     | $134,567.25 | 10    | $13,456.73       |

The results show a substantial concentration of revenue during peak periods. Although peak hours accounted for only 10 of 84 operating hours (12%), they generated approximately 84% of total revenue. Revenue efficiency was also significantly higher during peak periods, producing over 40 times more revenue per hour than non-peak periods.

These findings indicate that overall business performance is heavily dependent on a small number of high-demand operating hours.

### 1.2 Product Revenue Contribution
To understand which menu items drive overall business performance, revenue contribution was analyzed at the product level.

|            | Product               | Revenue Contribution |
|------------| --------------------- | -------------------- |
| 1          | Americano Misto       | 10.72%               |
| 2          | Strawberry Lemonade   | 9.28%               |
| 3          | Brewed Coffee         | 8.81%               |
| 4          | Caramel Macchiato	 | 6.99%               |
| 5          | Iced Matcha Latte	 | 6.88%               |
| 6          | Iced White Mocha	     | 6.56%               |
| 7          | Iced Americano		 | 6.27%               |
| 8          | Latte			     | 5.99%               |
| 9          | Iced Latte		     | 5.71%               |
| 10         | Iced Chocolate		 | 5.22%               |
| 11         | Americano		     | 5.13%               |

These 11 products collectively account for approximately 78% of total revenue, despite the menu containing over 100 items. This indicates a strong revenue concentration within a limited set of core beverage offerings. Particularly within Americano, Latte, and flavored drink families.

| Group                  | Revenue Share |
| ---------------------- | ------------: |
| Top 5 Products         |           42% |
| Top 10 Products        |           71% |
| Top 11 Products        |           78% |
| Remaining 90+ Products |           29% |

Beyond the top group, remaining products contribute less than 2% each individually, forming a classic long-tail distribution. While individual tail products have a low relative impact, they collectively contribute nearly a quarter of total revenue, showing that menu variety plays a crucial role in supporting our core daily drivers.

### 1.3 Channel / Category Performance
#### 1.3.1 Revenue Contribution by Channel Category
To understand how customers access the business, revenue was analyzed across delivery and non-delivery channels.

| Channel Category | Revenue | Revenue Share |
| ---------------- | ------: | ------------: |
| Non-Delivery     | $89,787 |         56.4% |
| Delivery         | $69,515 |         43.6% |

While non-delivery transactions remain the primary revenue source, delivery channels contribute a substantial portion of total revenue, accounting for nearly 44% of sales.

This indicates that revenue generation is not solely dependent on in-store traffic. Delivery platforms represent an important sales channel and significantly expand customer reach beyond physical store visits.
#### 1.3.2 Channel Preference by Time of Day
Channel usage varies significantly throughout the day. During morning hours (7 AM–10 AM), non-delivery purchases account for approximately two-thirds of transactions, indicating that customers primarily visit the store or use store pickup services.

In contrast, delivery channels become the dominant purchasing method during midday hours. Between 11 AM and 1 PM, delivery transactions account for approximately 68%–76% of orders, suggesting that customers increasingly rely on delivery services during lunch periods.

This shift highlights distinct customer purchasing behaviors throughout the day, with in-store demand concentrated during morning beverage purchases and delivery demand peaking around lunchtime.
### 1.4 Key Findings
The sales and revenue analysis reveals three key patterns in business performance.

First, revenue generation is highly concentrated within a small number of peak operating hours. Although peak periods account for only 12% of operating hours, they generate approximately 84% of total revenue, making them the primary driver of overall business performance.

Second, revenue is concentrated among a relatively small group of beverage offerings. The top-performing products account for a substantial share of total revenue, while most menu items individually contribute less than 1%, indicating a long-tail product distribution.

Finally, customers utilize both delivery and non-delivery channels extensively, with purchasing preferences varying throughout the day. Non-delivery channels dominate during morning hours, while delivery services become the primary purchasing method during lunchtime periods.

While these findings explain where and when revenue is generated, they do not explain how customers purchase products. The next section uses market basket analysis to examine purchasing patterns, product relationships, and basket composition to better understand the customer behaviors driving these revenue outcomes.

## 2. Market Basket Analysis
## 2.1 Basket Structure
To understand customer purchasing behavior, I analyzed transaction baskets by size and product composition.

| Basket Composition (size) | Orders |
| ------------------------- | -----: | 
| Single-item               | 8.04%  | 
| Multi-item                | 91.96% |

![Basket Composition by product](images/Basket%20Composition.svg)

### Insights:
**Beverages Drive Traffic**: Beverages appear in 96% of all transactions, which drive the vast majority of orders. Food-only purchases are rare (4%), suggesting that customers view the brand primarily as a beverage destination rather than a dining option.  
**Multi-Item Dominance**: Customers rarely purchase a single product, with roughly 92% of orders consisting of multiple items. Combined with an average basket size of 4.79 items, this indicates strong product attachment and multi-item ordering habits per visit.

Overall, the results suggest that customers typically purchase multiple products per transaction, with beverages serving as the foundation of most baskets. This purchasing behavior creates opportunities to further increase basket value through product recommendations and food attachment strategies.

## 2.2 Basket Size Contribution
Do larger baskets contribute disproportionately to revenue?
| Basket Size | Revenue Share |
| ----------- | ------------: |
| 1 item      | 1.67%         |
| 2 items     | 4.55%         |
| 3+ items    | 93.78%        |

Now you understand whether growth comes from:

- More customers
- Larger baskets
This is valuable.

## 2.3 Product Affinity Analysis
To understand how products are purchased together within a single transaction, an association rule analysis was conducted using support, confidence, and lift metrics.

#### Top Product Associations

| Antecedent      | Consequent          | Support (%) | Confidence (%) | Lift |
| --------------- | ------------------- | ----------: | -------------: | ---: |
| Americano       | Brewed Coffee       |        1.68 |          16.22 | 9.65 |
| Americano Misto | Brewed Coffee       |        2.79 |          14.40 | 5.16 |
| Brewed Coffee   | Strawberry Lemonade |        2.05 |           9.55 | 4.66 |
| Brewed Coffee   | Iced Matcha Latte   |        1.90 |           8.83 | 4.65 |
| Brewed Coffee   | Latte               |        1.76 |           8.18 | 4.65 |
| Americano Misto | Strawberry Lemonade |        1.70 |           8.75 | 5.15 |
| Americano Misto | Iced Americano      |        1.68 |           8.67 | 5.16 |
| Americano Misto | Iced White Mocha    |        1.56 |           8.04 | 5.15 |
| Americano Misto | Iced Chocolate      |        1.54 |           7.96 | 5.17 |
| Brewed Coffee   | Iced Latte          |        1.53 |           7.11 | 4.65 |

#### Key Patterns

The results show strong evidence of **structured product affinity around a small set of core beverages**, particularly Americano, Americano Misto, and Brewed Coffee. These items act as “anchor products,” frequently appearing in association with a wide range of secondary beverages.

Across all rules, lift values are consistently above 4, with some associations reaching above 9. This indicates that these product pairings occur significantly more often than would be expected under independent purchasing behavior, confirming the presence of meaningful cross-product relationships.

A second clear pattern is the clustering of beverage-to-beverage combinations rather than cross-category bundling. Core coffee products are commonly associated with iced espresso variations and flavored drinks such as Strawberry Lemonade, Latte, and Matcha-based beverages. This suggests that customers tend to diversify drink types within a single order rather than combining drinks with food items.

Overall, the analysis indicates that customer purchasing behavior is driven by a small number of high-affinity anchor products, with consistently strong associative relationships across beverage categories. These insights provide opportunities for targeted bundling and recommendation strategies, particularly around Americano- and Brewed Coffee-based products.


## 2.4 Cross-Sell Opportunity
### Overview
Add-on analysis was conducted to understand how frequently customers enhance their primary beverage purchases with additional food items, and which conditions are most associated with higher basket expansion.

| Metric              | Value  |
| ------------------- | -----: |
| Drink Orders        | 6,221  |
| Drink + Food Orders | 1,036  |
| Food Attach Rate    | 16.65% |

Overall, 16.65% of drink orders include at least one food item, indicating more than 80% of the beverage customers do not extend their purchase beyond drinks alone. This suggests a significant opportunity for improving cross-selling performance.

### Upselling Opportunities
To identify upselling opportunities, food attachment rates across different drink categories were analyzed.

Although several beverages exhibit higher attachment rates, many of these products have relatively low order volumes and therefore present limited business impact. For example, Matcha Latte with food attachment rate at a higher 26%, but it only has a 56 order volume.

|            | Drink Category      | Food Attachment Rate | Order Volume |
|------------| ------------------- | -------------------: | -----------: |
|          1 | Brewed Coffee       |                  16% |        1,393 |
|          2 | Americano Misto     |                  13% |        1,257 |
|          3 | Strawberry Lemonade |                  15% |        1,030 |
|          4 | Caramel Macchiato   |                  15% |          702 |
|          5 | Iced Chocolate      |                  14% |          669 |
|          6 | Iced Matcha Latte   |                  13% |          718 |
|          7 | Americano           |                  13% |          672 |
|          8 | Latte               |                  12% |          704 |
|          9 | Iced Americano      |                  12% |          696 |
|         10 | Iced Latte          |                  12% |          636 |
|         11 | Iced White Mocha    |                  11% |          651 |


In contrast, the beverages above consist of both strong food attachment rate and substantial transaction volume, serving as the top 11 impactful drinks to food sales.

### Key Insights

This analysis reveals that the top 11 food-sales driving beverages generate at least one food purchase is made every 4 to 5 orders. Additionally, these drinks are also the same as the top 11 revenue contributors from [1.2 Product Revenue Contribution](#1.2-Product-Revenue-Contribution).

These findings suggest that cross-selling initiatives should focus the top 11 impactful drinks to food sales in the above table. Product recommendations, bundle promotions, and checkout prompts centered around these beverages are likely to provide the greatest opportunity for increasing basket size and revenue.

## 2.5 Key Findings
# Limitations & Assumptions
### Future Enhancements
Include the logging of shipment time and customer satisfaction survey.