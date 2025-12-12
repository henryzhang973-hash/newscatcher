# coding=utf-8
"""
新闻热点总结程序
功能：抓取各平台前10条热点新闻，使用 AI 生成要点总结并推送到飞书
"""

import json
import os
import time
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Union

import pytz
import requests
import yaml

try:
    from openai import OpenAI
    HAS_OPENAI = True
except ImportError:
    HAS_OPENAI = False


# === 配置管理 ===
def load_config() -> Dict:
    """加载配置文件"""
    config_path = os.environ.get("CONFIG_PATH", "config.yaml")
    
    if not Path(config_path).exists():
        raise FileNotFoundError(f"配置文件 {config_path} 不存在")
    
    with open(config_path, "r", encoding="utf-8") as f:
        config_data = yaml.safe_load(f)
    
    # AI 配置（从环境变量读取）
    ai_config = {
        "provider": os.environ.get("AI_PROVIDER", "openai").lower(),
        "api_key": os.environ.get("AI_API_KEY", ""),
        "base_url": os.environ.get("AI_BASE_URL", ""),
        "model": os.environ.get("AI_MODEL", config_data.get("ai", {}).get("model", "deepseek-chat")),
    }
    
    # 飞书配置（从环境变量读取）
    feishu_webhook = os.environ.get("FEISHU_WEBHOOK_URL", "").strip()
    
    config = {
        "platforms": config_data.get("platforms", []),
        "request_interval": config_data.get("request_interval", 1000),
        "top_n": int(os.environ.get("TOP_N", "10")),
        "ai": ai_config,
        "feishu_webhook": feishu_webhook,
    }
    
    return config


# === 数据获取 ===
class DataFetcher:
    """数据获取器"""
    
    def __init__(self):
        self.headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
            "Accept": "application/json, text/plain, */*",
            "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
        }
    
    def fetch_data(self, platform_id: str, max_retries: int = 2) -> Optional[Dict]:
        """获取平台数据"""
        url = f"https://newsnow.busiyi.world/api/s?id={platform_id}&latest"
        
        for retry in range(max_retries + 1):
            try:
                response = requests.get(url, headers=self.headers, timeout=10)
                response.raise_for_status()
                data = response.json()
                
                if data.get("status") in ["success", "cache"]:
                    return data
            except Exception as e:
                if retry < max_retries:
                    time.sleep(2)
                else:
                    print(f"  ✗ 抓取失败: {e}")
        return None
    
    def fetch_top_news(self, platforms: List[Dict], top_n: int = 10, request_interval: int = 1000) -> Dict[str, List[Dict]]:
        """抓取各平台前N条热点新闻"""
        results = {}
        
        for i, platform in enumerate(platforms):
            platform_id = platform.get("id")
            platform_name = platform.get("name", platform_id)
            
            print(f"[{i+1}/{len(platforms)}] 正在抓取 {platform_name}...")
            
            data = self.fetch_data(platform_id)
            
            if data:
                items = data.get("items", [])
                top_items = []
                
                for idx, item in enumerate(items[:top_n], 1):
                    title = item.get("title", "")
                    if title and str(title).strip():
                        top_items.append({
                            "rank": idx,
                            "title": str(title).strip(),
                        })
                
                results[platform_name] = top_items
                print(f"  ✓ 成功获取 {len(top_items)} 条新闻")
            else:
                results[platform_name] = []
            
            if i < len(platforms) - 1:
                time.sleep(request_interval / 1000.0)
        
        return results


# === AI 总结功能 ===
class AISummarizer:
    """AI 总结器"""
    
    def __init__(self, provider: str, api_key: str, model: str, base_url: Optional[str] = None):
        if not api_key:
            raise ValueError("AI API Key 未配置，请设置环境变量 AI_API_KEY")
        
        if provider != "openai" or not HAS_OPENAI:
            raise ImportError("请安装 openai 库: pip install openai")
        
        client_kwargs = {"api_key": api_key}
        if base_url:
            client_kwargs["base_url"] = base_url
        
        self.client = OpenAI(**client_kwargs)
        self.model = model
    
    def summarize_news(self, news_data: Dict[str, List[Dict]]) -> str:
        """使用 AI 总结新闻"""
        prompt = self._build_prompt(news_data)
        
        print("\n正在使用 AI 生成总结...")
        
        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "system",
                        "content": "你是一个专业的新闻分析助手，擅长从多个平台的热点新闻中提取关键信息并生成简洁明了的总结。"
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                temperature=0.7,
            )
            summary = response.choices[0].message.content
            print("✓ AI 总结生成成功")
            return summary
        except Exception as e:
            raise Exception(f"AI 总结失败: {e}")
    
    def _build_prompt(self, news_data: Dict[str, List[Dict]]) -> str:
        """构建 AI 提示词"""
        prompt_parts = [
            "请分析以下各平台的热点新闻，并生成一份要点总结。",
            "\n要求：",
            "1. 按主题分类整理新闻（如：科技、财经、社会、娱乐等）",
            "2. 提取每个主题的核心要点（3-5个关键信息）",
            "3. 标注重要新闻的来源平台",
            "4. 总结整体趋势和热点话题",
            "5. 使用简洁明了的语言，控制在800-1200字",
            "\n各平台热点新闻：\n"
        ]
        
        for platform_name, news_list in news_data.items():
            if not news_list:
                continue
            prompt_parts.append(f"\n【{platform_name}】")
            for news in news_list:
                prompt_parts.append(f"{news['rank']}. {news['title']}")
        
        prompt_parts.append("\n请开始分析并生成总结：")
        return "\n".join(prompt_parts)


# === 飞书推送功能 ===
def format_feishu_content(summary: str) -> str:
    """格式化飞书消息内容"""
    beijing_time = datetime.now(pytz.timezone("Asia/Shanghai"))
    time_str = beijing_time.strftime("%Y年%m月%d日 %H:%M:%S")
    
    return f"""**📊 热点新闻 AI 总结报告**

**生成时间：** {time_str}

---

{summary}

---

*本报告由 NewsCatcher 自动生成*"""


def send_to_feishu(webhook_url: str, summary: str) -> bool:
    """发送 AI 总结到飞书（支持分批发送）"""
    headers = {"Content-Type": "application/json"}
    feishu_content = format_feishu_content(summary)
    
    # 飞书消息大小限制（约 30KB）
    feishu_batch_size = 29000
    content_bytes = feishu_content.encode("utf-8")
    
    if len(content_bytes) <= feishu_batch_size:
        batches = [feishu_content]
    else:
        # 分批发送：按段落分割
        batches = []
        current_batch = ""
        paragraphs = feishu_content.split("\n\n")
        
        for para in paragraphs:
            test_batch = current_batch + ("\n\n" if current_batch else "") + para
            if len(test_batch.encode("utf-8")) <= feishu_batch_size:
                current_batch = test_batch
            else:
                if current_batch:
                    batches.append(current_batch)
                current_batch = para
        
        if current_batch:
            batches.append(current_batch)
    
    print(f"飞书消息分为 {len(batches)} 批次发送")
    
    beijing_time = datetime.now(pytz.timezone("Asia/Shanghai"))
    time_str = beijing_time.strftime("%Y-%m-%d %H:%M:%S")
    
    # 逐批发送
    for i, batch_content in enumerate(batches, 1):
        batch_size = len(batch_content.encode("utf-8"))
        print(f"发送飞书第 {i}/{len(batches)} 批次，大小：{batch_size} 字节")
        
        payload = {
            "msg_type": "text",
            "content": {
                "total_titles": 0,
                "timestamp": time_str,
                "report_type": "AI 总结报告",
                "text": batch_content,
            },
        }
        
        try:
            response = requests.post(webhook_url, headers=headers, json=payload, timeout=30)
            if response.status_code == 200:
                result = response.json()
                if result.get("StatusCode") == 0 or result.get("code") == 0:
                    print(f"✓ 飞书第 {i}/{len(batches)} 批次发送成功")
                    if i < len(batches):
                        time.sleep(3)
                else:
                    error_msg = result.get("msg") or result.get("StatusMessage", "未知错误")
                    print(f"✗ 飞书第 {i}/{len(batches)} 批次发送失败，错误：{error_msg}")
                    return False
            else:
                print(f"✗ 飞书第 {i}/{len(batches)} 批次发送失败，状态码：{response.status_code}")
                return False
        except Exception as e:
            print(f"✗ 飞书第 {i}/{len(batches)} 批次发送出错：{e}")
            return False
    
    print(f"✓ 飞书所有 {len(batches)} 批次发送完成")
    return True


# === 主程序 ===
def main():
    """主函数"""
    print("=" * 80)
    print("热点新闻总结程序")
    print("=" * 80)
    
    try:
        # 加载配置
        print("\n[1/4] 加载配置...")
        config = load_config()
        print(f"  ✓ 配置加载成功")
        print(f"  - 监控平台: {len(config['platforms'])} 个")
        print(f"  - 每个平台抓取: 前 {config['top_n']} 条")
        print(f"  - AI 模型: {config['ai']['model']}")
        
        # 检查 AI 配置
        if not config['ai']['api_key']:
            print("\n❌ 错误: 未配置 AI_API_KEY")
            return
        
        # 检查飞书配置
        if not config['feishu_webhook']:
            print("\n❌ 错误: 未配置 FEISHU_WEBHOOK_URL")
            return
        
        # 抓取新闻
        print(f"\n[2/4] 抓取各平台热点新闻...")
        fetcher = DataFetcher()
        news_data = fetcher.fetch_top_news(
            platforms=config['platforms'],
            top_n=config['top_n'],
            request_interval=config['request_interval'],
        )
        
        total_news = sum(len(news_list) for news_list in news_data.values())
        print(f"\n  ✓ 抓取完成: {len(news_data)} 个平台，共 {total_news} 条新闻")
        
        if total_news == 0:
            print("\n⚠️  未获取到任何新闻，程序退出")
            return
        
        # AI 总结
        print(f"\n[3/4] 使用 AI 生成总结...")
        summarizer = AISummarizer(
            provider=config['ai']['provider'],
            api_key=config['ai']['api_key'],
            model=config['ai']['model'],
            base_url=config['ai']['base_url'] if config['ai']['base_url'] else None,
        )
        
        summary = summarizer.summarize_news(news_data)
        
        # 推送到飞书
        print(f"\n[4/4] 推送到飞书...")
        success = send_to_feishu(config['feishu_webhook'], summary)
        
        if success:
            print("\n" + "=" * 80)
            print("✅ 程序执行完成！")
            print("=" * 80)
        else:
            print("\n⚠️  飞书推送失败")
            raise Exception("飞书推送失败")
    
    except KeyboardInterrupt:
        print("\n\n⚠️  用户中断程序")
        raise
    except Exception as e:
        print(f"\n\n❌ 程序执行出错: {e}")
        import traceback
        traceback.print_exc()
        raise


if __name__ == "__main__":
    main()

