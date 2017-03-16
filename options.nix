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

  webserverOpts = { name, config, ... }: {
    options = {
      # recommended settings
      recommendedSettings = mkOption {
        type = types.bool;
        default = true;
      };

      # cfg.user will not work. Will need mapping each attribute set to list and
      # use the containers.configs' user.
      phpPool = mkOption {
        type = types.lines;
        default = '''';
      };

      # vhosts options
      vhosts = mkOption {
        type = type.attrsOf (types.submodule (
          import ../nixpkgs/nixos/modules/services/web-servers/nginx/vhost-options.nix {
            inherit lib;
          }));
        default = {};
      };

    };
  };

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
        default = "container.local";
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
      server = mkOption {
        type = types.attrsOf (types.submodule webserverOpts);
        default = {
          vhosts = import ./conf/nginx.default.nix pkgs config.hostName;
          recommendedSettings = true;
          phpPool = ''
            listen = 127.0.0.1:9000
            listen.owner = ${config.user}
            listen.group = ${config.user}
            user = ${config.user}
            pm = dynamic
            pm.max_children = 75
            pm.start_servers = 10
            pm.min_spare_servers = 5
            pm.max_spare_servers = 20
            pm.max_requests = 500
          '';
        };
      };
    };

    config = {
      name = mkDefault name;
    };
  };

}
