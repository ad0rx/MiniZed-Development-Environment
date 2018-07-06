# MiniZed Development Environment 2017.4

# Goals 
* Provide a method to quickly experiment with Xilinx SDx (a.k.a. SDSoC) Tool
* Serve as example projects to demonstrate common embedded Linux tasks
  * User Space IO (UIO) (Done)
  * Kernel char driver  (In Progress)
* Quick start for any project targetting Avnet MiniZed SoC development board
* Demonstrate how to automate Xilinx tool flows and common support tasks
* Demonstrate how to use revision control for large projects by tracking only source code and build scripts

# Summary
The culminating capability of this project is the ability to start developing a Xilinx SDx application, with streaming IO (DMA) and a practical hardware reference design. This project provides a collection of scripts and supporing files which enable you to quickly develop applications for the Avnet MiniZed development board. The current automation supports generation of the following:

1. Vivado Hardware Project
   1. Custom AXI Counter IP example (VHDL)
1. PetaLinux Distribution Project
   1. UIO Driver link to AXI Counter IP
1. SDx Platform Project
   1. Streaming IO Application (DMA) with UIO API to custom hardware control registers
   
By running the automated scripts, you will be able to choose any area of interest and not have to start from scratch. This enables you to focus on what matters to you today. If you are interested in seeing how the projects are architected, the information is contained in the included Bash and Tcl scripts.  

Along with the automated build scripts are a few helper scripts containing tips and tricks which are generally applicable to just about any development board that runs Linux. For example, the bin/setup_ssh.sh and bin/upload.sh scripts.

Although this project targets the Avnet MiniZed, the concepts transfer to just about any Zynq and Zynq UltraScale (MPSoC) based development board.

# Prerequisites

1. Xilinx SDx 2017.4 
   - includes Vivado
   
1. PetaLinux 2017.4 

1. Licenses sufficient to target XC7Z007S part

# Getting Started

1. cd to a place where you have 20GB available

1. Clone the repo
   ```sh
   > git clone https://github.com/ad0rx/mz_stream_petalinux_2017.4.git mz_stream_petalinux --depth 1
   ```

1. If you are going to develop with intent to submit patches back to master branch, 
   consider creating a local branch

1. Change to directory just created by git
   ```sh
   > cd mz_stream_petalinux
   ```

5. Set PROJWS
   ```sh
   > export PROJWS=$(pwd)
   ```

1. Edit bin/setup.sh
   - replace occurances of 'myhostname' with the host name of your machine as reported by 'hostname'
   - edit the path to tool settings.sh to match your local environment
   - set the IP address of your MiniZed in the MZ_IP variable (optional)
  
1. Source the bin/setup.sh file
   ```sh
   > . bin/setup
   ```

1. Run the top level script which will build everything required by the final
   SDx application that we will run
   ```sh
   > top.sh
   ```
   
   - Alternatively, each step can be run sequentially, one at a time
     ```sh
     > gen_hardware_project.sh
     > gen_petalinux_project.sh
     > gen_sdx_platform_project.sh
     > gen_sdx_application_project.sh
     ```
   - Once the gen_sdx_application_project.sh script completes, SDx will automatically open
   
1. Build the SDx Application

   - Project -> Build All or CTRL+B
   
1. Deploy Files to MiniZed

   - The following steps assume that the board has booted into Linux, the wifi.sh script has been executed on the board, and you have set the IP of the board in bin/setup.sh MZ_IP variable. Once you source the bin/setup_ssh.sh file, the mzssh command will be available to you and allows you to log into the board without having to provide an interactive password. The bin/setup_ssh.sh file configures public key authentication. You will be asked to connect to the board only once per board reboot.

   1. Source the SSH setup file
      ```sh
      > . bin/setup_ssh.sh
      ```

   - Once you have built the SDx Application Project, there will be files in the sd_card directory that must be uploaded to the board. These files are located at ${PROJWS}/work/sdx_application_project/mz_stream_petalinux/Debug/sd_card

     1. BOOT.BIN
     1. image.ub
     1. mz_stream_petalinux.elf
     
   1. Upload files to MiniZed
      ```sh
      > upload.sh
      ```

1. Program BOOT.BIN into QSPI and reboot the board
   ```sh
   > mzssh /usr/sbin/flashcp /mnt/emmc/BOOT.BIN /dev/mtd0
   > mzssh /sbin/reboot
   ```

1. Run the Application over SSH fron the development host
   ```sh
   > mzssh /mnt/emmt/mz_stream_petalinux.elf
   ```
   
1. Celebrate a well earned victory!
