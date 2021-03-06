#!/bin/bash

# Fail if attempting to use a variable which hasn't been set.
set -u;
# Stop on first error.
set -e;

NGINX_CONFIG="/etc/nginx";
SITES_AVAILABLE="${NGINX_CONFIG}/sites-available";
SITES_ENABLED="${NGINX_CONFIG}/sites-enabled";
STEEP_CONFIG="${SITES_AVAILABLE}/steep-nginx";

echo "Disable the default web site."
sudo rm -f "${SITES_ENABLED}/default";

echo "Enable the steep website.";
sudo cp "run-once/steep-nginx" "${STEEP_CONFIG}";
sudo ln -s -f "${STEEP_CONFIG}" "${SITES_ENABLED}/steep-nginx" --no-target-directory;

sudo systemctl restart nginx;
