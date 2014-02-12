# devops-etcd

Relies on https://github.com/coreos/etcd

Used for var sharing across the various hosts of a devops repo.

# Build instruction

## Build binary

Perform the following in a clean environment (chroot). The generated binary will be working on all ubuntu versions, no need to build for each individual distribution.

Install `go` as follow:

- check http://golang.org/doc/install
- https://code.google.com/p/go/downloads/detail?name=go1.2.linux-amd64.tar.gz&can=2&q=

```bash 
sudo apt-get install wget git
wget --no-check-certificate https://go.googlecode.com/files/go1.2.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.2.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile
source /etc/profile
```

Then build / compile etcd.

```bash
git clone https://github.com/coreos/etcd
cd etcd
./build
```

Then build / compile etcdctl.

```bash
git clone https://github.com/coreos/etcdctl
cd etcdctl
./build
```

## Build package

Copy both binary (etcd/etcdctl) from their respective `./bin` folders to the `opt/devops/bin` folder.

Update the `build/DEBIAN/control` file to put the correct version (get it from `opt/devops/bin/etcd -version`)

Run the following command:

```bash
# You need to be at the root of this repo, replace VERSION by the version...
dpkg-deb --build build/ devops-etcd_VERSION_amd64.deb
```

## Add package to .deb repository

Copy the generated file in repo.devo.ps in `/var/www/repos/apt/ubuntu/incoming` and change the ownership to `debrepo`.
Then sign and add to the APT repo by following the details in `repository/README.md`

etcd being a go based project, the binary is compatible on all versions of Ubuntu (and Linux in general). You can use the same package in all the distributions and simply need to add the package via `reprepro includedeb <osrelease> devops-etcd_VERSION_amd64.deb`.