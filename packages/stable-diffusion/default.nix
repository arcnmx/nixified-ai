{
  buildPythonPackage
, pythonRelaxDepsHook
, fetchFromGitHub

, torch
, torchvision
, numpy

, albumentations
, opencv4
, pudb
, imageio
, imageio-ffmpeg
, pytorch-lightning
, omegaconf
, test-tube
, streamlit
, einops
, taming-transformers-rom1504
, torch-fidelity
, torchmetrics
, transformers
, kornia
, k-diffusion
}:
buildPythonPackage rec {
  pname = "stable-diffusion";
  version = "2022-11-16";

  src = fetchFromGitHub {
    owner = "CompVis";
    repo = pname;
    rev = "21f890f9da3cfbeaba8e2ac3c425ee9e998d5229";
    sha256 = "sha256-zrjiFOQM5uTTCRtaHfX/fUW2INbroCD96guJSMdaKyI=";
  };

  nativeBuildInputs = [ pythonRelaxDepsHook ];
  pythonRelaxDeps = [
    "transformers"
  ];

  propagatedBuildInputs = [
    torch
    torchvision
    numpy

    albumentations
    opencv4
    pudb
    imageio
    imageio-ffmpeg
    pytorch-lightning
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
  ];

  doCheck = false;
}
