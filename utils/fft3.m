function y = fft3(x)
	y = x;
	% y = fft(y, [], 1);
	% y = fft(y, [], 2);
	% y = fft2(y)
	% y = fft(y, [], 3);
	[~,~,~,dimk] = size(x);
	for k=1:dimk
		y(:,:,:,k) = fftn(x(:,:,:,k));
	end
return 