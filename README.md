# Hierarchial Performance Test

This is a Julia implementation of the Non-parametric Hierarchial Performance Testing statistical technique described in [Statistical Performance Comparisons of Computers](https://parsec.cs.princeton.edu/publications/chen14ieeetc.pdf). It is meant to compare the performance of different computers on a common set of benchmarks with high statistical confidence, rather than .

For more information, check the [official website](http://novel.ict.ac.cn/tchen/hpt/) maintained by one of the technique's creators.

## Example usage

Each set of benchmark results should be provided as a 2D matrix where each row is comprised of the same benchmark's results.

```julia
using HierarchialPerformanceTest

# Computer A's benchmark matrix
a = [86 86 86; 46 46 46; 2.491 2.3 2.314; 5.629 5.31 5.91; 262.69 262.39 262.632; 17.761 16.882 15.541; 3.264 3.205 3.256; 3678 3612 3642; 4251 4220 4170; 58176 56384 56512]

# Computer B's benchmark matrix
b = [83 83 83; 46 46 46; 2.263 2.239 2.228; 5.663 6.488 5.383; 260.977 261.075 260.757; 14.816 11.811 15.633; 2.323 2.153 2.315; 3456 3540 3442; 4009 4118 4090; 57664 58432 54848]

hptSpeedup(a, b)  # => 1.013
```

This shows that computer B is 1.013x faster than computer A.
