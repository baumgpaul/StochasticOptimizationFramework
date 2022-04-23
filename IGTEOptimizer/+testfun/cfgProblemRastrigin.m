function [problemConfig] = cfgProblemRastrigin
% loads Problem config for 3D Rastrigin
%
% last change:  August 16, 2017  V1.1 PB

% Project: IGTE_Optimizer
% 
% Authors: P. Baumgartner (PB)    , Graz, Austria
%
% V1.0 July 19, 2017 Implementation; PB
% V1.1 August 16, 2017 change from script to function; PB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

problemConfig.name = 'Rastrigin_test_function';
problemConfig.parameterNames = {'x1', 'x2'};
problemConfig.objectiveNames = {'Rastrigin_output'};
problemConfig.parMin = [-5.12 , -5.12];
problemConfig.parMax = [5.12 , 5.12];
problemConfig.nObj = 1;
problemConfig.nRestVals = 0;
problemConfig.forwardSolver = @rastriginFun;

problemConfig.scalarization = 1;
problemConfig.membershipFunctions{1}.type=1;%faktor
problemConfig.membershipFunctions{1}.k = 1;
problemConfig.membershipFunctions{1}.objectivepar(1) = 1;

end

function varargout = rastriginFun(pop)
   varargout{1} = (20+(pop(:,1).^2-10*cos(2*pi*pop(:,1)))...
    +(pop(:,2).^2-10*cos(2*pi*pop(:,2))));
   varargout{2} = zeros(size(pop,1),1);
   varargout{3} = zeros(size(pop,1),0);
end