function v = psnr(I, K)
    mse = mean((abs(I(:)) - abs(K(:))).^2);
    if mse==0
        v = 999;
    else
        v = 10 * log10(1 ./ mse);
    end
end

