# Description

Generate hardening_manifest.yaml for python3.6 and python3.8 dependencies per Iron Bank requirements specifications.

# Usage

##### R

Place your target libraries inside build/r/scripts/download_deps.R and then run:

```
$ ./r_get_deps.sh
```

##### Python

```bash
$ ./python_get_deps.sh PYTHON_VERSION PACKAGE_NAME
```

```bash
chmod +x get_deps.sh
./get_deps.sh 3.6 pandas

> cat hardening_manifest.yaml

- resources:
  - filename: pandas-1.1.5-cp36-cp36m-manylinux1_x86_64.whl
    url: https://files.pythonhosted.org/packages/c3/e2/00cacecafbab071c787019f00ad84ca3185952f6bb9bca9550ed83870d4d/pandas-1.1.5-cp36-cp36m-manylinux1_x86_64.whl
    validation:
      type: sha256
      value: b61080750d19a0122469ab59b087380721d6b72a4e7d962e4d7e63e0c4504814
  - filename: numpy-1.19.5-cp36-cp36m-manylinux2010_x86_64.whl
    url: https://files.pythonhosted.org/packages/14/32/d3fa649ad7ec0b82737b92fefd3c4dd376b0bb23730715124569f38f3a08/numpy-1.19.5-cp36-cp36m-manylinux2010_x86_64.whl
    validation:
      type: sha256
      value: a4646724fba402aa7504cd48b4b50e783296b5e10a524c7a6da62e4a8ac9698d
  - filename: python_dateutil-2.8.1-py2.py3-none-any.whl
    url: https://files.pythonhosted.org/packages/d4/70/d60450c3dd48ef87586924207ae8907090de0b306af2bce5d134d78615cb/python_dateutil-2.8.1-py2.py3-none-any.whl
    validation:
      type: sha256
      value: 75bb3f31ea686f1197762692a9ee6a7550b59fc6ca3a1f4b5d7e32fb98e2da2a
  - filename: pytz-2020.5-py2.py3-none-any.whl
    url: https://files.pythonhosted.org/packages/89/06/2c2d3034b4d6bf22f2a4ae546d16925898658a33b4400cfb7e2c1e2871a3/pytz-2020.5-py2.py3-none-any.whl
    validation:
      type: sha256
      value: 16962c5fb8db4a8f63a26646d8886e9d769b6c511543557bc84e9569fb9a9cb4
  - filename: six-1.15.0-py2.py3-none-any.whl
    url: https://files.pythonhosted.org/packages/ee/ff/48bde5c0f013094d729fe4b0316ba2a24774b3ff1c52d924a8a4cb04078a/six-1.15.0-py2.py3-none-any.whl
    validation:
      type: sha256
      value: 8b74bedcbbbaca38ff6d7491d76f2b06b3592611af620f8426e82dddb04a5ced

```
