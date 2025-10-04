{pkgs, ...}: {
  environment.shellAliases = {
    add = "git add .";
    gch = "git checkout";
    gd = "git diff";
    gdc = "git diff --cached";
    gdh = "git diff HEAD";
    glo = "git log --oneline";
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
    python313
    sqlite
    typescript
    yarn
  ];

  services.snap.enable = true;
}
