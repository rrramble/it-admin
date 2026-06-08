# Bash / Zsh commands

## Size of all files in a folder

find <FOLDER> -type f -exec stat -f "%z %b" {} + | awk '{net+=$1; blocks+=$2} END {disk=blocks*512; print "Net Size (MB):  " net/1024/1024; print "4K Disk (MB):   " disk/1024/1024}'
