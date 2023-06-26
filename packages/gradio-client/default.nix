{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, writeTextFile
, setuptools
, hatchling
, hatch-requirements-txt
, hatch-fancy-pypi-readme
, huggingface-hub
, fsspec
, httpx
, websockets
}:

buildPythonPackage rec {
  pname = "gradio_client";
  version = "0.2.7";
  disabled = pythonOlder "3.8";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-yDAI34od0/gaKQwKJMA9CrcDF3QZkbYPcTYg7TmtjxI=";
  };

  nativeBuildInputs = [
    hatchling
    hatch-requirements-txt
    hatch-fancy-pypi-readme
  ];

  propagatedBuildInputs = [
    huggingface-hub
    fsspec
    httpx
    websockets
  ];

  meta = with lib; {
    homepage = "https://www.gradio.app/";
    description = "Python library for easily interacting with trained machine learning models";
  };
}
