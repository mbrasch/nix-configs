Hmpffff
bekomme ich nach "nixos-generate-configuration" folgende config:

cat /mnt/etc/nixos/hardware-configuration.nix

Do not modify this file! It was generated by ‘nixos-generate-config’
and may be overwritten by future invocations. Please make changes
to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
imports =
[ (modulesPath + "/profiles/qemu-guest.nix")
];

boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "usbhid" "usb_storage" "sr_mod" ];
boot.initrd.kernelModules = [ ];
boot.kernelModules = [ ];
boot.extraModulePackages = [ ];

fileSystems."/" =
{ device = "rpool/root/nixos";
fsType = "zfs";
};

fileSystems."/home" =
{ device = "rpool/home";
fsType = "zfs";
};

fileSystems."/boot" =
{ device = "/dev/disk/by-uuid/94B2-5D16";
fsType = "vfat";
};

swapDevices = [ ];

}

und: ll /dev/disk/by-uuid/
total 0
lrwxrwxrwx 1 root root  9 Jul 20  2022 1980-01-01-00-00-00-00 -> ../../sr0
lrwxrwxrwx 1 root root 10 Jul 20 17:20 94B2-5D16 -> ../../vda2
und folgenden abbruch der installation:


setting up /etc...
/etc/tmpfiles.d/journal-nocow.conf:26: Failed to resolve specifier: uninitialized /etc detected, skipping
All rules containing unresolvable specifiers will be skipped.
Initializing machine ID from VM UUID.
Failed to check file system type of "/boot/efi": No such file or directory
Traceback (most recent call last):
  File "/nix/store/741n4m2rnl3wz3dwnms5z1gbqdqlhy5b-systemd-boot", line 325, in <module>
    main()
  File "/nix/store/741n4m2rnl3wz3dwnms5z1gbqdqlhy5b-systemd-boot", line 254, in main
    subprocess.check_call(["/nix/store/fgcrc8gxf14ddyzlxxjaw6dxdqm52pav-systemd-249.7/bin/bootctl", "--path=/boot/efi"] + flags + ["install"])
  File "/nix/store/phzaqgv2d3y0b3bnyi53zmyja4mpqbr0-python3-3.9.13/lib/python3.9/subprocess.py", line 373, in check_call
    raise CalledProcessError(retcode, cmd)
subprocess.CalledProcessError: Command '['/nix/store/fgcrc8gxf14ddyzlxxjaw6dxdqm52pav-systemd-249.7/bin/bootctl', '--path=/boot/efi', '--graceful', 'install']' returned non-zero exit status 1.
stelle ich mich gerade doof an, oder wie… oder wer… oder was?
ich teste jetzt mal mit QEMU mit x86-emulation gegen. das dauert aber. das ist DEUTLICH langsamer
Erweitern
RJHacker19993 und 2 andere haben den Raum verlassen, cap hat den Raum betreten und wieder verlassen, RJHacker80253 und ein weiteres Raummitglied haben den Raum betreten
Hmpffff
verdammt, der bricht an der gleichen stelle ab

setting up /etc...
/etc/tmpfiles.d/journal-nocow.conf:26: Failed to resolve specifier: uninitialized /etc detected, skipping
All rules containing unresolvable specifiers will be skipped.
Initializing machine ID from VM UUID.
Failed to check file system type of "/boot/efi": No such file or directory
Traceback (most recent call last):
  File "/nix/store/3kw6d28ah9fxzm2zczvngc4dmn6xk723-systemd-boot", line 317, in <module>
    main()
  File "/nix/store/3kw6d28ah9fxzm2zczvngc4dmn6xk723-systemd-boot", line 243, in main
    subprocess.check_call(["/nix/store/iirqa1lqni18mcaii3g1l5s15jxwz17a-systemd-250.4/bin/bootctl", "--path=/boot/efi"] + flags + ["install"])
  File "/nix/store/xpwwghl72bb7f48m51amvqiv1l25pa01-python3-3.9.13/lib/python3.9/subprocess.py", line 373, in check_call
    raise CalledProcessError(retcode, cmd)
subprocess.CalledProcessError: Command '['/nix/store/iirqa1lqni18mcaii3g1l5s15jxwz17a-systemd-250.4/bin/bootctl', '--path=/boot/efi', '--graceful', 'install']' returned non-zero exit status 1.
mist. parallels startet nicht vom aarch64-iso und vmware aarch64 ist noch im testing und startet auch nicht
ich könnte es fürs erst ja mal mit einer infect-variante auf debian oder ubuntu probieren
welche der infect-varianten will man aktuell nehmen?
Erweitern
Mic92 (@Mic92:hackint.org) und 4 andere haben den Raum betreten
Hmpffff
HACH!!!!! ES BOOTET!!11!!!1!!!!11!
das problem war wohl die option boot.loader.efi.efiSysMountPoint = "/boot/efi";
das booten ist zwar noch kaputt, aber immerhin sieht der jetzt das laufwerk und fängt an zu booten
importing root ZF'S pool 'rpool". cannot import
'rpool : no such pool available
cannot import
'rpool
such pool available
mounting rpool/root/nixos on
mount: mounting rpool/root/nixos on /mnt-root/ failed: No such file or directory
...
retrying..
mount: mounting rpool/root/nixos on /mnt-root/ failed: No such file or directory
An error occurred in stage 1 of the boot process, which must mount the root filesystem on 'mnt-root' and then start stage 2.
Press one
of the following keys:
r) to reboot immediately
*) to ignore the error and continue
wenn jemand hier noch eine idee hätte…
und wieder frage ich mich: musste ich unbedingt mit nixos linux lernen? :)
Erweitern
RJHacker80253 hat den Raum verlassen, cap hat den Raum betreten und wieder verlassen, RJHacker64630 hat den Raum betreten
Hmpffff
ein kleiner unterschied zwischen QEMU/x86-emu und QEMU/aarch64-virt ist, daß bei ersterem die üblichen boot-stages durchlaufen. bei letzerem kommt nach dem systemd-boot-menü direkt

EFI stub: Booting Linux Kernel...
EFI stub: Using DIB from configuration table
EFI stub: Exiting boot services and installing virtual address map.

dann 1-2sec später springt es in den fertig aufgebauten nixos-installer-prompt. die frage wäre, welche unterschiede es noch so gibt und wie relevant die sind
Hmpffff
oh, das betrifft nur das installer-image. das installierte system bootet mit den stages.

ok, ich kann jetzt mit einem 1-zeiler die komplette installation in eine fertige konfig in einem rutsch laufen lassen. jetzt muss ich nur noch herausfinden, warum der zfs-pool nicht eingehängt werden kann
Erweitern
RJHacker64630 hat den Raum verlassen, cap hat den Raum betreten und wieder verlassen, RJHacker22459 hat den Raum betreten
Hmpffff
hmmm, verstehe ich das korrekt? ich kann von einem 21.05-installer booten, dann den nix-channel auf z.B. nixos-unstable anheben und dann ein nixos-unstable installieren?

kann es jemand bestätigen, daß das so machbar ist? dann wäre es ja gar nicht so ärgerlich, wenn man nicht das aktuellste installer-iso hat.

mein rpool-import-beim-booten-problem hat es zar nicht behoben, aber es war ein versuch wert
azrael
aiui könnte ein problem die version von nix selbst sein, weil die ist ja dann die alte aus dem installer. aber nicht sicher ob das stimmt
Hmpffff
hmmm, das könnte ein punkt sein. naja nach dem rebooten die version anzuheben wäre nun auch kein drama. aber mal hoffen, daß bald mal wieder fertige aarch64-ISOs aus hydra rausfallen.
ich werd dann morgen mal die konfig von zfs auf ext4 umbauen. für VMs passt das ja. ich hätte nur gerne einen installer für alles gehabt. mal schauen
die ausgabe von bootctl direkt nach dem durchlauf von nixos-install schaut doch OK aus, oder?

Couldn't find EFI system partition. It is recommended to mount it to /boot or /efi.
Alternatively, use --esp-path= to specify path to mount point.
System:
     Firmware: n/a (n/a)
  Secure Boot: disabled
   Setup Mode: user
 TPM2 Support: no
 Boot into FW: supported

Current Boot Loader:
      Product: n/a
     Features: ✗ Boot counting
               ✗ Menu timeout control
               ✗ One-shot menu timeout control
               ✗ Default entry control
               ✗ One-shot entry control
               ✗ Support for XBOOTLDR partition
               ✗ Support for passing random seed to OS
               ✗ Boot loader sets ESP information
          ESP: n/a
         File: └─n/a

Random Seed:
 Passed to OS: no
 System Token: not set

Boot Loaders Listed in EFI Variables:
        Title: Linux Boot Manager
           ID: 0x0005
       Status: active, boot-order
    Partition: /dev/disk/by-partuuid/d3e6b7f0-9850-407e-8fa5-5b464ed37d6f
         File: └─/EFI/systemd/systemd-bootaa64.efi
Erweitern
cptchaos83 hat den Raum 2-mal verlassen und wieder betreten, RJHacker22459 hat den Raum verlassen, cap hat den Raum betreten und wieder verlassen, RJHacker5801 hat den Raum betreten
Heute
Erweitern
cptchaos83 hat den Raum verlassen und wieder betreten, RJHacker5801 hat den Raum verlassen, cap hat den Raum 2-mal betreten und wieder verlassen, RJHacker66656 hat den Raum betreten und wieder verlassen, hax404 (@hax404:hackint.org) und 2 andere haben den Raum betreten
Hmpffff
so, das system baut jetzt. ich hab zsh erstmal durch ext4 ersetzt. iso booten. einen einzeiler eintippen und nach <1min ist das system fertig installiert, incl. 2 user und tools. was lange währt. danke, daß ich hier meine gedanken hab auskippen dürfen. hierbei bin ich überhaupt auf einiges gestoßen :)
Erweitern
cap hat den Raum 6-mal betreten und wieder verlassen, RJHacker71139 hat den Raum verlassen, RJHacker71307 und 4 andere haben den Raum betreten und wieder verlassen, RJHacker21934 hat den Raum betreten
Linux Hackerman
Hmpffff
ach, bei der gelegenheit: wieso wird hier beim installations-script kein GIT installiert?

#!/usr/bin/env nix-shell
#!nix-shell -p git
Sollte eigentlich schon. Aber es ist auch nur für das Skript im PATH.
Ah ja, -i bash brauchst du auch schon
Linux Hackerman
Wie hast du das Skript dann ausgeführt?
1 Antwort
Hmpffff
Das hab ich via "sh <(curl …) ausgeführt. Ich wollte/will halt min minimalst möglichem "Erinnerungsaufwand" ein System bootstrappen können. Bin natürlich offen für Ideen.
Linux Hackerman
Hmpffff
so, das system baut jetzt. ich hab zsh erstmal durch ext4 ersetzt. iso booten. einen einzeiler eintippen und nach <1min ist das system fertig installiert, incl. 2 user und tools. was lange währt. danke, daß ich hier meine gedanken hab auskippen dürfen. hierbei bin ich überhaupt auf einiges gestoßen :)
Was war der Unterschied?
1 Antwort
Hmpffff
Ach, ich hatte zu viele unterschiedliche Dinge angefangen zu ändern und bin gelegentlich herausgerissen worden und hab dann Mist gebaut, wie z.B. die Indizes bei den Partitionen nicht korrigiert. :)
azrael
"hab zsh erstmal durch ext4 ersetzt."  sehr gut! :D
RJHacker21934 hat den Raum verlassen: Nick
cap hat den Raum betreten
Linux Hackerman
Ah ja, dann geht das natürlich nicht, weil sh nicht fürs interpretieren von shebangs zuständig ist
Linux Hackerman
curl in eine Datei, chmod +x, und Datei ausführen sollte gehen.
1 Antwort
Hmpffff
hmmmm, über diese genauen Mechanismen muß ich mich wohl nochmal besser einlesen. Danek
Linux Hackerman
partitionslabels regeln :p
1 Antwort
Hmpffff
Scheint keine seltene Fehlerquelle zu sein, oder? ;) Das war dann bei mir der blinde Fleck, weil, daß passt ja, lief ja schon. Und dann hab ich die BIOS-Partition rausgeworfen…
azrael
gerneller daumen: /dev/disk/by-label  oder by-uuid  nutzen, statt indizes
CRTified
Sehr sinnvolle Sache
Hmpffff
by-uuid ist für (halb)automatische installationen eher unpraktisch. Oder gibt es da etwas, was man hier nutzen kann? ich hätte grundsätzlich nichts gegen by-id oder so. mir fehlt dann aber die möglichkeit das passende ziellaufwerk möglichst einfach herauszufinden
gibt es vielleicht einen weg in einfachen szenarien, z.B. bei einem CD- und einem HDD/SDD-laufwerk automatisch das passende ziellaufwerk auszuwählen?
eventuell ist es ja auch eine idee, ein installer-iso zu bauen, was nach dem start automatisch die installation beginnt, incl. dem download der config usw., um damit headless-geräte (z.B. RasPi) zu bootstrappen.
CRTified
Für RasPis kann man sich direkt lauffähige SD-Images bauen 😉
3 Antworten
CRTified
In dem Fall mit SD-Images muss man stellenweise gar nichts mehr installieren, weil es direkt schon ein lauffähiges System mit Config ist. So habe ich zumindest meine RockPi gebootstrapped
Hmpffff
ich bin jedenfalls einigermaßen begeistert, wie einfach man mit dem nixos-generator eine neue ISO bauen kann. Auf diese weise hab ich jetzt auch für aarch64 eine bleeding-edge-version
CRTified
Im einfachsten Fall hat man für headless-Geräte eine Config, bindet da nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix ein und baut dann das Attribut config.system.build.sdImage 🙂 (Zur Referenz: https://nixos.wiki/wiki/NixOS_on_ARM#Build_your_own_image_natively )

NixOS on ARM - NixOS Wiki
Navigation menu Toggle navigation NixOS Wiki Ecosystem Resources Community Wiki Log in NixOS on ARM From NixOS Wiki
GLaDOS
⤷ NixOS on ARM - NixOS Wiki
CRTified
Also das wäre für den headless-Fall
azrael
Hmpffff
: wegen dem uuid thema empfiehlt der nixos installer by-label, afaik
azrael
/installer/install guide/
2 Antworten
Hmpffff
mich wundert, daß es dafür nicht längst ein tool gibt, was einem die laufwerkswahl erleichtert oder gar komplett abnehmen kann
azrael
und automatisch ein laufwerk wählen… bräuchtest halt ein kriterium dafür, und das ist allgemein nicht verfügbar
azrael
'western digital 256GB SSD, with "use as OS disk" marker +25€'
2 Antworten
CRTified
Sowas wie lsblk --list -o NAME,UUID,TYPE wäre ja ein guter Startpunkt zum greppen 😉
azrael
viele andere distros haben sowas (grafische installer), meistens sind sie seit jahren mist
Hmpffff
und für den Fall wie bei der OPNsense wäre es cool, wenn der Instalöler direkt automatisch losläuft, das korrekte ziellaufwerk wählt, installiert und rebootet
azrael
naja, "das korrekte" hängt halt von ab
"hier sind 2 leere disks"
Hmpffff
naja, in dem fall das einige laufwerk das wo keine CD oder USB-stick ist
azrael
"hier ist ein ubuntu installiert mit 15gb daneben frei"
"hier ist ein windows installiert"
Hmpffff
in diesem fall würde ich das komplette laufwerk übernehmen wollen.
aber der hinweis mit dem lsblk führt vrmtl. schon in die richtige richtung
CRTified
Mein Server hat /dev/nvme1n1 und geht von /dev/sda bis /dev/sds. Was soll es da werden? 😄
azrael
und jmd anderes will vllt dual boot machen. oder hart failen wenn die platte nicht leer ist
1 Antwort
Hmpffff
dieses konkrete installer-iso wäre ja nur für diesen 1-drive-only-fall gedacht
Hmpffff
(nicht vergessen: ich lerne überhaupt erst linux)
CRTified
Also klar, für deinen Usecase wo du vorher schon kennst was du machen willst ist das realisierbar - dafür bietet NixOS auch die richtigen Werkzeuge, weil man sehr leicht eigene Installer bauen kann
Aber man kann sowas einfach nicht generisch lösen
Hmpffff
klar, das sehe ich ein. mir geht es konkret um die 1-laufwerk-1-os-fälle. also "einfache" headless-geräte und ggf. VMs
Linux Hackerman
Es gibt ja inzwischen auch einen grafischen Installer
Hmpffff
headless <––––
:)
Linux Hackerman
den hab ich noch nicht ausprobiert, weiß nicht was der so taugt, aber ich denke für einen "einfachen" Fall sollte der tun
CRTified
Für das formatieren wäre eventuell https://search.nixos.org/options?channel=22.05&query=filesystems.<name>.auto ein guter Startpunkt?

NixOS Search - Loading...
Hmpffff
?!?
CRTified
Ansonsten: Für das System einen installer bauen und via SSH drauf?
CRTified
Hmpffff
?!?
filesystems.<name>.autoFormat erstellt auf dem angegebenen device ein Dateisystem wenn keins gefunden wird
1 Antwort
Hmpffff
kann ich das für einen unattended installer nutzen?
CRTified
Nur weil es headless ist muss es ja kein unattended install sein 🙂
7 Antworten
Hmpffff
ja, wo ist das problem an dieser stelle? das will ich ja. oder verstehe ich etwas falsch?
Hmpffff
oder andere blickrichtung: Nix auf macOS und ich will eine NixOS-VM bauen. ein weg eine VM mit minimalem aufwand zu erstellen wäre ja ein automatischer installer. oder gibt es einen weg auf macOS/Nix eine komplette VM mit Nix zu bauen?
ich weiß, ich könnte den weg über vagrant gehen, aber… das wäre eher mein notfallplan
Linux Hackerman
Hmpffff
oder andere blickrichtung: Nix auf macOS und ich will eine NixOS-VM bauen. ein weg eine VM mit minimalem aufwand zu erstellen wäre ja ein automatischer installer. oder gibt es einen weg auf macOS/Nix eine komplette VM mit Nix zu bauen?
ja
also letzteres
man kann in Nix auch VM-Images bauen
CRTified
Du kannst schnell Configs in einer VM testen via: nixos-rebuild build-vm oder nix-build '<nixpkgs/nixos>' -A config.system.build.vm -I nixos-config=./config-to-test.nix
das nixos-rebuild build-vm bezieht sich standardmäßig dabei auf die Config unter /etc/nixos/configuration.nix
Hmpffff
ja, aber das funktioniert ja nur in NixOS, aber nicht auf einem macOS+Nix
CRTified
In der dabei gebauten derivation ist dann ein skript was dir qemu startet
nix-build sollte auch unter macOS+nix laufen
Hmpffff
ok, dann werde ich mir mal nix-build näher ansehen. und falls jemand noch einen tipp hat, wie man beim installer-iso, nach dem kompletten hochfahren, ein script automatisch starten kann. ich hab eine ganz vage idee, bin aber am überlegen wo ich meine mal was passendes gesehen zu haben
CRTified
boot.postBootCommands
Die sd-image.nix nutzt das z.B. um / zu resizen: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/sd-card/sd-image.nix#L247-L272

nixpkgs/sd-image.nix at master · NixOS/nixpkgs - GitHub
Nix Packages collection. Contribute to NixOS/nixpkgs development by creating an account on GitHub.

GLaDOS
⤷ nixpkgs/sd-image.nix at master · NixOS/nixpkgs · GitHub
CRTified
Wobei, das ist bevor systemd startet. vielleicht wäre es besser, einen install-script via systemd oneshot service zu starten
6 Antworten
Hmpffff
goil, danke :)
azrael
oder eher after network-online.target
CRTified
Stimmt, das ist vmtl besser
Hmpffff
mit dem input sollte ich was zustandebringen – danke Leute
