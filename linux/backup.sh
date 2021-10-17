#!/bin/bash
help() {
    echo "
Usage: backup [options]

CISO CCDC Backup System

Options:
  -r, --restore            restore archived directory
  -a, --archive            create an archive
  -d, --database           backup a database
  -f, --filesystem         backup a filesystem 
  -w, --webserver          backup a webserver
  -h, --help               display help for command
Examples:
   backup -f [SRC_PATH] [DEST_PATH]
   backup -a [SRC_PATH] [DEST_PATH]
"
}

restore_file_system() {
    rm -rf $2
    tar -xvpzf $1 $2
    echo done
}

filesystem() {
  if [ "$1" == "-a"]; then
    tar -cvpzf $2 $3
  elif [ "$1" == "-r" ]; then
    rm -rf $3
    tar -xvpzf $2 $3
    echo done
  else 
    echo "INVALID TYPE"
  fi
}

database() {
  if [ "$1" == "-a"]; then
    mysqldump -u [username] –p [password] [database_name] > [dump_file.sql]
  elif [ "$1" == "-r" ]; then
    mysql -u [username] –p [password] [database_name] < [dump_file.sql]
  else 
    echo "INVALID TYPE"
  fi
}

while [ -n "$1" ]
do
    case "$1" in
        -d) database $1 $2 $3;;
        -f) filesystem $1 $2 $3;;
        -h) help ;;
    esac
    shift
done
