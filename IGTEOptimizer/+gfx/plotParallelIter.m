function plotParallelIter(optim, currIter)

figure(optim.plotCfg.pltId)
X = (currIter.population - optim.problemCfg.parMin)/(optim.problemCfg.parMax - ...
                           optim.problemCfg.parMin);

end

