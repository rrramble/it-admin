# Multiboot Windows Installer

- Use [`Ventoy`](https://github.com/ventoy/Ventoy/releases/) to format a USB-drive in `ExFAT` format. Do not split by volumes, Ventoy will add a small volume with Fat32 bootloader by itself.
- Copy Windows ISO files into the USB-drive.
- (Optionally) Add [`autounattend_{:language}.xml`](https://schneegans.de/windows/unattend-generator/) file(s). [`autounattend_en.xml` example](./autounattend_en.xml).
- Create [`/ventoy/ventoy.json`](./ventoy.json) file pointing to the `autounattend_...` files (lowercase letters!) Every ISO-file must have its `image/template` setup.
