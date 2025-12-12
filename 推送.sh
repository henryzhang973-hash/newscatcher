#!/bin/bash
# 简化版推送脚本 - 支持多种输入方式

cd "$(dirname "$0")"

echo "=========================================="
echo "NewsCatcher 推送到 GitHub"
echo "=========================================="
echo ""

# 确保远程地址正确
git remote set-url origin https://github.com/henryzhang973-hash/newscatcher.git

# 方法1: 从命令行参数获取 Token
if [ ! -z "$1" ]; then
    GITHUB_TOKEN="$1"
    echo "✓ 使用命令行参数中的 Token"
# 方法2: 从环境变量获取
elif [ ! -z "$GITHUB_TOKEN" ]; then
    echo "✓ 使用环境变量 GITHUB_TOKEN"
# 方法3: 从文件读取（如果存在）
elif [ -f ".github_token" ]; then
    GITHUB_TOKEN=$(cat .github_token | tr -d '\n\r ')
    echo "✓ 从 .github_token 文件读取 Token"
# 方法4: 交互式输入
else
    echo ""
    echo "请选择 Token 输入方式："
    echo "1. 直接在命令行输入（推荐）"
    echo "2. 从文件读取（需要先创建 .github_token 文件）"
    echo "3. 使用环境变量（export GITHUB_TOKEN='你的token'）"
    echo ""
    read -p "请选择 (1-3，直接回车使用方式1): " choice
    choice=${choice:-1}
    
    case $choice in
        1)
            echo ""
            echo "请输入你的 Personal Access Token："
            echo "（输入时不会显示，输入完成后按回车）"
            read -s GITHUB_TOKEN
            echo ""
            ;;
        2)
            if [ -f ".github_token" ]; then
                GITHUB_TOKEN=$(cat .github_token | tr -d '\n\r ')
            else
                echo "❌ .github_token 文件不存在"
                echo "创建方法：echo '你的token' > .github_token"
                exit 1
            fi
            ;;
        3)
            if [ -z "$GITHUB_TOKEN" ]; then
                echo "❌ 环境变量 GITHUB_TOKEN 未设置"
                echo "设置方法：export GITHUB_TOKEN='你的token'"
                exit 1
            fi
            ;;
    esac
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Token 不能为空"
    echo ""
    echo "使用方法："
    echo "  方式1: ./推送.sh 你的token"
    echo "  方式2: export GITHUB_TOKEN='你的token' && ./推送.sh"
    echo "  方式3: echo '你的token' > .github_token && ./推送.sh"
    exit 1
fi

echo ""
echo "正在推送到 GitHub..."
echo "仓库: https://github.com/henryzhang973-hash/newscatcher"
echo ""

# 使用 Token 设置远程 URL
git remote set-url origin https://${GITHUB_TOKEN}@github.com/henryzhang973-hash/newscatcher.git

# 推送
git push -u origin main 2>&1

EXIT_CODE=$?

# 清除 URL 中的 Token（安全考虑）
git remote set-url origin https://github.com/henryzhang973-hash/newscatcher.git

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ 推送成功！"
    echo ""
    echo "下一步：配置 GitHub Secrets"
    echo "访问：https://github.com/henryzhang973-hash/newscatcher/settings/secrets/actions"
else
    echo "❌ 推送失败（退出码: $EXIT_CODE）"
    echo ""
    echo "可能的原因："
    echo "1. 仓库不存在 - 请先创建：https://github.com/new"
    echo "2. Token 无效 - 检查权限和有效性"
    echo "3. 网络问题 - 稍后重试"
fi

