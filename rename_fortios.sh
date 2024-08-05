#!/bin/bash

# Create the qcow2 directory if it doesn't exist
mkdir -p qcow2

# Function to extract and rename qcow2 files
extract_and_rename() {
    local zip_file=$1
    local version=$2

    # Check if the zip file exists
    if [[ -f "$zip_file" ]]; then
        # Extract the zip file
        unzip "$zip_file"
        
        # Check if the extraction was successful
        if [[ -f fortios.qcow2 ]]; then
            # Rename the extracted qcow2 file and move it to the qcow2 directory
            mv fortios.qcow2 "qcow2/FGT-VM64-KVM-$version.qcow2"
        else
            echo "Extraction failed or fortios.qcow2 not found for $zip_file"
        fi
    else
        echo "File $zip_file does not exist"
    fi
}

# Array of zip files and corresponding versions
declare -A files_and_versions=(
    ["FGT_VM64_KVM-v7.2.8.M-build1639-FORTINET.out.kvm.zip"]="v7-2-8"
    ["FGT_VM64_KVM-v7.4.1.F-build2463-FORTINET.out.kvm.zip"]="v7-4-1"
    ["FGT_VM64_KVM-v7.4.2.F-build2571-FORTINET.out.kvm.zip"]="v7-4-2"
    ["FGT_VM64_KVM-v7.4.3.F-build2573-FORTINET.out.kvm.zip"]="v7-4-3"
    ["FGT_VM64_KVM-v7.4.4.F-build2662-FORTINET.out.kvm.zip"]="v7-4-4"
    ["FGT_VM64_KVM-v7.6.0.F-build3401-FORTINET.out.kvm.zip"]="v7-6-0"
)

# Loop through the array and process each file
for zip_file in "${!files_and_versions[@]}"; do
    version=${files_and_versions[$zip_file]}
    extract_and_rename "$zip_file" "$version"
done
