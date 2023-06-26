{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, writeTextFile
, setuptools
, aenum
, pillow
, deprecation
, numpy
}:

buildPythonPackage rec {
  pname = "blendmodes";
  version = "2022";
  disabled = pythonOlder "3.8";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-k2jxwekOhzS0lo8MrANpbg5acU/VfnS8bu/SXAQY/QM=";
  };

  propagatedBuildInputs = [
    aenum
    pillow
    deprecation
    numpy
  ];

  meta = {
    homepage = "https://github.com/FHPythonUtils/BlendModes";
    description = "Apply a number of blending modes to a background and foreground image";
  };
}
