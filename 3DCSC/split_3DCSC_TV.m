function result = split_3DCSC_TV(full, mask, undersample, ga, options)
%  Thanh Nguyen-Duc
%  Ulsan National Institute of Science and Technology
%  thanhnguyen.cse@gmail.com
%
%  Septembet 2018

    %% Assign variables
    S0 = single(full);
    M0 = undersample;    
    mask = fftshift(mask, 1);
    mask = fftshift(mask, 2);
    R0 = mask;
    
    %% TV matrices
    opt.D = options.D;
    opt.Dt = options.Dt;
    
    %% general options
    opt.maxIter = options.num_iters;
    opt.isDisplay = options.isDisplay; % show figure
    opt.isConsole = options.isConsole; % Show PNSR 

    % CSC options
    numAtoms = options.numAtoms;
    opt.elemSize = [options.dataSizeX, options.dataSizeY, options.dataSizeZ, 1];
    opt.dataSize = [options.dataSizeX, options.dataSizeY, options.dataSizeZ, 1]; 
    opt.blobSize = [options.dataSizeX, options.dataSizeY, options.dataSizeZ, numAtoms];
    
    opt.numAtoms = options.numAtoms;

    % Dictionaries options
    numDicts      = options.numAtoms/options.numTypes;
    opt.dataDict  = [ options.dataSizeX, options.dataSizeY, options.dataSizeZ, numDicts];

    opt.atomSize1 = [ options.atomSize1X,  options.atomSize1Y, options.atomSize1Z,  1];
    opt.dictSize1 = [ options.atomSize1X,  options.atomSize1Y, options.atomSize1Z,  numDicts];
    opt.atomSize2 = [ options.atomSize2X,  options.atomSize2Y, options.atomSize2Z,  1];
    opt.dictSize2 = [ options.atomSize2X,  options.atomSize2Y, options.atomSize2Z, numDicts];
    opt.atomSize3 = [ options.atomSize3X,  options.atomSize3Y, options.atomSize3Z, 1];
    opt.dictSize3 = [ options.atomSize3X,  options.atomSize3Y, options.atomSize3Z, numDicts];   

    % Construct initial dictionary
    D0.D1 = rand(opt.dictSize1, 'single') + 1i*rand(opt.dictSize1, 'single');
    D0.D2 = rand(opt.dictSize2, 'single') + 1i*rand(opt.dictSize2, 'single');
    D0.D3 = rand(opt.dictSize3, 'single') + 1i*rand(opt.dictSize3, 'single');

    %% Initialize params
    % See param.m
    opt.alpha  = params; 
    opt.gamma  = params;
    opt.lambda1 = params; 
    opt.lambda2 = params; 
    opt.sigma   = params; 
    opt.rho     = params;
    
    opt.sigma.AutoScaling    = 1;
    opt.rho.AutoScaling      = 1;

    % Solver initialization    
    opt.AbsStopTol = 1e-6;
    opt.RelStopTol = 1e-6;

    % Ga params
    opt.alpha.Value          = ga.alpha;
    opt.gamma.Value          = ga.gamma;
    opt.lambda1.Value        = ga.lambda1;
    opt.lambda2.Value        = ga.lambda2;
    opt.rho.Value            = ga.rho;
    opt.sigma.Value          = ga.sigma;
    opt.theta.Value          = ga.theta;

    % filter
    opt.w0                   = ga.w0; % w0 is equal to D0 in paper
    opt.n                    = ga.n; % n is equal to n in paper

    %% Solving subproblems
    [result] = gpu_solving(D0, S0, M0, R0, opt);

end