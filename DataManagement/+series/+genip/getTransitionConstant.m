function const = getTransitionConstant(transitionModel, aggregation, lowData)
% getTransitionConstant  Calculate transition equation constant in Level,
% Diff or DiffDiff genip models
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

numWithin = size(aggregation, 2);

if strcmpi(transitionModel, 'Level')
    order = 0;
elseif strcmpi(transitionModel, 'Diff')
    order = 1;
elseif strcmpi(transitionModel, 'DiffDiff') || strcmpi(transitionModel, 'Diff^2')
    order = 2;
end

target = hereCalculateLowConstant( );
const = hereConvertToHighConstant( );

return

    function target = hereCalculateLowConstant( )
        numLowPeriods = size(lowData, 1);
        M = ones(numLowPeriods, 1);
        for i = 1 : order
            M = [M, cumsum(M(:, end), 1)]; 
        end
        inxObservations = isfinite(lowData);
        beta = M(inxObservations, :) \ lowData(inxObservations);
        target = beta(end);
    end%


    function const = hereConvertToHighConstant( )
        x = ones(numWithin*(order+1), 1);
        for i = 1 : order
            x = cumsum(x);
        end
        y = aggregation*reshape(x, numWithin, [ ]);
        if order>0
            y = diff(y, order, 2);
        end
        const = target / y;
    end%
end%
