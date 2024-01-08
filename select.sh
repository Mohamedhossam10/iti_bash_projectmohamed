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
    select sel in "all" "with condition" "specific column" "exit"; do
      case $sel in
      "all")
        cat "$selected_table"
        break
        ;;
      "with condition")
        declare -a arr=()
        declare -a arrdatatype=()

        while IFS= read -r line; do
          arr+=("$line")
        done < <(awk -F":" '{print $1}' "${selected_table}metadata")

        while IFS= read -r line; do
          arrdatatype+=("$line")
        done < <(awk -F":" '{print $2}' "${selected_table}metadata")

        PS3="Choose column number not the name: "
        typeset -i un
        typeset -i index

        select col in "${arr[@]}"; do
          nu=$REPLY
          index=$nu-1
          num_lines='wc -l <${selected_table}"metadata"'

          # Check if the given number is greater than the number of lines
          if [[ $REPLY > $num_lines ]]; then
            echo "no column with this number. "
            continue
          fi

          echo "You selected based on ${arr[$index]} and its datatype is ${arrdatatype[$index]}. "
          read -p "Please choose the value of ${arr[$index]}: " value
          check_datatype "${arrdatatype[$index]}" "$value"
          check=$?

          if [[ $check =~ "1" ]]; then
            read -p "Please put the condition(=/>/<): " cond
            if [[ $cond =~ "=" ]]; then
              awk -v col="$nu" -v val="$value" -F":" '{if ($col == val) print $0;}' "$selected_table"
            elif [[ $cond =~ ">" ]]; then
              awk -v col="$nu" -v val="$value" -F":" '{if ($col > val) print $0;}' "$selected_table"
            elif [[ $cond =~ "<" ]]; then
              awk -v col="$nu" -v val="$value" -F":" '{if ($col < val) print $0;}' "$selected_table"
            else
              echo "not a condition"
            fi
          else
            echo "Something went wrong with the input."
          fi
            echo "no data that match your input is found."
	    break 2
        done
        ;;
      "specific column")
        arr=()
        for i in $(awk '{print $1}' "$opt"metadata); do
          arr+="$i "

        done
        PS3="choose from the above #: "

        select col in ${arr[@]}; do
          nu=$REPLY
          num_lines=$(wc -l <"${opt}metadata")

          # Check if the given number is greater than the number of lines
          if [[ $REPLY > $num_lines ]]; then
            echo "no column with this number. Pls Try Again."
            break 2
          fi
          awk -v col="$nu" -F":" '{print $col}' $opt
          break 2
        done
        ;;
      "exit")
        break 3
        ;;
      *)
        echo "Invalid selection. Please choose a valid option."
        ;;
      esac
    done
    read -p "Do you want to continue selecting from $selected_table? (y/n): " another_op
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

