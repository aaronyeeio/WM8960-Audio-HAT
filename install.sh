#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 1>&2
   exit 1
fi

is_Radxa=$(cat /proc/device-tree/model | awk  '{print $1}')
if [ "x${is_Radxa}" != "xRadxa" ] ; then
  echo "Sorry, this drivers only works on Radxa"
  exit 1
fi

ver="1.0"


# we create a dir with this version to ensure that 'dkms remove' won't delete
# the sources during kernel updates
marker="0.0.0"

apt update
apt-get -y install linux-headers-$(uname -r) #raspberrypi-kernel 
apt-get -y install dkms git i2c-tools libasound2-plugins

# locate currently installed kernels (may be different to running kernel if
# it's just been updated)
kernels=$(ls /lib/modules | sed "s/^/-k /")
uname_r=$(uname -r)

function install_module {
  src=$1
  mod=$2

  if [[ -d /var/lib/dkms/$mod/$ver/$marker ]]; then
    rmdir /var/lib/dkms/$mod/$ver/$marker
  fi

  if [[ -e /usr/src/$mod-$ver || -e /var/lib/dkms/$mod/$ver ]]; then
    dkms remove --force -m $mod -v $ver --all
    rm -rf /usr/src/$mod-$ver
  fi
  mkdir -p /usr/src/$mod-$ver
  cp -a $src/* /usr/src/$mod-$ver/
  dkms add -m $mod -v $ver
  dkms build $uname_r -m $mod -v $ver && dkms install --force $uname_r -m $mod -v $ver

  mkdir -p /var/lib/dkms/$mod/$ver/$marker
}

install_module "./" "wm8960-soundcard"

# install dtbos
echo -e "\n\n****************************************************"
echo "please run rsetup to install the dtbo file after this script finished"
echo "select Overlays - Install 3rd party overlay - wm8960-soundcard.dtbo"
echo -e "****************************************************\n\n"

#set kernel moduels
grep -q "i2c-dev" /etc/modules || \
  echo "i2c-dev" >> /etc/modules  
grep -q "snd-soc-wm8960" /etc/modules || \
  echo "snd-soc-wm8960" >> /etc/modules  
grep -q "snd-soc-wm8960-soundcard" /etc/modules || \
  echo "snd-soc-wm8960-soundcard" >> /etc/modules  
  
#install config files
mkdir /etc/wm8960-soundcard || true
cp *.conf /etc/wm8960-soundcard
cp *.state /etc/wm8960-soundcard

#set service 
cp wm8960-soundcard /usr/bin/
cp wm8960-soundcard.service /lib/systemd/system/
systemctl enable  wm8960-soundcard.service 
systemctl start wm8960-soundcard                                

echo "------------------------------------------------------"
echo "Please reboot your device to apply all settings"
echo "Enjoy!"
echo "------------------------------------------------------"
