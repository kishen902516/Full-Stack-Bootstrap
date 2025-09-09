# Devcontainer Manifest

This manifest contains the file structure and content for the devcontainer components.

## .devcontainer/Dockerfile

```dockerfile
FROM node:20

ARG TZ
ENV TZ="$TZ"

ARG CLAUDE_CODE_VERSION=latest

# Install basic development tools and iptables/ipset
RUN apt-get update && apt-get install -y --no-install-recommends \
  less \
  git \
  procps \
  sudo \
  fzf \
  zsh \
  man-db \
  unzip \
  gnupg2 \
  gh \
  iptables \
  ipset \
  iproute2 \
  dnsutils \
  aggregate \
  jq \
  nano \
  vim \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Ensure default node user has access to /usr/local/share
RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share

ARG USERNAME=node

# Persist bash history.
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && mkdir /commandhistory \
  && touch /commandhistory/.bash_history \
  && chown -R $USERNAME /commandhistory

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true

# Create workspace and config directories and set permissions
RUN mkdir -p /workspace /home/node/.claude && \
  chown -R node:node /workspace /home/node/.claude

WORKDIR /workspace

ARG GIT_DELTA_VERSION=0.18.2
RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  sudo dpkg -i "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  rm "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb"

# Set up non-root user
USER node

# Install global packages
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# Set the default shell to zsh rather than sh
ENV SHELL=/bin/zsh

# Set the default editor and visual
ENV EDITOR=nano
ENV VISUAL=nano

# Default powerline10k theme
ARG ZSH_IN_DOCKER_VERSION=1.2.0
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v${ZSH_IN_DOCKER_VERSION}/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
  -a "source /usr/share/doc/fzf/examples/completion.zsh" \
  -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  -x

# Install Claude
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}


# Copy and set up firewall script
COPY .devcontainer/init-firewall.sh /usr/local/bin/
USER root
RUN chmod +x /usr/local/bin/init-firewall.sh && \
  echo "node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/node-firewall && \
  chmod 0440 /etc/sudoers.d/node-firewall
USER node

```

---

## .devcontainer/init-firewall.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
# Minimal, opt-in egress limiter. No-op unless FIREWALL_STRICT=1
if [[ "${FIREWALL_STRICT:-0}" != "1" ]]; then
  echo "init-firewall: noop (set FIREWALL_STRICT=1 to enable rules)"; exit 0; fi

# Flush and default policies
iptables -F
iptables -P INPUT ACCEPT
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Allow loopback
iptables -A OUTPUT -o lo -j ACCEPT

# Allow DNS (TCP/UDP 53)
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Allow HTTPS (443) and Git (ssh 22)
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT

echo "init-firewall: strict egress policy enabled"

```

---

## .devcontainer/devcontainer.json

```json
{
  "name": "BMAD CCA",
  "build": {
    "dockerfile": "./Dockerfile",
    "context": "..",
    "args": {
      "TZ": "Asia/Singapore",
      "CLAUDE_CODE_VERSION": "latest"
    }
  },
  "features": {
    "ghcr.io/devcontainers/features/dotnet:2": { "version": "8.0" }
  },
  "remoteUser": "node",
  "mounts": [
    "source=${localEnv:USERPROFILE}/.claude,target=/home/node/.claude,type=bind,consistency=cached"
  ],
  "postCreateCommand": "cd app-frontend && ( [ -f package-lock.json ] && npm ci || npm install ) || true && cd - >/dev/null && dotnet restore ./app-api/AppApi.sln && bash ./scripts/install-hooks.sh && node tools/mcp/context7-index.js",
  "postStartCommand": "sudo /usr/local/bin/init-firewall.sh || true",
  "customizations": {
    "vscode": {
      "extensions": ["anthropic.claude-dev"]
    }
  }
}

```

