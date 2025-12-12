# NewsCatcher 部署指南

## 📋 快速部署步骤

### 1. Fork 项目

1. 访问项目仓库
2. 点击右上角 "Fork" 按钮
3. 等待 Fork 完成

### 2. 配置 GitHub Secrets

进入你的仓库：`Settings` → `Secrets and variables` → `Actions` → `New repository secret`

**必须配置的 Secrets：**

```
AI_API_KEY: sk-你的API密钥
AI_BASE_URL: https://api.deepseek.com
AI_MODEL: deepseek-chat
FEISHU_WEBHOOK_URL: https://www.feishu.cn/flow/api/trigger-webhook/xxxxx
```

**可选配置：**

```
TOP_N: 10  # 每个平台抓取条数，默认10
```

### 3. 获取飞书 Webhook

#### 方法一：机器人指令（推荐）

1. 访问：https://botbuilder.feishu.cn/home/my-command
2. 点击 "新建机器人指令"
3. 选择触发器 → "Webhook 触发"
4. 复制 Webhook 地址（先保存）
5. 在 "参数" 中填入：
```json
{
  "message_type": "text",
  "content": {
    "total_titles": "{{内容}}",
    "timestamp": "{{内容}}",
    "report_type": "{{内容}}",
    "text": "{{内容}}"
  }
}
```
6. 选择操作 → "通过官方机器人发消息"
7. 消息标题：`NewsCatcher 热点总结`
8. 点击 + 按钮，选择 "Webhook 触发"，按提示配置
9. 将第4步复制的 Webhook 地址填入 GitHub Secrets

#### 方法二：机器人应用

1. 访问：https://botbuilder.feishu.cn/home/my-app
2. 点击 "新建机器人应用"
3. 流程设计 → 创建流程 → Webhook 触发
4. 复制 Webhook 地址
5. 配置参数（同方法一）
6. 选择操作 → "发送飞书消息"
7. 配置完成后，将 Webhook 地址填入 GitHub Secrets

### 4. 测试运行

1. 进入你的仓库 → `Actions` 标签
2. 找到 "News Summarizer" workflow
3. 点击 "Run workflow" → "Run workflow"
4. 等待运行完成（约 2-3 分钟）
5. 检查飞书是否收到消息

### 5. 定时运行

Workflow 已配置为每8小时运行一次：
- UTC 时间：0:00, 8:00, 16:00
- 北京时间：8:00, 16:00, 0:00（次日）

如需修改，编辑 `.github/workflows/news-summarizer.yml`：

```yaml
schedule:
  - cron: "0 */8 * * *"  # 修改这里的 cron 表达式
```

## 🔍 验证配置

### 检查 Secrets 配置

在 Actions 页面查看 workflow 运行日志，确认：
- ✅ 环境变量已正确读取
- ✅ 配置加载成功
- ✅ 数据抓取正常
- ✅ AI 总结生成成功
- ✅ 飞书推送成功

### 常见错误

**错误：未配置 AI_API_KEY**
- 解决：检查 GitHub Secrets 中是否已添加 `AI_API_KEY`

**错误：未配置 FEISHU_WEBHOOK_URL**
- 解决：检查 GitHub Secrets 中是否已添加 `FEISHU_WEBHOOK_URL`

**错误：飞书推送失败**
- 检查 Webhook URL 是否正确
- 检查飞书机器人是否已启用
- 查看 Actions 日志中的详细错误信息

## 📊 运行时间表

| UTC 时间 | 北京时间 | 说明 |
|---------|---------|------|
| 0:00 | 8:00 | 早上推送 |
| 8:00 | 16:00 | 下午推送 |
| 16:00 | 0:00（次日） | 晚上推送 |

## 🎉 完成！

配置完成后，程序会自动每8小时运行一次，将 AI 总结推送到你的飞书。

如需查看运行历史，访问：`你的仓库/Actions`

