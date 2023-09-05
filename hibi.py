
import click
import subprocess
import json
import os
from datetime import datetime, timedelta


USER_HOME = os.path.expanduser("~")
APP_DIR = os.path.join(USER_HOME, ".hibi")
os.makedirs(APP_DIR, exist_ok=True)
HABIT_DATA_FILE = os.path.join(APP_DIR, "habit_data.json")

# Function to load habit data from the JSON file
def load_habit_data():
    try:
        with open(HABIT_DATA_FILE, 'r') as file:
            return json.load(file)
    except FileNotFoundError:
        # Create an empty dictionary if the file doesn't exist
        return {}
    except Exception as e:
        print(f"Error loading JSON file: {e}")
        return {}  # Return an empty habits dictionary in case of error

# Function to save habit data to the JSON file
def save_habit_data(habits):
    try:
        with open(HABIT_DATA_FILE, 'w') as file:
            json.dump(habits, file)
    except Exception as e:
        print(f"Error saving JSON file: {e}")

# Create or load the habit data
habits = load_habit_data()

# Command-line interface using Click
@click.group()
def cli():
    pass

# Function to reset the "Completed today" status for all habits
def reset_completed_today():
    today = datetime.today()
    
    for habit_name, habit_data in habits.items():
        last_completed = habit_data.get('last_completed', None)
        
        if last_completed:
            last_completed_date = datetime.strptime(last_completed, '%Y-%m-%d')
            
            # Calculate the difference in days between today and last_completed_date
            days_difference = (today - last_completed_date).days
            
            if days_difference > 1:
                habit_data['streak'] = 0
                habit_data['completed_today'] = False
            elif days_difference == 1:
                habit_data['completed_today'] = False
    
    save_habit_data(habits)


# List habits and completion status
@cli.command()
def show():
    click.echo('\n')
    logo = subprocess.run(["figlet", "Hibi", "-k", "-f", "big"], capture_output=True, text=True, check=True).stdout
    reset_completed_today()

    habits = load_habit_data()

    if not habits:
        click.echo("No habits found.")
        return

    logo_lines = logo.split('\n')
    max_logo_width = max(len(line) for line in logo_lines)
    logo_padded = '\n'.join(line.ljust(max_logo_width) for line in logo_lines)

    table = "\nHabit Name      Streak     Completed Today"
    table += "\n" + "-" * 45

    for habit_name, habit_data in habits.items():
        streak = habit_data['streak']
        completed_today = "Yes" if habit_data['completed_today'] else "No"

        # Center the streak column with additional padding
        table += f"\n{habit_name.ljust(15)} {str(streak).center(6)} {completed_today.rjust(13)}"

    result_lines = logo_padded.split('\n')
    table_lines = table.split('\n')

    # Ensure logo and table have the same number of lines
    while len(result_lines) < len(table_lines):
        result_lines.append(' ' * max_logo_width)

    while len(table_lines) < len(result_lines):
        table_lines.append(' ' * 40)

    combined_lines = [f"{logo_line}  {table_line}" for logo_line, table_line in zip(result_lines, table_lines)]
    combined_result = '\n'.join(combined_lines)

    click.echo(combined_result)
    click.echo('\n')

# Add a new habit
@cli.command()
@click.argument('habit_name')
def add(habit_name):
    if habit_name in habits:
        click.echo(f'Habit "{habit_name}" already exists!')
    else:
        # Initialize the habit data including last_completed
        habits[habit_name] = {'streak': 0, 'completed_today': False, 'last_completed': None}
        save_habit_data(habits)
        click.echo(f'Added new habit: {habit_name}')


# Complete habit
@cli.command()
@click.argument('habit_name')
def done(habit_name):
    if habit_name in habits:
        if not habits[habit_name]['completed_today']:
            habits[habit_name]['streak'] += 1
            habits[habit_name]['completed_today'] = True
            habits[habit_name]['last_completed'] = datetime.today().strftime('%Y-%m-%d')
            click.echo(f'{habit_name} completed. Streak: {habits[habit_name]["streak"]}')

            save_habit_data(habits)  # Save the updated habits dictionary
        else:
            click.echo(f'{habit_name} already completed today!')
    else:
        click.echo(f'Habit "{habit_name}" not found.')

# Delete habit
@cli.command()
@click.argument('habit_name')
def delete(habit_name):
    if habit_name in habits:
        del habits[habit_name]
        save_habit_data(habits)  # Save the updated habits dictionary
        click.echo(f'Habit "{habit_name}" deleted.')
    else:
        click.echo(f"{habit_name} doesn't exist!")

if __name__ == '__main__':
    cli()

