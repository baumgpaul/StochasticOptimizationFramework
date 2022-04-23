function plotParallelCoord(optim, currIter, figId)

[valMin, indMin] = min(currIter.quality);
[valMinG, indMinG] = min(optim.improvedPop.Quality);

figure(figId)
hold on
ylim([0, 1])
if currIter.iIter == 1
    
    % Plot variable separators :
    for iPlt = 1:optim.problemCfg.nPar
        plot([iPlt, iPlt], [0, 1], 'k:', 'linewidth', 2)
    end
    
    bestVal = [valMinG, optim.improvedPop.Population(indMinG, :)];
    
    % Plot best one :
    optim.plotCfg.swap.bestLine = plot([0, optim.plotCfg.paramInts], ...
        [valMinG, (bestVal(2:end) - optim.problemCfg.parMin)./(optim.problemCfg.parMax - optim.problemCfg.parMin)], ... 
        '*-', ...
        'linewidth', 2.0, ...
        'Color', [0.4940, 0.1840, 0.5560]);
    
    optim.plotCfg.swap.bestPts = text([0, optim.plotCfg.paramInts] - 0.5, ...
        [valMinG, (bestVal(2:end) - optim.problemCfg.parMin)./(optim.problemCfg.parMax - optim.problemCfg.parMin)] + 0.05,...
        split(num2str(bestVal)));
    
    xticks([0, optim.plotCfg.paramInts])
    xticklabels([{'Q'}, optim.problemCfg.parameterNames(:)'])
    colormap(optim.plotCfg.colGrad(:,1:3))
    colorbar
end

iColor = optim.colGradIndexer(valMin);
colorArr = optim.plotCfg.colGrad(iColor,:);

title(['Iteration : ' num2str(currIter.iIter) ' Best Q = ' num2str(valMinG)])

bestVal = [optim.colGradIndexer(valMinG)/100, optim.improvedPop.Population(indMinG, :)];
currY = [iColor/100, (currIter.population(indMin, :) - optim.problemCfg.parMin ...
    )./(optim.problemCfg.parMax - optim.problemCfg.parMin)];

plot([0, optim.plotCfg.paramInts], ...
    currY, ... 
    'linewidth', 0.9, ...
    'Color', colorArr)

set(optim.plotCfg.swap.bestLine, 'YData', ...
    [bestVal(1), (bestVal(2:end) - optim.problemCfg.parMin ...
        )./(optim.problemCfg.parMax - optim.problemCfg.parMin)])

delete(optim.plotCfg.swap.bestPts)

optim.plotCfg.swap.bestPts = text([0, optim.plotCfg.paramInts] - 0.5, ...
        [bestVal(1), (bestVal(2:end) - optim.problemCfg.parMin ...
        )./(optim.problemCfg.parMax - optim.problemCfg.parMin)] + 0.05, ...
        split(num2str(bestVal)));
    
uistack(optim.plotCfg.swap.bestLine, 'top')
    
end