# Xyce builder

- Build guide
    - [Xyce](https://github.com/Xyce/Xyce/blob/master/INSTALL.md)
    - [Xyce documentaion](https://github.com/Xyce/Xyce/tree/master/doc)
- [Test guides](https://github.com/Xyce/Xyce/blob/master/test/ReadMe_RegressionTesting.txt)

Scripts to build and test Xyce.

Parallel/MPI build is disable by default, since running the test suite takes extreamly long time (>12h on VM with 4x Zen 4 cores).

## Usage

1. Pull all repositories and install dependencies

    - [repo_prepare.sh](./repo_prepare.sh)
    - [prerequisites.sh](./prerequisites.sh)

2. Build Trilinos

    - [trilinos.sh](./trilinos.sh)

3. Build Xyce

    - [build.sh](./build.sh)

Output file: `~/xyce_<serial or parallel>-<version>.tar.zst`

## Enabled options

### Trilinos

- Trilinos_ENABLE_OpenMP
- TPL_ENABLE_METIS

#### Additional options for parallel

- Trilinos_ENABLE_ShyLU
- Trilinos_ENABLE_ShyLU_NodeBasker
- TPL_ENABLE_ParMETIS

### Xyce

- Xyce_PLUGIN_SUPPORT

#### Additional options for parallel

- Xyce_SHYLU
- Xyce_AMESOS2_SHYLUBASKER