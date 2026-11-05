# Store Sales Analysis in PostgreSQL

A small data analysis project written entirely in SQL. It models a made-up
online store and answers four business questions about its first six
months of sales (January to June 2026).

## Talking points

1. **Repeat customers drive the business.** 8 of the 11 paying customers
   ordered more than once, and they brought in 87% of revenue. A repeat
   customer is worth about $208, versus $80 for a one-time buyer, so
   keeping customers matters more than finding new ones.
2. **Two categories carry half the revenue.** Electronics (27%) and Sports
   (25%) lead, mostly thanks to two products: Wireless Earbuds ($300) and
   Running Shoes ($285). Clothing is the weakest category at 13%.
3. **Revenue is flat, not growing.** Monthly revenue stays between about
   $250 and $365 with no clear upward trend, and June was the lowest month.

## SQL skills shown

- Table design with primary keys, foreign keys and CHECK constraints
- Joins across five tables, wrapped in a reusable view
- GROUP BY aggregates and date bucketing with `DATE_TRUNC`
- Window functions: `LAG` for month-over-month change, `RANK` for top
  products, and `SUM() OVER ()` for percent of total
- A CTE with `CASE` to segment customers

## The data

| Table         | What it holds                              |
|---------------|--------------------------------------------|
| `customers`   | 12 customers in 8 countries                |
| `categories`  | 5 product groups                           |
| `products`    | 15 products and their list price           |
| `orders`      | 26 orders, 3 of them cancelled             |
| `order_items` | 42 order lines with quantity and price     |

```
customers 1──* orders 1──* order_items *──1 products *──1 categories
```

## Files

- `sql/01_setup.sql` creates the tables and loads the sample data
- `sql/02_analysis.sql` answers the four questions

## How to run it

With PostgreSQL installed:

```
createdb store_sales
psql -d store_sales -f sql/01_setup.sql
psql -d store_sales -f sql/02_analysis.sql
```

The setup script drops and rebuilds the tables, so it is safe to rerun.
