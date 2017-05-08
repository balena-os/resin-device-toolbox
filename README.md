#  [Deprecated] Resin Device Toolbox - rdt

### =================================================================
## __NOTE:__ `rdt` is now deprecated, please use the `local` commands in the [Resin CLI](https://github.com/resin-io/resin-cli).
### =================================================================
> The official resinOS command line tool.

Resin Device Toolbox or `rdt` is a collection of utilities that can help you develop resinOS based application containers.

## Preview

Click below to see a preview of `rdt push`

[![asciicast](https://asciinema.org/a/88937.png)](https://asciinema.org/a/88937)

## Dependencies

* [NodeJS >= 4](https://nodejs.org/en/)
  - `ssh`: Any recent version of the OpenSSH ssh client (required by `rdt ssh` and `rdt push`)
  - `rsync`: >= 2.6.9 (required by `rdt push`)

### Windows Support

`rdt push` and `rdt ssh` have not been thoroughly tested on the standard Windows cmd.exe shell. We recommend using bash (or a similar) shell, like Bash for Windows 10 or [Git for Windows](https://git-for-windows.github.io/).

If you still want to use `cmd.exe` you will have to use a package manager like MinGW or chocolatey. For MinGW the steps are:

1. Install [MinGW](http://www.mingw.org).
2. Install the `msys-rsync` and `msys-openssh` packages.
3. Add MinGW to the `%PATH%` if this hasn't been done by the installer already. The location where the binaries are places is usually `C:\MinGW\msys\1.0\bin`, but it can vary if you selected a different location in the installer.

## Install

You can install Resin Device Toolbox by running:

```sh
$ npm install -g resin-device-toolbox
```

## Getting Started

If you want a quick introduction on development with resinOS you can also [check our tutorial](https://resinos.io/docs/raspberrypi3/gettingstarted/).

## Usage

You can get a list of available commands with `rdt -h`:

```
Usage: rdt [COMMAND] [OPTIONS]

If you need help, or just want to say hi, don't hesitate in reaching out at:

  GitHub: https://github.com/resin-os/resin-device-toolbox/issues/new
  Gitter: https://gitter.im/resin-io/chat

Primary commands:

    ssh [deviceIp]                      Get a shell into a resinOS device
    push [deviceIp]                     Push your changes to a container on local resinOS device
    logs [deviceIp]                     Get or attach to logs of a running container on a resinOS device
    scan                                Scan for resinOS devices in your local network
    configure <target>                  (Re)configure a resinOS drive or image
    flash <image>                       Flash an image to a drive
    version                             Output the version number
    help [command...]                   Show help

Global Options:

    --help, -h
```

## Support

If you're having any problem, please [raise an issue][newissue] on GitHub and
the Resin.io team will be happy to help. You can also get in touch with us in the resin.io [forums](https://forums.resin.io).

## License

Resin Device Toolbox is free software, and may be redistributed under the terms specified
in the [license][license].

[license]: https://github.com/resin-os/resin-device-toolbox/blob/master/LICENSE
[newissue]: https://github.com/resin-os/resin-device-toolbox/issues/new
