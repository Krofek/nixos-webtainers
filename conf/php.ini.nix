pkgs:
''
  date.timezone = "Europe/Ljubljana"
  zend_extension = "${pkgs.phpPackages.xdebug}/lib/php/extensions/xdebug.so"
  max_execution_time = 30
  post_max_size = 100M
  upload_max_size = 200M
  upload_max_filesize = 20M
  memory_limit = 512M
''
