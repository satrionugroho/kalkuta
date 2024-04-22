{ pkgs, ... }:

{
  # See full reference at https://devenv.sh/reference/options/
  packages = with pkgs; [
    cmake
    zstd
    libyaml
    libsodium
    openssl
    elixir_1_16
    erlang_25
    elixir_ls
    xz
    zstd
  ];

  enterShell = ''
    export MIX_HOME=$(PWD)/.mix
    export HEX_HOME=$(PWD)/.mix
    export PATH=$PATH:$MIX_HOME/bin:$MIX_HOME/escripts
    export DATABASE_USERNAME=$(whoami)
    export DATABASE_HOSTNAME=localhost
    export DATABASE_NAME=berlin_dev
    export AUTH_TOKEN=MmnOFhnY0iD5ome7Lptjfahc68RywlDhIKYiddfevYqwcV0LjQmmS1imoJPR2z0w
    export GOPATH=$(PWD)/.golang
    [ -d $PWD/.bin ] && export PATH=$PWD/.bin:$PATH
    [ -d $PWD/.golang/bin ] && export PATH=$PWD/.golang/bin:$PATH
  '';

  languages.go.enable = true;
  languages.zig.enable = true;

  process.implementation = "process-compose";

  services.postgres = {
    enable = true;
    extensions = extensions: [
    ];
    initialDatabases = [
      { name = "kalkuta_dev"; }
      { name = "kalkuta_test"; }
    ];
    package = pkgs.postgresql_14;
    listen_addresses = "*";
  };
}
