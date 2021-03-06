{ pkgs, stdenv, lib, fetchFromGitHub, dataDir ? "/var/lib/munki" }:

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
  pname = "Munki";
  version = "5.6.3";

  src = fetchFromGitHub {
    owner = "munki";
    repo = pname;
    rev = "v${version}";
    sha256 = "1bfwpvawa3pxpdsdbi3nxpjpdv2z1jmv7nk6cs9gs0210jlairsz";
  };

  meta = with lib; {
    description = "A platform to create documentation/wiki content built with PHP & Laravel";
    longDescription = ''
      A platform for storing and organising information and documentation.
      Details for BookStack can be found on the official website at https://www.bookstackapp.com/.
    '';
    homepage = "https://www.munki.org/munki/";
    license = licenses.mit;
    maintainers = with maintainers; [ ymarkus ];
    platforms = platforms.linux;
  };
}
