import time, csv, re, os, datetime

""" Log location """
LOG_FOLDER = "log_query/"
BASE_LOG_NAME = "logquery"
LOG_EXT = ".txt"

""" BASE PARAMS """
os.environ["TZ"]="US/Pacific"
time_id = datetime.datetime.now().strftime("%m.%d.%Y-%H.%M")

class Query():
    """ A Query object will hold data relevant to the query """
    csv_header = ["Query#", "Secs", "Cache Hit %", "Metadata Hit %"]

    def __init__(self, query_num, secs_taken, cache_hit_ratio, metadata_hit_ratio):
        self.query_num = query_num
        self.secs_taken = secs_taken
        self.cache_hit_ratio = cache_hit_ratio
        self.metadata_hit_ratio = metadata_hit_ratio

    def get_csv_row(self):
        return [self.query_num, self.secs_taken, self.cache_hit_ratio, self.metadata_hit_ratio]

    def get_query_num(self):
        return self.query_num

    def get_secs_taken(self):
        return self.secs_taken

    def set_secs_taken(self, secs_taken):
        self.secs_taken = secs_taken

    def set_cache_hit_ratio(self, cache_hit_ratio):
        self.cache_hit_ratio = cache_hit_ratio

    def set_metadata_hit_ratio(self, metadata_hit_ratio):
        self.metadata_hit_ratio = metadata_hit_ratio

def parseLog(query_num, path):
    """
        Returns a query object with updated metrics. Object will have a dummy value if it can't find it or query failed.

        1. The precise time of query by using the recorded in the logs. Also assumes target is formatted as:
           "1 row selected (1.23 seconds)"
           "2 rows selected (1.23 seconds)"
        2. Cache hit ratio.
        3. Metadata hit ratio. "Cache retention rate".
    """
    DUMMY_FAILED_VALUE = 0.0123
    secs_taken, found_time_taken = 0, False
    cache_hit, cache_miss, cache_total = 0, 0, 0
    metadata_hit, metadata_miss, metadata_total = 0, 0, 0

    with open(path, "r") as file:
        for line in file:
            # Parse time taken
            if "rows selected (" in line or "row selected (" in line:
                secs_taken += float(re.findall("[0-9]+\\.[0-9]+", line)[0])
                found_time_taken = True

            # Parse cache hit ratio
            elif "CACHE_HIT_BYTES" in line:
                cache_hit += [int(item) for item in line.split() if item.isdigit()][0]
            elif "CACHE_MISS_BYTES" in line:
                cache_miss += [int(item) for item in line.split() if item.isdigit()][0]

            # Parse metadata hit ratio
            elif "METADATA_CACHE_HIT" in line:
                metadata_hit += [int(item) for item in line.split() if item.isdigit()][0]
            elif "METADATA_CACHE_MISS" in line:
                metadata_miss += [int(item) for item in line.split() if item.isdigit()][0]

    # Update data after read
    query = Query(query_num, DUMMY_FAILED_VALUE, DUMMY_FAILED_VALUE, DUMMY_FAILED_VALUE)

    if found_time_taken:
        query.set_secs_taken(round(secs_taken, 2))

    cache_total = cache_hit + cache_miss
    if cache_total != 0:
        query.set_cache_hit_ratio(round(cache_hit / cache_total * 100, 2))

    metadata_total = metadata_hit + metadata_miss
    if metadata_total != 0:
        query.set_metadata_hit_ratio(round(metadata_hit / metadata_total * 100, 2))

    return query

def process_min_querytime(minquerytime_map, query_object):
    """
        This processes query objects to output a map of minimum times per query.
    """
    i = int(float(query_object.get_query_num()))
    if i not in minquerytime_map:
        minquerytime_map[i] = query_object.get_secs_taken()
    else:
        current_min_secs = minquerytime_map[i]
        if query_object.get_secs_taken() < current_min_secs:
            minquerytime_map[i] = query_object.get_secs_taken()

def write_csv(query_object_map, output_file_name):
    """
        Writes info to a csv file.
    """
    query_num_list = list(query_object_map.keys())
    query_num_list.sort(key=float)

    with open(output_file_name, "w", newline="") as output_csv:
        writer = csv.writer(output_csv)
        writer.writerow(Query.csv_header)
        # info
        for i in query_num_list:
            query_object = query_object_map[i]
            writer.writerow(query_object.get_csv_row())

def write_mintimes_csv(minquerytime_map, output_file_name):
    """
        Writes the minimum time of each query to a csv file.
    """
    query_num_list = list(minquerytime_map.keys())
    query_num_list.sort(key=float)

    with open(output_file_name, "w", newline="") as output_csv:
        writer = csv.writer(output_csv)
        writer.writerow(["Query#", "Secs"])
        # info
        for i in query_num_list:
            writer.writerow([i, minquerytime_map[i]])

def main():
    querynum_to_queryobject = {}
    minquerytime_map = {}

    for filename in os.listdir(LOG_FOLDER):
        if filename.startswith(BASE_LOG_NAME) and filename.endswith(LOG_EXT):
            query_runNum = re.findall("\\d+\\.\\d+", filename)
            if len(query_runNum) == 1:
                query_num = query_runNum[0]
                filepath = LOG_FOLDER + filename

                query_object = parseLog(query_num, filepath)
                process_min_querytime(minquerytime_map, query_object)
                querynum_to_queryobject[query_object.get_query_num()] = query_object
            else:
                raise Exception("Did not find query number in " + query_runNum)

    write_csv(querynum_to_queryobject, "llapio_summary{0}.csv".format(time_id))
    write_mintimes_csv(minquerytime_map, "llap_mintimes_summary{0}.csv".format(time_id))

if __name__ == "__main__":
    start = time.time()
    main()
    end = time.time()
    print("Log parsing finished in {0} secs".format(round(end - start, 2)))
