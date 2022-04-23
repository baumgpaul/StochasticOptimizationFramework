
To use the framework for optimization the following needs to be defined and passed to the **IGTEOptimizer** constructor.
```matlab
% Choose strategy : 
strategyCfg = optim.initConfigFirefly;

% Problem definition : see Prob. def. section
problemCfg = testfun.cfgProblemXSquaredND;

% Declare and initialize optimizer : 
optimizer = IGTEOptimizer(strategyCfg, problemCfg);

% Start the optimization : 
optimizer.start()
```