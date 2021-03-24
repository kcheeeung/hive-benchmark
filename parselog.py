import time, csv, re, os, datetime

""" Log location """
LOG_FOLDER = "log_query/"
BASE_LOG_NAME = "logquery"
LOG_EXT = ".txt"

""" BASE PARAMS """
os.environ["TZ"]="US/Pacific"
time_id = datetime.datetime.now().strftime("%m.%d.%Y-%H.%M")
OUT_NAME = "llapio_summary" + time_id + ".csv"

def getPreciseTime(path):
    """
        Returns the precise time of query by using the recorded in the logs. Also assumes target is formatted as:
        "1 row selected (1.23 seconds)"
        "2 rows selected (1.23 seconds)"
    """
    found = False
    total_time = 0

    with open(path, "r") as file:
        for line in file:
            if "rows selected (" in line or "row selected (" in line:
                total_time += float(re.findall("[0-9]+\.[0-9]+", line)[0])
                found = True

    if found:
        return total_time
    else:
        return 0.01234

def getCacheHitRatio(path):
    """ Returns the cache hit ratio """
    cacheHit, miss, total = 0, 0, 0

    with open(path, "r") as file:
        for line in file:
            if "CACHE_HIT_BYTES" in line:
                cacheHit += [int(item) for item in line.split() if item.isdigit()][0]
            elif "CACHE_MISS_BYTES" in line:
                miss += [int(item) for item in line.split() if item.isdigit()][0]
    
    total = cacheHit + miss
    if total != 0:
        return cacheHit / total * 100
    else:
        # query fail
        return 0.12345

def getMetadataHitRatio(path):
    """ Returns the metadata hit ratio. 'Cache retention rate basically' """
    metadataHit, miss, total = 0, 0, 0

    with open(path, "r") as file:
        for line in file:
            if "METADATA_CACHE_HIT" in line:
                metadataHit += [int(item) for item in line.split() if item.isdigit()][0]
            elif "METADATA_CACHE_MISS" in line:
                miss += [int(item) for item in line.split() if item.isdigit()][0]
        
    total = metadataHit + miss
    if total != 0:
        return metadataHit / total * 100
    else:
        # query fail
        return 0.12345

def write_csv(queryTime, cacheHitRatios, metadataHitRatio):
    """
        Writes info to a csv file.
        Modify by adding new columns and map of parsed data.
    """
    queryNum = list(cacheHitRatios.keys())
    queryNum.sort(key=float)

    with open(OUT_NAME, "w", newline="") as output_csv:
        writer = csv.writer(output_csv)
        # header
        head = ["Query#", "Secs", "Cache Hit %", "Metadata Hit %"]
        writer.writerow(head)
        # info
        for i in queryNum:
            writer.writerow([float(i), queryTime[i], cacheHitRatios[i], metadataHitRatio[i]])

def main():
    querynum_to_timetaken = {}
    querynum_to_cacheratio = {}
    querynum_to_metadatahitratio = {}
    for filename in os.listdir(LOG_FOLDER):
        if filename.startswith(BASE_LOG_NAME) and filename.endswith(LOG_EXT):
            query_runNum = re.findall("\d+\.\d+", filename)
            if len(query_runNum) == 1:
                query_num = query_runNum[0]
                filepath = LOG_FOLDER + filename

                querynum_to_timetaken[query_num] = getPreciseTime(filepath)
                querynum_to_cacheratio[query_num] = getCacheHitRatio(filepath)
                querynum_to_metadatahitratio[query_num] = getMetadataHitRatio(filepath)
            else:
                raise Exception("Did not find query number in " + query_runNum)

    write_csv(querynum_to_timetaken, querynum_to_cacheratio, querynum_to_metadatahitratio)

if __name__ == "__main__":
    start = time.time()
    main()
    end = time.time()
    print("Log parsing finished in {0} secs".format(end - start))
