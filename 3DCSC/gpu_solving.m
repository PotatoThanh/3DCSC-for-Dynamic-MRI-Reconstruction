function [result] = gpu_solving(D0, S0, M0, R0, opt)
%  Thanh Nguyen-Duc
%  Ulsan National Institute of Science and Technology
%  thanhnguyen.cse@gmail.com
%
%  Septembet 2018

%% Parameters extractions
    elemSize = opt.elemSize;
    dataSize = opt.dataSize;
    blobSize = opt.blobSize;
    numAtoms = blobSize(end);
    
    dataDict  = opt.dataDict;
    numDicts  = dataDict(end);
    atomSize1 = opt.atomSize1;
    dictSize1 = opt.dictSize1;    
    atomSize2 = opt.atomSize2;
    dictSize2 = opt.dictSize2;
    atomSize3 = opt.atomSize3;
    dictSize3 = opt.dictSize3;
    
    N         = numAtoms;
   
    % Put params to GPU
    gNx = gpuArray(prod(blobSize));
    gNd = gpuArray(prod(blobSize));
    galpha  = gpuArray(opt.alpha.Value);
    ggamma  = gpuArray(opt.gamma.Value);
    glambda1 = gpuArray(opt.lambda1.Value);
    glambda2 = gpuArray(opt.lambda2.Value);
    grho    = gpuArray(opt.rho.Value);
    gsigma  = gpuArray(opt.sigma.Value);
    gtheta  = gpuArray(opt.theta.Value);

    %% Operators here
    %% Mean removal and normalisation projections
    Pzmn    = @(x) bsxfun(@minus,   x, mean(mean(mean(x,1),2),3));
    Pnrm    = @(x) bsxfun(@rdivide, x, sqrt(sum(sum(sum(x.^2,1),2),3)));

    %% Projection of filter to full image size and its transpose
    % (zero-pad and crop respectively)
    Pzp     = @(x) zeropad(x, blobSize); %entire data    
    Pzp1     = @(x) zeropad(x, dataDict);
    Pzp2     = @(x) zeropad(x, dataDict);
    Pzp3     = @(x) zeropad(x, dataDict);
    
    PzpT    = @(x) bndcrop(x, blobSize); %entire data    
    PzpT1    = @(x) bndcrop(x, dictSize1);
    PzpT2    = @(x) bndcrop(x, dictSize2);
    PzpT3    = @(x) bndcrop(x, dictSize3);

    %% Projection of dictionary filters onto constraint set
    Pcn     = @(x) Pnrm(Pzp(PzpT(x)));
    Pcn1     = @(x) Pnrm(Pzp1(PzpT1(x)));
    Pcn2     = @(x) Pnrm(Pzp2(PzpT2(x)));
    Pcn3     = @(x) Pnrm(Pzp3(PzpT3(x)));
    
    %% Memory reservation
    gtvtD  = gpuArray(opt.D);
    gtvtDt = gpuArray(opt.Dt);
            
    gD0     = cat(4,Pzp1(Pnrm(D0.D1)), Pzp2(Pnrm(D0.D2)), Pzp3(Pnrm(D0.D3)));

	gR      = gpuArray(R0);
	gMf     = gpuArray(M0);
    gM      = gpuArray(ifft2(gMf));
	
    grx = gpuArray(Inf);
    gsx = gpuArray(Inf);
    grd = gpuArray(Inf);
    gsd = gpuArray(Inf);
    geprix = gpuArray(0);
    geduax = gpuArray(0);
    geprid = gpuArray(0);
    geduad = gpuArray(0);

    gX      = gpuArray(zeros(blobSize));
    gY      = gpuArray(zeros(blobSize));
    gYprv   = gpuArray(gY);
    gXf     = gpuArray(zeros(blobSize));
    gYf     = gpuArray(zeros(blobSize));

    gS      = gpuArray(ifft2(gMf));
    gSf     = gpuArray(zeros(dataSize));

    gD      = gpuArray(zeros(blobSize));
    gG      = gpuArray(zeros(blobSize));
    gGprv   = gpuArray(zeros(blobSize));

    gD      = gpuArray(gD0); clear gD0;
    gG      = gpuArray(gD); % Zero pad the dictionary
    
    gGprv   = gpuArray(gG);
    gDf     = gpuArray(zeros(blobSize));
    gGf     = gpuArray(zeros(blobSize));

    gU      = gpuArray(zeros(blobSize));
    gH      = gpuArray(zeros(blobSize));

    gGf     = gpuArray(zeros(blobSize));
    gGf     = gpuArray(fft3(gG));
    
    % Temporary buffers
    gGSf    = gpuArray(zeros(blobSize));
    gYSf    = gpuArray(zeros(blobSize));
    
    gSh = gpuArray.zeros(size(gS));
    gSl = gpuArray.zeros(size(gS));
    gShf = gpuArray.zeros(size(gS));
    gSlf = gpuArray.zeros(size(gS));
    gMhf = gpuArray.zeros(size(gS));

   
    %% Set up PSNR array
    PSNR = [];
    gS0     = gpuArray(S0);
    
    p = psnr(gS,gS0); % init psnr
    fprintf('Initial psnr: %f\n',p);
    PSNR = [PSNR, p];
    
    %% Main loops    
    k = 1;
    tstart = tic;
    while k <= opt.maxIter && (grx > geprix | gsx > geduax | ...
                               grd > geprid | gsd > geduad),
                          
        %% Permutation here
        gS = gS;
        
        %% Low pass filter
        filter = lowpass_butterworth(gS, opt.w0, opt.n, 'square');
        gSf =  fft2(gS);
        for i=1:opt.dataSize(3)
            gSlf(:,:,i) = gSf(:,:,i).*filter;
            gShf(:,:,i) = gSf(:,:,i).*(1-filter);
            gMhf(:,:,i) = gMf(:,:,i).*(1-filter);
             
        end
        
        % low and high frequency
        gSl  = ifft2(gSlf);
        gSh  = ifft2(gShf);
        
        %% Compute the signal in DFT domain
        gSf  = fft3(gSh); 
        gGSf = bsxfun(@times, conj(gGf), gSf); 

        %% Solve X subproblem
        gXf  = solvedbi_sm(gGf, ...
                           grho/galpha, ...
                           gGSf + grho/galpha*fft3(gY-gU));  
        gX   = ifft3(gXf); 
        gXr  = gX; %relaxation

        %% Solve Y subproblem
        gY   = shrink( grho*(gXr + gU)./(glambda2 + grho), glambda1/(glambda2 + grho));
        gYf  = fft3(gY);
        gYSf = sum(bsxfun(@times, conj(gYf), gSf), 5);

        %% Solve U subproblem
        gU = gU + gXr - gY;
        
        %% Update params 
        gnX = norm(gX(:)); gnY = norm(gY(:)); gnU = norm(gU(:));
        grx = norm(vec(gX - gY))/max(gnX,gnY);
        gsx = norm(vec(gYprv - gY))/gnU;
        geprix = sqrt(gNx)*opt.AbsStopTol/max(gnX,gnY)+opt.RelStopTol;
        geduax = sqrt(gNx)*opt.AbsStopTol/(grho*gnU)+opt.RelStopTol;

        if opt.rho.Auto,
            if k ~= 1 && mod(k, opt.rho.AutoPeriod) == 0,
                if opt.rho.AutoScaling,
                    grhomlt = sqrt(grx/gsx);
                    if grhomlt < 1, grhomlt = 1/grhomlt; end
                    if grhomlt > opt.rho.Scaling, grhomlt = opt.rho.Scaling; end
                else
                    grhomlt = opt.rho.Scaling;
                end
                grsf = 1;
                if grx > opt.rho.RsdlRatio*gsx, grsf = grhomlt; end
                if gsx > opt.rho.RsdlRatio*grx, grsf = 1/grhomlt; end
                grho = grsf*grho;
                gU = gU./grsf;
            end
        end
        
        %% Record information
        gYprv = gY;
        
        %% Solve D subproblem
        gDf  = solvedbi_sm(gYf, ...
                           gsigma/galpha, ... 
                           gYSf + gsigma/galpha*fft3(gG - gH));
        gD   = ifft3(gDf);
        gDr  = gD;

        %% Solve G subproblem
        P1               = Pcn1(gDr(:,:,:,1:numDicts)                + gH(:,:,:,1:numDicts));
        P2               = Pcn2(gDr(:,:,:,numDicts+1:2*numDicts)     + gH(:,:,:,numDicts+1:2*numDicts));
        P3               = Pcn3(gDr(:,:,:,2*numDicts +1:size(gDr,4)) + gH(:,:,:,2*numDicts +1:size(gH,4)));
        gG               = cat(4, P1, P2, P3);
        clear P1 P2 P3;
        
        gGf  = fft3(gG);
        gGSf = bsxfun(@times, conj(gGf), gSf);

        %% Solve H subproblem
        gH = gH + gDr - gG;

        %% Update params    
        gnD = norm(gD(:)); gnG = norm(gG(:)); gnH = norm(gH(:));
        grd = norm(vec(gD - gG))/max(gnD,gnG);
        gsd = norm(vec(gGprv - gG))/gnH;
        geprid = sqrt(gNd)*opt.AbsStopTol/max(gnD,gnG)+opt.RelStopTol;
        geduad = sqrt(gNd)*opt.AbsStopTol/(gsigma*gnH)+opt.RelStopTol;
        
        if opt.sigma.Auto,
            if k ~= 1 && mod(k, opt.sigma.AutoPeriod) == 0,
                if opt.sigma.AutoScaling,
                    gsigmlt = sqrt(grd/gsd);
                    if gsigmlt < 1, gsigmlt = 1/gsigmlt; end
                    if gsigmlt > opt.sigma.Scaling, gsigmlt = opt.sigma.Scaling; end
                else
                    gsigmlt = opt.sigma.Scaling;
                end
                gssf = 1;
                if grd > opt.sigma.RsdlRatio*gsd, gssf = gsigmlt; end
                if gsd > opt.sigma.RsdlRatio*grd, gssf = 1/gsigmlt; end
                gsigma = gssf*gsigma;
                gH = gH./gssf;
            end
        end
        %% Record information
        gGprv = gG;
        
		%% Solve for S low
        try
        tg_seq = gSl;
        tg_seq_vector = DenoiseTG(tg_seq(:).', gtheta, 40, gtvtD, gtvtDt);
        seq_tg_approx = reshape(tg_seq_vector, size(tg_seq));
        gSlf = fft2(seq_tg_approx);        
        catch
            warning('Dimensions is not match. Please generate TV matrices using GenD in TV_matrix folder');
        end
        
		%% Solve for S high
        gRMf =     bsxfun(@times, conj(gR), gMhf);
        gGYf = sum(bsxfun(@times,     (gGf), gYf), 4);
				
		gSf2 = solvedbi_sm(gR, ...
						   galpha/ggamma, ...
						   gRMf + galpha/ggamma*ifft(gGYf, [], 3));
		gSf2 = gSf2 + gSlf;				   
        gSf2(gR>0) = gMf(gR>0);
		
		gSprv = gS;
		
        gS = ifft2(gSf2);

        %% Calculate psnr        
        p = psnr(gS,gS0);
        PSNR = [PSNR, p];
        
        % show psnr
        if opt.isConsole
            fprintf('Iter: %i, psnr: %f\n',k,p);
        end
        
        % show figures
        if opt.isDisplay 
            
            % show images
            l = 10;
            figure(3);
            subplot(1,3,1);
            imshow(abs(gather(gM(:,:,l))),[0 1]);
            title('Undersample');
           
            subplot(1,3,2);
            imshow(abs(gather(gS0(:,:,l))),[0 1]);
            title('Fullsample');
            
            subplot(1,3,3);
            imshow(abs(gather(gS(:,:,l))),[0 1]);
            title('Reconstruction');
            drawnow();
            
            figure(4);
            plot(PSNR);
            xlabel('Iterations');
            ylabel('PSNR');
            title(num2str(p));
            drawnow;
           
        end
        
        %% Update iterations
        k = k+1;
        
    end %% End main loop

    %% Collect output
    result.runtime = toc(tstart);
    result.S = gather(gS);
    result.X = gather(gX);
    result.PSNR = gather(PSNR);    
return