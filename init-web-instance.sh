#!/bin/bash 
git clone https://github.com/jeisonroa1/movie-analyst-ui.git /home/ubuntu/movie-analyst-ui;
apt-get -y update;
apt-get -y upgrade;
apt-get -y install npm; 
npm install --prefix /home/ubuntu/movie-analyst-ui/;