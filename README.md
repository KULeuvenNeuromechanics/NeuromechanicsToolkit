# NeuromechanicsToolkit

In this repository you will find a broad range of functions used at the Computational Neuromechanics research group at the KU Leuven.

Function are divided in categories in the main folder after which they will be further divided in consequent folders. 

Current categories:

- DataProcessing
  - Functions that are useful in processing data, including marker and force data processing, calculation of inverse kinematics, inverse dynamics, and more.
- Read&Write
  - Functions that read and write data, including function that read .c3d files, write .trc, .mot, .sto files, and more.

In each subfolder you will find a README.md file with a description of the files in the respective folder. (**to do**)

### Rules for contributing to the NeuromechanicsToolkit

This repository is build to organically grow as people contribute to the repository over time. If you contribute to the repository, please follow the guidelines below. This way we can keep the repository clean and easy to use.

1. Create your own branch in which you will add your contribution.
2. For new functions use the function template (FunctionTemplate.m). Make sure you describe the different step you take by comments in your new function.
3. Finished with your contribution? Make a pull request to the main branch and ask for reviewing by Bram or Wouter. 

### Dependencies

As the toolkit develops, different software packages may be needed to be able to use this repository. Here we describe dependencies of this repository on other software packages. We kindly ask that if you add functions that depend on other software, that you describe these dependences by completing the overview below. Specify the folder that depends on other software, the software the folder depends on, a brief summary of why this software is used, and directions for installing the software.

**Dataprocessing**

*In the Dataprocessing folder some functions depend on the OpenSim API to use OpenSim functionalities for processing steps. Some examples are: inverse kinematics, inverse dynamics, and body kinematics.*

- Software: OpenSim MATLAB API

- For information on setting up the MATLAB API see: https://simtk-confluence.stanford.edu/display/OpenSim/Scripting+with+Matlab

### Notes

Lab users typically want to use this repository inside their current project. It is good practice to include this repository as a submodule. More information on submodules here: https://git-scm.com/book/nl/v2/Git-Tools-Submodules.