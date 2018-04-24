function h = spl(i, num)
% Easy subplots. (e.g. easily used within loops.) Examples:
%    spl 16, for i=1:16, spl, imagesc(magic(i)), end % 4x4 array
%    spl([2 8]), for i=1:16, spl, imagesc(magic(i)), end % 2x8 array
%    spl(16), for i=1:16, spl, imagesc(magic(i)), end % 4x4 array
%    for i=1:16, spl(i,16), imagesc(magic(i)), end % 4x4 array

% get values
spl_subplot_current = getappdata(gcf,'spl_subplot_current');
spl_subplot_max = getappdata(gcf,'spl_subplot_max');

% first call to spl
if nargin==1
if ~isnan(str2double(i)) % string to num for "spl 16"
i = str2double(i);
end
if isnumeric(i)
spl_subplot_current = 0;
spl_subplot_max = i;
setappdata(gcf,'spl_subplot_current',spl_subplot_current);
setappdata(gcf,'spl_subplot_max',spl_subplot_max);
return
end
end

% non-first call to spl
if nargin==0 || strcmp(i,'next')
if isempty(spl_subplot_max)
warning('Skipping spl because number N of desired subplots unknown. Call spl N first.');
return
end
if isempty(spl_subplot_current)
spl_subplot_current = 1;
else
spl_subplot_current = spl_subplot_current+1;
end
if spl_subplot_current<=prod(spl_subplot_max)
spl(spl_subplot_current,spl_subplot_max);
else
warning('Skipping spl because current subplot would exceed the total nubmer N of subplots.');
end
return
end

% do the work
if numel(i)>numel(num) || (numel(i)==numel(num) && i>num) % first and second argument interchangeable
tmp=i;
i=num;
num=tmp;
end
hd = subplot(splm(num),spln(num),i+(i==0));
% hd = subaxis(splm(num),spln(num),i+(i==0), 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
if nargout>0
h = hd;
end

spl_subplot_current = i;
spl_subplot_max = num;

% set values
setappdata(gcf,'spl_subplot_current',spl_subplot_current);
setappdata(gcf,'spl_subplot_max',spl_subplot_max);

function splm = splm(num)
if numel(num)==1
splm = round(sqrt(num));
else
splm = num(1);
end

function spln = spln(num)
if numel(num)==1
spln = ceil(num/splm(num));
else
spln = num(2);
end

