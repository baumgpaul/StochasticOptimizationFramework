function plotParamDistribution(optim, currIter, figId)

[valMinG, indMinG] = min(optim.improvedPop.Quality);

figure(figId)
hold on

if currIter.iIter == 1
    
    ylim([-0.1, 1.1])
    xlim([0.5, optim.problemCfg.nPar+1])
    yticks([0, 1])
    yticklabels({'min', 'max'})
    
    bestVal = optim.improvedPop.Population(indMinG, :);
    
    plot([0.5, optim.problemCfg.nPar+1], [1, 1], 'k:', 'linewidth', 1.)
    plot([0.5, optim.problemCfg.nPar+1], [0, 0], 'k:', 'linewidth', 1.)
    
    % Plot variable separators :
    for iPlt = 1:optim.problemCfg.nPar
        plot([iPlt, iPlt], [0, 1], 'k:', 'linewidth', 1.0)
        
        optim.plotCfg.swap.hDist{iPlt} = plot([0], [0], '-.', 'Color', ...
            [0.5255, 0.2078, 0.5882, 0.7], 'linewidth', 1.5);
        
        text(iPlt, -0.05, num2str(optim.problemCfg.parMin(iPlt)))
        text(iPlt,  1.05, num2str(optim.problemCfg.parMax(iPlt)))
    end
    
    % Plot best one :
    optim.plotCfg.swap.bestScat = scatter(optim.plotCfg.paramInts, ...
        (optim.improvedPop.Population(indMinG, :) - optim.problemCfg.parMin ...
        )./(optim.problemCfg.parMax - optim.problemCfg.parMin), ...
        100, ...
        's', ...
        'MarkerFaceColor', [0.4940, 0.1840, 0.5560], ...
        'MarkerEdgeColor', [0.4940, 0.1840, 0.5560]);
    
    optim.plotCfg.swap.bestPts = text(optim.plotCfg.paramInts - 0.2, ...
        (bestVal - optim.problemCfg.parMin)./(optim.problemCfg.parMax - optim.problemCfg.parMin) - 0.1,...
        split(num2str(bestVal)));
    
    set(optim.plotCfg.swap.bestPts, 'Rotation', 90);
    
    xticks(optim.plotCfg.paramInts)
    xticklabels(optim.problemCfg.parameterNames)
    colormap(optim.plotCfg.colGrad(:,1:3))
    colorbar
end

iColor = optim.colGradIndexer(1 - optim.results.localBestQuality(currIter.iIter));
colorArr = optim.plotCfg.colGrad(iColor,:);

title(['Iteration : ' num2str(currIter.iIter) ',  Best Q = ' num2str(valMinG)])

bestPopulationNormd = (optim.results.localBestPopulation(currIter.iIter,:) - ...
    optim.problemCfg.parMin ...
    )./(optim.problemCfg.parMax - optim.problemCfg.parMin);
bestVal = optim.improvedPop.Population(indMinG, :);

scatter(optim.plotCfg.paramInts, ...
    bestPopulationNormd, ...
    35, ...
    'MarkerFaceColor', colorArr(:,1:3), ...
    'MarkerFaceAlpha', colorArr(:,4), ...
    'MarkerEdgeColor', colorArr(:,1:3), ...
    'MarkerEdgeAlpha', colorArr(:,4))

normedPointsHist = (optim.results.localBestPopulation(1:currIter.iIter, :) ...
    - optim.problemCfg.parMin)./(optim.problemCfg.parMax - optim.problemCfg.parMin);

for iParam = 1:length(bestPopulationNormd)
    [F,XI] = ksdensity(normedPointsHist(:, iParam), 'Support', [0, 1]);
    F = F/(2*max(F));
    set(optim.plotCfg.swap.hDist{iParam}, 'XData', F+iParam, 'YData', XI)
end

set(optim.plotCfg.swap.bestScat, 'YData', ...
    (optim.improvedPop.Population(indMinG, :) - optim.problemCfg.parMin ...
    )./(optim.problemCfg.parMax - optim.problemCfg.parMin))

delete(optim.plotCfg.swap.bestPts)

optim.plotCfg.swap.bestPts = text(optim.plotCfg.paramInts - 0.2, ...
        (bestVal - optim.problemCfg.parMin ...
        )./(optim.problemCfg.parMax - optim.problemCfg.parMin) - 0.1, ...
        split(num2str(bestVal)));
set(optim.plotCfg.swap.bestPts, 'Rotation', 90);

uistack(optim.plotCfg.swap.bestScat, 'top')

end