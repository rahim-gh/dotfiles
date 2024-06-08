#!/bin/bash

# Define the source directories and files
SRC_DIRS_AND_FILES=(
  "$HOME/.zshrc"
  "$HOME/.termux"
  "$HOME/.config/nvim"
  "$HOME/.config/starship.toml"
  # Add more directories and files as needed
)

# Define the target directory (current directory)
TARGET_DIR="."

# Define colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
WHITE='\033[0;37m'
NC='\033[0m'

# Function to list files to sync
# This function takes a source directory or file as an argument
# and lists it with a white color
list_files_to_sync() {
  local src_dir_or_file=$1
  if [ -f "$src_dir_or_file" ]; then
    echo -e "\t${WHITE}$src_dir_or_file${NC}"
  elif [ -d "$src_dir_or_file" ]; then
    echo -e "\t${WHITE}$src_dir_or_file/${NC}"
  fi
}

# Function to synchronize directories and files
# This function takes a source directory or file and a target subdirectory or file as arguments
# and synchronizes them using rsync
sync_dirs_and_files() {
  local src_dir_or_file=$1
  local target_subdir_or_file=$2

  if [ -d "$src_dir_or_file" ]; then
    mkdir -p "$TARGET_DIR/$target_subdir_or_file"
    rsync -av --delete "$src_dir_or_file/" "$TARGET_DIR/$target_subdir_or_file/" &> /dev/null
    if [ $? -eq 0 ]; then
      echo -e "\t${GREEN}$src_dir_or_file/ synced${NC}"
    else
      echo -e "\t${RED}$src_dir_or_file/ NOT synced, error occurred${NC}"
    fi
  else
    rsync -av --delete "$src_dir_or_file" "$TARGET_DIR/$target_subdir_or_file" &> /dev/null
    if [ $? -eq 0 ]; then
      echo -e "\t${GREEN}$src_dir_or_file synced${NC}"
    else
      echo -e "\t${RED}$src_dir_or_file NOT synced, error occurred${NC}"
    fi
  fi
}

# List files to sync for each source directory and file and collect the information
echo -e "${BLUE}Synchronize Plan:${NC}"
echo -e "${GREEN}Files to be synced:${NC}"
for src_dir_or_file in "${SRC_DIRS_AND_FILES[@]}"; do
  if [ -f "$src_dir_or_file" ]; then
    list_files_to_sync "$src_dir_or_file"
  fi
done
echo -e "\n${GREEN}Folders to be synced:${NC}"
for src_dir_or_file in "${SRC_DIRS_AND_FILES[@]}"; do
  if [ -d "$src_dir_or_file" ]; then
    list_files_to_sync "$src_dir_or_file"
  fi
done

# Prompt user for acceptance
echo -e "\n${WHITE}Accept the synced? (y/n)${NC}"
read -p "> " user_input

if [ "$user_input" != "y" ]; then
  echo -e "\n${RED}Synchronization cancelled.${NC}\n"
  exit 1
fi

# Synchronize each source directory and file
echo -e "\n${BLUE}In Progress:${NC} "
for src_dir_or_file in "${SRC_DIRS_AND_FILES[@]}"; do
  subdir_or_file_name=$(basename "$src_dir_or_file")
  sync_dirs_and_files "$src_dir_or_file" "$subdir_or_file_name"
done

echo -e "\n${WHITE}Script finished. exit...${NC}"
