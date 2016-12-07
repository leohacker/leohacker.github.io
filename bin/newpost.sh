#!/bin/bash

SCRIPT_DIR=`basename $0`

DATE=`date +%F`
TIME=`date +%T`

title=$1
name=${title// /-}

filename=${DATE}-${name}.md
touch ${filename}

cat > ${filename} << EOF
---
title: "${title}"
excerpt:
date: ${DATE} ${TIME}
modified: ${DATE}
categories: []
published: false
---
{% include toc %}

EOF
