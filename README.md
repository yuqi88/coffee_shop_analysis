# Findings & Visualizations
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

|  | Product               | Revenue Contribution |
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
### 2.1 Basket Structure
### 2.2 Basket Size Contribution
### 2.3 Product Affinity Analysis
### 2.4 Cross-Sell Opportunity
### 2.5 Light Customer Segmenation
### 2.6 Key Findings

