#!/bin/bash

# 使用方法: ./download_images_bash.sh <html_file> <download_directory>

HTML_FILE=$1
DOWNLOAD_DIR=$2

if [ ! -f "$HTML_FILE" ]; then
    echo "错误: HTML文件不存在，请提供有效的HTML文件路径。"
    exit 1
fi

if [ ! -d "$DOWNLOAD_DIR" ]; then
    mkdir -p "$DOWNLOAD_DIR"
fi

# 使用grep, awk, cut提取img标签的src属性，这是一个简化的尝试，可能不适用于所有情况
IMAGES=$(grep -o '<img[^>]*src=[^>]*>' "$HTML_FILE" | awk '{print $2}' | cut -d'"' -f2)

if [ -z "$IMAGES" ]; then
    echo "没有在HTML文件中找到图片链接。"
    exit 0
fi

echo "开始下载图片..."

# 遍历图片URL并下载
for IMAGE_URL in $IMAGES; do
    if [[ "$IMAGE_URL" != http* ]]; then
        # 如果URL不是绝对路径，尝试将其视为相对于HTML文件的路径
        RELATIVE_PATH="$IMAGE_URL"
        if [ -f "$(dirname "$HTML_FILE")/$RELATIVE_PATH" ]; then
            IMAGE_URL=$(realpath "$(dirname "$HTML_FILE")/$RELATIVE_PATH")
        else
            echo "警告: 无法解析相对图片路径'$RELATIVE_PATH'，已跳过。"
            continue
        fi
    fi
    curl -s -O "$IMAGE_URL" -o "$DOWNLOAD_DIR/$(basename "$IMAGE_URL")"
	echo "完成$IMAGE_URL的下载"
done

echo "图片下载完成。"
