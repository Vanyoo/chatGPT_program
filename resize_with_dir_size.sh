#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <directory> <width> <height>"
    exit 1
fi

# Assign arguments to variables
directory=$1
width=$2
height=$3

# Check if the directory exists
if [ ! -d "$directory" ]; then
    echo "Error: Directory $directory does not exist."
    exit 1
fi

# Check if width and height are integers
if ! [[ "$width" =~ ^[0-9]+$ ]] || ! [[ "$height" =~ ^[0-9]+$ ]]; then
    echo "Error: Width and height must be integers."
    exit 1
fi

# Process images
echo "Resizing images in $directory to ${width}x${height} with white background..."

for image in "$directory"/*.{jpg,jpeg,png,gif,JPG,JPEG,PNG,GIF}; do
    if [ -f "$image" ]; then
        echo "Processing $image..."
        convert "$image" -resize "${width}x${height}" -background white -gravity center -extent "${width}x${height}" "${image%.jpg}-resized.jpg"
    fi
done

echo "Image resizing complete."
