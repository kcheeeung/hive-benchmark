#!/usr/bin/python
"""
This UDF generates k-th part of n part TPCDS generartion. This uses dsdgen and runs it parallelly and uploads the output to HDFS.
It requires following files to be added using "ADD FILE" syntax to the session.
- dsdgen
- tpcds.idx

"""

import argparse
import subprocess
import sys
import os
import time
import random
import logging
import glob
import re

HDFS_CMD = "hdfs dfs"

MAX_BACKOFF_UNIT = 60
MIN_BACKOFF_UNIT = 1

_logger = logging.getLogger(__name__)

def usage():
    print(__file__)

def generate_data_to_hdfs(hdfs_output, partition, scale_factor, num_parts):
    """Generate data using dsdgen and upload it to HDFS."""

    _logger.info("starting : ./dsdgen -dir . -force Y -scale {} -child {} -parallel {}".format(scale_factor, partition, num_parts))
    execute("./dsdgen -dir . -force Y -scale %d -child %d -parallel %d" % (scale_factor, partition, num_parts))
    _logger.info("completed : ./dsdgen -dir . -force Y -scale {} -child {} -parallel {}".format(scale_factor, partition, num_parts))
    for t in glob.glob("*.dat"):
        copy_table_to_hdfs(hdfs_output, re.sub(r"_[0-9]+_[0-9]+.dat","",t), t)
        _logger.info("delting the local file {}".format(t))
        os.remove(t)

def copy_table_to_hdfs(hdfs_output, table_name, data_file):
    _logger.info("Beginning copy_table_to_hdfs for table_name: {} file {} ".format(table_name,data_file))
    execute("%s -mkdir -p %s/%s" % (HDFS_CMD, hdfs_output, table_name))
    execute("%s -copyFromLocal -f %s %s/%s/" % (HDFS_CMD, data_file, hdfs_output, table_name))
    _logger.info("copy_table_to_hdfs complete for table_name: {}".format(table_name))

def execute(cmd,retries_remaining=10):
    if(retries_remaining<0):
        _logger.info("All retries for {} exhauseted. Failing the attempt".format(cmd))
        sys.exit(1)

    try:
        subprocess.check_call(cmd,stdin=subprocess.PIPE,stderr=subprocess.STDOUT,shell=True)
    except:
        backoff_time = (11-retries_remaining)*random.randint((11-retries_remaining)*MIN_BACKOFF_UNIT,MAX_BACKOFF_UNIT)
        _logger.info("command {} failed. Retries remaining {}. Sleeping for {} before trying again".format(cmd, retries_remaining, backoff_time))
        time.sleep(backoff_time)
        execute(cmd,retries_remaining-1)


def main():
    logging.basicConfig(level=logging.INFO,stream=sys.stderr)
    parser = argparse.ArgumentParser(description='Generate TPCDS data in parallel')
    parser.add_argument('-s','--scale', metavar='SCALE_FACTOR',type=int, required=True,
                    help='scale factor for TPCDS datagen')
    parser.add_argument('-o','--output', metavar='OUTPUT_HDFS_PATH', required=True,
                    help='HDFS path where the generated data will be stored')
    parser.add_argument('-n','--num_parts', metavar='NUM_PARTS', type=int, required=True,
                    help='Number of parts to divide the datagen')

    args = parser.parse_args()
    partition = None

    while True:
        line = sys.stdin.readline()
        if not line:
            break

        try:
            partition = int(line.strip())
        except:
            print("UDF expects a number as input.")

        if (args.output is None or partition is None or
            args.num_parts is None or args.scale is None):
            usage()
            sys.exit()

        generate_data_to_hdfs(args.output, partition, args.scale, args.num_parts)

if __name__ == "__main__":
    main()
