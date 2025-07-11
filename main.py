#!/usr/bin/python3
import math
import os
import sys
import argparse
import subprocess
def startfunction():
    arguments()
    checkRoot()
    getDevSize()
    if crypt:
        partitonVariables()
        mkcrypt()
    else:
        nocrypt()
    MainInstall()
def partitonVariables():
    global crypt
    global swapPartSize
    global homeDirSource
    global homePartSize
    global rootPartSize
    global devName
    global devSizeGB
    global devSize
    global countParts
    global mountPoint
    if mountPoint is None:
        mountPoint = '/mnt/newsystem'
    elif mountPoint.endswith('/'):
        mountPoint = mountPoint.rstrip('/')
    devSizeGB = round(devSize / 1000000000)
    devSize = devSize / 1024
    devSize = devSize / 1024
    devSize = devSize / 1024
    devSize = math.floor(devSize)
    countParts = 0
    countETL = 0
    if homePartSize is None:
        homePartSize = 0
    elif homePartSize == 'ETL':
        countETL = countETL + 1
    else:
        countParts = countParts + 1
    if rootPartSize is None:
        rootPartSize = 0
        print('Root Partition Size cannot be 0 ! Exiting ...')
        exit()
        countParts = countParts + 1
    elif rootPartSize == 'ETL':
        countETL = countETL + 1
    else:
        countParts = countParts + 1
    if swapPartSize is None:
        swapPartSize = 0
        countParts = countParts + 1
    elif swapPartSize == 'ETL':
        countETL = countETL + 1
    else:
        countParts = countParts + 1
    if countParts >= 2 and countETL != 1:
        print("One of the Partitions has to be \"ETL\" (Every Thing Left), as there is now reliable way of determiting the lvm size.")
        exit()
    try:
        if swapPartSize != 'ETL':
            swapPartSize = int(swapPartSize)
            swapPartSizevar = int(swapPartSize)
        else:
            swapPartSizevar = 0 
        if homePartSize != 'ETL':
            homePartSize = int(homePartSize)
            homePartSizevar = int(swapPartSize)
        else:
            homePartSizevar = 0 
        if rootPartSize != 'ETL':
            rootPartSize = int(rootPartSize)
            rootPartSizevar = int(swapPartSize)
        else:
            rootPartSizevar = 0 
    except ValueError:
        print("Enter a vaild integer as the partition size, without GB at the end!")
        exit()
    if swapPartSizevar + homePartSizevar + rootPartSizevar > devSize:
        print('Not enough space on device!')
    if rootPartSize == 0:
        rootPartSize = 'ZERO'
    if homePartSize == 0:
        homePartSize = 'ZERO'
    if swapPartSize == 0:
        swapPartSize = 'ZERO'
def MainInstall():
    print('Installing base package ...')
    subprocess.run(['/opt/ArchInstall/baseInstallPac.sh', str(mountPoint)])
    configureFstab()
    configureGrub()
    configureInitramfs()
    global username
    global executable
    global homeDirSource
    if username is None:
        username = 'ZERO'
    if homeDirSource is None:
        homeDirSource = 'ZERO'
    elif not homeDirSource.endswith('/'):
        homeDirSource = homeDirSource + '/'
    if executable is None:
        executable = 'ZERO'
    subprocess.run(['/opt/ArchInstall/ArchChroot.sh', str(mountPoint), str(keymap), str(hostname), str(username), str(homeDirSource), str(close), str(vgName), str(cryptPartName), str(executable)])
def configureInitramfs():
    if crypt:
        subprocess.run(['/opt/ArchInstall/InitramfsCrypt.sh', str(mountPoint), str(lvmVar)])
def configureGrub():
    if crypt:
        subprocess.run(['/opt/ArchInstall/grubCrypt.sh', str(devName), str(cryptPartName), str(vgName), str(lvmVar), str(mountPoint)])
    else:
        subprocess.run(['/opt/ArchInstall/grubNoCrypt.sh', str(mountPoint)])
def configureFstab():
    if crypt:
        subprocess.run(['/opt/ArchInstall/fstabCrypt.sh', str(vgName), str(devName), str(mountPoint), str(homePartSize), str(swapPartSize)])
    else:
        if homePartSize is None:
            swapPartNID = '3'
        elif homePartSize == 0 or homePartSize == 'ZERO':
            swapPartNID = '3'
        else:
            swapPartNID = '4'
        if swapPartSize is None:
            swapPartNID = '0'
        elif swapPartSize == 0 or swapPartSize == 'ZERO':
            swapPartNID = '0'
        subprocess.run(['/opt/ArchInstall/fstabNoCrypt.sh', str(mountPoint), str(devName), str(swapPartNID)])
def nocrypt():
    global crypt
    global swapPartSize
    global homeDirSource
    global homePartSize
    global rootPartSize
    global devName
    global devSizeGB
    global devSize
    global countParts
    devSizeGB = round(devSize / 1000000000)
    devSize = devSize / 1024
    devSize = devSize / 1024
    devSize = devSize / 1024
    devSize = math.floor(devSize)
    swapPartSizeA = swapPartSize
    homePartSizeA = homePartSize
    rootPartSizeA = rootPartSize
    countETLA = 0
    if rootPartSizeA is None:
        rootPartSizeA = 'ETL'
        rootPartCalc = 0
        countETLA = countETLA + 1
    elif rootPartSizeA == 'ETL':
        countETLA = countETLA + 1
        rootPartCalc = 0
    else:
        rootPartCalc = rootPartSizeA
    if homePartSizeA is None:
        homePartSizeA = 0
        homePartCalc = 0
    elif homePartSizeA == 'ETL':
        countETLA = countETLA + 1
        homePartCalc = 0
    else:
        homePartCalc = homePartSizeA
    if swapPartSizeA is None:
        swapPartSizeA = 0
        swapPartCalc = 0
    elif swapPartSizeA == 'ETL':
        countETLA = countETLA + 1
        swapPartCalc = 0
    else:
        swapPartCalc = swapPartSizeA
    if countETLA != 1:
        print('There are either too many or not enough ETL\'s, there has to be exactly one! So either specify the root Partition Size or use one less ETL')
        exit()
    try:
        allParts = int(rootPartCalc) + int(homePartCalc) + int(swapPartCalc)
    except ValueError:
        print('ERROR: 2')
        exit()
    if allParts > devSizeGB:
        print('Partitions can\'t be bigger than the device itself! exiting ...')
        exit()
    print('Making Partitions ...')
    subprocess.run(['/opt/ArchInstall/noCryptParted.sh', str(devSizeGB), str(devName), str(rootPartSizeA), str(homePartSizeA), str(swapPartSizeA), str(mountPoint)])
def mkcrypt():
    global lvmVar
    print('Making Partitions ...')
    if countParts == 1:
        MainPartName = 'root'
    else:
        MainPartName = 'crypt'
    subprocess.run(['/opt/ArchInstall/cryptParted.sh', str(devSizeGB), str(devName), str(MainPartName)])
    print('Formating Partitions ...')
    subprocess.run(['/opt/ArchInstall/cryptMKFS.sh', str(devName), str(mountPoint)])
    subprocess.run(['/opt/ArchInstall/openLuks.sh', str(devName), str(cryptPartName)])
    if countParts == 1 :
        lvmVar = "False"
        subprocess.run(['/opt/ArchInstall/cryptNoLvm.sh', str(cryptPartName), str(mountPoint)])
    else:
        lvmVar = "True" 
        subprocess.run(['/opt/ArchInstall/cryptLvm.sh', str(cryptPartName), str(rootPartSize), str(homePartSize), str(swapPartSize), str(vgName), str(mountPoint)])
    subprocess.run(['/opt/ArchInstall/mountBoot.sh', str(devName), str(mountPoint)])
def checkRoot():
    if os.geteuid() != 0:
        print("Program has to be run as root!")
        exit()
def getDevSize():
    global devSize
    devSize = subprocess.run(['/opt/ArchInstall/getDiskInfo.sh', devName], capture_output=True, text=True)
    if devSize.returncode == 0:
        try:
            devSize = int(devSize.stdout.strip())
        except ValueError:
            print('ERROR: 1')
            exit()
    else:
        print("Script failed with return code: " + devSize.returncode)
        exit()
def arguments():
    global crypt
    global swapPartSize
    global homeDirSource
    global homePartSize
    global rootPartSize
    global devName
    global vgName
    global cryptPartName
    global close
    global keymap
    global hostname
    global username
    global executable
    global mountPoint
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--home-directory-source', type=str, help='Backup of the old home directory. SYNTAX: /home/Example/Documents/old/home/user/ with the files in the user directory being the files that should be copied into the new user directory. Only works together with the -u option.', required=False)
    parser.add_argument('-c', '--crypt', action='store_true', help='Install encrypted system', required=False)
    parser.add_argument('-S', '--swap-partition-size', type=str, help='Size of the swap partition in GB default is 0, which means no swap partition will be made. ALL SIZES IN GB!', required=False)
    parser.add_argument('-H', '--home-partition-size', type=str, help='size of the home partition in GB, default is 0, aka no home partition. if set to -p "ETL" all available space will be used.', required=False)
    parser.add_argument('-R', '--root-partition-size', type=str, help='size of the root partition. Everything as stated above. Note that "ETL" can and HAS to be used in exact one of those values.')
    parser.add_argument('-d', '--device-to-install-on', type=str, help='The device that the operating system should be installed on. Example Usage: -d /dev/sda and NOT sda1! THE DEFAULT PASSWORD FOR ROOT IS "root", for the normal user it is "pass"!', required=True)
    parser.add_argument('-v', '--vg-name', type=str, help='The name that should be used for the Logical Volume Group', required=False)
    parser.add_argument('-N', '--crypt-device-name', type=str, help='The name that the luks ecrypted device should be opened as.', required=False)
    parser.add_argument('-C', '--close-cryptdevice', action='store_true', help='If the option is given, the cryptdevice will be closed when the Installation is finsihed.', required=False)
    parser.add_argument('-K', '--keymap', type=str, help='The Keymap that should be echo\'d into /etc/vconsole.conf', required=True)
    parser.add_argument('-n', '--hostname', type=str, help='The hostname for the new system.', required=True)
    parser.add_argument('-u', '--username', type=str, help='The username for the user of the new operating system. If not given, no user will be created.', required=False)
    parser.add_argument('-e', '--executable', type=str, help="File to execute after the Installation has finished.")
    parser.add_argument('-m', '--mountpoint', type=str, help="Mountpoint of the new system. DEFAULT: /mnt/newsystem",required=False)
    args = parser.parse_args()
    homeDirSource = args.home_directory_source
    swapPartSize = args.swap_partition_size
    homePartSize = args.home_partition_size
    crypt = args.crypt
    executable = args.executable
    rootPartSize = args.root_partition_size
    devName = args.device_to_install_on
    vgName = args.vg_name
    keymap = args.keymap
    username = args.username
    hostname = args.hostname
    cryptPartName = args.crypt_device_name
    close = args.close_cryptdevice
    mountPoint = args.mountpoint
if __name__ == '__main__':
    #os.chdir(os.path.dirname(os.path.abspath(__file__)))
    try:
        startfunction()
    except KeyboardInterrupt:
        print('   ERROR: SIGTERM received!')
