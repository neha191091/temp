function showNdMouseMotion(hFig,evnt,hText,hRect,dims,dist,complexmode,tilemode_or_ncols,mmfun,data)

axlist = findobj(hFig,'Type','axes');
dcm=datacursormode(gcf); % are we in Data Cursor mode?
for ax = axlist'
	dims = getappdata(ax,'showNd_slicedims');
	if isempty(dims)
		continue % probably colorbar axes
	end
	
	cp = get(ax,'CurrentPoint');
	switch tilemode_or_ncols
		case '4d'
			coords = show4d_to_coords(cp(1,1),cp(1,2),dims,dist);
			str = sprintf('Mouse coordinates:\n%i{\\fontsize{6} / %i}\n%i{\\fontsize{6} / %i}\n%i{\\fontsize{6} / %i}\n%i{\\fontsize{6} / %i}',coords(1),dims(1),coords(2),dims(2),coords(3),dims(3),coords(4),dims(4));
		case '2d'
			coords = show2d_to_coords(cp(1,1),cp(1,2),dims);
			str = sprintf('Mouse coordinates:\n%i{\\fontsize{6} / %i}\n%i{\\fontsize{6} / %i}',coords(1),dims(1),coords(2),dims(2));
		otherwise
			if isnumeric(tilemode_or_ncols)
				coords = show3d_to_coords(cp(1,1),cp(1,2),dims,dist,tilemode_or_ncols);
			else
				coords = show3d_to_coords(cp(1,1),cp(1,2),dims,dist);
			end
			str = sprintf('Mouse coordinates:\n%i{\\fontsize{6} / %i}\n%i{\\fontsize{6} / %i}\n%i{\\fontsize{6} / %i}',coords(1),dims(1),coords(2),dims(2),coords(3),dims(3));
	end
	
% 	% if loaded figure from file, find the rectangle handle and text handle
% 	% TODO problem with saved *.fig: tags don't match objects, reason unknown, workaround: type checking
% 	if gca~=ax || ~ishandle(hRect) || ~strcmp(get(hRect,'Type'),'rectangle'), hRect = findobj(ax,'Tag','showNd_rectangle'); end
% 	if gca~=ax || ~ishandle(hText) || ~strcmp(get(hRect,'Type'),'text'), hText = findobj(ax,'Tag','showNd_text_right'); end
	
	hRect = findobj(ax,'Tag','showNd_rectangle');
	hText = findobj(ax,'Tag','showNd_text_right');
	
	if any(isnan(coords))
		str = '';
	else
		% show data value
		if exist('data','var')
			% data passed as argument
			csp = getappdata(ax, 'CurrentScrollPlot');
			fullcoordvec_cell = num2cell([coords csp]);
			value = data(fullcoordvec_cell{:});
			str = sprintf('%s\n\nValue:\n%s', str, num2str(value));
			if ~isreal(value)
				str = sprintf('%s\nm=%s\n\\phi=%s', str, num2str(abs(value)), num2str(angle(value)));
			end
		else
			% CData of image
			hImg = findobj(hFig, 'Parent', ax, 'Tag', showNd_currentimgtag(ax));
			if numel(hImg)==1
				slice = get(hImg,'CData');
				value = slice(round(cp(1,2)),round(cp(1,1)),:);
				str = sprintf('%s\n\nValue:\n%s', str, num2str(value));
				if size(value,3)==3
					if ~isempty(complexmode)
						switch complexmode
							case 1
								hsl = rgb2hsl(double(value));
								str = sprintf('%s\nm=%s%%\n\\phi=%s°', str, num2str(hsl(3)*100), num2str((hsl(1)*2-1) * 180));
						end
						% TODO complex modes
					end
				end
			else
				% TODO subplots
			end
		end
		
		if isa(mmfun,'function_handle')
			csp = getappdata(ax, 'CurrentScrollPlot');
			fullcoordvec = [coords csp];
			mmfun(fullcoordvec)
		end
	end
	
	if numel(axlist)>1 && sum(~strcmp(get(axlist,'tag'),'Colorbar'))>1 && ~any(isnan(coords(3:min(4,end))))
% 		axes(ax) % problem: brings ax to front, even if it's in an underlapping window
		set(hFig,'CurrentAxes',ax) % TODO also bring child to front, like axes(ax) would do it
	end
	
	try
		if any(isnan(coords)) || strcmp(dcm.Enable,'on')
			set(hRect,'Visible','off')
			set(hText,'String',str)
		else
			set(hRect,'Visible','on','Position',[floor(cp(1,1:2)+.5)-.5 1 1])
			
% 			set(hRect,'Visible','on','Position',[coords_to_show4d(coords,dims,dist)-.5 1 1])

% 			hRect = reshape(hRect,dims([3 4]));
% 			rect_coords = coords;
% 			for i=1:dims(3)
% 				rect_coords(3) = i;
% 				for j=1:dims(4)
% 					rect_coords(4) = j;
% 					set(hRect(i,j),'Visible','on','Position',[coords_to_show4d(rect_coords,dims,dist)-.5 1 1])
% 				end
% 			end

			uistack(hRect,'top') % in case of later-rendered lazy-mode slice
			set(hText,'String',str)
			
			break
		end
	catch e
		warning(e.getReport)
	end
end



% p = get(hText, 'Extent') %Get the outer position of the text
% % now create a patch around the text object
% hPatch = patch([p(1) p(1) p(1)+p(3) p(1)+p(3)], [p(2) p(2)+p(4) p(2)+p(4) p(2)], 'r');
% [p(1) p(1) p(1)+p(3) p(1)+p(3)], [p(2) p(2)+p(4) p(2)+p(4) p(2)]
% uistack(hText, 'top'); % put the text object on top of the patch object
% set(hPatch , 'FaceAlpha', .2); % set the alpha of the patch face to .2

% uistack(findobj(hFig,'Tag','Colorbar'),'bottom')

