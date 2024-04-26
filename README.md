# disable-systemd-wall-messages

[![Version](https://img.shields.io/github/v/release/Kir-Antipov/disable-systemd-wall-messages?sort=date&style=flat&label=version&cacheSeconds=3600)](https://github.com/Kir-Antipov/disable-systemd-wall-messages/releases/latest)
[![License](https://img.shields.io/github/license/Kir-Antipov/disable-systemd-wall-messages?style=flat&cacheSeconds=36000)](https://github.com/Kir-Antipov/disable-systemd-wall-messages/blob/HEAD/LICENSE.md)

You may have noticed that every time you reboot or shut down your system, a set of annoying messages appears on the screen:

```
Broadcast message from user@host (Thu 1970-01-01 00:00:00 UTC):

The system will power off now!
```

Can we just take a moment to appreciate how useful these messages are? How else in the world would you know that your system is going to shut down after you click the "Shut Down" button and then "Yes" in the confirmation prompt? Wow. Thank God for these messages coming in clutch!

Funnily enough, we didn't always have this goodness. While it's the intended behavior of systemd, for quite some time in the past it simply didn't work. Surprisingly, nobody noticed such a useful feature not functioning as intended! However, one day, somebody - whom I can only assume was that kid literally nobody liked, the one who loved to remind teachers about homework - finally noticed and reported this terrible malfunction. Instead of doing the smart thing, i.e., recognizing the de facto default behavior and making a few adjustments in the documentation, systemd maintainers did the exact opposite and decided to enforce the word of the old rules. By the way, this immediately backfired, because systemd started displaying these messages not only when the system shuts down, but also whenever someone tries to suspend their machine, which was not just annoying, but plainly disruptive. Consequently, the maintainers rushed to exempt the suspend operation from this new old rule. And this is how you know that the "feature" is useful, desired, and just plain good in general - you need to disable it for a bunch of special cases as soon as possible to make it at least somewhat usable.

Whatever's the case, now we need to manually revert to the old behavior in case somebody else didn't do that for us *(like our distros, DEs, and such)*. Thankfully, it's quite easy to do! If you run the following command:

```sh
busctl set-property org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager EnableWallMessages b false
```

The wall messages will be gone next time you shut down your machine. However, this change is not persistent between reboots. To make it persistent, we can create a very simple systemd service that runs this command on boot automatically. And this is exactly what this small repo offers.

----

## Installation

The installation process is quite straightforward: just clone this repo and run the `install.sh` script.

```sh
git clone https://github.com/Kir-Antipov/disable-systemd-wall-messages
cd disable-systemd-wall-messages
sudo ./install.sh
```

Alternatively, you can achieve the same results with this one-liner:

```sh
sudo bash <(curl -Ls https://github.com/Kir-Antipov/disable-systemd-wall-messages/blob/HEAD/install.sh?raw=true)
```

This will:

1) Copy *(or download, if you haven't cloned the repo)* the `disable-systemd-wall-messages.service` file to `/etc/systemd/system/`.
2) Start the newly created service.
3) Enable the service to automatically start on boot.

After that, the annoying wall messages should be gone for good!

----

## License

Licensed under the terms of the [MIT License](https://github.com/Kir-Antipov/disable-systemd-wall-messages/blob/HEAD/LICENSE.md).
