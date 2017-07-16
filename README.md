# update_vmdk

Ensure raw VMDK points to the intended disk

## Problem

On Windows, the Virtual Machine Disk (VMDK) files that VirtualBox uses for raw disk access depend on drive references by index, e.g., \\.\PhysicalDrive1. Unfortunately, these indices can change every time the drive configuration is updated. As a result, VirtualBox may give a VM raw access to the wrong disk. This is dangerous because mounting a drive simultaneously on the host and guest can result in file system corruption.

## Solution

This script updates VMDK files with the proper drive indices using a signature which is unique to each drive. In particular, this script
- Takes as input a file containing a list of vmdk template file names and drive signature pairs
- Deletes any existing VMDK's in the output directory
- For each input pair, the signature is used to identify the current drive location, and based on the corresponding template vmdk, a new vmdk is with the correct drive index is created in the output directory.

## Usage

To use the script, do the following
1. Generate VMDK's for any drives for which you want raw access using the method in the VirtualBox manual
2. Find the signatures for those drives. One way is to use the wmic tool. At the command prompt, run "wmic DISKDRIVE GET INDEX,SIGNATURE".  The index corresponds to the drive number. In my tests, the signature remains the same even if a drive is assigned a different number. I've even tried connecting via different interfaces (SATA and USB) and the signature correctly identifies the drive.
3. Create a text file which contains pairs of lines with the names of the VMDK files (without extension) and the corresponding drive signatures. An example drive list file might look like:
drive_a
18417
drive_b
19477
where the VMDK files are named "drive_a.vmdk" and "drive_b.vmdk" and are located in the templates directory.
4. Call the script with the following arguments: 
    - drive list path
    - template directory (should end with '\\')
    - output directory (should end with '\\')
