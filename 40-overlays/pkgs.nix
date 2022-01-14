final: prev: {
  pure-prompt = prev.pure-prompt.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./pure-zsh.patch ];
  });

  steampipe = with prev; buildGoModule rec {
    pname = "steampipe";
    version = "0.11.0";

    src = fetchFromGitHub {
      owner = "turbot";
      repo = "steampipe";
      rev = "v${version}";
      sha256 = "sha256-P/Fys9/V71+VL5Az3EGGaW+tdeQbr2wO+jvVSVZmJT0=";
    };

    vendorSha256 = "sha256-PYaq74NNEOJ1jZ6PoS6zcTiUN4JA9JDjO7GB9tqgT6c=";

    doCheck = false;

    nativeBuildInputs = [ installShellFiles ];

    ldflags = [
      "-s"
      "-w"
    ];

    postInstall = ''
      INSTALL_DIR=$(mktemp -d)
      installShellCompletion --cmd steampipe \
        --bash <($out/bin/steampipe --install-dir $INSTALL_DIR completion bash) \
        --fish <($out/bin/steampipe --install-dir $INSTALL_DIR completion fish) \
        --zsh <($out/bin/steampipe --install-dir $INSTALL_DIR completion zsh)
    '';

    meta = with lib; {
      homepage = "https://steampipe.io/";
      description = "select * from cloud;";
      license = licenses.agpl3;
      maintainers = with maintainers; [ hardselius ];
    };
  };

  yubikey-manager = with prev; python3Packages.buildPythonPackage rec {
    pname = "yubikey-manager";
    version = "4.0.7";

    src = fetchFromGitHub {
      repo = "yubikey-manager";
      rev = version;
      owner = "Yubico";
      sha256 = "sha256-PG/mIM1rcs1SAz2kfQtfUWoMBIwLz2ASZM0YQrz9w5I=";
    };

    postPatch = ''
      substituteInPlace "ykman/pcsc/__init__.py" \
        --replace '/usr/bin/pkill' '${procps}/bin/pkill'
    '';

    format = "pyproject";

    nativeBuildInputs = with python3Packages; [ poetry-core ];

    propagatedBuildInputs =
      with python3Packages; [
        click
        cryptography
        pyscard
        pyusb
        pyopenssl
        six
        fido2
      ] ++ [
        libu2f-host
        libusb1
        yubikey-personalization
      ];

    makeWrapperArgs = [
      "--prefix"
      "LD_LIBRARY_PATH"
      ":"
      (lib.makeLibraryPath [ libu2f-host libusb1 yubikey-personalization ])
    ];

    postInstall = ''
      mkdir -p "$out/man/man1"
      cp man/ykman.1 "$out/man/man1"

      mkdir -p $out/share/bash-completion/completions
      _YKMAN_COMPLETE=source $out/bin/ykman > $out/share/bash-completion/completions/ykman || :
      mkdir -p $out/share/zsh/site-functions/
      _YKMAN_COMPLETE=source_zsh "$out/bin/ykman" > "$out/share/zsh/site-functions/_ykman" || :
      substituteInPlace "$out/share/zsh/site-functions/_ykman" \
        --replace 'compdef _ykman_completion ykman;' '_ykman_completion "$@"'
    '';

    checkInputs = with python3Packages; [ pytestCheckHook makefun ];

    meta = with lib; {
      homepage = "https://developers.yubico.com/yubikey-manager";
      description = "Command line tool for configuring any YubiKey over all USB transports";

      license = licenses.bsd2;
      platforms = platforms.unix;
      maintainers = with maintainers; [ hardselius ];
    };
  };

  atlantis = with prev; buildGoModule rec {
    pname = "atlantis";
    version = "0.17.4";

    src = fetchFromGitHub {
      owner = "runatlantis";
      repo = "atlantis";
      rev = "v${version}";
      sha256 = "sha256-QXFUvYUslhwQOiDo9SIMrTjI1sKUv5+6oiVfQbqewNg=";
    };

    vendorSha256 = "sha256-jZ5QHxUTDVdhCNbCk6Be+zuuXHodYOEcB3braDgH9uM=";

    doCheck = false;

    subPackages = [ "." ];

    meta = with lib; {
      homepage = "https://github.com/runatlantis/atlantis";
      description = "Terraform Pull Request Automation";
      license = licenses.asl20;
      maintainers = with maintainers; [ jpotier ];
    };
  };

  jsonnet-language-server = with prev; buildGoModule rec {
    pname = "jsonnet-language-server";
    version = "0.6.3";

    src = fetchFromGitHub {
      owner = "grafana";
      repo = "jsonnet-language-server";
      rev = "v${version}";
      sha256 = "sha256-nJlw3RiZWdLmJdrfKlty0Fnn+g+UwkCNNBxVQMp8erI=";
    };

    vendorSha256 = "sha256-mGocX5z3wf9KRhE9leLNCzn8sVdjKJo6FzgP1OwQB3M=";

    meta = with lib; {
      homepage = "https://github.com/grafana/jsonnet-language-server";
      description = "A Language Server Protocol (LSP) server for Jsonnet (https://jsonnet.org)";
      license = licenses.agpl3Only;
      maintainers = with maintainers; [ hardselius ];
    };
  };
}
