flake: { pkgs, lib, config, ... }: with lib;
let cfg = config.services.zero-ui; in 
{
  options.services.zero-ui = {
    enable = mkEnableOption ("zero-ui ZeroTier Controller UI");
    controllerSecretFile = mkOption {
      type = types.path;
      # No default!
      description = lib.mdDoc ''
        Path to file that contains an environment variable in the format ZU_CONTROLLER_TOKEN=[zerotier controller token].
      '';
    };
  };

  config = mkIf cfg.enable {
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
        EnvironmentFile = cfg.controllerSecretFile;
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
