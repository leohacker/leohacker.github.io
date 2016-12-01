#!/bin/bash

set -x
# Pls set the BLOG env to blog root.
draft=${BLOG}/_drafts

DATE=`date +%F`
TIME=`date +%T`

title=$1
name=${title// /-}

cd ${draft}
filename=${DATE}-${name}.md
touch ${filename}

cat > ${filename} << EOF
---
title: "${title}"
excerpt:
date: ${DATE} ${TIME}
categories: []
published: false
---
{% include toc %}

EOF
set +x
