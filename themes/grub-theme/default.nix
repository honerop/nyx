{ stdenvNoCC }:
stdenvNoCC.mkDerivation {
  pname = "nux-grub-theme";
  version = "1";
  src = ./.;
  installPhase = "mkdir -p $out; cp -r ./* $out/";
}
