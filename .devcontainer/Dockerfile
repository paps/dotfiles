FROM mcr.microsoft.com/devcontainers/base:debian

RUN echo 'cache bust 4'

USER vscode

RUN curl -fsSL 'https://raw.githubusercontent.com/paps/dotfiles/refs/heads/master/min-setup-via-curl.sh' | bash
