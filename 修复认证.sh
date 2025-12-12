#!/bin/bash
# 修复 Git 认证问题脚本

echo "=========================================="
echo "修复 Git 认证问题"
echo "=========================================="
echo ""

cd "$(dirname "$0")"

# 检查是否在正确的目录
if [ ! -f "main.py" ]; then
    echo "❌ 错误: 请在 newscatcher 目录下运行此脚本"
    exit 1
fi

echo "当前远程仓库配置："
git remote -v
echo ""

# 检查远程仓库是否已配置
if [ -z "$(git remote -v)" ]; then
    echo "⚠️  远程仓库未配置"
    read -p "请输入你的 GitHub 仓库地址: " REPO_URL
    if [ ! -z "$REPO_URL" ]; then
        git remote add origin "$REPO_URL"
        echo "✓ 远程仓库已添加"
    else
        echo "❌ 未输入仓库地址，退出"
        exit 1
    fi
fi

echo ""
echo "选择修复方式："
echo "1. 清除凭据缓存（然后重新输入）"
echo "2. 使用 Personal Access Token（推荐）"
echo "3. 切换到 SSH 方式"
echo "4. 查看当前配置"
echo ""
read -p "请选择 (1-4): " choice

case $choice in
    1)
        echo ""
        echo "清除凭据缓存..."
        
        # macOS
        if [[ "$OSTYPE" == "darwin"* ]]; then
            git credential-osxkeychain erase <<EOF
host=github.com
protocol=https
EOF
            echo "✓ macOS 凭据缓存已清除"
        fi
        
        # 清除 Git 凭据配置
        git config --local --unset credential.helper 2>/dev/null
        git config --global --unset credential.helper 2>/dev/null
        
        echo "✓ 凭据配置已清除"
        echo ""
        echo "现在可以重新推送，系统会提示输入用户名和密码"
        echo "注意：GitHub 已不支持密码，需要使用 Personal Access Token"
        echo ""
        echo "运行: git push -u origin main"
        ;;
    
    2)
        echo ""
        echo "=========================================="
        echo "使用 Personal Access Token"
        echo "=========================================="
        echo ""
        echo "1. 访问：https://github.com/settings/tokens"
        echo "2. 点击 'Generate new token' → 'Generate new token (classic)'"
        echo "3. 勾选 'repo' 权限"
        echo "4. 生成并复制 Token"
        echo ""
        read -p "按回车继续..."
        
        read -p "请输入你的 GitHub 用户名: " GIT_USER
        read -p "请输入你的 Personal Access Token: " GIT_TOKEN
        
        if [ -z "$GIT_USER" ] || [ -z "$GIT_TOKEN" ]; then
            echo "❌ 用户名或 Token 不能为空"
            exit 1
        fi
        
        # 获取当前远程 URL
        CURRENT_URL=$(git remote get-url origin)
        
        # 提取仓库路径
        if [[ $CURRENT_URL == *"@"* ]]; then
            # 如果已经包含认证信息，先移除
            REPO_PATH=$(echo $CURRENT_URL | sed 's|.*@||')
        else
            REPO_PATH=$(echo $CURRENT_URL | sed 's|https://github.com/||' | sed 's|git@github.com:||')
        fi
        
        # 设置新的远程 URL（包含 Token）
        NEW_URL="https://${GIT_TOKEN}@github.com/${REPO_PATH}"
        git remote set-url origin "$NEW_URL"
        
        echo ""
        echo "✓ 远程地址已更新（包含 Token）"
        echo ""
        echo "正在推送..."
        git push -u origin main
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "✅ 推送成功！"
            echo ""
            echo "💡 提示：为了安全，建议配置凭据助手，避免 Token 出现在 URL 中"
            echo "运行: git config --global credential.helper osxkeychain"
        else
            echo ""
            echo "❌ 推送失败，请检查："
            echo "1. Token 是否正确"
            echo "2. Token 是否有 repo 权限"
            echo "3. 仓库地址是否正确"
        fi
        ;;
    
    3)
        echo ""
        echo "=========================================="
        echo "切换到 SSH 方式"
        echo "=========================================="
        echo ""
        
        # 获取当前远程 URL
        CURRENT_URL=$(git remote get-url origin)
        
        # 提取仓库路径
        if [[ $CURRENT_URL == https://* ]]; then
            REPO_PATH=$(echo $CURRENT_URL | sed 's|https://github.com/||' | sed 's|.*@github.com/||')
        elif [[ $CURRENT_URL == git@* ]]; then
            echo "✓ 已经是 SSH 方式"
            REPO_PATH=""
        else
            REPO_PATH=$(echo $CURRENT_URL | sed 's|.*github.com/||')
        fi
        
        if [ ! -z "$REPO_PATH" ]; then
            NEW_URL="git@github.com:${REPO_PATH}"
            git remote set-url origin "$NEW_URL"
            echo "✓ 已切换到 SSH 方式: $NEW_URL"
        fi
        
        echo ""
        echo "测试 SSH 连接..."
        ssh -T git@github.com 2>&1 | head -3
        
        echo ""
        echo "如果看到 'successfully authenticated'，说明 SSH 配置成功"
        echo "运行: git push -u origin main"
        ;;
    
    4)
        echo ""
        echo "当前配置："
        echo "----------------------------------------"
        echo "远程仓库："
        git remote -v
        echo ""
        echo "凭据配置："
        git config --list | grep credential || echo "未配置"
        echo ""
        echo "用户配置："
        git config user.name 2>/dev/null || echo "未配置"
        git config user.email 2>/dev/null || echo "未配置"
        ;;
    
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac

