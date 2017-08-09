#!/bin/bash

pushd . > /dev/null
SCRIPT_DIR=$(dirname $0)
POST_DIR=${SCRIPT_DIR}/../_posts

cd ${POST_DIR}

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

popd
