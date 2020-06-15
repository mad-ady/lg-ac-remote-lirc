# lg-ac-remote-lirc
Lirc codes for a LG Air Conditioning remote (AKB73456113)

The toml keymap uses ir-ctl which does not need lirc, it just needs write
access to /dev/lirc0.

```
ir-ctl -k lg-ac-remote.toml -K fan-high
```
