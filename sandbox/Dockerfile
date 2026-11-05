# syntax=docker/dockerfile:1
# Build context is the repository root: docker build -f sandbox/Dockerfile .
FROM ubuntu:26.04

ARG USER_UID=1000
ARG USER_GID=1000

# Reuse the Linux package list, minus the container engine tooling and packages a sandbox has no use for
COPY conf.d/packages.toml /tmp/packages.toml
RUN apt-get update \
 && packages=$(grep -oP '^"apt:\K[^"]+' /tmp/packages.toml | grep -vE '^(docker|graphviz|ack|sshpass|zopfli)') \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      $packages ca-certificates curl locales openssh-client vim \
 && locale-gen en_US.UTF-8 \
 && rm -rf /var/lib/apt/lists/* /tmp/packages.toml

# The base image ships a user at UID 1000; the clone is bind-mounted, so UIDs must match the host
RUN (userdel -r ubuntu 2>/dev/null || true) \
 && (groupadd --gid "$USER_GID" agent 2>/dev/null || true) \
 && useradd --uid "$USER_UID" --gid "$USER_GID" --create-home --shell /usr/bin/zsh agent

USER agent
WORKDIR /home/agent

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    MISE_DISABLE_TOOLS=tokei,atuin,fnox,terraform,cmake,hadolint,npm:agent-browser \
    PATH=/home/agent/.local/share/mise/shims:/home/agent/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN curl -fsSL https://mise.run | sh

COPY --chown=agent:agent . /home/agent/.config/mise

# Placeholder values: the sandbox gets its git identity from the environment at run time
RUN --mount=type=secret,id=gh_token,required=false,mode=0444 \
    if [ -s /run/secrets/gh_token ]; then export MISE_GITHUB_TOKEN="$(cat /run/secrets/gh_token)"; fi \
 && mise vars \
      git_name=agent \
      git_personal_email=agent@sandbox.invalid \
      git_personal_signing_key=none \
      git_work_email=agent@sandbox.invalid \
      git_work_signing_key=none \
 && mise bootstrap --skip packages --skip user --yes \
 && rm -rf /home/agent/.cache/mise

RUN mkdir -p /home/agent/.cache /home/agent/.npm

WORKDIR /work
CMD ["sleep", "infinity"]
