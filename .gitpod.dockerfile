FROM gitpod/workspace-base:2024-04-15-16-35-16

USER root

RUN apt-get update \
  && apt-get install -y --no-install-recommends luarocks=3.8.0+dfsg1-1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN luarocks install busted \
  && luarocks install luacheck

USER gitpod
