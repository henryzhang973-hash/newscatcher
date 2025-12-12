#!/bin/bash
# 诊断并推送脚本

cd "$(dirname "$0")"

echo "=========================================="
echo "NewsCatcher 诊断和推送"
echo "=========================================="
echo ""

# 1. 检查配置
echo "1. 检查 Git 配置..."
echo "   远程地址: $(git remote get-url origin)"
echo "   用户名: $(git config user.name)"
echo "   邮箱: $(git config user.email)"
echo ""

# 2. 确保远程地址正确
git remote set-url origin https://github.com/henryzhang973-hash/newscatcher.git
echo "✓ 远程地址已设置为正确的用户名"
echo ""

# 3. 检查本地提交
echo "2. 检查本地提交..."
COMMIT_COUNT=$(git log --oneline | wc -l | tr -d ' ')
echo "   本地提交数: $COMMIT_COUNT"
if [ "$COMMIT_COUNT" -eq 0 ]; then
    echo "   ⚠️  还没有提交，正在提交..."
    git add .
    git commit -m "Initial commit: NewsCatcher - AI新闻总结工具" || {
        echo "   ❌ 提交失败，请检查文件状态"
        exit 1
    }
    echo "   ✓ 代码已提交"
fi
echo ""

# 4. 测试远程连接
echo "3. 测试远程仓库连接..."
if git ls-remote origin &>/dev/null; then
    echo "   ✓ 远程仓库可访问"
    REMOTE_EXISTS=true
else
    echo "   ⚠️  无法访问远程仓库"
    echo "   可能原因："
    echo "   1. 仓库尚未创建"
    echo "   2. Token 无效或权限不足"
    echo "   3. 网络问题"
    REMOTE_EXISTS=false
fi
echo ""

# 5. 获取 Token
echo "4. 准备推送..."
if [ -z "$GITHUB_TOKEN" ]; then
    echo ""
    echo "请输入你的 Personal Access Token"
    echo "（获取地址：https://github.com/settings/tokens）"
    echo ""
    read -sp "Token: " GITHUB_TOKEN
    echo ""
    echo ""
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Token 不能为空"
    exit 1
fi

# 6. 设置带 Token 的远程 URL
git remote set-url origin https://${GITHUB_TOKEN}@github.com/henryzhang973-hash/newscatcher.git

# 7. 推送
echo "5. 正在推送到 GitHub..."
echo "   仓库: https://github.com/henryzhang973-hash/newscatcher"
echo "   分支: main"
echo ""

git push -u origin main 2>&1

EXIT_CODE=$?

# 清除 URL 中的 Token
git remote set-url origin https://github.com/henryzhang973-hash/newscatcher.git

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "=========================================="
    echo "✅ 推送成功！"
    echo "=========================================="
    echo ""
    echo "下一步："
    echo "1. 访问仓库：https://github.com/henryzhang973-hash/newscatcher"
    echo "2. 配置 GitHub Secrets："
    echo "   Settings → Secrets and variables → Actions"
    echo "3. 添加以下 Secrets："
    echo "   - AI_API_KEY"
    echo "   - AI_BASE_URL: https://api.deepseek.com"
    echo "   - AI_MODEL: deepseek-chat"
    echo "   - FEISHU_WEBHOOK_URL"
    echo ""
    echo "详细步骤见：GitHub-Secrets配置指南.md"
else
    echo "=========================================="
    echo "❌ 推送失败"
    echo "=========================================="
    echo ""
    echo "错误代码: $EXIT_CODE"
    echo ""
    echo "常见问题和解决方法："
    echo ""
    echo "1. 仓库不存在"
    echo "   解决："
    echo "   a) 访问 https://github.com/new"
    echo "   b) 仓库名：newscatcher"
    echo "   c) 选择 Public 或 Private"
    echo "   d) 不要勾选 'Initialize with README'"
    echo "   e) 点击 'Create repository'"
    echo ""
    echo "2. Token 无效"
    echo "   解决："
    echo "   a) 检查 Token 是否有 'repo' 权限"
    echo "   b) 生成新 Token：https://github.com/settings/tokens"
    echo "   c) 确保 Token 未过期"
    echo ""
    echo "3. 权限不足"
    echo "   解决：确保 Token 有 'repo' 权限"
    echo ""
    echo "4. 网络问题"
    echo "   解决：检查网络连接，稍后重试"
    echo ""
    echo "如果问题持续，请查看上方的详细错误信息"
fi

