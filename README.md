# Tensor Factorization for Fluorescence Spectroscopy

### MATLAB Tooboxes used
#### Part 1
[Tensor toolbox](https://www.tensortoolbox.org/)
which includes
[L-BFGS-B-C](https://github.com/stephenbeckr/L-BFGS-B-C).
#### Part 2
Same as part 1, but also the
[AOADMM-DataFusionFramework](https://github.com/AOADMM-DataFusionFramework/Matlab-Code) and
[Proximity-operator](https://proximity-operator.net/)

### How to run this code
The following is for Apple silicon macOS 14.6.1 (and probably similar on Linux)

Install the [tensortoolbox](https://www.tensortoolbox.org/) package for MATLAB 

Compile the lbfgsb wrapper that comes with tensortoolbox, (it can also be found as a standalone package [here](https://github.com/stephenbeckr/L-BFGS-B-C).)
```
cd /Users/<your-username>/Documents/MATLAB/packages/tensor_toolbox-v3.7/libraries/lbfgsb/Matlab
compile_mex
```

Check the install
```
which lbfgsb_wrapper
```
Install all the toolboxes and state their paths in `setup_paths.m`

For CP decomposition of florescence spectroscopy run `part_1.m`
```
part_1
```
For coupled tensor matrix factorization run `part_2.m`
```
part_2
```

