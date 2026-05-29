# 资源

- installation：[https://docs.getdbt.com/docs/local/install-dbt?version=1.13#installation](https://docs.getdbt.com/docs/local/install-dbt?version=1.13#installation)
- https://docs.getdbt.com/docs/local/install-dbt?version=1.13#create-a-project
- https://docs.getdbt.com/guides/manual-install?step=1&version=1.13

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
- 新建数据库：`CREATE DATABASE financial_data;`

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

financial_data: # financial_data/dbt_project.yml 中 profile: financial_data
  outputs:
    dev:
      type: postgres
      host: localhost
      port: 5432
      user: jiaweitang
      password: '123456' # 与上文 Postgres.app 中设置的密码一致
      dbname: financial_data
      schema: dbt-dev
      threads: 1

  target: dev

```
  - 测试链接：`dbt debug`

## dbt 命令

### 导入数据
- 导入 csv：`dbt seed --select raw_naaim`

### 构建模型（中间清洗层）
- stg_naaim 模型：完成初步数据转换
  - 转换日期字段
  - 删除空数据
  - 指定字段的数据类型

### 编写文档和测试（中间清洗层）
- schema.yml：
  - 对重要的字段做出说明
  - 对重要的字段编写测试
- 运行测试
  - `cd xxx/dbt-core-demo/financial_data`
  - `dbt test --select stg_naaim 2>&1`

### 构建事实表的模型
- fct_naaim.sql
  - 为环比数据添加基础数据：prior_naaim_number、naaim_wow_change

### 编译 sql ，更新表
- `dbt run --select stg_naaim          # 只跑 staging`
- `dbt run --select +fct_naaim         # 跑事实表及其上游`
- `dbt run --select +naaim_percentile_5y`