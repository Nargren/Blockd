#!/bin/bash

#This script was written by:
# _   _                                
#| \ | |                               
#|  \| | __ _ _ __ __ _ _ __ ___ _ __  
#| . ` |/ _` | '__/ _` | '__/ _ \ '_ \ 
#| |\  | (_| | | | (_| | | |  __/ | | |
#\_| \_/\__,_|_|  \__, |_|  \___|_| |_|
#                  __/ |               
#                 |___/   
# 5 May, 2012
# Simple script to block tracking websites like Facebook.com
# Nargren

# Credit goes to hak5.org for the idea, see at http://hak5.org
# For updates please visit my blog at http://ubuntuhak.blogspot.com

###############################################################################################################
######################  VERSION 0.5  ##########################################################################
# Facebook block
# Google block added
# Google and Facebook blocks at the same time
# Configure menu added, option to choose the number of reset packets you want to send, own blocklist,
# temporary file cleaning
# Added option to create own, permanent blocklist
# Bug with Manual block and own blocklists have been fixed
# Interface specific blocking is available
# 21 spet 2012; minor changes, cleaning up some parts of the script

#####################  IMPORTANT  ############################################################################
#This script provides a fast and simple way for disabling website tracking
#The srcript uses ngrep to find any network packets containing the target expressions and sends out reset segments. If you don't already have ngrep installed, do so (apt-get install ngrep)
#Basically it Is blocking the searched word on the netwok level
#Some files must be created for specific functions at the moment, extensions used are *.blockd (temp) 
# and *.blockdd (permanent)
#By default the script blocks on all network interfaces
#Stopping the script should allow traffic again by default, however there is a manual option

#Note that blocking is case sensitive! ie write facebook.com and NOT Facebook.com
#To interrupt a running process in the terminal, press Ctrl + C

#####################  FEATURES  #############################################################################
# Add manual blocking option [x]
# Stop command for running script [-]   - Ctrl + C works only for now
# Make script return to start [x]
# Permanent "manual" Block list from file [x]
# Design more interactive UI/GUI [-]
# Add interface specific block [x]
# Fix manual block [x]
# Fix own blocklist [x]

#####################  CONFIGURE  ############################################################################
# Here you can change some basic default settings

#Set amount of reset packets you want to send
#(1 is usually enough, but you can pick anything,3,5,10 etc)
packet=3

#Specify on what interface you want to block tracking websites
#(any=all by default; change to: wlan0, eth0 etc as needed)
interface=any

#####################  LOGO  #################################################################################
clear
echo "Welcome to Block-d v0.5 track blockker!"
echo "Track me if you can!"
echo -en "\033[1m                                 
 ____   _               _             _____  
|  _ \ | |             | |           |  __ \ 
| |_) || |  ___    ___ | | __ ______ | |  | |
|  _ < | | / _ \  / __|| |/ /|______|| |  | |
| |_) || || (_) || (__ |   <         | |__| |
|____/ |_| \___/  \___||_|\_\        |_____/ 
              
\033[0m"

#####################  FUNCTIONS  ############################################################################

function fb_block {
echo ""
echo "Blocking Facebook.com"
sudo ngrep -q -d $interface 'facebook.com' -K $packet
}

function google_block {
echo ""
echo "Blocking Google.com"
sudo ngrep -q -d $interface 'google.com' -K $packet
}

function fg_block {
echo ""
echo "Blocking Google.com and Facebook.com"
sudo ngrep -q -d $interface 'facebook.com|google.com' -K $packet
}

function allow_all {
echo ""
echo "Disabling block"
sudo killall ngrep
}

function manual_block {
file="blocklist.blockd"
if [ -e $file ]; then
sudo rm -f blocklist.blockd
sudo rm -f read.blockd
fi

echo ""
echo "How many sites do you want to block?"
read number
echo "Enter the name of the $number site(s) you want to block"
echo "Seperate them by pressing ENTER"
count=$number
while [ $count -gt 0 ]
	do
	read block
	echo "$block" >> read.blockd				
	let count=count-1
	done

echo | awk -vORS='|' 5 read.blockd > templist.blockd
path=`sed '$s/.$//' templist.blockd`
echo ""
sudo ngrep -q -d $interface $path -K $packet
sudo rm read.blockd
sudo rm templist.blockd
}

function create_own_blocklist {
echo ""
echo "Enter the sites that you want to block"
echo "ATTENTION! Put each of them separately into new line"
sudo nano blocklist.blockdd
}

function run_own_blocklist {
echo | awk -vORS='|' 5 blocklist.blockdd > blocklist.blockd
path2=`sed '$s/.$//' blocklist.blockd`
echo ""
sudo ngrep -q -d $interface $path2 -K $packet
sudo rm blocklist.blockd
}

function packets {
echo ""
echo "Enter number of reset packets to be sent:"
echo "(By default it's $packet, choose 1-10 generally)"
read packet
}

function configure {
PS3='
Select an option:'
select config in "Delete temporary files" "Manage own blocklist" "Reset-packet count" "Interface settings" "Back"
do
case $config in

"Delete temporary files")
tempf=*.blockd
if [ -e $tempf ]; then
sudo rm -f *.blockd
else
echo "No temporary files were found."
fi
echo "
1) Delete temporary files  4) Interface settings
2) Create own blocklist	   5) Back
3) Reset packet count"
;;

"Manage own blocklist")
create_own_blocklist
echo "
1) Delete temporary files  4) Interface settings
2) Create own blocklist	   5) Back
3) Reset packet count"
;;

"Reset-packet count")
packets
echo "
1) Delete temporary files  4) Interface settings
2) Create own blocklist	   5) Back
3) Reset packet count"
;;

"Interface settings")
echo "On what interface you want to block?"
echo "(Default is $interface. Change if necessary)"
read interface
echo "
1) Delete temporary files  4) Interface settings
2) Create own blocklist	   5) Back
3) Reset packet count"
;;

"Back")
echo "
1) Block Facebook	    5) Own blocklist
2) Block Google		    6) Settings
3) Block Facebook & Google  7) Allow all
4) Manual Block		    8) Quit"
break
;;
*) echo PEBKAC;;
esac
done
}

#####################  MAIN MENU  ############################################################################

PS3='
Select an option:'
select option in "Block Facebook" "Block Google" "Block Facebook & Google" "Manual Block" "Own blocklist" "Settings" "Allow all" "Quit"

do
case $option in
"Block Facebook")
fb_block
echo "
1) Block Facebook	    5) Own blocklist
2) Block Google		    6) Settings
3) Block Facebook & Google  7) Allow all
4) Manual Block		    8) Quit"
;;


"Block Google")
google_block
echo "
1) Block Facebook	    5) Own blocklist
2) Block Google		    6) Settings
3) Block Facebook & Google  7) Allow all
4) Manual Block		    8) Quit"
;;


"Block Facebook & Google")
fg_block
echo "
1) Block Facebook	    5) Own blocklist
2) Block Google		    6) Settings
3) Block Facebook & Google  7) Allow all
4) Manual Block		    8) Quit"
;;


"Manual Block")
manual_block
echo "
1) Block Facebook	    5) Own blocklist
2) Block Google		    6) Settings
3) Block Facebook & Google  7) Allow all
4) Manual Block		    8) Quit"
;;


"Own blocklist")
run_own_blocklist
echo "
1) Block Facebook	    5) Own blocklist
2) Block Google		    6) Settings
3) Block Facebook & Google  7) Allow all
4) Manual Block		    8) Quit"
;;


"Settings")
configure
;;


"Allow all")
allow_all
echo "
1) Block Facebook	    5) Own blocklist
2) Block Google		    6) Settings
3) Block Facebook & Google  7) Allow all
4) Manual Block		    8) Quit"
;;


"Quit")
exit 0


break
;;
*) echo PEBKAC;;
esac
done
