#!/bin/bash
# 本地测试脚本 - 模拟 GitHub Actions 环境

echo "=========================================="
echo "本地测试 NewsCatcher"
echo "=========================================="
echo ""

cd "$(dirname "$0")"

# 检查配置文件
if [ ! -f "config.yaml" ]; then
    echo "❌ 错误: config.yaml 不存在"
    exit 1
fi

# 检查环境变量
echo "检查环境变量..."
if [ -z "$AI_API_KEY" ]; then
    echo "⚠️  AI_API_KEY 未设置"
    read -p "请输入 AI_API_KEY: " AI_API_KEY
    export AI_API_KEY
fi

if [ -z "$FEISHU_WEBHOOK_URL" ]; then
    echo "⚠️  FEISHU_WEBHOOK_URL 未设置"
    read -p "请输入 FEISHU_WEBHOOK_URL: " FEISHU_WEBHOOK_URL
    export FEISHU_WEBHOOK_URL
fi

if [ -z "$AI_BASE_URL" ]; then
    export AI_BASE_URL="https://api.deepseek.com"
    echo "✓ 使用默认 AI_BASE_URL: $AI_BASE_URL"
fi

if [ -z "$AI_MODEL" ]; then
    export AI_MODEL="deepseek-chat"
    echo "✓ 使用默认 AI_MODEL: $AI_MODEL"
fi

echo ""
echo "环境变量配置："
echo "  AI_API_KEY: ${AI_API_KEY:0:10}..."
echo "  AI_BASE_URL: $AI_BASE_URL"
echo "  AI_MODEL: $AI_MODEL"
echo "  FEISHU_WEBHOOK_URL: ${FEISHU_WEBHOOK_URL:0:30}..."
echo ""

# 运行程序
echo "开始运行..."
python3 main.py

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ 测试成功！"
else
    echo "❌ 测试失败，退出码: $EXIT_CODE"
fi

exit $EXIT_CODE

