{ pkgs, lib, ... }:

{
  imports = [ ./bootstrap.nix ];

  environment = {
    systemPackages = with pkgs;
      [
        #terminal-notifier
        #alacritty
      ];
  };

  programs.bash = { enable = true; };

  system = {
    defaults = {
      LaunchServices = { LSQuarantine = false; };

      NSGlobalDomain = {
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = true;
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 20;
        KeyRepeat = 1;

        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;

        NSDisableAutomaticTermination = false;
        NSDocumentSaveNewDocumentsToCloud = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;

        NSScrollAnimationEnabled = true;
        NSTableViewDefaultSizeMode = 1; # 1 small, 2 medium, 3 large
        NSWindowResizeTime = "0.20";
        _HIHideMenuBar = false;

        #com.apple = {
        #  keyboard.fnState = true; # false = F-keys
        #  mouse.tapBehavior = 1; # null or 1 for tap to click
        #  sound.beep.feedback = 0; # 1 = audio feedback when changing volume
        #  sound.beep.volume = "0.0"; # 0.0 to 1.0
        #  springing.enabled = true;
        #  springing.delay = "1.0";
        #  swipescrolldirection = true; # true = natural direction
        #  trackpad.enableSecondaryClick = true;
        #};
      };

      dock = {
        autohide = true;
        autohide-delay = "0.25";
        autohide-time-modifier = "1.0";
        dashboard-in-overlay = true; # true = hide dashboard

        expose-animation-duration = "1.0";
        expose-group-by-app = true;

        launchanim = true;
        orientation = "bottom"; # "bottom", "left", "right" or null
        enable-spring-load-actions-on-all-items = true;
        mineffect = "scale"; # "genie", "suck", "scale" or null
        minimize-to-application = false;
        mouse-over-hilite-stack = true;
        mru-spaces =
          false; # true = automatically rearrange spaces based on most recent use
        show-process-indicators = true;
        show-recents = false;
        showhidden = true;
        static-only = false; # true = show only open applications
        tilesize = 48;
      };

      finder = {
        AppleShowAllExtensions = true;
        QuitMenuItem = true;
        FXEnableExtensionChangeWarning = false;
      };

      loginwindow = {
        DisableConsoleAccess = false;
        GuestEnabled = false;
        LoginwindowText = "Die Power von nix.";
        PowerOffDisabledWhileLoggedIn = false;
        RestartDisabled = false;
        RestartDisabledWhileLoggedIn = false;
        SHOWFULLNAME = false; # true = login via name and password field
        ShutDownDisabled = false;
        ShutDownDisabledWhileLoggedIn = false;
        SleepDisabled = false;
        autoLoginUser = null;
      };

      screencapture = {
        location = null; # path as string
        disable-shadow = false;
      };

      trackpad = {
        ActuationStrength = 1; # 0 = silent clicking
        Clicking = true; # 1 = tap to click
        FirstClickThreshold =
          null; # normal click: 0 for light clicking, 1 for medium, 2 for firm
        SecondClickThreshold =
          null; # force touch: 0 for light clicking, 1 for medium, 2 for firm
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = false;
      };

      # keyboard = {
      #   enableKeyMapping = false;
      #   nonUS.remapTilde = false;
      #   remapCapsLockToControl = true;
      #   remapCapsLockToEscape = false;
      # };
    };
  };
}
