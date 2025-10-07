{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  # https://devenv.sh/basics/
  env.GREET = "devenv";
  env.CUDA_PATH = "${pkgs.cudatoolkit}";
  env.CUDA_HOME = "${pkgs.cudatoolkit}";
  env.LD_LIBRARY_PATH = "${pkgs.cudatoolkit}/lib:${pkgs.cudatoolkit.lib}/lib:${pkgs.linuxPackages.nvidia_x11}/lib";
  env.NVIDIA_VISIBLE_DEVICES = "all";
  env.NVIDIA_DRIVER_CAPABILITIES = "compute,utility";
  
  # https://devenv.sh/packages/
  packages = with pkgs; [
    git
    cudatoolkit
    cudaPackages.cudnn
    cudaPackages.cutensor
    cudaPackages.nccl
    cudaPackages.cuda_nvcc
    linuxPackages.nvidia_x11
  ];

  # https://devenv.sh/languages/
  languages.python = {
    enable = true;
    package = pkgs.python311;
    uv.enable = true;
    uv.sync.enable = true;
    venv.enable = true;
  };

  # https://devenv.sh/processes/
  # processes.cargo-watch.exec = "cargo-watch";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo hello from $GREET
  '';

  enterShell = ''
    hello
    git --version
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
