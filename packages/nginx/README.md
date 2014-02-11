# Requirements

Nginx is currently built for individual ubuntu distributio, the build process need to occur in the various [chroot'ed environment](/docs/chroot.md).

### Nginx
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

Fetch gist from the above and update the header to match the version / maintainer, etc.

Run script. Several dependencies may be required to be installed - see output and install them (still in chroot environment); including:
- git
- other provided in the gist output

The packages will be available in the `/src` folder. Keep track of which ubuntu distribution they belong to! It will be required for the addition in the DEB repository.

