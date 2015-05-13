#!/bin/bash

# Fail if attempting to use a variable which hasn't been set.
set -u;
# Stop on first error.
set -e;

# Assumes a Debian (Jessie) system with 'sudo' installed.

# This script installs Mediawiki in two possible scenarios:
# 1. You have an existing version installed and symlinked to /var/www/mediawiki, in which case we will do an upgrade.
# 2. You have no existing version, and will need to set some environment variables when you run this script.

# This script does not handle the case when you want to restore from backed up files, although it could do in the future.

TARGET_DIR="/var/www";

REL="REL1_25";
SEMANTIC_REL="2.1.3";
MEDIAWIKI_DIR="${TARGET_DIR}/mediawiki";
NEW_DIR="${MEDIAWIKI_DIR}_${REL}";
EXT_DIR="${NEW_DIR}/extensions";
EXTRA_CONFIG_FILE="server-specific-variables.php";
EXTRA_CONFIG="${NEW_DIR}/${EXTRA_CONFIG_FILE}";

PROCESS_MODEL_DIR="${TARGET_DIR}/process-model";
MAP_DIR="${TARGET_DIR}/energy-efficiency-planner";
SHARE_DIR="/opt/shareserver";
SHARE_SERVICE="shareserver.service";

PROCESS_MODEL_VERSION="v0.5.0";
MAP_VERSION="v0.5.0";
SHARE_VERSION="v0.5.0";

if [ -d $MEDIAWIKI_DIR ]; then
    echo "Upgrading existing install";
    
else
    echo "Creating install from scratch";
    # For a fresh install, these variables must have been set:
    test -n $MYSQL_ROOT_PASS;

    test -n $MYSQL_MEDIAWIKI_PASS;

    # The DNS name of this server.
    test -n $WG_SERVER;
    if [[ $WG_SERVER  != "http"* ]]; then
	echo "WG_SERVER variable must begin with http" 1>&2; exit 1;
    fi;

    # The username and password of an admin user.
    test -n $MEDIAWIKI_ADMIN;
    test -n $MEDIAWIKI_ADMIN_PASS;
    
    # An email address which account request notifications will be sent to.
    test -n $ACCOUNT_CONTACT;

    # Run pre-requisites for first install
    source "run-once/run-once.sh";
fi;

echo "Preparing the new version.";
source "mediawiki-version.sh";

if [ -d $MEDIAWIKI_DIR ]; then

    echo "Migrating existing files.";
    
    OLD_DIR=(readlink $MEDIAWIKI_DIR);
    OLD_EXTRA_CONFIG="${OLD_DIR}/${EXTRA_CONFIG_FILE}";    
    
    # Take down the wiki temporarily.
    rm ${MEDIAWIKI_DIR};

    # Migrate files from the old version
    cp "${OLD_DIR}/LocalSettings.php" "${NEW_DIR}";

    if [ -e $OLD_EXTRA_CONFIG ]; then
	cp "${OLD_EXTRA_CONFIG}" "${NEW_EXTRA_CONFIG}";
    fi;

    cp "${OLD_DIR}/images" "${NEW_DIR}" -R;

    source "upgrade-steep-server-components.sh";

    echo "Running Mediawiki's update script (sorts out the database tables).";
    sudo php "${NEW_DIR}/maintenance/update.php";    

else
    echo "Providing default settings, adding in our server-specific configuration.";
    cp "LocalSettings.php.default" "${NEW_DIR}/LocalSettings.php";

    EXTRA_CONFIG="${NEW_DIR}/${EXTRA_CONFIG_FILE}";
    
    echo "<?php" > $EXTRA_CONFIG;
    echo "\$wgDBpassword=\"${MYSQL_MEDIAWIKI_PASS}\";" >> $EXTRA_CONFIG;
    echo "\$wgConfirmAccountContact=\"${ACCOUNT_CONTACT}\";" >> $EXTRA_CONFIG;
    echo "\$wgServer=\"${WG_SERVER}\"" >> $EXTRA_CONFIG;
    echo "?>" >> $EXTRA_CONFIG;

    echo "Running Mediawiki's install script.";
    sudo php 

    sudo php "${NEW_DIR}/maintenance/install.php" --confpath /tmp SteepWiki "${MEDIAWIKI_ADMIN}" --pass "${MEDIAWIKI_ADMIN_PASS}";    
fi;

echo "Refreshing Semantic Data";
sudo php "${EXT_DIR}/SemanticMediaWiki/maintenance/rebuildData.php";

echo "Upgrading the other Steep server-side components.";
source "update-steep-server-components.sh";

echo "Pointing the symlink at the newly installed version of mediawiki.";
ln -s ${NEW_DIR} ${MEDIAWIKI_DIR} --no-target-directory;
