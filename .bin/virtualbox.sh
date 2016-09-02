#!/bin/bash
# https://github.com/cgerke/dotfiles

# PXE kernel source
url="https://www.kernel.org/pub/linux/utils/boot/syslinux"
kernel="/6.xx/syslinux-6.03.tar.gz"

# CentOS
centos="centos/{5,6,7}"

#Ubuntu
ubuntu="ubuntu/{precise,trusty,xenial}"

## Dependencies
## * Brew
## * 7z
[ ! -f /usr/local/bin/brew ] && /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
[ ! -d /usr/local/Cellar/p7zip ] && brew install p7zip

# Distro media source
distros=""
distros+="${centos}"
distros+=",${ubuntu}"

# PXE TFTP core
tftp_env=~/Library/VirtualBox/TFTP

# Help
_self="${0##*/}"; echo "$_self"
if [ $# -lt 1 ];  then
    dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    source "${dir}/help.sh"
	exit
fi

##
## Usage
shopt -s nocasematch
case $1 in
  ## -c Download CentOS syslinux kernel for PXE
  c|-c)
    mirror="http://mirror.centos.org"
    initrd="os/x86_64/images/pxeboot/initrd.img"
    vmlinuz="os/x86_64/images/pxeboot/vmlinuz"
    for i in $(eval "echo ${centos}");
    do
        [ ! -f ${tftp_env}/images/$i/initrd.img ] && curl -o ${tftp_env}/images/$i/initrd.img ${mirror}/$i/${initrd}
        [ ! -f ${tftp_env}/images/$i/vmlinuz ] && curl -o ${tftp_env}/images/$i/vmlinuz ${mirror}/$i/vmlinuz
    done
  ;;
  ## -l <Guest Name> Create Linux VirtualBox Guest
  l|-l)
    mkdir -p ~/VirtualBox\ VMs/${1}
    VBoxManage createhd --filename ~/VirtualBox\ VMs/test/${1}.vdi --size 8192
    VBoxManage createvm --register --name ${1} --ostype Linux_64
    VBoxManage modifyvm ${1} --boot1 disk --boot2 net --boot3 none --boot4 none
    VBoxManage modifyvm ${1} --nattftpfile1 /pxelinux.0
    VBoxManage modifyvm ${1} --memory 1024
    VBoxManage modifyvm ${1} --vram 128 --accelerate3d off --audio none
    VBoxManage modifyvm ${1} --nic1 nat --nictype1 82540EM --cableconnected1 on
    VBoxManage modifyvm ${1} --natpf1 "guest_ssh,tcp,,2222,,22"
    VBoxManage modifyvm ${1} --natpf1 "guest_http,tcp,,8080,,80"
    VBoxManage modifyvm ${1} --natpf1 "guest_https,tcp,,8443,,443"
    VBoxManage modifyvm ${1} --hda ~/VirtualBox\ VMs/test/test.vdi
    VBoxManage storagectl ${1} --name "IDE Controller" --add ide --controller PIIX4 --bootable on
  ;;
  ## -m MacOS Virtual machine dev env
  m|-m)
    while IFS= read -r -d '' n; do
      installer_app="$n"
      installer_name=$(echo $installer_app | cut -d'.' -f1 | cut -d'X' -f2 | sed 's/ //g' | cut -d'/' -f5)
      echo '## Mounting os x installer'
      hdiutil attach "${installer_app}/Contents/SharedSupport/InstallESD.dmg" -noverify -nobrowse -mountpoint /Volumes/attached_${installer_name}_InstallESD
      echo '## Creating temporary cdr'
      hdiutil create -o ~/VirtualBox\ VMs/tmp_${installer_name}.cdr -size 7316m -layout SPUD -fs HFS+J
      echo '## Attaching temporary cdr'
      hdiutil attach ~/VirtualBox\ VMs/tmp_${installer_name}.cdr.dmg -noverify -nobrowse -mountpoint /Volumes/attached_${installer_name}_cdr
      echo '## Restoring os x installer basesystem to attached cdr'
      asr restore -source /Volumes/attached_${installer_name}_InstallESD/BaseSystem.dmg -target /Volumes/attached_${installer_name}_cdr -noprompt -noverify -erase
      echo '## Deleting /Volumes/OS\ X\ Base\ System/System/Installation/Packages'
      rm -f /Volumes/OS\ X\ Base\ System/System/Installation/Packages
      echo '## Copying osx installer packages'
      cp -rp /Volumes/attached_${installer_name}_InstallESD/Packages /Volumes/OS\ X\ Base\ System/System/Installation
      echo '## Copying osx installer chunklist'
      cp -rp /Volumes/attached_${installer_name}_InstallESD/BaseSystem.chunklist /Volumes/OS\ X\ Base\ System/
      echo '## Copying osx installer basesystem dmg'
      cp -rp /Volumes/attached_${installer_name}_InstallESD/BaseSystem.dmg /Volumes/OS\ X\ Base\ System/
      echo '## Detaching os x installer'
      hdiutil detach /Volumes/attached_${installer_name}_InstallESD
      echo '## Detaching basesystem'
      hdiutil detach /Volumes/OS\ X\ Base\ System
      hdiutil convert ~/VirtualBox\ VMs/tmp_${installer_name}.cdr.dmg -format UDTO -o ~/VirtualBox\ VMs/tmp_${installer_name}.iso
      mv ~/VirtualBox\ VMs/tmp_${installer_name}.iso.cdr ~/VirtualBox\ VMs/Mac\ OS\ X\ ${installer_name}.iso
      rm -f ~/VirtualBox\ VMs/tmp_${installer_name}.cdr.dmg
      rm -f ~/VirtualBox\ VMs/tmp_${installer_name}.iso
    done < <(find ~/VirtualBox\ VMs/Install* -maxdepth 0 -type d -print0)
    echo "Change chipset to PIIX3, mount created ISO and boot up."
    open ~/VirtualBox\ VMs/
  ;;
  ## -t Configure PXE TFTP
  t|-t)
    # PXE TFTP tree
    mkdir -p ${tftp_env}/pxelinux.cfg
    eval "mkdir -p  ~/Library/VirtualBox/TFTP/images/{${distros}}"
    curl -o ${tftp_env}/syslinux.tar.gz "${url}/${kernel}"
    tar -xvf ${tftp_env}/syslinux.tar.gz
    cp ${tftp_env}/syslinux*/bios/core/pxelinux.0 ${tftp_env}/
    cp ${tftp_env}/syslinux*/bios/com32/chain/chain.c32 ${tftp_env}/
    cp ${tftp_env}/syslinux*/bios/com32/elflink/ldlinux/ldlinux.c32 ${tftp_env}/
    cp ${tftp_env}/syslinux*/bios/com32/lib/libcom32.c32 ${tftp_env}/
    cp ${tftp_env}/syslinux*/bios/com32/libutil/libutil.c32 ${tftp_env}/
    cp ${tftp_env}/syslinux*/bios/com32/menu/menu.c32 ${tftp_env}/
    cp ${tftp_env}/syslinux*/bios/com32/menu/vesamenu.c32 ${tftp_env}/
  ;;
  ## -u Download Ubuntu syslinux kernel for PXE
  u|-u)
    mirror="http://archive.ubuntu.com/ubuntu/dists"
    iso="main/installer-amd64/current/images/netboot/mini.iso"
    for i in $(eval "echo ${ubuntu}");
    do
        maj_version=$(echo $i | cut -d'/' -f2)
        brew list p7zip && echo "Installed" || brew install p7zip
        [ ! -f ${tftp_env}/images/${i}/initrd.gz ] &&  curl -o ${tftp_env}/images/mini.iso ${mirror}/${maj_version}/${iso}
        [ ! -f ${tftp_env}/images/${i}/initrd.gz ] &&  7z -y x ${tftp_env}/images/mini.iso -o${tftp_env}/images/${i}
    done
  ;;
  ## -x <ORIG> <NEW> Clone VirtualBox Guest
  x|-x)
    #curl -o http://download.virtualbox.org/virtualbox/${version}/Oracle_VM_VirtualBox_Extension_Pack-${version}.vbox-extpack
    #VBoxManage extpack install ./Oracle_VM_VirtualBox_Extension_Pack-${version}.vbox-extpack
    VBoxManage clonevm ${1} --name ${2}
    VBoxManage registervm ~/VirtualBox\ VMs/${2}/${2}.vbox
    # Make a pxe file
    cp ~/Library/VirtualBox/TFTP/pxelinux.0 ~/Library/VirtualBox/TFTP/_temp_${2}.pxe
    VBoxManage modifyvm ${2} --nattftpfile1 /_temp_${2}.pxe
esac
