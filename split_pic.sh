#!/bin/bash

# 检查输入参数数量
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <image_path> <number_of_pieces>"
  exit 1
fi

# 读取输入参数
input_image="$1"
number_of_pieces="$2"

# 检查文件是否存在
if [ ! -f "$input_image" ]; then
  echo "Error: File '$input_image' not found."
  exit 1
fi

# 检查分割份数是否为正整数
if ! [[ "$number_of_pieces" =~ ^[0-9]+$ ]] || [ "$number_of_pieces" -le 0 ]; then
  echo "Error: Number of pieces must be a positive integer."
  exit 1
fi

# 使用mktemp创建临时目录
tmp_dir=$(mktemp -d)
if [ ! -d "$tmp_dir" ]; then
  echo "Error: Failed to create temporary directory."
  exit 1
fi

# 获取图片的宽度和高度
width=$(identify -format "%w" "$input_image")
height=$(identify -format "%h" "$input_image")

# 计算每一份的高度
piece_height=$((height / number_of_pieces))

# 循环分割图片
for (( i=0; i<number_of_pieces; i++ ))
do
  # 计算Y坐标的起始点
  start_y=$((i * piece_height))

  # 打印将要截图的区域
  echo "Cropping area: ${start_y}x0-${width}x${piece_height}"

  # 使用basename获取不带路径的文件名
  filename=$(basename -- "$input_image")
  extension="${filename##*.}"
  filename="${filename%.*}"

  # 构建输出文件名
  output_image="${tmp_dir}/${filename}_part_${i}.${extension}"

  # 切割图片并保存到临时目录
  convert "$input_image" -crop ${width}x${piece_height}+0+${start_y} "$output_image"
done

echo "Splitting completed. Parts saved in '$tmp_dir' directory."
open $tmp_dir
