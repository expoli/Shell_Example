#!/usr/bin/env bash
set -x
CONVERT_BIN_PATH="/usr/bin/convert"

function help() {
    echo && echo -e "    -q Q               对jpeg格式图片进行图片质量因子为Q的压缩
    -r R               对jpeg/png/svg格式图片在保持原始宽高比的前提下压缩成R分辨率
    -w font_size text  对图片批量添加自定义文本水印
    -p text            统一添加文件名前缀，不影响原始文件扩展名
    -s text            统一添加文件名后缀，不影响原始文件扩展名
    -t                 将png/svg图片统一转换为jpg格式图片
    -h                 帮助文档 " && echo
}

function install_dependent() {
    if [[ -f ${CONVERT_BIN_PATH} ]]; then
        return
    else
        eval "$(sudo apt install imagemagick -y)"
    fi
}
# 对jpeg格式图片进行图片质量压缩
# convert filename1 -quality 50 filename2
# https://imagemagick.org/script/command-line-options.php#quality
function image_mass_compress() {
    Q=$1
    for i in *; do
        type=$(file "${i}" | awk '{printf $2}')
        if [[ ${type} == "JPEG" ]]; then
            convert "${i}" -quality "${Q}" "${i}"
            echo "${i} compress success!"
        else
            continue
        fi
    done
}

# 对jpeg/png/svg格式图片在保持原始宽高比的前提下压缩分辨率
# Compress the resolution of pictures in jpeg/png/svg format while maintaining the original aspect ratio
# convert filename1 -resize 50% filename2
# https://imagemagick.org/script/command-line-options.php#resize
# https://imagemagick.org/script/command-line-options.php#sample
function image_resolution_compress() {
    R=$1
    for i in *; do
        type=$(file "${i}" | awk '{printf $2}')
        if [[ ${type} == "JPEG" || ${type} == "PNG" || ${type} == "SVG" ]]; then
            convert -resize "${R}" "${i}"
            echo "${i} is resized."
        else
            continue
        fi
    done
}

# 对图片批量添加自定义文本水印
# Add custom text watermarks to pictures in batches
# convert filename1 -pointsize 50 -fill black -gravity center -draw "text 10,10 'Works like magick' " filename2
# https://imagemagick.org/script/command-line-options.php#draw
function add_watermarks_to_image() {
    for i in *; do
        type=$(file "${i}" | awk '{printf $2}')
        if [[ ${type} != "JPEG" && ${type} != "PNG" && ${type} != "SVG" ]]; then
            continue
        fi
        convert "${i}" -pointsize "$1" -fill black -gravity center -draw "text 10,10 '$2'" "${i}"
        echo "${i} is watermarked with $2."
    done
}

# 批量重命名（统一添加文件名前缀或后缀，不影响原始文件扩展名）
# Batch rename (add the prefix or suffix of the file name uniformly, without affecting the original file extension)
function batch_rename() {
    for i in *; do
        type=$(file "${i}" | awk '{printf $2}')
        if [[ ${type} != "JPEG" && ${type} != "PNG" && ${type} != "SVG" ]]; then
            continue
        fi
        convert "${i}" -pointsize "$1" -fill black -gravity center -draw "text 10,10 '$2'" "${i}"
        echo "${i} is watermarked with $2."
    done
}

# 将png/svg图片统一转换为jpg格式图片
# Convert png/svg pictures into jpg format pictures uniformly
# convert xxx.png xxx.jpg
function image_format_conver() {
    for i in *; do
        type=$(file "${i}" | awk '{printf $2}')
        if [[ ${type} != "JPEG" && ${type} != "PNG" && ${type} != "SVG" ]]; then
            continue
        fi
        filename=${i%.*}".jpg"
        convert "${i}" "${filename}"
        echo "${i} is transformed to ${filename}"
    done
}

# 批量重命名（统一添加文件名前缀或后缀，不影响原始文件扩展名）
# mv filename1 filename2
function prefix {
    for i in *; do
        type=$(file "${i}" | awk '{printf $2}')
        if [[ ${type} != "JPEG" && ${type} != "PNG" && ${type} != "SVG" ]]; then
            continue
        fi
        mv "${i}" "$1""${i}"
        echo "${i} is renamed to $1${i}"
    done
}
function suffix {
    for i in *; do
        type=$(file "${i}" | awk '{printf $2}')
        if [[ ${type} != "JPEG" && ${type} != "PNG" && ${type} != "SVG" ]]; then
            continue
        fi
        filename=${i%.*}$1"."${type}
        mv "${i}" "${filename}"
        echo "${i} is renamed to ${filename}"
    done
}

case "$1" in
"-q")
    image_mass_compress "$2"
    exit 0
    ;;
"-r")
    image_resolution_compress "$2"
    exit 0
    ;;
"-w")
    add_watermarks_to_image "$2" "$3"
    exit 0
    ;;
"-p")
    prefix "$2"
    exit 0
    ;;
"-s")
    suffix "$2"
    exit 0
    ;;
"-t")
    image_format_conver
    exit 0
    ;;
"-h")
    help
    exit 0
    ;;
*)
    help
    exit 0
    ;;
esac
