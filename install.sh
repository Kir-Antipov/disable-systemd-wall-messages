#!/bin/sh
#
# Disable utterly useless systemd wall messages.

#################################################
# Prints a brief help message.
# Arguments:
#   None
# Outputs:
#   Writes the help message to stdout.
#################################################
help() {
  echo "Usage: ${0} [<options>]"
  echo
  echo "Disable utterly useless systemd wall messages."
  echo
  echo "Examples:"
  echo "  sudo ${0}"
  echo
  echo "Options:"
  echo "  -h, --help  Display this help text and exit."
  echo "  -u, --undo  Undo the changes made by this script."
}

#################################################
# Formats and prints the provided error message.
# Arguments:
#   $1. The error message to format and print.
# Outputs:
#   Writes the formatted error message to stderr.
# Returns:
#   Always returns 1.
#################################################
error() {
  echo "${0}: ${1}" >& 2
  return 1
}

#################################################
# Formats and prints the provided error message,
# displays the help page, and terminates the
# process.
# Arguments:
#   $1. The error message to format and print.
# Outputs:
#   Writes the formatted error message to stderr.
# Returns:
#   Never returns (exits with a status of 1).
#################################################
fatal_error() {
  error "${1}"
  help >& 2
  exit 1
}

#################################################
# Downloads a file.
# Arguments:
#   $1. The URL of the file to download.
#   $2. The destination of the downloaded file.
#       If not provided, the file will be written
#       to stdout.
# Returns:
#   0 if the operation succeeds;
#   otherwise, a non-zero status.
#################################################
download() {
  if command_exists wget; then
    wget -O "${2:-"-"}" "${1}"
  elif command_exists curl; then
    curl -Lo "${2:-"-"}" "${1}"
  fi
}

#################################################
# Copies a file from the project's source
# directory to the corresponding location
# in the target system.
# Arguments:
#   $1. The source file path.
#   $2. The permissions to apply on
#       the copied file.
#       If not provided, defaults to 600.
#   $3. The permissions to apply on
#       the copied file's parent directory.
#       If not provided, defaults to 755.
# Returns:
#   0 if the operation succeeds;
#   otherwise, a non-zero status.
#################################################
unwrap() {
  unwrapped_file_path="`echo "${1}" | sed "s/^[^/]*//"`"
  mkdir -m=${3:-755} -p "`dirname "${unwrapped_file_path}"`"

  if [ -f "${1}" ]; then
    cp "${1}" "${unwrapped_file_path}"
  else
    download "https://github.com/Kir-Antipov/disable-systemd-wall-messages/blob/HEAD/${1}?raw=true" "${unwrapped_file_path}"
  fi

  [ $? -eq 0 ] && chmod "${2:-600}" "${unwrapped_file_path}"
}

#################################################
# Asserts that the current user is "root" (i.e.,
# a superuser). Otherwise, terminates the current
# process.
# Arguments:
#   None
# Outputs:
#   Writes the error message, if any, to stderr.
# Returns:
#   0 if the current user is a superuser;
#   otherwise, never returns (exits the shell
#   with a status of 1).
#################################################
assert_is_root() {
  [ "${EUID:-"`id -u`"}" -eq 0 ] && return

  error "cannot perform the installation: Permission denied"
  exit 1
}

#################################################
# Undoes all changes made by this script.
# Arguments:
#   None
#################################################
uninstall() {
  assert_is_root

  systemctl stop disable-systemd-wall-messages.service
  systemctl disable disable-systemd-wall-messages.service
  rm -f /etc/systemd/system/disable-systemd-wall-messages.service
}

#################################################
# The main entry point for the script.
# Arguments:
#   ... A list of the command line arguments.
#################################################
main() {
  # Parse the arguments and options.
  while [ -n "${1}" ]; do
    case "${1}" in
      -h|--help) help; exit 0 ;;
      -u|--undo|--uninstall) uninstall; exit 0 ;;
      -*) fatal_error "invalid option: ${1}" ;;
      *) fatal_error "invalid argument: ${1}" ;;
    esac
    shift 2> /dev/null
  done

  # Ensure that prerequisites for the script are met.
  assert_is_root

  # Create "disable-systemd-wall-messages.service" and enable it.
  unwrap src/etc/systemd/system/disable-systemd-wall-messages.service && \
  systemctl start disable-systemd-wall-messages.service && \
  systemctl enable disable-systemd-wall-messages.service
}

main "$@"
