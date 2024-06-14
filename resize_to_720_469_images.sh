#!/bin/bash

input_directory=$1

for image in "$input_directory"/*; do
  convert "$image" -resize 720x469 -background white -gravity center -extent 720x469 "${image%.*}_resized.${image##*.}"
 done
