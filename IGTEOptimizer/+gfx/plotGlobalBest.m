function plotGlobalBest(optim, currIter, figId)
% plotGlobalBest : simple plot showing the global best evolution over the
% iterations of the optimization process.



figure(figId)
scatter(currIter.iIter, min(currIter.quality), 'r*')
% pause(optim.plotConfig.pauseDuration)
hold on

end