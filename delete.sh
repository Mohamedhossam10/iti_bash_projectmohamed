#! /usr/bin/bash
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

PS3="choose the table : "
select opt in `ls | grep -v "metadata"`
do
	if [[ $(wc -c < $opt) -eq 0 ]]; then
	    echo "File is empty."
	    break
	fi
	select choose in "delete all data" "delete based on condition" "exit"
	do
		if [[ "delete all data" =~ $choose ]]
		then
			if [[ $(wc -c < $opt) -eq 0 ]]; then
			    echo "File is empty."
			    break
			else
			    echo "file have data. "
			    read -p "do you want to delete it(y/n): " cho
				    if [[ "yes" =~ $cho ]]
				    then
					    sed -i '1,$d' $opt
					    echo "all value was deleted."
					    break
					    else 
					    echo "data still exist. "
					    break
				    fi
			fi
		elif [[ "delete based on condition" =~ $choose ]]
		then
			declare -a arr
			declare -a arrdatatype
			while IFS= read -r line;
			 do
			    arr+=("$line")
			done < <(awk -F":" '{print $1}' "${opt}metadata")
			#######################################################
			while IFS= read -r line; 
			do
			    arrdatatype+=("$line")
			done < <(awk -F":" '{print $2}' "${opt}metadata")
			#######################################################

			PS3="choose number from selection above: "
			typeset -i un
			typeset -i index
			select col in ${arr[@]}
			do
				nu=$REPLY
				index=$nu-1
				num_lines=$(wc -l < "${opt}metadata")
				# Check if the given number is greater than the number of lines
				if [[ $REPLY > $num_lines ]]; then
				    echo "no column with this number. "
				    break
				fi
				#######################################################
				echo "you select based on ${arr[$index]} and it is datatype is ${arrdatatype[$index]}. "
				read -p "please choose the value of ${arr[$index]}to delete based on it: " value
				check_datatype "${arrdatatype[$index]}" "$value"
				check=$?
				if cut -d':' -f"$REPLY" "$opt" | grep -q "$value"; then
					if [[ $check =~ "1" ]]
					then
						read -p "please put the condition(=/>/<): " cond
						if [[ $cond =~ "=" ]]
						then
						touch temp
						cat $opt > temp
						awk -v col="$nu" -v val="$value" -F":" '{if ($col != val) print $0 ;}' temp > $opt
						echo "lines deleted. "
						rm temp
						break
					elif [[ $cond =~ ">" ]]
					then
						touch temp
						cat $opt > temp
						awk -v col="$nu" -v val="$value" -F":" '{if ($col < val) print $0;}' temp > $opt
						echo "lines deleted. "
						rm temp
						break
					elif [[ $cond =~ "<" ]]
					then
						touch temp
						cat $opt > temp
						awk -v col="$nu" -v val="$value" -F":" '{if ($col > val) print $0;}' temp > $opt
						echo "lines deleted."
						rm temp
						break
					else
						echo "no condition. "
						break
					fi
				else
					echo "there is a wrong something."
					break
				fi
				else
				echo "no data is found with the entered value."
				fi
			done
		elif [[ "exit" =~ $choose ]]
		then
			echo "good bye. "
			break
		fi
	break
	done

break
done
