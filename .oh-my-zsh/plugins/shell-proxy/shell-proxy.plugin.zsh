#!/usr/bin/bash
# shellcheck disable=SC1090,SC2154

# Handle $0 according to the standard:
# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

eval '
  proxy() {
    # deprecate $DEFAULT_PROXY, use SHELLPROXY_URL instead
    if [[ -n "$DEFAULT_PROXY" && -z "$SHELLPROXY_URL" ]]; then
      echo >&2 "proxy: DEFAULT_PROXY is deprecated, use SHELLPROXY_URL instead"
      SHELLPROXY_URL="$DEFAULT_PROXY"
      unset DEFAULT_PROXY
    fi

    # deprecate CONFIG_PROXY, use SHELLPROXY_CONFIG instead
    if [[ -n "$CONFIG_PROXY" && -z "$SHELLPROXY_CONFIG" ]]; then
      echo >&2 "proxy: CONFIG_PROXY is deprecated, use SHELLPROXY_CONFIG instead"
      SHELLPROXY_CONFIG="$CONFIG_PROXY"
      unset CONFIG_PROXY
    fi

    # the proxy.py script is in the same directory as this function
    local proxy="'"${0:h}"'/proxy.py"

    # capture the output of the proxy script and bail out if it fails
    local output
    output="$(SHELLPROXY_URL="$SHELLPROXY_URL" SHELLPROXY_CONFIG="$SHELLPROXY_CONFIG" "$proxy" "$1")" ||
      return $?

    # evaluate the output generated by the proxy script
    source <(echo "$output")
  }
'

_proxy() {
  local -r commands=('enable' 'disable' 'status')
  compset -P '*,'
  compadd -S '' "${commands[@]}"
}

compdef _proxy proxy