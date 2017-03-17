{lib, pkgs, ...}:
with lib;

config:
{
    # recommended settings
    recommendedSettings = mkOption {
      type = types.bool;
      default = true;
    };

    phpPool = mkOption {
      type = types.lines;
      default = ''
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

    # vhosts options
    vhosts = mkOption {
      type = types.attrsOf (types.submodule (
        # todo: This needs a fix asap.
        import ../nixpkgs/nixos/modules/services/web-servers/nginx/vhost-options.nix {
          inherit lib;
        }));
      default = import ./php/nginx.default.nix pkgs config.hostName;
    };

  }
