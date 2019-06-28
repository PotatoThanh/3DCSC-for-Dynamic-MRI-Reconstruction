function [ ga ] = main_GA(full, mask, undersample, Generation, Population, num_params, lb, ub, opt)
%  Thanh Nguyen-Duc
%  Ulsan National Institute of Science and Technology
%  thanhnguyen.cse@gmail.com
%
%  Septembet 2018

    global gl_full
    global gl_undersample
    global gl_mask
    global gl_opt
    global temp
    gl_full = full;
    gl_mask = mask;
    gl_undersample = undersample;
    gl_opt = opt;
    temp = Inf;
    
    [params, fval, exitflag, output, population, score] = GA_func(num_params, lb, ub, Generation, Population);
    
    ga.alpha   = params(1);
    ga.gamma   = params(2);
    ga.lambda1 = params(3);
    ga.lambda2 = params(4);
    ga.rho     = params(5);
    ga.sigma   = params(6);
    ga.theta   = params(7);
    ga.w0      = params(8);
    ga.n       = params(9);
end

