final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (
      python-final: python-prev:
      let
        python = python-final.python;
        sitePkgs = python.sitePackages;
        bootstrapSitePkgs = "usr/${sitePkgs}";
        installerSrc = python-prev.bootstrap.installer.src;

        buildBootstrapPythonModule =
          basePackage: attrs:
          final.stdenv.mkDerivation (
            {
              pname = "${python.libPrefix}-bootstrap-${basePackage.pname}";
              inherit (basePackage) version src meta;

              buildPhase = ''
                runHook preBuild

                PYTHONPATH="${python-prev.bootstrap.flit-core}/${sitePkgs}" \
                  ${python.interpreter} -m flit_core.wheel

                runHook postBuild
              '';

              installPhase = ''
                runHook preInstall

                PYTHONPATH="${installerSrc}/src" \
                  ${python.interpreter} -m installer \
                    --destdir "$out" --prefix "" dist/*.whl

                runHook postInstall
              '';
            }
            // attrs
          );

        bootstrap-packaging = buildBootstrapPythonModule python-prev.packaging { };
        bootstrap-pyproject-hooks = buildBootstrapPythonModule python-prev.pyproject-hooks { };
        bootstrap-tomli = buildBootstrapPythonModule python-prev.tomli { };
      in
      {
        bootstrap = python-prev.bootstrap // {
          packaging = bootstrap-packaging;

          build = buildBootstrapPythonModule python-prev.build {
            nativeBuildInputs = [ final.makeWrapper ];
            installPhase = ''
              runHook preInstall

              PYTHONPATH="${installerSrc}/src" \
                ${python.interpreter} -m installer \
                  --destdir "$out" --prefix "" dist/*.whl

              rm -f "$out/bin/pyproject-build"
              makeWrapper ${python.interpreter} "$out/bin/pyproject-build" \
                --add-flags "-m build" \
                --prefix PYTHONPATH : "$out/${sitePkgs}" \
                --prefix PYTHONPATH : "$out/${bootstrapSitePkgs}" \
                --prefix PYTHONPATH : "${bootstrap-pyproject-hooks}/${sitePkgs}" \
                --prefix PYTHONPATH : "${bootstrap-pyproject-hooks}/${bootstrapSitePkgs}" \
                --prefix PYTHONPATH : "${bootstrap-packaging}/${sitePkgs}" \
                --prefix PYTHONPATH : "${bootstrap-packaging}/${bootstrapSitePkgs}" \
                --prefix PYTHONPATH : "${bootstrap-tomli}/${sitePkgs}" \
                --prefix PYTHONPATH : "${bootstrap-tomli}/${bootstrapSitePkgs}"

              runHook postInstall
            '';
          };
        };
      }
    )
  ];
}
