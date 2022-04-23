function strategyConfig = initConfigDE()

strategyConfig = struct();
strategyConfig.name = 'Differential Evolution';
strategyConfig.optimizer = @optim.strategyDE;
strategyConfig.F = 0.8;  
strategyConfig.cr = 0.5;      
strategyConfig.nSwarm = 30;

end