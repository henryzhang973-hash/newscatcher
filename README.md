# NewsCatcher - 新闻热点 AI 总结工具

自动抓取各平台热点新闻，使用 AI 生成要点总结并推送到飞书。

## ✨ 功能特点

- ✅ 自动抓取 11+ 平台前10条热点新闻
- ✅ AI 智能总结（支持 OpenAI/DeepSeek 等）
- ✅ 自动推送到飞书
- ✅ GitHub Actions 定时运行（每8小时）

## 🚀 快速开始

### 1. Fork 本项目

点击右上角的 Fork 按钮，将项目复制到你的 GitHub 账户。

### 2. 配置 GitHub Secrets

进入你的仓库：`Settings` → `Secrets and variables` → `Actions` → `New repository secret`

需要配置以下 Secrets：

| Secret 名称 | 说明 | 必填 |
|------------|------|------|
| `AI_API_KEY` | AI API Key | ✅ |
| `AI_BASE_URL` | AI API 地址（DeepSeek: `https://api.deepseek.com`） | ⚠️ |
| `AI_MODEL` | AI 模型名称（DeepSeek: `deepseek-chat`） | ⚠️ |
| `FEISHU_WEBHOOK_URL` | 飞书 Webhook 地址 | ✅ |
| `TOP_N` | 每个平台抓取条数（默认：10） | ❌ |

**配置示例：**

```
AI_API_KEY: sk-f7d071fdb38040ef890ee131fe7ff8d8
AI_BASE_URL: https://api.deepseek.com
AI_MODEL: deepseek-chat
FEISHU_WEBHOOK_URL: https://www.feishu.cn/flow/api/trigger-webhook/xxxxx
```

### 3. 获取飞书 Webhook

1. 访问 https://botbuilder.feishu.cn/home/my-command
2. 创建新的机器人指令
3. 选择 "Webhook 触发"
4. 复制 Webhook 地址
5. 配置参数（参考主项目 README.md 的飞书配置部分）

### 4. 测试运行

1. 进入你的仓库 Actions 页面
2. 找到 "News Summarizer" workflow
3. 点击 "Run workflow" 手动触发
4. 等待运行完成，检查飞书是否收到消息

### 5. 定时运行

Workflow 已配置为每8小时自动运行一次（UTC 时间：0点、8点、16点，对应北京时间：8点、16点、0点）。

如需修改运行时间，编辑 `.github/workflows/news-summarizer.yml` 中的 cron 表达式。

## 📁 项目结构

```
newscatcher/
├── main.py              # 主程序
├── config.yaml          # 配置文件
├── requirements.txt     # Python 依赖
├── README.md           # 说明文档
└── .github/
    └── workflows/
        └── news-summarizer.yml  # GitHub Actions 配置
```

## ⚙️ 配置说明

### 环境变量

所有配置通过 GitHub Secrets 设置，程序会自动读取：

- `AI_API_KEY`: AI API Key（必填）
- `AI_PROVIDER`: AI 提供商（默认：`openai`）
- `AI_BASE_URL`: 自定义 API 地址（DeepSeek 必填）
- `AI_MODEL`: AI 模型名称（默认：`deepseek-chat`）
- `FEISHU_WEBHOOK_URL`: 飞书 Webhook（必填）
- `TOP_N`: 每个平台抓取条数（默认：10）

### 配置文件

`config.yaml` 包含平台列表和基础配置，可根据需要修改。

## 🔧 本地运行

```bash
# 1. 安装依赖
pip install -r requirements.txt

# 2. 设置环境变量
export AI_API_KEY="your-api-key"
export AI_BASE_URL="https://api.deepseek.com"
export AI_MODEL="deepseek-chat"
export FEISHU_WEBHOOK_URL="your-webhook-url"

# 3. 运行程序
python main.py
```

## 📊 输出格式

程序会生成 AI 总结并推送到飞书，格式如下：

```
📊 热点新闻 AI 总结报告

生成时间：2025年12月12日 12:00:00

---

【科技类】
1. AI 技术新突破：...
...

---

*本报告由 NewsCatcher 自动生成*
```

## ❓ 常见问题

**Q: 如何修改运行频率？**  
A: 编辑 `.github/workflows/news-summarizer.yml`，修改 cron 表达式。

**Q: 支持其他 AI 提供商吗？**  
A: 当前仅支持 OpenAI 兼容的 API（如 DeepSeek）。如需支持 Anthropic，需要修改代码。

**Q: 可以推送到其他平台吗？**  
A: 可以修改 `main.py` 中的 `send_to_feishu` 函数，添加其他推送渠道。

**Q: 如何查看运行日志？**  
A: 在 GitHub Actions 页面查看 workflow 运行记录。

## 📝 许可证

与 TrendRadar 主项目相同：GPL-3.0 License

