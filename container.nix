{ config, pkgs, lib, ... }: cfg:
with lib;

let
  mkContainers = containers: map mkContainer containers;

  mkNetworking = container: {
    hostName = container.hostName;
    firewall = {
      enable = true;
      allowedTCPPorts = container.allowedTCPPorts;
    };
  };

  mkPackages = container: with pkgs;
    let
      mkDefaultPackages = [
          vim git wget
          rxvt_unicode
      ];

      mkWebserverPackages = container: if (container.type == "php-fpm") then [
          php
          phpPackages.composer
          phpPackages.imagick
          phpPackages.memcached
          phpPackages.xdebug
        ] else [];
    in
    mkDefaultPackages ++ mkWebserverPackages container ++ container.packages;

  mkSshServer = container: {
      enable = true;
      listenAddresses = [{
        addr = "${container.net}.1";
        port = 22;
      }];
  };

  mkMySql = container: {
    enable = true;
    package = pkgs.mariadb;
    extraOptions = ''
      max_allowed_packet=40000000
      innodb_buffer_pool_size=500M
    '';
  };

  mkWebserver = "";

  # todo: move these two into nginx
  mkPhpFpm = container: {
    phpPackage = pkgs.php;
    phpOptions = import ./php/php.ini.nix pkgs;
    poolConfigs.nginx = container.server.phpPool;
  };

  mkNginx = container: {
    enable = true;
    user = container.user;
    group = container.user;
    recommendedOptimisation = container.server.recommendedSettings;
    recommendedTlsSettings = container.server.recommendedSettings;
    recommendedGzipSettings = container.server.recommendedSettings;
    recommendedProxySettings = container.server.recommendedSettings;
    virtualHosts = container.server.vhosts;
  };

  mkServices = container: {
    openssh = mkSshServer container;

    mysql = mkMySql container;

    # todo: takes part in the nginx config
    phpfpm = mkPhpFpm container;

    nginx = mkNginx container;
  };

  mkUser = container: import ./user.nix container.user;

  mkContainer = name: container:
    nameValuePair (name) ({
      privateNetwork = true;
      hostAddress = "${container.net}.1";
      localAddress = "${container.net}.${container.lastOctave}";

      bindMounts = container.bindMounts;

      config = { config, pkgs, ...}:
      {
        networking = mkNetworking container;

        programs.zsh.enable = true;

        environment.systemPackages = mkPackages container;

        services = mkServices container;

        users = mkUser container;
      };
    });

in

mapAttrs' (mkContainer) cfg
