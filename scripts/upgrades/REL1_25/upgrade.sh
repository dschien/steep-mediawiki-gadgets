#!/bin/bash

# Fail if attempting to use a variable which hasn't been set.
set -u;
# Stop on first error.
set -e;

# We now distribute a skin with this repository.
# Symlink it into the skins directory.
ln -s -T "${STEEP_DIR}/steep-skin" "${NEW_DIR}/skins/Steep";

source "steep-settings-symlink.sh";

# Migrate from MongoDB to ElasticSearch.
source "search.sh";

source "steep-icons-extension.sh";
source "category-tables-extension.sh";
source "steep-tags-extension.sh";
source "project-structure-extension.sh";
