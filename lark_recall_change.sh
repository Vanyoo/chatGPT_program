#!/bin/bash

# 定义路径
base_dir="/Applications/Lark.app/Contents/Frameworks/Lark Framework.framework/Resources/webcontent/"
asar_file="${base_dir}messenger.asar"
extract_dir="${base_dir}messenger-asar"

# 检查解压目录是否存在，如果存在则删除
if [ -d "$extract_dir" ]; then
  echo "Removing existing directory..."
  rm -rf "$extract_dir"
fi

# 解压Asar文件
echo "Extracting Asar file..."
asar extract "$asar_file" "$extract_dir"
if [ $? -ne 0 ]; then
  echo "Failed to extract Asar file"
  exit 1
fi

# 修改所有JS文件
echo "Modifying JS files..."
find "$extract_dir" -type f -name "*.js" -exec sed -i '' 's/async receivePushMessagesEntities(e,s){/async receivePushMessagesEntities(e,s){try{Object.keys(e.messages).forEach(itemKey=>{if(e.messages[itemKey].isRecalled){e.messages[itemKey].isRecalled=false;delete e.messages[itemKey];}});}catch(e){console.log(e);}/' {} \;
if [ $? -ne 0 ]; then
  echo "Failed to modify JS files"
  exit 1
fi

# 删除原始Asar文件
echo "Removing original Asar file..."
rm "$asar_file"
if [ $? -ne 0 ]; then
  echo "Failed to remove original Asar file"
  exit 1
fi

# 重新打包Asar文件
echo "Packing new Asar file..."
asar pack "$extract_dir" "$asar_file"
if [ $? -ne 0 ]; then
  echo "Failed to pack new Asar file"
  exit 1
fi

echo "All tasks completed successfully."
