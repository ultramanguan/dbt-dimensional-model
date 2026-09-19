## Part 5: Create the fact table

After we have created all required dimension tables, we can now create the fact table for `fct_sales`.

### Step 1: Create model files

Let's create the new dbt model files that will contain our transformation code. Under [adventureworks/models/marts](../adventureworks/models/marts), create two files:

- `fct_sales.sql` : This file will contain our SQL transformation code.
- `fct_sales.yml` : This file will contain our documentation and tests for `fct_sales` .

```
adventureworks/models/
└── marts
    ├── fct_sales.sql
    ├── fct_sales.yml
```

### Step 2: Fetch data from the upstream staging models

To answer the business questions, we need columns from both `stg_sales__salesorderheader` and `stg_sales__salesorderdetail`. Let's reflect that in `fct_sales.sql` :

```sql
with stg_salesorderheader as (
    select
        sales_order_id,
        customer_id,
        credit_card_id,
        ship_to_address_id,
        order_status,
        order_date
    from {{ ref('stg_sales__salesorderheader') }}
),

stg_salesorderdetail as (
    select
        sales_order_id,
        sales_order_detail_id,
        product_id,
        order_qty,
        unit_price,
        unit_price * order_qty as revenue
    from {{ ref('stg_sales__salesorderdetail') }}
)

...
```

### Step 3: Perform joins

The grain of the `fct_sales` table is one record in the SalesOrderDetail table, which describes the quantity of a product within a SalesOrderHeader. So we perform a join between `stg_salesorderheader` and `stg_salesorderdetail` to achieve that grain.

```sql
...

select
    ...
from stg_salesorderdetail
inner join stg_salesorderheader on stg_salesorderdetail.sales_order_id = stg_salesorderheader.sales_order_id
```

### Step 4: Create the surrogate key

Next, we create the surrogate key to uniquely identify each row in the fact table. Each row in the `fct_sales` table can be uniquely identified by the `sales_order_id` and the `sales_order_detail_id` which is why we use both columns in the `generate_surrogate_key()` macro.

```sql
...

select
    {{ dbt_utils.generate_surrogate_key(['stg_salesorderdetail.sales_order_id', 'sales_order_detail_id']) }} as sales_key,
    ...
from stg_salesorderdetail
inner join stg_salesorderheader on stg_salesorderdetail.sales_order_id = stg_salesorderheader.sales_order_id
```

### Step 5: Select fact table columns

You can now select the fact table columns that will help us answer the business questions identified earlier. We want to be able to calculate the amount of revenue, and therefore we include a column revenue per sales order detail which is calculated by `unit_price * order_qty as revenue` .

```sql
...

select
    {{ dbt_utils.generate_surrogate_key(['stg_salesorderdetail.sales_order_id', 'sales_order_detail_id']) }} as sales_key,
    stg_salesorderdetail.sales_order_id,
    stg_salesorderdetail.sales_order_detail_id,
    stg_salesorderdetail.unit_price,
    stg_salesorderdetail.order_qty,
    stg_salesorderdetail.revenue
from stg_salesorderdetail
inner join stg_salesorderheader on stg_salesorderdetail.sales_order_id = stg_salesorderheader.sales_order_id
```

### Step 6: Create foreign surrogate keys

We want to be able to slice and dice our fact table against the dimension tables we have created in the earlier step. So we need to create the foreign surrogate keys that will be used to join the fact table back to the dimension tables.

We achieve this by applying the `generate_surrogate_key()` macro to the same unique id columns that we had previously used when generating the surrogate keys in the dimension tables.

```sql
...

select
    {{ dbt_utils.generate_surrogate_key(['stg_salesorderdetail.sales_order_id', 'sales_order_detail_id']) }} as sales_key,
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} as product_key,
    {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_key,
    {{ dbt_utils.generate_surrogate_key(['credit_card_id']) }} as creditcard_key,
    {{ dbt_utils.generate_surrogate_key(['ship_to_address_id']) }} as ship_address_key,
    {{ dbt_utils.generate_surrogate_key(['order_status']) }} as order_status_key,
    {{ dbt_utils.generate_surrogate_key(['order_date']) }} as order_date_key,
    stg_salesorderdetail.sales_order_id,
    stg_salesorderdetail.sales_order_detail_id,
    stg_salesorderdetail.unit_price,
    stg_salesorderdetail.order_qty,
    stg_salesorderdetail.revenue
from stg_salesorderdetail
inner join stg_salesorderheader on stg_salesorderdetail.sales_order_id = stg_salesorderheader.sales_order_id
```

### Step 7: Choose a materialization type

You may choose from one of the following materialization types supported by dbt:

- View
- Table
- Incremental

It is common for fact tables to be materialized as `incremental` or `table` depending on the data volume size. [As a rule of thumb](https://docs.getdbt.com/docs/build/incremental-models#when-should-i-use-an-incremental-model), if you are transforming millions or billions of rows, then you should start using the `incremental` materialization. In this example, we have chosen to go with `table` for simplicity.

### Step 8: Create model documentation and tests

Alongside our `fct_sales.sql` model, we can populate the corresponding `fct_sales.yml` file to document and test our model.

```yaml
version: 2

models:
  - name: fct_sales
    columns:

      - name: sales_key
        description: The surrogate key of the fct sales
        data_tests:
          - not_null
          - unique

      - name: product_key
        description: The foreign key of the product
        data_tests:
          - not_null

      - name: customer_key
        description: The foreign key of the customer
        data_tests:
          - not_null

      ...

      - name: order_qty
        description: The quantity of the product
        data_tests:
          - not_null

      - name: revenue
        description: The revenue obtained by multiplying unit_price and order_qty
```

### Step 9: Build dbt models

Execute the [dbt run](https://docs.getdbt.com/reference/commands/run) and [dbt test](https://docs.getdbt.com/reference/commands/run) commands to run and test your dbt models:

```
dbt run && dbt test
```

Great work, you have successfully created your very first fact and dimension tables! Our dimensional model is now complete!! 🎉

[&laquo; Previous](part04b-slowly-changing-dimensions.md) [Next &raquo;](part06-document-model.md)
