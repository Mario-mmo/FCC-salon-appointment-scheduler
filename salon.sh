#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~ Cheap & Fresh ~~"
echo -e "\n Welcome to the Salon, select your service below =)"

SERVICES() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SALON_SERVICES=$($PSQL "SELECT * FROM services")
  echo -e "\n$SALON_SERVICES" | sed 's/ //g' | sed 's/|/) /'
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SERVICES "Oops! I work only with numbers! Select one service number."
  else
    SERVICE_RESULT=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_RESULT ]] 
    then
      SERVICES "Oops! Something went wrong. Choose again =)"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_ID ]]
      then
        echo -e "\nNice! A new client, what's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      fi
      FORMATED_CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/^ //g')
      SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      FORMATED_SERVICE_TIME=$(echo $SERVICE | sed s'/^ //g')
      echo -e "\nWhat time would you like your $FORMATED_SERVICE_TIME, $FORMATED_CUSTOMER_NAME?"
      read SERVICE_TIME
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$TIME')")
      echo -e "\nI have put you down for a $FORMATED_SERVICE_TIME at $SERVICE_TIME, $FORMATED_CUSTOMER_NAME."
    fi
  fi
}

SERVICES