#!/bin/bash

if ! [ -x "$(command -v npx)" ]; then
    echo "please install node.js, and run this bash again."
    exit
fi

target_process="XMind"
target_app_path="/Applications/XMind.app"
target_asar_path="$target_app_path/Contents/Resources/app.asar"
target_asar_bak_path="$target_asar_path.bak"
root_dir="$(mktemp -d)"
tmp_asar_folder="$root_dir/extract"
tmp_asar_path="$root_dir/app.asar"

if [ ! -f "$target_asar_path" ]; then
    echo "$target_asar_path not existed, please install XMind ZEN first."
    exit
fi

number=$(ps aux | grep -v grep | grep -ci $target_process)
if [ $number -gt 0 ]; then
    echo "XMind is runing"
    read -p "press enter to kill XMind..."
    killall $target_process
fi

if [ -f "$target_asar_bak_path" ]; then
    echo "$target_asar_bak_path exist, crack again?"
    read -p "press enter to continue..."
fi

echo "unpack asar into $tmp_asar_folder"
npx asar extract "$target_asar_path" "$tmp_asar_folder"

echo "replace strings..."
sed -i '' 's/{TRIAL:"trial",VALID:"valid",EXPIRED:"expired"}/{TRIAL:"trial",VALID:"trial",EXPIRED:"trial"}/g' "$tmp_asar_folder/main/main.js" "$tmp_asar_folder/renderer/common.js"

echo "pack asar into $tmp_asar_path"
npx asar pack "$tmp_asar_folder" "$tmp_asar_path"

echo "backup original file..."
mv "$target_asar_path" "$target_asar_bak_path"

echo "copy cracked file to target..."
cp "$tmp_asar_path" "$target_asar_path"

echo "remove temp folder..."
rm -rf "$root_dir"

echo "xattr $target_app_path"
xattr -cr "$target_app_path"

echo "done"