#!/bin/bash
generate_index() {
  dir="$1"
  if [ "$dir" = "." ]; then
    current_path="/"
  else
    current_path="/${dir#./}"
  fi
  echo "<!DOCTYPE html><html><head><meta charset=\"UTF-8\"><title>Index of $current_path</title><style>body{font-family:Arial;margin:20px;}table{width:100%;border-collapse:collapse;}th,td{padding:8px;text-align:left;border-bottom:1px solid #ddd;}th{background-color:#f2f2f2;}a{text-decoration:none;color:#0366d6;}a:hover{text-decoration:underline;}.dir{font-weight:bold;}</style></head><body><h1>Index of $current_path</h1><table><tr><th>Name</th><th>Size</th><th>Last Modified</th></tr>" > "$dir/index.html"
  if [ "$dir" != "." ]; then echo "<tr><td><a href=\"../\" class=\"dir\">../</a></td><td>-</td><td></td></tr>" >> "$dir/index.html"; fi
  # Get all items in directory except index.html, .git and .github
  items=$(find "$dir" -maxdepth 1 -mindepth 1 -not -name "index.html" -not -name ".git" -not -path "./.github/*")
  # Process each item and get Git timestamp for sorting
  echo "$items" | while read item; do
    if [ -e "$item" ]; then
      name=$(basename "$item")
      if [ -d "$item" ]; then
        # For directories, find all files in the directory except index.html and get the latest commit time
        timestamp=0
        for file in $(find "$item" -type f -not -name "index.html"); do
          file_timestamp=$(git log -1 --format="%ct" -- "$file" 2>/dev/null)
          if [ -n "$file_timestamp" ] && [ "$file_timestamp" -gt "$timestamp" ]; then
            timestamp=$file_timestamp
          fi
        done
        # If no files found (empty directory), use directory creation time
        if [ "$timestamp" -eq 0 ]; then
          timestamp=$(git log -1 --format="%ct" -- "$item" 2>/dev/null)
        fi
        class="dir"
        name="$name/"
        size="-"
      else
        # For files, get the latest commit time
        timestamp=$(git log -1 --format="%ct" -- "$item" 2>/dev/null)
        class=""
        # Get file size from Git
        size=$(git cat-file -s HEAD:"$item" 2>/dev/null)
        if [ -n "$size" ]; then
          if [ $size -ge 1048576 ]; then
            size=$(echo "scale=1; $size/1048576" | bc)MB
          elif [ $size -ge 1024 ]; then
            size=$(echo "scale=1; $size/1024" | bc)KB
          else
            size="${size}B"
          fi
        else
          size="-"
        fi
      fi
      # Convert timestamp to readable format
      if [ -n "$timestamp" ]; then
        mod_time=$(date -d "@$timestamp" "+%Y-%m-%d %H:%M" 2>/dev/null)
      else
        mod_time=""
      fi
      # Output for sorting
      echo "$timestamp|$class|$name|$size|$mod_time|$item"
    fi
  done | sort -t"|" -k1,1nr | while IFS="|" read -r timestamp class name size mod_time item; do
    echo "<tr><td><a href=\"$name\" class=\"$class\">$name</a></td><td>$size</td><td>$mod_time</td></tr>" >> "$dir/index.html"
  done
  echo "</table></body></html>" >> "$dir/index.html"
}
find . -type d -not -path "./.git/*" -not -path "./.github/*" | while read dir; do
  generate_index "$dir"
done
