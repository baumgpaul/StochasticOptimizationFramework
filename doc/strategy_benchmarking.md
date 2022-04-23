## Optimization strategy benchmarking : 
Banchmarking allows running the selected strategy on different test problems with selected parameters for a number of runs and computes statistics regarding the obtained results. This way it is possible to easily compare the changes between implementations, strategies and parameters used.

```matlab
% Choose strategy : 
strategyCfg = optim.initConfigFirefly;

% Run tests : 
IGTEOptimizer(strategyCfg, 'BENCHMARK');
```