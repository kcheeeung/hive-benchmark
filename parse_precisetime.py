import argparse
import csv
import datetime
import os
import re
import time

""" Log location """
LOG_FOLDER = "log_query/"
BASE_LOG_NAME = "logquery"
LOG_EXT = ".txt"

""" Constants """
os.environ["TZ"]="US/Pacific"
time_id = datetime.datetime.now().strftime("%m.%d.%Y-%H.%M.%S")
DENOTE_QUERYFAILS_AS = 0

def getQueryTime(path):
    """
        Returns the query time. Also assumes target is formatted as:
        "row/s selected (12.345 seconds)"

        # if "rows selected (" in line or "row selected (" in line:
    """
    currtime = 0
    with open(path, "r") as file:
        for line in file:
            if " selected (" in line:
                currtime += float(re.findall("[0-9]+\.[0-9]+", line)[0])
    return currtime

def write_csv(querytime_map, OUTPUT_NAME):
    """
        Writes the query times to a csv
    """
    with open(OUTPUT_NAME, "w", newline="") as output_csv:
        writer = csv.writer(output_csv)
        # header
        head = ["Query#", "PreciseTime"]
        writer.writerow(head)
        # info
        for key in querytime_map:
            writer.writerow([key, querytime_map[key]])

def main():
    """
        Parses the log files to capture ONLY THE QUERY TIME, meaning user is already inside beeline or hive client.
        Bypasses any connection time using a public gateway or connection to the client itself.
    """
    # Pass arguments
    parser = argparse.ArgumentParser(description="Which benchmark are you using?")
    parser.add_argument("benchtype", type=str, choices={"tpcds", "tpch"})
    args = parser.parse_args()

    # Determine which benchmark
    querytime_map = {}
    OUTPUT_NAME=""
    if args.benchtype == "tpcds":
        OUTPUT_NAME = "time_precise_tpcds" + time_id + ".csv"
        for i in range(1, 99 + 1):
            querytime_map[i] = DENOTE_QUERYFAILS_AS
    elif args.benchtype == "tpch":
        OUTPUT_NAME = "time_precise_tpch" + time_id + ".csv"
        for i in range(1, 24 + 1):
            querytime_map[i] = DENOTE_QUERYFAILS_AS
    else:
        raise Exception("There was an internal error. Probably invalid argument.")
    
    # Parse the logs
    for file in os.listdir(LOG_FOLDER):
        if file.startswith(BASE_LOG_NAME) and file.endswith(LOG_EXT):
            # Get query number from filename
            query_number = int("".join(filter(str.isdigit, file)))
            # Map query_number to querytime
            querytime_map[query_number] = getQueryTime(LOG_FOLDER + BASE_LOG_NAME + str(query_number) + LOG_EXT)

    # Write the csv
    write_csv(querytime_map, OUTPUT_NAME)

if __name__ == "__main__":
    start = time.time()
    main()
    end = time.time()
    print("Log parsing finished in {0} secs".format(end - start))
