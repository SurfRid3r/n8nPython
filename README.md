 # N8N Python Docker 项目

这是一个基于 N8N 工作流自动化平台的 Docker 项目，集成了 Python 支持。

## 项目特点

- 基于 N8N 平台，支持 Python 脚本执行、ffmpeg
- 支持多架构部署（linux/amd64, linux/arm64）
- 自动化 Docker 镜像构建和发布
- 持久化数据存储

## 快速开始

### 环境要求

- Docker
- Docker Compose

### 配置

在运行之前，请创建 `.env` 文件并设置以下环境变量：

```env
SUBDOMAIN=your-subdomain
DOMAIN_NAME=your-domain
GENERIC_TIMEZONE=your-timezone
N8N_DATA_DIR=/path/to/data
```

### 启动服务

```bash
docker-compose up -d
```

服务将在 `https://{SUBDOMAIN}.{DOMAIN_NAME}:5678` 上运行。

## 目录结构

- `/n8n_data`: N8N 配置和数据
- `/python_scripts`: Python 脚本存储目录


## Docker 镜像

镜像托管在 Docker Hub：`surfrid3r/n8n-python:latest`