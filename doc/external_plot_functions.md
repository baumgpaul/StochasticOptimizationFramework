## External plotting and printing function definitions : 
Plotting and printing functions can be externally defined and passed to the framework to have full access to iteration, run and global data. The functions need to have the following structure : 

```matlab
function plotPrototype(optim, currIter, figId)
    figure(figId)
    % plotting code 
end
```

Additionally one has the option to store data in between iterations which might be needed for various reasons inside the plotting functions with : 
```matlab
% Structure which can be used to store any data needed.
optim.plotCfg.swap
```