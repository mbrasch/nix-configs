{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [ htop ];

  users.extraUsers.root.password = "topsecret";

}
