#!/bin/bash
set -e

DESTINATION="id=82305935-F792-49A9-9D4D-89305FF7A62F"
DERIVED_DATA="build"
SCHEME="Wherer"
BUNDLE_ID="com.kane.wherer"

echo "=========================================="
echo "🧪 Wherer UI 自动化测试"
echo "=========================================="
echo ""

if ! xcodebuild -project Wherer.xcodeproj -list 2>/dev/null | grep -q "WhererUITests"; then
    echo "❌ 错误：未找到 WhererUITests target"
    exit 1
fi

echo "🚀 启动模拟器..."
open -a Simulator 2>/dev/null || true
sleep 2

echo "🔨 编译并运行 UI 测试..."
echo "   Scheme:   $SCHEME"
echo "   Device:   iPhone 17 Pro (iOS 26.4)"
echo ""

xcodebuild test \
    -project Wherer.xcodeproj \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -derivedDataPath "$DERIVED_DATA" \
    -only-testing:WhererUITests \
    2>&1 | tee build/ui-test-output.log | while IFS= read -r line; do
        if echo "$line" | grep -q "Test case.*started"; then
            echo ""
            echo "▶️  $(echo "$line" | sed 's/.*Test case/Test case/')"
        elif echo "$line" | grep -q "Test case.*passed"; then
            echo "✅ $(echo "$line" | sed 's/.*Test case/Test case/')"
        elif echo "$line" | grep -q "Test case.*failed"; then
            echo "❌ $(echo "$line" | sed 's/.*Test case/Test case/')"
        elif echo "$line" | grep -q "TEST SUCCEEDED"; then
            echo ""
            echo "🎉 TEST SUCCEEDED"
        elif echo "$line" | grep -q "TEST FAILED"; then
            echo ""
            echo "💥 TEST FAILED"
        fi
    done

EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo "=========================================="
echo "📋 提取测试日志..."
echo "=========================================="

# 从模拟器沙盒提取日志文件
LOG_PATH=$(xcrun simctl get_app_container "$DESTINATION" "$BUNDLE_ID" documents 2>/dev/null || true)
if [ -n "$LOG_PATH" ] && [ -f "$LOG_PATH/ui-test-log.txt" ]; then
    mkdir -p ui-test-reports
    cp "$LOG_PATH/ui-test-log.txt" ui-test-reports/
    echo ""
    echo "📄 测试步骤日志："
    echo "──────────────────────────────────────────"
    cat ui-test-reports/ui-test-log.txt
    echo "──────────────────────────────────────────"
else
    echo "⚠️  未找到测试日志文件（ui-test-log.txt）"
fi

echo ""
echo "=========================================="
echo "📸 提取测试截图..."
echo "=========================================="

XCRESULT=$(find "$DERIVED_DATA"/Logs/Test -maxdepth 1 -name "*.xcresult" -type d 2>/dev/null | sort -r | head -1)
mkdir -p .screenshots

if [ -n "$XCRESULT" ]; then
    # 用 xcresulttool 提取附件（截图）
    xcrun xcresulttool get --legacy --format json --path "$XCRESULT" 2>/dev/null | \
        python3 -c "
import json, sys, os, base64, pathlib

def extract_attachments(d, out_dir='.screenshots'):
    os.makedirs(out_dir, exist_ok=True)
    if isinstance(d, dict):
        if d.get('_type', {}).get('_name') == 'ActionTestAttachment':
            name = d.get('name', {}).get('_value', 'screenshot')
            payload = d.get('payload', {})
            if payload and '_value' in payload:
                data = base64.b64decode(payload['_value'])
                path = os.path.join(out_dir, f'{name}.png')
                with open(path, 'wb') as f:
                    f.write(data)
                print(f'📸 {name}.png')
        for v in d.values():
            extract_attachments(v, out_dir)
    elif isinstance(d, list):
        for item in d:
            extract_attachments(item, out_dir)

data = json.load(sys.stdin)
extract_attachments(data)
" 2>/dev/null || true
fi

SCREENSHOT_COUNT=$(ls .screenshots/*.png 2>/dev/null | wc -l | tr -d ' ')
if [ "$SCREENSHOT_COUNT" -gt 0 ]; then
    echo ""
    echo "✅ 已提取 $SCREENSHOT_COUNT 张截图到 .screenshots/"
    ls -1 .screenshots/*.png | sed 's/^/   /'
else
    echo "⚠️  未提取到截图"
fi

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ 所有测试通过！"
else
    echo "❌ 测试失败，请查看上面的详细日志"
fi

echo ""
echo "💡 在 Xcode 中查看 Test Report："
echo "   Cmd+6 打开 Test Navigator → 选择最新运行记录"
echo "   点击每个测试可以看到步骤树和截图"
echo ""
