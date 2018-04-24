function clickhide(handle)
try
	addEventFcn(handle,'ButtonDownFcn',@(src,evnt)set(src,'Visible','off')) % or @(src,evnt)set(handle,'Visible','off')
catch e
	warning(e.getReport)
	set(handle,'ButtonDownFcn',@(src,evnt)set(src,'Visible','off')) % or @(src,evnt)set(handle,'Visible','off')
end
