# DisplayName: Jolla vayu/@ARCH@ (release) 1
# KickstartType: release
# DeviceModel: vayu
# DeviceVariant: vayu
# Brand: Jolla
# SuggestedImageType: fs
# SuggestedArchitecture: aarch64

timezone --utc UTC

### Commands from /tmp/sandbox/usr/share/ssu/kickstart/part/default
part / --size 500 --ondisk sda --fstype=ext4

## No suitable configuration found in /tmp/sandbox/usr/share/ssu/kickstart/bootloader

repo --name=adaptation-common-vayu-@RELEASE@ --baseurl=https://releases.jolla.com/releases/@RELEASE@/jolla-hw/adaptation-common/@ARCH@/
repo --name=adaptation0-vayu-@RELEASE@ --baseurl=https://sailfishos-vayu.github.io/repo/@RELEASE@/vayu/repo/
repo --name=apps-@RELEASE@ --baseurl=https://releases.jolla.com/jolla-apps/@RELEASE@/@ARCH@/
repo --name=custom-repo-@RELEASE@ --baseurl=https://sailfishos-vayu.github.io/repo/custom-repo/repo/
repo --name=customer-jolla-@RELEASE@ --baseurl=https://releases.jolla.com/features/@RELEASE@/customers/jolla/@ARCH@/
repo --name=hotfixes-@RELEASE@ --baseurl=https://releases.jolla.com/releases/@RELEASE@/hotfixes/@ARCH@/
repo --name=jolla-@RELEASE@ --baseurl=https://releases.jolla.com/releases/@RELEASE@/jolla/@ARCH@/

%packages
patterns-sailfish-device-configuration-vayu
%end

%attachment
### Commands from /tmp/sandbox/usr/share/ssu/kickstart/attachment/vayu
/boot/hybris-boot.img
/boot/hybris-updater-script
/boot/hybris-updater-unpack.sh
/boot/update-binary

%end

%pre --erroronfail
export SSU_RELEASE_TYPE=release
### begin 01_init
touch $INSTALL_ROOT/.bootstrap
### end 01_init
%end

%post --erroronfail
export SSU_RELEASE_TYPE=release
### begin 01_arch-hack
if [ "@ARCH@" == armv7hl ] || [ "@ARCH@" == armv7tnhl ] || [ "@ARCH@" == aarch64 ]; then
    # Without this line the rpm does not get the architecture right.
    echo -n "@ARCH@-meego-linux" > /etc/rpm/platform

    # Also libzypp has problems in autodetecting the architecture so we force tha as well.
    # https://bugs.meego.com/show_bug.cgi?id=11484
    echo "arch = @ARCH@" >> /etc/zypp/zypp.conf
fi
### end 01_arch-hack
### begin 01_rpm-rebuilddb
# Rebuild db using target's rpm
echo -n "Rebuilding db using target rpm.."
rm -f /var/lib/rpm/__db*
rpm --rebuilddb
echo "done"
### end 01_rpm-rebuilddb
### begin 50_oneshot
# exit boostrap mode
rm -f /.bootstrap

# export some important variables until there's a better solution
export LANG=en_US.UTF-8
export LC_COLLATE=en_US.UTF-8

# run the oneshot triggers for root and first user uid
UID_MIN=$(grep "^UID_MIN" /etc/login.defs |  tr -s " " | cut -d " " -f2)
DEVICEUSER=`getent passwd $UID_MIN | sed 's/:.*//'`

if [ -x /usr/bin/oneshot ]; then
   /usr/bin/oneshot --mic
   su -c "/usr/bin/oneshot --mic" $DEVICEUSER
fi
### end 50_oneshot
### begin 60_ssu
if [ "$SSU_RELEASE_TYPE" = "rnd" ]; then
    [ -n "@RNDRELEASE@" ] && ssu release -r @RNDRELEASE@
    [ -n "@RNDFLAVOUR@" ] && ssu flavour @RNDFLAVOUR@
    # RELEASE is reused in RND setups with parallel release structures
    # this makes sure that an image created from such a structure updates from there
    [ -n "@RELEASE@" ] && ssu set update-version @RELEASE@
    ssu mode 2
else
    [ -n "@RELEASE@" ] && ssu release @RELEASE@
    ssu mode 4
fi
### end 60_ssu
### begin 70_sdk-domain

export SSU_DOMAIN=@RNDFLAVOUR@

if [ "$SSU_RELEASE_TYPE" = "release" ] && [[ "$SSU_DOMAIN" = "public-sdk" ]];
then
    ssu domain sailfish
fi
### end 70_sdk-domain
### begin 90_accept_unsigned_packages
sed -i /etc/zypp/zypp.conf \
    -e '/^# pkg_gpgcheck =/ c \
# Modified by kickstart. See sdk-configs sources\
pkg_gpgcheck = off
'
### end 90_accept_unsigned_packages
### begin 90_zypper_skip_check_access_deleted
sed -i /etc/zypp/zypper.conf \
    -e '/^# *psCheckAccessDeleted =/ c \
# Modified by kickstart. See sdk-configs sources\
psCheckAccessDeleted = no
'
### end 90_zypper_skip_check_access_deleted
%end

%post --nochroot --erroronfail
export SSU_RELEASE_TYPE=release
### begin 50_os-release
(
CUSTOMERS=$(find $INSTALL_ROOT/usr/share/ssu/features.d -name 'customer-*.ini' \
    |xargs --no-run-if-empty sed -n 's/^name[[:space:]]*=[[:space:]]*//p')

cat $INSTALL_ROOT/etc/os-release
echo "SAILFISH_CUSTOMER=\"${CUSTOMERS//$'\n'/ }\""
) > $IMG_OUT_DIR/os-release
### end 50_os-release
### begin 99_check_shadow
IS_BAD=0

echo "Checking that no user has password set in /etc/shadow."
# This grep prints users that have password set, normally nothing
if grep -vE '^[^:]+:[*!]{1,2}:' $INSTALL_ROOT/etc/shadow
then
    echo "A USER HAS PASSWORD SET! THE IMAGE IS NOT SAFE!"
    IS_BAD=1
fi

# Checking that all users use shadow in passwd,
# if they weren't the check above would be useless
if grep -vE '^[^:]+:x:' $INSTALL_ROOT/etc/passwd
then
    echo "BAD PASSWORD IN /etc/passwd! THE IMAGE IS NOT SAFE!"
    IS_BAD=1
fi

# Fail image build if checks fail
[ $IS_BAD -eq 0 ] && echo "No passwords set, good." || exit 1
### end 99_check_shadow
%end

%pack --erroronfail
export SSU_RELEASE_TYPE=release
### begin hybris
pushd $IMG_OUT_DIR # ./sfe-$DEVICE-$RELEASE_ID

DEVICE=vayu
EXTRA_NAME=@EXTRA_NAME@
DATE=$(date +"%Y%m%d") # 20191101

# Source release info e.g. VERSION
source ./os-release

# Locate rootfs .tar.bz2 archive
for filename in *.tar.bz2; do
	GEN_IMG_BASE=$(basename $filename .tar.bz2) # sfe-$DEVICE-3.2.0.12
done
if [ ! -e "$GEN_IMG_BASE.tar.bz2" ]; then
	echo "[hybris-installer] No rootfs archive found, exiting..."
	exit 1
fi

for bootname in *.img; do
	GEN_BOOT_IMG=$(basename $bootname .img) # hybris-boot.img
done

# Make sure we have 'bc' to estimate rootfs size
zypper --non-interactive in bc &> /dev/null

# Roughly estimate the final rootfs size when installed
IMAGE_SIZE=`echo "scale=2; 2.25 * $(du -h $GEN_IMG_BASE.tar.bz2 | cut -d'M' -f1)" | bc`
echo "[hybris-installer] Estimated rootfs size when installed: ${IMAGE_SIZE}M"

# Output filenames
DST_IMG=sfos-rootfs.tar.bz2
DST_PKG=$ID-$VERSION_ID-$DATE-$DEVICE$EXTRA_NAME # sailfishos-3.2.0.12-20191101-$DEVICE

# Clone hybris-installer if not preset (e.g. porters-ci build env)
if [ ! -d ../hybris/hybris-installer/ ]; then
	git clone --depth 1 https://github.com/SailfishOS-vayu/hybris-installer ../hybris/hybris-installer > /dev/null
fi

# Copy rootfs & hybris-installer scripts into updater .zip tree
mkdir updater/
mv $GEN_IMG_BASE.tar.bz2 updater/$DST_IMG
cp -r ../hybris/hybris-installer/hybris-installer/* updater/
cp $GEN_BOOT_IMG.img updater/$GEN_BOOT_IMG.img

# Update install script with image details
LOS_VER="18.1"
sed -e "s/%DEVICE%/$DEVICE/g" -e "s/%VERSION%/$VERSION/g" -e "s/%VERSION_ID%/$VERSION_ID/g" -e "s/%DATE%/$DATE/g" -e "s/%IMAGE_SIZE%/${IMAGE_SIZE}M/g" -e "s/%DST_PKG%/$DST_PKG/g" -e "s/%LOS_VER%/$LOS_VER/g" -i updater/META-INF/com/google/android/update-binary

# Pack updater .zip
pushd updater # sfe-$DEVICE-$RELEASE_ID/updater
echo "[hybris-installer] Creating package '$DST_PKG.zip'..."
zip -r ../$DST_PKG.zip .
mv $DST_IMG ../$GEN_IMG_BASE.tar.bz2
popd # sfe-$DEVICE-$RELEASE_ID

# Clean up working directory
rm -rf updater/

# Calculate some checksums for the generated zip
printf "[hybris-installer] Calculating MD5, SHA1 & SHA256 checksums for '$DST_PKG.zip'..."
md5sum $DST_PKG.zip > $DST_PKG.zip.md5sum
#sha1sum $DST_PKG.zip > $DST_PKG.zip.sha1sum
#sha256sum $DST_PKG.zip > $DST_PKG.zip.sha256sum
echo " DONE!"

popd # hadk source tree
### end hybris
%end

