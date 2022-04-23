function [problemConfig] = cfgProblemXSquaredND
% loads Problem config for Ackleys function
%
% last change:  August 16, 2017  V1.1 PB

% Project: IGTE_Optimizer
% 
% Authors: P. Baumgartner (PB)    , Graz, Austria
%
% V1.0 July 19, 2017 Implementation; PB
% V1.1 August 16, 2017 change from script to function; PB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nPar = 5; %randi([2,10],[1,1]);
problemConfig.name = 'XSquaredND_test_function';
problemConfig.parameterNames = cell(1,nPar);
for ind = 1:nPar
    problemConfig.parameterNames{ind} = ['x' num2str(ind)];
end
problemConfig.objectiveNames = {'XsquaredND_output'};
problemConfig.parMin = -5*ones(1, nPar);
problemConfig.parMax =  5*ones(1, nPar);
problemConfig.nObj = 1;
problemConfig.nRestVals = 0;
problemConfig.objThreshold = 1;
problemConfig.forwardSolver = @xSquared;

problemConfig.scalarization = 1;
problemConfig.membershipFunctions{1}.type=1;%faktor
problemConfig.membershipFunctions{1}.k = 1;
problemConfig.membershipFunctions{1}.objectivepar(1) = 1;

end

function [varargout] = xSquared(pop)
    varargout{1} = sum(pop.^2, 2);
    varargout{2} = zeros(size(pop,1),1);
    varargout{3} = zeros(size(pop,1),0);
end