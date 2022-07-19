 % yes | sh <(curl -L https://nixos.org/nix/install) --daemon
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100  4053  100  4053    0     0   8381      0 --:--:-- --:--:-- --:--:-- 52636
downloading Nix 2.8.1 binary tarball for aarch64-darwin from 'https://releases.nixos.org/nix/nix-2.8.1/nix-2.8.1-aarch64-darwin.tar.xz' to '/var/folders/mh/hsdpz69s4b5bphv4h_vb70s40000gn/T/nix-binary-tarball-unpack.XXXXXXXXXX.CM8jX73t'...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 9137k  100 9137k    0     0  3329k      0  0:00:02  0:00:02 --:--:-- 3337k
Switching to the Multi-user Installer
Welcome to the Multi-User Nix Installation

This installation tool will set up your computer with the Nix package
manager. This will happen in a few stages:

1. Make sure your computer doesn't already have Nix. If it does, I
   will show you instructions on how to clean up your old install.

2. Show you what I am going to install and where. Then I will ask
   if you are ready to continue.

3. Create the system users and groups that the Nix daemon uses to run
   builds.

4. Perform the basic installation of the Nix files daemon.

5. Configure your shell to import special Nix Profile files, so you
   can use Nix.

6. Start the Nix daemon.

Would you like to see a more detailed list of what I will do?
No TTY, assuming you would say yes :)

I will:

 - make sure your computer doesn't already have Nix files
   (if it does, I will tell you how to clean them up.)
 - create local users (see the list above for the users I'll make)
 - create a local group (nixbld)
 - install Nix in to /nix
 - create a configuration file in /etc/nix
 - set up the "default profile" by creating some Nix-related files in
   /var/root
 - back up /etc/bashrc to /etc/bashrc.backup-before-nix
 - update /etc/bashrc to include some Nix configuration
 - back up /etc/zshrc to /etc/zshrc.backup-before-nix
 - update /etc/zshrc to include some Nix configuration
 - create a Nix volume and a LaunchDaemon to mount it
 - create a LaunchDaemon (at /Library/LaunchDaemons/org.nixos.nix-daemon.plist) for nix-daemon

Ready to continue?
No TTY, assuming you would say yes :)

---- let's talk about sudo -----------------------------------------------------
This script is going to call sudo a lot. Normally, it would show you
exactly what commands it is running and why. However, the script is
run in a headless fashion, like this:

  $ curl -L https://nixos.org/nix/install | sh

or maybe in a CI pipeline. Because of that, I'm going to skip the
verbose output in the interest of brevity.

If you would like to
see the output, try like this:

  $ curl -L -o install-nix https://nixos.org/nix/install
  $ sh ./install-nix


~~> Fixing any leftover Nix volume state
Before I try to install, I'll check for any existing Nix volume config
and ask for your permission to remove it (so that the installer can
start fresh). I'll also ask for permission to fix any issues I spot.
During install, I add '/nix' to /etc/fstab so that macOS knows what
mount options to use for the Nix volume.
Password:
I might be able to help you make this edit. Here's the diff:
  #
  # Warning - this file should only be modified with vifs(8)
  #
  # Failure to do so is unsupported and may be destructive.
  #


- UUID=46EA0336-1534-441A-BA96-299534B0217F /nix apfs rw,noauto,nobrowse,suid,owners
Does the change above look right?
No TTY, assuming you would say yes :)
patching file /etc/fstab

The installer adds a LaunchDaemon to mount your Nix volume: org.nixos.darwin-store
Can I remove it?
No TTY, assuming you would say yes :)

~~> Checking for artifacts of previous installs
Before I try to install, I'll check for signs Nix already is or has
been installed on this system.

---- Nix config report ---------------------------------------------------------
        Temp Dir:       /var/folders/mh/hsdpz69s4b5bphv4h_vb70s40000gn/T/tmp.snkmOunH3b
        Nix Root:       /nix
     Build Users:       32
  Build Group ID:       30000
Build Group Name:       nixbld

build users:
    Username:   UID
     _nixbld1:  301
     _nixbld2:  302
     _nixbld3:  303
     _nixbld4:  304
     _nixbld5:  305
     _nixbld6:  306
     _nixbld7:  307
     _nixbld8:  308
     _nixbld9:  309
     _nixbld10: 310
     _nixbld11: 311
     _nixbld12: 312
     _nixbld13: 313
     _nixbld14: 314
     _nixbld15: 315
     _nixbld16: 316
     _nixbld17: 317
     _nixbld18: 318
     _nixbld19: 319
     _nixbld20: 320
     _nixbld21: 321
     _nixbld22: 322
     _nixbld23: 323
     _nixbld24: 324
     _nixbld25: 325
     _nixbld26: 326
     _nixbld27: 327
     _nixbld28: 328
     _nixbld29: 329
     _nixbld30: 330
     _nixbld31: 331
     _nixbld32: 332

Ready to continue?
No TTY, assuming you would say yes :)

---- Preparing a Nix volume ----------------------------------------------------
    Nix traditionally stores its data in the root directory /nix, but
    macOS now (starting in 10.15 Catalina) has a read-only root directory.
    To support Nix, I will create a volume and configure macOS to mount it
    at /nix.

~~> Configuring /etc/synthetic.conf to make a mount-point at /nix

~~> Creating a Nix volume
disk3s8 was already unmounted

~~> Configuring /etc/fstab to specify volume mount options

~~> Encrypt the Nix volume
Volume Nix Store on Nix Store mounted
Encrypting with the new "Disk" crypto user on disk3s8
The new "Disk" user will be the only one who has initial access to disk3s8
The new APFS crypto user UUID will be 844CD5F7-90C4-4025-948F-2CC0F3D7BD6F
Encryption has likely completed due to AES hardware; see "diskutil apfs list"
Volume Nix Store on disk3s8 force-unmounted

~~> Configuring LaunchDaemon to mount 'Nix Store'

~~> Setting up the build group nixbld
            Created:    Yes

~~> Setting up the build user _nixbld1
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 1
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld2
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 2
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld3
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 3
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld4
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 4
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld5
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 5
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld6
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 6
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld7
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 7
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld8
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 8
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld9
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 9
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld10
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 10
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld11
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 11
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld12
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 12
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld13
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 13
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld14
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 14
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld15
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 15
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld16
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 16
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld17
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 17
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld18
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 18
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld19
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 19
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld20
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 20
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld21
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 21
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld22
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 22
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld23
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 23
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld24
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 24
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld25
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 25
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld26
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 26
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld27
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 27
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld28
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 28
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld29
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 29
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld30
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 30
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld31
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 31
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the build user _nixbld32
           Created:     Yes
            Hidden:     Yes
    Home Directory:     /var/empty
              Note:     Nix build user 32
   Logins Disabled:     Yes
  Member of nixbld:     Yes
    PrimaryGroupID:     30000

~~> Setting up the basic directory structure
install: mkdir /nix/var
install: mkdir /nix/var/log
install: mkdir /nix/var/log/nix
install: mkdir /nix/var/log/nix/drvs
install: mkdir /nix/var/nix
install: mkdir /nix/var/nix/db
install: mkdir /nix/var/nix/gcroots
install: mkdir /nix/var/nix/profiles
install: mkdir /nix/var/nix/temproots
install: mkdir /nix/var/nix/userpool
install: mkdir /nix/var/nix/daemon-socket
install: mkdir /nix/var/nix/gcroots/per-user
install: mkdir /nix/var/nix/profiles/per-user
install: mkdir /nix/store
install: mkdir /etc/nix

~~> Installing Nix
      Alright! We have our first nix at /nix/store/dirm8hsnmvvzjs21hrx8i84w8k453jzp-nix-2.8.1
      Just finished getting the nix database ready.

~~> Setting up shell profiles: /etc/bashrc /etc/profile.d/nix.sh /etc/zshrc /etc/bash.bashrc /etc/zsh/zshrc

# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
# End Nix


# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
# End Nix


# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
# End Nix


~~> Setting up the default profile
installing 'nix-2.8.1'
building '/nix/store/37wfw83i1bckriqivm7vkm0mrflpa5c0-user-environment.drv'...
installing 'nss-cacert-3.66'
building '/nix/store/ly418bnv01nsbls5zn0yyl54ld2bv506-user-environment.drv'...
unpacking channels...

~~> Setting up the nix-daemon LaunchDaemon
Alright! We're done!
Try it! Open a new terminal, and type:

  $ nix-shell -p nix-info --run "nix-info -m"

Thank you for using this installer. If you have any feedback or need
help, don't hesitate:

You can open an issue at https://github.com/nixos/nix/issues

Or feel free to contact the team:
 - Matrix: #nix:nixos.org
 - IRC: in #nixos on irc.libera.chat
 - twitter: @nixos_org
 - forum: https://discourse.nixos.org

---- Reminders -----------------------------------------------------------------
[ 1 ]
Nix won't work in active shell sessions until you restart them.
