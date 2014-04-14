@echo off
haxe -cp src -cp test -php bin/php/ -dce full -main Test
php bin/php/index.php