#!/bin/bash
set -euo pipefail

# Only handle git config locally. For codespaces, leave it to them.
if [[ "${CODESPACES:-}" != "true" ]]; then

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
	# (which would affect the devcontainer's host).
	# So we use the git config trick below:
	git config --global url."https://github.com/".insteadOf git@github.com:
	git config --global --add url."https://github.com/".insteadOf ssh://git@github.com/

fi

# Claude Code currently has a bug where it won't detect it has an available
# CLAUDE_CODE_OAUTH_TOKEN unless we set hasCompletedOnboarding.
if [ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]; then
	touch ~/.claude.json
	jq '.hasCompletedOnboarding=true' ~/.claude.json > /tmp/c && mv /tmp/c ~/.claude.json
fi
