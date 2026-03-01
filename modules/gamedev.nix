{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    godot
    blender
  ];
}
