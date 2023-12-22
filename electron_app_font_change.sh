#!/bin/bash

# 检查输入参数
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <target_directory>"
    exit 1
fi

# 指定目标目录为第一个输入参数
target_directory="$1"

echo "1. 查找所有asar文件..."
# 1. 遍历目录，找出所有asar文件
IFS=$'\n' asar_files=($(find "$target_directory" -type f -name "*.asar"))

echo "2. 解压这些asar文件..."
# 2. 解压这些asar文件
for asar_file in "${asar_files[@]}"; do
    # 提取文件名（不包含后缀）
    base_name=$(basename "$asar_file" .asar)
    # 解压asar文件
    asar extract "$asar_file" "$target_directory/$base_name-asar"
    echo "   解压: $asar_file -> \"$target_directory/$base_name-asar\""
done

echo "3. 修改所有.css文件..."
# 3. 修改所有.css文件中的`font-family:`为`font-family:JB-Mono-ND-MiS,`
find "$target_directory" -type f -name "*.css" -exec sed -i '' 's/\(font-family:[[:space:]]*\)/\1JB-Mono-ND-MiS, /g' "{}" +

echo "4. 重命名原始.asar文件为.asar.org..."
# 4. 重命名原始.asar文件为.asar.org
for asar_file in "${asar_files[@]}"; do
    mv "$asar_file" "$asar_file.org"
    echo "   重命名: $asar_file -> \"$asar_file.org\""
done

echo "5. 重新打包为.asar文件..."
# 5. 重新打包为.asar文件
for asar_file in "${asar_files[@]}"; do
    # 提取文件名（不包含后缀）
    base_name=$(basename "$asar_file" .asar)
    # 重新打包文件夹为.asar文件
    asar pack "$target_directory/$base_name-asar" "$target_directory/$base_name.asar"
    echo "   重新打包: \"$target_directory/$base_name-asar\" -> \"$target_directory/$base_name.asar\""
done

echo "任务完成"
