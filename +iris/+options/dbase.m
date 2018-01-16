function Def = dbase( )
% dbase  Default options for dbase functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

validFn = iris.options.validfn;

Def = struct( );

dateformat = { ...
    'dateformat',@config,@config
    'freqletters,freqletter',@config,@config
    'months,month',@config,@config
    'ConversionMonth, standinmonth',@config,@config
    'Wday',@config,@config
    };

Def.dbbatch = {
    'append',[ ],@(x) isempty(x) || islogical(x), ...
    'classlist, classfilter', @all, @(x) isequal(x, @all) || isequal(x, Inf) || ischar(x) || iscellstr(x), ...
    'freqfilter',Inf,@isnumeric, ...
    'merge',[ ],@(x) isempty(x) || islogical(x), ...
    'namefilter','',@(x) isempty(x) || (isnumeric(x) && isinf(x)) || ischar(x), ...
    'namelist',Inf,@(x) (isnumeric(x) && isinf(x)) || ischar(x) || iscellstr(x), ...
    'fresh',false,@(x) islogical(x) || isstruct(x), ...
    'stringlist',{ },@(x) iscellstr(x) || ischar(x), ...
    };

Def.dbload = [
    dateformat
    {
    'case,changecase','',@(x) isempty(x) || any(strcmpi(x,{'lower','upper'}))
    'commentrow',{'comment','comments'},@(x) ischar(x) || iscellstr(x)
    'Continuous', false, @(x) isequal(x, false) || any(strcmpi(x, {'Ascending', 'Descending'}))
    'delimiter',',',@(x) ischar(x) && length(sprintf(x))==1
    'firstdateonly',false,@islogicalscalar
    'inputformat','auto',@(x) ischar(x) && (strcmpi(x,'auto') || strcmpi(x,'csv') || strncmpi(x,'xl',2))
    'namerow,leadingrow',{'','variables'},@(x) ischar(x) || iscellstr(x) || isnumericscalar(x)
    'namefunc',[ ],@(x) isempty(x) || isfunc(x) || (iscell(x) && all(cellfun(@isfunc,x)))
    'freq',[ ],@(x) isempty(x) || (ischar(x) && strcmpi(x,'daily')) || (length(x)==1 && isnan(x)) || (isnumeric(x) && length(x)==1 && any(x==[0,1,2,4,6,12,52,365]))
    'nan','NaN',@(x) ischar(x)
    'preprocess',[ ],@(x) isempty(x) || isfunc(x) || (iscell(x) && all(cellfun(@isfunc,x)))
    'select',@all, @(x) isequal(x,@all) || ischar(x) || iscellstr(x)
    'skiprows,skiprow','',@(x) isempty(x) || ischar(x) || iscellstr(x) || isnumeric(x)
    'userdata',Inf,@(x) isequal(x,Inf) || (ischar(x) && isvarname(x))
    'userdatafield','.',@(x) ischar(x) && length(x)==1
    'userdatafieldlist',{ },@(x) isempty(x) || iscellstr(x) || isnumeric(x)
    } ]; %#ok<CCAT>

Def.dbminuscontrol = { ...
    'fresh',true,@islogicalscalar, ...
    };

Def.dbnames = { ...
    'classfilter,classlist',@all, ...
    @(x) isequal(x,@all) || ischar(x) || iscellstr(x) || isa(x, 'rexp'), ...
    'namefilter,namelist',@all, ...
    @(x) isequal(x,@all) || ischar(x) || iscellstr(x) || isa(x, 'rexp'), ...
    };

Def.dbfun = { ...
    'recursive,cascade',true,@islogicalscalar, ...
    'fresh',false,@islogicalscalar, ...
    'iferror,onerror','remove',@(x) ischar(x) && any(strcmpi(x,{'remove','nan'})), ...
    'ifwarning,onwarning','keep',@(x) ischar(x) && any(strcmpi(x,{'remove','keep','nan'})), ...
    Def.dbnames{:}, ...
    }; %#ok<CCAT>

Def.dbplot = {...
    'addclick',true,@islogicalscalar, ...
    'caption,captions,title,titles',{ },@(x) isempty(x) || iscellstr(x) || isfunc(x), ...
    'comment',{ },@(x) isempty(x) || ischar(x) || iscellstr(x), ...
    'clear',[ ],@isnumeric, ...
    'clone','',@ischar, ...
    'deviationfrom,deviationsfrom',[ ],@(x) isempty(x) || islogicalscalar(x) || isnumericscalar(x), ...
    'deviationtimes,deviationstimes',1,@isnumericscalar, ...
    'dbsave',false,@(x) islogicalscalar(x) || (iscell(x) && iscellstr(x(1:2:end))), ...
    'drawnow',false,@islogical, ...
    'IncludeInLegend', true, @islogical, ...
    'grid',true,@islogicalscalar, ...
    'figurefunc', @figure, @(x) isa(x, 'function_handle'), ...
    'figureopt,figureoptions,figure',{ },validFn.figureopt, ...
    'highlight',[ ],@(x) isnumeric(x) ...
    || (iscell(x) && all(cellfun(@isnumeric,x))), ...
    'interpreter','none',@(x) any(strcmpi(x,{'latex','tex','none'})), ...
    'mark',{ },@iscellstr, ...
    'maxfigure',false,@islogicalscalar, ...
    'maxperfigure',36,@(x) isintscalar(x) && x>0, ...
    'overflow',true,@islogicalscalar, ...
    'pagenumber,pagenumbers',false,@islogicalscalar, ...    
    'plotfunc,plotfn',@plot, ...
    @(x) isfunc(x) || ischar(x) || (iscell(x) && isfunc(x{1}) && iscellstr(x(2:2:end))), ...
    'prefix','P%g_',@ischar, ...
    'round',Inf,@(x) isnumericscalar(x) && x>=0 && round(x)==x, ...
    'saveas','',@ischar, ...
    'Steady, sstate',struct( ),@(x) isempty(x) || isstruct(x) || isa(x,'model'), ...
    'style',struct( ),@(x) isempty(x) || isstruct(x) || (iscellstr(x) && length(x)==1), ...
    'SubDatabase,SubDbase', [ ], @(x) isempty(x) || iscellstr(x) || ischar(x), ...
    'subplot',@auto,validFn.subplot, ...
    'tight',false,@islogicalscalar, ...
    'transform',[ ],@(x) isempty(x) || isfunc(x), ...
    'vline',[ ],@(x) isempty(x) || isnumeric(x), ...
    'xlabel','',@(x) ischar(x) || iscellstr(x), ...
    'ylabel','',@(x) ischar(x) || iscellstr(x), ...
    'zeroline',false,@islogicalscalar, ...
    };

Def.dbprintuserdata = { ...
    'output','prompt',@(x) ischar(x) && any(strcmpi(x,{'html','prompt'})), ...
    };

Def.dbrange = { ...
    'startdate','maxrange',@(x) ischar(x) && any(strcmpi(x,{'maxrange','minrange','balanced','unbalanced'})), ...
    'enddate','maxrange',@(x) ischar(x) && any(strcmpi(x,{'maxrange','minrange','balanced','unbalanced'})), ...
    };

Def.dbsave = [
    dateformat
    {
    'VariablesHeader', 'Variables ->', @(x) ischar(x) && isempty(strfind(x, '''')) && isempty(strfind(x, '"'))
    'ClassHeader', 'Class[Size] ->', @(x) ischar(x) && isempty(strfind(x, '''')) && isempty(strfind(x, '"'))
    'Class',true,@islogicalscalar
    'Comment',true,@islogicalscalar
    'CommentsHeader', 'Comments ->', @(x) ischar(x) && isempty(strfind(x, '''')) && isempty(strfind(x, '"'))
    'Decimal',[ ],@(x) isempty(x) || (length(x)==1 && isnumeric(x))
    'Format','%.8e',@(x) ischar(x) && ~isempty(x) && x(1)=='%' && isempty(strfind(x,'$')) && isempty(strfind(x,'-'))
    'MatchFreq',false,@islogicalscalar
    'Nan','NaN',@ischar
    'SaveSubdb',false,@islogicalscalar
    'UserData','userdata',@(x) ischar(x) && isvarname(x)
    'UnitsHeader', 'Units ->', @(x) ischar(x) && isempty(strfind(x, '''')) && isempty(strfind(x, '"'))
    'Delimiter', ',', @ischar
    } ]; %#ok<CCAT>

Def.dbsplit = { ...
    'discard',true,@islogicalscalar, ...
    };

Def.xls2csv = { ...
    'sheet',1,@(x) (isintscalar(x) && x>0) || ischar(x), ...
    };

end
