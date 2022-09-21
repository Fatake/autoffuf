#!/bin/bash
function run_cmd () {
	/bin/bash -c "$1" 2>/dev/null
}

echo -e "\n\t Auto FFUF by Fatake\n"
if [ "$EUID" -ne 0 ] ; then
	echo -e "\n[!] Not sudo detected";
	exit 1
fi

WORDLIST_PATH="/home/kali/Documents/Tools/SecLists"
WORDLIST="-w ${WORDLIST_PATH}/Discovery/Web-Content/big.txt"

EXTENSIONS="-e conf,config,bak,backup,swp,old,db,sql,asp,aspx,aspx~,asp~,py,py~,rb,rb~,php,php~,bak,bkp,cache,cgi,conf,csv,html,inc,jar,js,json,jsp,jsp~,lock,log,rar,old,sql,sql.gz,sql.zip,sql.tar.gz,sql~,swp,swp~,tar,tar.bz2,tar.gz,txt,wadl,zip,.log,.xml,.js.,.json"
RECURSION="-recursion -recursion-depth 2"
REPLAY_PROXY="-replay-proxy http://127.0.0.1:8080"
THREADS="-t 10"

OUTPUT_FILES="$(pwd)/AutoFFUF/"
INPUTF_TARGETS="$(pwd)/Targets.txt"

#Optional
COOKIES="-b 'Some:some'"

i=1

if [ ! -d "${OUTPUT_FILES}" ]; then
	run_cmd "mkdir ${OUTPUT_FILES}"
	run_cmd "chown -R 1000:1000 ${OUTPUT_FILES}/"
fi

if [ ! -f "${INPUTF_TARGETS}" ]; then
	echo -e "[+] Creating ${INPUTF_TARGETS}"
	run_cmd "touch ${INPUTF_TARGETS}"
	run_cmd "chown -R 1000:1000 ${INPUTF_TARGETS}"
	echo -e "[i]Please add Targets(URL's) to the created files to continue"
	read -r -s -p $'Press enter to continue...'
fi

echo -e "\n[i] Output log files in format html path\n -> ${OUTPUT_FILES}"
echo -e "<------------------------------->"
for target in $(cat ${INPUTF_TARGETS}); do
	echo -e "\n\n[+] Listing Target#${i}: ${target}";
	echo -e "<------------------------------->";
	if  ! curl --output /dev/null --silent --head --fail "${target}"; then
		echo "[!] Target: ${target} NOT RESPONDING"
		continue
	fi
	OUTPUT_LOG="-o ${OUTPUT_FILES}ffuf_target${i}.html -of html"
	COMMAND="ffuf -r ${RECURSION} ${REPLAY_PROXY} ${WORDLIST} -ac ${OUTPUT_LOG} ${THREADS} ${EXTENSIONS} -u ${target}/FUZZ"
	
	echo -e "root# ${COMMAND}"
	echo -e "<------------------------------->\n";
	eval $COMMAND
	((i=i+1))
done;


