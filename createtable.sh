#! /usr/bin/bash
check_value_in_file() {
    local value_to_check="$1"
    local filename="$2"

    if grep -q "$value_to_check" "$filename"; then
        echo "'$value_to_check' exists in the file."
        return 0  # Return 0 to indicate success
    else
        echo "'$value_to_check' does not exist in the file."
        return 1  # Return 1 to indicate failure
    fi
}
validate_name() {
    local tn="$1"

    case $tn in 
        *[0-9]*)
          return 0
            ;;
        *\ *)
            return 0
            ;;
        *['!'@#,\$%^\&*_+]*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
read -p "enter the table name : " tname 
tn="${tname,,}"
case $tn in 
*[0-9]*)
echo "the name cannot have number. "
;;
*\ * )
echo "the name cannot have space. "
;;
*['!'@#,\$%^\&*_+]* )
echo "the name cannot have spacial chars. "
;;
*)
if [ -f "$tname" ]; then
    echo "table '$tname' exists."
else
touch $tn
read -p "enter the number of column: " colnum
i=1
touch "$tn"metadata
filemeta="$tn"metadata
while [[ $i -le $colnum ]];
do
read -p "enter the name of column #$i: " name
validate_name "$name"
col=$?
check_value_in_file "$name" "$filemeta"
exist=$?
if [[ "$col" =~ "1" && "$exist" =~ "1" ]]
then
if [[ $i -eq 1 ]]
then
read -p "you need the column be a pk (y/n):" pk
if [[ "yes" =~ $pk ]]
then 
pk="pk"
else 
pk="not a pk"
fi
fi
read -p "enter the data type of column(int/string): " dtype
if [[ $i == 1 ]]
then
echo "$name : $dtype : $pk" >> "$tn"metadata
else
echo "$name : $dtype" >> "$tn"metadata
fi
((i++))
else 
echo "the name not valid or exist in the table"
fi
done
fi
esac

