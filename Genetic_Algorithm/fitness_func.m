function fitness_val = fitness_func(params)
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

    ga.alpha   = params(1);
    ga.gamma   = params(2);
    ga.lambda1 = params(3);
    ga.lambda2 = params(4);
    ga.rho     = params(5);
    ga.sigma   = params(6);
    ga.theta   = params(7);
    ga.w0      = params(8); % w0 is equal to D0 in paper
    ga.n       = params(9); % n is equal to n in paper

    % Recontruct process
    result = split_3DCSC_TV(gl_full, gl_mask, gl_undersample, ga, gl_opt);

    fitness_val = -1*(result.PSNR(end));% + 20*mean(result.X(:));

    fprintf('Fitness value:%f\n',fitness_val);

    if gl_opt.saveIntermediate
        if fitness_val < temp
            temp = fitness_val;
            save(strcat('./temp_params/fitness_',num2str(fitness_val),'.mat'), 'ga');
            fprintf('Saving temp parameters(%f)\n',fitness_val);
        end
    end

end

