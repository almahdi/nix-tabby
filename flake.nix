{
  description= "Tabby using Nix Flake";
  inputs={
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs, ... }:
  {
    packages.x86_64-linux.tabby = let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      name = "tabby";
      version = "1.0.205";
      src = pkgs.fetchurl {
        url = "https://github.com/Eugeny/tabby/releases/download/v1.0.205/tabby-1.0.205-linux-x64.AppImage";
        sha256 = "sha256-dlfClBbwSkQg4stKZdSgNg3EFsWksoI21cxRG5SMrOM=";
      };
      appimageContents = pkgs.appimageTools.extractType2 { inherit name src; };
    in
    pkgs.appimageTools.wrapType2 {
      inherit name version src;
      extraInstallCommands = ''
        install -m 444 -D ${appimageContents}/tabby.desktop $out/share/applications/tabby.desktop
        install -m 444 -D ${appimageContents}/tabby.png $out/share/icons/hicolor/512x512/apps/tabby.png
        substituteInPlace $out/share/applications/tabby.desktop \
    	  --replace 'Exec=AppRun --no-sandbox %U' 'Exec=${name} %U'
      '';
    };

    packages.x86_64-linux.default = self.packages.x86_64-linux.tabby;
    apps.x86_64-linux.tabby = {
      type = "app";
      program = "${self.packages.x86_64-linux.tabby}/bin/tabby";
    };
    apps.x86_64-linux.default = self.apps.x86_64-linux.tabby;
  };
}
