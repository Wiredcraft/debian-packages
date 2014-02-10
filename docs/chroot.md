# Debian Package management

## Purpose

Wiredcraft maintains a few `.deb` packages in order to provide additional features to its products / services. The purpose of this page is to provide the guidelines to:
- maintain / create / update existing packages, including:
    - build environment for various ubuntu distributions (precise, saucy, raring, etc.)
    - build instructions
    - spec file

- maintain / create / update existing repository, including:
    - how to add new packages
    - how to maintain several 

## Package management

### Build environment preparation
To build packages for the various ubuntu distribution in a clean manner (no old installed packages), one need to prepare minimal setup of the distribution

Prepare the minimal version of the distribution, replace `precise` by `saucy` / `raring` / etc. And set the default locales to english.

```bash
# Install the build packages
sudo apt-get install packaging-dev debootstrap
# Prepare the base chroot
sudo debootstrap precise precise_chroot
# Access the minimal environment
sudo chroot precise_chroot
# Set the locale to en_US.UTF-8
locale-gen en_US.UTF-8 && echo LC_ALL="en_US.UTF-8" >> /etc/default/locale
# Exit chroot
exit
```

Since the setup can take a while (a lot of packages need to be retrieved), you better perform a backup of the original chroot'ed environment that you will be able to re-use later on.

```bash
mkdir chroot_templates
sudo cp -a *_chroot chroot_templates
```

To access each of the environment, run the following command; replace by the appropriate chroot folder

```bash
sudo chroot precise_chroot
```

Then you can proceed with the build of the various packages.

The short approach would be to use the devops/ yaml definition of the server to get a fully up and running environement in minutes.
