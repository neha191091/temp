function showNd_init

if isempty(getappdata(0,'showNd_init'))

	setappdata(0,'showNd_init','done')
	
	%% context menu

	% http://undocumentedmatlab.com/blog/customizing-workspace-context-menu/

	classes_real = {'double','logical','single','uint8','uint16','uint32','uint64','int8','int16','int32','int64','gpuArray'};
	menuName = 'My context-menu';
	menuItems = {'show', 'scroll', '-', 'size'};
	menuActions = {'show($1)', 'scroll($1)', '', 'fprintf(''size = \n\t%s\n'', num2str(size($1)))'};
	com.mathworks.mlwidgets.workspace.MatlabCustomClassRegistry.registerClassCallbacks(classes_real,menuName,menuItems,menuActions);

	classes_complex = cellfun(@(x)[x ' (complex)'],classes_real,'UniformOutput',false);
	menuName = 'My context-menu';
	menuItems = {'show (complex)', 'showm (magnitude)', 'scroll (complex)', 'scrollm (magnitude)', '-', 'size'};
	menuActions = {'show($1)', 'showm($1)', 'scroll($1)', 'scrollm($1)', '', 'fprintf(''size = \n\t%s\n'', num2str(size($1)))'};
	com.mathworks.mlwidgets.workspace.MatlabCustomClassRegistry.registerClassCallbacks(classes_complex,menuName,menuItems,menuActions);	
	
	classes = {'cell','struct','function_handle'};
	menuName = 'My context-menu';
	menuItems = {'size'};
% 	menuActions = {'size($1)'};
	menuActions = {'fprintf(''size = \n\t%s\n'', num2str(size($1)))'};
	com.mathworks.mlwidgets.workspace.MatlabCustomClassRegistry.registerClassCallbacks(classes,menuName,menuItems,menuActions);

	%% hotkeys

	% use EditorMacro from file exchange

	% if variable is in base workspace
	% EditorMacro('Alt x', @(hDocument,eventData)show(evalin('base',char(hDocument.getSelectedText))), 'run');

	% better: variable in current workspace, no matter if base or not
	% original EditorMacro has nested function calls, but we want to access the
	% value of the selection via evalin('caller', selection),
	% so we use a slightly modified version of EditorMacro:

	try
		EditorMacro_mymod('Alt x', {'use selection as argument',@(value,varargin)show(value)}, 'run')
		EditorMacro_mymod('Alt c', {'use selection as argument',@(value,varargin)scroll(value)}, 'run')
		EditorMacro_mymod('Alt s', {'use selection as argument',@(value,string)fprintf('size(%s) = \n\t%s\n', string, num2str(size(value)))}, 'run')
		% EditorMacro_mymod('Alt d', @(a,b)editoraction(a,b), 'run')
		EditorMacro_mymod('Alt a', {'use selection as argument',@(value,varargin)showm(value)}, 'run')
		EditorMacro_mymod('Alt z', {'use selection as argument',@(value,varargin)scrollm(value)}, 'run')
		EditorMacro_mymod('Alt y', {'use selection as argument',@(value,varargin)scrollm(value)}, 'run')
		EditorMacro_mymod('Alt q', {'use selection as argument',@(value,string)openvar(string)}, 'run')
		EditorMacro_mymod('Alt f', {'use selection as argument',@(value,varargin)find(value)}, 'run')
	catch e
		warning(e.getReport)
	end
	
	%% switchable figures
	try
		sfig all
	catch e
		warning(e.getReport)
	end
end

