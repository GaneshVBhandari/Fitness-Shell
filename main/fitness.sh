#!/bin/bash

# Log file for user activities
LOG_FILE="fitness_log.txt"

# Data file for fitness-related data
DATA_FILE="fitness_data.txt"

# Function to log user activities
log_activity() {
  echo "$(date "+%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
}

# Function to add fitness data
add_fitness_data() {
  exercise_name=$(dialog --inputbox "Enter exercise name:" 8 40 --stdout)
  sets=$(dialog --inputbox "Enter sets:" 8 40 --stdout)
  reps=$(dialog --inputbox "Enter reps:" 8 40 --stdout)
  weight=$(dialog --inputbox "Enter weight (lbs):" 8 40 --stdout)

  # Check if file exists and if not, add header
  if [ ! -e "$DATA_FILE" ]; then
    echo -e "Date\tExercise Name\tSets\tReps\tWeight (lbs)" > "$DATA_FILE"
  fi

  # Add data under respective columns
  printf "%s\t%s\t%s\t%s\t%s\n" "$(date "+%Y-%m-%d %H:%M:%S")" "$exercise_name" "$sets" "$reps" "$weight" >> "$DATA_FILE"
  dialog --msgbox "Fitness data added successfully." 8 40
}

# Function to view fitness data
view_fitness_data() {
  if [ -s "$DATA_FILE" ]; then
    # Use column command to format the table
    column -t -s $'\t' "$DATA_FILE" > temp.txt
    dialog --title "Fitness Data" --textbox temp.txt 20 80
    rm temp.txt
  else
    dialog --title "Fitness Data" --msgbox "No fitness data found." 8 40
  fi
}

# Function to remove an exercise from the list
remove_exercise() {
  if [ -s "$DATA_FILE" ]; then
    dialog --title "Select Exercise to Remove" --textbox "$DATA_FILE" 20 80
    exercise_to_remove=$(dialog --inputbox "Enter exercise name to remove:" 8 40 --stdout)

    if [ -z "$exercise_to_remove" ]; then
      dialog --msgbox "No exercise name entered for removal." 8 40
      return
    fi

    sed -i "/$exercise_to_remove/d" "$DATA_FILE"
    dialog --msgbox "Exercise '$exercise_to_remove' removed successfully." 8 40
  else
    dialog --msgbox "No fitness data found to remove." 8 40
  fi
}

# Main function
main() {
  log_activity "Script Started"

  while true; do
    choice=$(dialog --menu "Fitness Tracking Menu" 15 40 4 \
            1 "Log Fitness Data" \
            2 "View Fitness Data" \
            3 "Remove Exercise" \
            4 "Exit" --stdout)

    case $choice in
      1)
        add_fitness_data
        log_activity "Fitness Data Added"
        ;;
      2)
        view_fitness_data
        log_activity "Viewed Fitness Data"
        ;;
      3)
        remove_exercise
        log_activity "Removed Exercise"
        ;;
      4)
        log_activity "Script Exited"
        dialog --msgbox "Exiting Fitness Tracker. Goodbye!" 8 40
        exit 0
        ;;
      *)
        dialog --msgbox "Invalid choice. Please enter a valid option." 8 40
        ;;
    esac
  done
}

# Execute the main function
main
