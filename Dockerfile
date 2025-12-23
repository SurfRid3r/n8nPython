FROM n8nio/n8n:latest

USER root

# Reinstall apk-tools (n8n 2.1.0+ removed it from final image to optimize size)
# Use static version that doesn't depend on shared libraries
# See: https://github.com/n8n-io/n8n/issues/23246
RUN apkArch="$(uname -m)" && \
    case "$apkArch" in \
        x86_64) wget -qO- https://dl-cdn.alpinelinux.org/alpine/v3.22/main/x86_64/apk-tools-static-2.14.9-r3.apk | tar -xz -C / ;; \
        aarch64) wget -qO- https://dl-cdn.alpinelinux.org/alpine/v3.22/main/aarch64/apk-tools-static-2.14.9-r3.apk | tar -xz -C / ;; \
        *) echo "Unsupported architecture: $apkArch" && exit 1 ;; \
    esac

# Install Python runtime and tooling
RUN /sbin/apk.static add --no-cache --allow-untrusted \
        python3 \
        py3-pip \
        python3-dev \
        gcc \
        musl-dev \
        curl \
        jq \
        ffmpeg \
        yt-dlp \
        apk-tools

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
