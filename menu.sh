#!/bin/bash

fromCursor=1;
selected=1;
selectedName="";
search="";

DEF='\033[0;44m'
RED='\033[0;41m'
NC='\033[0m' # reset color

FILE=~/.sshlist/sshlist.txt
if [ -f "$FILE" ]; then
    echo -e "${DEF}"
else 
    echo -e "${RED}sshlist.txt file does not exists. Create your ssh connections list first!"
    echo -e "${NC}"
    return 0;
fi

serversListToArray()
{
    IFS=$'\n' read -d '' -r -a connections < $FILE
    maxIndex=${#connections[@]}
}


drawSshMenu()
{
    tput civis
    clear
    serversListToArray
    
    ##Filter search results
    for index in "${!connections[@]}" ; do [[ ${connections[$index]} != *"$search"* ]] && unset -v 'connections[$index]' ; done
    connections=("${connections[@]}")
    
    index="1"
    selected=$1
    perPage=$(tput lines) 
    perPage=$(("$perPage" - 4))
    toCursor=$(("$fromCursor" + "$perPage"))
    currentPage=$((("$fromCursor" / "$perPage") + 1 ))

    if (($selected > $maxIndex))
    then
        selected=$maxIndex
    fi

    if (($selected<1))
    then
        selected=1
    fi
    
    ##Draw table
    echo "| ✔️  | Host & description | SEARCH: $search | PAGE: $currentPage/$((($maxIndex/$perPage)+1))"
    printf %"$COLUMNS"s |tr " " "-"
    
    for connection in "${connections[@]}"
    do
        if (($index >= $fromCursor && $index < $toCursor)) 
        then
            if (($index == $selected))
            then
                selectedName=$(echo $connection | grep -o ".*\s" | tr -d '[:space:]')
                echo -e "${RED}| 🔳 |" $connection
            else
                echo -e "${DEF}| 🔲 |" $connection
            fi
        fi
        ((index=index+1))

    done

    printf "${DEF}"
}

#@param $1 - direction
changePage()
{
    serversListToArray
    tempPerPage=$(tput lines) 
    tempPerPage=$(("$tempPerPage" - 4))
    tempFromCursor=$(($fromCursor $1 $tempPerPage))

    if (($tempFromCursor > 0 && $tempFromCursor < $maxIndex))
    then
        fromCursor="$tempFromCursor"
        selected=$fromCursor
        drawSshMenu $selected
    fi
}

#Init table
drawSshMenu 1

#Main loop
while read -sN1 key # 1 char (not delimiter), silent
do
  keyCode=$( echo "$key" | od | cut -c 9- | grep -o ".*\w")
  keyCode="$keyCode" | cut -c 1-

  case "$keyCode" in
    005133)
        #cursor up [
        tempSelected=$((selected=selected-1))

        if (($tempSelected > 0))
        then
            drawSshMenu "$tempSelected"
        fi
        ;;
    005135)
        #cursor down ]
        tempSelected=$((selected=selected+1))
        tempMaxIndex=$(($fromCursor + $perPage - 1))
        
        if (($tempSelected <= $tempMaxIndex))
        then
            drawSshMenu "$tempSelected"
        fi
        ;;
    005012)
        #connect to selected server enter
        echo -e "${NC}"
        clear
        ssh "$selectedName"
        break
        ;;
    005040)
        #Exit space
        echo -e "${NC}"
        clear
        tput cnorm
        break
        ;;
    005177)
        #Search remove character backspace
        search=$(echo $search | rev | cut -c 2- | rev)
        drawSshMenu $selected
        ;;
    005054)
        #pagination backward <
        changePage -
        ;;
    005056)
        #pagination forward >
        changePage +
        ;;
    005140)
        #reset search ~ 
        search=""
        fromCursor=1
        selected=1
        drawSshMenu $selected
        ;;
    *)
        #Any other key is an input for search
        search="${search}$key"
        drawSshMenu $selected
  esac  
  
done