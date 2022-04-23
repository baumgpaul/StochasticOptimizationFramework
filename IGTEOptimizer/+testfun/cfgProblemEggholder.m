function [problemConfig] = cfgProblemEggholder
% loads Problem config for Eggholder foo
%
% last change:  August 16, 2017  V1.1 PB

% Project: IGTE_Optimizer
% 
% Authors: P. Baumgartner (PB)    , Graz, Austria
%
% V1.0 July 19, 2017 Implementation; PB
% V1.1 August 16, 2017 change from script to function; PB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

problemConfig.name = 'Eggholder_test_function';
problemConfig.parameterNames = {'x1', 'x2'};
problemConfig.objectiveNames = {'Eggholder_output'};
problemConfig.parMin = [-512 , -512];
problemConfig.parMax = [512 , 512];
problemConfig.nObj = 1;
problemConfig.nRestVals = 0;
problemConfig.forwardSolver = @eggholderFun;

problemConfig.scalarization = 1;
problemConfig.membershipFunctions{1}.type=1;%faktor
problemConfig.membershipFunctions{1}.k = 1;
problemConfig.membershipFunctions{1}.objectivepar(1) = 1;

end

function varargout = eggholderFun(pop)
    varargout{1} = -(pop(:,2)+47).*sin(sqrt(abs(pop(:,1)/2+pop(:,2)+47)))-pop(:,1).*sin(sqrt(abs(pop(:,1)-pop(:,2)-47)));
    varargout{2} = zeros(size(pop,1),1);
    varargout{3} = zeros(size(pop,1),0);
end