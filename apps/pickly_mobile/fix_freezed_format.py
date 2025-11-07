#!/usr/bin/env python3
import re
import sys

def fix_freezed_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Find the mixin block and fix concatenated getters
    lines = content.split('\n')
    fixed_lines = []
    in_mixin = False
    
    for line in lines:
        if re.match(r'^mixin _\$', line):
            in_mixin = True
            fixed_lines.append(line)
        elif in_mixin and (line.startswith('///') or line.startswith('@JsonKey(includeFromJson')):
            in_mixin = False
            fixed_lines.append(line)
        elif in_mixin:
            # Split on semicolons followed by type declarations
            fixed = re.sub(r';\s*(@JsonKey.*?String|String|int|bool|DateTime|Map<String, dynamic>)', r';\n\1', line)
            fixed_lines.append(fixed)
        else:
            fixed_lines.append(line)
    
    with open(filepath, 'w') as f:
        f.write('\n'.join(fixed_lines))
    
    print(f"Fixed: {filepath}")

if __name__ == '__main__':
    import glob
    freezed_files = glob.glob('lib/**/*.freezed.dart', recursive=True)
    for f in freezed_files:
        fix_freezed_file(f)
    print(f"✅ Fixed {len(freezed_files)} files")
