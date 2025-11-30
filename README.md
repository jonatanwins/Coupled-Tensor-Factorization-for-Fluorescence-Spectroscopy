# Tensor Factorization for Fluorescence Spectroscopy

### How to run this code on macOS
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

Find the rank by running `part_1.m`
```
part_1
```
