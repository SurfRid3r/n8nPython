FROM n8nio/n8n:latest

USER root

# Reinstall apk-tools (n8n 2.1.0+ removed it from final image to optimize size)
# See: https://github.com/n8n-io/n8n/issues/23246
RUN wget -qO- https://dl-cdn.alpinelinux.org/alpine/v3.22/main/x86_64/apk-tools-2.14.8-r0.apk | tar -xz -C / \
    || wget -qO- https://dl-cdn.alpinelinux.org/alpine/v3.22/main/aarch64/apk-tools-2.14.8-r0.apk | tar -xz -C /

# Install Python runtime and tooling
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
