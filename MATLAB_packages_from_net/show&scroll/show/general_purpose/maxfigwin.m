function maxfigwin(hFig)
% maximize figure window

if nargin==0
	hFig=gcf;
end

if ~strcmpi(get(hFig,'WindowStyle'),'docked')
	jFrame = get(handle(hFig),'JavaFrame');
	drawnow
	jFrame.setMaximized(true) % may throw uncatchable java exception
end
