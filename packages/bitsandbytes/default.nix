{ lib
, buildPythonPackage
, fetchFromGitHub
, torch
, cudaPackages
, cudaPackageSets ? { inherit cudaPackages; }
}: let
  formatVersion = lib.replaceStrings [ "." ] [ "" ];
  makeWithFlags = make: ''
    _accumFlagsArray makeFlags makeFlagsArray buildFlags buildFlagsArray
    ${make}
    unset flagsArray
  '';
  buildLib = { cudaVersion, cudatoolkit,... }@cudaPackages: let
    buildver =
      if cudaVersion == "9.2" then "92"
      else if lib.versionAtLeast cudaVersion "11.8" then "12x"
      else if cudaVersion == "11.0" then "110"
      else "11x";
    targets = if cudaVersion == "9.2" then [ "cuda${buildver}" ]
      else [ "cuda${buildver}" "cuda${buildver}_nomatmul" ];
  in makeWithFlags ''
    flagsArray+=(
      CUDA_VERSION=${formatVersion cudaVersion}
      CUDA_HOME=${cudatoolkit}
      NIX_LDFLAGS="$NIX_LDFLAGS -L${cudatoolkit.lib}/lib"
    )
    echoCmd 'build ${toString targets} flags' "''${flagsArray[@]}"
    make "''${flagsArray[@]}" ${toString targets}
  '';
in buildPythonPackage rec {
  pname = "bitsandbytes";
  version = "20230202";
  src = fetchFromGitHub {
    owner = "telpirion";
    repo = pname;
    rev = "fa12c9c8af91f1764a87bb76ab597cb1124e69d4";
    sha256 = "sha256-5WNR4lm8PCl6vUZvpRCqPb1Pr4ZadgMjMOHuSzB27M4=";
  };

  makeFlags = [ "GPP=g++" ];
  preBuild = makeWithFlags ''
    echoCmd 'build cpuonly flags' "''${flagsArray[@]}"
    make cpuonly "''${flagsArray[@]}" CUDA_VERSION=CPU
  '' + lib.concatMapStringsSep "\n" buildLib (lib.attrValues cudaPackageSets);

  nativeBuildInputs = [
    cudaPackages.backendStdenv.cc
  ];

  checkInputs = [
    torch
  ];

  doCheck = false;
}
