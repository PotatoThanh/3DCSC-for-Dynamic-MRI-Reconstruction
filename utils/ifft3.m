function y = ifft3(x)
	y = x;
	% y = ifft(y, [], 3);
	% y = ifft(y, [], 2);
	% y = ifft2(y);
	% y = ifft(y, [], 1);
	[~,~,~,dimk] = size(x);
	for k=1:dimk
		y(:,:,:,k) = ifftn(x(:,:,:,k));
	end
	%y = abs(y);
return 