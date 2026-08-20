{ stdenvNoCC }:
stdenvNoCC.mkDerivation {
  pname = "nyx-grub-theme";
  version = "1";
  src = ./.;
  installPhase = "mkdir -p $out; cp -r ./* $out/";
}
