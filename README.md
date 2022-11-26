# simple_tes3mp_deploy

With thanks to the [original installation guide](https://steamcommunity.com/groups/mwmulti/discussions/1/133258092238983950/) that inspired this script.

I have created an install script script for linux to make creating your own TES3MP server a much easier, quicker, and more secure process.
This script essentially, decompresses the server files, moves them to `/opt/`, creates a tes3mp-specific user to isolate it from the rest of the OS, and the runs it using systemd.
I created and tested this script using Ubuntu 22.04 ; It may work for other versions, but this is the one I used it for.
Use at your own risk, and be sure to ALWAYS READ THE SCRIPT. 
If you do not understand it, do not run it, or ask someone who does understand it to walk you through it.
I understand the irony of making a script to make it easier, then telling you not to run it if you don't understand it, but I am putting this on a public repo, so if something's fishy, someone should be able to sus it out (I hope).
Just do your due diligence, is all I'm saying.
That being said... here's how to use it.

## How to use it

For this, you will need to download a few files.
As was the case in the original instructions that inspired this one:
Grab the [latest stable binaries.](https://github.com/TES3MP/TES3MP/releases)
The one you will need will depend on architecture of your CPU.
Most computers (like mine) will need the `tes3mp-server-GNU+Linux-x86_64` binaries.
There is an alternative for ARM machines (Like the raspberry pi) will need the `tes3mp-server-GNU+Linux-armv7l` binaries.

Also (Following the other guide), you will need the [server management scripts listed in the PluginExample repository.](https://github.com/TES3MP/CoreScripts)
To use this script, download the code as a zip file. (It's a green button that says Code. click it, then click Download ZIP

Create a directory somewhere you feel comfortable, place both of these files into this directory, and then copy the file `simple_tes3mp_deploy.sh` to it.

Make `simple_tes3mp_deploy.sh` executable. 
While still in that folder, execute the command by supplying these parameters: The first parameter is the .tar.gz file, the second is the .zip file, and the third is the username of the user account that will be created to host the server.
To execute it, it will be used in the format:
``` 
sudo ./simple_tes3mp_deploy.sh <tar.gz file> <zip file> <username>
```
As an example, I will provide what I used to test this script:
```
sudo ./simple_tes3mp_deploy.sh tes3mp-server-GNU+Linux-x86_64-release-0.8.1-68954091c5-6da3fdea59.tar.gz CoreScripts-0.8.1.zip tes3mpuser
```
    
If all goes well, you should have a usable tes3mp on your server. You can start it by running the command:
```
sudo systemctl start tes3mp.service
```

There you go, have fun!

Note: double check your dependencies if it does not work! I had to run:
```
sudo apt-get install luajit liblua5.1 libluajit-5.1
```

Note: log files are saved in the created user name's home directory under `.config/openmw`

If all else fails, log in as the user to run the application to get the full error details:
```
su tes3mpuser
/opt/TES3MP/tes3mp-server
```

## Special Thanks

Thanks to PriestOfIlunibi, skoomabreath, and _Bizz for helping me understand what I was doing wrong, as well as encouraging me to create this repo.
