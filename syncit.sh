#!/bin/bash

# Set colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color

# Set default values
VERBOSE=false
AUTO_ACCEPT=false
FILE_LIST=""
TARGET_DIR="."  # Current directory as default target

# Function to check if rsync is installed
check_rsync() {
  if ! command -v rsync &> /dev/null; then
    echo -e "${RED}Error: rsync is missing${NC}"
    exit 1
  fi
}

# Function to check if file or directory is modified
is_modified() {
  local src_path=$1
  local target_path=$2
  if [ -f "$src_path" ]; then
    [ ! -f "$target_path" ] || [ "$src_path" -nt "$target_path" ]
  elif [ -d "$src_path" ]; then
    [ ! -d "$target_path" ] || [ -n "$(find "$src_path" -newer "$target_path" -print -quit)" ]
  else
    return 1
  fi
}

# Function to display help
show_help() {
  echo "Usage: $0 [-h] [-V] [-y] [-f <file_list>] [-d <target_dir>] <source_dir_or_file> ..."
  echo " "
  echo "Options:"
  echo "  -h, --help       Display this help message"
  echo "  -V               Verbose mode (show changes with --dry-run)"
  echo "  -y               Auto-accept synchronization (skip confirmation)"
  echo "  -f <file_list>   Read source files/directories from a text file"
  echo "  -d <target_dir>  Specify the target directory (default: current directory)"
  echo "Examples:"
  echo "  $0 /path/to/source /path/to/target"
  echo "  $0 -f sources.txt -d /path/to/target"
  echo "  $0 ~/Documents ~/Backup -V"
}

# Function to parse command-line options
parse_options() {
  while getopts ":Vyhd:f:" opt; do
    case $opt in
      V) VERBOSE=true;;
      y) AUTO_ACCEPT=true;;
      f) FILE_LIST="$OPTARG";;
      d) TARGET_DIR="$OPTARG";;
      h) show_help; exit 0;;
      \?) echo "Invalid option: -$OPTARG"; exit 1;;
    esac
  done
  shift $((OPTIND - 1))
}

# Function to read source files and directories from a file
read_file_list() {
  local file_list=$1
  local -n src_dirs_and_files=$2
  if [ ! -f "$file_list" ]; then
    echo -e "${RED}Error${NC}: File list '$file_list' does not exist"
    exit 1
  fi

  while IFS= read -r line; do
    # Skip empty lines or lines with only whitespace
    if [[ -z "${line// }" ]]; then
      continue
    fi

    line=$(eval echo "$line")  # Evaluate the line to expand variables
    if [ -e "$line" ]; then
      src_dirs_and_files+=("$line")
    else
      echo -e "${RED}Warning${NC}: '$line' does not exist"
    fi
  done < "$file_list"
}

# Function to synchronize files and directories
sync_files() {
  local src_dir_or_file=$1
  local target_dir=$2
  local verbose=$3
  local sync_summary=$4

  src_dir_or_file=$(echo "$src_dir_or_file" | sed 's|^~|'"$HOME"'|')
  local subdir_or_file_name=$(basename "$src_dir_or_file")
  local target_path="$target_dir/$subdir_or_file_name"

  if is_modified "$src_dir_or_file" "$target_path"; then
    if $verbose; then
      echo -e "\t${GREEN}Modified : ${NC}$subdir_or_file_name"
    fi
    mkdir -p "$(dirname "$target_path")"
    if $verbose; then
      rsync -av --force --delete --dry-run "$src_dir_or_file" "$target_path"
    fi
    if [ $? -eq 0 ]; then
      if [ ! -e "$target_path" ]; then
        eval "$sync_summary+=\"\t${GREEN}Create : ${NC}$subdir_or_file_name\n\""
      else
        eval "$sync_summary+=\"\t${GREEN}Sync : ${NC}$subdir_or_file_name\n\""
      fi
    else
      eval "$sync_summary+=\"\t${RED}Error syncing : ${NC}$subdir_or_file_name\n\""
    fi
  else
    if $verbose; then
      echo -e "\t${WHITE}Skip : ${NC}$subdir_or_file_name (up to date)"
    fi
  fi
}

# Main function
main() {
  check_rsync
  parse_options "$@"

  # Check if source files/directories are provided
  if [ -z "$FILE_LIST" ] && [ $# -eq 0 ]; then
    echo -e "${RED}Error:${NC} No source files or directories specified."
    show_help
    exit 1
  fi

  # Check if target directory exists and create it if necessary
  if [ ! -d "$TARGET_DIR" ]; then
    echo -e "Target directory doesn't exist, creating..."
    mkdir -p "$TARGET_DIR"
  fi

  # Get list of source files and directories
  SRC_DIRS_AND_FILES=()
  if [ -n "$FILE_LIST" ]; then
    read_file_list "$FILE_LIST" SRC_DIRS_AND_FILES
  else
    SRC_DIRS_AND_FILES=("$@")
  fi

  # Prepare synchronization summary
  SYNC_SUMMARY=""

  # Synchronize files and directories
  for src_dir_or_file in "${SRC_DIRS_AND_FILES[@]}"; do
    sync_files "$src_dir_or_file" "$TARGET_DIR" "$VERBOSE" SYNC_SUMMARY
  done

  # Display synchronization summary
  if [ -n "$SYNC_SUMMARY" ]; then
    echo -e "\n${BLUE}Synchronizing to '${TARGET_DIR}/' :${NC}"
    echo -e "$SYNC_SUMMARY"
  else
    echo -e "\t${GREEN}No job to do${NC}"
    exit 0
  fi

  # Ask for confirmation if not auto-accepting
  if ! $AUTO_ACCEPT; then
    echo -e "${BLUE}Confirm synchronization? (y/n) ${NC}"
    read -n 1 -r
    echo -e "\n"
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "Synchronization confirmed, executing..."
      # Perform actual synchronization
      for src_dir_or_file in "${SRC_DIRS_AND_FILES[@]}"; do
        src_dir_or_file=$(echo "$src_dir_or_file" | sed 's|^~|'"$HOME"'|')
        subdir_or_file_name=$(basename "$src_dir_or_file")
        target_path="$TARGET_DIR/$subdir_or_file_name"

        if [ -f "$src_dir_or_file" ]; then
          rsync -av --force --delete "$src_dir_or_file" "$target_path" &> /dev/null
        elif [ -d "$src_dir_or_file" ]; then
          rsync -av --recursive --force --delete "$src_dir_or_file/" "$target_path/" &> /dev/null
        fi
      done
    else
      echo -e "${RED}Synchronization cancelled${NC}"
      exit 1
    fi
  fi
}

# Execute main function
main "$@"
