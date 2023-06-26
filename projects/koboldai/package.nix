{ aipython3
, lib
, src
, fetchFromGitHub
, lndir
, stateDir ? "$HOME/.koboldai/state"
, libdrm
}:
let
  pythonPackages = aipython3.overrideScope (final: prev: {
    transformers = prev.transformers.overrideAttrs (old: rec {
       propagatedBuildInputs = old.propagatedBuildInputs ++ [ final.huggingface-hub ];
       pname = "transformers";
       version = "4.24.0";
       src = fetchFromGitHub {
         owner = "huggingface";
         repo = pname;
         rev = "refs/tags/v${version}";
         hash = "sha256-aGtTey+QK12URZcGNaRAlcaOphON4ViZOGdigtXU1g0=";
       };
    });
    bleach = prev.bleach.overrideAttrs (old: rec {
       pname = "bleach";
       version = "4.1.0";
       src = fetchFromGitHub {
         owner = "mozilla";
         repo = pname;
         rev = "refs/tags/v${version}";
         hash = "sha256-YuvH8FvZBqSYRt7ScKfuTZMsljJQlhFR+3tg7kABF0Y=";
       };
    });
  });
in pythonPackages.buildPythonPackage {
  pname = "koboldai";
  version = if src ? lastModifiedDate
    then builtins.substring 0 8 src.lastModifiedDate
    else "0";

  # The original kobold-ai program wants to write models settings and user
  # scripts to the current working directory, but tries to write to the
  # /nix/store erroneously due to mismanagement of the current working
  # directory in its source code.
  #
  # The wrapper script we have made for the program will initialize ${stateDir}
  # as an appropriate working directory to run from.

  inherit src;
  patches = [
    ./state-path.patch
  ];

  doCheck = false;
  dontRewriteSymlinks = true;

  passAsFile = [ "setup" "wrapper" ];
  inherit stateDir;
  postPatch = ''
    substituteAll $setupPath setup.py

    substituteAllInPlace aiserver.py \
      --replace 'shutil.rmtree("cache/")' 'shutil.rmtree(CACHE_DIR)' \
      --replace 'cache_dir="cache"' "cache_dir=CACHE_DIR"

    sed -i -e 's|^git\+.*/mkultra$|mkultra|' requirements.txt
  '';

  staticPaths = [
    "colab" "maps" "static" "templates"
    "cores" "extern"
  ];
  sharedPaths = [
    "models" "userscripts" "settings" "stories"
  ];
  inherit (pythonPackages.python) sitePackages;
  postInstall = ''
    substituteAll $wrapperPath $out/bin/koboldai
    chmod +x $out/bin/*

    install -d $out/lib/$pname
    for static_path in $staticPaths *.lua; do
      mv $static_path $out/$sitePackages/
      ln -s $out/$sitePackages/$static_path $out/lib/$pname/
    done

    for shared_path in $sharedPaths; do
      install -d $out/lib/$pname/$shared_path
      if [[ -e $out/$sitePackages/$shared_path ]]; then
        lndir -silent $out/$sitePackages/$shared_path $out/lib/$pname/$shared_path
      fi
    done
  '';

  propagatedBuildInputs = with pythonPackages; [
    bleach
    transformers
    colorama
    flask
    flask-socketio
    flask-session
    eventlet
    dnspython
    markdown
    sentencepiece
    protobuf
    marshmallow
    loguru
    termcolor
    psutil
    torch-bin
    torchvision-bin
    apispec
    apispec-webframeworks
    lupa
    memcached
  ]);

  # See note about consumer GPUs:
  # https://docs.amd.com/bundle/ROCm-Deep-Learning-Guide-v5.4.3/page/Troubleshooting.html
  rocmInit = ''
    if [ ! -e /tmp/nix-pytorch-rocm___/amdgpu.ids ]
    then
        mkdir -p /tmp/nix-pytorch-rocm___
        ln -s ${libdrm}/share/libdrm/amdgpu.ids /tmp/nix-pytorch-rocm___/amdgpu.ids
    fi
    export HSA_OVERRIDE_GFX_VERSION=''${HSA_OVERRIDE_GFX_VERSION-'10.3.0'}
  '';
in
(writeShellScriptBin "koboldai" ''
  if [ -d "/usr/lib/wsl/lib" ]
  then
    echo "Running via WSL (Windows Subsystem for Linux), setting LD_LIBRARY_PATH"
    set -x
    export LD_LIBRARY_PATH="/usr/lib/wsl/lib"
    set +x
  fi
  rm -rf ${tmpDir}
  mkdir -p ${tmpDir}
  mkdir -p ${stateDir}/models ${stateDir}/cache ${stateDir}/settings ${stateDir}/userscripts
  ln -s ${stateDir}/models/   ${tmpDir}/models
  ln -s ${stateDir}/settings/ ${tmpDir}/settings
  ln -s ${stateDir}/userscripts/ ${tmpDir}/userscripts
  ${lib.optionalString (aipython3.torch.rocmSupport or false) rocmInit}
  ${koboldPython}/bin/python ${patchedSrc}/aiserver.py $@
'').overrideAttrs
  (_: {
    meta = {
      maintainers = [ lib.maintainers.matthewcroughan ];
      license = lib.licenses.agpl3;
      description = "browser-based front-end for AI-assisted writing with multiple local & remote AI models";
      homepage = "https://github.com/KoboldAI/KoboldAI-Client";
      mainProgram = "koboldai";
    };
  })
