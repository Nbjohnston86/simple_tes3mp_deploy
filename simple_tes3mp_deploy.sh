## If any error occurs that I haven't accounted for, stop
## Created using TES3MP Version 0.8.1
## Created under the assumption that the operating system is Ubuntu 22.04,
## Though this is likely to work with other versions, but not tested.
## Created with the assumption that you will run tes3mp using systemd
## Use at own risk, and be sure to ALWAYS READ THE SCRIPT. If you do not understand it,
## do not run it, or ask someone who does understand it to walk you through it.
## (This is similar to the warnings I've seen other linux users give, it's good advice in general)
## (Even though I made it, people can alter and repost this for malicious ends, so just be vigilant!)
## This script is loosely based upon the instructions here:
## https://steamcommunity.com/groups/mwmulti/discussions/1/133258092238983950/

## For the uninformed (like myself), this just makes it so any error will stop the script from continuing.
set -e

## Taken and altered from: https://stackoverflow.com/questions/64848619/how-to-check-if-user-has-sudo-privileges-inside-the-bash-script
## Perhaps overkill, but the original author of this script understands it better
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

## Possible improvements to the below section that I've been suggested:
## Check if parameter is a file using -f instead.
## Other possible ehancements: check if file is the appropriate type, too.

if [ -z "$1" ]
  then
    echo "Error: Needs tar'd and compressed server files location, relative to current working directory"
    isvalid=0
fi

if [ -z "$2" ]
  then
    echo "Error: Needs zipped Script file location, relative to current working directory"
    isvalid=0
fi

## Although, THIS parameter does not represent a file, so don't accidentally 'fix' this.

if [ -z "$3" ]
  then
    echo "Error: Needs user to create and assign files to"
    isvalid=0
fi

if [ $isvalid -eq 0 ]
  then
    echo "Errors found, stopping"
    exit 1
fi


##Lets name our variables and inputs, to reduce confusion

serverfiles="$1"
serverscriptFiles="$2"
tesUserName="$3"
serverDestination='/opt/TES3MP'
serverScriptDestination="$serverDestination/PluginExamples"
## Perhaps a bit awkward, but I'm just wanting to remove .zip from the end of the file name,
## Because the folder is going to be named after it, without .zip;
## This will make this work with any version of this script, unlike what I had previously.
## previous version of next line: coreScriptsExtractedFolderName='CoreScripts-0.8.1'
coreScriptsExtractedFolderName=`echo $serverscriptFiles | awk '{ print substr( $0, 1, length($0)-4 ) }'`
coreServerExtractedFolderName='TES3MP-server'
coreServeConfigFile="$serverDestination/tes3mp-server-default.cfg"
tes3mpServiceFile='tes3mp.service'
systemdLocation='/etc/systemd/system'

##Upon review of this script, the second parameter may be unnecessary for the server to run. 
## I was blindly following the original guide above, thinking it was important, 
## But comparing the files seemed to indicate that the modern scripts are included in tes3mp
## By default. Oh well, I put a lot of effort into getting this script as good as it is
## This is my first 'real' script, I'm just happy it works

## Currently this script makes the following assumptions:
## You are providing either the full, or appropriate relative paths
## and You are providing them in the right order.
## It assumes you are providing valid files, as well.
## This script does its actions -in place-, it will extract to its current dirrectory,
## Then it will attempt to move things and attempt to clean up after itself.
## This is intended to make it obvious where things are located if something gets screwed up

## Extract TES3MP files
echo "Extracting TES3MP files from given sources."
tar -xf $serverfiles

## Testing this script, I need to create the destination folder before moving to it. Oops.
mkdir $serverDestination

## As of the making of this script, I am using what is the default name of the folder
## To move it. If this changes, this script will need to be updated.
## The common place I've seen people put 'Universal' applications is /opt
## The original instructions put it in their home folder. I am blatantly ignoring that.
mv $coreServerExtractedFolderName/* $serverDestination

## Next, we extract the Scripts that were provided
## This is zipped, instead of TAR'd because CONSISTENCY!
## (I downloaded the git repo from github, and chose the zipped option, can I get it tar'd?)
unzip $serverscriptFiles

## Moving it to the server folder similar to the original instructions, but like above,
## It is located within the /opt folder
## I will follow the original example for the naming of this folder, in this case: PluginExamples
## Otherwise it will make the following the extra instructions more confusing than I want to deal with
## First, create the folder we're about to move to:
mkdir $serverScriptDestination

## Uhh, The extract zip file is the same name as the zip. 
## Can I use that to make this more multi-version friendly/compatible?
mv $coreScriptsExtractedFolderName/* $serverScriptDestination

## Cleanup, Cleanup
## Editing this script, because apparently .gitignore is not copied. Ugh.
## Previous line: rmdir $coreServerExtractedFolderName
## Previous line: rmdir $coreScriptsExtractedFolderName
echo "Cleaning up Extracted folders."
rm -rf $coreServerExtractedFolderName
rm -rf $coreScriptsExtractedFolderName
## Is it more dangerous this way? You absolutely have to specify a parameter at the top for it to get this far, though.

## Next we need to create the user that will run TES3MP, 
## Which in every other instruction guide I've seen was always touted as a good idea, 
## and an idea the original guide lacked. 
## I've decided to include this step into this script.
echo "Create $tesUserName user here."
useradd -m $tesUserName
## The -m is super important. In a previous version, I did not do this, and it broke the server

## Set up the service account's password
## I have mixed feelings about having a password, as I feel it'd be more secure if
## nobody could use this account except systemd... But then again if something
## goes wrong, it would need a password so a user could troubleshoot what's going wrong.
## Hard choices.
echo "Enter Password for $tesUserName:"
passwd $tesUserName

## The new user needs to own the files its using
chown $tesUserName:$tesUserName $serverDestination
chown -R $tesUserName:$tesUserName $serverDestination/*
## A previous version of this line was flawed, and did not give ownership to the user
## As a result, it would run, but no users could be created. Oops.

## Now for the tricky part, at this point the instructions are editing some configuration files
## I should probably include this, but I'm clumsy when it comes to that. Advice appreciated!
## default: home = ./server 
## Change to script folder: home = /opt/TES3MP/PluginExamples/scripts 
echo "Create TES3MP files here"

## I found a guide that says that said to use sed to edit a file, so let's try that.
sed -i "s+home = ./server+home = $serverScriptDestination+g" $coreServeConfigFile

## This section is responsible for creating the systemd file needed to run this as a service.
echo "Create SystemD service file here"

## Create line-by-line systemd file
echo "[Unit]" >> $tes3mpServiceFile
echo "Description=TES3MP Server" >> $tes3mpServiceFile
echo "" >> $tes3mpServiceFile
echo "[Service]" >> $tes3mpServiceFile
echo "WorkingDirectory=/opt/TES3MP/" >> $tes3mpServiceFile
echo "User=$tesUserName" >> $tes3mpServiceFile
echo "Group=$tesUserName" >> $tes3mpServiceFile
echo "Restart=always" >> $tes3mpServiceFile
echo "RemainAfterExit=yes" >> $tes3mpServiceFile
echo "" >> $tes3mpServiceFile
echo "ExecStart=/opt/TES3MP/tes3mp-server" >> $tes3mpServiceFile
echo "" >> $tes3mpServiceFile
echo "[Install]" >> $tes3mpServiceFile
echo "WantedBy=multi-user.target" >> $tes3mpServiceFile
echo "" >> $tes3mpServiceFile

## Move it to the systemd folder
mv $tes3mpServiceFile $systemdLocation

## Final Instructions to the user :D
echo "============================================================================================================="
echo "Basic Setup Complete, you may now turn the server on using:"
echo "sudo systemctl start $tes3mpServiceFile"
echo "This of course, requires sudo privileges, which you needed to run this file, so have fun!"
echo "Oh, and this script did NOT set the password to the server, to do that, go to:"
echo "$coreServeConfigFile"
echo "Open this file by using the text editor of your choice. If you're using Ubuntu, like me, I like to use gedit."
echo ""
echo "If you encounter issues after this, you may be lacking some important packages,"
echo "I installed them outside this script because I don't think this script should do that."
echo "The packages I had to install were: luajit liblua5.1 libluajit-5.1"
echo "And using Ubuntu (What I developed this script against), they can be installed with the following command:"
echo "sudo apt-get install luajit liblua5.1 libluajit-5.1"
echo "============================================================================================================="
