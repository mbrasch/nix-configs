{ pkgs, stdenv, lib, fetchFromGitHub, dataDir ? "/var/lib/munkireport" }:

let
  package = (import ./composition.nix {
    inherit pkgs;
    inherit (stdenv.hostPlatform) system;
    noDev = true; # Disable development dependencies
  }).overrideAttrs (attrs : {
    installPhase = attrs.installPhase + ''
      rm -R $out/storage $out/public/uploads
      ln -s ${dataDir}/.env $out/.env
      ln -s ${dataDir}/storage $out/storage
      ln -s ${dataDir}/public/uploads $out/public/uploads
    '';
  });

in package.override rec {
  pname = "munkireport-php";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "munkireport";
    repo = pname;
    rev = "v${version}";
    sha256 = "";
  };

  meta = with lib; {
    description = "MunkiReport is a reporting client for macOS.";
    longDescription = ''
      MunkiReport is a reporting client for macOS. While originally dependent on Munki,
      MunkiReport is now able to run stand-alone or to be coupled with Munki, Jamf or
      other macOS management solutions.
    '';
    homepage = "https://github.com/munkireport/munkireport-php";
    license = licenses.mit;
    maintainers = with maintainers; [ mbrasch ];
    platforms = platforms.linux;
  };
}
