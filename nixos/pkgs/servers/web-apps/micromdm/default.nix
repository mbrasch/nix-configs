{ lib, stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "micromdm";
  version = "1.8.0";
  sha256 = "9b4d96afba0d4086473b29466eeec2a485899361";

  src = fetchFromGitHub {
    owner = "micromdm";
    repo = ${pname};
    rev = "v${version}";
    sha256 = ${sha256};
    #fetchSubmodules = true;
  };

  #runVend = true;
  #vendorSha256 = "06hl1npwmy9dvpf4kljvw8lwwiigm52wf106lmf9k6k2gi5ikprz";

  #buildFlagsArray = '''';
  ldflags = [ "-s" "-w" "-X main.Version=v${version}" ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  doCheck = !stdenv.isDarwin;

  meta = with lib; {
    description = "MDM for MacOS clients.";
    longDescription = ''
      MicroMDM is a project which provides an open source Mobile Device Management server for Apple devices.
      Our goal is to create a performant and extensible device management solution for enterprise and education.
    '';
    homepage = "https://micromdm.io/";
    #configure: The current version [...] can only be built on 64bit platforms
    platforms = [ "x86_64-linux" ];
    license = licenses.mit;
    changelog = "https://github.com/micromdm/${pname}/releases/tag/v${version}"
  };
}
