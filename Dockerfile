FROM --platform=linux/amd64 registry.access.redhat.com/ubi9/ubi:latest

RUN dnf install -y openssh-server unzip jq buildah;

ARG TKNCLI_VERSION=0.36.0 \
    TKNCLI_SHA256SUM=13999ec46a37624fcf41f88d959aaab213d907c69a6238d0cb0e84dc81d6cc4d

RUN yum update -y && \
    yum install -y wget tar gzip && \
    yum clean all

RUN curl --progress-bar --location --fail --show-error \
  --connect-timeout "${CURL_CONNECTION_TIMEOUT:-20}" \
  --retry "${CURL_RETRY:-5}" \
  --retry-delay "${CURL_RETRY_DELAY:-0}" \
  --retry-max-time "${CURL_RETRY_MAX_TIME:-60}" \
  --output /tmp/tkn_${TKNCLI_VERSION}_Linux_x86_64.tar.gz \
  --url "https://github.com/tektoncd/cli/releases/download/v${TKNCLI_VERSION}/tkn_${TKNCLI_VERSION}_Linux_x86_64.tar.gz" && \
  echo "${TKNCLI_SHA256SUM} /tmp/tkn_${TKNCLI_VERSION}_Linux_x86_64.tar.gz" | sha256sum -c - && \
  tar -xzf /tmp/tkn_${TKNCLI_VERSION}_Linux_x86_64.tar.gz --no-same-owner -C /usr/local/bin tkn && \
  chmod 0755 /usr/local/bin/tkn && \
  rm -f /tmp/tkn_${TKNCLI_VERSION}_Linux_x86_64.tar.gz
