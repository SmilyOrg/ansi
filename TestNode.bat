@echo off
haxe -cp src -cp test -js bin/ansi.js -lib hxnodejs -dce full -main Test
node bin/ansi.js
