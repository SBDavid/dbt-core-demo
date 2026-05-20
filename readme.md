# 资源

- installation：[https://docs.getdbt.com/docs/local/install-dbt?version=1.13#installation](https://docs.getdbt.com/docs/local/install-dbt?version=1.13#installation)
- https://docs.getdbt.com/docs/local/install-dbt?version=1.13#create-a-project

# 环境配置
## python
- 检查 python 环境：`python3 --version`
- 检查 pip 环境：`pip3 --version`
- 配置虚拟环境：
  - `python3 -m venv env`
  - `source env/bin/activate`
  - 检查 python 的路径：`which python`
  - 运行：`env/bin/python`
  - 关闭环境：`deactivate`

## 安装 dbt 适配器
安装适配器会自动安装 dbt-core。
安装之前可以先关闭代理。
可以在虚拟环境中关闭，`env/bin/activate`

- 安装: `python -m pip install dbt-duckdb`
- 安装：`python -m pip install dbt-postgres`
- 升级：`python -m pip install --upgrade dbt-duckdb`
- 指定版本：`python -m pip install --upgrade dbt-core==1.9`

## 数据库安装
- `Postgres.app`
  - 默认端口：5432
  - 用户名：jiawei.tang
  - 修改密码：`jiawei.tang" WITH PASSWORD '123456'`
- 新建数据库：`CREATE DATABASE my_new_db;`

# dbt 项目
## 构建项目
- init: `dbt init my_project`
- `cd my_project`
此时，已经有了基本陪文件结构和配置 dbt_project.yml

## 数据库连接
- 数据库连接配置文件
  - 全局配置（默认）：~/.dbt/profiles.yml
  - 本地配置：xxx/my_project/profiles.yml
```yml
jaffle_shop:
  outputs:
    dev:
      type: duckdb
      path: dev.duckdb # 使用了相对路径，相对于 dbt 运行的目录
      threads: 1

    prod:
      type: duckdb
      path: prod.duckdb
      threads: 4

  target: dev # 默认的使用 dev
```
  - 测试链接：`dbt debug`

## dbt 命令
- dbt run：编译 sql ，更新表
- dbt test：测试，models/schema.yml 中的描述来测试
```yml
version: 2

models:
  - name: customers
    description: One record per customer
    columns:
      - name: customer_id
        description: Primary key
        data_tests:
          - unique
          - not_null
      - name: first_order_date
        description: NULL when a customer has not yet placed an order.

  - name: stg_customers
    description: This model cleans up customer data
    columns:
      - name: customer_id
        description: Primary key
        data_tests:
          - unique
          - not_null

  - name: stg_orders
    description: This model cleans up order data
    columns:
      - name: order_id
        description: Primary key
        data_tests:
          - unique
          - not_null
      - name: status
        data_tests:
          - accepted_values:
              arguments: # available in v1.10.5 and higher. Older versions can set the <argument_name> as the top-level property.
                values: ['placed', 'shipped', 'completed', 'return_pending', 'returned']
      - name: customer_id
        data_tests:
          - not_null
          - relationships:
              arguments:
                to: ref('stg_customers')
                field: customer_id
```