function strategyConfig = initConfigDEcluster()

strategyConfig = struct();
strategyConfig.name = 'DE Cluster';
strategyConfig.optimizer = @optim.strategyDEcluster;
strategyConfig.F = 0.8;  
strategyConfig.cr = 0.5;      
strategyConfig.nSwarm = 30;

end