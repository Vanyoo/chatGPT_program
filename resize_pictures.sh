#!/bin/bash

# 检查是否提供了目录参数
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 /path/to/directory"
    exit 1
fi

# 获取输入的目录路径
input_dir="$1"

# 使用find命令查找指定目录下的jpg和png文件
find "$input_dir" -type f \( -iname "*.jpg" -o -iname "*.png" \) | while read -r img_path; do
    # 提取原文件名及扩展名
    base_name=$(basename "$img_path")
    extension="${base_name##*.}"
    file_name="${base_name%.*}"

    # 计算输出文件路径（与原文件同目录，文件名为原文件名，扩展名不变）
    output_path="${img_path%/*}/${file_name}_resized.${extension}"

    # 使用convert命令进行按比例缩放，保持宽为1080px
    convert "$img_path" -resize '1080x>' "$output_path"

    echo "Resized image: ${img_path} -> ${output_path}"
done

echo "Image resizing completed."