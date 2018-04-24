  
function cbscroll(hFig)
% Makes color limits of colorbar scrollable with the mouse wheel.
% Author: Vladimir Golkov
% Usage:
% cbscroll
%	SHIFT+Mousewheel		adjusts upper limit
%	CTRL+Mousewheel			adjusts lower limit
%	CTRL+SHIFT+Mousewheel	adjusts lower and upper limit (zooms in/out)
%	ALT+Mousewheel			shifts color window (both limits up or both down)
if nargin==0
	hFig = gcf;
end

setappdata(hFig, 'isAltKeyDown', false);
setappdata(hFig, 'isControlKeyDown', false);
setappdata(hFig, 'isShiftKeyDown', false);

addEventFcn(hFig,'KeyPressFcn',@ModifierKeyPressFcn)
addEventFcn(hFig,'KeyReleaseFcn',@ModifierKeyReleaseFcn)
addEventFcn(hFig,'WindowScrollWheelFcn',@cbScroll)


function cbScroll(hFig,evnt)
%get(hFig)
%getappdata(hFig)
factor = 0.9^abs(evnt.VerticalScrollCount);
if evnt.VerticalScrollCount>0
	factor = 1/factor;
end

if getappdata(hFig, 'isShiftKeyDown') && ~getappdata(hFig, 'isControlKeyDown')
	% scroll upper colorbar limit
	clim = linsc([0 factor],[0 1],inf_to_realmax(get(gca,'clim')));
	if ~any(isnan(clim))
		set(gca,'clim',inf_to_realmax(clim))
	end
end
if getappdata(hFig, 'isControlKeyDown') && ~getappdata(hFig, 'isShiftKeyDown')
	% scroll lower colorbar limit
	clim = linsc([1/factor 0],[1 0],inf_to_realmax(get(gca,'clim')));
	if ~any(isnan(clim))
		set(gca,'clim',inf_to_realmax(clim))
	end
end
if getappdata(hFig, 'isControlKeyDown') && getappdata(hFig, 'isShiftKeyDown')
	% scroll both colorbar limits
	clim = linsc([-factor factor],[-1 1],inf_to_realmax(get(gca,'clim')));
	if ~any(isnan(clim))
		set(gca,'clim',inf_to_realmax(clim))
	end
end
if getappdata(hFig, 'isAltKeyDown')
	% shift colorbar window
	clim = linsc([-1 1]+0.1*evnt.VerticalScrollCount,[-1 1],inf_to_realmax(get(gca,'clim')));
	if ~any(isnan(clim))
		set(gca,'clim',inf_to_realmax(clim))
	end
end


function ModifierKeyPressFcn(hFig, keyEvent)
switch (keyEvent.Key)
	case 'alt'
		setappdata(hFig, 'isAltKeyDown', true);
	case 'control'
		setappdata(hFig, 'isControlKeyDown', true);
	case 'shift'
		setappdata(hFig, 'isShiftKeyDown', true);
end

function ModifierKeyReleaseFcn(hFig, keyEvent)
setappdata(hFig, 'isAltKeyDown', false);
setappdata(hFig, 'isControlKeyDown', false);
setappdata(hFig, 'isShiftKeyDown', false);

function clim_current = inf_to_realmax(clim_current)
% replace Inf by realmax and -Inf by -realmax
clim_current(isinf(clim_current)) = realmax.*sign(clim_current(isinf(clim_current)));

