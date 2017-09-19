#!/bin/sh
set -v

if [ "$#" -ne "1" ]; then
  exit 0
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
cd "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

filename=${1}.strings
find ./ -name ${filename} -type f | while read file
do
    new=${file%/*}/InfoPlist.strings
    mv "$file" "$new"
done

