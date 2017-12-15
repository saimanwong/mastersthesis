import numpy
import os
import re
import sys

directory_src = sys.argv[1] # Directory of raw data
directory_dst = sys.argv[2] # Directory of latex data

_nsre = re.compile('([0-9]+)')
def natural_sort_key(s):
        return [int(text) if text.isdigit() else text.lower()
                            for text in re.split(_nsre, s)]   

lst = []
p = []

for filename in os.listdir(directory_src):
    p.append(filename)

p.sort(key=natural_sort_key)

for filename in p:
    if filename.endswith(".dat"):
        path = os.path.join(directory_src, filename)
        path_array = path.replace(directory_src + "/","").replace(".dat","").split("_")

        with open (path) as f:
            for line in f:
                temp = line.split()
                if temp[1] == "kbps":
                    lst.append(float(temp[0])/1000)
                else:
                    lst.append(float(temp[0]))


        temp_path = directory_dst + "/" + path_array[0] + "_" + path_array[1] + ".dat"
        text = path_array[2] + " " + str(numpy.mean(lst)) + " " + str(numpy.std(lst)) + '\n'
        f = open(temp_path, 'a')
        f.write(text)
        f.close
        lst = []
        continue
    else:
        continue
