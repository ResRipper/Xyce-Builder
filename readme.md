# Xyce builder

- Build guide
    - [Xyce](https://github.com/Xyce/Xyce/blob/master/INSTALL.md)
    - [Xyce documentaion](https://github.com/Xyce/Xyce/tree/master/doc)
- [Test guides](https://github.com/Xyce/Xyce/blob/master/test/ReadMe_RegressionTesting.txt)

Scripts to build and test Xyce.

Parallel/MPI build is disable by default, since running the test suite takes extreamly long time (>12h on VM with 4x Zen 4 cores).

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