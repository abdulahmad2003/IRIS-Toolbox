function [ plotHandle, time, yData, ...
           axesHandle, xData, ...
           unmatchedOptions ] = implementPlot(plotFunc, varargin)
% implementPlot  Plot functions for Series objects
%
% Backend function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

ERROR_INVALID_FREQUENCY = { 'Series:InvalidPlotRangeFrequency'
                            'Plot range and input time series must have the same date frequency' };

IS_ROUND = @(x) isnumeric(x) && all(x==round(x));

if isgraphics(varargin{1})
    axesHandle = varargin{1};
    varargin(1) = [ ];
else
    axesHandle = @gca;
end

if isa(varargin{1}, 'DateWrapper') || isequal(varargin{1}, Inf)
    time = varargin{1};
    varargin(1) = [ ];
elseif isnumeric(varargin{1})
    time = DateWrapper.fromDouble(varargin{1});
    varargin(1) = [ ];
else
    time = Inf;
end

this = varargin{1};
varargin(1) = [ ];

persistent parser
if isempty(parser)
    parser = extend.InputParser(['Series.implementPlot(', char(plotFunc), ')']);
    parser.KeepUnmatched = true;
    parser.addRequired('PlotFun', @(x) isa(x, 'function_handle'));
    parser.addRequired('Axes', @(x) isequal(x, @gca) || (all(isgraphics(x, 'Axes')) && isscalar(x)));
    parser.addRequired('Dates', @(x) isa(x, 'Date') || isa(x, 'DateWrapper') || isequal(x, Inf) || isempty(x) || IS_ROUND(x) );
    parser.addRequired('InputSeries', @(x) isa(x, 'Series') && ~iscell(x.Data));
    parser.addOptional('SpecString', cell.empty(1, 0), @iscell);
    parser.addParameter('DateTick', @auto, @(x) isequal(x, @auto) || DateWrapper.validateDateInput(x));
    parser.addParameter('DateFormat', @default, @(x) isequal(x, @default) || ischar(x));
    parser.addParameter( 'PositionWithinPeriod', @auto, @(x) isequal(x, @auto) ...
                         || any(strncmpi(x, {'Start', 'Middle', 'End'}, 1)) );
    parser.addParameter('XLimMargins', @auto, @(x) isequal(x, @auto) || isequal(x, true) || isequal(x, false));
end

parser.parse(plotFunc, axesHandle, time, this, varargin{:});
specString = parser.Results.SpecString;
opt = parser.Options;
unmatchedOptions = parser.UnmatchedInCell;

time = double(time);
enforceXLimHere = true;
if isequal(time, Inf) || isequal(time, [-Inf, Inf])
    time = this.RangeAsNumeric;
    enforceXLimHere = false;
elseif isempty(time) || all(isnan(time))
    time = double.empty(0, 1);
else
    time = time(:);
    checkUserFrequency(this, time);
end

%--------------------------------------------------------------------------

if isa(axesHandle, 'function_handle')
    axesHandle = axesHandle( );
end

[yData, time] = getData(this, time);

if ~isempty(time)
    timeFrequency = DateWrapper.getFrequencyAsNumeric(time(1));
else
    timeFrequency = NaN;
end

if ndims(yData)>2
    yData = yData(:, :);
end

[ xData, ...
  positionWithinPeriod, ...
  dateFormat ] = TimeSubscriptable.createDateAxisData( axesHandle, ...
                                                       time, ...
                                                       opt.PositionWithinPeriod, ...
                                                       opt.DateFormat );

if isempty(plotFunc)
    plotHandle = gobjects(0);
    return
end

if ~ishold(axesHandle)
    resetAxes( );
end

set(axesHandle, 'XLimMode', 'auto', 'XTickMode', 'auto');
[plotHandle, isTimeAxis] = this.plotSwitchboard( plotFunc, ...
                                                 axesHandle, ...
                                                 xData, ...
                                                 yData, ...
                                                 specString, ...
                                                 unmatchedOptions{:} );
if isTimeAxis
    addXLimMargins( );
    setXLim( );
    setXTick( );
    setXTickLabelFormat( );
    set(axesHandle, 'XTickLabelRotation', 0);
    setappdata(axesHandle, 'IRIS_PositionWithinPeriod', positionWithinPeriod);
    setappdata(axesHandle, 'IRIS_TimeSeriesPlot', true);
end

return




    function addXLimMargins( )
        % Leave a half period on either side of the horizontal axis around
        % the currently added data
        if isequal(opt.XLimMargins, false)
            return
        end
        if isequal(opt.XLimMargins, @auto) ...
           && ~(isequal(plotFunc, @bar) || isequal(plotFunc, @numeric.barcon))
           return
        end
        xLimMarginsOld = getappdata(axesHandle, 'IRIS_XLimMargins');
        margin = Frequency.getXLimMarginCalendarDuration(timeFrequency);
        xLimMarginsHere = [ xData(1)-margin
                            xData(:)+margin ];
        if isempty(xLimMarginsOld)
            xLimMarginsNew = xLimMarginsHere;
        else
            xLimMarginsNew = [ xLimMarginsOld
                              xLimMarginsHere ];
        end
        xLimMarginsNew = sort(unique(xLimMarginsNew));
        setappdata(axesHandle, 'IRIS_XLimMargins', xLimMarginsNew);
    end%




    function setXLim( )
        xLimHere = [min(xData), max(xData)];
        xLimOld = getappdata(axesHandle, 'IRIS_XLim');
        enforceXLimOld = getappdata(axesHandle, 'IRIS_EnforceXLim');
        if ~islogical(enforceXLimOld)
            enforceXLimOld = false;
        end
        enforceXLimNew = enforceXLimOld || enforceXLimHere;
        if ~enforceXLimNew
            if isempty(xLimOld)
                xLimNew = xLimHere;
            else
                xLimNew = [ min(xLimHere(1), xLimOld(1)), max(xLimHere(2), xLimOld(2)) ];
            end
        elseif enforceXLimHere
            xLimNew = xLimHere;
        else
            xLimNew = xLimOld;
        end
        xLimActual = getXLimActual(xLimNew);
        if ~isempty(xLimActual)
            set(axesHandle, 'XLim', xLimActual);
        end
        setappdata(axesHandle, 'IRIS_XLim', xLimNew);
        setappdata(axesHandle, 'IRIS_EnforceXLim', enforceXLimNew);
    end%




    function setXTick( )
        if isequal(opt.DateTick, @auto) || isempty(opt.DateTick)
            return
        end
        try
            dateTick = DateWrapper.toDatetime(opt.DateTick);
            set(axesHandle, 'XTick', dateTick);
        end
    end%




    function xData = setXTickLabelFormat( )
        if isempty(time) || timeFrequency==Frequency.INTEGER
            return
        end
        try
            axesHandle.XAxis.TickLabelFormat = dateFormat;
        end
    end%




    function xLim = getXLimActual(xLim)
        xLimMargins = getappdata(axesHandle, 'IRIS_XLimMargins');
        if isempty(xLimMargins)
            return
        end
        if xLim(1)>xLimMargins(1) && xLim(1)<xLimMargins(end)
            pos = find(xLim(1)<xLimMargins, 1) - 1;
            xLim(1) = xLimMargins(pos);
        end
        if xLim(2)>xLimMargins(2) && xLim(2)<xLimMargins(end)
            pos = find(xLim(2)>xLimMargins, 1, 'last') + 1;
            xLim(2) = xLimMargins(pos);
        end
    end%




    function resetAxes( )
        list = { 'IRIS_PositionWithinPeriod'
                 'IRIS_TimeSeriesPlot'
                 'IRIS_XLim'
                 'IRIS_EnforceXLim'
                 'IRIS_XLimMargins'
                 'IRIS_XLim'
                 'IRIS_XLim' };
        for i = 1 : numel(list)
            try
                rmappdata(axesHandle, list{i});
            end
        end
    end%
end%

%
% Local Validation Functions
%


function checkUserFrequency(this, time)
    ERROR_INVALID_FREQUENCY = { 'Series:InvalidPlotRangeFrequency'
                                'Plot range and input time series must have the same date frequency' };

    if numel(time)==1 || numel(time)==2
        validFrequencies = isnan(this.Start) || all(validateFrequencyOrInf(this, time));
    else
        validFrequencies = isnan(this.Start) || all(validateFrequency(this, time));
    end

    if ~validFrequencies
        throw( exception.Base(ERROR_INVALID_FREQUENCY, 'error') );
    end
end%
