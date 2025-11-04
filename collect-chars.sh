#!/bin/bash
# collect-chars.sh

# 构建 Hugo 站点
hugo

# 提取所有 HTML 文件中的文字字符
find public -name "*.html" -exec cat {} \; | \
  grep -o . | sort | uniq | \
  tr -d '\n' > characters.txt

cat characters.txt

rm -f static/fonts/XiaolaiSC-Regular-subset.woff2
pyftsubset static/fonts/XiaolaiSC-Regular.woff2 --text-file=characters.txt --output-file=static/fonts/XiaolaiSC-Regular-subset.woff2 --flavor=woff2
rm -f characters.txt