#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


RANDOM_NUMBER() {
  number=$(shuf -i 1-1000 -n 1)
  echo $number
  return $number
}


GUESS_GAME() {
  guessNumber=$(RANDOM_NUMBER) 
  echo "Guess the secret number between 1 and 1000:"
  guessCount=1
  read userGuess
  while [[ ! $userGuess -eq $guessNumber ]];
  do 
    if [[ ! $userGuess =~ ^[0-9]+$ ]]; then
      echo "That is not an integer, guess again:"
    elif [[ $userGuess -lt	 $guessNumber ]]; then
      echo "It's higher than that, guess again:"
    else
      echo "It's lower than that, guess again:"
    fi
    read userGuess
    ((guessCount++))
  done

  echo "You guessed it in $guessCount tries. The secret number was $guessNumber. Nice job!"
  
  # increment games played
  INC_GAMES_PLAYED=$($PSQL "update users set games_played = games_played + 1 where username='$1'")
  # if no best game
  if [[ -z $2  ]]
  then
    # enter guessCount
    UPDATE_BEST_GAME=$($PSQL "update users set best_game = $guessCount where username='$1'");
  else
    # if gamesCount < best_game $2 update the count
    if [[ $guessCount -lt $2 ]];
    then
      UPDATE_BEST_GAME=$($PSQL "update users set best_game = $guessCount where username='$1'");
    fi
  fi

}

MAIN() {
  echo $1;
  read username
  # query the db for the username
  username_query=$($PSQL "select * from users where username='$username'")
  # if it does not exists
  if [[ -z $username_query ]]
  then
    # create a new user and print a message.
    create_user=$($PSQL "insert into users(username) values('$username')")
    echo -e "Welcome, $username! It looks like this is your first time here."
  else
    # else show a welcome back message
    echo $username_query | while IFS="|" read user_id username games_played best_game
    do
      echo -e "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
    done
  fi
  GUESS_GAME $username $best_game
}

MAIN "Enter your username:"