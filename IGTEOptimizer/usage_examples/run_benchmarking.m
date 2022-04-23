%% 2. Strategy benchmarking : 

% Define strategy : 
strategyCfg = optim.initConfigFirefly;

% Start benchmarking : 
IGTEOptimizer(strategyCfg, ...
              'problemCfg', 'BENCHMARK');