classdef IGTEOptimizer < handle
    %IGTEOptimizer Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        strategy = '';
        dumpFileName = '';
        pthSep = '/';
        nline = sprintf('\n');
        
        parseRes = struct();
        
        commonCfg = struct();
        problemCfg = struct();
        strategyCfg = struct();
        plotCfg = struct();
        dashboardCfg = struct();
        report = struct();
        
        % Membership functions setup :
        membershipFuncs = {};
        scalarizationFunc = @(x) x;
        
        memParamTypes = {'onesided', 'twosided'}
        kSum = 1;
        kProd = 1;
        probCfgArr = [];
        
        dashbApp = [];
        
        % Global results hold the final results of every local results
        % calculation. Does not get erased or replaced in any way during
        % the runtime of the optimization.
        results = struct();
        runData = {};
        finalResults = struct();
        improvedPop = struct();
        initialPopulation = [];
        
        % Define stopping criterions : default all of them are initialized
        % but to run forever.
        stoppingCriteria = struct();
        stopReason = {};
        shallNotPass = true;
        
        % Log declaration :
        qualityLog = [];
        parameterLog = [];
        
        objectiveLog = [];
        qualityContributionLog = [];
        returnValueLog = [];
        
        % Start time snapshot :
        startTime = 0;
        iterationStartTime = 0;
        endTime = 0;
        
        
    end
    
    methods
        
        function obj = IGTEOptimizer(varargin)
            % IGTEOptimizer initializer : main class controlling the data
            % exchange and interfaces behind the optimization strategies.
            %
            % Inputs :
            %
            %        - strategy [string] : 'DE', 'Firefly', 'ES', ...
            %        - probConf [struct] : needs to have implemented :
            %                            - forwardSolver [function handle]
            %                            - parMin, parMax [arrays]
            %                            - nObj [int]
            %                            - nRestVal [int]
            %
            %        - nRuns (optional) [int = 1]
            %        - logSelector (optional) [cell array = {'all'}]
            %        - extPlotFun (optional) [function handle]
            %        - printFunIter (optional) [function handle]
            %        - printFunRun (optional) [function handle]
            %        - enablePrintIter (optional) [bool = true]
            %        - enablePrintRun (optional) [bool = true]
            %        - enablePlotting (optional) [bool = false]
            %        - enableDataDump (optional) [bool = true]
            %        - warmStartData (optional) [string = '']
            %        - enableDashboard (optional) [bool = false]
            %
            % Returns :
            %
            %         - IGTEOptimizer instance
            %
            
            % Default values :
            printDefaultSw = false;
            plotDefaultSw = false;
            dataDumpDefaultSw = false;
            enableDeshboardSw = false;
            warmStartDefault = '';
            stopCritDefault = struct('ph',0);
            logSelectorDefault = {''};
            everyNthDefault = 1;
            dummyPlotFuncs = {@dummyPlotFunc};
            isFunHandle = @(x) isa(x, 'function_handle');
            checkCfg = @(x) isstruct(x) || ischar(x);
            
            p = inputParser;
            addRequired(p, 'strategyCfg', checkCfg);
            addParameter(p, 'problemCfg', testfun.cfgProblemRosenbrock, checkCfg);
            addParameter(p, 'stoppingCriteria', stopCritDefault, @isstruct);
            addParameter(p, 'logSelector', logSelectorDefault, @iscell);
            addParameter(p, 'extPlotFun', dummyPlotFuncs, @iscell);
            addParameter(p, 'printFunIter', @defaultPrintFuncIter, isFunHandle);
            addParameter(p, 'printFunRun', @defaultPrintFuncRun, isFunHandle);
            addParameter(p, 'enablePrintIter', printDefaultSw, @islogical);
            addParameter(p, 'enablePrintRun', printDefaultSw, @islogical);
            addParameter(p, 'enablePlotting', plotDefaultSw, @islogical);
            addParameter(p, 'enableDataDump', dataDumpDefaultSw, @islogical);
            addParameter(p, 'nRuns', 1, @isnumeric);
            addParameter(p, 'warmStartData', warmStartDefault, @ischar);
            addParameter(p, 'enableDashboard', enableDeshboardSw, @islogical);
            addParameter(p, 'plotEveryNth', everyNthDefault, @isnumeric);
            addParameter(p, 'initialization', 'UNIFORM', @ischar);
            addParameter(p, 'saveFiguresEveryRun', false, @islogical);
            addParameter(p, 'saveFiguresEveryIter', false, @islogical);
            addParameter(p, 'figFormat', 'png', @ischar);
            addParameter(p, 'figResolution', 150, @isnumeric);
            addParameter(p, 'replayDataPath', './', @ischar);
            
            parse(p, varargin{:});
            
            obj.parseRes = p.Results;
            
            % Change path separator if not unix :
            if ispc
                obj.pthSep = '\';
            end
            
            % Initialize the optimizer :
            obj.initOptimizer();
            
        end
        
        function initOptimizer(obj)
            % For the different configs all of the possible fields need to
            % be defined such that the user can see all of the available
            % properties which can be edited. (Needs to be expanded only as
            % an example shown below)
            
            % Initialize problemCfg :
            if ischar(obj.parseRes.strategyCfg) && ...
                    strcmpi(obj.parseRes.strategyCfg, 'TEST')
                
                obj.initTestNBenchmark('TEST');
                
                % do testing !
                DEConfig = optim.initConfigDE;
                obj.testStrategy(DEConfig)
                
            elseif ischar(obj.parseRes.problemCfg) && ...
                    strcmpi(obj.parseRes.problemCfg, 'BENCHMARK')
                
                obj.initTestNBenchmark('BENCHMARK');
                
                % do benchmarking !
                obj.runBenchmarking()
                
            elseif ischar(obj.parseRes.strategyCfg) && ...
                    strcmpi(obj.parseRes.strategyCfg, 'PLAYBACK')
                
                parseResult = obj.parseRes;
                data = load(obj.parseRes.replayDataPath);
                obj = data.obj;
                
                % Set some variables :
                obj.setWindowSize();
                obj.parseRes.enablePlotting = true;
                obj.parseRes.saveFiguresEveryIter = parseResult.saveFiguresEveryIter;
                obj.parseRes.saveFiguresEveryRun = parseResult.saveFiguresEveryRun;
                obj.parseRes.figResolution = parseResult.figResolution;
                obj.parseRes.figFormat = parseResult.figFormat;
                obj.parseRes.extPlotFun = parseResult.extPlotFun;
                obj.parseRes.plotEveryNth = parseResult.plotEveryNth;
                
                % Generate folder structure :
                obj.generateFolderStructure()
                
                % Initialize plot config :
                obj.initPlotConfig();
                
                % Init memFunc:
                obj.initMembershipFunctions();
                
                % Start playback loop runner :
                obj.startPlaybackLoop();
                
            elseif isstruct(obj.parseRes.problemCfg)
                
                % Initialize commonCfg :
                obj.commonCfg.logSelector = obj.parseRes.logSelector;
                obj.commonCfg.nLogFun = 0;
                obj.commonCfg.logFuncs = {};
                obj.commonCfg.enableDataDump = obj.parseRes.enableDataDump;
                obj.commonCfg.warmStartDataLoc = obj.parseRes.warmStartData;
                obj.commonCfg.warmStart = false;
                obj.commonCfg.initialization = obj.parseRes.initialization;
                obj.parseRes.problemCfg.parMinTrue = zeros(size(obj.parseRes.problemCfg.parMin));
                obj.parseRes.problemCfg.parMaxTrue = ones(size(obj.parseRes.problemCfg.parMax));
                
                if isfield(obj.parseRes.problemCfg, 'normalizePopulation') && ...
                    obj.parseRes.problemCfg.normalizePopulation
                    
                    obj.parseRes.problemCfg.parMinTrue = obj.parseRes.problemCfg.parMin;
                    obj.parseRes.problemCfg.parMaxTrue = obj.parseRes.problemCfg.parMax;
                    obj.parseRes.problemCfg.parMin = zeros(size(obj.parseRes.problemCfg.parMin));
                    obj.parseRes.problemCfg.parMax = ones(size(obj.parseRes.problemCfg.parMax));
                                    
                end
                
                obj.setWindowSize();
                
                obj.initProblemCfg()
                
                if ~strcmp(obj.parseRes.warmStartData, '')
                    obj.commonCfg.warmStart = true;
                    obj.setUpInitPopulation();
                end
                
                obj.commonCfg.nRuns = obj.parseRes.nRuns;
                obj.commonCfg.iRun = 1;
                
                % Files and names generation :
                obj.generateFolderStructure();
                
                % Plot interface function :
                obj.initPlotConfig();
                
                % Init memFunc:
                obj.initMembershipFunctions();
                
                if (isfield(obj.problemCfg, 'plotMemFuns') && ...
                    isfield(obj.problemCfg, 'extPercent')) && ...
                    obj.problemCfg.plotMemFuns
                    
                    obj.plotMembershipFunctions(obj.problemCfg.extPercent);
                    
                end
                
                % Printing initialization :
                obj.commonCfg.enablePrintIter = obj.parseRes.enablePrintIter;
                obj.commonCfg.enablePrintRun = obj.parseRes.enablePrintRun;
                
                if obj.commonCfg.enablePrintIter
                    obj.commonCfg.printFunIter = obj.parseRes.printFunIter;
                else
                    obj.commonCfg.printFunIter = @dummyPrintFunc;
                end
                
                if obj.commonCfg.enablePrintRun
                    obj.commonCfg.printFunRun = obj.parseRes.printFunRun;
                else
                    obj.commonCfg.printFunRun = @dummyPrintFunc;
                end
                
                % Initialize strategyCfg :
                obj.strategyCfg = obj.parseRes.strategyCfg;
                
                % Problem init additional variables :
                obj.initProblemConfig();
                
                % Initialize stopping criteria :
                obj.initStopCriteria();
                
                % Data init :
                obj.improvedPop.Quality = realmax*ones(obj.strategyCfg.nSwarm,1);
                
                % Log initialization :
                obj.initLogVariables();
                obj.runData = cell(1, obj.commonCfg.nRuns);
                
                % Dashboard initialization :
                obj.dashboardCfg.isEnabled = obj.parseRes.enableDashboard;
                
                if obj.dashboardCfg.isEnabled
                    obj.plotCfg.mainPlotHandler = @plotHandlerDashboard;
                    obj.dashbApp = gfx.dashboardApp;
                    obj.dashbApp.optim = obj;
                else
                    obj.plotCfg.mainPlotHandler = @plotHandlerStandalone;
                end
                
            end
        end
        
        function setWindowSize(obj)
            obj.commonCfg.mainWinSize = get(0, 'screensize');
            obj.commonCfg.mainWinSize = obj.commonCfg.mainWinSize(3:end);
        end
        
        function initFigures(obj)
            
            if ~obj.plotCfg.noFig
                
                xpos = 10; ypos = 10;
                
                for iFig = 1:obj.plotCfg.nPlotFuncs
                    f = figure(iFig);
                    
                    if (xpos + obj.plotCfg.standardFigDim(1)) < obj.commonCfg.mainWinSize(1)
                        
                        f.Position(1:2) = [xpos, ypos];
                        xpos = xpos + obj.plotCfg.standardFigDim(1);
                        
                    elseif (ypos + obj.plotCfg.standardFigDim(2)) < obj.commonCfg.mainWinSize(2)
                        
                        xpos = 0;
                        ypos = ypos + obj.plotCfg.standardFigDim(2);
                        f.Position(1:2) = [xpos, ypos];
                        xpos = xpos + obj.plotCfg.standardFigDim(1);
                        
                    end
                end
            end
        end
        
        function initPlotConfig(obj)
            
            obj.plotCfg.pauseDuration = 0.1;
            obj.plotCfg.saveFigsRun = obj.parseRes.saveFiguresEveryRun;
            obj.plotCfg.saveFigsIter = obj.parseRes.saveFiguresEveryIter;
            obj.plotCfg.figResolution = obj.parseRes.figResolution;
            obj.plotCfg.figFormat = obj.parseRes.figFormat;
            obj.plotCfg.extFigNum = 1;
            obj.plotCfg.intFigNum = 2;
            obj.plotCfg.enablePlotting = obj.parseRes.enablePlotting;
            obj.plotCfg.paramInts = 1:obj.problemCfg.nPar;
            obj.plotCfg.colGradThreshold = obj.problemCfg.objThreshold;
            obj.plotCfg.everyNth = obj.parseRes.plotEveryNth;
            obj.plotCfg.standardFigDim = [580, 530];
            
            obj.plotCfg.cgK1 = -90/obj.plotCfg.colGradThreshold;
            obj.plotCfg.cgK2 = -10/(realmax-obj.plotCfg.colGradThreshold);
            obj.plotCfg.cgD1 = 100;
            obj.plotCfg.cgD2 = 10 - obj.plotCfg.cgK2*obj.plotCfg.colGradThreshold;
            
            obj.plotCfg.colGrad = interp1([0, 1], [1 0 0; 0 1 0], ...
                linspace(0, 1, 100));
            obj.plotCfg.swap = struct();
            obj.plotCfg.swap.paramDist = [];
            obj.plotCfg.swap.paramsNormd = [];
            obj.plotCfg.swap.hDist = cell(obj.problemCfg.nPar,1);
            
            obj.plotCfg.colGrad = [obj.plotCfg.colGrad, ones(100,1)*0.3];
            
            if obj.plotCfg.enablePlotting
                obj.plotCfg.extPlotFuncs = obj.parseRes.extPlotFun;
                obj.plotCfg.nPlotFuncs = length(obj.plotCfg.extPlotFuncs);
                obj.plotCfg.noFig = false;
            else
                obj.plotCfg.extPlotFuncs = {@dummyPlotFunc};
                obj.plotCfg.nPlotFuncs = 1;
                obj.plotCfg.noFig = true;
            end
            
            obj.plotCfg.plotPths = obj.generatePlotPaths();
            obj.initFigures();
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%% MEMBERSHIP FUN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function initMembershipFunctions(obj)
            
            obj.setScalarizationFun();
            obj.membershipFuncs = cell(obj.problemCfg.nObj);
            
            for iFun = 1:obj.problemCfg.nObj
                obj.setMembershipVariables(iFun);
                obj.membershipFuncs{iFun} = obj.getMembershipFunction(iFun);
            end
        end
        
        function setMembershipVariables(obj, iFun)
            
            isParametrized = any(strcmp(obj.problemCfg.membershipFunctions{iFun}.type, obj.memParamTypes));
            
            if isParametrized
                
                p10 = obj.problemCfg.membershipFunctions{iFun}.p10;
                p90 = obj.problemCfg.membershipFunctions{iFun}.p90;
                
                c = (p10.*log(1/9) - p90.*log(9))./(log(1/9) - log(9));
                obj.problemCfg.membershipFunctions{iFun}.a = -log(9)./(p10 - c);
                obj.problemCfg.membershipFunctions{iFun}.c = c;
                
            end
            
        end
        
        function memFun = getMembershipFunction(obj, iFun)
            
            memFun = @(x) x;
            
            switch obj.problemCfg.membershipFunctions{iFun}.type
                
                case {'flat', 1}
                    memFun = @(x) obj.problemCfg.membershipFunctions{iFun}.k .* x;
                    
                case {'onesided', 2}
                    a   = obj.problemCfg.membershipFunctions{iFun}.a;
                    c   = obj.problemCfg.membershipFunctions{iFun}.c;
                    memFun = @(x) obj.problemCfg.membershipFunctions{iFun}.k .* obj.memFunOneSided(x, a, c);
                    
                case {'twosided', 3}
                    a   = obj.problemCfg.membershipFunctions{iFun}.a;
                    c   = obj.problemCfg.membershipFunctions{iFun}.c;
                    memFun = @(x) obj.problemCfg.membershipFunctions{iFun}.k .* obj.memFunTwoSided(x, a, c);
                    
            end
            
        end
        
        function y = memFunOneSided(~, x, a, c)
            y = ((1)./(1+exp(-a*(x-c))));
        end
        
        function y = memFunTwoSided(~, x, a, c)
            y = ((1)./(1+exp(-a(1)*(x-c(1))))+(1)./(1+exp(-a(2)*(x-c(2))))-1);
        end
        
        function setScalarizationFun(obj)
            
            obj.setAccumulatedVariables();
            
%             if obj.problemCfg.nObj == 1
%                 obj.problemCfg.scalarization = 'bypass';
%             end
            
            switch obj.problemCfg.scalarization
                
                case {'sum'}
                    obj.scalarizationFunc = @(qContrib) obj.kSum  -  sum(qContrib,2);
                    
                case {'product'}
                    obj.scalarizationFunc = @(qContrib) obj.kProd - prod(qContrib,2);
                    
                case {'bypass'}
                    obj.scalarizationFunc = @(qContrib) qContrib;
                    
            end
            
        end
        
        function setAccumulatedVariables(obj)
            
            obj.probCfgArr = [obj.problemCfg.membershipFunctions{:}];
            obj.kSum = sum([obj.probCfgArr.k]);
            obj.kProd = prod([obj.probCfgArr.k]);
            
        end
        
        function plotMembershipFunctions(obj, extPercent)
            
            for iObj = 1:obj.problemCfg.nObj
                
                figure();
                gfx.plotMemFun(obj, iObj, extPercent);
                
            end
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%% MEMBERSHIP FUN END %%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function initProblemConfig(obj)
            obj.problemCfg.weightedObjNames = obj.problemCfg.objectiveNames;
            for iObj = 1:obj.problemCfg.nObj
                obj.problemCfg.weightedObjNames{iObj} = [num2str(obj.problemCfg.membershipFunctions{iObj}.k), ...
                    '*', obj.problemCfg.weightedObjNames{iObj}];
            end
        end
        
        function generateFolderStructure(obj)
            obj.commonCfg.resultsFolder = [obj.problemCfg.name, '_results', obj.pthSep];
            obj.commonCfg.plotsFolder = [obj.commonCfg.resultsFolder, ...
                obj.pthSep, 'plots', obj.pthSep];
            
            obj.generateDumpFileName();
            
            if obj.commonCfg.enableDataDump && ~exist(obj.commonCfg.resultsFolder, 'dir')
                mkdir(obj.commonCfg.resultsFolder);
            end
            
            if obj.parseRes.enablePlotting && ...
                    (obj.parseRes.saveFiguresEveryRun || obj.parseRes.saveFiguresEveryIter) && ...
                    ~exist(obj.commonCfg.plotsFolder, 'dir')
                mkdir(obj.commonCfg.plotsFolder);
            end
        end
        
        function pltPaths = generatePlotPaths(obj)
            
            pltPaths = {};
            
            if obj.plotCfg.enablePlotting
                
                pltPaths = cell(1, obj.plotCfg.nPlotFuncs);
                for iFig = 1:obj.plotCfg.nPlotFuncs
                    pltPaths{iFig} = [obj.commonCfg.plotsFolder, 'plot_' num2str(iFig)];
                end
            end
            
        end
        
        function initTestNBenchmark(obj, option)
            
            if strcmp(option, 'TEST')
                
                obj.commonCfg.resultsFolder = ...
                ['TEST_runner', obj.pthSep];
            
            else
                
                obj.commonCfg.resultsFolder = ...
                [strrep(obj.parseRes.strategyCfg.name, ' ', '_'), ...
                '_report', obj.pthSep];
            
            end
            
            obj.report.filePath = [obj.commonCfg.resultsFolder, 'report.txt'];
            
            if ~exist(obj.commonCfg.resultsFolder, 'dir')
                mkdir(obj.commonCfg.resultsFolder);
            end
            
            obj.report.fileOutTxt = '';
            
        end
        
        function testStrategy(obj, strategy)
            
            obj.parseRes.strategyCfg = strategy;
            
            disp([obj.nline ' Running tests : ' obj.nline])
            obj.addLineToReport(['TEST REPORT : ' obj.parseRes.strategyCfg.name obj.nline]);
            
            % Running basic functionality test : 
            try
                % Initialize optimizer :
                stopCrit.maxIter = 2;
                testOptimizer = IGTEOptimizer(obj.parseRes.strategyCfg, ...
                    'problemCfg', testfun.cfgProblemRosenbrockMultidim, ...
                    'stoppingCriteria', stopCrit);
                
                % Start optimization :
                testOptimizer.start();
                
                obj.addLineToReport([' - [PASSED] Basic functionality.' obj.nline]);
                disp('> [PASSED] Basic functionality.')
            catch
                obj.addLineToReport([' - [FAILED] Basic functionality.' obj.nline]);
                error('> [FAILED] Basic functionality.')
            end
            
            % Running membership functionality test 1 : 
            try
                % Initialize optimizer :
                stopCrit.maxIter = 2;
                testOptimizer = IGTEOptimizer(obj.parseRes.strategyCfg, ...
                    'problemCfg', testfun.cfgProblemRosenbrock, ...
                    'stoppingCriteria', stopCrit);
                
                % Start optimization :
                testOptimizer.start();
                
                obj.addLineToReport([' - [PASSED] Membership functionality flat.' obj.nline]);
                disp('> [PASSED] Membership functionality flat.')
            catch
                obj.addLineToReport([' - [FAILED] Membership functionality flat.' obj.nline]);
                error('> [FAILED] Membership functionality flat.')
            end
            
            % Running membership functionality test 2 : 
            try
                % Initialize optimizer :
                stopCrit.maxIter = 2;
                testOptimizer = IGTEOptimizer(obj.parseRes.strategyCfg, ...
                    'problemCfg', testfun.cfgProblemRosenbrockOneSided, ...
                    'stoppingCriteria', stopCrit);
                
                % Start optimization :
                testOptimizer.start();
                
                obj.addLineToReport([' - [PASSED] Membership functionality onesided.' obj.nline]);
                disp('> [PASSED] Membership functionality onesided.')
            catch
                obj.addLineToReport([' - [FAILED] Membership functionality onesided.' obj.nline]);
                error('> [FAILED] Membership functionality onesided.')
            end
            
            % Running membership functionality test 3 : 
            try
                % Initialize optimizer :
                stopCrit.maxIter = 2;
                testOptimizer = IGTEOptimizer(obj.parseRes.strategyCfg, ...
                    'problemCfg', testfun.cfgProblemRosenbrockTwoSided, ...
                    'stoppingCriteria', stopCrit);
                
                % Start optimization :
                testOptimizer.start();
                
                obj.addLineToReport([' - [PASSED] Membership functionality twosided.' obj.nline]);
                disp('> [PASSED] Membership functionality twosided.')
            catch
                obj.addLineToReport([' - [FAILED] Membership functionality twosided.' obj.nline]);
                error('> [FAILED] Membership functionality twosided.')
            end
            
            % Initialize optimizer 1D convergence test :
            stopCrit.maxIter = 50;
            testOptimizer = IGTEOptimizer(obj.parseRes.strategyCfg, ...
                'problemCfg', testfun.cfgProblemXSquared, ...
                'stoppingCriteria', stopCrit, ...
                'nRuns', 3);
            
            % Start optimization :
            testOptimizer.start();
            quality = [testOptimizer.runData.quality];
            
            if any(quality < 1e-8)
                testRes = 'PASSED';
            else
                testRes = 'FAILED';
            end
            
            disp(['> [' testRes '] Basic convergence 1-D.'])
            
            obj.addLineToReport([' - [', testRes, '] Basic convergence 1D.', obj.nline, ...
                '   > Threshold    : 1e-8', obj.nline, ...
                '   > Method score : ', num2str(quality), ...
                obj.nline]);
            
            % Initialize optimizer 1D normalized convergence test :
            stopCrit.maxIter = 50;
            testOptimizer = IGTEOptimizer(obj.parseRes.strategyCfg, ...
                'problemCfg', testfun.cfgProblemXSquaredNormalized, ...
                'stoppingCriteria', stopCrit, ...
                'nRuns', 3);
            
            % Start optimization :
            testOptimizer.start();
            quality = [testOptimizer.runData.quality];
            
            if any(quality < 1e-8)
                testRes = 'PASSED';
            else
                testRes = 'FAILED';
            end
            
            disp(['> [' testRes '] Basic convergence 1-D normalized.'])
            
            obj.addLineToReport([' - [', testRes, '] Basic convergence 1D normalized.', obj.nline, ...
                '   > Threshold    : 1e-8', obj.nline, ...
                '   > Method score : ', num2str(quality), ...
                obj.nline]);
            
            % Initialize optimizer n-D convergence test :
            stopCrit.maxIter = 100;
            testOptimizer = IGTEOptimizer(obj.parseRes.strategyCfg, ...
                'problemCfg', testfun.cfgProblemXSquaredND, ...
                'stoppingCriteria', stopCrit, ...
                'nRuns', 3);
            
            % Start optimization :
            testOptimizer.start();
            quality = [testOptimizer.runData.quality];
            
            if any(quality < 0.01)
                testRes = 'PASSED';
            else
                testRes = 'FAILED';
            end
            
            disp(['> [' testRes '] Basic convergence 5-D.'])
            
            obj.addLineToReport([' - [', testRes, '] Basic convergence 5-D.', obj.nline, ...
                '   > Threshold    : 1e-8', obj.nline, ...
                '   > Method score : ', num2str(quality), ...
                obj.nline]);
           
            % Initialize optimizer n-D normalized convergence test :
            stopCrit.maxIter = 100;
            testOptimizer = IGTEOptimizer(obj.parseRes.strategyCfg, ...
                'problemCfg', testfun.cfgProblemXSquaredNDNormalized, ...
                'stoppingCriteria', stopCrit, ...
                'nRuns', 3);
            
            % Start optimization :
            testOptimizer.start();
            quality = [testOptimizer.runData.quality];
            
            if any(quality < 0.01)
                testRes = 'PASSED';
            else
                testRes = 'FAILED';
            end
            
            disp(['> [' testRes '] Basic convergence 5-D normalized.'])
            
            disp(obj.nline)
            
            obj.addLineToReport([' - [', testRes, '] Basic convergence 5-D normalized.', obj.nline, ...
                '   > Threshold    : 1e-8', obj.nline, ...
                '   > Method score : ', num2str(quality), ...
                obj.nline]);
            
            fid = fopen(obj.report.filePath, 'w');
            fprintf(fid, '%s', obj.report.fileOutTxt);
            fclose(fid);
            
        end
        
        function runBenchmarking(obj)
            
            txt = [obj.nline ' BENCHMARK LOG FOR : ' ...
                obj.parseRes.strategyCfg.name obj.nline];
            disp(txt)
            obj.addLineToReport(txt)
            
            obj.benchmarkStrategy(obj.parseRes.strategyCfg, testfun.cfgProblemRosenbrock);
            obj.benchmarkStrategy(obj.parseRes.strategyCfg, testfun.cfgProblemRosenbrockMultidim);
            obj.benchmarkStrategy(obj.parseRes.strategyCfg, testfun.cfgProblemRosenbrockModified);
            obj.benchmarkStrategy(obj.parseRes.strategyCfg, testfun.cfgProblemRastrigin);
            obj.benchmarkStrategy(obj.parseRes.strategyCfg, testfun.cfgProblemAckley);
            
            fid = fopen(obj.report.filePath, 'w');
            fprintf(fid, '%s', obj.report.fileOutTxt);
            fclose(fid);
            
            disp(' BENCHMARK FINISHED !')
            
        end
        
        function benchmarkStrategy(obj, strategyCfg, problemCfg)
            
            txt = [obj.nline '  - Running benchmark for : ' ...
                problemCfg.name obj.nline];
            disp(txt)
            obj.addLineToReport(txt)
            
            % Initialize optimizer :
            stopCrit.maxFuncCalls = 10000;
            stopCrit.maxIter= round(10000/strategyCfg.nSwarm);
            
            testOptimizer = IGTEOptimizer(strategyCfg, ...
                'problemCfg', problemCfg, ...
                'stoppingCriteria', stopCrit, ...
                'nRuns', 10);
            
            % Start optimization :
            testOptimizer.start();
            quality = [testOptimizer.runData.quality];
            params = [testOptimizer.runData.parameter];
            params = reshape(params, [testOptimizer.problemCfg.nPar, ...
                testOptimizer.commonCfg.nRuns])';
            runTimes = [testOptimizer.runData.runTime];
            
            [minQuality, indMinQ] = min(quality);
            muQuality = mean(quality);
            stdQuality = std(quality);
            muParams = mean(params);
            stdParams = std(params);
            muRuntime = mean(runTimes);
            stdRuntime = std(runTimes);
            
            txt = ['    > Runtime mean    : ' num2str(muRuntime)];
            obj.addLineToReport(txt);
            
            txt = ['    > Runtime std     : ' num2str(stdRuntime)];
            obj.addLineToReport(txt);
            
            txt = ['    > Runtime total   : ' num2str(sum(runTimes))];
            obj.addLineToReport(txt);
            
            txt = ['    > Quality best    : ' num2str(minQuality)];
            obj.addLineToReport(txt);
            
            txt = ['    > Quality mean    : ' num2str(muQuality)];
            obj.addLineToReport(txt);
            
            txt = ['    > Quality std     : ' num2str(stdQuality)];
            obj.addLineToReport(txt);
            
            txt = ['    > Parameters best : ' num2str(params(indMinQ, :))];
            obj.addLineToReport(txt);
            
            txt = ['    > Parameters mean : ' num2str(muParams)];
            obj.addLineToReport(txt);
            
            txt = ['    > Parameters std  : ' num2str(stdParams)];
            obj.addLineToReport(txt);
            
            txt = obj.nline;
            obj.addLineToReport(txt);
            
        end
        
        function addLineToReport(obj, sLine)
            obj.report.fileOutTxt = [obj.report.fileOutTxt, ...
                sLine, obj.nline];
        end
        
        function X = initializePopulation(obj)
            
            if obj.commonCfg.warmStart
                X = obj.initialPopulation;
            else
                switch upper(obj.commonCfg.initialization)
                    case {'LHS'}
                        X = lhsdesign(obj.strategyCfg.nSwarm, obj.problemCfg.nPar);
                        X = X.*(obj.problemCfg.parMax - obj.problemCfg.parMin) + obj.problemCfg.parMin;
                    case {'NORMAL'}
                        X = randn(obj.strategyCfg.nSwarm, obj.problemCfg.nPar).*obj.problemCfg.initStd ...
                            + obj.problemCfg.initMu;
                    case {'UNIFORM'}
                        X = rand(obj.strategyCfg.nSwarm, obj.problemCfg.nPar);
                        X = X.*(obj.problemCfg.parMax - obj.problemCfg.parMin) + obj.problemCfg.parMin;
                    case {'NORMALIZED'}
                        X = lhsdesign(obj.strategyCfg.nSwarm, obj.problemCfg.nPar);
                end
            end
        end
        
        function ind = colGradIndexer(obj, x)
            
            
            ind = round(max(obj.plotCfg.cgK1*x + obj.plotCfg.cgD1, ...
                obj.plotCfg.cgK2*x + obj.plotCfg.cgD2));
            
        end
        
        function initStopCriteria(obj)
            if ~isfield(obj.parseRes.stoppingCriteria, 'maxIter')
                obj.parseRes.stoppingCriteria.maxIter = 1000;
            end
            if ~isfield(obj.parseRes.stoppingCriteria, 'minQual')
                obj.parseRes.stoppingCriteria.minQual.val = inf;
                obj.parseRes.stoppingCriteria.minQual.eps = 0;
            end
            if ~isfield(obj.parseRes.stoppingCriteria, 'maxPopulationEps')
                obj.parseRes.stoppingCriteria.maxPopulationEps = 0;
            end
            if ~isfield(obj.parseRes.stoppingCriteria, 'maxTime')
                obj.parseRes.stoppingCriteria.maxTime = inf;
            end
            if ~isfield(obj.parseRes.stoppingCriteria, 'maxFuncCalls')
                obj.parseRes.stoppingCriteria.maxFuncCalls = inf;
            end
            obj.parseRes.stoppingCriteria.userStop = false;
            obj.parseRes.stoppingCriteria.reasons = {'maxIteration', 'minQuality', ...
                'maxPopulation', 'maxTime', 'maxFuncCalls', 'userStop'};
            
            obj.stoppingCriteria = obj.parseRes.stoppingCriteria();
        end
        
        function reInitOptimizer(obj)
            
            % Data init :
            obj.improvedPop.Quality = realmax*ones(obj.strategyCfg.nSwarm,1);
            
            % Log initialization :
            obj.initLogVariables();
            
        end
        
        function initProblemCfg(obj)
            
            obj.problemCfg = obj.parseRes.problemCfg;
            
            if isfield(obj.parseRes.problemCfg,'nObj')
                obj.problemCfg.nObj = obj.parseRes.problemCfg.nObj;
            else
                obj.problemCfg.nObj = 1;
            end
            
            if isfield(obj.parseRes.problemCfg,'nRestVals')
                obj.problemCfg.nRestVals = obj.parseRes.problemCfg.nRestVals;
            else
                obj.problemCfg.nRestVals = 0;
            end
            
            if isfield(obj.parseRes.problemCfg,'scalarization')
                obj.problemCfg.scalarization = obj.parseRes.problemCfg.scalarization;
            else
                obj.problemCfg.scalarization = 1;
            end
            
            if isfield(obj.parseRes.problemCfg,'objThreshold')
                obj.problemCfg.objThreshold = obj.parseRes.problemCfg.objThreshold;
            else
                obj.problemCfg.objThreshold = 10;
            end
            
            obj.problemCfg.nPar = size(obj.problemCfg.parMin(:),1);
            obj.problemCfg.range = [obj.problemCfg.parMin; obj.problemCfg.parMax]';
            
            if strcmpi(obj.commonCfg.initialization, 'NORMAL')
                if ~isfield(obj.problemCfg, 'initMu')
                    obj.problemCfg.initMu = zeros(1, obj.problemCfg.nPar);
                end
                
                if ~isfield(obj.problemCfg, 'initStd')
                    obj.problemCfg.initStd = ones(1, obj.problemCfg.nPar);
                end
            end
            
        end
        
        function setUpInitPopulation(obj)
            oldData = load(obj.commonCfg.warmStartDataLoc);
            obj.initialPopulation = oldData.obj.finalResults.population;
        end
        
        function generateDumpFileName(obj)
            dtstring = strrep(strrep(datestr(datetime), ' ', '_'), ':', '_');
            obj.dumpFileName = [obj.commonCfg.resultsFolder, ...
                obj.problemCfg.name, '_run_', ...
                num2str(obj.commonCfg.iRun), '_', dtstring, '.mat'];
        end
        
        function initLogVariables(obj)
            
            % Function for initializing the log variables as selected in
            % the log selector variable.
            
            obj.results.globalBestQuality = zeros(obj.stoppingCriteria.maxIter,1);
            obj.results.localBestQuality = zeros(obj.stoppingCriteria.maxIter,1);
            obj.results.localBestPopulation = zeros(obj.stoppingCriteria.maxIter,...
                obj.problemCfg.nPar);
            obj.results.clusterRad = cell(obj.stoppingCriteria.maxIter,1);
            
            iLogFun = 1;
            
            if any(strcmp(obj.commonCfg.logSelector, 'all')) || ...
                    any(strcmp(obj.commonCfg.logSelector, 'quality'))
                
                obj.results.quality = ...
                    zeros(obj.stoppingCriteria.maxIter*obj.strategyCfg.nSwarm,1);
                
                obj.commonCfg.logFuncs{iLogFun} = @qualityLogFun;
                
                iLogFun = iLogFun + 1;
            end
            
            if any(strcmp(obj.commonCfg.logSelector, 'all')) || ...
                    any(strcmp(obj.commonCfg.logSelector, 'parameters'))
                
                obj.results.population = ...
                    zeros(obj.stoppingCriteria.maxIter*obj.strategyCfg.nSwarm, ...
                    obj.problemCfg.nPar);
                
                obj.commonCfg.logFuncs{iLogFun} = @parameterLogFun;
                
                iLogFun = iLogFun + 1;
            end
            
            if any(strcmp(obj.commonCfg.logSelector, 'all')) || ...
                    any(strcmp(obj.commonCfg.logSelector, 'objective'))
                
                obj.results.objectives = ...
                    zeros(obj.stoppingCriteria.maxIter*obj.strategyCfg.nSwarm, ...
                    obj.problemCfg.nObj);
                
                obj.commonCfg.logFuncs{iLogFun} = @objectiveLogFun;
                
                iLogFun = iLogFun + 1;
            end
            
            if any(strcmp(obj.commonCfg.logSelector, 'all')) || ...
                    any(strcmp(obj.commonCfg.logSelector, 'qualityContribution'))
                
                obj.results.qualityContribution = ...
                    zeros(obj.stoppingCriteria.maxIter*obj.strategyCfg.nSwarm, ...
                    obj.problemCfg.nObj);
                obj.commonCfg.logFuncs{iLogFun} = @qualityContributionLogFun;
                
                iLogFun = iLogFun + 1;
            end
            
            if any(strcmp(obj.commonCfg.logSelector, 'all')) || ...
                    any(strcmp(obj.commonCfg.logSelector, 'restValue'))
                
                obj.results.restValues = ...
                    zeros(obj.stoppingCriteria.maxIter*obj.strategyCfg.nSwarm, ...
                    obj.problemCfg.nRestVals);
                
                obj.commonCfg.logFuncs{iLogFun} = @restValueLogFun;
                
                iLogFun = iLogFun + 1;
            end
            
            obj.commonCfg.nLogFun = iLogFun - 1;
            
        end
        
        function qualityLogFun(obj, currIter)
            obj.results.quality(currIter.logStartingIndex:currIter.logEndIndex, :) = currIter.quality;
        end
        
        function parameterLogFun(obj, currIter)
            obj.results.population(currIter.logStartingIndex:currIter.logEndIndex, :) = currIter.population;
        end
        
        function objectiveLogFun(obj, currIter)
            obj.results.objectives(currIter.logStartingIndex:currIter.logEndIndex, :) = currIter.objectives;
        end
        
        function qualityContributionLogFun(obj, currIter)
            obj.results.qualityContribution(currIter.logStartingIndex:currIter.logEndIndex, :) = ...
                currIter.qualityContribution;
        end
        
        function restValueLogFun(obj, currIter)
            obj.results.restValues(currIter.logStartingIndex:currIter.logEndIndex, :) = currIter.restValues;
        end
        
        function mainLoopProcessHandler(obj, currIter)
            % Strategy main loop processes handler, updating of populations
            % logging of current results, printing of intermediate results
            % and plotting handler.
            
            % Update best population :
            obj.updateBestPopulation(currIter);
            
            % Log levels may not be needed as whole state is kept at al
            % times for the restart from a checkpoint.
            obj.logCurrentResults(currIter);
            
            % Plotting stuff :
            obj.plotCfg.mainPlotHandler(obj, currIter);
            
            % Printing stuff :
            obj.mainPrintHandler(currIter);
            
            % Check stopping criterion :
            obj.stoppingCriterionCheck(currIter);
            
        end
        
        function mainPrintHandler(obj, currIter)
            
            % Run printing function :
            obj.commonCfg.printFunIter(obj, currIter)
            
        end
        
        function defaultPrintFuncIter(obj, currIter)
            
            disp([' >> Iteration : ' num2str(currIter.iIter)])
            disp(['    Best in iteration : ' num2str(obj.results.localBestQuality(currIter.iIter))])
            disp(['    Best overall      : ' num2str(obj.results.globalBestQuality(currIter.iIter))])
            fprintf('\n')
            
        end
        
        function defaultPrintFuncRun(obj, ~)
            
            disp([obj.nline ' >> Run : ' num2str(obj.commonCfg.iRun)])
            disp(['    Best in run : ' num2str(obj.finalResults.quality)])
            disp(['    Function calls : ' num2str(obj.finalResults.nFuncCalls)])
            fprintf('\n')
            
        end
        
        function dummyPrintFunc(~, ~)
            return;
        end
        
        function startPlaybackLoop(obj)
            
            nSwarm = obj.strategyCfg.nSwarm;
            nIter = length(obj.results.quality)/nSwarm;
            
            for iIter = 1:nIter
                iStart = ((iIter-1)*nSwarm + 1);
                iEnd = (iIter*nSwarm);
                currIter = struct('quality', obj.results.quality(iStart:iEnd), ...
                    'qualityContribution', obj.results.qualityContribution(iStart:iEnd,:), ...
                    'population', obj.results.population(iStart:iEnd,:), ...
                    'objectives', obj.results.objectives(iStart:iEnd,:), ...
                    'iIter', iIter);
                
                obj.plotHandlerStandalone(currIter);
                
            end
            
            
        end
        
        function plotHandlerDashboard(obj, currIter)
            
            % Update dashboard plots :
            gfx.dbPlotGlobalBest(obj, currIter, obj.dashbApp.UIAxes_1)
            %             obj.dashbApp.updatePlot1(currIter, obj.dashbApp.UIAxes_1)
            
        end
        
        function plotHandlerStandalone(obj, currIter)
            
            % Run external plotting function :
            if mod(currIter.iIter, obj.plotCfg.everyNth) == 0 || ...
                    currIter.iIter == 1
                for iPlotFun = 1:obj.plotCfg.nPlotFuncs
                    
                    plotFun = obj.plotCfg.extPlotFuncs{iPlotFun};
                    plotFun(obj, currIter, iPlotFun);
                    obj.printFigures(obj.plotCfg.saveFigsIter, currIter.iIter);
                    
                end
            end
        end
        
        function dummyPlotFunc(~, ~, ~)
            return;
        end
        
        function logCurrentResults(obj, currIter)
            
            for iLogFun = 1:obj.commonCfg.nLogFun
                logFun = obj.commonCfg.logFuncs{iLogFun};
                logFun(obj, currIter);
            end
            
            [minVal, indMin] = min(currIter.quality);
            obj.results.localBestQuality(currIter.iIter) = minVal;
            obj.results.globalBestQuality(currIter.iIter) = min(obj.results.localBestQuality(1:currIter.iIter));
            obj.results.localBestPopulation(currIter.iIter, :) = currIter.population(indMin, :);
            obj.results.clusterRad{currIter.iIter} = currIter.ClusterRad;
            
            obj.results.bestQuality = min(currIter.quality);
            
        end
        
        function updateBestPopulation(obj, currIter)
            
            obj.improvedPop.Quality(currIter.bIndImprov) = currIter.quality(currIter.bIndImprov);
            
            if currIter.iIter == 1
                obj.improvedPop.Objectives = currIter.objectives;
                obj.improvedPop.QualityContribution = currIter.qualityContribution;
                obj.improvedPop.RestValues = currIter.restValues;
                obj.improvedPop.Feasibility = currIter.feasibility;
                obj.improvedPop.Population = currIter.population;
            else
                obj.improvedPop.Objectives(currIter.bIndImprov,:) = ...
                    currIter.objectives(currIter.bIndImprov,:);
                obj.improvedPop.QualityContribution(currIter.bIndImprov,:) = ...
                    currIter.qualityContribution(currIter.bIndImprov,:);
                obj.improvedPop.RestValues(currIter.bIndImprov,:) = ...
                    currIter.restValues(currIter.bIndImprov,:);
                obj.improvedPop.Feasibility(currIter.bIndImprov,:) = ...
                    currIter.feasibility(currIter.bIndImprov,:);
                obj.improvedPop.Population(currIter.bIndImprov,:) = ...
                    currIter.population(currIter.bIndImprov,:);
            end
        end
        
        function finalizeResults(obj, currIter)
            
            [minqual,minind] = min(obj.improvedPop.Quality);
            
            obj.finalResults.quality = minqual;
            obj.finalResults.parameter = obj.improvedPop.Population(minind,:);
            obj.finalResults.objectives = obj.improvedPop.Objectives(minind,:);
            obj.finalResults.qualityContribution = obj.improvedPop.QualityContribution(minind,:);
            obj.finalResults.restValues = obj.improvedPop.RestValues(minind,:);
            obj.finalResults.feasibility = obj.improvedPop.Feasibility(minind,:);
            obj.finalResults.nFuncCalls = currIter.nFuncCalls;
            obj.finalResults.runTime = obj.endTime;
            
            obj.finalResults.population = currIter.population;
            
            if any(strcmp(obj.commonCfg.logSelector, 'all')) || ...
                    any(strcmp(obj.commonCfg.logSelector, 'quality'))
                
                obj.results.quality = obj.results.quality(1:currIter.logEndIndex, :);
                
            end
            
            if any(strcmp(obj.commonCfg.logSelector, 'all')) || ...
                    any(strcmp(obj.commonCfg.logSelector, 'parameter'))
                
                obj.results.population = obj.results.population(1:currIter.logEndIndex, :);
                
            end
            
            if any(strcmp(obj.commonCfg.logSelector, 'all')) || ...
                    any(strcmp(obj.commonCfg.logSelector, 'objective'))
                
                obj.results.objectives = obj.results.objectives(1:currIter.logEndIndex, :);
                
            end
            
            if any(strcmp(obj.commonCfg.logSelector, 'all')) || ...
                    any(strcmp(obj.commonCfg.logSelector, 'qualityContribution'))
                
                obj.results.qualityContribution = obj.results.qualityContribution(1:currIter.logEndIndex, :);
                
            end
            
            if any(strcmp(obj.commonCfg.logSelector, 'all')) || ...
                    any(strcmp(obj.commonCfg.logSelector, 'restValue'))
                
                obj.results.restValues = obj.results.restValues(1:currIter.logEndIndex, :);
                
            end
            
            obj.dashbApp = [];
            
        end
        
        function stoppingCriterionCheck(obj, currIter)
            
            conditions = [
                currIter.iIter >= obj.stoppingCriteria.maxIter;
                
                abs(obj.results.bestQuality-obj.stoppingCriteria.minQual.val) <= ...
                obj.stoppingCriteria.minQual.eps;
                
                all(std(currIter.population) <= obj.stoppingCriteria.maxPopulationEps);
                
                obj.stoppingCriteria.maxTime < toc(obj.startTime);
                
                currIter.nFuncCalls > obj.stoppingCriteria.maxFuncCalls;
                
                obj.stoppingCriteria.userStop
                ];
            
            if any(conditions)
                obj.shallNotPass = true;
                obj.stopReason = obj.stoppingCriteria.reasons(conditions);
                
                obj.finalizeResults(currIter);
                obj.dumpDataPacket();
            end
            
        end
        
        function obj = userStopActivated(obj)
            obj.stoppingCriteria.userStop = true;
        end
        
        function start(obj)
            % Start time :
            obj.startTime = tic;
            
            for iRun = 1:obj.commonCfg.nRuns
                
                obj.reInitOptimizer();
                
                obj.iterationStartTime = tic;
                
                obj.shallNotPass = false;
                obj.commonCfg.iRun = iRun;
                
                % Start optimization :
                obj = obj.strategyCfg.optimizer(obj);
                
                obj.endTime = toc(obj.iterationStartTime);
                
                if obj.commonCfg.enablePrintRun
                    disp([' >> Optimization run ', ...
                        num2str(iRun), ' took : ', ...
                        num2str(obj.endTime), ' s'])
                end
                
                obj.commonCfg.printFunRun(obj, []);
                obj.saveRunData(iRun);
                obj.printFigures(obj.plotCfg.saveFigsRun, iRun);
                
            end
            
            obj.runData = [obj.runData{:}];
            
            obj.endTime = toc(obj.startTime);
            
            if obj.commonCfg.enablePrintRun
                disp([' >> Total optimization took : ', ...
                    num2str(obj.endTime), ' s'])
            end
            
        end
        
        function saveRunData(obj, iRun)
            obj.runData{iRun} = obj.finalResults;
        end
        
        function dumpDataPacket(obj)
            % Dumps the IGTEOptimizer object to save current state before
            % ending the current iteration.
            if obj.commonCfg.enableDataDump
                obj.generateDumpFileName();
                save(obj.dumpFileName, 'obj')
            end
        end
        
        function X = scalePopulation(obj, X)
            X = X.*(obj.problemCfg.parMaxTrue - obj.problemCfg.parMinTrue) + obj.problemCfg.parMinTrue;
        end
        
        function currIter = costFunction(obj, currIter, population)
            
            % Scale the population to range if working with normalized
            % range is turned on.
            populationScaled = obj.scalePopulation(population);
            
            % Run the forward solver and update currIter state :
            
            [currIter.objectives, ...
                currIter.feasibility, ...
                currIter.restValues] = obj.problemCfg.forwardSolver(populationScaled);
            
            % Quality calculation and Scalarization :
            currIter = obj.qualitycalculation( currIter );
            
            % Get improoved individuals :
            currIter.bIndImprov = currIter.quality < obj.improvedPop.Quality;
            
            % Update current population :
            currIter.population(currIter.bIndImprov,:) = population(currIter.bIndImprov,:);
            
            % Update number of function calls :
            currIter.nFuncCalls = currIter.nFuncCalls + obj.strategyCfg.nSwarm;
            
        end
        
        function printFigures(obj, shallPlot, iIter)
            
            if shallPlot
                for iFig = 1:obj.plotCfg.nPlotFuncs
                    fig = figure(iFig);
                    print(fig, [obj.plotCfg.plotPths{iFig}, '_i', num2str(iIter)], ...
                        ['-d' obj.plotCfg.figFormat], ...
                        ['-r' num2str(obj.plotCfg.figResolution)])
                end
            end
            
        end
        
        function currIter = qualitycalculation( obj, currIter )
            
            nSwarm = size(currIter.objectives, 1);
            nObj = obj.problemCfg.nObj;
            
            qualityContribution = realmax*ones(nSwarm, nObj);
            minval = realmax*ones(1, nObj);
            
            for iObj = 1:nObj
                
                x = currIter.objectives(:,obj.problemCfg.membershipFunctions{iObj}.objectivepar(1));
                memFun = obj.membershipFuncs{iObj};
                
                qualityContribution(:, iObj) = memFun(x);
                minval(iObj)=0;
                
            end
            
            currIter.qualityContribution = qualityContribution;
            
            % Perform scalarization of the objective values. The max value
            % in case of summation is the number of objectives and in all
            % other cases the maximal value is 1. The resulting quality is
            % then subtracted from the respective max value.
            
            currIter.quality = obj.scalarizationFunc(qualityContribution);
            
            
        end
        
    end
    
end