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

# Install apk-tools and fix musl pin, then install packages
# n8n base image pins musl to a specific version via hash, blocking upgrades
RUN /sbin/apk.static add --no-cache --allow-untrusted apk-tools && \
    apk del --no-cache musl 2>/dev/null; \
    apk add --no-cache --allow-untrusted musl musl-dev && \
    apk add --no-cache \
        python3 \
        py3-pip \
        python3-dev \
        gcc \
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
