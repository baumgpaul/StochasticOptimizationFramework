function [problemConfig] = cfgProblemRosenbrock
% loads Problem config for Rosenbrock
%
% last change:  August 16, 2017  V1.1 PB

% Project: IGTE_Optimizer
% 
% Authors: P. Baumgartner (PB)    , Graz, Austria
%
% V1.0 July 19, 2017 Implementation; PB
% V1.1 August 16, 2017 change from script to function; PB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

problemConfig.name = 'Rosenbrock_test_function';
problemConfig.parameterNames = {'x1', 'x2'};
problemConfig.objectiveNames = {'Rosenbrock_output'};
problemConfig.parMin = [-3 , -3];
problemConfig.parMax = [3 , 3];

problemConfig.normalizePopulation = false;

problemConfig.nObj = 1;
problemConfig.objThreshold = 1;
problemConfig.nRestVals = 0;
problemConfig.forwardSolver = @rosenbrockFun;

% problemConfig.plotMemFuns = false;
problemConfig.extPercent = 0.5;

problemConfig.membershipFunctions{1}.type='flat';
problemConfig.membershipFunctions{1}.k = 1;
problemConfig.membershipFunctions{1}.objectivepar(1) = 1;

end

function [varargout] = rosenbrockFun(pop)
    varargout{1} = sum(100*(pop(:,2:size(pop,2))-pop(:,1:(size(pop,2)-1)).^2).^2+(pop(:,1:(size(pop,2)-1))-1).^2,2);
    varargout{2} = zeros(size(pop,1),1);
    varargout{3} = zeros(size(pop,1),0);
end