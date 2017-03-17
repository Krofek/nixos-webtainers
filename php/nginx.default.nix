# Default php nginx config
pkgs: hostname:
{
  "${hostname}" = {
    default = true;
    enableSSL = false;
    forceSSL = false;
    enableACME = false;
    serverName = hostname;
    serverAliases = [ "www.${hostname}" ];
    root = "/var/www/${hostname}/public";

    extraConfig = "index index.html index.htm index.php;";

    locations = {
      "/" = {
        tryFiles = "$uri $uri/ /index.php?$query_string";
      };

      "~ \\.php$" = {
        tryFiles = "$uri /index.php =404";
        extraConfig = ''
          include ${pkgs.nginx}/conf/fastcgi_params;
          fastcgi_split_path_info ^(.+\.php)(/.+)$;
          fastcgi_pass 127.0.0.1:9000;
          fastcgi_index index.php;
          fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        '';
      };
    };
  };
}
