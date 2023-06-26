{ lib
, buildPythonPackage
, fetchPypi
, torch
}:

buildPythonPackage rec {
  pname = "tomesd";
  version = "0.1.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-Fbui6VL0ZDyDVZUeiS/akY3cy9/yI43DaNQr0Hj87ck=";
  };

  propagatedBuildInputs = [
    torch
  ];

  meta = {
    homepage = "https://github.com/dbolya/tomesd";
    description = "Token Merging for Stable Diffusion";
  };
}
