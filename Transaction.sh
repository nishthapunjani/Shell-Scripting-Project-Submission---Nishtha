#!/bin/bash

# Global Variables
ACCOUNT_BALANCE=0
CUSTOMER_NAME=""
ATM_PIN=""
ID_NUMBER=""

# Function to validate ID formats with specific hardcoded examples
validate_id() {
    local type=$1
    local id_num="${2// /}" 
    id_num="${id_num^^}"    

    if [[ "$id_num" == "234567891234" || "$id_num" == "ABCDE1234F" || "$id_num" == "UP1420160034761" ]]; then
        return 0
    fi

    case $type in
        "adhar")   [[ "$id_num" =~ ^[2-9][0-9]{11}$ ]] && return 0 ;;
        "pan")     [[ "$id_num" =~ ^[A-Z]{5}[0-9]{4}[A-Z]$ ]] && return 0 ;;
        "licence") [[ "$id_num" =~ ^[A-Z]{2}[0-9]{13}$ ]] && return 0 ;;
    esac
    return 1
}

# 1. Customer_Details Function
Customer_Details() {
    echo "--- Welcome to India Bank ATM ---"
    echo "--- Account Creation Started ---"
    read -p "Enter Full Name: " CUSTOMER_NAME

    local attempts=0
    local max_attempts=5
    local id_type

    while [ $attempts -lt $max_attempts ]; do
        read -p "Enter the ID Proof Type [adhar/pan/licence]: " id_type
        id_type=$(echo "$id_type" | tr '[:upper:]' '[:lower:]' | xargs)

        if [[ "$id_type" =~ ^(adhar|pan|licence)$ ]]; then
            echo "Example: Aadhar(234567891234), PAN(ABCDE1234F), License(UP1420160034761)"
            read -p "Enter $id_type number: " input_id
            if validate_id "$id_type" "$input_id"; then
                ID_NUMBER=$input_id
                break
            else
                ((attempts++))
                echo "Invalid format. Attempts remaining: $((max_attempts - attempts))"
            fi
        else
            ((attempts++))
            echo "Invalid ID Proof Type. Attempts remaining: $((max_attempts - attempts))"
        fi

        if [ $attempts -eq $max_attempts ]; then
            echo "Account Creation Failed. Exiting..."
            exit 1
        fi
    done

    read -p "Enter Account Type (S for Savings / C for Current): " acc_choice
    
    while true; do
        read -p "Enter Initial Deposit Amount: Rs." amount
        if [[ "$amount" =~ ^[0-9]+$ ]] && (( amount % 100 == 0 )) && (( amount > 0 )); then
            ACCOUNT_BALANCE=$amount
            break
        else
            echo "Error: Amount should not be denomination of 50. Enter multiples of 100/1000."
        fi
    done

    echo "Account Created Successfully! Balance: Rs.$ACCOUNT_BALANCE"
    Customer_Choice
}

# 2. Customer_Choice Function
Customer_Choice() {
    read -p "Do you want to Apply for ATM Card? (Yes/No): " apply_atm
    if [[ "${apply_atm,,}" == "yes" ]]; then
        ATM_PIN=$((RANDOM % 9000 + 1000))
        echo "ATM Card Processed. Your Temporary PIN is: $ATM_PIN"
        
        read -p "Access ATM now? (Okay/Cancel): " access
        if [[ "${access,,}" == "okay" ]]; then
            ATM_Process
        else
            Final_Exit_Choice
        fi
    else
        echo -e "Thanks for being a valuable customer!"
        Final_Exit_Choice
    fi
}

# 3. ATM_Process Function (LOOP ADDED HERE)
ATM_Process() {
    read -sp "Enter the Pin Number: " pin_entered
    echo
    if [ "$pin_entered" == "$ATM_PIN" ]; then
        echo "Welcome User!!"
        # While loop allows multiple transactions
        while true; do
            echo -e "\n--- ATM MENU ---"
            echo "1. Cash Withdraw"
            echo "2. Cash Deposit"
            echo "3. Exit to Final Menu"
            read -p "Enter choice: " choice
            case $choice in
                1) Debit_Process ;;
                2) Credit_Process ;;
                3) Final_Exit_Choice ;;
                *) echo "Wrong Choice. Please select 1, 2, or 3." ;;
            esac
        done
    else
        echo "Invalid Pin Number."
        ATM_Process
    fi
}

# 4. Debit_Process Function
Debit_Process() {
    read -p "Enter Amount to Withdraw: Rs." withdraw
    if [[ "$withdraw" =~ ^[0-9]+$ ]] && (( withdraw % 100 == 0 )) && (( withdraw > 0 )); then
        if (( withdraw <= ACCOUNT_BALANCE )); then
            ACCOUNT_BALANCE=$((ACCOUNT_BALANCE - withdraw))
            echo "Deduction Successful. New Balance: Rs.$ACCOUNT_BALANCE"
        else
            echo "Error: Insufficient Balance! Current Balance: Rs.$ACCOUNT_BALANCE"
        fi
    else
        echo "Error: Enter a valid amount (Multiples of 100, no 50 denominations)."
    fi
    # No return to Final_Exit_Choice here, it goes back to the ATM loop
}

# 5. Credit_Process Function
Credit_Process() {
    read -p "Enter Amount to Deposit: Rs." deposit
    if [[ "$deposit" =~ ^[0-9]+$ ]] && (( deposit % 100 == 0 )) && (( deposit > 0 )); then
        ACCOUNT_BALANCE=$((ACCOUNT_BALANCE + deposit))
        echo "Deposit Successful. New Balance: Rs.$ACCOUNT_BALANCE"
    else
        echo "Error: Enter a valid amount (Multiples of 100, no 50 denominations)."
    fi
    # No return to Final_Exit_Choice here, it goes back to the ATM loop
}

# 6. Final_Exit_Choice Function
Final_Exit_Choice() {
    echo -e "\n--- EXIT MENU ---"
    echo "1. Show Account Balance"
    echo "2. Exit"
    read -p "Enter Choice: " exit_choice

    if [ "$exit_choice" == "1" ]; then
        echo "------------------------------------"
        echo "Customer Name: $CUSTOMER_NAME"
        echo "Final Account Balance: Rs.$ACCOUNT_BALANCE"
        echo "------------------------------------"
    fi
    
    echo "Thank you, Visit Again!!"
    exit 0
}

# Start App
Customer_Details
