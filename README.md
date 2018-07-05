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
   SDx application that we will run*
   ```sh
   > top.sh
   ```
   
   - Alternatively, each step can be run sequentially, one at a time
     ```sh
     > gen_hardware_project.sh
     > gen_petalinux_project.sh
     > gen_sdx_platform_project.sh
     ```

   - When the menuconfig for petalinux pops up during the
     gen_petalinux_project.sh script, exit without making any
     changes. Select YES to save new configuration
   
1. Create the SDx application project
   1. Source the settings for SDx and start SDx Tool
   ```sh
   > $SSDX
   > cd work/
   > sdx -workspace sdx_application_project
   ```
   
   1. File -> New -> SDx Project -> Application Project
   1. Name: mz_stream_petalinux
   1. Add Custom Platform
      * ${PROJWS}/work/sdx_platform_project/
      * Next -> Next -> Finish
   1. Properties -> C++ Build -> Behavior -> Enable Parallel Build -> optimal
   1. Right click src folder -> Import -> General -> File System
      * ${PROJWS}/support/sdx/src
   1. Enable read_stream as hardware function
   1. Setup Linux TCF Agent as needed
   1. Build the project
   1. Deploy files under sd_card to MiniZed (see next section)
   
# Deploying Files to MiniZed

Once you have built the SDx Application Project, there will be files in the sd_card directory that must be uploaded to the board. These files are located at ${PROJWS}/work/sdx_application_project/mz_stream_petalinux/Debug/sd_card

1. BOOT.BIN
1. image.ub
1. mz_stream_petalinux.elf

There is a helper script, bin/upload.sh which can be used to upload the files automatically. The script assumes that the MiniZed is booted into Linux and the wifi.sh script has been executed on the board such that the MiniZed has joined a wireless network. Also, the environmet variable 'MZ_IP' must hold the IPv4 address of the board, for example '192.168.1.16'. The MZ_IP variable is set in bin/setup.sh. By examining the bin/upload.sh script, one can see examples of uploading files to the MiniZed over SCP in the case that the automated script is unsuitable.
