#!/bin/bash

# Array of IP addresses
IP_ADDRESSES=("192.168.1.16" "192.168.1.15" "192.168.1.26")

# Function to check if the default_dds_og.xml file exists on remote machines and move if not exist
move_if_not_exists() {
  sshpass -p 'root' ssh root@"$1" "[ ! -f /algo/include/default_dds_og.xml ] && mv /algo/include/default_dds.xml /algo/include/default_dds_og.xml"
  if [ $? -eq 0 ]; then
    echo "Moved default_dds.xml to default_dds_og.xml on $1"
  else
    echo "default_dds_og.xml already exists on $1, no need to move."
  fi
}

# Function to move back the default_dds_og.xml to default_dds.xml if it exists
move_back_if_exists() {
  sshpass -p 'root' ssh root@"$1" "[ -f /algo/include/default_dds_og.xml ] && mv /algo/include/default_dds_og.xml /algo/include/default_dds.xml"
  if [ $? -eq 0 ]; then
    echo "Moved default_dds_og.xml back to default_dds.xml on $1"
  else
    echo "default_dds_og.xml not found on $1, no move needed."
  fi
}

# Function to copy default_dds.xml to remote machine
copy_default_dds() {
  sshpass -p 'root' scp "./default_dds.xml" "root@$1:/algo/include/"
  if [ $? -eq 0 ]; then
    echo "Copied default_dds.xml to $1"
  else
    echo "Failed to copy default_dds.xml to $1"
  fi
}

for ip in "${IP_ADDRESSES[@]}"; do
	# Check the command-line argument
	if [ "$1" == "dev" ]; then
		# Perform the move operation only if default_dds_og.xml does not exist on each remote machine
		move_if_not_exists $ip
		# Copy the new default_dds.xml to the remote machines
		copy_default_dds $ip
	elif [ "$1" == "revert" ]; then
		move_back_if_exists $ip
	else
		echo "Usage: $0 {dev|revert}"
		exit 1
	fi
done

echo "Done."