function [optim] = strategyFirefly(optim)
% Firefly strategy
%
% Executes the Differential Evolution Strategy optimizer
%
% input parameter:
%  - commonCfg . . . Common config for different strategies
%  - deConfig. . . Strategy specific config
%  - problemCfg. . . Config which defines problem (solver, quality, ..)
%
% return values:
%  - minima . . .  Cell Array of all local minimas
%  - funcCalls . . .  number of forward-solver calls
%  - logger . . .  logger of values defined in commonCfg.log
%
% last change: August 24, 2017  V6.0  PB

% Project: IGTE_Optimizer
%
% Authors: A. Reinbacher-Köstinger (ARK), Graz, Austria
%          P. Baumgartner (PB)    , Graz, Austria
%
% V1.0 May , 2016  First Implementation; Hackl Andi
% . . 
% V5.0 August 21, 2017  new structure; PB
% V6.0 August 24, 2017 adding initial guess ; PB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Result variables definition
currIter = struct('population', [], 'nFuncCalls', 0, ... 
                  'logEndIndex', 0, 'logStartingIndex', 0, ...
                  'iIter', 0, 'strategyParams', struct());

% problem initialization
paramRange = optim.problemCfg.range;
dParamRange = (paramRange(:,2) - paramRange(:,1));

%% strategy parameter initialization

nSwarm = optim.strategyCfg.nSwarm;     % Number of particles in the swarm
currIter.strategyParams.alpha = optim.strategyCfg.alpha.*dParamRange;   % Randomness 0--1 (highly random)
currIter.strategyParams.gamma = optim.strategyCfg.gamma./sqrt(dParamRange);   % Absorption coefficient
currIter.strategyParams.delta = optim.strategyCfg.delta; % Randomness reduction
nCluster = 1;
% cluster radius ??

%% starting strategy
currIter.population = optim.initializePopulation(); 

parameterspace_diam = sqrt(sum((paramRange(:,2)-paramRange(:,1)).^2));

%% --------------- Start  Optimization --------------------------
while 1      % Start iteration steps
    
    %% Update indices : 
    currIter.iIter = currIter.iIter + 1 ;
    currIter.logStartingIndex = currIter.logEndIndex+1;
    currIter.logEndIndex = currIter.logEndIndex+nSwarm;
    
    Xdis = pdist(currIter.population);                   % Distance FireFly's
    CTree = linkage(Xdis,'complete');            % Build up Cluster Tree
    currIter.ClusterRad = CTree(end,end)/parameterspace_diam*100;  
    
    %% Do forward pass and update currIter state : 
    currIter = optim.costFunction(currIter, currIter.population);
    
    %% Main IGTEOptimizer loop handler : 
    % Update logging indices and pass current iteration data to be
    % processed and saved. At the end a check of the stopping criteria is
    % performed and the loop is aborted if fulfilled.
    
    optim.mainLoopProcessHandler(currIter);
    
    if optim.shallNotPass
        break;
    end
    
    currIter.strategyParams.alpha = newalpha(currIter.strategyParams.alpha, ... 
                                             currIter.strategyParams.delta);
    
    [currIter.population] = makeMove(currIter.population, currIter.quality, ... 
                                     currIter.strategyParams.alpha, ... 
                                     currIter.strategyParams.gamma, ... 
                                     paramRange);
end

end


%% %% -----------------Subfunctions------------------------------------- %%
% ------------------- Movement Function ----------------------------------
function [pop] = makeMove(pop,quality,alpha,gamma,range)
ni=size(pop,1); nj=size(pop,1); nvars = size(pop,2);
for i=1:ni
    for j=1:nj
        if quality(i)>quality(j)           % Brighter and more attractive
            sum = 0;
            for k=1:nvars
                sum= sum + (pop(i,k)-pop(j,k))^2;
            end
            r = sqrt(sum);% The attractiveness parameter beta=exp(-gamma*r)
            beta0 = 1; beta = beta0 .* exp(-gamma .* r.^2 ./ norm(range));
            for k=1:nvars
                pop(i,k)=pop(i,k).*(1-beta(k))+pop(j,k).*beta(k) + ...
                    alpha(k).*(rand-0.5);
            end
        end
    end     % end for j
end         % end for i
pop=findrange(pop,nvars,range);
end

% ------------------- Range function ----------------------------------
function pop=findrange(pop,nvars,range)
upb = repmat(range(:,2)',size(pop,1),1);
lowb = repmat(range(:,1)',size(pop,1),1);
runbound = 0;
while (runbound~=1)
    oobd = [find(pop(:,1:nvars) > upb) ; find(pop(:,1:nvars) < lowb)];
    runbound = isempty(oobd);
    for newp = oobd'
        posrand = randi(3,1);
        if posrand == 1
            if pop(newp)>upb(newp)  % loop position
                pop(newp) = pop(newp) - upb(newp) + lowb(newp);  
            else
                pop(newp) = (pop(newp) - lowb(newp)) + upb(newp); 
            end
        elseif posrand == 2
            if pop(newp)>lowb(newp) % mirrow position
                pop(newp) = 2*upb(newp) - pop(newp);                 
            else
                pop(newp) = 2*lowb(newp) - pop(newp);
            end
        elseif posrand == 3  % random position
            pop(newp)=lowb(newp)+(upb(newp)-lowb(newp))*rand;                            
        end
    end
end
end

% ------------------- generalize new alpha -------------------------------
function alpha=newalpha(alpha,delta)
alpha=alpha*delta;
end




