function [problemConfig] = cfgProblemRosenbrockMultidim
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

nPar = 6;
problemConfig.name = 'RosenbrockMultidim_test_function';
problemConfig.parameterNames = cell(1,nPar);
for ind = 1:nPar
    problemConfig.parameterNames{ind} = ['x' num2str(ind)];
end
problemConfig.objectiveNames = {'RosenbrockMultidim_output'};
problemConfig.parMin = -3*ones(1, nPar);
problemConfig.parMax =  3*ones(1, nPar);
problemConfig.nObj = 1;
problemConfig.objThreshold = 250;
problemConfig.nRestVals = 0;
problemConfig.forwardSolver = @rosenbrockFun;

problemConfig.scalarization = 1;
problemConfig.membershipFunctions{1}.type=1;%faktor
problemConfig.membershipFunctions{1}.k = 1;
problemConfig.membershipFunctions{1}.objectivepar(1) = 1;

end

function [varargout] = rosenbrockFun(pop)
    
    varargout{1} = 0;
    for ind = 1:size(pop, 2)-1
        varargout{1} = varargout{1} + (100*(pop(:,ind+1) - pop(:,ind).^2).^2 ...
                       + (1 + pop(:,ind).^2));
    end
    
    varargout{2} = zeros(size(pop,1),1);
    varargout{3} = zeros(size(pop,1),0);
end