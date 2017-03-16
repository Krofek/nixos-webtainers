# Nginx server users
user:
{
  extraUsers = {
    "${user}" = {
      password = "webserv";
      group = user;
      uid = 33;
      createHome = true;
      home = "/home/${user}";
      extraGroups = [ "users" "wheel" ];
      shell = "/run/current-system/sw/bin/zsh";
      isNormalUser = true;
    };
  };

  extraGroups."${user}".gid = 33;
}
