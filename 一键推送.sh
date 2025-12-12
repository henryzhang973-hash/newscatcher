#!/bin/bash
# 一键推送脚本 - 复制粘贴所有命令

cd /Users/henryzhang/TrendRadar/newscatcher

echo "=========================================="
echo "NewsCatcher 一键推送"
echo "=========================================="
echo ""

# 1. 配置用户
echo "1. 配置 Git 用户..."
git config user.name "henryzhang973-hash"
git config user.email "henryzhang973@gmail.com"
echo "   ✓ 用户配置完成"
echo ""

# 2. 设置远程仓库
echo "2. 设置远程仓库..."
git remote set-url origin https://github.com/henryzhang973-hash/newscatcher.git
echo "   ✓ 远程仓库已设置"
echo ""

# 3. 检查并提交
echo "3. 检查代码状态..."
if [ -n "$(git status --porcelain)" ]; then
    echo "   发现未提交的文件，正在提交..."
    git add .
    git commit -m "Initial commit: NewsCatcher - AI新闻总结工具"
    echo "   ✓ 代码已提交"
else
    echo "   ✓ 代码已是最新"
fi
echo ""

# 4. 获取 Token
echo "4. 准备推送..."
if [ -z "$1" ]; then
    echo ""
    echo "请输入你的 Personal Access Token："
    echo "（获取地址：https://github.com/settings/tokens）"
    echo ""
    read -p "Token: " GITHUB_TOKEN
else
    GITHUB_TOKEN="$1"
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Token 不能为空"
    echo ""
    echo "使用方法："
    echo "  ./一键推送.sh 你的token"
    exit 1
fi

# 5. 推送
echo ""
echo "5. 正在推送到 GitHub..."
git remote set-url origin https://${GITHUB_TOKEN}@github.com/henryzhang973-hash/newscatcher.git
git push -u origin main

EXIT_CODE=$?

# 清除 Token
git remote set-url origin https://github.com/henryzhang973-hash/newscatcher.git

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "=========================================="
    echo "✅ 推送成功！"
    echo "=========================================="
    echo ""
    echo "访问仓库：https://github.com/henryzhang973-hash/newscatcher"
    echo ""
    echo "下一步：配置 GitHub Secrets"
    echo "Settings → Secrets and variables → Actions"
else
    echo "=========================================="
    echo "❌ 推送失败"
    echo "=========================================="
    echo ""
    echo "请检查："
    echo "1. 仓库是否已创建"
    echo "2. Token 是否正确"
    echo "3. Token 是否有 repo 权限"
fi
