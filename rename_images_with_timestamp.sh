#!/bin/bash

# 使用方法: ./rename_images_with_timestamp_macos.sh <目录路径> [前缀]

DIRECTORY=$1
PREFIX=$2
COUNT=1

if [ ! -d "$DIRECTORY" ]; then
    echo "错误: 目录不存在，请提供有效的目录路径。"
    exit 1
fi

# 获取目录下所有图片文件的列表，按修改时间排序
IMAGES=$(find "$DIRECTORY" \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.gif" \) -type f -exec stat -f "%m %N" {} \; | sort -n)

# 遍历图片并重命名
while read -r MOD_TIME FILE_PATH; do
    BASENAME=$(basename "$FILE_PATH")
    EXTENSION="${BASENAME##*.}"
    NAME="${BASENAME%.*}"

    # 构建新文件名，添加前缀和序号
    NEW_NAME="${PREFIX}${COUNT}.${EXTENSION}"
    NEW_PATH="$DIRECTORY/$NEW_NAME"

    # 重命名文件
    mv "$FILE_PATH" "$NEW_PATH"
    echo "重命名: $FILE_PATH -> $NEW_NAME"

    ((COUNT++))
done <<< "$IMAGES"

echo "所有图片已按修改时间顺序重命名并添加序号及前缀。"