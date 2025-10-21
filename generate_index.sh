#!/bin/bash
find . -type d -not -path "./.git/*" -not -path "./.github/*" | while read dir; do
  if [ "$dir" = "." ]; then
    current_path="/"
  else
    current_path="/${dir#./}"
  fi
  echo "<!DOCTYPE html><html><head><meta charset=\"UTF-8\"><title>File List - $current_path</title><style>body{font-family:Arial;margin:40px;}ul{list-style:none;padding:0;}li{margin:8px 0;}a{text-decoration:none;color:#0366d6;}a:hover{text-decoration:underline;}.dir{font-weight:bold;}.path{color:#666;margin-bottom:20px;}</style></head><body><h1>File List</h1><div class=\"path\">Current directory: <strong>$current_path</strong></div><ul>" > "$dir/index.html"
  if [ "$dir" != "." ]; then echo "<li><a href=\"../\" class=\"dir\">../</a></li>" >> "$dir/index.html"; fi
  for item in "$dir"/*; do
    if [ -e "$item" ]; then
      name=$(basename "$item")
      if [ "$name" != "index.html" ] && [ "$name" != ".git" ]; then
        if [ -d "$item" ]; then
          echo "<li><a href=\"$name/\" class=\"dir\">$name/</a></li>" >> "$dir/index.html"
        else
          echo "<li><a href=\"$name\">$name</a></li>" >> "$dir/index.html"
        fi
      fi
    fi
  done
  echo "</ul></body></html>" >> "$dir/index.html"
done
