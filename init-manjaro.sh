#!/bin/bash

install_working_tools() {
    yaourt -Syua --noconfirm openssh git docker xclip
    
    # Enable
    sudo systemctl enable docker

    # Configure git
    read -p "Enter your github email: " githubEmail
    ssh-keygen -t rsa -C $githubEmail
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa
    echo ""
    echo "Copying the public key to the clipboard"
    echo ""
    xclip -sel clip < ~/.ssh/id_rsa.pub
    echo ""
    echo "Your web browser will be open, close after copy the public key..."
    echo ""
    killall firefox
    firefox --new- https://github.com/settings/ssh
    ssh -T git@github.com
    echo ""
    echo "Set your local identity for github"
    echo ""
    read -p "Enter your github username: " githubUsername
    git config --global user.email $githubEmail
    git config --global user.name $githubUsername

    # Configure docker
    sudo gpasswd -a ${USER} docker
    newgrp docker
    bash
}

install_shell() {
    yaourt -Syua --noconfirm zsh zsh-completions

    # Install and configure oh-my-zsh
    git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
    cp ~/.zshrc ~/.zshrc.backup
    cp config/.zshrc ~/.zshrc
    cp ~/.bashrc ~/.bashrc.backup
    cp config/.bashrc ~/.bashrc

    # Set as default shell for all the users
    chsh -s $(which zsh)
    sudo -s chsh -s $(which zsh)
}

install_shell_tools() {
    yaourt -Syua --noconfirm tmux tmuxinator gvim fbterm

    # Install and configure spf13-vim
    curl http://j.mp/spf13-vim3 -L -o - | sh
    cp config/.vimrc.local ~/.vimrc.local 

    # Install and configure tmux plugins
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    cp config/.tmux.conf ~/.tmux.conf
    tmux source-file ~/.tmux.conf
    tmux start-server
    tmux new-session -d
    ~/.tmux/plugins/tpm/scripts/install_plugins.sh
    tmux kill-server
}

install_utilities() {
    yaourt -Syua --noconfirm skype dropbox bleachbit xchat mplayer youtube-viewer

    # Config mplayer
    mkdir ~/.mplayer
    cp config/.mplayer/config ~/.mplayer/config

    # Config youtube-viewer
    mkdir -p ~/.config/youtube-viewer
    cp config/.config/youtube-viewer/youtube-viewer.conf ~/.config/youtube-viewer/youtube-viewer.conf
}

improve_performance() {
    yaourt -Syua --noconfirm zramswap verynice preload irqbalance

    sudo systemctl enable zramswap
    sudo systemctl enable verynice
    sudo systemctl enable preload
    sudo systemctl enable irqbalance
	
    sudo -s <<EOF
echo "vm.swappiness = 1" > /etc/sysctl.d/100-manjaro.conf
echo "vm.vfs_cache_pressure = 50" >> /etc/sysctl.d/100-manjaro.conf
EOF

    echo "/etc/sysctl.d/100-manjaro.conf modified"
}

change_system_config() {
    # Keyboard
    sudo kbdrate -d 200 -r 30
    sudo xset r rate 200 30
    echo "Remember change keyboard rate and speed from your DE settings to make it persist."
    
    # Compositor
    # turn off the xfce compositor
    xfconf-query --channel=xfwm4 --property=/general/use_compositing --set=false
}

install_working_tools
install_shell
install_shell_tools
install_utilities
improve_performance
change_system_config

echo "You should restart the system."
