#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Remove content inside tables (games, teams)
echo $($PSQL "TRUNCATE games, teams;")

# Insert data from <games.csv> to <worldcup> database

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != 'winner' ]]
  then
    # Get team_id to check if winner team exists in database
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    # If not found
    if [[ -z $TEAM_ID ]]
    then
      # Insert winner team into database and print info to bash
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_RESULT == 'INSERT 0 1' ]]
      then
        echo Inserted into teams: $WINNER
      fi
    fi

    # Get team_id to check if opponent team exists in database
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # If not found
    if [[ -z $TEAM_ID ]]
    then
      # Insert opponent team into database and print info to bash
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_RESULT == 'INSERT 0 1' ]]
      then
        echo Inserted into teams: $OPPONENT
      fi
    fi
  fi

done

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # After teams inserted, inserting data into games
  if [[ $YEAR != 'year' ]]
  then
    # Get winner_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # Get opponent_id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # Insert data into games table
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == 'INSERT 0 1' ]]
    then
      echo Inserted into games: Game of $YEAR, $ROUND
    fi
  fi
done