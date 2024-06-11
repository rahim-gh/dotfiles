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

# Function to check if source is modified compared to target
is_modified() {
  local src_dir_or_file=$1
  local target_subdir_or_file=$2

  if [ -f "$src_dir_or_file" ]; then
    if [ -f "$TARGET_DIR/$target_subdir_or_file" ]; then
      if [ "$(stat -c "%Y" "$src_dir_or_file")" -gt "$(stat -c "%Y" "$TARGET_DIR/$target_subdir_or_file")" ]; then
        return 0  # Modified
      else
        return 1  # Up-to-date
      fi
    else
      return 2  # New file
    fi
  elif [ -d "$src_dir_or_file" ]; then
    if [ -d "$TARGET_DIR/$target_subdir_or_file" ]; then
      if [ "$(find "$src_dir_or_file" -type f -exec stat -c "%Y" {} \; | sort -n | tail -1)" -gt "$(find "$TARGET_DIR/$target_subdir_or_file" -type f -exec stat -c "%Y" {} \; | sort -n | tail -1)" ]; then
        return 0  # Modified
      else
        return 1  # Up-to-date
      fi
    else
      return 2  # New directory
    fi
  fi
}

# Check if any files or directories need to be synced
needs_sync=0
for src_dir_or_file in "${SRC_DIRS_AND_FILES[@]}"; do
  if [ -f "$src_dir_or_file" ]; then
    subdir_or_file_name=$(basename "$src_dir_or_file")
    is_modified "$src_dir_or_file" "$subdir_or_file_name"
    if [ $? -eq 0 ]; then
      needs_sync=1
      break
    fi
  elif [ -d "$src_dir_or_file" ]; then
    subdir_or_file_name=$(basename "$src_dir_or_file")
    is_modified "$src_dir_or_file" "$subdir_or_file_name"
    if [ $? -eq 0 ]; then
      needs_sync=1
      break
    fi
  fi
done

if [ $needs_sync -eq 0 ]; then
  echo -e "${WHITE}All files and folders are up to date. No sync needed.${NC}"
  exit 0
fi

# Prompt user for acceptance
echo -e "${BLUE}Synchronize Plan:${NC}"
echo -e "${GREEN}Files to be synced:${NC}"
for src_dir_or_file in "${SRC_DIRS_AND_FILES[@]}"; do
  if [ -f "$src_dir_or_file" ]; then
    subdir_or_file_name=$(basename "$src_dir_or_file")
    is_modified "$src_dir_or_file" "$subdir_or_file_name"
    if [ $? -eq 0 ]; then
        echo -e "\t${GREEN}${subdir_or_file_name} : modified${NC}"
    else
        echo -e "\t${WHITE}${subdir_or_file_name} : up-to-date${NC}"
    fi
  fi
done
echo -e "\n${GREEN}Folders to be synced:${NC}"
for src_dir_or_file in "${SRC_DIRS_AND_FILES[@]}"; do
  if [ -d "$src_dir_or_file" ]; then
    subdir_or_file_name=$(basename "$src_dir_or_file")
    is_modified "$src_dir_or_file" "$subdir_or_file_name"
    if [ $? -eq 0 ]; then
      echo -e "\t${GREEN}${subdir_or_file_name}/ : modified${NC}"
    else
      echo -e "\t${WHITE}${subdir_or_file_name}/ : up-to-date${NC}"
    fi
  fi
done

echo -e "\n${WHITE}Accept the sync? (y/n)${NC}"
echo "> "
read -r user_input

if [ "$user_input" != "y" ]; then
  echo -e "\n${RED}Synchronization cancelled.${NC}\n"
  exit 1
fi



# Synchronize each source directory and file
echo -e "\n${BLUE}In Progress:${NC} "
for src_dir_or_file in "${SRC_DIRS_AND_FILES[@]}"; do
  subdir_or_file_name=$(basename "$src_dir_or_file")
  target_path="$TARGET_DIR/$subdir_or_file_name"

  if [ -f "$src_dir_or_file" ]; then
    # File
    is_modified "$src_dir_or_file" "$subdir_or_file_name"
    if [ $? -eq 0 ]; then
      mkdir -p "$(dirname "$target_path")"
      rsync -av --force --delete "$src_dir_or_file" "$target_path" &> /dev/null
      if [ $? -eq 0 ]; then
        if [! -f "$target_path" ]; then
          echo -e "\t${GREEN}${subdir_or_file_name} : created${NC}"
        else
          echo -e "\t${GREEN}${subdir_or_file_name} : synced${NC}"
        fi
      else
        echo -e "\t${RED}${subdir_or_file_name} : NOT synced, error occurred${NC}"
      fi
    else
      echo -e "\t${WHITE}${subdir_or_file_name} : skip${NC}"
    fi
  elif [ -d "$src_dir_or_file" ]; then
    # Directory
    is_modified "$src_dir_or_file" "$subdir_or_file_name"
    if [ $? -eq 0 ]; then
      mkdir -p "$target_path"
      rsync -av --mkdir --force --delete "$src_dir_or_file/" "$target_path/" &> /dev/null
      if [ $? -eq 0 ]; then
        if [! -d "$target_path" ]; then
          echo -e "\t${GREEN}${subdir_or_file_name}/ : created${NC}"
        else
          echo -e "\t${GREEN}${subdir_or_file_name}/ : synced${NC}"
        fi
      else
        echo -e "\t${RED}${subdir_or_file_name}/ : NOT synced, error occurred${NC}"
      fi
    else
      echo -e "\t${WHITE}${subdir_or_file_name}/ : skip${NC}"
    fi
  fi
done

#...

echo -e "\n${WHITE}Script finished. exit...${NC}"
