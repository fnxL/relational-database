#!/usr/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

PRINT_RESULT() {
  echo -e "The element with atomic number $1 is $2 ($3). It's a $4, with a mass of $5 amu. $2 has a melting point of $6 celsius and a boiling point of $7 celsius."
}

NOT_FOUND() {
  echo "I could not find that element in the database."
  exit
}


if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

if [[ $1 =~ ^[0-9]+$ ]]
then
  # arg is a number
  QUERY_RESULT=$($PSQL "select * from properties inner join elements using(atomic_number) inner join types using(type_id) where atomic_number = $1")
  if [[ -z $QUERY_RESULT ]]
  then
    NOT_FOUND
  fi
  echo $QUERY_RESULT |  while IFS="|" read type_id atomic_number  atomic_mass melting_point boiling_point symbol name type
  do
    PRINT_RESULT $atomic_number $name $symbol $type $atomic_mass $melting_point $boiling_point
  done

else
  # not a number
  QUERY_RESULT=$($PSQL "select * from properties inner join elements using(atomic_number) inner join types using(type_id) where symbol = '$1' OR name = '$1'")
  if [[ -z $QUERY_RESULT ]]
  then
    NOT_FOUND
  fi
  echo $QUERY_RESULT | while IFS="|" read type_id atomic_number  atomic_mass melting_point boiling_point symbol name type
  do
    PRINT_RESULT $atomic_number $name $symbol $type $atomic_mass $melting_point $boiling_point
  done
fi

