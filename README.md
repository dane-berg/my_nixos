## Installation
Install NixOS

[vimjoyer's guide](https://youtu.be/a67Sv4Mbxmc?si=49mqSaMg0ayrK5fF)

I also found [Why Does Nothing Work's guide](https://youtu.be/63sSGuclBn0?si=WdAuKiwzDZJWmqgV) to be helpful since I had never installed a new OS before.

Download the repo. It assumes that it exists at /etc/nixos/
```
cd /etc/nixos/
nix-shell -p git
git clone git@github.com:dane-berg/my_nixos.git
```

Move your auto-generated nix files to a directory just for your machine. I call my development machine erebus.
```
mkdir erebus/
mv configuration.nix erebus/
mv hardware-configuration.nix erebus/
```

Now update the configuration.
```
nano flake.nix
# set your system and the path to your configuration.nix.
let
  system = "x86_64-linux";
  ...
in
...
modules = [
  ./erebus/configuration.nix
  ...
];

nano erebus/configuration.nix
# import the core module
imports = [
  ./hardware-configuration.nix
  ../modules/core.nix
];
```

Rebuild your system.
```
sudo nixos-rebuild switch --flake /etc/nixos#default
```

Now setup a git repository to track your changes. Use the rebuild script to make edits, format your changes, rebuild your system, and commit the result all in a single command.
```
nixrb erebus/configuration.nix modules/home.nix # list any files you want to edit before rebuilding
```

You should experiment with importing additional modules and changing settings as you desire. 
Note: If you import the modules in this repo, you may need to edit references to the daneb user.

Enjoy the last system you will ever configure!
