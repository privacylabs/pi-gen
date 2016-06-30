#How to Build

To automate the process of generating an Oasis raspbian image a vagrant configuration is defined.  Install vagrant and virtual box and then do a 'vagrant up' in this directory.  The provisioning process will update the vm with the required dependencies and then run the build.sh script to generate teh image.  Upon completion of the vagrant provisioning process the image will be copied into the data directory.  After the copy has completed you can iss the 'vagrant destroy' command to tear down the vm.

#TODO

1. Image export
1. NOOBS export
1. Simplify running a single stage
1. Documentation

#Dependencies

`quilt kpartx realpath qemu-user-static debootstrap zerofree`
