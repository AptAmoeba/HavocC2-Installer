#!/bin/bash
# This script assists the default Apt Package install by applying the patch for issue #105: "Demon Compiler."
# UNTIL THEY FIX IT, #105 exists by default in the apt package version of Havoc (which we solve here).
# 
# === THIS SCRIPT REQUIRES SUDO PERMISSIONS TO RUN! ===
RED="\033[1;31m"
GREEN="\033[0;32m"
NOCOLOR="\033[0m"
CompilerURL="http://musl.cc/x86_64-w64-mingw32-cross.tgz"
# Compiler URL pulled from https://github.com/HavocFramework/Havoc/issues/105
HavocFile="/usr/share/havoc/profiles/havoc.yaotl"
echo ""
echo -e "______________________________________________${RED}"
echo '          _______           _______  _______ '
echo '|\     /|(  ___  )|\     /|(  ___  )(  ____ \'
echo '| )   ( || (   ) || )   ( || (   ) || (    \/'
echo '| (___) || (___) || |   | || |   | || |      '
echo '|  ___  ||  ___  |( (   ) )| |   | || |      '
echo '| (   ) || (   ) | \ \_/ / | |   | || |      '
echo '| )   ( || )   ( |  \   /  | (___) || (____/\'
echo '|/     \||/     \|   \_/   (_______)(_______/'
echo -e "${NOCOLOR}============== ${RED}INSTALLER SCRIPT${NOCOLOR} =============="
echo -e ${NOCOLOR}
if [ "$EUID" -ne 0 ]; then
	echo ""
	echo -e "${RED}[-]${NOCOLOR} Please re-run this script as root ('sudo ./HavocHelper.sh')"
	exit 1
fi
echo ""
echo -e "${GREEN}[+]${NOCOLOR} Installing Havoc C2 Apt package..."
sleep 2
sudo apt install havoc -y
# Validate install success:
if [ $? -ne 0 ]; then
	echo ""
	echo -e "${RED}[-]${NOCOLOR} Havoc apt package install failed. Check apt error output."
	exit 1
fi
echo ""
echo -e "${GREEN}[+]${NOCOLOR} Installing new compiler for Demon payload creation (Fixes i:#105)...${NOCOLOR}"
wget $CompilerURL -O /tmp/compiler.tgz
# Validate compiler download success:
if [ $? -ne 0 ]; then
	echo ""
	echo -e "${RED}[-]${NOCOLOR} Download failed. Check internet connectivity & verify that the dest URL is still maintained."
	exit 1
fi
echo ""
sleep 1
echo -e "${GREEN}[+]${NOCOLOR} Downloaded archived compiler. Extracting & moving to /usr/bin..."
echo -e "${GREEN}[+]${NOCOLOR} Prepare for a bunch of output! This is expected."
sleep 2
sudo tar -xzvf /tmp/compiler.tgz -C /usr/bin
# Validate extraction success:
if [ $? -ne 0 ]; then
	echo ""
	echo -e "${RED}[-]${NOCOLOR} Extract to /usr/bin failed. Check code to step-through debug."
	exit 1
fi
echo ""
echo -e "${GREEN}[+]${NOCOLOR} Extract & move successful."
rm /tmp/compiler.tgz
echo ""
echo -e "${GREEN}[+]${NOCOLOR} Overwriting default compiler values in Havoc config..."
sudo sed -i 's|Compiler64 = "/usr/bin/x86_64-w64-mingw32-gcc"|Compiler64 = "usr/bin/x86_64-w64-mingw32-cross/bin/x86_64-w64-mingw32-gcc"|' $HavocFile
sudo sed -i 's|Compiler86 = "/usr/bin/i686-w64-mingw32-gcc"|Compiler86 = "usr/bin/x86_64-w64-mingw32-cross/bin/x86_64-w64-mingw32-gcc"|' $HavocFile
# Validate variable patching success:
if [ $? -ne 0 ]; then
	echo ""
	echo -e "${RED}[-]${NOCOLOR} Compiler variable patching failed. Verify access to /path/to/Havoc.yaotl in system vs script vars..."
	echo "... then verify that the lines we are searching for exist in the yaotl config exactly as searched in this script." 
	exit 1
fi
echo ""
echo -e "${GREEN}[+]${NOCOLOR} Compiler variable patching successful."
echo ""
echo ""
sleep 1
echo -e "${GREEN}=================================================================${NOCOLOR}"
echo -e "${GREEN}[+] Havoc C2 Installation & Patching successful!${NOCOLOR}"
echo ""
sleep .3
echo "> Provision Operators in /usr/share/havoc/profiles/havoc.yaotl"
echo ""
sleep .3
echo "> Start Teamserver with the following command (without sudo):"
sleep .3
echo "#~$ havoc server --profile profiles/havoc.yaotl"
sleep .3
echo ""
echo "> Start Operator Client with the following command (without sudo):"
sleep .3
echo "#~$ havoc client"
sleep .3
echo -e "${GREEN}=================================================================${NOCOLOR}"
exit 0
