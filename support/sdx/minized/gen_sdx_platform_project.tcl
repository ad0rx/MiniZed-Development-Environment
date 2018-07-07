######################################################################
# Generated from email from Xilinx containing recommendation:
# RE: (SR#10436164) SDSoc SDx 2017.4 PetaLinux XC7Z007S Processor Instance DNE
# Please follow the below steps to create a platform using the DSA you have shared.
# 1.	Open SDx GUI. 
# 2.	Navigate to Window->Show View->XSCT.
# 3.	Run the below commands in the XSCT according to files location in your system:
# a.	platform -name {mz_stream} -hw { /10436164/mz_stream.dsa} -out {/10436164/temp02/platforms} -prebuilt;platform -write
# b.	platform -read { /10436164/temp02/platforms/mz_stream/platform.spr}
# c.	system -name {linux2} -display-name {linux} -desc {} -boot { /tmp/boot};boot -bif {/tmp/boot/bootgen.bif}
# d.	domain -name linux3 -os linux -proc ps7_cortexa9_0 -display-name test -runtime cpp -image /tmp/image
# e.	platform -write
# f.	platform generate
# 4.	Then add the platform located on temp02/platforms/mz_stream/export folder and create application on the top of that.
#
######################################################################
# Note that all commands appear to be undocumented, however some
# information available by running command in xsct: '% <COMMAND> help'
######################################################################

set PROJWS                 $::env(PROJWS)
set PROJ_HW_PROJECT_PATH   $::env(PROJ_HW_PROJECT_PATH)
set PROJ_PLNX_PROJECT_PATH $::env(PROJ_PLNX_PROJECT_PATH)

set platform_dir    "platform"
set platform_name   "mz_stream_petalinux"
set platform_domain "mz_stream_petalinux_domain"

exec rm -rf "$platform_dir"

# Platform name here must match the PFM_NAME when the platform was
# created in Vivado by the mz_stream_petalinux_pfm.tcl script
platform -name $platform_name -hw "$PROJ_HW_PROJECT_PATH/$platform_name.dsa" -out $platform_dir -prebuilt
platform -write
platform -read "$platform_dir/$platform_name/platform.spr"

system -name {linux2} -display-name {linux} -desc {} -boot "$PROJ_PLNX_PROJECT_PATH/sdx_minized/images/linux/boot"
boot -bif "$PROJ_PLNX_PROJECT_PATH/sdx_minized/images/linux/boot/sdx_pfm.bif"

domain -name linux3 -os linux -proc ps7_cortexa9_0 -display-name "$platform_domain" -runtime cpp -image "$PROJ_PLNX_PROJECT_PATH/sdx_minized/images/linux/image"

platform -write
platform -generate
