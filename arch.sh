#! /bin/bash

# Ethernet: ip link
# WiFi: iwctl -> station wlan0 connect "WiFi-AP"

set -e 

COMMAND="$1"

EFI_SIZE="100M"


function create_parts()
{
	echo
	echo "### Creating partitions"
	
	echo -n "Enter swap size (ex: 16G): "
	read SWAP_SIZE
	
	PART1="n\n1\n\n+$EFI_SIZE\nEF00\n"
	PART2="n\n2\n\n-$SWAP_SIZE\n8300\n"
	PART3="n\n3\n\n\n8200\n"
	PRINT="p\n"
	WRITE="w\ny\n"
	QUIT="q\n";
	echo -ne "${PART1}${PART2}${PART3}${PRINT}${WRITE}${QUIT}" | gdisk /dev/sda
}


function make_and_mount_fs()
{
	echo
	echo "### Creating filesystems"
	
	mkfs.fat -F 32 /dev/sda1
	mkfs.ext4 /dev/sda2
	mkswap /dev/sda3
	
	mount /dev/sda2 /mnt
	mount --mkdir /dev/sda1 /mnt/boot/efi
	swapon /dev/sda3
}


function install_base_system()
{
	echo
	echo "### Installing base system"
	
	pacstrap -K /mnt base linux linux-firmware
	genfstab -U /mnt >>/mnt/etc/fstab
}


function setup_time()
{
	echo
	echo "### Configuring time"
	
	ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
	hwclock --systohc
}


function setup_locale()
{
	echo
	echo "### Configuring locale"
	
	echo -ne "en_US.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8\n" >>/etc/locale.gen
	locale-gen
	
	echo "LANG=ru_RU.UTF-8" >/etc/locale.conf
	echo -ne "KEYMAP=ru\nFONT=cyr-sun16\n" >/etc/vconsole.conf
}


function setup_network()
{
	echo
	echo "### Configuring network"
	
	echo -n "Enter hostname: "
	read HOST_NAME
	echo "$HOST_NAME" >/etc/hostname
}


function setup_initcpio()
{
	echo
	echo "### Generating initcpio"
	mkinitcpio -P
}


function setup_passwd()
{
	echo
	echo "### Setting root password"
	passwd
}


function setup_lib32()
{
	echo
	echo "### Configuring multilib"
	echo -ne "[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" >>/etc/pacman.conf
	pacman -Sy
}


function install_daemons()
{
	echo
	echo "### Installing daemons"
	pacman -S --noconfirm \
		avahi \
		cups \
		cups-filters \
		darkhttpd \
		mosquitto \
		transmission-cli \
		docker \
		docker-buildx
}


function install_sys_utils()
{
	echo
	echo "### Installing system utils"
	pacman -S --noconfirm \
		dosfstools \
		grub \
		efibootmgr \
		efivar \
		lsof \
		sudo \
		fakeroot \
		fakechroot \
		debugedit \
		meson \
		pkgconf \
		expac \
		jq
}


function install_net_utils()
{
	echo
	echo "### Installing network utils"
	pacman -S --noconfirm \
		inetutils \
		net-tools \
		openssh \
		openvpn \
		tcpdump \
		traceroute \
		wget \
		wireguard-tools \
		netctl \
		dialog \
		iw \
		dhcpcd \
		wpa_supplicant \
		socat
}


function install_file_utils()
{
	echo
	echo "### Installing file utils"
	pacman -S --noconfirm \
		binwalk \
		dos2unix \
		mc \
		p7zip \
		squashfs-tools \
		unrar \
		zip
}


function install_other()
{
	echo
	echo "### Installing others"
	pacman -S --noconfirm \
		lrzsz \
		man-db \
		man-pages \
		rtl-sdr \
		sox \
		sqlite \
		wine \
		wine-mono
}


function install_dev_tools()
{
	echo
	echo "### Installing dev tools"
	pacman -S --noconfirm \
		gcc \
		gdb \
		autoconf \
		automake \
		asciidoc \
		bison \
		flex \
		cmake \
		git \
		make \
		mbedtls \
		nodejs \
		ts-node \
		tslib \
		npm \
		rustup \
		php \
		valgrind \
		lrzsz \
		picocom
}


function install_cross_tools()
{
	echo
	echo "### Installing cross tools"
	pacman -S --noconfirm \
		arm-none-eabi-binutils \
		arm-none-eabi-gcc \
		arm-none-eabi-newlib \
		riscv64-elf-binutils \
		riscv64-elf-gcc \
		riscv64-elf-newlib \
		sdcc \
		stlink
}


function install_Xorg()
{
	echo
	echo "### Installing Xorg"
	pacman -S --noconfirm \
		xf86-input-libinput \
		xf86-video-intel \
		xkeyboard-config \
		xorg-fonts-100dpi \
		xorg-fonts-75dpi \
		xorg-fonts-alias-100dpi \
		xorg-fonts-alias-75dpi \
		xorg-fonts-alias-cyrillic \
		xorg-fonts-alias-misc \
		xorg-fonts-cyrillic \
		xorg-fonts-encodings \
		xorg-fonts-misc \
		xorg-fonts-type1 \
		xorg-mkfontscale \
		xorg-server \
		xorg-server-common \
		xorg-setxkbmap \
		xorg-xauth \
		xorg-xinit \
		xorg-xinput \
		xorg-xkbcomp \
		xorg-xmodmap \
		xorg-xprop \
		xorg-xrandr \
		xorg-xrdb \
		xorg-xset \
		fluxbox \
		ttf-liberation \
		ttf-opensans
}


function install_X_apps()
{
	echo
	echo "### Installing X apps"
	pacman -S --noconfirm \
		audacity \
		chromium \
		firefox \
		geeqie \
		gimp \
		imagemagick \
		mplayer \
		qt5-base \
		qt5-charts \
		qt5-serialport \
		rxvt-unicode \
		rxvt-unicode-terminfo \
		telegram-desktop \
		thunderbird \
		virtualbox \
		virtualbox-guest-iso \
		virtualbox-host-modules-arch \
		xpdf \
		xsel \
		cbatticon
}


function install_X_dev_tools()
{
	echo
	echo "### Installing X dev tools"
	pacman -S --noconfirm \
		code \
		meld \
		kicad \
		kicad-library \
		kicad-library-3d \
		openscad \
		prusa-slicer \
		f3d
}


function setup_etc()
{
	echo
	echo "### Configuring /etc"
	
	if [ ! -f /etc/mkinitcpio.conf.orig ]; then
		cat /etc/mkinitcpio.conf | grep -v "^HOOKS=" >/etc/mkinitcpio.conf.new
		cat >>/etc/mkinitcpio.conf.new <<__EOF__
HOOKS=(base udev autodetect modconf block filesystems keyboard resume fsck)
__EOF__
		mv /etc/mkinitcpio.conf /etc/mkinitcpio.conf.orig
		mv /etc/mkinitcpio.conf.new /etc/mkinitcpio.conf
	fi
	
	if [ ! -f /etc/systemd/logind.conf.orig ]; then
		cat /etc/systemd/logind.conf | grep -v "^HandlePowerKey=" | grep -v "^HandleHibernateKey=" >/etc/systemd/logind.conf.new
		cat >>/etc/systemd/logind.conf.new <<__EOF__
HandlePowerKey=hibernate
HandleHibernateKey=hibernate
__EOF__
		mv /etc/systemd/logind.conf /etc/systemd/logind.conf.orig
		mv /etc/systemd/logind.conf.new /etc/systemd/logind.conf
	fi
	
	if [ ! -f /etc/X11/xinit/xinitrc.orig ]; then
		mv /etc/X11/xinit/xinitrc /etc/X11/xinit/xinitrc.orig
		cat >/etc/X11/xinit/xinitrc <<__EOF__
#!/bin/sh

userresources=\$HOME/.Xresources
usermodmap=\$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

if [ -f \$sysresources ]; then
    xrdb -merge \$sysresources
fi

if [ -f \$sysmodmap ]; then
    xmodmap \$sysmodmap
fi

if [ -f "\$userresources" ]; then
    xrdb -merge "\$userresources"

fi

if [ -f "\$usermodmap" ]; then
    xmodmap "\$usermodmap"
fi

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "\$f" ] && . "\$f"
 done
 unset f
fi

#cbatticon -i symbolic &
fluxbox
__EOF__
	fi
	
	cat >/etc/sudoers.d/10-wheel <<__EOF__
%wheel ALL=(ALL:ALL) ALL
__EOF__
}


function setup_grub()
{
	echo
	echo "### Configuring GRUB"
	
	eval `blkid -o export /dev/sda2`
	ROOT_UUID=$UUID
	
	eval `blkid -o export /dev/sda3`
	SWAP_UUID=$UUID
	
	mkdir -p /boot/grub
	cat >>/boot/grub/grub.cfg <<__EOF__
set timeout=3

search --fs-uuid --set=root $ROOT_UUID

menuentry "Arch Linux" {
    linux /boot/vmlinuz-linux root=UUID=$ROOT_UUID rw resume=UUID=$SWAP_UUID
    initrd /boot/initramfs-linux.img
}

menuentry "Arch Linux no resume" {
    linux /boot/vmlinuz-linux root=UUID=$ROOT_UUID rw
    initrd /boot/initramfs-linux.img
}
__EOF__
	
	grub-install
}


function setup_user()
{
	echo
	echo "### Configuring user"
	echo -n "Enter user name: "
	read USERNAME
	useradd -g users -G wheel,audio,uucp,video,vboxusers,docker $USERNAME
	mkdir -p /home/$USERNAME
	chown $USERNAME:users /home/$USERNAME
	chmod 700 /home/$USERNAME
	passwd $USERNAME
}


function setup_eth()
{
	echo
	echo "### Configuring ethernet"
	for NETIF in `ls -1 /sys/class/net | grep '^enp'`
	do
		echo "Creating /etc/netctl/$NETIF-dhcp"
		cat >/etc/netctl/$NETIF-dhcp <<__EOF__
Description='$NETIF DHCP'
Interface=$NETIF
Connection=ethernet
IP=dhcp 
__EOF__
		netctl enable $NETIF-dhcp
	done
	systemctl enable systemd-resolved
}


function setup_Xorg()
{
	echo
	echo "### Configuring Xorg"
	
	cat >/etc/X11/xorg.conf.d/00-keyboard.conf <<__EOF__
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "us,ru"
    Option "XkbModel" "pc105"
    Option "XkbVariant" "os_winkeys"
    #Option "XKbOptions" "grp:menu_toggle,grp_led:scroll,ctrl:swapcaps,compose:ralt"
    Option "XKbOptions" "grp:ctrl_shift_toggle,grp_led:scroll"
EndSection
__EOF__
	
	cat >/etc/X11/xorg.conf.d/20-video.conf <<__EOF__
Section "Monitor"
	Identifier   "Monitor"
	Option       "Enable"
EndSection

Section "Device"
	Identifier  "Card0"
	Driver      "intel"
EndSection
__EOF__
}


function setup_rc_local()
{
	echo
	echo "### Configuring rc.local"
	
	cat >/etc/systemd/system/rc-local.service <<__EOF__
[Unit]
Description=/etc/rc.local Compatibility
ConditionPathExists=/etc/rc.local
 
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
 
[Install]
WantedBy=multi-user.target
__EOF__
	
	cat >/etc/rc.local <<__EOF__
#! /bin/bash

__EOF__
	chmod 755 /etc/rc.local
	
	systemctl enable rc-local.service
}


function install_auracle()
{
	echo
	echo "### Installing auracle"
	WD=$PWD
	mkdir -p $HOME/pkg
	cd $HOME/pkg
	git clone https://aur.archlinux.org/auracle-git.git
	cd auracle-git
		makepkg PKGBUILD --skippgpcheck --install --needed
	cd $WD
}


function install_pacaur()
{
	echo
	echo "### Installing pacaur"
	WD=$PWD
	mkdir -p $HOME/pkg
	cd $HOME/pkg
	git clone https://aur.archlinux.org/pacaur.git
	cd pacaur
		makepkg PKGBUILD --skippgpcheck --install --needed
	cd $WD
}


function install_aur_pkgs()
{
	echo
	echo "### Installing AUR packages"
	export EDITOR=mcedit	# needed by pacaur
	pacaur -S --noconfirm --noedit \
		stm32flash-git \
		stm8flash-git \
		mbpoll-git \
		lndir \
		saleae-logic2 \
		xtensa-lx106-elf-gcc-bin \
		rtl_433-git
}





if [ "$COMMAND" == "strap" ]; then
	create_parts
	make_and_mount_fs
	install_base_system
	cp "$0" /mnt
	
	echo
	echo "Now run: arch-chroot /mnt"
	echo "Next: sh /arch.sh install"
elif [ "$COMMAND" == "install" ]; then
	setup_time
	setup_locale
	setup_network
	setup_initcpio
	setup_passwd
	setup_lib32
	
	install_Xorg
	install_daemons
	install_sys_utils
	install_net_utils
	install_file_utils
	install_other
	install_dev_tools
	install_cross_tools
	install_X_apps
	install_X_dev_tools
	
	setup_etc
	setup_grub
	setup_user
	setup_eth
	setup_Xorg
	setup_rc_local
	
	echo
	echo "Now run: sudo -u $USERNAME sh /arch.sh aur"
elif [ "$COMMAND" == "aur" ]; then
	if [ `id -u` == "0" ]; then
		echo "Don't run as root !"
		exit 1
	fi
	
	install_auracle
	install_pacaur
	install_aur_pkgs
else
	echo "Commands: strap => install => aur"
fi
