## I don't know if scripts need licenses, but just in case, MIT Licensed.
## This script is to delete the server and service created by the previous script
## Only use it if you used the script that is alongside this one, 
## If you don't know what that is: DO NOT RUN THIS SCRIPT
## Use at own risk, and be sure to ALWAYS READ THE SCRIPT. If you do not understand it,
## Do not run it, or ask someone who does understand it to walk you through it.
## (This is similar to the warnings I've seen other linux users give, it's good advice in general)
## (Even though I made it, people can alter and repost this for malicious ends, so just be vigilant!)

#############################################
## THIS DOES NOT BACK UP ANY OF YOUR DATA  ##
## YOU WILL LOSE YOUR CONFIG AND SAVE DATA ##
#############################################

## Using from the previous script:

set -e

## Taken and altered from: https://stackoverflow.com/questions/64848619/how-to-check-if-user-has-sudo-privileges-inside-the-bash-script

is_sudoer() {
    ## Define error code
    E_NOTROOT=87 # Non-root exit error.

    ## check if is sudoer
    if [ "$EUID" -ne 0 ]
      then
        echo 'Error: root privileges are needed to run this script'
        return $E_NOTROOT
    fi
    ## Normally when I think of things logically, 0 is false, but this is linux land, so 0 is the GOOD return code
    return  0
}

## But then again, I'm a programmer at heart, and I just want positive numbers to be TRUE. Oh no
isvalid=1

if is_sudoer; then
  echo "sudo privileges found"
else
  echo "Error: Run as sudoer"
  isvalid=0
fi

if [ -z "$1" ]
  then
    echo "Error: Needs TES3MP username to remove it."
    isvalid=0
fi

if [ $isvalid -eq 0 ]
  then
    echo "Errors found, stopping"
    exit 1
fi

#name our variable names again
tesUserName="$1"
serverDestination='/opt/TES3MP'
systemdLocation='/etc/systemd/system'
tes3mpServiceFile='tes3mp.service'
systemdTesFileLocation="$systemdLocation/$tes3mpServiceFile"

echo "Stopping TES3MP"
systemctl stop $tes3mpServiceFile
echo "Deleteing TE3MP local files"
rm -rf $serverDestination
echo "Deleteing TE3MP user"
userdel $tesUserName
echo "Deleteing TE3MP systemd record"
rm -f $systemdTesFileLocation
