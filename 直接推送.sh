#!/bin/bash
# 直接推送 - 使用 Token 环境变量

cd "$(dirname "$0")"

echo "=========================================="
echo "直接推送 NewsCatcher"
echo "=========================================="
echo ""

# 确保远程地址正确
git remote set-url origin https://github.com/henryzhang973-hash/newscatcher.git

echo "当前配置："
echo "  远程地址: $(git remote get-url origin)"
echo "  本地分支: $(git branch --show-current)"
echo ""

# 检查 Token 环境变量
if [ -z "$GITHUB_TOKEN" ]; then
    echo "⚠️  未设置 GITHUB_TOKEN 环境变量"
    echo ""
    read -p "请输入你的 Personal Access Token: " GITHUB_TOKEN
    export GITHUB_TOKEN
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Token 不能为空"
    exit 1
fi

# 使用 Token 设置远程 URL
git remote set-url origin https://${GITHUB_TOKEN}@github.com/henryzhang973-hash/newscatcher.git

echo ""
echo "正在推送到 GitHub..."
echo ""

# 尝试推送
git push -u origin main 2>&1

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✅ 推送成功！"
    echo ""
    echo "下一步："
    echo "1. 访问：https://github.com/henryzhang973-hash/newscatcher"
    echo "2. 配置 GitHub Secrets（见 GitHub-Secrets配置指南.md）"
else
    echo ""
    echo "❌ 推送失败（退出码: $EXIT_CODE）"
    echo ""
    echo "可能的原因和解决方法："
    echo ""
    echo "1. 仓库不存在"
    echo "   解决：访问 https://github.com/new 创建仓库 'newscatcher'"
    echo ""
    echo "2. Token 无效或权限不足"
    echo "   解决："
    echo "   - 检查 Token 是否有 'repo' 权限"
    echo "   - 生成新 Token：https://github.com/settings/tokens"
    echo ""
    echo "3. Token 已过期"
    echo "   解决：生成新的 Token"
    echo ""
    echo "4. 网络问题"
    echo "   解决：检查网络连接，或稍后重试"
    echo ""
    echo "详细错误信息请查看上方输出"
fi

# 清除 URL 中的 Token（安全考虑）
git remote set-url origin https://github.com/henryzhang973-hash/newscatcher.git

