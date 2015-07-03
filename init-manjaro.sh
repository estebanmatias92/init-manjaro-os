#!/bin/bash

install_working_tools() {
    yaourt -Syua --noconfirm openssh git docker xclip sublime-text htop

    # Install docker-compose
    sudo curl -L https://github.com/docker/compose/releases/download/1.1.0/docker-compose-`uname -s`-`uname -m` --output /usr/local/bin/docker-compose
    sudo chmod -v +x /usr/local/bin/docker-compose
    
    # Enable
    sudo systemctl start docker
    sudo systemctl enable docker

    # Configure git
    read -p "Enter your github email: " githubEmail
    ssh-keygen -t rsa -C $githubEmail
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa
    echo ""
    echo "Copying the public key to the clipboard"
    echo ""
    xclip -verbose -sel clip < ~/.ssh/id_rsa.pub
    echo ""
    echo "Your web browser will be open, close after copy the public key..."
    echo ""
    killall -v firefox
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
}

install_shell() {
    yaourt -Syua --noconfirm zsh zsh-completions

    # Install oh-my-zsh
    git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
    cp -vf ~/.zshrc ~/.zshrc.backup
    cp -vf ~/.bashrc ~/.bashrc.backup

    sudo git clone git://github.com/robbyrussell/oh-my-zsh.git /root/.oh-my-zsh
    sudo cp -vf /root/.zshrc /root/.zshrc.backup
    sudo cp -vf /root/.bashrc /root/.bashrc.backup

    # Set as default shell for all the users
    chsh -s $(which zsh)
    sudo -s chsh -s $(which zsh)
}

install_shell_tools() {
    yaourt -Syua --noconfirm tmux tmuxinator gvim fbterm

    # Install spf13-vim
    curl http://j.mp/spf13-vim3 -L -o - | sh

    # Install tmux plugins
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    cp -vf ./config/.tmux.conf ~/.tmux.conf
    tmux start-server
    tmux new-session -d
    ~/.tmux/plugins/tpm/scripts/install_plugins.sh
    tmux kill-server
}

install_utilities() {
    yaourt -Syua --noconfirm skype dropbox bleachbit xchat pidgin mplayer youtube-viewer pidgin-libnotify pidgin-otr
}

improve_performance() {
    yaourt -Syua --noconfirm zramswap verynice preload irqbalance

    sudo systemctl enable zramswap
    sudo systemctl enable verynice
    sudo systemctl enable preload
    sudo systemctl enable irqbalance
	
    sudo cp -vf ./etc/sysctl.d/100-manjaro.conf /etc/sysctl.d/100-manjaro.conf

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

    # Adobe
    sudo cp -vf ./etc/adobe/mms.cfg ~/etc/adobe/mms.cfg

    # Move /tmp to disk
    sudo systemctl mask tmp.mount
}

copy_user_config() {
    cp -vTRf ./config ~/
}

install_working_tools
install_shell
install_shell_tools
install_utilities
improve_performance
change_system_config
copy_user_config

echo "You should restart the system."
