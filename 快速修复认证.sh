#!/bin/bash
# 快速清除错误的 Git 凭据

echo "清除 Git 凭据缓存..."

# 方法1：使用 git credential reject
echo "host=github.com
protocol=https" | git credential reject

echo ""
echo "✓ 凭据已清除"
echo ""
echo "现在重新推送时，系统会提示输入："
echo "  - Username: 你的GitHub用户名"
echo "  - Password: 使用 Personal Access Token（不是密码！）"
echo ""
echo "获取 Token: https://github.com/settings/tokens"
echo ""
echo "运行: git push -u origin main"
