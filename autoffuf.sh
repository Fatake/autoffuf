#!/bin/bash
function run_cmd () {
	/bin/bash -c "$1" 2>/dev/null
}

usage () {
	echo -e "\n[i] auto-ffuf is designed to run an automatic dir web scan"
	echo -e "\nUsage:"
	echo -e "sudo ./autoffuf -n Output_File_Name -l TargetsList\n"

	echo -e "\t-h \tDisplays this message of use"
	echo -e "\t-w \tWordlist path, if this flag is not used the program whill use de the default path "
	echo -e "\t\t\"/usr/share/seclists/Discovery/Web-Content/big.txt\""
	echo -e "\n\t-n \tSpecifies the folder name to the output results"
	echo -e "\t-l \tThis flag specifies a file with all targets to be audited";

	echo -e "\nSamples:"
	echo -e "\tsudo ./autoffuf -n GenericStore -l urls.txt"
	echo -e "\tsudo ./autoffuf -n apiImportantClient -l targets.lst -w /my/custom/wordlist\n"


	echo -e "[*] Made with love and tacos by \n\t-> @Fatake \n"
}

# Check opts
while getopts ":w:l:n:h" opt; do
	case $opt in
		# help
		h)
			usage
			exit 1
			;;

		# WordlistPath
		w)
			CUSTOM_WL="$OPTARG"
			f_wordpath=true
			;;

		# Targets list
		l)
			INPUTF_TARGETS="$OPTARG"
			f_list=true
			;;

		# Project Name
		n)
			PNAME="$OPTARG"
			f_pname=true
			;;

		\?)
			echo -e "[!] Invalid option:\t -$OPTARG" >&2
			usage
			exit 1
			;;

		:)
			echo -e "[!] Option -$OPTARG requires an argument." >&2
			usage
			exit 1
			;;
	esac
done


#-------------------------------------------------------
if [ -z "$f_list" ] || [ -z "$f_pname" ]; then
	echo -e "[!] ERROR! \n[i] check ./autoffuf -h"
	exit 1;
fi 

if [ "$EUID" -ne 0 ] ; then
	echo -e "\n[!] Not sudo detected";
	usage
	exit 1
fi

## Custom world list
if [ -z "$f_wordpath" ]; then
	WORDLIST_PATH="/home/kali/Documents/Tools/SecLists";
	WORDLIST="${WORDLIST_PATH}/Discovery/Web-Content/big.txt";
else
	WORDLIST="${CUSTOM_WL}"
fi 

EXTENSIONS="-e conf,config,bak,backup,swp,old,db,sql,asp,aspx,aspx~,asp~,py,py~,rb,rb~,php,php~,bak,bkp,cache,cgi,conf,csv,html,inc,jar,js,json,jsp,jsp~,lock,log,rar,old,sql,sql.gz,sql.zip,sql.tar.gz,sql~,swp,swp~,tar,tar.bz2,tar.gz,txt,wadl,zip,.log,.xml,.js.,.json"
RECURSION="-recursion -recursion-depth 2"
REPLAY_PROXY="-replay-proxy http://127.0.0.1:8080"
THREADS="-t 10"

OUTPUT_FILES="$(pwd)/AutoFFUF_${PNAME}/"

#Optional
COOKIES="-b 'some:some'"

echo -e "\n\t Auto FFUF by Fatake\n"
echo -e "[i] Project Output: ${OUTPUT_FILES}"
echo -e "[i] Targets: ${INPUTF_TARGETS}"
echo -e "[i] Using wordlist: ${WORDLIST}"
echo -e "<------------------------------->"

if [ ! -d "${OUTPUT_FILES}" ]; then
	run_cmd "mkdir ${OUTPUT_FILES}"
	run_cmd "chown -R 1000:1000 ${OUTPUT_FILES}/"
fi

i=1
for target in $(cat ${INPUTF_TARGETS}); do
	echo -e "\n\n[+] Listing Target#${i}: ${target}";
	echo -e "<------------------------------->";
	#if  ! curl --output /dev/null --silent --head --fail "${target}"; then
	#	echo "[!] Target: ${target} NOT RESPONDING"
	#	continue
	#fi
	OUTPUT_LOG="-o ${OUTPUT_FILES}ffuf_target${i}.html -of html"
	COMMAND="ffuf -r ${RECURSION} ${REPLAY_PROXY} -w ${WORDLIST} ${COOKIES} -ac ${OUTPUT_LOG} ${THREADS} ${EXTENSIONS} -u ${target}/FUZZ"
	
	echo -e "root# ${COMMAND}"
	echo -e "<------------------------------->\n";
	eval $COMMAND
	((i=i+1))
done;


