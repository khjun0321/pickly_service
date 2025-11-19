#!/bin/bash
echo "🪄 Fixing Freezed mixin formatting bug..."

for f in $(find lib -name "*.freezed.dart"); do
  echo "Processing $f"
  
  # Use awk to properly format all lines within the mixin block
  # Find the mixin _$ block and add newlines after semicolons
  awk '
    /^mixin _\$/ {in_mixin=1}
    in_mixin && /^\s*String get|^\s*int get|^\s*bool get|^\s*DateTime get|^\s*Map<String, dynamic> get/ {
      # Split on semicolons and add newlines
      gsub(/;[[:space:]]*String/, ";\nString")
      gsub(/;[[:space:]]*int/, ";\nint")
      gsub(/;[[:space:]]*bool/, ";\nbool")
      gsub(/;[[:space:]]*DateTime/, ";\nDateTime")
      gsub(/;[[:space:]]*Map/, ";\nMap")
      gsub(/;[[:space:]]*@JsonKey/, ";\n@JsonKey")
    }
    /^\s*\/\/\/ Create a copy of/ {in_mixin=0}
    {print}
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done

echo "✅ Freezed formatting complete!"
