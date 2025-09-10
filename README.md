# Wise Funnel dbt Project

## Purpose
This project demonstrates a full medallion architecture (staging → curated → metrics) for analyzing Wise transfer funnel performance.  
It is designed to:
- Transform raw event logs into analytics-ready tables in Snowflake.
- Calculate conversion rates, drop-off rates, and anomalies at multiple levels (experience, platform, region).
- Support reporting and visualization in tools like Power BI.

- `stage/` → **Bronze layer**: Cleaned and standardized source data.
- `curated/` → **Silver layer**: Joined and pivoted tables, applying business logic.
- `metrics/` → **Gold layer**: Aggregated KPIs and reporting views.

### Example Funnel Metrics Output

| experience | platform | region  | created_transfers | funded_transfers | completed_transfers | created_to_funded_pct | created_to_funded_dropoff_pct | funded_to_completed_pct | funded_to_completed_dropoff_pct |
|------------|----------|---------|-------------------|-------------------|---------------------|-----------------------|--------------------------------|-------------------------|----------------------------------|
| Existing   | Android  | Europe  | 6489              | 4284              | 2733                | 66.02                 | 33.98                          | 63.8                    | 36.2                             |
| New        | Android  | Europe  | 3509              | 70                | 62                  | 1.99                  | 98.01                          | 88.57                   | 11.43                            |



## Project Structure

- `models/`
  - `sources/`: Source definitions ([source.yaml](models/sources/source.yaml))
  - `stage/`: Staging models ([stg_wise_funnel_events.sql](models/stage/stg_wise_funnel_events.sql))
  - `curated/`: Curated models for funnel events ([wise_funnel_events_final.sql](models/curated/wise_funnel_events_final.sql), etc.)
  - `metrics/`: Metrics and reporting views ([metrics_vw.sql](models/metrics/metrics_vw.sql))
- `macros/`: Custom dbt macros for metrics ([metrics_utils.sql](macros/metrics_utils.sql))
- `scripts/`: Helper scripts for data loading ([load_csv_stage.py](scripts/load_csv_stage.py)) Files Can placed in source_files (Local Dir in .env) folder
- `analyses/`, `seeds/`, `snapshots/`, `tests/`: Standard dbt directories

## Getting Started

### Prerequisites

- Python 3.7+
- dbt (core or dbt-snowflake)
- Snowflake account
- [dotenv](https://pypi.org/project/python-dotenv/) (for scripts)

### Setup

1. **Install dependencies:**
   ```sh
   pip install dbt-snowflake python-dotenv
   ```

2. **Configure your Snowflake profile:**
   Edit your `~/.dbt/profiles.yml` or use environment variables as required.

3. **Set up environment variables:**
   Create a `.env` file with Snowflake credentials and parameters for the loader script. Example:
   ```
   SF_ACCOUNT=your_account
   SF_USER=your_user
   SF_PASSWORD=your_password
   SF_ROLE=your_role
   SF_WAREHOUSE=your_warehouse
   SF_DATABASE=wise_db
   SF_SCHEMA=wise_schema
   SF_STAGE=your_stage
   SF_FILE_FORMAT=your_file_format
   LOCAL_DIR=path/to/csvs
   TARGET_TABLE=STG_WISE_FUNNEL_EVENTS
   CSV_FILE_NAME=your_file.csv
   ```

4. ## Database Setup Commands

    Below are the key commands (DDL, DML, and Snowflake stage operations) used in this project.
    
    ### 1. Create Stage

    Used to create an internal Snowflake stage for uploading raw CSV files.

    ```sql
    CREATE STAGE wise_db.wise_schema.funnel_stage;
    ```

    **Purpose:**  
    Stores the raw CSV file before it is loaded into the staging table.

    ---

    ### 2. Remove All Files from Stage

    Removes all files from the internal stage.

    ```sql
    REMOVE @wise_db.wise_schema.funnel_stage;
    ```

    **Purpose:**  
    Clears the stage to ensure old files do not interfere with new loads.

    ---

    ### 3. Truncate Staging Table

    Clears all data from the staging table while keeping its structure intact.

    ```sql
    TRUNCATE TABLE wise_db.wise_schema.stg_wise_funnel_events;
    ```

    **Purpose:**  
    Ensures the staging table is empty before reloading fresh data.

    ---

    ### 4. Create Staging Table

    Defines the schema for the raw data loaded from the CSV file.

    ```sql
    CREATE TABLE wise_db.wise_schema.stg_wise_funnel_events (
        event_name STRING,
        dt STRING,
        user_id STRING,
        region STRING,
        platform STRING,
        experience STRING
    );
    ```

    **Purpose:**  
    Defines the structure for loading and staging raw funnel event

5. **Load data (optional):**
   Use the provided script to upload a CSV to Snowflake:
   ```sh
   python scripts/load_csv_stage.py
   ```

### Running dbt

- Build all models:
  ```sh
  dbt run
  ```
- Run tests:
  ```sh
  dbt test
  ```
- View documentation:
  ```sh
  dbt docs generate && dbt docs serve
  ```

## Key Models

- [`stg_wise_funnel_events`](models/stage/stg_wise_funnel_events.sql): Stages raw funnel events.
- [`wise_funnel_events_pivoted`](models/curated/wise_funnel_events_pivoted.sql): Pivots events into transfer steps.
- [`wise_funnel_events_final`](models/curated/wise_funnel_events_final.sql): Final curated table.
- [`wise_funnel_events_metrics`](models/curated/wise_funnel_events_metrics.sql): Adds metrics and status.
- [`metrics_vw`](models/metrics/metrics_vw.sql): Aggregated funnel metrics.

## Custom Macros

- [`metrics_utils.sql`](macros/metrics_utils.sql): Percent and drop-off calculation helpers.

## Resources

- [dbt Documentation](https://docs.getdbt.com/docs/introduction)
- [dbt Discourse](https://discourse.getdbt.com/)
- [dbt Community](https://getdbt.com/community)
- [dbt Events](https://events.getdbt.com)
- [dbt Blog](https://blog.getdbt.com/)

---
*Project