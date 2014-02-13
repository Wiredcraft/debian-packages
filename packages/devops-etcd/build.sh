#!/bin/bash
####################
# Helper script to build the etcd package
# Ensure the proper permissions, etc.
####################

INCOMING=/var/www/repos/apt/ubuntu/incoming

echo -n "Have you already copied the newest etcd / etcdctl binaries in build/opt/devops/bin ? [y/N]: "
read confirm

if [ "$confirm" != 'y' -a "$confirm" != 'Y' ]; then
    echo "Do it"
    exit 1
fi

echo "Setting up proper permissions for the files"
sudo chown root:root build/opt/devops/bin/*
sudo mkdir -p build/opt/devops/var/etcd
sudo chown root:root build/opt/devops/var/etcd
sudo chown -R root:root build/etc
sudo chmod +x build/etc/init.d/devops-etcd

echo "Fetching etcd version"
version=$(./build/opt/devops/bin/etcd -version | cut -f2 -d'v')
echo "Current etcd version: $version"
echo -n "Proceed with the package build? [Y/n] "
read confirm

if [ -z "$confirm" -o "$confirm" == 'y' -o "$confirm" == 'Y' ]; then
    echo "Setting up proper version in the control file"
    sed -i "s/^Version: /Version: $version/" build/DEBIAN/control
    dpkg-deb --build build/ devops-etcd_"$version"_amd64.deb
    if [ $? -eq 0 ]; then
        echo "Success - the deb package is available at ./devops-etcd_${version}_amd64.deb"
        sudo cp devops-etcd_"$version"_amd64.deb $INCOMING
        sudo chown debrepo. $INCOMING/devops-etcd_"$version"_amd64.deb
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
