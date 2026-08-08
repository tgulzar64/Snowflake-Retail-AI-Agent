import snowflake.snowpark as snowpark

def main(session: snowpark.Session):

    # Upload CSV data files to the data stage
    files = [
        "retail_2009_2010.csv",
        "retail_2010_2011.csv"
    ]

    print("Uploading data files to RETAIL_DATA_STAGE...")
    for f in files:
        session.file.put(
            f"@HOL_ONLINE_RETAIL.DATA.RETAIL_DATA_STAGE/{f}",
            f,
            auto_compress=True,
            overwrite=True
        )
        print(f"  ✅ Uploaded: {f}")

    # Verify what's in the stage
    print("\nFiles in RETAIL_DATA_STAGE:")
    result = session.sql("LIST @HOL_ONLINE_RETAIL.DATA.RETAIL_DATA_STAGE").collect()
    for row in result:
        print(f"  {row['name']}")

    print("\nDone! Ready for data loading.")
    return "Upload complete"