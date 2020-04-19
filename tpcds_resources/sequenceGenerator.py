#!/usr/bin/python
"""
This udf generates sequence of number from [1...n] when invoked with n as commandline arguments.
"""

import sys

def usage():
	print("usage : " + __file__ + " n ")
	print("Generate sequnce of number from 1 to n")

def main():
	try:
		max=int(sys.argv[1])+1
	except Exception as e:
		usage()
		sys.exit()

	for i in range(1,max):
		print("%d" % (i))

if __name__ == "__main__":
	main()
