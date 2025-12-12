# GitHub Secrets 配置详细指南

## 📍 进入配置页面

1. 打开你的 GitHub 仓库：`https://github.com/你的用户名/newscatcher`
2. 点击顶部的 **Settings**（设置）标签
3. 在左侧菜单找到 **Secrets and variables** → **Actions**
4. 点击 **New repository secret** 按钮

## 🔑 需要配置的 Secrets

### 1. AI_API_KEY（必填）

**用途**：AI API 密钥，用于调用 DeepSeek API

**配置步骤**：
1. 点击 "New repository secret"
2. **Name**: 输入 `AI_API_KEY`（必须完全一致，区分大小写）
3. **Secret**: 输入你的 API Key，例如：`sk-f7d071fdb38040ef890ee131fe7ff8d8`
4. 点击 "Add secret"

**获取方式**：
- DeepSeek: https://platform.deepseek.com/api_keys

---

### 2. AI_BASE_URL（必填）

**用途**：AI API 的基础地址

**配置步骤**：
1. 点击 "New repository secret"
2. **Name**: 输入 `AI_BASE_URL`
3. **Secret**: 输入 `https://api.deepseek.com`
4. 点击 "Add secret"

**注意**：如果使用 OpenAI，则填写 `https://api.openai.com/v1`

---

### 3. AI_MODEL（可选，有默认值）

**用途**：指定使用的 AI 模型

**配置步骤**：
1. 点击 "New repository secret"
2. **Name**: 输入 `AI_MODEL`
3. **Secret**: 输入 `deepseek-chat`
4. 点击 "Add secret"

**其他可选值**：
- DeepSeek: `deepseek-chat`, `deepseek-coder`
- OpenAI: `gpt-4o-mini`, `gpt-4o`, `gpt-3.5-turbo`

**注意**：如果不配置，默认使用 `deepseek-chat`

---

### 4. FEISHU_WEBHOOK_URL（必填）

**用途**：飞书机器人的 Webhook 地址，用于接收推送消息

**配置步骤**：
1. 点击 "New repository secret"
2. **Name**: 输入 `FEISHU_WEBHOOK_URL`（必须完全一致）
3. **Secret**: 输入你的飞书 Webhook 地址
4. 点击 "Add secret"

**获取方式**：

#### 方法一：机器人指令（推荐）

1. 访问：https://botbuilder.feishu.cn/home/my-command
2. 点击 "新建机器人指令"
3. 选择触发器 → "Webhook 触发"
4. **复制 Webhook 地址**（先保存到记事本）
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
6. 点击 "完成"
7. 选择操作 → "通过官方机器人发消息"
8. 消息标题填写：`NewsCatcher 热点总结`
9. 点击 + 按钮，选择 "Webhook 触发"，按提示配置
10. 将第4步复制的 Webhook 地址填入 GitHub Secrets

#### 方法二：机器人应用

1. 访问：https://botbuilder.feishu.cn/home/my-app
2. 点击 "新建机器人应用"
3. 流程设计 → 创建流程 → Webhook 触发
4. 复制 Webhook 地址
5. 配置参数（同方法一）
6. 选择操作 → "发送飞书消息"
7. 配置完成后，将 Webhook 地址填入 GitHub Secrets

**Webhook 地址格式**：
```
https://www.feishu.cn/flow/api/trigger-webhook/xxxxxxxxxxxxxxxx
```

---

### 5. TOP_N（可选）

**用途**：每个平台抓取的新闻条数

**配置步骤**：
1. 点击 "New repository secret"
2. **Name**: 输入 `TOP_N`
3. **Secret**: 输入数字，例如：`10`
4. 点击 "Add secret"

**默认值**：如果不配置，默认抓取每个平台前 10 条

**建议值**：
- `5` - 快速测试，成本低
- `10` - 平衡（推荐）
- `15` - 更全面，但成本更高

---

## ✅ 配置完成检查

配置完成后，你应该在 Secrets 列表看到：

```
✅ AI_API_KEY
✅ AI_BASE_URL
✅ AI_MODEL (可选)
✅ FEISHU_WEBHOOK_URL
✅ TOP_N (可选)
```

**重要提示**：
- Secret 名称必须**完全一致**（区分大小写）
- 保存后无法查看 Secret 的值（只能重新设置）
- 如果配置错误，可以点击 Secret 右侧的 "Update" 更新

---

## 🧪 测试配置

1. 进入仓库的 **Actions** 标签页
2. 找到 "News Summarizer" workflow
3. 点击 "Run workflow" → "Run workflow"
4. 等待运行完成（约 2-3 分钟）
5. 点击运行记录查看日志
6. 检查飞书是否收到消息

**如果运行失败**：
- 查看 Actions 日志中的错误信息
- 检查 Secrets 名称是否正确
- 检查 API Key 和 Webhook URL 是否有效

---

## 📝 配置示例

### 完整配置示例（DeepSeek）

```
AI_API_KEY: sk-f7d071fdb38040ef890ee131fe7ff8d8
AI_BASE_URL: https://api.deepseek.com
AI_MODEL: deepseek-chat
FEISHU_WEBHOOK_URL: https://www.feishu.cn/flow/api/trigger-webhook/xxxxx
TOP_N: 10
```

### 最小配置（使用默认值）

```
AI_API_KEY: sk-xxx...
AI_BASE_URL: https://api.deepseek.com
FEISHU_WEBHOOK_URL: https://www.feishu.cn/flow/api/trigger-webhook/xxxxx
```

（不配置 AI_MODEL 和 TOP_N，使用默认值）

---

## 🔒 安全提示

- ✅ Secrets 是加密存储的，只有仓库管理员可以查看和修改
- ✅ 不要在代码中硬编码 API Key
- ✅ 不要将 Secrets 提交到代码仓库
- ✅ 定期更新 API Key（如果泄露）

---

## ❓ 常见问题

**Q: 如何修改已配置的 Secret？**  
A: 在 Secrets 列表中找到对应的 Secret，点击右侧的 "Update" 按钮。

**Q: 如何删除 Secret？**  
A: 在 Secrets 列表中找到对应的 Secret，点击右侧的 "Delete" 按钮。

**Q: Secret 名称写错了怎么办？**  
A: 删除错误的 Secret，重新创建正确名称的 Secret。

**Q: 可以配置多个 Webhook 吗？**  
A: 当前版本只支持一个飞书 Webhook。如需多个，需要修改代码。

