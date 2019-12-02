import time, csv, re, os, datetime

""" Log location """
LOG_FOLDER = "log_query/"
BASE_LOG_NAME = "logquery"
LOG_EXT = ".txt"

def parse_log(path, cacheHitRatios):
    """
        Parses the target log. File size is converted into OUT_FILE_SIZE
    """
    found = 0
    cacheHit, total = 0, 0

    with open(path, "r") as file:
        for line in file:
            if "CACHE_HIT_BYTES" in line:
                cacheHit = [int(item) for item in line.split() if item.isdigit()][0]
                found += 1
            elif "CACHE_MISS_BYTES" in line:
                miss = [int(item) for item in line.split() if item.isdigit()][0]
                total = cacheHit + miss
                found += 1

            # Number of items to find before stop parsing
            if found == 2:
                break

    if total != 0 and cacheHit != 0:
        # query success
        cacheHitRatios.append(cacheHit / total * 100)
    else:
        # query fail
        cacheHitRatios.append(0)

def write_csv(cacheHitRatios):
    """
        Writes info to a csv file.
    """
    with open(OUT_NAME, "w", newline="") as output_csv:
        writer = csv.writer(output_csv)
        # header
        head = ["Query#", "Cache Hit Ratio %"]
        writer.writerow(head)
        # info
        for i in range(len(cacheHitRatios)):
            writer.writerow([i + 1, cacheHitRatios[i]])

os.environ["TZ"]="US/Pacific"
time_id = datetime.datetime.now().strftime("%m.%d.%Y-%H.%M")
OUT_NAME = "llapio_summary" + time_id + ".csv"
def main():
    # Range of queries. Counts the files so you don't need to know which benchmark it is
    START = 1
    END = 0
    for file in os.listdir(LOG_FOLDER):
        if file.startswith(BASE_LOG_NAME) and file.endswith(LOG_EXT):
            END += 1

    # parse all data
    cacheHitRatios = list()
    for i in range(START, END + 1):
        parse_log(LOG_FOLDER + BASE_LOG_NAME + str(i) + LOG_EXT, cacheHitRatios)

    write_csv(cacheHitRatios)

if __name__ == "__main__":
    start = time.time()
    main()
    end = time.time()
    print("Log parsing finished in {0} secs".format(end - start))
