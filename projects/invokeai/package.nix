{ aipython3
# misc
, lib
, src
, fetchFromGitHub
# extra deps
, libdrm
}:

let
  pythonPackages = aipython3.overrideScope (final: prev: {
    transformers = prev.transformers.overrideAttrs (old: rec {
       propagatedBuildInputs = old.propagatedBuildInputs ++ [ final.huggingface-hub ];
       version = "4.26.1";
       src = fetchFromGitHub {
         owner = "huggingface";
         repo = old.pname;
         rev = "refs/tags/v${version}";
         hash = "sha256-JRW3uSPgWgvtH4WFQLHD1ma8L1qq05MSemJbcdYMC6E=";
       };
    });
  });
  getVersion = lib.flip lib.pipe [
    (src: builtins.readFile "${src}/ldm/invoke/_version.py")
    (builtins.match ".*__version__='([^']+)'.*")
    builtins.head
  ];
in

pythonPackages.buildPythonPackage {
  pname = "InvokeAI";
  format = "pyproject";
  version = getVersion src;
  inherit src;
  propagatedBuildInputs = with pythonPackages; [
    numpy
    dnspython
    albumentations
    opencv4
    pudb
    imageio
    imageio-ffmpeg
    compel
    npyscreen
    pytorch-lightning
    protobuf
    omegaconf
    test-tube
    streamlit
    einops
    taming-transformers-rom1504
    torch-fidelity
    torchmetrics
    transformers
    kornia
    k-diffusion
    picklescan
    diffusers
    pypatchmatch
    realesrgan
    pillow
    send2trash
    fastapi
    fastapi-events
    fastapi-socketio
    peft
    python-multipart
    flask
    flask-socketio
    flask-cors
    dependency-injector
    gfpgan
    eventlet
    clipseg
    getpass-asterisk
    safetensors
    datasets
    packaging
  ];
  nativeBuildInputs = [ pythonPackages.pythonRelaxDepsHook ];
  pythonRemoveDeps = [ "clip" "pyreadline3" "flaskwebgui" "opencv-python" ];
  pythonRelaxDeps = [ "dnspython" "protobuf" "flask" "flask-socketio" "pytorch-lightning" "fastapi" ];
  makeWrapperArgs = [
    '' --run '
      if [ -d "/usr/lib/wsl/lib" ]
      then
          echo "Running via WSL (Windows Subsystem for Linux), setting LD_LIBRARY_PATH=/usr/lib/wsl/lib"
          set -x
          export LD_LIBRARY_PATH="/usr/lib/wsl/lib"
          set +x
      fi
      '
    ''
  ] ++ lib.optionals (pythonPackages.torch.rocmSupport or false) [
    '' --run '
      if [ ! -e /tmp/nix-pytorch-rocm___/amdgpu.ids ]
      then
          mkdir -p /tmp/nix-pytorch-rocm___
          ln -s ${libdrm}/share/libdrm/amdgpu.ids /tmp/nix-pytorch-rocm___/amdgpu.ids
      fi
      '
    ''
    # See note about consumer GPUs:
    # https://docs.amd.com/bundle/ROCm-Deep-Learning-Guide-v5.4.3/page/Troubleshooting.html
    " --set-default HSA_OVERRIDE_GFX_VERSION 10.3.0"
  ];
  patchPhase = ''
    runHook prePatch

    # Add subprocess to the imports
    substituteInPlace ./ldm/invoke/config/invokeai_configure.py --replace \
        'import shutil' \
'
import shutil
import subprocess
'
    # shutil.copytree will inherit the permissions of files in the /nix/store
    # which are read only, so we subprocess.call cp instead and tell it not to
    # preserve the mode
    substituteInPlace ./ldm/invoke/config/invokeai_configure.py --replace \
      "shutil.copytree(configs_src, configs_dest, dirs_exist_ok=True)" \
      "subprocess.call('cp -r --no-preserve=mode {configs_src} {configs_dest}'.format(configs_src=configs_src, configs_dest=configs_dest), shell=True)"
    runHook postPatch
  '';
  postFixup = ''
    chmod +x $out/bin/*
    wrapPythonPrograms
  '';
  doCheck = false;
  meta = {
    description = "Fancy Web UI for Stable Diffusion";
    homepage = "https://invoke-ai.github.io/InvokeAI/";
    mainProgram = "invoke.py";
  };
}
