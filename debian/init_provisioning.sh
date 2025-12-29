#!/bin/sh

alias elevate="echo '$ELEVATE_PASS' | sudo -S "

get_prov_file()
{
	local path="$1"
	local output="$2"

	curl -s "http://$PACKER_HTTP_ADDR/$path" -o "$output"
}

get_prov_file_sudo()
{
	get_prov_file "$1" /tmp/tmp_file
	elevate mv /tmp/tmp_file "$2"
}

printf "\n====================\n"
printf   "STARTING PROVISIONER"
printf "\n====================\n"

cd ~
rm -rf .cache \
	.dotnet \
	Downloads \
	.gnupg \
	.local \
	Music \
	Pictures \
	.pki \
	Public \
	.sudo_as_admin_successful \
	Templates \
	Videos \
	.xsession-errors

# Proper aliases
printf "alias l='ls -al --color'\n" >> ~/.bashrc
printf "alias grep='grep --color'\n" >> ~/.bashrc

# Dark theme
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
# If it doesn't work, here are some other candidates:
#   $ for s in $(gsettings list-schemas) ; do gsettings list-recursively "$s" ; done | grep -i dark
#   org.gnome.desktop.background picture-uri-dark 'file:///usr/share/backgrounds/gnome/adwaita-d.jpg'
#   org.gnome.desktop.interface color-scheme 'prefer-dark'
#   org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
#   org.gnome.shotwell.preferences.ui use-dark-theme true
#   org.gnome.shotwell.preferences.ui use-dark-theme true
#   org.gtk.gtk4.Inspector.Recorder dark false
#   org.yorba.shotwell.preferences.ui use-dark-theme true
#   org.yorba.shotwell.preferences.ui use-dark-theme true
#   org.yorba.shotwell.preferences.ui use-dark-theme true


# Disable the welcome tour
dconf write /org/gnome/shell/welcome-dialog-last-shown-version "'$(dpkg-query -W -f '${Version}' gnome-shell | cut -d~ -f1)'"


# I hate this default
elevate sed -i 's/set mouse=a/set mouse-=a/g' /usr/share/vim/vim91/defaults.vim


#############
# Mount and install the vmware guest tools
if [ "_$PACKER_BUILDER_TYPE" = "_vmware-iso" ]
then
	elevate mount -o ro /tmp/vmware_tools.iso /mnt
	elevate cp -r /mnt /tmp/guest-tools
	elevate umount /mnt
	elevate /tmp/guest-tools/run_upgrader.sh
	elevate rm -rf /tmp/guest-tools
	# A reboot will be required, but we can continue with the provisioning for now
fi

printf "\n[+] Finished!\n"

