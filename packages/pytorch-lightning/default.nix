{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonOlder
, fsspec
, lightning-utilities
# , numpy
, packaging
, pyyaml
, tensorboard
, torch
, torchmetrics
, tqdm
, traitlets

# tests
, psutil
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "pytorch-lightning";
  version = "1.7.7";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "Lightning-AI";
    repo = "pytorch-lightning";
    rev = "refs/tags/${version}";
    hash = "sha256-KMd7EQLxHowlxJi5nJD0d9bkBrSx+r1RgPy/SYUN8uU=";
  };

  preConfigure = ''
    export PACKAGE_NAME=pytorch
 '';

  patches = [
    ./fix-requirements.patch
  ];

  propagatedBuildInputs = [
    fsspec
    # numpy
    packaging
    pyyaml
    tensorboard
    torch
    # lightning-utilities
    torchmetrics
    tqdm
    # traitlets
  ];
#   ++ fsspec.optional-dependencies.http;

  checkInputs = [
    psutil
    pytestCheckHook
  ];

  # Some packages are not in NixPkgs; other tests try to build distributed
  # models, which doesn't work in the sandbox.
  doCheck = false;

  pythonImportsCheck = [
    "pytorch_lightning"
  ];

  meta = with lib; {
    description = "Lightweight PyTorch wrapper for machine learning researchers";
    homepage = "https://pytorch-lightning.readthedocs.io";
    license = licenses.asl20;
    maintainers = with maintainers; [ tbenst ];
  };
}