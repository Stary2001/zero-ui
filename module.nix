flake: { pkgs, lib, config, ... }: with lib;
{
  options.services.zero-ui = {
    enable = mkEnableOption ("zero-ui ZeroTier Controller UI");
  };

  config = mkIf config.services.zero-ui.enable {
    systemd.services.zero-ui = {
      description = "ZeroTier Controller UI";
      environment = {
        NODE_ENV = "production";
        # TODO: options for these?
        ZU_SERVE_FRONTEND = "false";
        ZU_SECURE_HEADERS = "false";
        ZU_DEFAULT_USERNAME = "admin";
        ZU_DEFAULT_PASSWORD = "admin";
        ZU_DATAPATH = "/var/lib/zero-ui/db.json";
      };
      serviceConfig = {
        ExecStart = "${flake.packages.${pkgs.stdenv.hostPlatform.system}.default}/libexec/zero-ui/backend/bin/www";
        WorkingDirectory = "${flake.packages.${pkgs.stdenv.hostPlatform.system}.default}/libexec/zero-ui/backend";
        User = "zero-ui";
        StateDirectory = "zero-ui";
        # TODO: add ZU_CONTROLLER_TOKEN somehow
      };
    };

    users.users.zero-ui = {
      group = "zero-ui";
      description = "zero-ui user";
      isSystemUser = true;
    };
    users.groups.zero-ui = {};
  };
}
