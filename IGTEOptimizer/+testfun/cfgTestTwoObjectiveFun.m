function [problemConfig] = cfgTestTwoObjectiveFun


problemConfig.name = 'Two_objectives_test_fun';
problemConfig.parameterNames = {'x1', 'x2'};
problemConfig.objectiveNames = {'y1', 'y2'};
problemConfig.parMin = [-5 , -5];
problemConfig.parMax = [5 , 5];
problemConfig.nObj = 2;
problemConfig.nRestVals = 0;
problemConfig.forwardSolver = @twoObjTestFun;

% % Objective 1 :
% problemConfig.membershipFunctions{1}.type=1;
% problemConfig.membershipFunctions{1}.k = 1;
% problemConfig.membershipFunctions{1}.objectivepar(1) = 1;

problemConfig.scalarization = 'sum';

problemConfig.membershipFunctions{1}.type='onesided';
problemConfig.membershipFunctions{1}.k = 1;
problemConfig.membershipFunctions{1}.p10 = 20;
problemConfig.membershipFunctions{1}.p90 = 4;
problemConfig.membershipFunctions{1}.objectivepar(1) = 1;

% Objective 2 : 
problemConfig.membershipFunctions{2}.type='onesided';
problemConfig.membershipFunctions{2}.k = 1;
problemConfig.membershipFunctions{2}.p10 = 20;
problemConfig.membershipFunctions{2}.p90 = 4;
problemConfig.membershipFunctions{2}.objectivepar(1) = 2;

end

function varargout = twoObjTestFun(pop)
    varargout{1} = [pop(:,1).^2 + pop(:,2).^2, (pop(:,1)-1).^2 + (pop(:,2)-1).^2];
    varargout{2} = zeros(size(pop,1),1);
    varargout{3} = zeros(size(pop,1),0);
end