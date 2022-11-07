# DeskPI Super6c
### Useful Links
https://github.com/DeskPi-Team/super6c
https://github.com/geerlingguy/deskpi-super6c-cluster

https://www.jeffgeerling.com/blog/2020/raspberry-pi-cluster-episode-2-setting-cluster
https://learn.networkchuck.com/courses/take/ad-free-youtube-videos/lessons/26093614-i-built-a-raspberry-pi-super-computer-ft-kubernetes-k3s-cluster-w-rancher
https://www.the-diy-life.com/raspberry-pi-cm4-cluster-running-kubernetes-turing-pi-2/

## Step 1: Assemble the Board
[[README]]
## Step 2: Flash the CM4's
We are going to install Raspberry Pi OS to the CM4's using the [Raspberry Pi Imager](https://www.raspberrypi.com/software/)

#### eMMC 

The DeskPi functions as an IO Board and has micro-usb connectors next to each Compute Module. 
Note that CM1's usb connector is on the back of the [board](https://github.com/DeskPi-Team/super6c/blob/main/assets/port_definitions.png).

1. Install or compile [`rpiboot`](https://github.com/raspberrypi/usbboot) for your host OS. A windows installer is available here https://github.com/raspberrypi/usbboot/tree/master/win32. 
2. Download and Install the [Raspberry PI Imager](https://www.raspberrypi.com/software/) for your host OS.
3. Bridge the [`nRPBOOT`](https://github.com/DeskPi-Team/super6c/blob/main/assets/CM4_Jumpers.png)  jumper next to the CM you want to flash.
4. Plug in the Micro USB cable to the USB Connector of the CM you want to flash. 
5. Apply power to the board
6. Start `rpiboot`
7. After `rpiboot` completes you should  have access to a new mass storage device. Do not format if prompted.
8. Start the Raspberry Pi Imager tool.
9. Select your preferred OS (for k3s you need a 64-bit OS). Typically the 64-bit lite version should be sufficient, unless you want full GUI support.
10. Select the newly discovered raspberry mass storage device to write to.
11. NOTE: In `Advanced options`, be sure to 
	* set the **hostname** of your Pi to something unique and memorable 
	* enable SSH and set your preferred authentication 
	* set a username and password (optional, but recommended) and 
	* configure Wireless LAN, if it is supported by your CM (optional)
12. Repeat this for all CMs - the headless versions do not need a desktop environment, so the 64-bit lite version of Raspberry Pi OS should be sufficient. Remember to change the hostname for every CM.

### Notes
1. You may need to enable USB2.0 support for the CM in the first slot by adding `dtoverlay=dwc2,dr_mode=host` to the `config.txt` file in the root of the boot image.
2. If you did not enable SSH via the Imager, to enable it you can create a blank file called `ssh` in the root of the boot image.
3. At least on my monitor, I did not get a video signal, so for the CM in the first slot I had to replace `dtoverlay=vc4-kms-v3d`with `dtoverlay=vc4-fkms-v3d` (note the additional "f") in the `config.txt` file. I figured this out from this [comment](https://forums.raspberrypi.com/viewtopic.php?t=323920#p1939139) on the raspberry forums.
4. You **cannot** mount an [SD Card to a CM with eMMC](https://www.reddit.com/r/retroflag_gpi/comments/snesyy/is_it_impossible_to_mount_the_sd_card_with_an/). Even though it's not explicitly stated, and the documentation on the Super6c github misleadingly states in the [TroubleShooting Section](https://github.com/DeskPi-Team/super6c#troubleshooting) that
	> "If your CM4 module has eMMC on board, the SSD drive and **TF card** can be external mass storage." 
	
#### References
https://github.com/raspberrypi/usbboot
https://www.raspberrypi.com/documentation/computers/compute-module.html#flashing-the-compute-module-emmc
https://www.jeffgeerling.com/blog/2020/usb-20-ports-not-working-on-compute-module-4-check-your-overlays

### Non-eMMC (CM4 Lite)
Flash Raspberry Pi OS to the TF cards or SSD drives, insert them into the card slot, fix it with screws, connect the power supply, and press `PWR_BTN` button to power them on.