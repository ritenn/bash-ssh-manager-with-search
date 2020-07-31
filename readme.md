# Terminal bash script - SSH connections manager with search

This is simple bash script that allows to quickly find and connect server via ssh from terminal. Of course you could use aliases for ssh, but I find this script much more helpful.

**Important!! - it doesn't store passwords.**


![Menu preview](preview.png)

## Features
* Automatically fits terminal size
* Records pagination
* Search 
* You can add some additional label for example "Dev" or "Prod" which could be helpful if you are using only IPs

## Configuration

1. Clone repo and put this script to your home user directory (or change it in script if you want)
```
mkdir ~/.sshlist
cd ~/.sshlist/
```
2. Configure .bashrc and add script alias e.g.
```
alias s='. ~/.sshlist/menu.sh'
```
3. Reload your bashrc
```
. ~/.bashrc
```
4. Add your connections to sshlist.txt file e.g.
```
user@host label
test@127.0.0.1 Dev
```

Done! You can now just type "s" in terminal and ssh manager will pop up.

## Usaage & Keys

* "space" - exit
* "[" - cursor up
* "]" - cursor down
* ">" - next page
* "<" - previous page
* "enter" - connect to selected host
* "backspace" - remove search char
* "~" - reset search
* Any other key is an input for search