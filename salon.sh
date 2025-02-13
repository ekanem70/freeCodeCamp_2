#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]
  then 
      echo $1
  fi

  echo -e "\n~~~ Please choose a service ~~~\n"

  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while IFS="|" read -r ID NAME
  do
      echo -e "$( echo $ID | sed 's/\s*/)/g; s/^)//')$NAME"
  done
}
MAIN_MENU

BOOK_APPOINTMENT() {
    read SERVICE_ID_SELECTED
    #check if the input is valid;
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_NAME ]]
    then
        MAIN_MENU "Enter a valid service number"
    else
        echo -e "Pls enter your phone number:\n"
        read CUSTOMER_PHONE
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_ID ]]
        then
            echo -e "Please enter your name\n"
            read CUSTOMER_NAME
            echo -e "Please enter your appointment time\n"
            read SERVICE_TIME
            ADD_NEW_CUSTOMER=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

            CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
            BOOK_CUSTOMER=$($PSQL "INSERT INTO appointments (time, customer_id, service_id) VALUES ('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
            echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
        else
            echo -e "Please enter your appointment time\n"
            read SERVICE_TIME
            BOOK_CUSTOMER=$($PSQL "INSERT INTO appointments (time, customer_id, service_id) VALUES ('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
            echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
        fi

    fi
}
BOOK_APPOINTMENT


