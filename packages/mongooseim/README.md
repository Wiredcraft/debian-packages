TODO

    - from `erlang` source + source patch
    - includes latest mongooseim + patch for hot vhost edition

# Start in a clean state - use a chroot environment

```
# Need to add apt universe for reltool
if [ $(grep -c universe /etc/apt/sources.list) -eq 0 ]; then
    sed -i 's/main$/main universe/' /etc/apt/sources.list
    apt-get update
fi

# Install required dependencies
apt-get install     \
    git             \
    gcc             \
    make            \
    libexpat1       \
    libexpat1-dev   \
    erlang-dev      \
    erlang-snmp     \
    erlang-eunit    \
    erlang-asn1     \
    erlang-reltool  \
    openssl         \
    libssl-dev      \
    libpam0g-dev    \
    zlib1g      

git clone https://github.com/snoopaloop/MongooseIM.git
git clone https://github.com/Wiredcraft/Octochat.git

# Copy custom files from octochat to mongoose source
cp -a Octochat/deps/ejabberd/src/mod_eventful.erl    MongooseIM/apps/ejabberd/src/
cp -a Octochat/deps/ejabberd/src/mod_roster_http.erl MongooseIM/apps/ejabberd/src/

# Build MongooseIM
cd MongooseIM
make rel
```

If everythign goes right, the files are in `rel/ejabberd/`

The build packages are standalones and embed the erlang VM. It does not add any init script