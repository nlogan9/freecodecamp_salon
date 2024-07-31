#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~  Postgres Salon ~~~~~"

MAIN_MENU() {
  if [[ $1 ]]
  then
    # print return to main menu message
    echo -e "\n$1"
  fi

  
  SERVICES=$($PSQL "SELECT * FROM services")

  echo -e "\nWhat service would you like?"
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  echo -e "\nWhat kind of appointment would you like?"
  read SERVICE_ID_SELECTED

  # if input isn't a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "This is not a valid service number."
  else
    SERVICE_AVAILABLE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    if [[ -z $SERVICE_AVAILABLE ]]
    then
      MAIN_MENU "That service is not available."
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME

        INSERT_CUSTOMER_NAME=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi

      echo -e "\nWhat time would you like your appointment?"
      read SERVICE_TIME

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")

      SERVICE_FORMATTED=$(echo $SERVICE_AVAILABLE | sed -E 's/^ *| *$//g')
      TIME_FORMATTED=$(echo $SERVICE_TIME | sed -E 's/^ *| *$//g')
      NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')

      echo -e "\nI have put you down for a $SERVICE_FORMATTED at $TIME_FORMATTED, $NAME_FORMATTED."
    fi
  fi

}

MAIN_MENU