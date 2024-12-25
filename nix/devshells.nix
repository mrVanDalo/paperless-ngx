{ inputs, ... }:
{

  imports = [ inputs.devshell.flakeModule ];

  perSystem =
    {
      pkgs,
      self',
      system,
      config,
      lib,
      ...
    }:

    let
      # steam-run is the fhsEnv we need to make pipenv find it's dependencies.
      steamrun =
        (pkgs.steam.override {
          extraPkgs = pkgs: [
            pkgs.pkg-config
            pkgs.python312Packages.mysqlclient
            pkgs.mysql-client
            pkgs.libmysqlclient
          ];
          extraLibraries = pkgs: [
            pkgs.mysql-client
            pkgs.libmysqlclient
          ];
        }).run;

    in
    {

      # allow unfree packages to be installed
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      devshells.default = {

        commands = [
          {
            help = "pipen install";
            name = "pipenv-install";
            command = ''${steamrun}/bin/steam-run pipenv install "$@"'';
          }
        ];

        packages = [
          # packages used in commands or in devshell
        ];
      };
    };
}
