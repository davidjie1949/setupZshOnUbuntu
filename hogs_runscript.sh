#!/bin/bash

# Define the remote servers
SERVERS=("192.168.1.16")

# Define the username and password for SSH
USERNAME="root"
PASSWORD="root"

# Define the local directory to save the outputs
LOCAL_DIR="./"

# Define remote filenames
PIDS_FILE="/algo/bin/pids_and_names.txt"
HOGS_FILE="/algo/bin/hogs_output.txt"
# Function to run the commands on a specific server
run_commands() {
    local server_ip="$1"

    # Print all PIDs and their process names
    sshpass -p "$PASSWORD" ssh "$USERNAME@$server_ip" "ps -e -o pid,comm > $PIDS_FILE"

    # Run the hogs command (replace with actual command if different)
    sshpass -p "$PASSWORD" ssh "$USERNAME@$server_ip" "hogs -s 0.1  > $HOGS_FILE"
}

# Function to copy files from the server to the local machine
copy_files() {
    local server_ip="$1"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    echo "Copying files from $server_ip to local machine..."
    sshpass -p "$PASSWORD" scp "$USERNAME@$server_ip:$PIDS_FILE" "$LOCAL_DIR/$(basename $PIDS_FILE .txt)_$timestamp.txt"
    sshpass -p "$PASSWORD" scp "$USERNAME@$server_ip:$HOGS_FILE" "$LOCAL_DIR/$(basename $HOGS_FILE .txt)_$timestamp.txt"

}

# Trap the SIGINT signal (Ctrl + C)
trap 'echo "Interrupt received. Copying remaining files..."; for SERVER in "${SERVERS[@]}"; do copy_files "$SERVER"; done; exit' SIGINT

# Loop through each server and run the commands
for SERVER in "${SERVERS[@]}"; do
    echo "Running commands on $SERVER..."
    run_commands "$SERVER"
    copy_files "$SERVER"
done

echo "All commands executed and outputs copied to local directory."
