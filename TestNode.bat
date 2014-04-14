@echo off
haxe -cp src -cp test -js bin/ansi.js -dce full -main Test
node bin/ansi.js