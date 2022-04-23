function plotQualityContributions(optim, currIter, figId)

    figure(figId)
    
    [minQual, indMin] = min(currIter.quality);
    fuzziesInd = 1:length(optim.problemCfg.membershipFunctions);
    normedQualC = currIter.qualityContribution(indMin,:) ./ minQual * 100;
    
    bar(fuzziesInd, normedQualC)
    grid on
    xticklabels(optim.problemCfg.weightedObjNames)
    title(['Quality contribution, best from iteration ' num2str(currIter.iIter)])
    xlabel('Weight * Objective')
    ylabel('Contribution [%]')
    
end