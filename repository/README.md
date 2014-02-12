# Repository management

Links:
- https://wiki.debian.org/SettingUpSignedAptRepositoryWithReprepro

## Setup
### Prepare APT repo owner on remote box

You do not want the regular user to be in charge of the repo, not do you want root

```bash
ssh repo_server
sudo useradd -m -s /bin/bash debrepo

# This should already be installed if using the devo.ps recipe...
apt-get install dpkg-sig reprepro gnupg gnupg-agent
```

### Prepare GPG key

http://www.debuntu.org/how-to-importexport-gpg-key-pair/

Running the GPG creation on the server can be tediously slow, so better to generate on the local box where a lot of entropy is available, then export / import on the remote box as described in the tutorial below.

```bash
# On MacOSX
brew install gpg

gpg --gen-key
# Fill all the required information
#  - use an admin account / email so you don't use your own name, etc.
# Ex.
#  - RSA + DSA -- 2048bits
#  - Real Name: Wiredcraft bot
#  - email: debbot@wiredcraft.com
#  - comment (optional): Wiredcraft APT Deb Bot
#
# Save the passphrase in Keepass

# Get key id
ID=$(gpg --list-keys wiredcraft | grep pub | awk '{print $2}' | cut -f2 -d'/')

# Export GPG key
gpg --output wcl-deb_pub.gpg --armor --export $ID
gpg --output wcl-deb_sec.gpg --armor --export-secret-key $ID

# Copy keys over to the repo server
scp -r wcl-deb*gpg wcl@repo:~/.

# Import GPG keys
ssh wcl@repo
sudo cp wcl-deb*gpg /home/debrepo
sudo su - debrepo

gpg --import ~/wcl-deb_pub.gpg
gpg --allow-secret-key-import --import ~/wcl-deb_sec.gpg

```

### Configure reprepo

```bash
sudo mkdir -p /var/www/repos/apt/ubuntu/conf

# Change ownership of the folder
sudo chown -R debrepo. /var/www/repos

# Fetch the key_id of the GPG key
KEY_ID=$(sudo -u debrepo -i bash -c "gpg --list-keys wiredcraft | grep sub | awk '{print \$2}' | cut -f2 -d'/'")

for osrelease in precise saucy raring
do
    echo "Adding distribution support for $osrelease"
    cat >> /var/www/repos/apt/ubuntu/conf/distributions << EOF
Origin: Wiredcraft
Label: Wiredcraft $osrelease Repository
Codename: $osrelease
Architectures: amd64
Components: main
Description: Apt repository for Wiredcraft and devo.ps projects
DebOverride: override.$osrelease
DscOverride: override.$osrelease
SignWith: $KEY_ID

EOF

    touch /var/www/repos/apt/ubuntu/conf/override.$osrelease

    # Prepare the source.list.d files
    cat > /var/www/repos/apt/ubuntu/repo_devo_ps_$osrelease.list << EOF
deb [amd64] http://repo.devo.ps/ubuntu $osrelease main
EOF

done

cat > /var/www/repos/apt/ubuntu/conf/options << EOF
verbose
basedir /var/www/repos/apt/ubuntu
ask-passphrase
EOF

# Prepare the key for the end user
sudo -u debrepo -i bash -c 'gpg --armor --output /home/debrepo/repo.devo.ps.gpg.key --export $KEY_ID'
sudo cp /home/debrepo/repo.devo.ps.gpg.key /var/www/repos/apt/ubuntu/

```

### Nginx configuration

```bash
apt-get install nginx

cat > /etc/nginx/conf.d/debrepo.conf << EOF
server {
    server_name repo.devo.ps;
    listen 80;

    location / {
        root /var/www/repos/apt;
        autoindex on;
    }

    location ~ ^/ubuntu/(db|conf|incoming)/(.*) {
        deny all;
    }
}
EOF

service nginx restart
```

## Package management




How to sign and add the packages: 

```bash
# Get as debrepo
sudo su - debrepo

# To avoid having to enter the passphrase 1 million times, you can use gpg-agent
eval $(gpg-agent --daemon)

# Get the key ID from the GPG KEY
KEY_ID=$(gpg --list-keys wiredcraft | grep sub | awk '{print $2}' | cut -f2 -d'/')

# Sign the package (if required) - you may be required to enter the GPG passphrase
dpkg-sig -k $KEY_ID --sign builder your_packages_<version>_<architecture>.deb
```

Add any extra metadata in the `/var/www/repos/apt/ubuntu/conf/override.<osrelease>` (optional)
Make sure you apply it to all the osreleases currently supported ...

The format is the following: 

```
your_package_name Priority        optional
your_package_name Section         net
...
```

Finally add the package to the correct repo:

```bash
reprepro includedeb <osrelease> <debfile>

# ex. for files being in the deb folder - for saucy osrelease, with deb files having a '+saucy' package tag
# reprepro includedeb saucy incoming/*+saucy*deb
```