function [problemConfig] = cfgProblemAckley
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

problemConfig.name = 'Ackley_test_function';
problemConfig.parameterNames = {'x1', 'x2'};
problemConfig.objectiveNames = {'Ackley_output'};
problemConfig.parMin = [-5 , -5];
problemConfig.parMax = [5 , 5];
problemConfig.nObj = 1;
problemConfig.nRestVals = 0;
problemConfig.forwardSolver = @ackleyFun;

problemConfig.scalarization = 1;
problemConfig.membershipFunctions{1}.type=1;%faktor
problemConfig.membershipFunctions{1}.k = 1;
problemConfig.membershipFunctions{1}.objectivepar(1) = 1;

end

function varargout = ackleyFun(pop)
    varargout{1} = -20*exp(-0.2.*sqrt(0.5.*(pop(:,1).^2+pop(:,2).^2)))...
    -exp(0.5.*(cos(2*pi*pop(:,1))+cos(2*pi*pop(:,2))))+exp(1)+20;
    varargout{2} = zeros(size(pop,1),1);
    varargout{3} = zeros(size(pop,1),0);
end