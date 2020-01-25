#!/bin/bash
if [ "$(id -u)" != "0" ]; then
	dialog --title "INFO" --msgbox "You need root access to run this script!" 5 43
	clear	
	exit 1
fi
#
USER=$(cat /etc/passwd | grep 1000 | cut -d : -f 6)
DIR=$USER/proiect_os
if [ -d $DIR ]
then
	rm -R $DIR/*
	else
	mkdir $DIR
fi
clear
cd $DIR
echo
echo "<< How many IPs do you want to scan? >>" | ccze -A
echo
read IPS
echo
echo "<< Filter the ports: >>" | ccze -A
echo
read PORT
echo
echo "<< Filter the port status (open/closed/filtered): >>" | ccze -A
echo
read STAT
echo
echo
echo "<< Scanning...>>" | ccze -A
echo
nmap -iR $IPS -p $PORT  > nmap.txt 2>/dev/null
cat nmap.txt | sed -e '/Begin/ d' | sed -e \$d  > nmap1.txt
cat nmap1.txt | grep report | awk '{print $NF}' | cut -d "(" -f2 | cut -d ")" -f1 > nmap2.txt
cat nmap1.txt | grep $PORT/tcp | awk '{print $2}' > nmap3.txt
paste -d " " nmap2.txt nmap3.txt > nmap4.txt
cat nmap4.txt | grep '^[0-9]' | grep $STAT | awk '{print$1}' | cut -d : -f 1 > 1-IpOpen.txt
clear
echo
echo "<< The corresponding IPs are: >>" | ccze -A
echo
cat 1-IpOpen.txt
echo
echo "<< Press Enter to continue ...>>" | ccze -A 
read
#rm nmap*.txt
echo
echo  "<< Continue the list attack by using the nmap plugins? [y/n] >>" | ccze -A
read OP
abort=0
if [ $OP = y ]
then
	while [ $abort -eq 0 ];
	do
			echo
				touch result_nmap.txt
				module=($(ls -1 /usr/share/nmap/scripts | cut -d . -f 1))
				declare -p module | sed -e 's/ /\n/g'
			read MOD
			clear
			echo
			echo "<< Processing with the module $line... >>" | ccze -A
	      		echo "${module[MOD]}" | tee -a 1-module.txt
			echo
			MODULE=$(cat 1-module.txt)
			if [ -s result_nmap.txt ]
			then
				> result_nmap.txt
			else
				touch result_nmap.txt
			fi
			for line in `cat 1-IpOpen.txt`; do
				let number+=1
					nmap -O -sS --script=$MODULE -P0 $line -p T:$PORT  >> result_nmap.txt
					echo "---------------------------------------" >> result_nmap.txt
			done
		echo
		echo  "<< Scan finished! >>" | ccze -A
		echo
		echo  "<< View data? [y/n] >>" | ccze -A
		read OP1
		if  [ $OP1 = y ]
		then
			if [ -s result_nmap.txt ]
			then
				echo
				cat result_nmap.txt
				echo
			else
				echo "No data found, aborting...."
				exit 1
			fi
			echo "<< Press enter to continue....>>" | ccze -A
			read
		else
			echo
		fi
		clear
		echo
		echo  "Do you want to try another attack script [y/n]"  | ccze -A
		echo
		read cont
		if  [ $cont != "y" ];
		then
			abort=1
		else
			echo
		fi
	done
else
	echo
	exit
fi
echo
echo "<< For more queries, the data file is result_nmap.txt >>" | ccze -A
echo
chmod  -R 777 $USER/scan_results/*
exit 0