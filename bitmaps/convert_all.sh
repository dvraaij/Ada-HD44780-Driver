#!/bin/bash

for f in *.pbm;
do
  ./pbm_to_ada.py ${f} ${f%.*};
  printf "\n";
done > HD44780-Extra.ads
