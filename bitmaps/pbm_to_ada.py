#!/usr/bin/python

# You may want to loop this script
#
#   for f in *.pbm;
#   do
#     ./pbm_to_ada.py ${f} ${f%.*};
#     printf "\n";
#   done > list.txt
#

import string
import sys
import os

# Input arguments
if len(sys.argv) != 3:
    print "Usage: pbm_to_ada.py <input.pbm> <name>"
    sys.exit()

# Filename
filename = sys.argv[1];
varname  = sys.argv[2];

# Verify length of file
if os.path.getsize(filename) > 100:
    print "File unreasonably large"

# Read file content
with open(filename, 'r') as f:
    data = f.read()

# Remove whitespace
data = data.translate(None, string.whitespace)

# Split header / body
header, body = data[:4], data[4:]

# Validate header
if header != "P158":
    print "Header incorrect"
    sys.exit()

# Extract bitmap data
print("{0} : constant HD44780_Bitmap :=".format(varname))
for k in range(0, 8):

    if   k == 0:
      tmpl = "  ({0} => 2#{1}#,"
    elif k == 7:
      tmpl = "   {0} => 2#{1}#);"
    else:
      tmpl = "   {0} => 2#{1}#,"

    print tmpl.format(k, body[(5*k):(5*k+5)])
