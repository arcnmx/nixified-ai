{ lib
, fetchPypi
, buildPythonPackage
, starlette
, boto3
, google-cloud-pubsub
# checkInputs:
, requests
, pytestCheckHook
, pytest
, pytest-asyncio
, pytest-env
, pytest-mock
, mypy
, pytest-mypy
, moto
, flake8
, pydantic
}:
buildPythonPackage rec {
  pname = "fastapi-events";
  version = "0.6.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-I4DNw+MNyJjWtyHWI8V1xvWwXuNaPuBa3wuQsSue0fk=";
  };

  propagatedBuildInputs = [
    starlette
  ];

  checkInputs = [
    pytestCheckHook
  ] ++ passthru.optional-dependencies.test;

  pythonImportsCheck = [
    "fastapi_events"
  ];

  passthru.optional-dependencies = {
    test = [
      requests
      pytest
      pytest-asyncio
      pytest-env
      pytest-mock
      mypy
      pytest-mypy
      moto # ++ moto.optional-dependencies.sqs
      flake8
      pydantic
      google-cloud-pubsub
    ];
    aws = [
      boto3
    ];
    google = [
      google-cloud-pubsub
    ];
  };
}
