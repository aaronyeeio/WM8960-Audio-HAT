# WM8960 Audio HAT

The drivers of [WM8960 Audio HAT] for Radxa RK356x (only tested on ZERO 3).

http://www.waveshare.net/shop/WM8960-Audio-HAT.htm

http://www.waveshare.com/wm8960-audio-hat.htm

### Install wm8960-soundcard
Get the wm8960 soundcard source code. and install all linux kernel drivers

```bash
git clone https://github.com/waveshare/WM8960-Audio-HAT
cd WM8960-Audio-HAT
sudo ./install.sh 
rsetup # select Overlays - Install 3rd party overlay - wm8960-soundcard.dtbo
sudo reboot
```

While the upstream wm8960 codec is not currently supported by current Pi kernel builds, upstream wm8960 has some bugs, we had fixed it. we must it build manually.

Check that the sound card name matches the source code wm8960-soundcard.

```bash
radxa@radxa-zero3:~ $ aplay -l
**** List of PLAYBACK Hardware Devices ****
card 1: wm8960soundcard [wm8960-soundcard], device 0: fe430000.i2s-wm8960-hifi wm8960-hifi-0 []
  Subdevices: 1/1
  Subdevice #0: subdevice #0
radxa@radxa-zero3:~ $ arecord -l
**** List of CAPTURE Hardware Devices ****
card 1: wm8960soundcard [wm8960-soundcard], device 0: fe430000.i2s-wm8960-hifi wm8960-hifi-0 []
  Subdevices: 1/1
  Subdevice #0: subdevice #0

```
If you want to change the alsa settings, You can use `sudo alsactl --file=/etc/wm8960-soundcard/wm8960_asound.state  store` to save it.


### Usage:
```bash
#It will capture sound an playback on hw:1
arecord -f cd -Dhw:1 | aplay -Dhw:1
```

```bash
#capture sound 
#arecord -d 10 -r 16000 -c 1 -t wav -f S16_LE test.wav
arecord -D hw:1,0 -f S32_LE -r 16000 -c 2 test.wav
```

```bash
#play sound file test.wav
aplay -D hw:1,0 test.wav
```

### uninstall wm8960-soundcard
If you want to upgrade the driver , you need uninstall the driver first.

```bash
radxa@radxa-zero3:~/WM8960-Audio-HAT $ sudo ./uninstall.sh 
...

------------------------------------------------------
Please reboot your device to apply all settings
Thank you!
------------------------------------------------------
```

Enjoy !
