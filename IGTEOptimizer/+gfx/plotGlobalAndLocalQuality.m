function plotGlobalAndLocalQuality(optim, currIter, figId)

    figure(figId)
    
    subplot(2,1,1)
    scatter(currIter.iIter, optim.results.localBestQuality(currIter.iIter), 'r*')
    title('Best quality in population from iteration')
    xlabel('Iteration')
    hold on
    
    subplot(2,1,2)
    scatter(currIter.iIter, optim.results.globalBestQuality(currIter.iIter), 'b*')
    title('Overall best quality')
    xlabel('Iteration')
    hold on
    
end