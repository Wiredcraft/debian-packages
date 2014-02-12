# Requirements

Nginx is currently built for individual ubuntu distributio, the build process need to occur in the various [chroot'ed environment](/docs/chroot.md).

## Install PPA for source package
Details:
- from deb source package + patch
- includes LUA support + latest version (web-socket support)

Source:
- http://chairnerd.seatgeek.com/oauth-support-for-nginx-with-lua/
- https://gist.github.com/josegonzalez/4126937 
- https://gist.github.com/hajdbo/5526788 -- included list of dependencies
- https://gist.github.com/zbal/8778973

Add PPA (in chroot)
```bash
apt-get install python-software-properties # Precise only
# Or
apt-get install software-properties-common

add-apt-repository ppa:nginx/stable 
# Ensure the source repo is un-commented
sed -i 's/^#//g' /etc/apt/sources.list.d/nginx*
apt-get update
```

## Run rebuild

Fetch gist from the above and update the header to match the version / maintainer, etc.
Run script. Several dependencies may be required to be installed - see output and install them (still in chroot environment); including:
- git
- other provided in the gist output

The packages will be available in the `/src` folder. Keep track of which ubuntu distribution they belong to! It will be required for the addition in the DEB repository.

```bash
# Install required dependencies
apt-get install git wget 

# Fetch gist
wget -O /build_nginx_gist.tar.gz https://gist.github.com/zbal/8778973/download
tar --wildcards -xzvf /build_nginx_gist.tar.gz */nginx_release.sh -O > /nginx_build_lua.sh

# Update build script with proper RELEASE details
sed -i 's/^RELEASE_MAINTAINER=/RELEASE_MAINTAINER="Wiredcraft"/' /nginx_build_lua.sh
sed -i 's/^RELEASE_MAINTAINER_EMAIL=/RELEASE_MAINTAINER_EMAIL="debbot@wiredcraft.com"/' /nginx_build_lua.sh

# Run script
cd /
bash nginx_build_lua.sh
```

## Add to APT repo

Copy the generated files from /src to the repo.devo.ps server, then sign and add them to the repo via the `reprepro` command, making sure to add the package to the correct release (precise, raring, saucy) - see the details in the `repository/README.md` file.