{ lib
, fetchPypi
, buildPythonPackage
, fastapi
, python-socketio
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "fastapi-socketio";
  version = "0.0.9";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-jHOqlP4b8cmWT/iSM6a6Uu7uw6yLneACTZ2CsR5GveU=";
  };

  propagatedBuildInputs = [
    fastapi
    python-socketio
  ];

  doCheck = false;
  checkInputs = [
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "fastapi_socketio"
  ];
}
