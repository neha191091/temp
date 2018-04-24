function result = min_max(data)
if isreal(data)
	result = [min(data(:)), max(data(:))]; % values might be negative!
else
	result = [min(abs(data(:))), max(abs(data(:)))]; % magnitude
end
