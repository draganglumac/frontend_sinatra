#!/bin/bash

ps -ef | grep -v grep | grep ruby

if [ $? -eq 1 ]
then 
rackup &
else
echo "Sinatra is already running"
echo "Killing Sinatra now..."
`sudo killall -9 rackup`
fi
