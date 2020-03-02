% Gamma  Gamma distribution object
%
%
% Gamma methods:
%
% __Constructors__
%
% The following are static constructors and need to be called with
% `distribution.Gamma.` preceding their names.
%
%   fromShapeScale - Gamma distribution from shape and scale parameters
%   fromAlphaBeta - Gamma distribution from alpha and beta parameters
%   fromMeanVar - Gamma distribution from mean and variance
%   fromMeanStd - Gamma distribution from mean and std deviation
%   fromModeVar - Gamma distribution from mode and variance
%   fromModeStd - Gamma distribution from mode and std deviation
%
%
% __Distribution Properties__
%
% These properties are directly accessible through the distribution object,
% followed by a dot and the name of a property.
%
%   Name - Name of the distribution
%   Domain - Domain of the distribution
%
%   Alpha - Alpha (shape) parameter of Gamma distribution
%   Beta - Beta (scale) parameter of Gamma distribution
%   Mean - Mean (expected value) of distribution
%   Var - Variance of distribution
%   Std - Standard deviation of distribution
%   Mode - Mode of distribution
%   Median - Median of distribution
%   Location - Location parameter of distribution
%   Shape - Shape parameter of distribution
%   Scale - Scale parameter of distribution
%
%
% __Density Related Functions__
%
%   pdf - Probability density function
%   logPdf - Log of probability density function up to constant
%   info - Minus second derivative of log of probability density function
%   inDomain - True for data points within domain of distribution function
%
%
% __Description__
%

% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

classdef Gamma ...
    < distribution.Abstract ...
    & distribution.GammaFamily

    properties (SetAccess=protected)
        % Alpha  Alpha (shape) parameter of the distribution
        Alpha = NaN

        % Beta  Beta (scale) parameter of the distribution
        Beta = NaN
    end


    methods
        function this = Gamma( )
            this.Name = 'Gamma';
            this.Domain = [0, Inf];
            this.Location = 0;
        end%
    end


    methods (Access=protected)
        function alphaBetaFromMeanVar(this)
            this.Beta = this.Var / this.Mean;
            this.Alpha = this.Mean / this.Beta;
        end%


        function alphaBetaFromModeVar(this)
            k = this.Mode^2/this.Var + 2;
            this.Alpha = fzero(@(x) x+1/x - k, [1+1e-10, 1e10]);
            this.Beta = this.Mode/(this.Alpha - 1);
        end%
    end


    methods (Static)
        function this = fromShapeScale(varargin)
            % fromShapeScale  Gamma distribution from shape and scale parameters
            this = distribution.Gamma.fromAlphaBeta(varargin{:});
        end%


        function this = fromAlphaBeta(varargin)
            % fromAlphaBeta  Gamma distribution from alpha and beta parameters
            this = distribution.Gamma( );
            [this.Alpha, this.Beta] = varargin{1:2};
            populateParameters(this);
        end%


        function this = fromMeanVar(varargin)
            % fromMeanVar  Gamma distribution from mean and variance
            this = distribution.Gamma( );
            [this.Mean, this.Var] = varargin{1:2};
            alphaBetaFromMeanVar(this);
            populateParameters(this);
        end%


        function this = fromMeanStd(varargin)
            % fromMeanStd  Gamma distribution from mean and std deviation
            this = distribution.Gamma( );
            [this.Mean, this.Std] = varargin{1:2};
            alphaBetaFromMeanVar(this);
            populateParameters(this);
        end%


        function this = fromModeVar(varargin)
            % fromModeStd  Gamma distribution from mode and variance
            this = distribution.Gamma( );
            [this.Mode, this.Var] = varargin{1:2};
            alphaBetaFromModeVar(this);
            populateParameters(this);
        end%


        function this = fromModeStd(varargin)
            % fromModeStd  Gamma distribution from mode and std deviation
            this = distribution.Gamma( );
            [this.Mode, this.Std] = varargin{1:2};
            alphaBetaFromModeVar(this);
            populateParameters(this);
        end%
    end
end
