## Membership functions : 
Definitions of fuzzy membership functions for the scalarization of multiple objectives. One needs to define a membership function for every objective of the problem. Important notice : **the optimal value is 0 and the worst value is 1**. The setup is done in the problem configuration function. Looking at the example of the `testfun.cfgTestTwoObjectiveFun` test function. One can see the following lines for the membership functions : 

```matlab

% Scalarization type :
problemConfig.scalarization = 1;

% Objective 1 :
problemConfig.membershipFunctions{1}.type=1;
problemConfig.membershipFunctions{1}.parameter(1) = 1;
problemConfig.membershipFunctions{1}.objectivepar(1) = 1;

% Objective 2 : 
problemConfig.membershipFunctions{2}.type=2;
problemConfig.membershipFunctions{2}.k = 0.5;
problemConfig.membershipFunctions{2}.p10 = 0.1;
problemConfig.membershipFunctions{2}.p90 = 0.3;
problemConfig.membershipFunctions{2}.objectivepar(1) = 2;
```

First the type of scalarization needs to be chosen with `problemConfig.scalarization = sType` where `sType` can be :
- Sum of the individual contributions (sType = 1)
- Product of the individual contributions (sType = 2)
- Min of the individual contributions (sType = 3)
- Max of the individual contributions (sType = 4)

Next one needs to define the fuzzy functions for each objective. There are currently 3 types of fuzzy functions. 

- The first one (type = 1) is the bypass function $`f(x) = kx`$ which does not alter the objective value except for the multiplied coefficient $`k`$.
- The second one (type = 2) is the onesided fuzzy function with parameters $`p10`$ and $`p90`$ to set the threshold levels.
- The second one (type = 3) is the onesided fuzzy function with parameters $`p10`$ and $`p90`$ to set the threshold levels, here these parameters are arrays with length 2. 

<img src="doc/imgs/fuzzy_function_types.png" alt="fuzzy_funs" style="height: 400px; width:500px;"/>

At the end the fuzzified contributions are condensed into a scalar value according to the selected scalarization process where additionally each contribution is multiplied by the factor $`k`$. In the case of summation of the individual fuzzy contributions one would have : 

```math
y_{scalarized} = \sum\limits_{i} k_i \mu_i(x)
```