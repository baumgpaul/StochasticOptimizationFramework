function [problemConfig] = cfgProblemRosenbrockModified
% loads Problem config for a modified Rosenbrock function (2 local Minima,
% 1 global Minimum)
%
% last change:  August 16, 2017  V1.1 PB

% Project: IGTE_Optimizer
% 
% Authors: A. Reinbacher-Köstinger (ARK)    , Graz, Austria
% Authors: P. Baumgartner (PB)    , Graz, Austria
%
% V1.0 July 24, 2017 Implementation; ARK
% V1.1 August 16, 2017 change from script to function; PB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

problemConfig.name = 'RosenbrockMod_test_function';
problemConfig.parameterNames = {'x1', 'x2'};
problemConfig.objectiveNames = {'RosenbrockMod_output'};
problemConfig.parMin = [-10 , -10];
problemConfig.parMax = [10 , 10];
problemConfig.nObj = 1;
problemConfig.nRestVals = 0;
problemConfig.forwardSolver = @rosenbrockModFun;

problemConfig.scalarization = 1;
problemConfig.membershipFunctions{1}.type=1;%faktor
problemConfig.membershipFunctions{1}.k = 1;
problemConfig.membershipFunctions{1}.objectivepar(1) = 1;

end

function varargout = rosenbrockModFun(pop)
    varargout{1} = 1300 + 100*(pop(:,2) - pop(:,1).^2).^2 + (1 - pop(:,1)).^2  - 50*((pop(:,1)+1).^2 + (pop(:,2)-1).^2)  - 10*((pop(:,1)-1.5).^2) + (pop(:,2)-2.5).^2 + exp(2*pop(:,2)-5);
    varargout{2} = zeros(size(pop,1),1);
    varargout{3} = zeros(size(pop,1),0);
end