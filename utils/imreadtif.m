function mat = imreadtif(filename)
	info = imfinfo(filename);
	mat = [];
	for k=1:numel(info);
		img = uint8(imread(filename, k));
		mat(:,:,k) = img;
	end
end