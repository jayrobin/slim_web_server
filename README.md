# Slim Web Server

By [James Robinson](http://jayrob.in)

## Description
Slim Web Server is a super-lightweight, basic web server built in Ruby. It can support any static content requested by HTTP GET (i.e. no querystrings and no POST)

## How to use
1. Clone/download the repo
2. Add your web files in the root server directory
3. run the server with 'sudo ruby server.rb' (sudo is required in order to run on port 80)
4. Optional parameters:
 * port: server slisten port, default '80' (e.g. ruby server.rb 8080)
 * root: website root file, default '/index.html' (e.g. ruby server.rb 8080 /welcome.html)
 * error file: website error template file, default '/error.html' (e.g. ruby server.rb 8080 /welcome.html /404.html)