#! /usr/bin/bash
PS3="choose the table you wont to delete: "
select tab in `ls | grep -v "metadata"`
do 
if [[ $(wc -c < $tab) -eq 0 ]]; then
    echo "File is empty."
    rm $tab
    rm "$tab"metadata
    echo "file dropped. "
    break
else
    echo "File is not empty."
    read -p "do you want delete it(y/n):" cho
    if [[ "yes" =~ $cho ]]
    then
    rm $tab
    rm "$tab"metadata
    echo "file dropped. "
    break
    else 
    echo "file still exist in database. "
    break
    fi
fi
done
