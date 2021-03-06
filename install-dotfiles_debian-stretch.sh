#!/usr/bin/env bash
#test3

########### Check if running Debian Stretch ###########

if [ ! "$(command -v lsb_release)" ]; then
        echo -e "You are not running Debian.\nThis script is only optimized for Debian distributions.\nExiting..."
        exit 1
fi

lsb_dist="$(lsb_release -si)"
dist_codename="$(lsb_release -sc)"

if [ "$lsb_dist" = "Debian" ]; then
    if [ "$dist_codename" = "stretch" ]; then
        :
    else
        echo -e "You are not running Debian Stretch!\nThis script is optimized for Debian Stretch only."
        while true; do
        read -p "Continue anyway? [Yes/No] " cont
        if [ "$cont" = "no" ] || [ "$cont" = "No" ] || [ "$cont" = "n" ] || [ "$cont" = "NO" ]; then
            echo "Exiting script..."
            exit 1
        elif [ "$cont" = "yes" ] || [ "$cont" = "Yes" ] || [ "$cont" = "y" ] || [ "$cont" = "YES" ]; then
            echo -e "Continuing with script...\nWill exit one any errors!"
			set -e
            break
        else
            echo "Please only input 'Yes' or 'No'"
        fi
        done
    fi
else
    echo -e "You are not running Debian.\nThis script is only optimized for Debian distributions.\nExiting..."
    exit 1
fi
#################################################

############## Check monitor setup ##############
while true; do
read -p "Dual monitor[1] or single monitor[2] setup? " mon
if [ "$mon" -eq 1 ]; then
	while true; do
	read -p "Is your primary monitor located to the left[1] or to the right[2] of your secondary monitor? " monpos
	if [ "$monpos" -eq 1 ]; then
		monitorpos="left"
		break
	elif [ "$monpos" -eq 2 ]; then
		monitorpos="right"
		break
	else
		echo "Please only input 1 or 2"
	fi
	done
	break
elif [ "$mon" -eq 2 ]; then
	monitor="singlemon"
	break
else
	echo "Please only input 1 or 2"
fi
done
#################################################

######## Creating dirs and moving files ########
echo "Creating directories and moving files..."
mkdir -v ~/bin
mkdir -v ~/.xlock
mkdir -v ~/.i3
cp -v i3/config ~/.i3

if [ "$monitor" = "dualmon" ]; then
	if [ "$monitorpos" = "left" ]; then
		cp -v scripts/i3lock-dualmon-primLeft.sh ~/bin/i3lock.sh
	elif [ "$monitorpos" = "right" ]; then
		cp -v scripts/i3lock-dualmon-primRight.sh ~/bin/i3lock.sh
	fi
elif [ "$monitor" = "singlemon" ]; then
	cp -v scripts/i3lock-singlemon.sh ~/bin/i3lock.sh
fi

cp -v wallpapers/icon.png ~/.xlock
cp -v i3/i3blocks.conf ~/.i3blocks.conf
cp -v misc/Xdefaults ~/.Xdefaults
cp -v misc/zshrc ~/.zshrc
cp -v misc/vimrc ~/.vimrc
#################################################

############## Installing packages ##############
echo "Installing packages (vim, i3-gaps deps, urxvt, font-awesome, i3-utils) etc..."
sudo apt-get install -y libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev \
libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev \
libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev \
pkg-config i3blocks i3lock ruby-ronn fonts-font-awesome rxvt-unicode-256color vim scrot zsh curl \
xclip suckless-tools weechat feh unzip
#################################################

######## Compiling and installing i3-gaps ########
echo "Cloning i3-gap source..."
git clone https://www.github.com/Airblader/i3 ~/i3-gaps
echo "Changing cwd..."
cd ~/i3-gaps
echo "Compiling i3-gaps..."
make
echo "Installing i3-gaps..."
sudo make install
echo "Chaning back to previous directory..."
cd -
##################################################

############ Fixing urxvt copy/paste ############
echo "Fixing copy/paste for urxvt..."
sudo cp -v scripts/clipboard /usr/lib/urxvt/perl/clipboard
#################################################

######## Installing pathogen and plugins ########
echo "Installing pathogen..."
mkdir -pv ~/.vim/autoload ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
echo "Installing colorscheme gruvbox for vim..."
git clone https://github.com/morhetz/gruvbox.git ~/.vim/bundle/gruvbox
echo "Installing syntastic..."
git clone https://github.com/scrooloose/syntastic ~/.vim/bundle/syntastic
echo "Installing vim-airline..."
git clone https://github.com/bling/vim-airline ~/.vim/bundle/vim-airline
##################################################

############ Installing Google Chrome ############
echo "Adding Google Chrome repository..."
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
echo "Adding Google Chrome repository signing key..."
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo "Updating deb repositories and installing google-chrome-stable..."
sudo apt-get update && sudo apt-get install -y google-chrome-stable
###################################################

############### Installing Spotify ################
#The offical deb file in spotify's repository doesn't work for Debian Stretch, but there are dev pkg's out there...
current_spotify_package="spotify-client_1.0.19.106.gb8a7150f_amd64.deb"
echo "Installing Spotify ($current_spotify_package) dev package"
wget http://repository-origin.spotify.com/pool/non-free/s/spotify-client/$current_spotify_package
sudo dpkg -i $current_spotify_package
sudo rm -fv $current_spotify_package
###################################################

############ Installing dmenu_extended ############
echo "Installing dmenu-extended..."
cd ~
wget https://github.com/markjones112358/dmenu-extended/archive/master.zip
unzip ~/master.zip
cd dmenu-extended-master
sudo python setup.py install
cd ..
sudo rm -fv dmenu-extended-master master.zip
###################################################

##### Installing pip (python package manager) #####
echo "Installing pip (python package manager)..."
wget https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py
rm -fv get-pip.py
###################################################

############ Installing rainbowstream ############
echo "Installing rawinbowstream..."
sudo pip install rainbowstream
#fix for rainbowstream crash, cause of the use of sudo
sudo cp /root/.rainbow_config.json ~/
sudo chown $UID:"$GID" ~/.rainbow_config.json
###################################################

#################### Oh My Zsh ###################
echo "Installing oh-my-zsh..."
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
cp -v ~/dot-files/misc/headless.zsh-theme ~/.oh-my-zsh/themes
chsh -s /bin/zsh
##################################################

################### Wallpaper ###################
mkdir ~/Wallpapers
cp -v ~/dot-files/wallpapers/7SqL0BC.jpg ~/Wallpapers
feh --bg-scale ~/Wallpapers/7SqL0BC.jpg
##################################################
