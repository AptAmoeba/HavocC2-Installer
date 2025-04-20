#!/bin/bash
# This script automatically installs Havoc C2, handles the building, places it into /opt, and adds it to PATH for easier invocation therein (No './').
RED="\033[1;31m"
GREEN="\033[0;32m"
NOCOLOR="\033[0m"
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
#--- Root check
if [ "$EUID" -eq 0 ]; then
	echo -e "${RED}[-]${DEFAULT} Please run this script WITHOUT sudo to ensure pathing works properly. (#~$ ./HavocHelper.sh)"
	echo "    You will be prompted for your password by commands that require it."
	echo "    If you are running this on a system where Root is the default & intended Havoc user (not recommended), edit the code to remove this root check."
	exit 1
fi
#--- Root check
echo ""
echo -e "${GREEN}[+]${NOCOLOR} Preliminary system Update/Upgrade."
sleep 2
sudo apt update && sudo apt upgrade -y
# Validate install success:
if [ $? -ne 0 ]; then
	echo ""
	echo -e "${RED}[-]${NOCOLOR} Update/Upgrade failed. Check apt error output."
	exit 1
fi
echo ""
# Check/Install Havoc prerequisites
echo -e "${GREEN}[+]${NOCOLOR} Verifying Prerequisites..."
sudo apt install -y git build-essential apt-utils cmake libfontconfig1 libglu1-mesa-dev libgtest-dev libspdlog-dev libboost-all-dev libncurses5-dev libgdbm-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev mesa-common-dev qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools libqt5websockets5 libqt5websockets5-dev qtdeclarative5-dev golang-go qtbase5-dev libqt5websockets5-dev python3-dev libboost-all-dev mingw-w64 nasm
echo ""
#Pulling Havoc's Dev branch into Opt
echo -e "${GREEN}[+]${NOCOLOR} Cloning Havoc's DEV Branch into /opt..."
sleep 1
cd /opt
sudo git clone -b dev https://github.com/HavocFramework/Havoc.git
echo ""
echo -e "${GREEN}[+]${NOCOLOR} Preparing builds..."
sleep 2
cd Havoc/teamserver
sudo go mod download golang.org/x/sys
if [ $? -ne 0 ]; then
	echo ""
	echo -e "${RED}[-]${NOCOLOR} go mod download of golang.org/x/sys failed."
	exit 1
fi
sudo go mod download github.com/ugorji/go
if [ $? -ne 0 ]; then
	echo ""
	echo -e "${RED}[-]${NOCOLOR} go mod download of github.com/ugorji/go failed."
	exit 1
fi
cd ..
echo ""
echo -e "${GREEN}[+]${NOCOLOR} Building Havoc TeamServer..."
echo -e "${GREEN}[+]${NOCOLOR}This will take a little while and it'll potentially be a bit more resource-intensive."
echo -e "${GREEN}[+]${NOCOLOR} There will also be a few 'errors', but those are expected."
sleep 2
sudo make ts-build
if [ $? -ne 0 ]; then
	echo ""
	echo -e "${RED}[-]${NOCOLOR} TeamServer Build failed. See error output for more info."
	exit 1
fi
echo ""
echo -e "${GREEN}[+]${NOCOLOR} Building Havoc Client..."
sudo make client-build
if [ $? -ne 0 ]; then
	echo ""
	echo -e "${RED}[-]${NOCOLOR} Client Build failed. See error output for more info."
	exit 1
fi
echo ""
echo -e "${GREEN}[+]${NOCOLOR} Identifying Shell..."
if [[ $SHELL == "/usr/bin/zsh" ]]; then
	echo -e "${GREEN}[+]${NOCOLOR} ZSH Shell identified."
	shellFile="$HOME/.zshrc"
elif [[ $SHELL == "/usr/bin/bash" ]]; then
	echo -e "${GREEN}[+]${NOCOLOR} Bash Shell identified."
	shellFile="$HOME/.bashrc"
else
	echo -e "${RED}[-]${NOCOLOR} Shell ($SHELL) unidentifiable. You will need to manually add the Havoc binary to your PATH if you don't want to use './'"
	exit 1
fi
echo ""
echo -e "${GREEN}[+]${NOCOLOR} Adding binary to PATH..."
sleep 1
export PATH=$PATH:/opt/Havoc >> $shellFile
source $shellFile
echo -e "${GREEN}[NOTE]${NOCOLOR} Unfortunately, due to how Havoc searches for files, you will need to be inside the /opt directory when you execute it. However, you now no longer have to use the annoying './' when invoking."
sleep 2
echo ""
sleep 1
echo -e "${GREEN}=========================================================================${NOCOLOR}"
echo -e "${GREEN}[+] Havoc C2 Installation & Deployment Successful!${NOCOLOR}"
echo ""
echo "(Provision Operator Credentials & Config in /Havoc/profiles/havoc.yaotl)"
echo ""
echo ""
echo "---- Running Havoc ----"
echo ""
sleep .2
echo -e "${GREEN}1.)${NOCOLOR} CD into /Opt"
echo "-> #~$ cd /opt"
echo ""
sleep .2
echo -e "${GREEN}2.)${NOCOLOR} Start the Teamserver with the following command (${RED}without sudo${NOCOLOR}):"
sleep .2
echo "-> #~$ havoc server --profile profiles/havoc.yaotl"
sleep .2
echo ""
echo -e "${GREEN}3.)${NOCOLOR} Start the Operator Client with the following command (${RED}without sudo${NOCOLOR}):"
sleep .2
echo "-> #~$ havoc client"
sleep .2
echo -e "${GREEN}=========================================================================${NOCOLOR}"
exit 0
