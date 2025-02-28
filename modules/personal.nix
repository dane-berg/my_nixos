{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    discord
    obsidian
  ];
}
