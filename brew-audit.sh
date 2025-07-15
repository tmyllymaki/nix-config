#!/bin/bash

# ==============================================================================
# Homebrew Cask Audit Script
#
# Description:
#   This script identifies installed Homebrew casks that are not listed in your
#   Brewfile. This is useful for finding orphaned cask directories, often
#   left behind after a cask is renamed (e.g., 'docker' becoming
#   'docker-desktop').
#
# Usage:
#   1. Save this script to a file (e.g., `brew_audit.sh`).
#   2. Make it executable: `chmod +x brew_audit.sh`
#   3. Run it from the same directory as your Brewfile, or provide a path
#      to your Brewfile as an argument: `./brew_audit.sh /path/to/your/Brewfile`
#
# ==============================================================================

# --- Configuration and Setup ---

# Set colors for output to make it more readable
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Determine the location of the Brewfile.
# It defaults to './Brewfile' if no argument is provided.
BREWFILE_PATH=${1:-"./Brewfile"}

echo -e "${GREEN}🔍 Starting Homebrew Cask Audit...${NC}"

# --- Brewfile Validation ---

# Check if the Brewfile exists at the specified path.
if [ ! -f "$BREWFILE_PATH" ]; then
  echo -e "${YELLOW}Error: Brewfile not found at '$BREWFILE_PATH'.${NC}"
  echo "Please run this script in the same directory as your Brewfile, or provide the path as an argument."
  exit 1
fi

echo "✅ Found Brewfile at: $BREWFILE_PATH"

# --- Cask Directory and List Generation ---

# Determine the Homebrew Caskroom path. It's different for Apple Silicon and Intel Macs.
if [[ "$(uname -m)" == "arm64" ]]; then
  CASKROOM_PATH="/opt/homebrew/Caskroom"
else
  CASKROOM_PATH="/usr/local/Caskroom"
fi

echo "✅ Caskroom detected at: $CASKROOM_PATH"

# Get a list of all cask names from the Brewfile.
# This command extracts the second field from lines starting with "cask", removing quotes.
brewfile_casks=$(grep "^cask" "$BREWFILE_PATH" | awk -F' ' '{print $2}' | tr -d '"')

# Get a list of all directories in the Caskroom. These are the "installed" casks.
installed_casks=$(ls "$CASKROOM_PATH")

# --- Audit and Reporting ---

echo -e "\n${GREEN}Comparing installed casks with your Brewfile...${NC}\n"

found_orphans=false

# Loop through each directory in the Caskroom.
for cask in $installed_casks; do
  # Check if the directory name exists in the list of casks from the Brewfile.
  if ! echo "$brewfile_casks" | grep -q "^$cask$"; then
    echo -e "${YELLOW}Orphaned Cask Found:${NC} The directory '$cask' exists in your Caskroom but is not in your Brewfile."
    echo "  - Path: $CASKROOM_PATH/$cask"
    echo "  - This might be an old or renamed cask. You can likely remove it with: ${GREEN}rm -rf $CaskROOM_PATH/$cask${NC}\n"
    found_orphans=true
  fi
done

# --- Final Report ---

if [ "$found_orphans" = false ]; then
  echo -e "${GREEN}✨ Audit complete. No orphaned cask directories found.${NC}"
else
  echo -e "${YELLOW}Audit complete. Review the orphaned casks listed above.${NC}"
fi

