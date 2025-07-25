#!/bin/bash

# Mapping of old fontSize values to new ones
declare -A FONT_SIZE_MAP=(
  [48]=36
  [28]=22
  [26]=20
  [24]=18
  [20]=16
  [18]=15
  [16]=14
  [14]=13
  [13]=12
  [12]=11
)

echo "📁 Scanning .dart files for fontSize replacements..."

# Iterate through font sizes in descending order to avoid conflicting changes
for old_size in "${!FONT_SIZE_MAP[@]}"; do
  new_size=${FONT_SIZE_MAP[$old_size]}
  echo "🔄 Replacing fontSize: $old_size → $new_size"
  find . -type f -name "*.dart" -exec sed -i "s/fontSize: $old_size/fontSize: $new_size/g" {} +
done

echo "✅ All font sizes updated safely."
