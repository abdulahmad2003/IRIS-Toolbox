classdef ( Abstract, ...
           CaseInsensitiveProperties=true, ...
           InferiorClasses={?matlab.graphics.axis.Axes, ?DateWrapper} ) ...
         NumericTimeSubscriptable < TimeSubscriptable ...
                                  & shared.UserDataContainer

    properties
        % Data  Numeric or logical array of time series data
        Data = double.empty(0, 1) 

        % MissingValue  Representation of missing value
        MissingValue = NaN 
    end


    properties (Dependent)
        % MissingTest  Test for missing values
        MissingTest 
    end


    methods 
        function this = NumericTimeSubscriptable(varargin)
            this = this@shared.UserDataContainer( );
        end%


        function missingTest = get.MissingTest(this)
            missingValue = this.MissingValue;
            if isequaln(missingValue, NaN)
                missingTest = @isnan;
            else
                missingTest = @(x) x==missingValue;
            end
        end%
    end


    methods
        varargout = ellone(varargin)
    end
end