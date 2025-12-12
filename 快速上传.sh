#!/bin/bash
# NewsCatcher 快速上传脚本

echo "=========================================="
echo "NewsCatcher 上传到 GitHub"
echo "=========================================="
echo ""

# 检查是否在正确的目录
if [ ! -f "main.py" ]; then
    echo "❌ 错误: 请在 newscatcher 目录下运行此脚本"
    exit 1
fi

# 检查 git 是否已初始化
if [ ! -d ".git" ]; then
    echo "初始化 Git 仓库..."
    git init
fi

# 检查 git 用户配置
if [ -z "$(git config user.name)" ]; then
    echo ""
    echo "⚠️  需要配置 Git 用户信息"
    read -p "请输入你的 GitHub 用户名: " GIT_USER
    read -p "请输入你的邮箱: " GIT_EMAIL
    
    git config user.name "$GIT_USER"
    git config user.email "$GIT_EMAIL"
    echo "✓ Git 用户信息已配置"
fi

# 添加文件
echo ""
echo "添加文件到 Git..."
git add .

# 检查是否有更改
if [ -z "$(git status --porcelain)" ]; then
    echo "✓ 没有需要提交的更改"
else
    echo "提交更改..."
    git commit -m "Initial commit: NewsCatcher - AI新闻总结工具"
    echo "✓ 提交完成"
fi

# 检查远程仓库
if [ -z "$(git remote -v)" ]; then
    echo ""
    echo "=========================================="
    echo "下一步：连接 GitHub 仓库"
    echo "=========================================="
    echo ""
    echo "1. 在 GitHub 创建新仓库："
    echo "   https://github.com/new"
    echo ""
    echo "2. 创建后，运行以下命令连接并推送："
    echo ""
    echo "   git remote add origin https://github.com/你的用户名/newscatcher.git"
    echo "   git branch -M main"
    echo "   git push -u origin main"
    echo ""
    read -p "如果已创建仓库，请输入仓库地址（直接回车跳过）: " REPO_URL
    
    if [ ! -z "$REPO_URL" ]; then
        git remote add origin "$REPO_URL"
        git branch -M main
        
        echo ""
        echo "正在推送到 GitHub..."
        git push -u origin main
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "✅ 代码已成功推送到 GitHub！"
            echo ""
            echo "下一步：配置 GitHub Secrets"
            echo "1. 进入仓库 Settings → Secrets and variables → Actions"
            echo "2. 添加以下 Secrets："
            echo "   - AI_API_KEY"
            echo "   - AI_BASE_URL: https://api.deepseek.com"
            echo "   - AI_MODEL: deepseek-chat"
            echo "   - FEISHU_WEBHOOK_URL"
            echo ""
            echo "详细步骤见：上传指南.md"
        else
            echo ""
            echo "❌ 推送失败，请检查："
            echo "1. 仓库地址是否正确"
            echo "2. 是否有推送权限"
            echo "3. 是否已配置 GitHub 认证"
        fi
    fi
else
    echo ""
    echo "远程仓库已配置："
    git remote -v
    echo ""
    echo "运行以下命令推送："
    echo "  git push -u origin main"
fi

