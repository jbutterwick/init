dnf -y install cmake freetype-devel fontconfig-devel libxcb-devel libxkbcommon-devel g++ openssl-devel sqlite-devel python3-tkinter ncurses-devel perl helix
dnf -y groupinstall "Development Tools"

# rust and rust packages
if ! cargo --version; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

cargo install zellij btm starship rtx-cli bat exa ripgrep
bat cache --build
dnf -y install dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


mkdir ~/Projects ~/Dependencies

cd ~/Projects
