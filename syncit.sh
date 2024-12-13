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

# Function to check if file or directory is modified
is_modified() {
  local src_path=$1
  local target_path=$2
  if [ -f "$src_path" ]; then
    if [ ! -f "$target_path" ]; then
      return 0
    elif [ "$src_path" -nt "$target_path" ]; then
      return 0
    fi
  elif [ -d "$src_path" ]; then
    if [ ! -d "$target_path" ]; then
      return 0
    elif [ "$(find "$src_path" -newer "$target_path" -print -quit)" ]; then
      return 0
    fi
  fi
  return 1
}

# Function to display help
show_help() {
  echo "Usage: $0 [-h] [-V] [-y] [-f <file_list>] [-d <target_dir>] <source_dir_or_file> ..."
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

# Parse command-line options
while getopts ":Vyhd:f:" opt; do
  case $opt in
    V) VERBOSE=true;;
    y) AUTO_ACCEPT=true;;
    f) FILE_LIST="$OPTARG";;
    d) TARGET_DIR="$OPTARG";;
    h | *) show_help; exit 0;;
    \?) echo "Invalid option: -$OPTARG"; exit 1;;
  esac
done
shift $((OPTIND - 1))

# Check if source files/directories are provided
if [ -z "$FILE_LIST" ] && [ $# -eq 0 ]; then
  echo "${RED}Error:${NC} No source files or directories specified."
  show_help
  exit 1
fi

# Check if target directory exists and create it if necessary
if [ ! -d "$TARGET_DIR" ]; then
  mkdir -p "$TARGET_DIR"
fi

# Get list of source files and directories
SRC_DIRS_AND_FILES=()

if [ -n "$FILE_LIST" ]; then
  if [ ! -f "$FILE_LIST" ]; then
    echo -e "${RED}Error${NC}: File list '$FILE_LIST' does not exist"
    exit 1
  fi

  while IFS= read -r line; do
    line=$(eval echo "$line")  # Evaluate the line to expand variables
    if [ -e "$line" ]; then
      SRC_DIRS_AND_FILES+=("$line")
    else
      echo -e "${RED}Warning${NC}: '$line' does not exist"
    fi
  done < "$FILE_LIST"
else
  echo "No file list provided."
  show_help
  exit 1
fi



# Prepare synchronization summary
SYNC_SUMMARY=""

# Synchronize files and directories
#echo -e "\n${BLUE}Synchronizing to '${TARGET_DIR}/' :${NC}"
for src_dir_or_file in "${SRC_DIRS_AND_FILES[@]}"; do
  src_dir_or_file=$(echo "$src_dir_or_file" | sed 's|^~|'"$HOME"'|')  # Replace '~' with '$HOME'
  subdir_or_file_name=$(basename "$src_dir_or_file")
  target_path="$TARGET_DIR/$subdir_or_file_name"

  if [ -f "$src_dir_or_file" ]; then
    # File
    is_modified "$src_dir_or_file" "$target_path"
    if [ $? -eq 0 ]; then
      if $VERBOSE; then
        echo -e "\t${GREEN}Modified : ${NC}$subdir_or_file_name"
      fi
      mkdir -p "$(dirname "$target_path")"
      if $VERBOSE; then
        rsync -av --force --delete --dry-run "$src_dir_or_file" "$target_path"
      fi
      if [ $? -eq 0 ]; then
        if [ ! -f "$target_path" ]; then
          SYNC_SUMMARY+="\t${GREEN}Create : ${NC}$subdir_or_file_name\n"
        else
          SYNC_SUMMARY+="\t${GREEN}Sync : ${NC}$subdir_or_file_name\n"
        fi
      else
        SYNC_SUMMARY+="\t${RED}Error syncing : ${RED}$subdir_or_file_name\n"
      fi
    else
      if $VERBOSE; then
        echo -e "\t${WHITE}Skip : ${NC}$subdir_or_file_name (up to date)"
      fi
    fi
  elif [ -d "$src_dir_or_file" ]; then
    # Directory
    target_path="$TARGET_DIR/$subdir_or_file_name"
    is_modified "$src_dir_or_file" "$target_path"
    if [ $? -eq 0 ]; then
      if $VERBOSE; then
        echo -e "\t${GREEN}Modified : ${NC}$subdir_or_file_name/"
      fi
      if $VERBOSE; then
        rsync -av --recursive --force --delete --dry-run "$src_dir_or_file/" "$target_path/"
      fi
      if [ $? -eq 0 ]; then
        if [ ! -d "$target_path" ]; then
          SYNC_SUMMARY+="\t${GREEN}Create : ${NC}$subdir_or_file_name/\n"
        else
          SYNC_SUMMARY+="\t${GREEN}Sync : ${NC}$subdir_or_file_name/\n"
        fi
      else
        SYNC_SUMMARY+="\t${RED}Error syncing : ${NC}$subdir_or_file_name/\n"
      fi
    else
      if $VERBOSE; then
        echo -e "\t${WHITE}Skip : ${NC}$subdir_or_file_name/ (up to date)"
      fi
    fi
  fi
done

# Display synchronization summary
#echo -e "$SYNC_SUMMARY"
if [ -n "$SYNC_SUMMARY" ]; then
  echo -e "\n${BLUE}Synchronizing to '${TARGET_DIR}/' :${NC}"
  echo -e "$SYNC_SUMMARY"
else
  echo -e "\t${GREEN}No job to do${NC}"
  exit 0
fi


# Ask for confirmation if not auto-accepting
if ! $AUTO_ACCEPT; then
#  read -p "Confirm synchronization? (y/n) " -n 1 -r
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
