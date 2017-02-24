# 0.0.9

* rdt ssh: default to /bin/bash if it exists

# 0.0.8

* Use denymount module to fix "Resource busy" error when configuring SD Card

# 0.0.7

* scan: add a '--timeout' parameter to 'scan' to allow for extended scan periods

# 0.0.6

* scan: fix missing discoverLocalResinOsDevices() method

# 0.0.5

* logs: follow if container is running, only print logs otherwise
* logs: truncate long uuid and show container status in "logs"
* logs: list all containers, including those not running
* push: support environment variable setting
* code refactoring

# 0.0.4

* Implement 'scan' command
* Add missing package.json dependencies
* Rename ResinOS -> resinOS

# 0.0.3

* flash: lazy-load ES6 modules with babel require hook
* Typo fixes
* Add README.md

# 0.0.2

* flash: fix image flash confirmation

# 0.0.1

* Initial release
