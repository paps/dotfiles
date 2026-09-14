---
name: dev-container-config
description: Set up or manage my favorite dev container configuration
---

# Dev container config

This skill's goal is to help me manage my own dev container configuration (most often for my own repositories). I have a specific configuration that I like and have created over time. I mainly use it to isolate AI agents when they run within the context of the repository to do tasks.

## Behavior

When unsure, ask me questions about what is to be done.

When you find that the repo doesn't contain any configuration, create it from scratch and summarize what you did.

When working with an existing set of configuration files (which is the most probable case), it means I want you to refresh/update the configuration overall, and double check everything is fine (but not by running anything for real). I suggest you use the diffing tool of your choice to detect the differences between the repo's files and the reference implemenation below. You can then work from the diff's results to know what to do or not do.

It's normal for each repository to have its own specific configuration in parts of the files. In each case, you have to judge if the drift from the reference implementation is normal considering the repo, or if it's a problem that needs fixing.

When you think your work is done, I like to have a summary of the changes (if any) and the exhaustive list of differences between the repo's config and the reference implementation below.

If the repository is not mine and/or it already contains a completely different dev container configuration that achieves something different than what I have in mind here (i.e. mostly simple AI agent isolation), then say so. Ask me what I want to do. I might want to replace the whole existing thing with my own config? Or maybe not, ask me.

## Configuration files

Below I'm explaining each file and give some instructions. This is an exhaustive list, which means there should not be more or less files (if that is the case, ask me what to do).

### `.devcontainer/.env`

File content:
```
# Personal Access Token (PAT, classic) from a *different* user, for the agent to use.
# Typically needs the 'repo' and 'read:org' scopes, and eventually 'workflow' if there
# are GitHub Actions to manage.
GH_TOKEN=ghp_xxxxxxxxxxxx

# leaving this commented here for now, will use later when I force traffic through an inspection proxy
#NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/mitm.crt
```

You can check that the token formats are correct. Never modify the token values. If you create this file from scratch, just leave the fields empty and let me know that I have to fill it in.

Make sure this file is chmod 0600 and not committed to git.

### `.devcontainer/.gitignore`

File content:
```
.env
```

This is pretty much self explanatory. Don't ever commit secrets to git.

### `.devcontainer/Dockerfile`

File content:
```
FROM mcr.microsoft.com/devcontainers/base:debian

RUN echo 'cache bust {X}'

USER vscode

RUN curl -fsSL 'https://raw.githubusercontent.com/paps/dotfiles/refs/heads/master/min-setup-via-curl.sh' | bash

RUN curl -fsSL https://claude.ai/install.sh | bash
RUN curl -fsSL https://chatgpt.com/codex/install.sh | bash

# QoL improvement, e.g. to land there when doing `podman exec -it ID zsh`
WORKDIR /workspaces/{REPO}
```

In this file:
- `{X}` is just a small number that you can increment when there is a need to have the build start from there again (I mean, you know what cache busting is)
- `{REPO}` should be the repository name, for the QoL improvement mentioned in the related comment
- The `mcr.microsoft.com/devcontainers/base:debian` image is a good basic barebones image that I like, but it often has to be different, depending the repo's needs. If you're unsure, ask me
- The `vscode` user name should be changed depending on what the image requires. For example, the `mcr.microsoft.com/devcontainers/typescript-node` images requires `node`

### `.devcontainer/devcontainer.json`

File content:
```
{
  "build": {
    "dockerfile": "Dockerfile"
  },

  // Do this in case we're in a GH codespace or somehow forgot to create the .env file
  // so that runArgs below works in all cases, albeit with no additional env loaded.
  "initializeCommand": "touch .devcontainer/.env ; chmod og-rwx .devcontainer/.env",

  "runArgs": [
    // Make the dev container join the gluetun's network namespace, the goal
    // being to force any network traffic through wireguard for analysis
    // Leaving this commented for now, might use later to force traffic through an inspection proxy
    //"--network=container:gluetun",

    // Load the vars needed for execution of setup.sh and beyond
    "--env-file",
    "${localWorkspaceFolder}/.devcontainer/.env"
  ],

  "postCreateCommand": "bash .devcontainer/setup.sh"
}
```

Some repos might have custom mounts, port fowards, etc...

### `.devcontainer/setup.sh`

File content:
```
#!/bin/bash
set -euo pipefail

# git setup
# ---------
# Only handle git config locally. For codespaces, leave it to them.
if [[ "${CODESPACES:-}" != "true" ]]; then

	# leaving this commented here for now, will use later when I force traffic through an inspection proxy
	#sudo cp mitmproxy-ca-cert.pem /usr/local/share/ca-certificates/mitm.crt
	#sudo update-ca-certificates

	# Use gh as a git credential helper
	# (will work as long as our env has a valid GH_TOKEN)
	gh auth setup-git

	# Set our git name and email based on what GitHub returns
	# (works assuming we have a valid GH_TOKEN when this script runs)
	git config --global user.name "$(gh api user --jq '.name // .login')"
	git config --global user.email "$(gh api user --jq '"\(.id)+\(.login)@users.noreply.github.com"')"

	# We're going to use HTTPS with a PAT token (through gh) instead of SSH keys
	# but we don't want to mess with the already configured repo remote
	# (which would affect the dev container's host).
	# So we use the git config trick below:
	git config --global url."https://github.com/".insteadOf git@github.com:
	git config --global --add url."https://github.com/".insteadOf ssh://git@github.com/

fi
```

### `.devcontainer/README.md`

File content:
```
This dev container configuration is managed via this skill: https://raw.githubusercontent.com/paps/dotfiles/refs/heads/master/.agents/skills/dev-container-config/SKILL.md

Nevertheless it is expected to be modified specifically for the needs of this particular repo. The skill linked above supports that.
```

This file self-references this skill so that nobody is confused about what is going on in the future.
