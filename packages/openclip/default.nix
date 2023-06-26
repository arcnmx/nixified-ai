{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonOlder
, pythonRelaxDepsHook
, setuptools
, regex
, timm
, protobuf
, ftfy
, sentencepiece
}:

buildPythonPackage rec {
  pname = "open_clip_torch";
  version = "2.20.0";
  disabled = pythonOlder "3.7";
  format = "pyproject";

  # pypi doesn't have requirements.txt for some reason...
  src = fetchFromGitHub {
    owner = "mlfoundations";
    repo = "open_clip";
    rev = "refs/tags/v${version}";
    sha256 = "sha256-Ca4oi2LqleIFAGBJB7YIi4nXe2XhOP6ErDFXgXtJLxM=";
  };

  nativeBuildInputs = [ pythonRelaxDepsHook ];

  propagatedBuildInputs = [
    setuptools
    regex
    timm
    protobuf
    ftfy
    sentencepiece
  ];

  pythonRelaxDeps = [ "protobuf" ];

  meta = {
    homepage = "https://github.com/mlfoundations/open_clip";
    description = "Open source implementation of OpenAI's CLIP";
  };
}
