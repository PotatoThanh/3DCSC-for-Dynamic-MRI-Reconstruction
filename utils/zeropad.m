function u = zeropad(v, sz)
    u = zeros(sz, class(v));
    u(1:size(v,1), 1:size(v,2), 1:size(v,3), 1:size(v,4)) = v(1:size(v,1), 1:size(v,2), 1:size(v,3), 1:size(v,4));
return
