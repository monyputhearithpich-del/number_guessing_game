#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -q -c"

echo "Enter your username:"
read USERNAME

# Check whether the username already exists
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  # Register a new user
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')"

  echo "Welcome, $USERNAME! It looks like this is your first time here."

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  # Get returning user's statistics
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate a random secret number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Start counting guesses
NUMBER_OF_GUESSES=0

echo "Guess the secret number between 1 and 1000:"

while true
do
  read GUESS

  # Check whether the input is an integer
  if [[ ! $GUESS =~ ^-?[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))

    if (( GUESS < SECRET_NUMBER ))
    then
      echo "It's higher than that, guess again:"
    elif (( GUESS > SECRET_NUMBER ))
    then
      echo "It's lower than that, guess again:"
    else
      break
    fi
  fi
done

# Display the winning message
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

# Save the completed game in PostgreSQL
$PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)"
