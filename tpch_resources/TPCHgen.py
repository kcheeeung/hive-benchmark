#!/usr/bin/python
"""
This UDF generates k-th part of n part TPCH generartion. This uses dbgen to run in parallel and uploads the output to HDFS.
nation and region tables are not pratitioned and are only generate on one node.
It requires following files to be added using "ADD FILE" syntax to the session.
- dbgen
- dists.dss

"""

import argparse
import subprocess
import sys
import os

HDFS_CMD = "hdfs dfs"

def usage():
    print(__file__)

def generate_data_to_hdfs(hdfs_output, partition, scale_factor, num_parts):
    """Generate data using dbgen and save it to HDFS."""

    execute("./dbgen -b ./dists.dss -v -f -s %d -S %d -C %d" % (scale_factor, partition, num_parts))

    if partition == 1:
        # copy the two non-partitioned tables.
        execute("%s -mkdir -p %s/nation & exit" % (HDFS_CMD, hdfs_output))
        execute("%s -mkdir -p %s/region & exit" % (HDFS_CMD, hdfs_output))
        copy_local_file_to_hdfs("nation.tbl", "%s/nation/nation.tbl" % hdfs_output)
        copy_local_file_to_hdfs("region.tbl", "%s/region/region.tbl" % hdfs_output)

    # copy all partitioned tables.
    copy_partitioned_table_to_hdfs(hdfs_output, "supplier", partition)
    copy_partitioned_table_to_hdfs(hdfs_output, "part", partition)
    copy_partitioned_table_to_hdfs(hdfs_output, "partsupp", partition)
    copy_partitioned_table_to_hdfs(hdfs_output, "orders", partition)
    copy_partitioned_table_to_hdfs(hdfs_output, "lineitem", partition)
    copy_partitioned_table_to_hdfs(hdfs_output, "customer", partition)

def copy_partitioned_table_to_hdfs(hdfs_output, table_name, partition):
    local_file_name = "%s.tbl.%d" % (table_name, partition)
    hdfs_file_name = "%s/%s/%s" % (hdfs_output, table_name, local_file_name)
    execute("%s -mkdir -p %s/%s & exit" % (HDFS_CMD, hdfs_output, table_name))
    copy_local_file_to_hdfs(local_file_name, hdfs_file_name)

def copy_local_file_to_hdfs(local_path, hdfs_path):
    execute("%s -copyFromLocal -f %s %s" % (HDFS_CMD, local_path, hdfs_path))

def execute(cmd,retry=10):
    if(retry<0):
        sys.exit(1)

    try:
        subprocess.check_call(cmd,stdin=subprocess.PIPE,stderr=subprocess.STDOUT,shell=True)
    except:
        execute(cmd,retry-1)


def main():
    parser = argparse.ArgumentParser(description='Generate TPCH data in parallel')
    parser.add_argument('-s','--scale', metavar='SCALE_FACTOR',type=int, required=True,
                    help='scale factor for TPCH datagen')
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
