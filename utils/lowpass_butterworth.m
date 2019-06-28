function H = lowpass_butterworth(X, w0, order, shape)
    % Return filter shape in frequency domain
    [dimy, dimx, dimz] = size(X);
    u=0:(dimx-1);
    v=0:(dimy-1);
    idx=find(u>dimx/2);
    u(idx)=u(idx)-dimx;
    idy=find(v>dimy/2);
    v(idy)=v(idy)-dimy;
    [V,U]=meshgrid(v,u);
    %D = sqrt(U.^2+V.^2);
    %D = max(abs(U), abs(V));
    n = order; %5; % order of butterworth filter
    for i=1:dimy
        for j=1:dimx
            if shape=='circle'
                uvw = sqrt((U(i,j)^2 + V(i,j)^2))./(w0.^2);
            else if shape=='square'
                uvw = max(abs(U(i,j)), abs(V(i,j)))./(w0.^2);
                end
            end
            H(i,j) = 1./(1+uvw.^n);
        end
    end
end