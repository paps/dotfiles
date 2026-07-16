FROM mcr.microsoft.com/devcontainers/base:debian

RUN echo 'cache bust 5'

USER vscode

RUN curl -fsSL 'https://raw.githubusercontent.com/paps/dotfiles/refs/heads/master/min-setup-via-curl.sh' | bash

RUN curl -fsSL https://claude.ai/install.sh | bash
