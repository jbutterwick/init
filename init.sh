dnf install cmake freetype-devel fontconfig-devel libxcb-devel libxkbcommon-devel g++ openssl-devel sqlite-devel python3-tkinter ncurses-devel
cargo install zellij btm starship rtx-cli bat exa ripgrep

dnf -y install dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


mkdir ~/Projects ~/Dependencies

cd ~/Projects