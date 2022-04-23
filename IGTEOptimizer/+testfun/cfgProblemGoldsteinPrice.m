function [problemConfig] = cfgProblemGoldsteinPrice
% loads Problem config for Goldstein Price
%
% last change:  August 16, 2017  V1.1 PB

% Project: IGTE_Optimizer
% 
% Authors: P. Baumgartner (PB)    , Graz, Austria
%
% V1.0 July 19, 2017 Implementation; PB
% V1.1 August 16, 2017 change from script to function; PB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

problemConfig.name = 'GoldensteinPrice_test_function';
problemConfig.parameterNames = {'x1', 'x2'};
problemConfig.objectiveNames = {'GoldensteinPrice_output'};
problemConfig.parMin = [-2 , -2];
problemConfig.parMax = [2 , 2];
problemConfig.nObj = 1;
problemConfig.nRestVals = 0;
problemConfig.forwardSolver = @goldensteinPriceFun;

problemConfig.scalarization = 1;
problemConfig.membershipFunctions{1}.type=1;%faktor
problemConfig.membershipFunctions{1}.k = 1;
problemConfig.membershipFunctions{1}.objectivepar(1) = 1;

end

function varargout = goldensteinPriceFun(pop)
    varargout{1} = (1+(pop(:,1)+pop(:,2)+1).^2.*(19-4*pop(:,1)+3*pop(:,1).^2-14*pop(:,2)+6*pop(:,1).*pop(:,2)+3*pop(:,2).^2)).*(30+(2*pop(:,1)-3*pop(:,2)).^2.*(18-32.*pop(:,1)+12.*pop(:,1).^2+48.*pop(:,2)-36*pop(:,1).*pop(:,2)+27*pop(:,2).^2));
    varargout{2} = zeros(size(pop,1),1);
    varargout{3} = zeros(size(pop,1),0);
end