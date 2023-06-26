{
  buildPythonPackage
, pythonRelaxDepsHook
, fetchFromGitHub
, fetchpatch

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

, hatchling
, openclip
}:
buildPythonPackage rec {
  pname = "stable-diffusion";
  version = "2023-06-23";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "Stability-AI";
    repo = pname;
    rev = "cf1d67a6fd5ea1aa600c4df58e5b47da45f6bdbf";
    sha256 = "sha256-yEtrz/JTq53JDI4NZI26KsD8LAgiViwiNaB2i1CBs/I=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/Stability-AI/stablediffusion/commit/ab12d81663517796c18c7bf9266e7343cf0b1705.patch";
      sha256 = "sha256-wYrm4rBvt3mgG/tCRVSiuVXa7xa7+R46wq/5N1p/M2A=";
    })
  ];

  nativeBuildInputs = [ pythonRelaxDepsHook ];
  pythonRelaxDeps = [
    "transformers"
  ];

  propagatedBuildInputs = [
    hatchling

    openclip

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
