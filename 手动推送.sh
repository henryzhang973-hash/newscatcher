#!/bin/bash
# 手动推送脚本 - 使用正确的用户名

cd "$(dirname "$0")"

echo "=========================================="
echo "手动推送 NewsCatcher 到 GitHub"
echo "=========================================="
echo ""

# 设置正确的远程地址
echo "设置远程仓库地址..."
git remote set-url origin https://github.com/henryzhang973-hash/newscatcher.git

echo "当前远程配置："
git remote -v
echo ""

# 检查是否有提交
if [ -z "$(git log --oneline 2>/dev/null)" ]; then
    echo "⚠️  还没有提交，正在提交代码..."
    
    # 配置用户信息（如果还没配置）
    if [ -z "$(git config user.name)" ]; then
        git config user.name "henryzhang973-hash"
        git config user.email "henryzhang973@gmail.com"
    fi
    
    git add .
    git commit -m "Initial commit: NewsCatcher - AI新闻总结工具"
    echo "✓ 代码已提交"
fi

echo ""
echo "准备推送..."
echo ""
echo "⚠️  重要：GitHub 需要使用 Personal Access Token"
echo ""
read -p "请输入你的 Personal Access Token: " GIT_TOKEN

if [ -z "$GIT_TOKEN" ]; then
    echo "❌ Token 不能为空"
    exit 1
fi

# 使用 Token 设置远程 URL
git remote set-url origin https://${GIT_TOKEN}@github.com/henryzhang973-hash/newscatcher.git

echo ""
echo "正在推送到 GitHub..."
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 推送成功！"
    echo ""
    echo "下一步：配置 GitHub Secrets"
    echo "1. 进入仓库 Settings → Secrets and variables → Actions"
    echo "2. 添加必需的 Secrets（见 GitHub-Secrets配置指南.md）"
else
    echo ""
    echo "❌ 推送失败"
    echo ""
    echo "可能的原因："
    echo "1. Token 不正确或已过期"
    echo "2. Token 没有 repo 权限"
    echo "3. 仓库不存在（需要先在 GitHub 创建）"
    echo ""
    echo "检查："
    echo "1. Token 是否有 'repo' 权限"
    echo "2. 仓库地址是否正确：https://github.com/henryzhang973-hash/newscatcher"
fi

