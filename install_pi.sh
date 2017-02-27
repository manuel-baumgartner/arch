#! /bin/bash

# clear screen
	clear

# vars 
	PI_IP="192.168.0.103"
	PI_PATH="/mnt/pi"; 
	PI_USER="pi"
	PI_MOUNT_TYPE="2"
	PI_MOUNT_PERM="1"
	OWNER="manu" # This is the user who has local folder rights

function main {
	
	echo "-- Raspberry Pi setup --"
	echo "- Configurations -"

	echo "local mount path: $PI_PATH"
	echo "raspberry pi IP: $PI_IP"
	echo "raspberry pi user: $PI_USER"
	echo "Mount type: $PI_MOUNT_TYPE" 
	echo "Permanent mount: $PI_MOUNT_PERM" 
	echo "Change? (yes/No)" 

	read IN 

	if [[ $IN =~ ^[Yy]*$ ]] ; then
		setVars	
	fi
	
	mountPi
}


function setVars
{
		echo "1: pi ip"
		echo "2: pi mount path"
		echo "3: pi user"
		echo "4: pi mount type"
		echo "5: pi mount permanent"
		read IN

		if [ $IN -eq 1 ] ; then
			echo "change $PI_IP: "
			read PI_IP
		fi

		if [ $IN -eq 2 ] ; then
			echo "change $PI_PATH: "
			read PI_PATH
		fi

		if [ $IN -eq 3 ] ; then
			echo "change $PI_USER: "
			read PI_USER
		fi

		if [ $IN -eq 4 ] ; then
			echo "change $PI_MOUNT_TYPE: "
			read PI_MOUNT_TYPE
		fi

		if [ $IN -eq 5 ] ; then
			echo "change $PI_MOUNT_PERM: "
			read PI_MOUNT_PERM
		fi
}

# mounts pi; dependency PI_MOUNT_TYPE
# always check if mount is possible before putting it to fstab
function mountPi
{
	echo "trying to create a folder: $PI_PATH"
	sudo mkdir  $PI_PATH
	if [ $? -ne 0 ] ; then
		echo "Do you want to continue? This will change the folder settings!! (Yes/no)"
		read IN
		if [[ ! $IN =~ ^[Yy$ ]]  ; then
			exit
		fi
	fi

	echo "trying to change folder owner to: $OWNER"
	sudo chown $OWNER:users $PI_PATH

	
	if [ $PI_MOUNT_TYPE -eq 1 ] ; then
		sshfs $PI_USER@$PI_IP:/ $PI_PATH

		if [ $? -eq 0 ] ; then
			echo "Device exists and was mounted"
		else
			echo "Device not found"
			exit
		fi
	fi

	if [ $PI_MOUNT_TYPE -eq 2 ] ; then
		sudo mount $PI_IP:/ $PI_PATH

		if [ $? -eq 0 ] ; then
			echo "Device exists and was mounted"
		else
			echo "Device not found"
			echo "Do you want to change the settings? (Yes/no)"
			read IN
			if [[ $IN =~ ^[Yy]$ ]] ; then
				setVars
			fi

			exit
		fi

		if [ $PI_MOUNT_PERM -eq 1 ] ; then
			echo "Creating permanent mount in fstab"
			echo "$PI_IP:/	$PI_PATH	nfs	rsize=8192,wsize=8192,timeo=14,intr" | sudo tee -a /etc/fstab
		fi


	fi

	if [ $PI_MOUNT_TYPE -eq 3 ] ; then
		sudo mount -t cifs -o user=$PI_USER $PI_IP:/ $PI_PATH
		if [ $? -eq 0 ] ; then
			echo "Device exists and was mounted"
		else
			echo "Device not found"
			exit
		fi




	fi
}

# run main
main
