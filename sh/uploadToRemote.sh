#!/usr/bin/expect

set srcFile [lindex $argv 0]
set desFile [lindex $argv 1]
set password [lindex $argv 2]
set timeout -1
spawn scp -r $srcFile $desFile
expect "*password:"
send "$password\r"
expect eof



