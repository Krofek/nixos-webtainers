# Nixos-Webtainers

## About

This is an extension for NixOs containers. The tool offers an easy (nix declarative)
way to setup NixOs containers with a presetup webserver mostly meant for web development purposes. Creates also an additional `/etc/hosts` entry with the selected hostName
or name with a .local suffix.

Features:

* nginx
* php-fpm
* mysql + mariadb
* ssh server
* ...

## Instructions

Include the `default.nix` in your NixOs configuration within imports usually.
Check additional possible options in `options.nix`.

#### Example:

```nix
{ config, pkgs, ... }:

{
  imports = [
    ./nixos-webtainers/default.nix
  ];

  tools.webtainers = {
    "tests" = {
      net = "192.168.11"; # optional
      lastOctave = "12";
      bindMounts = {
        "/var/www/tests.local" = {
          hostPath = "/home/alice/projects/tests";
          isReadOnly = false;
        };
      };
      hostName = "tests.local"; # optional
    };
  };
}
```
