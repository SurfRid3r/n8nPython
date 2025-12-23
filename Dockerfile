FROM n8nio/n8n:latest

USER root

# Install Python runtime and tooling (Alpine-based n8n image)
RUN apk add --no-cache \
        python3 \
        py3-pip \
        python3-dev \
        gcc \
        musl-dev \
        curl \
        jq \
        ffmpeg \
        yt-dlp

# Create Python virtual environment
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv "$VIRTUAL_ENV"
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Copy requirements file
COPY requirements.txt /tmp/requirements.txt

# Install Python dependencies in virtual environment
RUN pip install --no-cache-dir -r /tmp/requirements.txt

USER node

EXPOSE 5678
