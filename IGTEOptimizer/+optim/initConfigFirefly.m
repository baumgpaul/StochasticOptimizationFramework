function [strategyConfig] = initConfigFirefly()
% loads Standard Firefly config with examples for different configs
%
% last change:  August 16, 2017  V1.1 PB

% Project: IGTE_Optimizer
% 
% Authors: P. Baumgartner (PB)    , Graz, Austria
%
% V1.0 July 19, 2017 Implementation; PB
% V1.1 August 16, 2017 change from script to function; PB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

strategyConfig.name = 'Firefly';
strategyConfig.optimizer = @optim.strategyFirefly;
strategyConfig.nSwarm = 20;
strategyConfig.alpha = 0.75; % of range
strategyConfig.gamma = 0.75; % over sqrt range
strategyConfig.delta = 0.9;