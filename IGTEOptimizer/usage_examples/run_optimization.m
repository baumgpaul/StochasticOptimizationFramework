%% 3. Initialize optimizer :

% Choose strategy : 
strategyCfg = optim.initConfigDE;

% Set problem config : 
problemCfg = testfun.cfgTestTwoObjectiveFun;%testfun.cfgProblemRosenbrock;

optimizer = IGTEOptimizer(strategyCfg, ... 
                      'problemCfg', problemCfg);
                  
% Start optimization : 
optimizer.start();

% Show only final results : 
optimizer.finalResults