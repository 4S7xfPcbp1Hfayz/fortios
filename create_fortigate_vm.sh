#!/bin/bash

# Function to create and configure VM in Proxmox
create_vm() {
    local version=$1
    local version_formatted=$(echo $version | sed 's/-/./g')  # Format version with dots
    local qcow2_file="qcow2/FGT-VM64-KVM-$version.qcow2"
    local vm_name="FGT-VM64-KVM-$version_formatted"
    local vm_id=$(pvesh get /cluster/nextid)
    local disk_size=30  # Size of the additional disk in GB

    if [[ -f "$qcow2_file" ]]; then
        echo "Creating VM with ID $vm_id and name $vm_name"

        # Create VM
        qm create $vm_id --name $vm_name \
                         --memory 2048 \
                         --net0 virtio,bridge=vmbr2 \
                         --net1 virtio,bridge=vmbr2 \
                         --net2 virtio,bridge=vmbr3 \
                         --sockets 1 \
                         --cores 1 \
                         --cpu host \
                         --ostype l26

        # Import the primary disk
        qm importdisk $vm_id $qcow2_file local-lvm

        # Attach the primary disk to the VM
        qm set $vm_id --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-$vm_id-disk-0

        # Create a second disk of 30GB
        qm set $vm_id --scsihw virtio-scsi-pci --scsi1 local-lvm:30

        # Set bootdisk
        qm set $vm_id --boot c --bootdisk scsi0

        qm set $vm_id --tablet 0
        
        echo "VM $vm_name created with ID $vm_id"
    else
        echo "File $qcow2_file does not exist"
    fi
}

# Array of versions to create VMs for
#declare -a versions=("v7-4-1" "v7-4-2" "v7-4-3" "v7-4-4" "v7-6-0" "v7-2-8")
declare -a versions=("v7-4-4")

# Loop through the array and create VMs
for version in "${versions[@]}"; do
    create_vm "$version"
done
