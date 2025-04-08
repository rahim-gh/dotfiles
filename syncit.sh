#!/bin/bash

# ---------------------------------------------------------------
# Improved File Synchronization Script
# This script synchronizes files and directories to a target location
# with enhanced error handling and logging
# ---------------------------------------------------------------

# ------ TERMINAL COLOR DEFINITIONS ------
# Define colors for better visual feedback in terminal output
BLUE='\033[0;34m'    # Used for headings and prompts
GREEN='\033[0;32m'   # Used for success messages
RED='\033[0;31m'     # Used for errors and warnings
YELLOW='\033[0;33m'  # Used for warnings
WHITE='\033[0;37m'   # Used for normal text
NC='\033[0m'         # No Color - resets text formatting

# ------ DEFAULT CONFIGURATION ------
# Set default values for script options
VERBOSE=false        # Detailed output mode off by default
AUTO_ACCEPT=false    # Require manual confirmation by default
FILE_LIST=""         # No input file by default
TARGET_DIR="."       # Current directory as default target
LOG_FILE=""          # Log file path (empty = no logging)
ERROR_COUNT=0        # Counter for tracking errors

# ------ UTILITY FUNCTIONS ------

# Function: log_message
# Purpose: Write messages to log file if logging is enabled
# Args: $1 - Message to log
log_message() {
    if [[ -n "$LOG_FILE" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    fi
}

# Function: error_exit
# Purpose: Display error message and exit with failure status
# Args: $1 - Error message
error_exit() {
    echo -e "${RED}ERROR:${NC} $1" >&2
    log_message "ERROR: $1"
    exit 1
}

# Function: check_rsync
# Purpose: Verify rsync is installed before proceeding
check_rsync() {
    if ! command -v rsync &> /dev/null; then
        error_exit "rsync is not installed. Please install it before running this script."
    fi
    
    # Get rsync version for logging/debugging
    if $VERBOSE; then
        RSYNC_VERSION=$(rsync --version | head -n 1)
        echo -e "${BLUE}Using:${NC} $RSYNC_VERSION"
        log_message "Using $RSYNC_VERSION"
    fi
}

# Function: is_modified
# Purpose: Check if source is newer than target, indicating it needs to be synced
# Args: $1 - Source path, $2 - Target path
# Returns: 0 (true) if modified, 1 (false) if not
is_modified() {
    local src_path="$1"
    local target_path="$2"
    
    # Check if source is a file
    if [ -f "$src_path" ]; then
        # Return true if target doesn't exist or source is newer
        [ ! -f "$target_path" ] || [ "$src_path" -nt "$target_path" ]
        return $?
    # Check if source is a directory
    elif [ -d "$src_path" ]; then
        # Return true if target doesn't exist or any file in source is newer
        [ ! -d "$target_path" ] || [ -n "$(find "$src_path" -newer "$target_path" -print -quit)" ]
        return $?
    else
        # Source doesn't exist or is not a regular file/directory
        log_message "WARNING: '$src_path' is not a valid file or directory"
        return 1
    fi
}

# Function: show_help
# Purpose: Display usage information and available options
show_help() {
    echo -e "${BLUE}File Synchronization Script${NC}"
    echo -e "Synchronizes files and directories to a target location"
    echo
    echo -e "Usage: $0 [OPTIONS] <source_dir_or_file> ..."
    echo
    echo -e "${BLUE}Options:${NC}"
    echo "  -h, --help       Display this help message"
    echo "  -V               Verbose mode (show detailed synchronization info)"
    echo "  -y               Auto-accept synchronization (skip confirmation)"
    echo "  -f <file_list>   Read source files/directories from a text file"
    echo "  -d <target_dir>  Specify the target directory (default: current directory)"
    echo "  -l <log_file>    Enable logging to specified file"
    echo
    echo -e "${BLUE}Examples:${NC}"
    echo "  $0 /path/to/source /path/to/target"
    echo "  $0 -f sources.txt -d /path/to/target"
    echo "  $0 ~/Documents ~/Backup -V"
    echo "  $0 -l sync.log -V ~/Documents ~/Backup"
}

# Function: parse_options
# Purpose: Process command-line arguments and set variables accordingly
# Args: All command-line arguments "$@"
parse_options() {
    # Use getopt to handle options with arguments
    while getopts ":Vyhd:f:l:" opt; do
        case $opt in
            V) 
                # Enable verbose mode
                VERBOSE=true
                log_message "Verbose mode enabled"
                ;;
            y) 
                # Auto-accept changes without confirmation
                AUTO_ACCEPT=true
                log_message "Auto-accept mode enabled"
                ;;
            f) 
                # Read sources from file
                FILE_LIST="$OPTARG"
                log_message "Using file list: $FILE_LIST"
                ;;
            d) 
                # Set target directory
                TARGET_DIR="$OPTARG"
                log_message "Target directory set to: $TARGET_DIR"
                ;;
            l) 
                # Enable logging to file
                LOG_FILE="$OPTARG"
                # Create log file or clear existing one
                echo "# Sync Log - Started $(date)" > "$LOG_FILE"
                ;;
            h) 
                # Show help and exit
                show_help
                exit 0
                ;;
            \?) 
                # Invalid option
                error_exit "Invalid option: -$OPTARG. Use -h for help."
                ;;
            :) 
                # Option requires an argument
                error_exit "Option -$OPTARG requires an argument. Use -h for help."
                ;;
        esac
    done
    
    # Remove processed options from args list
    shift $((OPTIND - 1))
    
    # Store remaining arguments
    REMAINING_ARGS=("$@")
}

# Function: read_file_list
# Purpose: Read source paths from a file, handling expansion and validation
# Args: $1 - File containing paths, $2 - Reference to array to fill
read_file_list() {
    local file_list="$1"
    local -n src_dirs_and_files=$2  # Nameref for array to modify
    
    # Check if file exists
    if [ ! -f "$file_list" ]; then
        error_exit "File list '$file_list' does not exist"
    fi
    
    # Initialize line counter for error reporting
    local line_num=0
    
    # Read file line by line
    while IFS= read -r line || [ -n "$line" ]; do
        ((line_num++))
        
        # Skip empty lines or comments
        if [[ -z "${line// }" || "${line:0:1}" == "#" ]]; then
            continue
        fi
        
        # Handle environment variables and path expansion
        # shellcheck disable=SC2088
        expanded_line=$(eval echo "$line" 2>/dev/null)
        
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}Warning:${NC} Failed to expand line $line_num: '$line'"
            log_message "Warning: Failed to expand line $line_num: '$line'"
            continue
        fi
        
        # Check if path exists
        if [ -e "$expanded_line" ]; then
            src_dirs_and_files+=("$expanded_line")
            log_message "Added source path: $expanded_line"
        else
            echo -e "${YELLOW}Warning:${NC} Path on line $line_num doesn't exist: '$expanded_line'"
            log_message "Warning: Path doesn't exist: '$expanded_line'"
        fi
    done < "$file_list"
    
    # If no valid sources found, exit with error
    if [ ${#src_dirs_and_files[@]} -eq 0 ]; then
        error_exit "No valid source paths found in '$file_list'"
    fi
}

# Function: sync_files
# Purpose: Perform synchronization preparation and add to summary
# Args: $1 - Source path, $2 - Target dir, $3 - Verbose flag, $4 - Summary variable
sync_files() {
    local src_path="$1"
    local target_dir="$2"
    local verbose="$3"
    local -n sync_summary=$4  # Nameref for the summary string
    
    # Expand home directory references in path
    src_path=$(echo "$src_path" | sed 's|^~|'"$HOME"'|')
    
    # Get just the filename/dirname from the full path
    local item_name=$(basename "$src_path")
    local target_path="$target_dir/$item_name"
    
    # Check if modification status indicates sync is needed
    if is_modified "$src_path" "$target_path"; then
        # In verbose mode, show what's being checked
        if $verbose; then
            echo -e "\t${GREEN}Modified:${NC} $item_name"
        fi
        
        # Ensure target directory exists
        local target_parent=$(dirname "$target_path")
        if [ ! -d "$target_parent" ]; then
            mkdir -p "$target_parent" || {
                # Handle directory creation errors
                echo -e "\t${RED}Error:${NC} Failed to create directory '$target_parent'"
                sync_summary+="\t${RED}Error:${NC} Failed to create directory for '$item_name'\n"
                log_message "Error: Failed to create directory '$target_parent'"
                ((ERROR_COUNT++))
                return 1
            }
        fi
        
        # In verbose mode, show what would be synced with --dry-run
        if $verbose; then
            echo -e "${BLUE}Dry run for${NC} '$item_name':"
            rsync -av --force --delete --dry-run "$src_path" "$target_path"
            rsync_status=$?
            echo # Add empty line for readability
        else
            # Silently check if rsync would succeed
            rsync -a --force --delete --dry-run "$src_path" "$target_path" &>/dev/null
            rsync_status=$?
        fi
        
        # Prepare summary based on rsync dry-run result
        if [ $rsync_status -eq 0 ]; then
            if [ ! -e "$target_path" ]; then
                sync_summary+="\t${GREEN}Create:${NC} $item_name\n"
                log_message "Will create: $item_name"
            else
                sync_summary+="\t${GREEN}Update:${NC} $item_name\n"
                log_message "Will update: $item_name"
            fi
        else
            sync_summary+="\t${RED}Error preparing:${NC} $item_name\n"
            log_message "Error preparing sync for: $item_name (rsync error $rsync_status)"
            ((ERROR_COUNT++))
        fi
    else
        # Item is already up to date
        if $verbose; then
            echo -e "\t${WHITE}Skip:${NC} $item_name (up to date)"
            log_message "Skip (up to date): $item_name"
        fi
    fi
}

# Function: perform_sync
# Purpose: Actually perform rsync operations after confirmation
# Args: $1 - Source path, $2 - Target dir, $3 - Verbose flag
perform_sync() {
    local src_path="$1"
    local target_dir="$2"
    local verbose="$3"
    
    # Expand home directory references
    src_path=$(echo "$src_path" | sed 's|^~|'"$HOME"'|')
    local item_name=$(basename "$src_path")
    local target_path="$target_dir/$item_name"
    
    # Set rsync options based on source type
    local rsync_opts="-a --force --delete"
    
    # Add verbosity if requested
    if $verbose; then
        rsync_opts+=" -v"
    fi
    
    # Different handling for files vs directories
    if [ -f "$src_path" ]; then
        # For files, sync directly
        if $verbose; then
            echo -e "Synchronizing file: $item_name"
        fi
        rsync $rsync_opts "$src_path" "$target_path"
    elif [ -d "$src_path" ]; then
        # For directories, ensure trailing slash to sync contents
        if $verbose; then
            echo -e "Synchronizing directory: $item_name/"
        fi
        rsync $rsync_opts "$src_path/" "$target_path/"
    else
        # Source no longer exists (rare race condition)
        echo -e "${YELLOW}Warning:${NC} '$src_path' no longer exists, skipping"
        log_message "Warning: Source no longer exists: $src_path"
        return 1
    fi
    
    # Check rsync result
    local rsync_status=$?
    if [ $rsync_status -ne 0 ]; then
        echo -e "${RED}Error:${NC} Failed to sync '$item_name' (rsync error $rsync_status)"
        log_message "Error: Failed to sync '$item_name' (rsync error $rsync_status)"
        ((ERROR_COUNT++))
        return 1
    else
        if $verbose; then
            echo -e "${GREEN}Successfully${NC} synchronized '$item_name'"
        fi
        log_message "Successfully synchronized: $item_name"
        return 0
    fi
}

# ------ MAIN FUNCTION ------
# Function: main
# Purpose: Main program flow
main() {
    # Display script banner if in verbose mode
    if $VERBOSE; then
        echo -e "${BLUE}====================================${NC}"
        echo -e "${BLUE}   File Synchronization Script     ${NC}"
        echo -e "${BLUE}====================================${NC}"
        echo
    fi
    
    # Check for rsync installation
    check_rsync
    
    # Parse command-line options
    parse_options "$@"
    
    # Check if source files/directories are provided
    if [ -z "$FILE_LIST" ] && [ ${#REMAINING_ARGS[@]} -eq 0 ]; then
        error_exit "No source files or directories specified. Use -h for help."
    fi
    
    # Normalize target directory path
    TARGET_DIR=$(echo "$TARGET_DIR" | sed 's|^~|'"$HOME"'|')
    
    # Check if target directory exists and create it if necessary
    if [ ! -d "$TARGET_DIR" ]; then
        echo -e "${YELLOW}Target directory doesn't exist, creating:${NC} $TARGET_DIR"
        mkdir -p "$TARGET_DIR" || error_exit "Failed to create target directory: $TARGET_DIR"
        log_message "Created target directory: $TARGET_DIR"
    fi
    
    # Get list of source files and directories
    SRC_DIRS_AND_FILES=()
    
    # Read from file if specified
    if [ -n "$FILE_LIST" ]; then
        read_file_list "$FILE_LIST" SRC_DIRS_AND_FILES
    fi
    
    # Add command-line arguments to sources
    if [ ${#REMAINING_ARGS[@]} -gt 0 ]; then
        for src in "${REMAINING_ARGS[@]}"; do
            # Expand path
            expanded_src=$(eval echo "$src" 2>/dev/null)
            
            if [ -e "$expanded_src" ]; then
                SRC_DIRS_AND_FILES+=("$expanded_src")
                log_message "Added source path: $expanded_src"
            else
                echo -e "${YELLOW}Warning:${NC} Source path doesn't exist: '$src'"
                log_message "Warning: Source path doesn't exist: '$src'"
            fi
        done
    fi
    
    # Check if we have valid sources
    if [ ${#SRC_DIRS_AND_FILES[@]} -eq 0 ]; then
        error_exit "No valid source files or directories specified."
    fi
    
    # Log the number of sources found
    log_message "Found ${#SRC_DIRS_AND_FILES[@]} valid source paths"
    
    # Prepare synchronization summary
    SYNC_SUMMARY=""
    
    # Process each source for synchronization
    for src in "${SRC_DIRS_AND_FILES[@]}"; do
        sync_files "$src" "$TARGET_DIR" "$VERBOSE" SYNC_SUMMARY
    done
    
    # Display synchronization summary if there's anything to do
    if [ -n "$SYNC_SUMMARY" ]; then
        echo -e "\n${BLUE}Synchronization plan for '${TARGET_DIR}':${NC}"
        echo -e "$SYNC_SUMMARY"
        
        # If errors occurred during preparation
        if [ $ERROR_COUNT -gt 0 ]; then
            echo -e "${YELLOW}Warning:${NC} Encountered $ERROR_COUNT preparation errors"
            log_message "Encountered $ERROR_COUNT preparation errors"
        fi
    else
        echo -e "${GREEN}No files need synchronization${NC} - everything is up to date"
        log_message "No files need synchronization - everything is up to date"
        exit 0
    fi
    
    # Prompt for confirmation unless auto-accept is enabled
    if ! $AUTO_ACCEPT; then
        echo -e "${BLUE}Confirm synchronization? (y/n) ${NC}"
        read -n 1 -r
        echo # Add newline after response
        
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Synchronization cancelled by user${NC}"
            log_message "Synchronization cancelled by user"
            exit 0
        fi
    fi
    
    # Reset error counter for actual sync
    ERROR_COUNT=0
    
    # Perform actual synchronization
    echo -e "${BLUE}Performing synchronization...${NC}"
    log_message "Starting synchronization"
    
    # Track sync operations
    local success_count=0
    local fail_count=0
    
    # Process each source
    for src in "${SRC_DIRS_AND_FILES[@]}"; do
        if perform_sync "$src" "$TARGET_DIR" "$VERBOSE"; then
            ((success_count++))
        else
            ((fail_count++))
        fi
    done
    
    # Report final status
    echo
    echo -e "${BLUE}Synchronization complete:${NC}"
    echo -e "  ${GREEN}Success:${NC} $success_count files/directories"
    
    if [ $fail_count -gt 0 ]; then
        echo -e "  ${RED}Failed:${NC} $fail_count files/directories"
        log_message "Synchronization completed with $success_count successes and $fail_count failures"
        exit 1
    else
        log_message "Synchronization completed successfully"
        echo -e "${GREEN}All synchronization operations completed successfully${NC}"
    fi
}

# ------ SCRIPT ENTRY POINT ------
# Execute main function with all arguments
main "$@"
