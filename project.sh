#!/bin/bash

# Database directory
DB_DIR="databases"
db_name=""

# Function to create a new database
create_database() {
  while true; do
    read -p "Enter the name of the new database: " name
	db_name="${name,,}"
    # Check if the database name is valid
    if [[ ! "$db_name" =~ ^[a-zA-Z_]+$ ]]; then
      echo "Invalid database name. Please use only letters and underscores."
    elif [ -d "$DB_DIR/$db_name" ]; then
      echo "Database '$db_name' already exists. Please choose a different name."
    else
      mkdir -p "$DB_DIR/$db_name"
      echo "Database '$db_name' created successfully."
      break
    fi
  done
}

# Function to list existing databases
list_databases() {
  if [[ -n $(ls -A "$DB_DIR" 2>/dev/null) ]]; then
    echo "Existing databases:"
    for db in "$DB_DIR"/*; do
      [ -d "$db" ] && echo "$(basename "$db")"
    done
  else
    echo "No databases are found"
  fi
}


# Function to connect to a database
connect_to_database() {
  while true; do
    PS3="Enter the name of the database to connect to: "
select db_name in `ls ~/$DB_DIR`
do
    # Check if the database name is valid
    if [[ ! "$db_name" =~ ^[a-zA-Z_]+$ ]]; then
      echo "Invalid database name. Please use only letters and underscores."
    elif [ -d "$DB_DIR/$db_name" ]; then
      echo "Connected to database '$db_name'."
      cd ~/$DB_DIR/$db_name
      # Submenu for connected database
	while true; do
      echo "1. Create Table"
      echo "2. List Tables"
      echo "3. Drop Table"
      echo "4. Insert Into Table"
      echo "5. Select From Table"
      echo "6. Delete From Table"
      echo "7. Update Table"
      echo "8. Go Back to Main Menu"

      read -p "you are connected to $db_name database. Enter your Operation #: " choice

      case $choice in
        1) create_table ;;
        2) list_tables ;;
        3) drop_table ;;
        4) insert_into_table ;;
        5) select_from_table ;;
        6) delete_from_table ;;
        7) update_table ;;
        8) break ;;
        *) echo "Invalid choice. Please enter a number between 1 and 8."
      esac

      if [ "$choice" != 8 ]; then
          read -p "Do you want to perform another operation on $db_name database? (y/n): " another_op
          case "$another_op" in
            [Yy]|[Yy][Ee][Ss]) continue ;;
            [Nn]|[Nn][Oo]) break;;
            *) echo "Invalid choice. Please enter 'yes' or 'no'."
          esac
        else
          break  # Skip the "Do you want to perform another operation" prompt for choice 8
        fi
    done
      break


    else
      echo "Error: Database '$db_name' not found."
    fi
done
break
  done
}

# Function to drop a database
drop_database() {
  while true; do
    read -p "Enter the name of the database to drop: " name
	db_name="${name,,}"
    # Check if the database name is valid
    if [[ ! "$db_name" =~ ^[a-zA-Z_]+$ ]]; then
      echo "Invalid database name. Please use only letters and underscores."
    elif [ -d "$DB_DIR/$db_name" ]; then
      # Check if the database directory is empty
      if [ -z "$(ls -A "$DB_DIR/$db_name")" ]; then
        # Directory is empty, remove it
        rm -r "$DB_DIR/$db_name"
        echo "Database '$db_name' dropped successfully."
      else
        # Directory is not empty, ask for confirmation
        read -p "The database '$db_name' is not empty. Do you want to force remove it? (yes/no): " answer
        case "$answer" in
          [Yy]|[Yy][Ee][Ss])
            rm -r "$DB_DIR/$db_name"
            echo "Database '$db_name' dropped successfully."
            ;;
          [Nn]|[Nn][Oo])
            echo "Database '$db_name' was not removed."
            ;;
          *)
            echo "Invalid choice. Please enter 'yes' or 'no'."
            ;;
        esac
      fi
      break
    else
      echo "Error: Database '$db_name' not found."
    fi
  done
}

# Function to ask the user whether to show the main menu again
ask_show_menu() {
cd ~
  while true; do
    read -p "Do you want to show the main menu again? (y/n): " answer
    case "$answer" in
      [Yy]|[Yy][Ee][Ss])
        return 0
        ;;
      [Nn]|[Nn][Oo])
        return 1
        ;;
      *)
        echo "Invalid choice. Please enter 'yes' or 'no'."
        ;;
    esac
  done
}

# Main Menu
list_menu() {
  while true; do
    echo "Main Menu:"
    echo "1. Create Database"
    echo "2. List Databases"
    echo "3. Connect to Database"
    echo "4. Drop Database"
    echo "5. Exit"

    read -p "Enter your choice: " choice

    case "$choice" in
      1)
        create_database
        ;;
      2)
        list_databases
        ;;
      3)
        connect_to_database
        ;;
      4)
        drop_database
        ;;
      5)
        echo "Exiting DBMS. Goodbye!"
        break
        ;;
      *)
        echo "Invalid choice. Please enter a valid option."
        ;;
    esac

    ask_show_menu
    should_show_menu=$?

    if [ "$should_show_menu" -eq 0 ]; then
      continue
    else
      echo "Exiting DBMS. Goodbye!"
      break
    fi
  done
}


# Function to create a table with metadata and data files
create_table() {
  ~/createtable
}


# Function to list tables
list_tables() {
  ~/listtables
}

# Function to drop a table
drop_table() {
    ~/droptable
}

# Function to insert into a table
insert_into_table() {
    ~/insert_in_table
}


# Function to select from a table
select_from_table() {
    ~/select
}

# Function to delete from a table
delete_from_table() {
    ~/delete
}

# Function to update a table
update_table() {
    ~/update
}

# Call the main menu function to start the program
list_menu
