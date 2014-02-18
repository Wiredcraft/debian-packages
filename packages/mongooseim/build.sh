#!/bin/bash
####################
# Helper script to build the etcd package
# Ensure the proper permissions, etc.
####################

INCOMING=/var/www/repos/apt/ubuntu/incoming
VERSION=1.2

echo -n "Have you already copied the latest Mongooseim rel in opt/ ? [y/N]: "
read confirm

if [ "$confirm" != 'y' -a "$confirm" != 'Y' ]; then
    echo "Do it"
    exit 1
fi

echo -n "What is the version of Mongooseim ? [1.2-1]: "
read version

if [ -z "$version" ]; then
    version="1.2-1"
fi

echo "Setting up proper permissions for the files"
sudo chown -R root:root build/opt/mongooseim
sudo chown -R root:root build/etc
sudo chmod +x build/etc/init.d/mongooseim

echo "Prepare templates for the bin/ejabberd"
sudo mkdir -p build/opt/mongooseim/share/
if [ -f build/opt/mongooseim/bin/ejabberd -a ! -f build/opt/mongooseim/share/ejabberd ]; then
    sudo mv build/opt/mongooseim/bin/ejabberd build/opt/mongooseim/share/ejabberd
fi
if [ -f build/opt/mongooseim/etc/vm.args -a ! -f build/opt/mongooseim/share/vm.args ]; then
    sudo mv build/opt/mongooseim/etc/vm.args build/opt/mongooseim/share/vm.args
fi

echo -n "Proceed with the package build? [Y/n] "
read confirm

if [ -z "$confirm" -o "$confirm" == 'y' -o "$confirm" == 'Y' ]; then
    echo "Setting up proper version in the control file"
    sed -i "s/^Version: /Version: $version/" build/DEBIAN/control

    dpkg-deb --build build/ mongooseim_"$version"_amd64.deb
    if [ $? -eq 0 ]; then
        echo "Success - the deb package is available at ./mongooseim_${version}_amd64.deb"
        sudo cp mongooseim_"$version"_amd64.deb $INCOMING
        sudo chown debrepo. $INCOMING/mongooseim_"$version"_amd64.deb
        echo "The package has been copied to the deb repo incoming folder, you can proceed to its addition."
    else
        echo "Error while building the package."
        exit 1
    fi
else
    echo "Aborting build process."
    exit
fi
exit 0
