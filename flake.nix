{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    # This pins requirements.txt provided by zephyr-nix.pythonEnv.
    zephyr.url = "github:zmkfirmware/zephyr/v3.5.0+zmk-fixes";
    zephyr.flake = false;

    # Zephyr sdk and toolchain.
    zephyr-nix.url = "github:nix-community/zephyr-nix";
    zephyr-nix.inputs.nixpkgs.follows = "nixpkgs";
    zephyr-nix.inputs.zephyr.follows = "zephyr";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;}
    {
      imports = [
        inputs.devshell.flakeModule
      ];

      systems = ["x86_64-linux"];
      perSystem = {
        inputs',
        config,
        pkgs,
        ...
      }: {
        devshells.default = {
          packages = with pkgs; [
            (inputs'.zephyr-nix.packages.sdk.override {
              targets = [
                "arm-zephyr-eabi"
              ];
            })
            inputs'.zephyr-nix.packages.pythonEnv
            inputs'.zephyr-nix.packages.hosttools-nix
          ];
        };
        formatter = pkgs.alejandra;
      };
    };
}
