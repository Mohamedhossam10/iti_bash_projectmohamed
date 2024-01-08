#! /usr/bin/bash
shopt -s extglob
export LC_COLLATE=C
values=()

last_selected_table=""

while true; do
    if [[ -z "$last_selected_table" ]]; then
        # Ask the user to choose a table if last_selected_table is not set
        PS3="Choose the table to insert into: "
        select opt in $(ls | grep -v "metadata")
        do
            if [[ -n "$opt" ]]; then
                last_selected_table="$opt"
                break
            else
                echo "Invalid selection. Please try again."
            fi
        done
    fi

    cat "$last_selected_table"metadata
    i=1
    y=`wc -l < $last_selected_table"metadata"`
    filename=$last_selected_table"metadata"
    echo "Number of columns in the table is $y."
while [[ $i -le $y ]]
        do
            colname=$(sed -n "${i}p" "$filename" | cut -f1 -d":")
            coltype=$(sed -n "${i}p" "$filename" | cut -f2 -d":")
            pk=$(sed -n "${i}p" "$filename" | cut -f3 -d":")
            check=""

            if [[ $pk =~ "pk" ]]; then
                check="pk"
            else
                check="not a pk"
            fi

            echo "Column name is $colname, type is $coltype, and it is $check."
            read -p "Enter $colname (data type: $coltype, $check): " value
	    val="${value,,}"
            if [[ $check == "pk" ]]; then
                if [[ $val =~ ^-?[0-9]+$ ]]; then
                    if cut -d':' -f$i "$opt" | grep -q "\<${val}\>"; then
                        echo "This value exists before and it must be Uniqe. Please Try again."
                        continue
                    else
                        values+=("$val")
                    fi
                else
                    echo "Invalid input for a primary key. It must be an integer."
                    continue
                fi
            else
                if [[ $coltype =~ "int" ]]; then
                    if [[ $val =~ ^-?[0-9]+$ ]]; then
                        values+=("$val") 
                    else
                        echo "Invalid input for an integer type."
                        values=()
                        i=1
                        continue
                    fi
                elif [[ $coltype =~ "string" ]]; then
                    if [[ "$val" =~ ^[a-zA-Z]+$ ]]; then
                        values+=("$val")
                    else
                        echo "Invalid input for a string type."
                        values=()
                        i=1
                        continue
                    fi
                else
                    echo "Unknown type."
                    continue
                fi
            fi

            ((i++))
        done

        echo "Inserted values: ${values[@]}"
        delimiter=":"

        if [[ -n "${values[@]}" ]]; then
            joined=$(IFS="$delimiter"; echo "${values[*]}")
            echo "$joined" >> "$opt"
            values=()
        fi

        read -p "Do you want to continue inserting into $last_selected_table? (y/n): " another_op
    case "$another_op" in
        [Yy]|[Yy][Ee][Ss]) continue ;;
        [Nn]|[Nn][Oo]) last_selected_table=""; break ;;
        *) echo "Invalid choice. Please enter 'yes' or 'no'."
    esac
done

        

