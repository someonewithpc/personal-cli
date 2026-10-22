self:
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.personal;
in
{
  options.programs.personal = {
    enable = lib.mkEnableOption "the personal CLI";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      defaultText = lib.literalExpression "personal-cli.packages.\${system}.default";
      description = "The personal package to install.";
    };

    url = lib.mkOption {
      type = lib.types.str;
      example = "https://example.com";
      description = "The site the CLI talks to.";
    };

    emails = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "My addresses, so `personal watch` skips my own mail replies.";
    };

    freedesktopUsername = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "My gitlab.freedesktop.org username, so `personal watch` skips my own MR comments.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."personal/config.json".text = builtins.toJSON (
      {
        inherit (cfg) url emails;
      }
      // lib.optionalAttrs (cfg.freedesktopUsername != null) {
        freedesktop_username = cfg.freedesktopUsername;
      }
    );
  };
}
