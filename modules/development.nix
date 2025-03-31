{pkgs, ...}: {
  environment.shellAliases = {
    gch = "git checkout";
    gd = "git diff";
    gdc = "git diff --cached";
    gdh = "git diff HEAD";
    gl = "git log";
    glp = "git log -p";
    gp = "git push";
    gpf = "git push --force-with-lease";
    gst = "git status";
    # gsw = "git checkout master-stable && git pull && git checkout";
    # rbm = "git fetch origin master && git rebase origin/master";
  };

  environment.systemPackages = with pkgs; [
    curl
    nest-cli
    nodejs
    python3
    sqlite
    yarn
  ];

  services.snap.enable = true;
}
