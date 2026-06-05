#!/bin/sh

FUZZY_PACKAGE="@fuzzyos/fuzzy-code"
FUZZY_CMD="fuzzy"
# Fuzzy publishes npm-shrinkwrap.json, so the explicit installer/reinstaller can
# bypass npm's release-age gate without reopening transitive dependency ranges.
FUZZY_NPM_INSTALL_MIN_AGE_ARG="--min-release-age=0"
FUZZY_ESC=$(printf '\033')
FUZZY_CR=$(printf '\r')
readonly FUZZY_PACKAGE FUZZY_CMD FUZZY_NPM_INSTALL_MIN_AGE_ARG FUZZY_ESC FUZZY_CR

fuzzy_installer_main() {
  set -eu

  check_file="${TMPDIR:-/tmp}/fuzzy-installer-checks.$$"
  run_preflight_checks >"$check_file" &
  check_pid=$!

  fuzzy_logo_animation

  if wait "$check_pid"; then
    check_status=0
  else
    check_status=$?
  fi

  printf '\033[1m  Fuzzy Installer\033[0m\n\033[2m  There are many code harnesses, but this one is mine.\033[0m\n\n'
  if [ "$check_status" -eq 0 ]; then
    cat "$check_file"
  fi
  rm -f "$check_file"

  if [ "$check_status" -ne 0 ]; then
    if ! install_node_npm_interactive; then
      exit "$check_status"
    fi

    check_file="${TMPDIR:-/tmp}/fuzzy-installer-checks.$$"
    if run_preflight_checks >"$check_file"; then
      check_status=0
    else
      check_status=$?
    fi
    cat "$check_file"
    rm -f "$check_file"

    if [ "$check_status" -ne 0 ]; then
      exit "$check_status"
    fi
  fi

  FUZZY_EXISTING_PATH=$(command -v "$FUZZY_CMD" 2>/dev/null || true)
  export FUZZY_EXISTING_PATH

  if ! FUZZY_NPM_INSTALL_PREFIX=$(select_npm_install_prefix); then
    exit 1
  fi
  export FUZZY_NPM_INSTALL_PREFIX

  FUZZY_NPM_UNINSTALL_PREFIX=$(select_npm_uninstall_prefix "$FUZZY_EXISTING_PATH")
  export FUZZY_NPM_UNINSTALL_PREFIX

  choose_fuzzy_action "$FUZZY_EXISTING_PATH"
  case "$FUZZY_INSTALL_ACTION" in
    uninstall)
      uninstall_fuzzy_package
      printf '\nFuzzy was uninstalled successfully.\n'
      exit 0
      ;;
    none)
      exit 0
      ;;
  esac

  install_fuzzy_package
  if [ "$FUZZY_INSTALL_ACTION" = reinstall ]; then
    printf '\nFuzzy was reinstalled successfully.\n'
  else
    printf '\nFuzzy was installed successfully.\n'
  fi
  if installed_fuzzy_is_first_on_path; then
    printf '\nRun it with: fuzzy\n'
    if [ "${FUZZY_NODE_INSTALLED_STANDALONE:-0}" = 1 ]; then
      printf 'If fuzzy is not found in your shell yet, add this to your shell profile:\n\n'
      printf '  export PATH="%s:$PATH"\n' "$FUZZY_STANDALONE_NODE_BIN"
    fi
  else
    print_fuzzy_not_on_path_message
  fi

}

run_preflight_checks() {
  status=0

  if command -v node >/dev/null 2>&1; then
    node_version=$(node --version)
    if ! node -e 'const [maj,min,patch] = process.versions.node.split(".").map(Number); process.exit(maj > 22 || (maj === 22 && (min > 19 || (min === 19 && patch >= 0))) ? 0 : 1)' >/dev/null; then
      printf 'error: Fuzzy requires Node.js 22.19.0 or newer. Found %s.\n' "$node_version"
      status=1
    fi
  else
    printf 'error: Node.js 22.19.0 or newer is required to install Fuzzy.\n'
    status=1
  fi

  if ! command -v npm >/dev/null 2>&1; then
    printf 'error: npm is required to install Fuzzy.\n'
    status=1
  fi

  if [ "$status" -ne 0 ]; then
    printf '\n'
  fi

  return "$status"
}

install_node_npm_interactive() {
  method=$(detect_node_install_method)
  case "$method" in
    homebrew) label="Homebrew" ;;
    apt) label="apt" ;;
    apk) label="apk" ;;
    standalone) label="standalone Node.js" ;;
  esac

  if ! ( : <>/dev/tty ) 2>/dev/null; then
    printf 'No terminal detected; install Node.js 22.19.0 or newer and npm, then run this installer again.\n'
    return 1
  fi
  exec 3<>/dev/tty

  printf 'Fuzzy needs Node.js 22.19.0 or newer and npm. Install them now with %s? [Y/n] ' "$label" >&3
  if ! IFS= read -r answer <&3; then
    answer=
  fi
  exec 3>&-
  case "$answer" in
    n|N|no|NO) printf '\nInstall Node.js 22.19.0 or newer and npm, then run this installer again.\n'; return 1 ;;
    *) ;;
  esac

  install_node_npm "$method" "$label"
}

detect_node_install_method() {
  case "$(uname -s)" in
    Darwin)
      if command -v brew >/dev/null 2>&1; then
        printf 'homebrew'
      else
        printf 'standalone'
      fi
      ;;
    Linux)
      if command -v apt-cache >/dev/null 2>&1 && command -v apt-get >/dev/null 2>&1 && apt_node_candidate_is_new_enough; then
        printf 'apt'
      elif command -v apk >/dev/null 2>&1 && apk_node_candidate_is_new_enough; then
        printf 'apk'
      else
        printf 'standalone'
      fi
      ;;
    *)
      printf 'standalone'
      ;;
  esac
}

apt_node_candidate_is_new_enough() {
  version=$(apt-cache policy nodejs 2>/dev/null | awk '/Candidate:/ { print $2; exit }')
  [ -n "$version" ] && [ "$version" != "(none)" ] && node_version_string_is_new_enough "$version"
}

apk_node_candidate_is_new_enough() {
  version=$(apk search -x nodejs 2>/dev/null | awk -F- '/^nodejs-/ { print $2; exit }')
  [ -n "$version" ] && node_version_string_is_new_enough "$version"
}

node_version_string_is_new_enough() {
  version="${1#v}"
  case "$version" in
    [0-9]*) ;;
    *) return 1 ;;
  esac
  version="${version%%[!0-9.]*}"
  version_ifs=${IFS- }
  IFS=.
  set -- $version
  IFS=$version_ifs
  major="${1:-}"
  minor="${2:-0}"
  patch="${3:-0}"
  case "$major" in ''|*[!0-9]*) return 1 ;; esac
  case "$minor" in ''|*[!0-9]*) minor=0 ;; esac
  case "$patch" in ''|*[!0-9]*) patch=0 ;; esac

  [ "$major" -gt 22 ] && return 0
  [ "$major" -eq 22 ] && [ "$minor" -gt 19 ] && return 0
  [ "$major" -eq 22 ] && [ "$minor" -eq 19 ] && [ "$patch" -ge 0 ] && return 0
  return 1
}

install_node_npm() {
  method="$1"; label="$2"

  if [ -t 1 ] && [ "${TERM:-}" != "dumb" ]; then
    install_node_npm_with_progress "$method" "$label"
  else
    printf '\nInstalling Node.js and npm with %s...\n\n' "$label"
    run_node_install_method "$method"
    printf '\nNode.js and npm are installed.\n'
  fi

  if [ "$method" = standalone ]; then
    load_standalone_node
    FUZZY_NODE_INSTALLED_STANDALONE=1
  fi
  hash -r
  printf '\n'
}

install_node_npm_with_progress() {
  method="$1"; label="$2"
  log_file="${TMPDIR:-/tmp}/fuzzy-installer-node.$$"
  rm -f "$log_file"
  : >"$log_file"

  run_node_install_method "$method" >"$log_file" 2>&1 &
  install_pid=$!

  printf '\033[?25l'
  animate_node_install "$log_file" "$label" &
  progress_pid=$!
  trap 'kill "$install_pid" 2>/dev/null || true; finish_install_progress "$progress_pid"; exit 130' INT TERM

  if wait "$install_pid"; then
    status=0
  else
    status=$?
  fi

  finish_install_progress "$progress_pid"
  trap - INT TERM

  if [ "$status" -ne 0 ]; then
    printf '\033[31mNode.js installation failed.\033[0m\n\n'
    cat "$log_file"
    rm -f "$log_file"
    return "$status"
  fi

  rm -f "$log_file"
  if terminal_supports_unicode; then
    printf '  \033[32m✓\033[0m Node.js and npm install complete\n'
  else
    printf '  \033[32mok\033[0m Node.js and npm install complete\n'
  fi
}

run_node_install_method() {
  case "$1" in
    homebrew) install_node_with_homebrew ;;
    apt) install_node_with_apt ;;
    apk) install_node_with_apk ;;
    standalone) install_node_standalone ;;
  esac
}

install_node_with_homebrew() {
  if brew list node >/dev/null 2>&1; then
    brew upgrade node
  else
    brew install node
  fi
}

install_node_with_apt() {
  print_sudo_note
  if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    apt-get update
    apt-get install -y nodejs npm
  else
    sudo sh -c 'apt-get update && apt-get install -y nodejs npm'
  fi
}

install_node_with_apk() {
  print_sudo_note
  run_with_sudo apk add --update-cache nodejs npm
}

install_node_standalone() {
  node_platform=$(detect_node_binary_platform) || {
    printf 'Unsupported operating system for automatic Node.js install: %s\n' "$(uname -s)"
    return 1
  }
  node_arch=$(detect_node_binary_arch) || {
    printf 'Unsupported CPU architecture for automatic Node.js install: %s\n' "$(uname -m)"
    return 1
  }
  node_dist_base="https://nodejs.org/dist/latest-v22.x"
  node_base_dir=$(node_standalone_base_dir)
  node_tmp_dir="${TMPDIR:-/tmp}/fuzzy-node.$$"

  rm -rf "$node_tmp_dir"
  mkdir -p "$node_tmp_dir" "$node_base_dir"

  printf 'Resolving Node.js binary for %s-%s\n' "$node_platform" "$node_arch"
  curl -fsSL "$node_dist_base/SHASUMS256.txt" -o "$node_tmp_dir/SHASUMS256.txt"
  node_file=$(awk -v suffix="-$node_platform-$node_arch.tar.xz" '
    index($2, "node-v") == 1 && length($2) >= length(suffix) && substr($2, length($2) - length(suffix) + 1) == suffix { print $2; exit }
  ' "$node_tmp_dir/SHASUMS256.txt")
  if [ -z "$node_file" ]; then
    printf 'No Node.js binary is available for %s-%s.\n' "$node_platform" "$node_arch"
    rm -rf "$node_tmp_dir"
    return 1
  fi

  printf 'Downloading Node.js %s\n' "${node_file%.tar.xz}"
  curl -fsSL "$node_dist_base/$node_file" -o "$node_tmp_dir/$node_file"
  verify_node_standalone_download "$node_tmp_dir" "$node_file"
  ensure_node_standalone_extract_tools "$node_platform"

  node_dir="$node_base_dir/${node_file%.tar.xz}"
  rm -rf "$node_dir"
  printf 'Extracting Node.js to %s\n' "$node_dir"
  tar -xf "$node_tmp_dir/$node_file" -C "$node_base_dir"
  rm -f "$node_base_dir/current"
  ln -s "$node_dir" "$node_base_dir/current"
  rm -rf "$node_tmp_dir"
  printf 'Node.js installed at %s\n' "$node_dir"
}

verify_node_standalone_download() {
  checksum_dir="$1"
  checksum_file_name="$2"
  awk -v file="$checksum_file_name" '$2 == file { print }' "$checksum_dir/SHASUMS256.txt" > "$checksum_dir/SHASUMS256.selected"

  if command -v sha256sum >/dev/null 2>&1; then
    printf 'Verifying Node.js download\n'
    (cd "$checksum_dir" && sha256sum -c SHASUMS256.selected)
  elif command -v shasum >/dev/null 2>&1; then
    printf 'Verifying Node.js download\n'
    (cd "$checksum_dir" && shasum -a 256 -c SHASUMS256.selected)
  fi
}

ensure_node_standalone_extract_tools() {
  extract_platform="$1"

  if [ "$extract_platform" = linux ] && ! command -v xz >/dev/null 2>&1; then
    printf 'Installing xz-utils for Node.js archive extraction\n'
    print_sudo_note
    if command -v apt-get >/dev/null 2>&1; then
      run_with_sudo apt-get update
      run_with_sudo apt-get install -y xz-utils
    elif command -v apk >/dev/null 2>&1; then
      run_with_sudo apk add --update-cache xz
    else
      printf 'xz is required to extract Node.js. Install xz and run this installer again.\n'
      return 1
    fi
  fi
}

load_standalone_node() {
  FUZZY_STANDALONE_NODE_BIN="$(node_standalone_base_dir)/current/bin"
  PATH="$FUZZY_STANDALONE_NODE_BIN:$PATH"
  export FUZZY_STANDALONE_NODE_BIN PATH
}

node_standalone_base_dir() {
  if [ -n "${XDG_DATA_HOME:-}" ]; then
    printf '%s/fuzzy-node' "$XDG_DATA_HOME"
  else
    printf '%s/.local/share/fuzzy-node' "$HOME"
  fi
}

detect_node_binary_platform() {
  case "$(uname -s)" in
    Darwin) printf 'darwin' ;;
    Linux) printf 'linux' ;;
    *) return 1 ;;
  esac
}

detect_node_binary_arch() {
  case "$(uname -m)" in
    x86_64|amd64) printf 'x64' ;;
    arm64|aarch64) printf 'arm64' ;;
    armv7l) printf 'armv7l' ;;
    ppc64le) printf 'ppc64le' ;;
    s390x) printf 's390x' ;;
    *) return 1 ;;
  esac
}

print_sudo_note() {
  if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    printf 'This may ask for your sudo password.\n\n'
  fi
}

run_with_sudo() {
  if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

select_npm_install_prefix() {
  npm_prefix=$(npm_global_prefix)
  if [ -n "$npm_prefix" ] && npm_prefix_supports_global_install "$npm_prefix"; then
    return 0
  fi

  if existing_global_fuzzy_blocks_user_local_install "$npm_prefix"; then
    print_existing_global_fuzzy_not_writable_message "$npm_prefix"
    return 1
  fi

  printf '%s/.local' "$HOME"
}

select_npm_uninstall_prefix() {
  existing_fuzzy_path="$1"
  [ -n "$existing_fuzzy_path" ] || return 0

  npm_prefix=$(npm_global_prefix)
  if [ -n "$npm_prefix" ] && [ "$existing_fuzzy_path" = "$npm_prefix/bin/$FUZZY_CMD" ]; then
    return 0
  fi

  if [ -n "${FUZZY_NPM_INSTALL_PREFIX:-}" ] && [ "$existing_fuzzy_path" = "$FUZZY_NPM_INSTALL_PREFIX/bin/$FUZZY_CMD" ]; then
    printf '%s' "$FUZZY_NPM_INSTALL_PREFIX"
    return 0
  fi

  fuzzy_bin_suffix="/bin/$FUZZY_CMD"
  case "$existing_fuzzy_path" in
    *"$fuzzy_bin_suffix") printf '%s' "${existing_fuzzy_path%$fuzzy_bin_suffix}" ;;
  esac
}

npm_global_prefix() {
  npm prefix -g 2>/dev/null || npm config get prefix 2>/dev/null
}

npm_prefix_supports_global_install() {
  prefix="$1"
  path_is_writable_or_creatable "$prefix/lib/node_modules" && path_is_writable_or_creatable "$prefix/bin"
}

existing_global_fuzzy_blocks_user_local_install() {
  npm_prefix="$1"
  [ -n "$npm_prefix" ] || return 1

  [ -e "$npm_prefix/bin/$FUZZY_CMD" ]
}

print_existing_global_fuzzy_not_writable_message() {
  npm_prefix="$1"
  existing_fuzzy_path="$npm_prefix/bin/$FUZZY_CMD"

  printf "npm's global directory is not writable: %s\n" "$npm_prefix" >&2
  printf 'Fuzzy is already installed at: %s\n\n' "$existing_fuzzy_path" >&2
  printf 'Installing another copy under %s/.local could leave your shell using the old global fuzzy, so this installer stopped.\n\n' "$HOME" >&2
  printf 'Update or remove the existing global install first. If it was installed with npm, you can run:\n\n' >&2
  printf '  sudo npm install -g --ignore-scripts %s %s\n\n' "$FUZZY_NPM_INSTALL_MIN_AGE_ARG" "$FUZZY_PACKAGE" >&2
  printf 'or uninstall it first with:\n\n' >&2
  printf '  sudo npm uninstall -g %s\n\n' "$FUZZY_PACKAGE" >&2
  printf 'Then run this installer again.\n' >&2
}

path_is_writable_or_creatable() {
  check_path="$1"
  while [ ! -e "$check_path" ]; do
    parent=${check_path%/*}
    if [ -z "$parent" ] || [ "$parent" = "$check_path" ]; then
      return 1
    fi
    check_path="$parent"
  done

  [ -d "$check_path" ] && [ -w "$check_path" ]
}

fuzzy_install_bin_dir() {
  if [ -n "${FUZZY_NPM_INSTALL_PREFIX:-}" ]; then
    printf '%s/bin' "$FUZZY_NPM_INSTALL_PREFIX"
  else
    npm_prefix=$(npm_global_prefix)
    if [ -n "$npm_prefix" ]; then
      printf '%s/bin' "$npm_prefix"
    fi
  fi
}

fuzzy_installed_path() {
  fuzzy_bin_dir=$(fuzzy_install_bin_dir)
  if [ -n "$fuzzy_bin_dir" ]; then
    printf '%s/%s' "$fuzzy_bin_dir" "$FUZZY_CMD"
  fi
}

installed_fuzzy_is_first_on_path() {
  installed_fuzzy_path=$(fuzzy_installed_path)
  [ -n "$installed_fuzzy_path" ] || return 1

  active_fuzzy_path=$(command -v "$FUZZY_CMD" 2>/dev/null) || return 1
  [ "$active_fuzzy_path" = "$installed_fuzzy_path" ]
}

shell_config_file() {
  current_shell=$(basename "${SHELL:-sh}")
  case "$current_shell" in
    fish) printf '%s/.config/fish/config.fish' "$HOME" ;;
    zsh) printf '%s/.zshrc' "${ZDOTDIR:-$HOME}" ;;
    bash)
      if [ -f "$HOME/.bashrc" ]; then
        printf '%s/.bashrc' "$HOME"
      else
        printf '%s/.profile' "$HOME"
      fi
      ;;
    *) printf '%s/.profile' "$HOME" ;;
  esac
}

path_update_command() {
  bin_dir="$1"
  current_shell=$(basename "${SHELL:-sh}")
  if [ "$bin_dir" = "$HOME/.local/bin" ]; then
    bin_expr='$HOME/.local/bin'
  else
    bin_expr="$bin_dir"
  fi

  case "$current_shell" in
    fish) printf 'fish_add_path "%s"' "$bin_expr" ;;
    *) printf 'export PATH="%s:$PATH"' "$bin_expr" ;;
  esac
}

config_file_mentions_path() {
  config_file="$1"
  command="$2"

  [ -f "$config_file" ] || return 1
  grep -Fxq "$command" "$config_file"
}

prompt_add_path_to_profile() {
  bin_dir="$1"
  if ! ( : <>/dev/tty ) 2>/dev/null; then
    return 1
  fi

  config_file=$(shell_config_file)
  command=$(path_update_command "$bin_dir")

  if config_file_mentions_path "$config_file" "$command"; then
    printf 'A PATH update for %s already exists in %s.\n' "$bin_dir" "$config_file"
    return 0
  fi

  exec 3<>/dev/tty
  printf 'Add %s to your PATH in %s now? [Y/n] ' "$bin_dir" "$config_file" >&3
  if ! IFS= read -r answer <&3; then
    answer=
  fi
  exec 3>&-
  case "$answer" in
    n|N|no|NO) return 1 ;;
    *) ;;
  esac

  mkdir -p "${config_file%/*}"
  touch "$config_file"
  printf '\n# Fuzzy\n%s\n' "$command" >> "$config_file"
  printf 'Added %s to %s.\n' "$bin_dir" "$config_file"
}

print_fuzzy_not_on_path_message() {
  fuzzy_bin_dir=$(fuzzy_install_bin_dir)
  active_fuzzy_path=$(command -v "$FUZZY_CMD" 2>/dev/null || true)

  printf 'Fuzzy was installed, but your shell is not using that install yet.\n'
  if [ -n "$active_fuzzy_path" ]; then
    printf 'Your shell currently resolves fuzzy to: %s\n' "$active_fuzzy_path"
  fi

  if [ -n "$fuzzy_bin_dir" ]; then
    prompt_add_path_to_profile "$fuzzy_bin_dir" || true
    command=$(path_update_command "$fuzzy_bin_dir")
    printf 'Restart your shell or run:\n\n'
    printf '  %s\n\n' "$command"
    printf 'Then run: fuzzy\n'
  else
    printf "Check npm's global prefix with:\n\n"
    printf '  npm prefix -g\n\n'
    printf 'Then add its bin directory to your shell PATH.\n'
  fi
}

choose_fuzzy_action() {
  existing_fuzzy_path="$1"

  if ! ( : <>/dev/tty ) 2>/dev/null; then
    print_fuzzy_action_menu "$existing_fuzzy_path"
    printf 'No terminal detected; continuing without confirmation.\n'
    if [ -n "$existing_fuzzy_path" ]; then
      FUZZY_INSTALL_ACTION=reinstall
    else
      FUZZY_INSTALL_ACTION=install
    fi
    print_fuzzy_action_selection "$FUZZY_INSTALL_ACTION"
    return 0
  fi

  exec 3<>/dev/tty
  print_fuzzy_action_menu "$existing_fuzzy_path" >&3

  while :; do
    key=$(read_tty_key)

    case "$key" in
      ""|" "|"$FUZZY_CR")
        if [ -n "$existing_fuzzy_path" ]; then
          FUZZY_INSTALL_ACTION=reinstall
        else
          FUZZY_INSTALL_ACTION=install
        fi
        break
        ;;
      y|Y)
        if [ -n "$existing_fuzzy_path" ]; then
          FUZZY_INSTALL_ACTION=reinstall
        else
          FUZZY_INSTALL_ACTION=install
        fi
        break
        ;;
      u|U)
        if [ -n "$existing_fuzzy_path" ]; then
          FUZZY_INSTALL_ACTION=uninstall
          break
        fi
        ;;
      n|N|"$FUZZY_ESC")
        FUZZY_INSTALL_ACTION=none
        break
        ;;
    esac

    printf 'Please choose one of the listed keys.\n' >&3
  done

  print_fuzzy_action_selection "$FUZZY_INSTALL_ACTION" >&3
  exec 3>&-
}

print_fuzzy_action_menu() {
  existing_fuzzy_path="$1"

  reset=
  dim=
  bold=
  cyan=
  green=
  red=
  if [ -t 1 ] && [ "${TERM:-}" != "dumb" ]; then
    reset="${FUZZY_ESC}[0m"
    dim="${FUZZY_ESC}[2m"
    bold="${FUZZY_ESC}[1m"
    cyan="${FUZZY_ESC}[38;2;71;217;250m"
    green="${FUZZY_ESC}[38;2;102;247;65m"
    red="${FUZZY_ESC}[38;2;216;59;48m"
  fi

  if [ -n "$existing_fuzzy_path" ]; then
    printf '%sFuzzy is already installed at:%s\n\n' "$bold" "$reset"
    printf '  %s\n\n' "$existing_fuzzy_path"
  fi

  if [ -n "${FUZZY_NPM_INSTALL_PREFIX:-}" ]; then
    printf "npm's global directory is not writable; Fuzzy will be installed under %s.\n\n" "$FUZZY_NPM_INSTALL_PREFIX"
  fi

  if [ -n "$existing_fuzzy_path" ]; then
    printf '%sReinstall command:%s\n\n  ' "$bold" "$reset"
  else
    printf '%sInstall command:%s\n\n  ' "$bold" "$reset"
  fi
  print_npm_install_command
  printf '\n\n'

  printf '%sChoose an action:%s\n\n' "$bold" "$reset"
  if [ -n "$existing_fuzzy_path" ]; then
    printf '  %s%-4s%s %sReinstall Fuzzy%s %s(default)%s\n' "$cyan" 'y' "$reset" "$green" "$reset" "$dim" "$reset"
    printf '  %s%-4s%s %sUninstall Fuzzy%s\n' "$cyan" 'u' "$reset" "$red" "$reset"
  else
    printf '  %s%-4s%s %sInstall Fuzzy%s %s(default)%s\n' "$cyan" 'y' "$reset" "$green" "$reset" "$dim" "$reset"
  fi
  printf '  %s%-4s%s %sDo nothing%s\n' "$cyan" 'n' "$reset" "$dim" "$reset"
}

print_fuzzy_action_selection() {
  case "$1" in
    install) message="Will install Fuzzy." ;;
    reinstall) message="Will reinstall Fuzzy." ;;
    uninstall) message="Will uninstall Fuzzy." ;;
    none) message="Chose to do nothing. Exiting." ;;
  esac
  printf '\n%s\n\n' "$message"
}

read_tty_key() {
  old_tty_state=$(stty -g < /dev/tty)
  trap 'stty "$old_tty_state" < /dev/tty; trap - INT TERM; exit 130' INT TERM
  stty -icanon -echo min 1 time 0 < /dev/tty
  if ! key=$(dd bs=1 count=1 2>/dev/null < /dev/tty); then
    key=
  fi
  stty "$old_tty_state" < /dev/tty
  trap - INT TERM
  printf '%s' "$key"
}

print_npm_install_command() {
  if [ -n "${FUZZY_NPM_INSTALL_PREFIX:-}" ]; then
    printf 'npm install -g --ignore-scripts %s --prefix %s %s' "$FUZZY_NPM_INSTALL_MIN_AGE_ARG" "$FUZZY_NPM_INSTALL_PREFIX" "$FUZZY_PACKAGE"
  else
    printf 'npm install -g --ignore-scripts %s %s' "$FUZZY_NPM_INSTALL_MIN_AGE_ARG" "$FUZZY_PACKAGE"
  fi
}

install_fuzzy_package() {
  if [ -t 1 ] && [ "${TERM:-}" != "dumb" ]; then
    install_fuzzy_package_with_progress
  else
    printf 'Installing Fuzzy...\n\n'
    run_npm_install_fuzzy error
  fi
}

run_npm_install_fuzzy() {
  npm_loglevel="$1"
  if [ -n "${FUZZY_NPM_INSTALL_PREFIX:-}" ]; then
    npm install -g --ignore-scripts "$FUZZY_NPM_INSTALL_MIN_AGE_ARG" --prefix "$FUZZY_NPM_INSTALL_PREFIX" --no-fund --no-audit "--loglevel=$npm_loglevel" --progress=false "$FUZZY_PACKAGE"
  else
    npm install -g --ignore-scripts "$FUZZY_NPM_INSTALL_MIN_AGE_ARG" --no-fund --no-audit "--loglevel=$npm_loglevel" --progress=false "$FUZZY_PACKAGE"
  fi
}

uninstall_fuzzy_package() {
  if ! npm_package_is_installed_for_uninstall; then
    printf 'I found fuzzy at:\n\n  %s\n\n' "$FUZZY_EXISTING_PATH" >&2
    printf 'but npm does not show %s installed there.\n' "$FUZZY_PACKAGE" >&2
    printf 'Nothing was removed.\n' >&2
    return 1
  fi

  printf 'Uninstalling Fuzzy...\n\n'
  run_npm_uninstall_fuzzy error
  hash -r

  if [ -e "$FUZZY_EXISTING_PATH" ] || [ -L "$FUZZY_EXISTING_PATH" ]; then
    printf '\nnpm uninstall finished, but fuzzy is still present at:\n\n  %s\n' "$FUZZY_EXISTING_PATH" >&2
    return 1
  fi
}

npm_package_is_installed_for_uninstall() {
  if [ -n "${FUZZY_NPM_UNINSTALL_PREFIX:-}" ]; then
    npm ls -g --prefix "$FUZZY_NPM_UNINSTALL_PREFIX" --depth=0 "$FUZZY_PACKAGE" >/dev/null 2>&1
  else
    npm ls -g --depth=0 "$FUZZY_PACKAGE" >/dev/null 2>&1
  fi
}

run_npm_uninstall_fuzzy() {
  npm_loglevel="$1"
  if [ -n "${FUZZY_NPM_UNINSTALL_PREFIX:-}" ]; then
    npm uninstall -g --prefix "$FUZZY_NPM_UNINSTALL_PREFIX" --no-fund --no-audit "--loglevel=$npm_loglevel" --progress=false "$FUZZY_PACKAGE"
  else
    npm uninstall -g --no-fund --no-audit "--loglevel=$npm_loglevel" --progress=false "$FUZZY_PACKAGE"
  fi
}

install_fuzzy_package_with_progress() {
  log_file="${TMPDIR:-/tmp}/fuzzy-installer-npm.$$"
  rm -f "$log_file"
  : >"$log_file"

  run_npm_install_fuzzy verbose >"$log_file" 2>&1 &
  npm_pid=$!

  printf '\033[?25l'
  animate_npm_install "$log_file" &
  progress_pid=$!
  trap 'kill "$npm_pid" 2>/dev/null || true; finish_install_progress "$progress_pid"; exit 130' INT TERM

  if wait "$npm_pid"; then
    status=0
  else
    status=$?
  fi

  finish_install_progress "$progress_pid"
  trap - INT TERM

  if [ "$status" -ne 0 ]; then
    printf '\033[31mInstallation failed.\033[0m\n\n'
    cat "$log_file"
    rm -f "$log_file"
    return "$status"
  fi

  rm -f "$log_file"
  if terminal_supports_unicode; then
    printf '  \033[32m✓\033[0m npm install complete\n'
  else
    printf '  \033[32mok\033[0m npm install complete\n'
  fi
}

finish_install_progress() {
  progress_pid="$1"

  kill "$progress_pid" 2>/dev/null || true
  wait "$progress_pid" 2>/dev/null || true
  printf '\r\033[K\033[?25h'
}

terminal_supports_unicode() {
  locale="${LC_ALL:-${LC_CTYPE:-${LANG:-}}}"

  case "$locale" in
    *UTF-8*|*utf-8*|*UTF8*|*utf8*) return 0 ;;
  esac

  case "${TERM_PROGRAM:-}" in
    Apple_Terminal|iTerm.app|vscode|WezTerm) return 0 ;;
  esac

  return 1
}

spinner_frame() {
  frame_step="$1"
  frame_count="$2"

  if [ "$frame_count" -eq 10 ]; then
    case $((frame_step % 10)) in
      0) printf '⠋' ;;
      1) printf '⠙' ;;
      2) printf '⠹' ;;
      3) printf '⠸' ;;
      4) printf '⠼' ;;
      5) printf '⠴' ;;
      6) printf '⠦' ;;
      7) printf '⠧' ;;
      8) printf '⠇' ;;
      *) printf '⠏' ;;
    esac
  else
    case $((frame_step % 4)) in
      0) printf '-' ;;
      1) printf '\\' ;;
      2) printf '|' ;;
      *) printf '/' ;;
    esac
  fi
}

animate_npm_install() {
  log_file="$1"

  if terminal_supports_unicode; then
    full="█"
    empty="░"
    frame_count=10
  else
    full="#"
    empty="-"
    frame_count=4
  fi

  step=0
  label="starting npm install"
  while :; do
    frame=$(spinner_frame "$step" "$frame_count")
    if [ $((step % 5)) -eq 0 ]; then
      label=$(npm_install_progress_label "$log_file" "$label")
    fi
    draw_install_progress "$step" "$frame" "$label" "$full" "$empty"
    step=$((step + 1))
    sleep 0.08
  done
}

animate_node_install() {
  log_file="$1"
  method_label="$2"

  if terminal_supports_unicode; then
    full="█"
    empty="░"
    frame_count=10
  else
    full="#"
    empty="-"
    frame_count=4
  fi

  step=0
  label="starting ${method_label} install"
  while :; do
    frame=$(spinner_frame "$step" "$frame_count")
    if [ $((step % 5)) -eq 0 ]; then
      label=$(node_install_progress_label "$log_file" "$label")
    fi
    draw_install_progress "$step" "$frame" "$label" "$full" "$empty" "Installing Node.js"
    step=$((step + 1))
    sleep 0.08
  done
}

node_install_progress_label() {
  log_file="$1"
  label="$2"

  while IFS= read -r line; do
    line=${line##*"$FUZZY_CR"}
    case "$line" in
      "") ;;
      Resolving\ Node.js*) label="resolving Node.js binary" ;;
      Downloading\ Node.js*) label="$line" ;;
      Verifying\ Node.js*) label="verifying download" ;;
      Installing\ xz-utils*) label="installing xz-utils" ;;
      Extracting\ Node.js*) label="extracting Node.js" ;;
      Node.js\ installed*) label="Node.js installed" ;;
      Hit:*|Get:*|Ign:*) label="updating package lists" ;;
      Reading\ package\ lists*) label="reading package lists" ;;
      Building\ dependency\ tree*) label="resolving dependencies" ;;
      The\ following\ NEW\ packages*) label="installing dependencies" ;;
      Need\ to\ get*|Fetched\ *) label="$line" ;;
      Selecting\ previously\ unselected\ package*) label="selecting packages" ;;
      Preparing\ to\ unpack*) label="preparing packages" ;;
      Unpacking\ *|Setting\ up\ *) label="$line" ;;
      fetch\ *) label="fetching packages" ;;
      *Installing\ nodejs*) label="$line" ;;
      OK:\ *) label="$line" ;;
      ==\>\ Downloading*) label="downloading packages" ;;
      ==\>\ Installing*|==\>\ Upgrading*) label="$line" ;;
      ==\>\ Pouring*) label="installing package" ;;
      *already\ installed*) label="$line" ;;
    esac
  done < "$log_file"

  if [ "${#label}" -gt 64 ]; then
    label=$(printf '%.61s...' "$label")
  fi
  printf '%s' "$label"
}

npm_install_progress_label() {
  log_file="$1"
  label="$2"
  metadata_cache_count=0
  metadata_fetch_count=0
  tarball_cache_count=0
  tarball_fetch_count=0

  while IFS= read -r line; do
    line=${line%"$FUZZY_CR"}
    case "$line" in
      npm\ verbose\ title\ npm\ install*)
        label="resolving packages"
        ;;
      npm\ http\ fetch\ GET\ *https://registry.npmjs.org/*.tgz*)
        tarball_fetch_count=$((tarball_fetch_count + 1))
        label="fetching tarballs (${tarball_fetch_count})"
        ;;
      npm\ http\ cache\ *@https://registry.npmjs.org/*.tgz*)
        tarball_cache_count=$((tarball_cache_count + 1))
        if [ "$tarball_fetch_count" -gt 0 ]; then
          label="fetching tarballs (${tarball_fetch_count})"
        else
          label="checking tarballs (${tarball_cache_count})"
        fi
        ;;
      npm\ http\ fetch\ GET\ *https://registry.npmjs.org/*)
        metadata_fetch_count=$((metadata_fetch_count + 1))
        label="fetching package metadata (${metadata_fetch_count})"
        ;;
      npm\ http\ cache\ https://registry.npmjs.org/*)
        metadata_cache_count=$((metadata_cache_count + 1))
        if [ "$metadata_fetch_count" -gt 0 ]; then
          label="fetching package metadata (${metadata_fetch_count})"
        else
          label="checking cached metadata (${metadata_cache_count})"
        fi
        ;;
      npm\ info\ run\ *)
        rest=${line#npm info run }
        package=${rest%% *}
        rest=${rest#* }
        script=${rest%% *}
        package=${package%@*}
        case "$line" in
          *\{\ code:*) label="finished ${script} for ${package}" ;;
          *) label="running ${script} for ${package}" ;;
        esac
        ;;
      changed\ *|added\ *|removed\ *|updated\ *|up\ to\ date\ *)
        label="$line"
        ;;
    esac
  done < "$log_file"

  printf '%s' "$label"
}

draw_install_progress() {
  step="$1"; frame="$2"; label="$3"; full="$4"; empty="$5"; title="${6:-Installing Fuzzy}"

  reset="${FUZZY_ESC}[0m"
  dim="${FUZZY_ESC}[2m"
  cyan="${FUZZY_ESC}[38;2;71;217;250m"
  red="${FUZZY_ESC}[38;2;216;59;48m"
  green="${FUZZY_ESC}[38;2;102;247;65m"
  orange="${FUZZY_ESC}[38;2;246;155;49m"
  bold="${FUZZY_ESC}[1m"

  width=28
  trail=8
  head=$((step % (width + trail)))
  bar=""

  i=0
  while [ "$i" -lt "$width" ]; do
    age=$((head - i))
    if [ "$age" -ge 0 ] && [ "$age" -lt "$trail" ]; then
      case "$age" in
        0|1) cell="${green}${full}${reset}" ;;
        2|3) cell="${cyan}${full}${reset}" ;;
        4|5) cell="${red}${full}${reset}" ;;
        *) cell="${orange}${full}${reset}" ;;
      esac
    else
      cell="${dim}${empty}${reset}"
    fi
    bar="${bar}${cell}"
    i=$((i + 1))
  done

  printf '\r\033[K  %s%s%s %s %s%s%s %s' "$orange" "$frame" "$reset" "$bar" "$bold" "$title" "$reset" "$label"
}

fuzzy_logo_animation() {
  if [ ! -t 1 ] || [ "${TERM:-}" = "dumb" ]; then
    print_static_logo
    return
  fi

  esc="${FUZZY_ESC}["
  reset="${FUZZY_ESC}[0m"
  hide="${esc}?25l"
  show="${esc}?25h"
  clear="${esc}H"

  printf '%s%s' "$hide" "${esc}2J${esc}H"

  draw_logo_frame "$clear" "$reset" 1 none 0 0 0 0; sleep 0.12
  draw_logo_frame "$clear" "$reset" 2 none 0 0 0 0; sleep 0.12
  draw_logo_frame "$clear" "$reset" 3 none 0 0 0 0; sleep 0.12
  draw_logo_frame "$clear" "$reset" 4 none 0 0 0 0; sleep 0.12
  draw_logo_frame "$clear" "$reset" 5 none 0 0 0 0; sleep 0.40

  draw_logo_frame "$clear" "$reset" 5 none 0 0 1 0; sleep 0.10
  draw_logo_frame "$clear" "$reset" 5 none 0 0 0 0; sleep 0.10
  draw_logo_frame "$clear" "$reset" 5 none 0 0 1 0; sleep 0.40

  printf '%s%s\n' "$reset" "$show"
}

draw_logo_frame() {
  clear="$1"; reset="$2"; phase="$3"; active="$4"; ax="$5"; ay="$6"; flash="$7"; white="$8"

  orange="${FUZZY_ESC}[38;2;246;155;49m"
  cyan="${FUZZY_ESC}[38;2;71;217;250m"
  red="${FUZZY_ESC}[38;2;216;59;48m"
  green="${FUZZY_ESC}[38;2;102;247;65m"
  white_c="${FUZZY_ESC}[38;2;255;255;255m"
  flash_c="${FUZZY_ESC}[38;2;255;245;180m"

  frame="${clear}\n"
  for y in 0 1 2 3 4; do
    frame="${frame}    "
    for x in 0 1 2 3 4; do
      set_logo_cell_color "$phase" "$active" "$ax" "$ay" "$flash" "$white" "$y" "$x"
      if [ "$LOGO_COLOR" = "panel" ]; then
        case "$x" in
          0|2|3) frame="${frame}       " ;;
          1|4)   frame="${frame}        " ;;
        esac
      else
        case "$LOGO_COLOR" in
          orange) col="$orange" ;; cyan)  col="$cyan" ;;  red)   col="$red" ;;
          green)  col="$green" ;;  white) col="$white_c" ;; *)    col="$flash_c" ;;
        esac
        case "$x:$y" in
          0:0) seg='███████' ;; 0:1) seg='██     ' ;; 0:2) seg='█████  ' ;;
          0:3) seg='██     ' ;; 0:4) seg='██     ' ;;
          1:0) seg='██    ██' ;; 1:1) seg='██    ██' ;; 1:2) seg='██    ██' ;;
          1:3) seg='██    ██' ;; 1:4) seg=' ██████ ' ;;
          2:0) seg='███████' ;; 2:1) seg='   ███ ' ;; 2:2) seg='  ███  ' ;;
          2:3) seg=' ███   ' ;; 2:4) seg='███████' ;;
          3:0) seg='███████' ;; 3:1) seg='   ███ ' ;; 3:2) seg='  ███  ' ;;
          3:3) seg=' ███   ' ;; 3:4) seg='███████' ;;
          4:0) seg='██    ██' ;; 4:1) seg=' ██  ██ ' ;; 4:2) seg='  ████  ' ;;
          4:3) seg='   ██   ' ;; 4:4) seg='   ██   ' ;;
        esac
        frame="${frame}${col}${seg}${reset}"
      fi
      [ "$x" -lt 4 ] && frame="${frame} "
    done
    frame="${frame}\n"
  done
  printf '%b' "$frame"
}

set_logo_cell_color() {
  phase="$1"; active="$2"; ax="$3"; ay="$4"; flash="$5"; white="$6"; y="$7"; x="$8"

  if [ "$x" -ge "$phase" ]; then LOGO_COLOR=panel; return; fi
  if [ "$white" = 1 ]; then LOGO_COLOR=white; return; fi
  if [ "$flash" = 1 ]; then LOGO_COLOR=flash; return; fi

  case "$x" in
    0) LOGO_COLOR=orange ;;
    1) LOGO_COLOR=cyan ;;
    2) LOGO_COLOR=red ;;
    3) LOGO_COLOR=green ;;
    4) LOGO_COLOR=white ;;
    *) LOGO_COLOR=panel ;;
  esac
}


print_static_logo() {
  cat <<'EOF'

    ███████ ██    ██ ███████ ███████ ██    ██
    ██      ██    ██    ███     ███   ██  ██
    █████   ██    ██   ███     ███     ████
    ██      ██    ██  ███     ███       ██
    ██       ██████  ███████ ███████    ██

EOF
}

fuzzy_installer_main "$@"
