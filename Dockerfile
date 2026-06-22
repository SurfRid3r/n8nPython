FROM n8nio/n8n:latest

USER root

# Reinstall apk (n8n 2.1.0+ removed it from the final image to optimize size).
# We use the fully statically-linked apk.static, which has no shared-library
# dependencies, so it sidesteps the libapk2/musl version-pin conflict that the
# n8n base image carries and that breaks the dynamic apk-tools package.
# See: https://github.com/n8n-io/n8n/issues/23246
#
# Resolve the current apk-tools-static package from the repo index instead of
# pinning a version: Alpine removes old point releases, and a hardcoded URL
# 404s the moment they publish a new one (e.g. 2.14.9-r3 -> 2.14.10-r0).
RUN apkArch="$(uname -m)" && \
    case "$apkArch" in \
        x86_64) repo="x86_64" ;; \
        aarch64) repo="aarch64" ;; \
        *) echo "Unsupported architecture: $apkArch" && exit 1 ;; \
    esac && \
    pkg="$(wget -qO- "https://dl-cdn.alpinelinux.org/alpine/v3.22/main/${repo}/APKINDEX.tar.gz" \
            | tar -xzO APKINDEX \
            | awk -v RS='' '$0 ~ /\nP:apk-tools-static\n/{n=split($0,L,"\n");for(i=1;i<=n;i++)if(L[i]~/^V:/){sub(/^V:/,"",L[i]);print L[i];exit}}')" && \
    [ -n "$pkg" ] || { echo "apk-tools-static not found in index" >&2; exit 1; } && \
    wget -qO- "https://dl-cdn.alpinelinux.org/alpine/v3.22/main/${repo}/apk-tools-static-${pkg}.apk" | tar -xz -C / && \
    [ -x /sbin/apk.static ]

# Install all packages with the static apk only. We deliberately do NOT install
# the dynamic apk-tools package: it pulls in libapk2, whose version clashes with
# the pin in the n8n base image ("unable to select packages: libapk2 breaks
# world[...]"), leaving no apk on PATH at all (exit 127). apk.static is
# self-contained, so musl never needs to be touched either.
RUN /sbin/apk.static add --no-cache --allow-untrusted \
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
