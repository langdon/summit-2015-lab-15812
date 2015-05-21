#! /bin/bash

echo "ensure you have vagrant boxes called 'rhel-7.1' and 'rhel-atomic-host'"
echo "you also need qemu-img; e.g. yum install qemu-img"
echo "must be run with sudo"
#vagrant up
#vagrant halt

#figure out the virsh domain name of dev vm
NAME_OF_DEV=`virsh list --all | awk '{print $2}' | grep summit_rhel_dev`
echo "Dev virsh domain name: $NAME_OF_DEV"
virsh dumpxml $NAME_OF_DEV > summit_rhel_dev.xml

#figure out the virsh domain name of deploy vm
NAME_OF_DEPLOY=`virsh list --all | awk '{print $2}' | grep summit_rhel_deploy_target`
echo "Deploy virsh domain name: $NAME_OF_DEPLOY"
virsh dumpxml $NAME_OF_DEPLOY > summit_rhel_deploy_target.xml

#convert to qcow, rebase image for dev machine
IMAGE=`sed -e "s/.*'\(.*summit_rhel_dev.img\)'.*/\1/g" summit_rhel_dev.xml | grep img`
echo "Dev image name: $IMAGE; about to convert, might be awhile"
#qemu-img convert -O qcow2 $IMAGE ./summit_rhel_dev.qcow2
mv ./summit_rhel_dev.qcow2 /var/lib/libvirt/images/
echo "moving ./summit_rhel_dev.qcow2 /var/lib/libvirt/images/"

#convert to qcow, rebase image for deploy machine
IMAGE=`sed -e "s/.*'\(.*summit_rhel_deploy_target.img\)'.*/\1/g" summit_rhel_deploy_target.xml | grep img`
echo "Deploy image name: $IMAGE; about to convert, might be awhile"
#qemu-img convert -O qcow2 $IMAGE ./summit_rhel_deploy_target.qcow2
echo "moving ./summit_rhel_deploy_target.qcow2 /var/lib/libvirt/images/"
mv ./summit_rhel_deploy_target.qcow2 /var/lib/libvirt/images/

#fix up the xml to point to this new file
echo "this may be wrong if you dont use the default pool for your vms"
sed -ie "s|'\(.*summit_rhel_dev.img\)'|'/var/lib/libvirt/images/summit_rhel_dev.qcow2'|g" summit_rhel_dev.xml
sed -ie "s|'\(.*summit_rhel_deploy_target.img\)'|'/var/lib/libvirt/images/summit_rhel_deploy_target.qcow2'|g" summit_rhel_deploy_target.xml

#fix up the xml to point to the default network
echo "this may be wrong if you dont use the default network for your vms"
sed -ie "s|<source network='vagrant-libvirt'/>|<source network='default'/>|g" summit_rhel_dev.xml
sed -ie "s|<source network='vagrant-libvirt'/>|<source network='default'/>|g" summit_rhel_deploy_target.xml
