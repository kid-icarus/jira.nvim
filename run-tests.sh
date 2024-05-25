#!/bin/sh
BUSTED_VERSION="2.1.2-3"

# Install busted if it is not already installed, sometimes you have to run this multiple times
# because busted is trying to use a 5.4 version of lua
if [ ! -d "lua_modules" ]; then
  luarocks init
  luarocks install busted "$BUSTED_VERSION"
  luarocks config --scope project lua_version 5.1
fi
nvim -u NONE \
  -c "lua package.path='lua_modules/share/lua/5.1/?.lua;lua_modules/share/lua/5.1/?/init.lua;'..package.path;package.cpath='lua_modules/lib/lua/5.1/?.so;'..package.cpath;local k,l,_=pcall(require,'luarocks.loader') _=k and l.add_context('busted','$BUSTED_VERSION')" \
  -l "lua_modules/lib/luarocks/rocks-5.1/busted/$BUSTED_VERSION/bin/busted"
