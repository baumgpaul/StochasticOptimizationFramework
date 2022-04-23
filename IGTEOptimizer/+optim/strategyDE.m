function [optim] = strategyDE(optim)
% Differential Evolution Strategy
%
% Executes the Differential Evolution Strategy optimizer
%
% input parameter:
%  - commonCfg . . . Common optim for different strategies
%  - deConfig. . . Strategy specific optim
%  - problemCfg. . . Config which defines problem (solver, quality, ..)
%
% return values:
%  - minima . . .  Cell Array of all local minimas
%  - results.funcCalls . . .  number of forward-solver calls
%  - logger . . .  logger of values defined in commonCfg.log
%
% last change: August 28, 2017  V4.0  ARK

% Project: IGTE_Optimizer
%
% Authors: A. Reinbacher-Köstinger (ARK), Graz, Austria
%          P. Baumgartner (PB)    , Graz, Austria
%
% V1.0 July 31, 2017  First Implementation; ARK
% V2.0 August 21, 2017  new structure; PB
% V3.0 August 24, 2017 adding initial guess ; PB
% V4.0 August 28, 2017 minor changes, ESPrint instead of commonPrint ; ARK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Result variables definition
currIter = struct('population', [], 'nFuncCalls', 0, ... 
                  'logEndIndex', 0, 'logStartingIndex', 0, ...
                  'iIter', 0, 'strategyParams', struct());

% problem initialization
paramRange = optim.problemCfg.range;
nPar = optim.problemCfg.nPar;

% strategy parameter initialization
F = optim.strategyCfg.F;           % scaling factor
cr = optim.strategyCfg.cr;         % crossover ratio
nSwarm = optim.strategyCfg.nSwarm;

paramSpaceDiam = sqrt(sum((paramRange(:,2)-paramRange(:,1)).^2));

%% starting strategy
currIter.population = optim.initializePopulation(); 

basemat = repmat(int16(linspace(1,nSwarm,nSwarm)),nSwarm,1); %used later
basej = repmat(int16(linspace(1,nPar,nPar)),nSwarm,1); %used later

pop_reco = currIter.population;

%% --------------- Start  Optimization --------------------------
while 1      % Start iteration steps
    
    %% Update indices : 
    currIter.iIter = currIter.iIter + 1 ;
    currIter.logStartingIndex = currIter.logEndIndex+1;
    currIter.logEndIndex = currIter.logEndIndex+nSwarm;
    
    % Method specific code : 
    Xdis = pdist(pop_reco);                   % Distance FireFly's
    CTree = linkage(Xdis, 'complete');            % Build up Cluster Tree
    currIter.ClusterRad = CTree(end,end)/paramSpaceDiam*100;
    
    %% Do forward pass and update currIter state : 
    currIter = optim.costFunction(currIter, pop_reco);
    
    %% Main IGTEOptimizer loop handler : 
    % Update logging indices and pass current iteration data to be
    % processed and saved. At the end a check of the stopping criteria is
    % performed and the loop is aborted if fulfilled.
    
    optim.mainLoopProcessHandler(currIter);
    
    if optim.shallNotPass
        break;
    end
    
    % moving and final strategy things before next iteration
    permat = bsxfun(@(population,y) population(randperm(y(1))), basemat', nSwarm(ones(nSwarm,1)))';
    v(1:nSwarm,1:nPar)=currIter.population(permat(1:nSwarm,1),1:nPar) + F*(currIter.population(permat(1:nSwarm,1),1:nPar)-currIter.population(permat(1:nSwarm,2),1:nPar));
    
    r=repmat(randi([1 nPar],nSwarm,1),1,nPar);
    muv=((rand(nSwarm,nPar)<cr)+(basej==r))~=0;
    mux=1-muv;
    pop_reco(1:nSwarm,1:nPar)=currIter.population(1:nSwarm,1:nPar).*mux(1:nSwarm,1:nPar)+v(1:nSwarm,1:nPar).*muv(1:nSwarm,1:nPar);
    
    pop_reco=findrange(pop_reco,paramRange);
    
end

end


% %% -----------------Subfunctions------------------------------------- %%
% ------------------- paramRange function ----------------------------------
function pop=findrange(pop,paramRange)
upb = repmat(paramRange(:,2)',size(pop,1),1);
lowb = repmat(paramRange(:,1)',size(pop,1),1);
runbound = 0;
while (runbound~=1)
    oobd = [find(pop(:,1:end) > upb) ; find(pop(:,1:end) < lowb)];
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
