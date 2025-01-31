#!/bin/bash

# File to store fitness goals
GOAL_FILE="fitness_goals.txt"

# Function to set a new fitness goal
set_fitness_goal() {
  goal_type=$(dialog --inputbox "Goal Type (e.g., Weight Loss, Muscle Gain, Specific Achievement):" 8 40 --stdout)
  goal_description=$(dialog --inputbox "Goal Description:" 8 40 --stdout)
  target_value=$(dialog --inputbox "Target Value:" 8 40 --stdout)

  # Check if file exists and if not, add header
  if [ ! -e "$GOAL_FILE" ]; then
    echo -e "Goal Type\tGoal Description\tTarget Value\tProgress" > "$GOAL_FILE"
  fi

  echo -e "$goal_type\t$goal_description\t$target_value\t0" >> "$GOAL_FILE"
  dialog --msgbox "Fitness goal set successfully." 8 40
}

# Function to view all fitness goals
view_fitness_goals() {
  if [ -s "$GOAL_FILE" ]; then
    # Use column command to format the table with appropriate headers
    (printf "Goal Type\tGoal Description\tTarget Value\tProgress\n" && cat "$GOAL_FILE") | column -t -s $'\t' > temp.txt
    dialog --title "Fitness Goals" --textbox temp.txt 20 80
    rm temp.txt
  else
    dialog --title "Fitness Goals" --msgbox "No fitness goals found." 8 40
  fi
}

# Function to update progress towards a fitness goal
update_fitness_progress() {
  goals=$(awk -F'\t' '{print $2}' "$GOAL_FILE")
  IFS=$'\n' read -r -d '' -a goals_array <<< "$goals"

  goal_number=$(dialog --menu "Select Goal to Update Progress" 20 80 10 "${goals_array[@]}" --stdout)

  current_progress=$(awk -F'\t' -v goal_number="$goal_number" 'NR==goal_number+1 {print $4}' "$GOAL_FILE")

  new_progress=$(dialog --inputbox "Enter current progress (numeric value):" 8 40 --stdout)
  sed -i "${goal_number}s/$current_progress/$new_progress/" "$GOAL_FILE"
  dialog --msgbox "Progress updated successfully." 8 40
}

# Main function
main() {
  while true; do
    choice=$(dialog --menu "Fitness Goal Tracker Menu" 15 40 4 \
            1 "Set Fitness Goal" \
            2 "View Fitness Goals" \
            3 "Update Fitness Progress" \
            4 "Exit" --stdout)

    case $choice in
      1)
        set_fitness_goal
        ;;
      2)
        view_fitness_goals
        ;;
      3)
        update_fitness_progress
        ;;
      4)
        dialog --msgbox "Exiting Fitness Goal Tracker. Goodbye!" 8 40
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
