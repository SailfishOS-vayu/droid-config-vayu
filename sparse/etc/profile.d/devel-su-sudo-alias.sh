# Add convenience 'sudo' alias for 'devel-su' if sudo command isn't found
command -v sudo > /dev/null || \
	alias sudo="devel-su"
