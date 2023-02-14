#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Valentino's Salon ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES_OFFERED=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo -e "We offer these services:"
  echo "$SERVICES_OFFERED" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  echo "Enter service number to set an appointment or 4 to exit." 
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1) SERVICE_MENU 1 ;;
    2) SERVICE_MENU 2 ;;
    3) SERVICE_MENU 3 ;;
    4) EXIT ;;
    *) MAIN_MENU "Please enter a valid option." ;;
  esac
}

SERVICE_MENU() {
  echo -e "You entered the service $1"
  echo -e "\nPlease enter your phone number"
  read CUSTOMER_PHONE

  CHECK_FOR_RECORD=$($PSQL "SELECT customer_id, name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CHECK_FOR_RECORD ]]
  then
    echo -e "\nEnter your name:"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    echo -e "\nWhat time do you want to set for the appointment?"
    read SERVICE_TIME
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $1, '$SERVICE_TIME')")
    SERVICE_TYPE=$($PSQL "SELECT name FROM services WHERE service_id = $1")
    SERVICE_TYPE_FORMATTED=$(echo $SERVICE_TYPE | sed -r 's/^ *| *$//g')
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')
    echo -e "I have put you down for a $SERVICE_TYPE_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    echo -e "\nWhat time do you want to set for the appointment?"
    read SERVICE_TIME
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $1, '$SERVICE_TIME')")
    SERVICE_TYPE=$($PSQL "SELECT name FROM services WHERE service_id = $1")
    SERVICE_TYPE_FORMATTED=$(echo $SERVICE_TYPE | sed -r 's/^ *| *$//g')
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')
    echo -e "I have put you down for a $SERVICE_TYPE_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  fi

}

EXIT() {
  echo -e "Shutting down..."
}

MAIN_MENU
