function [problemConfig] = cfgProblemBukin6
% loads Problem config for bukin6 foo
%
% last change:  August 16, 2017  V1.1 PB

% Project: IGTE_Optimizer
% 
% Authors: P. Baumgartner (PB)    , Graz, Austria
%
% V1.0 July 19, 2017 Implementation; PB
% V1.1 August 16, 2017 change from script to function; PB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

problemConfig.name = 'Bukin6_test_function';
problemConfig.parameterNames = {'x1', 'x2'};
problemConfig.objectiveNames = {'Bukin6_output'};
problemConfig.parMin = [-15 , -3];
problemConfig.parMax = [-5 , 3];
problemConfig.nObj = 1;
problemConfig.nRestVals = 0;
problemConfig.forwardSolver = @bukin6Fun;

problemConfig.scalarization = 1;
problemConfig.membershipFunctions{1}.type=1;%faktor
problemConfig.membershipFunctions{1}.k = 1;
problemConfig.membershipFunctions{1}.objectivepar(1) = 1;

end

function varargout = bukin6Fun(pop)
   varargout{1} = 100.*sqrt(abs(pop(:,2)-0.01.*pop(:,1).^2))+0.01.*abs(pop(:,1)+10);
   varargout{2} = zeros(size(pop,1),1);
   varargout{3} = zeros(size(pop,1),0);
end