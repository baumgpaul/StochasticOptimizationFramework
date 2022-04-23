function plotTesfun2DSpacePopZoom(optim, currIter, figId)
    
    N = 100;
    pop = currIter.population;
    
    [valMinG, bestInd] = min(optim.results.globalBestQuality(1:currIter.iIter));
    bestIndividual = optim.results.localBestPopulation(bestInd, :);
    
    xmin = min(currIter.population);
    xmax = max(currIter.population);
    
    x = linspace(xmin(1)-0.1*xmin(1), xmax(1)+0.1*xmax(1),N);
    y = linspace(xmin(2)-0.1*xmin(2),xmax(2)+0.1*xmax(2),N);
    
    [xx, yy] = meshgrid(x,y);
    
    X = [reshape(xx,N*N,1), reshape(yy,N*N,1)];
    Y = optim.problemCfg.forwardSolver(X);
    
    if size(Y,2) > 1
        Y = sum(Y,2);
    end
    
    figure(figId)
    pc = pcolor(xx,yy,reshape(Y, size(xx)));
    set(pc, 'EdgeColor', 'none');
    colorbar
    
    hold on
    
    sc = scatter(pop(:,1), pop(:,2));
    set(sc, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k')
    
    scb = scatter(bestIndividual(1), bestIndividual(2));
    set(scb, 'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'red')
    
    hold off
    
    title(['Iteration : ' num2str(currIter.iIter) ' Best Q = ' num2str(valMinG)])
    legend('Objective Fun', 'Current population', 'Best overall')
    
end