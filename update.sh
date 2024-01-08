

#!/usr/bin/bash
shopt -s extglob
export LC_COLLATE=C

# Function to check datatype
check_datatype() {
    local datatype="$1"
    local value="$2"

    # Check if the datatype is 'integer'
    if [[ "$datatype" =~ "int" ]]; then
        # Check if the value is an integer
        if [[ "$value" =~ ^[0-9]+$ ]]; then
            return 1
        else
            return 0
        fi
    # Check if the datatype is 'string'
    elif [[ "$datatype" =~ "string" ]]; then
        # Check if the value is a string
        if [[ "$value" =~ ^[a-zA-Z]+$ ]]; then
            return 1
        else
            return 0
        fi
    else
        return 0
    fi
}

# Variable to store the selected table
selected_table=""

PS3="Choose the table : "
select opt in $(ls | grep -v "metadata"); do
    # Store the selected table in the variable
    selected_table="$opt"

    while true; do
        PS3="Choose the method: "
        select choose in "update all the column" "update based on condition" "update based on id number" "exit"; do
            case $choose in
                "update all the column")

		declare -a arr=()
		declare -a arrdatatype=()

		while IFS= read -r line; do
		arr+=("$line")
		done < <(awk -F":" '{print $1}' "${selected_table}metadata")

		while IFS= read -r line; do
		arrdatatype+=("$line")
		done < <(awk -F":" '{print $2}' "${selected_table}metadata")
	

                    typeset -i un
                    typeset -i index
                    filename=$selected_table"metadata"

                    PS3="please choose the column: "
                    select col in "${arr[@]}"; do
                        nu=$REPLY
                        index=$nu-1
                        num_lines=$(wc -l < "${selected_table}metadata")

                        # Check if the given number is greater than the number of lines
                        if [[ $REPLY > $num_lines ]]; then
                            echo "no column with this number. "
                            break
                        fi

                        pk=$(sed -n "${nu}p" "$filename" | cut -f3 -d":")
                        check=""
                        if [[ $pk =~ "pk" ]]; then
                            check="pk"
                        else
                            check="not a pk"
                        fi

                        echo "you update based on ${arr[$index]} and it is datatype is ${arrdatatype[$index]} and it is $check. "

                        read -p "please enter the new value: " newvalue
                        check_datatype "${arrdatatype[$index]}" "$newvalue"
                        check2=$?

                        if [[ $check2 =~ "1" ]]; then
                            if [[ $check == "pk" ]]; then
                                echo "you cannot update the pk column with the same value"
                            else
                                # Define the new value you want to set for all rows in the 3rd column
                                new_value="$newvalue"

                                # Use awk to update the 3rd column with the new value for all rows in the same file
                                awk -v new_value="$new_value" -v col="$nu" 'BEGIN { FS = ":"; OFS = ":" } { $col = new_value; print }' "$selected_table" > tempfle
                                cat tempfle > "$selected_table"
                                rm tempfle
                                echo "data updated"
                            fi
                        fi
                        break 2
                    done
                    ;;
                "update based on condition")
                    # Your code for updating based on condition
			declare -a arr=()
			declare -a arrdatatype=()
			while IFS= read -r line;
			 do
			    arr+=("$line")
			done < <(awk -F":" '{print $1}' "${selected_table}metadata")
			while IFS= read -r line; 
			do
			    arrdatatype+=("$line")
			done < <(awk -F":" '{print $2}' "${selected_table}metadata")
			
			typeset -i un
			typeset -i index
			filename=$selected_table"metadata"
			PS3="please choose the column: "
			select col in ${arr[@]}
			do
			nu=$REPLY
			index=$nu-1
			num_lines=$(wc -l < "${selected_table}metadata")

			# Check if the given number is greater than the number of lines
			if [[ $REPLY > $num_lines ]]; then
			    echo "no column with this number. "
			    break
			fi

			pk=`sed -n "${nu}p" "$filename" | cut -f3 -d":"`
			check=""
			if [[ $pk =~ "pk" ]]
			then
			check="pk"
			else 
			check="not a pk"
			fi

			echo "you update based on ${arr[$index]} and it is datatype is ${arrdatatype[$index]} and it is $check. "

			read -p "please enter the old value: " oldvalue

			check_datatype "${arrdatatype[$index]}" "$oldvalue"

			check1=$?

			read -p "please enter the new value: " newvalue

			check_datatype "${arrdatatype[$index]}" "$newvalue"

			check2=$?

			if cut -d':' -f"$REPLY" "$selected_table" | grep -q "\<${oldvalue}\>"; then
			    echo "the old value exists in the table."
			else
			    echo "the old value doesnot exist in the table."
			    break 2
			fi
			if [[ $check1 =~ "1" && $check2 =~ "1" ]]
			then
			if [[ $check == "pk" ]]
			then
			if cut -d':' -f"$REPLY" "$selected_table" | grep -q "\<${newvalue}\>"; then
			    echo "the new value exists in the table."
			    echo "try again"
			    break 2
			else
			touch temp
			 awk -F':' -v old="$oldvalue" -v new="$newvalue" -v num="$REPLY" 'BEGIN {OFS=":"} { if ($num == old) $num = new; print }' $selected_table > temp 
			cat temp > $selected_table
			rm temp
			    echo "$oldvalue is replaced successfully with $newvalue"
			fi
			else
			if [[ "${arrdatatype[$index]}" =~ "string" ]]
			then
			touch temp
			 awk -F':' -v old="$oldvalue" -v new="$newvalue" -v num="$REPLY" 'BEGIN {OFS=":"} { if ($num == old) $num = new; print }' $selected_table > temp 
			cat temp > $selected_table
			rm temp
			    echo "$oldvalue is replaced successfully with $newvalue"
			else 
			read -p "choose the option (</>/=): " c
			if [[ $c == "=" ]]
			then
			touch temp
			awk -F':' -v old="$oldvalue" -v new="$newvalue" -v num="$REPLY" 'BEGIN {OFS=":"} { if ($num == old) $num = new; print }' $selected_table > temp 
			cat temp > $selected_table
			rm temp
			elif [[ $c == ">" ]]
			then
			touch temp
			awk -F':' -v old="$oldvalue" -v new="$newvalue" -v num="$REPLY" 'BEGIN {OFS=":"} { if ($num > old) $num = new; print }' $selected_table > temp
			cat temp > $selected_table
			rm temp
			elif [[ $c == "<" ]]
			then
			 touch temp
			awk -F':' -v old="$oldvalue" -v new="$newvalue" -v num="$REPLY" 'BEGIN {OFS=":"} { if ($num < old) $num = new; print }' $selected_table > temp
			cat temp > $selected_table
			rm temp
			fi
			fi
			fi
			fi
			break 2
			done
;;
                "update based on id number")
                    # Your code for updating based on id number
			declare -a arr=()
			declare -a arrdatatype=()
			while IFS= read -r line;
			 do
			    arr+=("$line")
			done < <(awk -F":" '{print $1}' "${selected_table}metadata")
			while IFS= read -r line; 
			do
			    arrdatatype+=("$line")
			done < <(awk -F":" '{print $2}' "${selected_table}metadata")
			filename=$selected_table"metadata"
			PS3="please choose the column you need to update: "
			typeset -i field
			typeset -i n
			select col in ${arr[@]:1}
			do
			nu=$REPLY
			index=$nu
			field=$REPLY+1
			num_lines=$(wc -l < "${selected_table}metadata")
			n=$num_lines-1
			# Check if the given number is greater than the number of lines
			if [[ $REPLY > $n ]]; then
			    echo "no column with this number. "
			    break
			fi
			echo "you need to update ${arr[$index]} and it is datatype is ${arrdatatype[$index]}. "
			read -p "please enter the id : " idd
			read -p "please enter the new value: " neww
			if cut -d':' -f1 "$selected_table" | grep -q "$idd"; then
			    echo "this id exists in the table."
			else
			    echo "this id doesnot exist in the table."
			    break
			fi
			check_datatype "${arrdatatype[$index]}" "$neww"
			check=$?
			if [[ $check =~ "1" ]]
			then
			touch temp
			awk -F':' -v ip="$idd" -v new="$neww" -v num="$field" 'BEGIN {OFS=":"} { if ($1 == ip) $num = new; print }' $selected_table > temp 
			cat temp > $selected_table
			rm temp
			echo "updated"
			fi
			break 2
			done
                    ;;
                "exit")
                    echo "Goodbye"
                    break 3
                    ;;
                *)
                    echo "Invalid selection. Please choose a valid option."
                    ;;
            esac
        done
 read -p "Do you want to continue updating in $selected_table? (y/n): " another_op
    case "$another_op" in
    [Yy] | [Yy][Ee][Ss])
      continue
      ;;
    [Nn] | [Nn][Oo])
      selected_table=""
      break 2
      ;;
    *)
      echo "Invalid choice. Please enter 'yes' or 'no'."
      ;;
    esac
    done
done

