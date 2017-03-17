{ config, pkgs, lib, ... }:
with lib;

let
  # copied from containers.nix
  bindMountOpts = { name, config, ... }: {

    options = {
      mountPoint = mkOption {
        example = "/mnt/usb";
        type = types.str;
        description = "Mount point on the container file system.";
      };
      hostPath = mkOption {
        default = null;
        example = "/home/alice";
        type = types.nullOr types.str;
        description = "Location of the host path to be mounted.";
      };
      isReadOnly = mkOption {
        default = true;
        example = true;
        type = types.bool;
        description = "Determine whether the mounted path will be accessed in read-only mode.";
      };
    };

    config = {
      mountPoint = mkDefault name;
    };

  };

  webserverOpts = config: if (config.type == "php-fpm")
    then import ./php-fpm-options.nix {
        inherit lib;
        inherit config;
        inherit pkgs;
      } config
    else throw "Only php-fpm type is available atm.";

in
{
  containersOpts = { name, config, ... }: {
    options = {

      name = mkOption {
        type = types.str;
      };

      user = mkOption {
        type = types.str;
        default = "webserv";
      };

      enableSsh = mkOption {
        type = types.bool;
        default = false;
      };

      net = mkOption {
        type = types.str;
        default = "192.168.11";
      };

      database = mkOption {
        type = types.str;
        default = "mysql";
      };

      lastOctave = mkOption {
        type = types.str;
        default = "11";
      };

      hostName = mkOption {
        type = types.str;
        default = "${config.name}.local";
      };

      bindMounts = mkOption {
        type = types.attrsOf (types.submodule bindMountOpts);
        default = {};
        example = {
          "/home" = {
            hostPath = "/home/alice";
            isReadOnly = false;
          };
        };
        description = ''
          An extra list of directories that is bound to the container.
        '';
      };

      type = mkOption {
        type = types.str;
        default = "php-fpm";
      };

      allowedTCPPorts = mkOption {
        type = types.listOf types.int;
        default = [ 80 443 ];
      };

      packages = mkOption {
        type = types.listOf types.string;
        default = [];
      };

      # match the appropriate config options. For now the phpFpm ones are hardcoded
      server = webserverOpts config;
    };

    config = {
      name = mkDefault name;
    };
  };

}
