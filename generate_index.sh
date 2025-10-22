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
  items=$(find "$dir" -maxdepth 1 -mindepth 1 -not -name "index.html" -not -name ".git" -not -path "./.github/*" -exec ls -td {} + | sort -f)
  echo "$items" | while read item; do
    if [ -e "$item" ]; then
      name=$(basename "$item")
      if [ -d "$item" ]; then
        class="dir"
        name="$name/"
        size="-"
      else
        class=""
        size=$(ls -lh "$item" | awk '{print $5}')
      fi
      mod_time=$(ls -l --time-style="+%Y-%m-%d %H:%M" "$item" | awk '{print $6, $7}')
      echo "<tr><td><a href=\"$name\" class=\"$class\">$name</a></td><td>$size</td><td>$mod_time</td></tr>" >> "$dir/index.html"
    fi
  done
  echo "</table></body></html>" >> "$dir/index.html"
}
find . -type d -not -path "./.git/*" -not -path "./.github/*" | while read dir; do
  generate_index "$dir"
done
