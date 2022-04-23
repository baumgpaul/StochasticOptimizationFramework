function [problemConfig] = cfgProblemBaele
% loads Problem config for Baele
%
% last change:  August 16, 2017  V1.1 PB

% Project: IGTE_Optimizer
% 
% Authors: P. Baumgartner (PB)    , Graz, Austria
%
% V1.0 July 19, 2017 Implementation; PB
% V1.1 August 16, 2017 change from script to function; PB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

problemConfig.name = 'Baele_test_function';
problemConfig.parameterNames = {'x1', 'x2'};
problemConfig.objectiveNames = {'Baele_output'};
problemConfig.parMin = [-4.5 , -4.5];
problemConfig.parMax = [4.5 , 4.5];
problemConfig.nObj = 1;
problemConfig.nRestVals = 0;
problemConfig.forwardSolver = @baeleFun;

problemConfig.scalarization = 1;
problemConfig.membershipFunctions{1}.type=1;%faktor
problemConfig.membershipFunctions{1}.k = 1;
problemConfig.membershipFunctions{1}.objectivepar(1) = 1;

end

function varargout = baeleFun(pop)
    varargout{1} = (1.5-pop(:,1)+pop(:,1).*pop(:,2)).^2+(2.25-pop(:,1)+pop(:,1).*pop(:,2).*pop(:,2)).^2+(2.625-pop(:,1)+pop(:,2).^3).^2;
    varargout{2} = zeros(size(pop,1),1);
    varargout{3} = zeros(size(pop,1),0);
end