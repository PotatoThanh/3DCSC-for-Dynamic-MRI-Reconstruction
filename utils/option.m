function opt = option()
    %% Parameters initialization
    opt.alpha  = params;
    opt.gamma  = params;
    opt.delta  = params;
    opt.theta  = params;
    opt.omega  = params;
    
    opt.lambda = params;
    opt.sigma  = params;
    opt.rho    = params;
    
    
    %% Solver initialization
    opt.Verbose = 1;
    opt.MaxIter = 500;
    opt.AbsStopTol = 1e-6;
    opt.RelStopTol = 1e-6;
end