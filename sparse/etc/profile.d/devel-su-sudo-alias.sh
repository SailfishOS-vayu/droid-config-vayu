# Add convenience 'sudo' alias for 'devel-su' if sudo command isn't found
if [[ $- = *i* && ! -x `command -v sudo` ]]; then
	alias sudo="devel-su"
fi
