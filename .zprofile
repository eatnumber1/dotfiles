function envvars() {
	if [[ -x "${commands[keychain]}" ]]; then
		eval "$(keychain --quiet --agents ssh --eval --inherit any id_rsa chromium)"
	fi
}
envvars
unfunction envvars
