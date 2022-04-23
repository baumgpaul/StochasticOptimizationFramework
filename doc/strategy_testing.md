## Optimization strategy testing :
This allows the testing of implementations of strategies. Tests currently include : 
- *Basic functionality* : Simple sanity check. One forward pass through pipeline. If **PASSED** there are no errors which might hinder the data flow but does not check strategy.
- *Basic convergence 1-D* : Checks the convergence of the strategy on the 1-D function $`x^2`$. Returns **PASSED** if in **3** runs and **50** iterations in each there is at least one quality less than 1e-8.
- *Basic convergence 5-D* : Checks the convergence of the strategy on the 5-D function sum($`x^2`$). Returns **PASSED** if in **3** runs and **100** iterations in each there is at least one quality less than 0.01.

To run the testing mode only the handle to the optimization strategy config needs to be passed : 
```matlab
% Choose strategy : 
strategyCfg = optim.initConfigFirefly;

% Run tests : 
IGTEOptimizer(strategyCfg, 'TEST');
```