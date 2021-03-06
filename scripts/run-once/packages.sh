#!/bin/bash

# Fail if attempting to use a variable which hasn't been set.
set -u;
# Stop on first error.
set -e;

echo "Installing packages";
echo "Updating package repository";
sudo aptitude update;

echo "Source control";
sudo aptitude install git subversion -y;

echo "PHP and MySQL required for Mediawiki";
sudo aptitude install php5-common php5-cli php5-fpm php5-mysql php5-apcu php5-curl php5-pecl-http -y;
sudo DEBIAN_FRONTEND=noninteractive aptitude install mysql-server mysql-client -y;

echo "Used by R-extension for Mediawiki";
sudo aptitude install r-base r-cran-ggplot2 -y;
sudo Rscript -e 'source("http://bioconductor.org/biocLite.R"); biocLite("Rgraphviz")';

echo "ImageMagick used by both R-extension and Mediawiki";
sudo aptitude install imagemagick -y;

echo "Sendmail required by Mediawiki for email notifications.";
sudo aptitude install sendmail -y;

echo "Tex required by Mediawiki for mathematical formatting.";
sudo aptitude install texlive -y;

echo "Our web server";
sudo aptitude install nginx -y;

echo "NodeJS and MongoDB used by the server-side components of the Process-Model and Map tools.";
sudo aptitude install nodejs npm nodejs-legacy -y;
sudo aptitude install mongodb-server mongodb-clients -y;

echo "Browserify, watchify and catw used to build the process-model and map.";
sudo npm install -g browserify;
sudo npm install -g watchify;
sudo npm install -g catw;
