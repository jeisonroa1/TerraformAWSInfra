#!/bin/bash 
git clone https://github.com/jeisonroa1/movie-analyst-api.git /home/ubuntu/movie-analyst-api;
apt-get -y update;
apt-get -y upgrade;
apt-get -y install npm; 
npm install --prefix /home/ubuntu/movie-analyst-api/;