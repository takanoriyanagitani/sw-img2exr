#!/bin/sh

imgname=~/Downloads/PNG_transparency_demonstration_1.png
outname=./sample.d/output.exr

mkdir -p sample.d

cat $imgname |
  curl \
    --request POST \
    --header 'Content-Type: application/octet-stream' \
    --data-binary @- \
    --silent \
    --show-error \
    --fail \
    --location \
    http://127.0.0.1:61280/img2exr |
    dd \
      if=/dev/stdin \
      of="${outname}" \
      bs=1048576 \
      status=progress

file "${outname}"
ls -lSh \
  "${imgname}" \
  "${outname}"
