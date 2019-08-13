#!/bin/sh

### This Script attempts to update Minecraft to the latest version of Forge and Minecraft
### Its meant to simplify the process - not to be run as a cron job.
### If you supply a minecraft version number on the command line, it will download that version
### instead of the latest.   This is necessary when a new version comes out but there is no
### corresponding forge



# Check if there is a Java Process with forge running.  
# If so, get its Process ID and send a hangup signal to it.

PROCESSID=`ps a | grep "java[\ A-Za-z0-9-]*forge\.jar" | cut -b 1-5`
if [ -n "${PROCESSID}" ]
then
  echo "Sending Minecraft Server a HUP"
  kill -HUP ${PROCESSID}
fi

# Contact Minecraft and Forge websites, extract out the download path of each of the files
# Put everything into Variables to use later

WGET="wget -q --no-check-certificate"
MINECRAFT_DL=`${WGET} -O - https://minecraft.net/download | grep -o "https://[A-Za-z0-9\._/~%\-\+\#\?!=\(\)@]*minecraft_server\.[[:digit:]]\.[0-9]*\.[0-9]*\.jar"`
LATEST_VERSION=`echo ${MINECRAFT_DL} | grep -o "[[:digit:]]\.[0-9]*\.[0-9]" | head -n 1`
if [ -n "$1" ]
then
  MINECRAFT_DL=`echo ${MINECRAFT_DL} | sed s/${LATEST_VERSION}/${1}/g`
fi
MINECRAFT_FILE=`echo ${MINECRAFT_DL} | grep -o "minecraft_server[\.0-9]*\.jar"`
FORGE_DL=`${WGET} -O - http://files.minecraftforge.net/minecraftforge/ | grep -o "http://[A-Za-z0-9\._/-]*minecraftforge-universal-[0-9\.-]*\.jar" | head -n 1`
FORGEINSTALLER_DL=`${WGET} -O - http://files.minecraftforge.net/minecraftforge/ | grep -o "http://[A-Za-z0-9\._/-]*minecraftforge-installer-[0-9\.-]*\.jar" | head -n 1`
FORGE_FILE=`echo ${FORGE_DL} | grep -o "minecraftforge-universal-[0-9\.-]*\.jar"`
INSTALLER_FILE=`echo ${FORGEINSTALLER_DL} | grep -o "minecraftforge-installer-[0-9\.-]*\.jar"`

echo "--------------------------------------------"
echo "LATEST MINECRAFT VERSION: ${LATEST_VERSION}"
echo "MINECRAFT_DL: ${MINECRAFT_DL}"
echo "FORGE_DL: ${FORGE_DL}"
echo "INSTALLER_DL: ${FORGEINSTALLER_DL}"
echo "FORGE_FILE: ${FORGE_FILE}"
echo "INSTALLER: ${INSTALLER_FILE}"
echo "--------------------------------------------"
echo -n

echo "Removing Old Files ..."
rm -f minecraft_server*.ja*
rm -f minecraftforge-universal*.ja*
rm -f minecraftforge-installer*.ja*
rm minecraft_server.jar
rm forge.jar
rm -rf ./libraries
echo "Downloading Minecraft: ${MINECRAFT_FILE}"
${WGET} $MINECRAFT_DL
echo "Downloading Forge: ${FORGE_FILE}"
# Do an Adf.ly request using Forge's ID so they don't get ripped off with us bypassing it
${WGET} -O - http://adf.ly/673885/${FORGE_DL} > adf.ly
${WGET} $FORGE_DL
echo "Downloading Forge Installer: ${INSTALLER_FILE}"
${WGET} $FORGEINSTALLER_DL
echo -n
echo "Running Installer (Extracting Libraries) ..."
java -jar ${INSTALLER_FILE} --installServer > forgeinstaller.log
rm ${INSTALLER_FILE}
echo "Setting up Symbolic Links"
ln -s $MINECRAFT_FILE minecraft_server.jar
ln -s $FORGE_FILE forge.jar