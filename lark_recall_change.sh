#!/bin/bash

# 定义路径
base_dir="/Applications/Lark.app/Contents/Frameworks/Lark Framework.framework/Resources/webcontent/"
asar_file="${base_dir}messenger.asar"
extract_dir="${base_dir}messenger-asar"
js_file="${extract_dir}/25873/41ec067c.js"

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

# 修改JS文件
echo "Modifying JS file..."
sed -i '' 's/async receivePushMessagesEntities(e,s){/async receivePushMessagesEntities(e,s){try{Object.keys(e.messages).forEach(itemKey=>{if(e.messages[itemKey].isRecalled){e.messages[itemKey].isRecalled=false;delete e.messages[itemKey];}});}catch(e){console.log(e);}/' "$js_file"
if [ $? -ne 0 ]; then
  echo "Failed to modify JS file"
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
