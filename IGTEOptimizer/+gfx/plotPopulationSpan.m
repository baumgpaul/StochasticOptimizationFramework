function plotPopulationSpan(optim, currIter, figId)

figure(figId)

yWorst = max(currIter.quality);
yBest = min(currIter.quality);

plot(currIter.iIter, log10(yWorst), 'bo')
hold on
plot(currIter.iIter, log10(yBest), 'ro')

xlabel('Iteration')
ylabel('Quality')

legend({'Worst in iter.', 'Best in iter.'})
title(['Population spread'])




end