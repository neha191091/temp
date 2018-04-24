function tag = showNd_currentimgtag(ax)

if nargin==0
	ax = gca;
end


csp = getappdata(ax, 'CurrentScrollPlot');
% always remove trailing ones to prevent errors due to "what used to be [2 2] now is [2 2 1 1] because we have more dimensions now"
last_nonsingleton_dim = find(csp~=1,1,'last');
if isempty(last_nonsingleton_dim)
	csp = 1;
else
	csp( find(csp~=1,1,'last')+1 : end ) = [];
end

tag = ['showNd_image_' mat2str(csp)];
