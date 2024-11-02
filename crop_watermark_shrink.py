import os
import sys
from PIL import Image, ImageDraw, ImageFont
from datetime import datetime

default_font_path_bold = "./MiSans/ttf/MiSans-Bold.ttf"
default_font_path_regular = "./MiSans/ttf/MiSans-Regular.ttf"

def add_watermarks(image, text1="茶友", text2="供图", directory_name="", font_path_bold="./MiSans/ttf/MiSans-Bold.ttf", font_path_regular="./MiSans/ttf/MiSans-Regular.ttf", font_size_regular=24, font_size_bold=36):
    # 获取图片的宽高
    width, height = image.size
    
    # 创建绘图对象
    draw = ImageDraw.Draw(image)
    
    # 加载字体
    font_regular = ImageFont.truetype(font_path_regular, font_size_regular)
    font_bold = ImageFont.truetype(font_path_bold, font_size_bold)
    font_dot = ImageFont.truetype(font_path_regular, 36)  # 为“•”符号加载字体并设置大小

    # 计算右下角水印的两行文本尺寸
    text1_bbox = draw.textbbox((0, 0), text1, font=font_regular)
    text1_width, text1_height = text1_bbox[2] - text1_bbox[0], text1_bbox[3] - text1_bbox[1]
    
    text2_bbox = draw.textbbox((0, 0), text2, font=font_regular)
    text2_width, text2_height = text2_bbox[2] - text2_bbox[0], text2_bbox[3] - text2_bbox[1]
    
    total_text_height_regular = text1_height + text2_height
    
    # 设置右边和底部距离为 25 像素的偏移
    padding_right_bottom = 25
    
    # 计算右下角水印位置
    text1_position = (width - text1_width - padding_right_bottom, height - total_text_height_regular - padding_right_bottom)
    text2_position = (width - text2_width - padding_right_bottom, text1_position[1] + text1_height)
    
    # 计算“•”符号的位置
    dot_position = (text1_position[0] - 27, text1_position[1] + 3)  # 适当调整“•”符号位置

    # 绘制“•”符号
    draw.text(dot_position, "•", font=font_dot, fill=(255, 255, 255, 128))
    
    # 绘制右下角的水印文本
    draw.text(text1_position, text1, font=font_regular, fill=(255, 255, 255, 128))
    draw.text(text2_position, text2, font=font_regular, fill=(255, 255, 255, 128))
    
    # 计算左下角水印（所属目录名）的边界框
    left_directory_text = f"@{directory_name}"
    directory_bbox = draw.textbbox((0, 0), left_directory_text, font=font_bold)  # 添加"@"前缀
    directory_width, directory_height = directory_bbox[2] - directory_bbox[0], directory_bbox[3] - directory_bbox[1]
    
    # 设置左边距离为 25 像素，并且与右下角水印垂直居中
    padding_left = 25
    vertical_center = text1_position[1] + (total_text_height_regular - directory_height) // 2
    
    # 计算左下角水印的位置
    directory_position = (padding_left, vertical_center)
    
    # 绘制左下角的水印文本（目录名）
    draw.text(directory_position, left_directory_text, font=font_bold, fill=(255, 255, 255, 128))
    
    return image

def crop_center(image, crop_width, crop_height):
    img_width, img_height = image.size
    return image.crop((
        (img_width - crop_width) // 2,
        (img_height - crop_height) // 2,
        (img_width + crop_width) // 2,
        (img_height + crop_height) // 2
    ))

def process_images_in_directory(directory):
    # 获取当前日期，创建新文件夹
    current_date = datetime.now().strftime("%Y%m%d")
    output_folder = os.path.join(os.getcwd(), f"{current_date}_crop")
    os.makedirs(output_folder, exist_ok=True)
    
    for root, _, files in os.walk(directory):
        for file in files:
            if file.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp', '.gif')):
                img_path = os.path.join(root, file)
                try:
                    with Image.open(img_path) as img:
                        width, height = img.size
                        if width != height:
                            # 1. 先裁剪图片
                            min_dimension = min(width, height)
                            cropped_img = crop_center(img, min_dimension, min_dimension)
                            
                            # 2. 缩放图片至 800x800
                            resized_img = cropped_img.resize((800, 800), Image.Resampling.LANCZOS)
                            
                            # 3. 添加水印，左下角水印为所属目录名称
                            directory_name = os.path.basename(root)
                            watermarked_img = add_watermarks(resized_img, directory_name=directory_name,font_path_bold=default_font_path_bold, font_path_regular=default_font_path_regular,)
                            
                            # 保存处理后的图片到新文件夹，文件名不变
                            cropped_img_path = os.path.join(output_folder, file)
                            watermarked_img.save(cropped_img_path)
                            print(f"裁剪、缩放、添加水印并保存了图片: {cropped_img_path}")
                except Exception as e:
                    print(f"处理图片 {img_path} 时出错: {e}")

def check_font_paths(font_path_bold, font_path_regular):
    """检查字体文件是否存在，不存在则退出程序"""
    if not os.path.exists(font_path_bold):
        print(f"字体文件不存在: {font_path_bold}")
        sys.exit(1)
    if not os.path.exists(font_path_regular):
        print(f"字体文件不存在: {font_path_regular}")
        sys.exit(1)
    print("字体文件检查通过。")

if __name__ == "__main__":
    # 检查字体路径是否存在

    check_font_paths(default_font_path_bold,default_font_path_regular)
    input_directory = input("请输入要处理的目录路径：")
    process_images_in_directory(input_directory)
