function y = scale_img(x)
    %% Scale to the 8bit display images
    y = x;
    y = y - min(y(:)) ;
    y = y / max(y(:)) ;
end