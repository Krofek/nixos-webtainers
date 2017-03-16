{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.tools.webtainers;

  extraHosts = containers: concatStringsSep "\n" (mapAttrsToList (name: container: ''
      # Container: ${name}
      ${container.net}.${container.lastOctave} ${container.hostName}
  '') containers);

  extraHostsOpts = ''
    ############################################################
    ### Webservers in containers service extra hosts options ###
    ############################################################

    ${extraHosts cfg}
  '';

  cfgOptions = import ./options.nix {
    inherit lib;
    inherit config;
    inherit pkgs;
  };

  mkContainers = import ./container.nix {
    inherit lib;
    inherit config;
    inherit pkgs;
  } cfg;

in
{
  options = {
    tools = {
      # as attribute sets.
      webtainers = mkOption {
        default = {};
        type = types.attrsOf (types.submodule cfgOptions.containersOpts);
        example = ''
          "tests" = {
            lastOctave = "12";
            bindMounts = {
                "/var/www/tests.local" = {
                  hostPath = "/home/krofek/projects/tests";
                  isReadOnly = false;
                };
            };
          };
        '';
      };
    };
  };

  config = {
    environment.etc.hosts.text = extraHostsOpts;

    containers = mkContainers;
  };


}
