# Moduele to load a local CSV file into a Snowflake table via a Snowflake stage.
# Prerequisites:
#   1. A Snowflake table to load data into (TARGET_TABLE)
#   2. A Snowflake stage (STAGE) and file format (FILE_FORMAT) - will be created if not exist
#   3. A local CSV file to upload (LOCAL_DIR + CSV_FILE_NAME)
#   4. A .env file with Snowflake connection details and other parameters

import os
from dotenv import load_dotenv
import snowflake.connector as sf

load_dotenv()

# Load configuration from environment variables
ACCOUNT      = os.getenv("SF_ACCOUNT")
USER         = os.getenv("SF_USER")
PASSWORD     = os.getenv("SF_PASSWORD")
ROLE         = os.getenv("SF_ROLE")
WAREHOUSE    = os.getenv("SF_WAREHOUSE")
DATABASE     = os.getenv("SF_DATABASE")
SCHEMA       = os.getenv("SF_SCHEMA")

STAGE        = os.getenv("SF_STAGE")
FILE_FORMAT  = os.getenv("SF_FILE_FORMAT")
LOCAL_DIR    = os.getenv("LOCAL_DIR")
TARGET_TABLE = os.getenv("TARGET_TABLE")
CSV_FILE_NAME = os.getenv("CSV_FILE_NAME")

# Expected columns in the target table
COLUMNS = "(event_name, dt, user_id, region, platform, experience)"

def fail(msg):
    raise RuntimeError(msg)


if not CSV_FILE_NAME:
    fail("CSV_FILE_NAME missing in .env")
if not LOCAL_DIR or not os.path.isdir(LOCAL_DIR):
    fail(f"LOCAL_DIR not found or invalid: {LOCAL_DIR}")

local_path = os.path.join(LOCAL_DIR, CSV_FILE_NAME)
if not os.path.isfile(local_path):
    fail(f"File does not exist: {local_path}")


local_path = local_path.replace("\\", "/")

print("Connecting to Snowflake...")
cnx = sf.connect(
    account=ACCOUNT,
    user=USER,
    password=PASSWORD,
    role=ROLE,
    warehouse=WAREHOUSE,
    database=DATABASE,
    schema=SCHEMA,
    login_timeout=30,
    network_timeout=60,
    ocsp_fail_open=True,   
)
cur = cnx.cursor()
print("Connected.")

try:
    # ---- setup stage and file format ----
    print(f"Ensuring stage '{STAGE}' exists...")
    cur.execute(f"CREATE STAGE IF NOT EXISTS {STAGE}")

    print(f"Ensuring file format '{FILE_FORMAT}' exists (CSV, skip 1 header)...")
    cur.execute(f"""
        CREATE FILE FORMAT IF NOT EXISTS {FILE_FORMAT}
          TYPE = CSV
          FIELD_OPTIONALLY_ENCLOSED_BY = '"'
          SKIP_HEADER = 1
          NULL_IF = ('', 'NULL');
    """)

    print(f"Uploading {local_path} to @{STAGE} ...")
    cur.execute(f"PUT file://{local_path} @{STAGE} AUTO_COMPRESS=FALSE OVERWRITE=TRUE")
    put_result = cur.fetchall()
    print("PUT result:", put_result)

    print(f"COPY INTO {TARGET_TABLE} from that one file (headers skipped)...")
    copy_sql = f"""
        COPY INTO {TARGET_TABLE} {COLUMNS}
        FROM @{STAGE}/{CSV_FILE_NAME}
        FILE_FORMAT = (FORMAT_NAME = {FILE_FORMAT})
        ON_ERROR = 'ABORT_STATEMENT';
    """
    cur.execute(copy_sql)
    copy_result = cur.fetchall()
    print("COPY result:", copy_result)

    print("Loading completed successfully.")

finally:
    try:
        cur.close()
    except Exception:
        pass
    try:
        cnx.close()
    except Exception:
        pass