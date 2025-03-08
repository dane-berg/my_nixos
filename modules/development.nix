{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nodejs
    python3
    # TODO: setup syntax highlighting using https://gist.github.com/wmertens/9f0f1db0e91bc5e3e430
    sublime
  ];
}
