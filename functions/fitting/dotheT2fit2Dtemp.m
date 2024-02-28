function [m0map_out,t2map_out,r2map_out] = dotheT2fit2D(app, slice, dynamic)

% -----------------------------------------------------------------------
% Performs a T2 map fitting of multi-echo data for 1 slice
% Gustav Strijkers
% 27 Feb 2024
% -----------------------------------------------------------------------

%#ok<*PFOUS> 

% image dimensions
inputImages = squeeze(app.images(:,:,:,slice,dynamic));
mask = squeeze(app.mask(:,:,slice,dynamic));
tes = app.tes;
rSquare = app.RsquareEditField.Value;
teSelection = app.teSelection;
[~,dimx,dimy] = size(inputImages);
m0map = zeros(dimx,dimy);
t2map = zeros(dimx,dimy);
r2map = zeros(dimx,dimy);

% drop the TEs that are deselected in the app
delements = find(teSelection==0);
tes(delements) = [];
inputImages(delements,:,:) = [];

x = [ones(length(tes),1),tes];

parfor j = 1:dimx               % for all x-coordinates
    
    for k = 1:dimy              % for all y-coordinates
        
        if mask(j,k) == 1       % only fit when mask value indicates valid data point

            % logarithm of pixel value as function of TE
            y = log(squeeze(inputImages(:,j,k)));

            % do the linear regression
            b = x\y;

            % maps
            t2map(j,k) = -1/b(2);
            m0map(j,k) = exp(b(1));

            % R2 map
            yCalc2 = x * b;
            r2map(j,k) = 1 - sum((y - yCalc2).^2)/sum((y - mean(y)).^2);

            % check for low R-square
            if r2map(j,k) < rSquare
                m0map(j,k) = 0;
                t2map(j,k) = 0;
                r2map(j,k) = 0;
            end
            
        end
        
    end
    
end

% Remove outliers
m0map(t2map < 0) = 0;
m0map(t2map > 5000) = 0;
r2map(t2map < 0) = 0;
r2map(t2map > 5000) = 0;
t2map(t2map < 0) = 0;
t2map(t2map > 5000) = 0;
m0map(isnan(t2map)) = 0;
r2map(isnan(t2map)) = 0;
t2map(isnan(t2map)) = 0;
m0map(isinf(t2map)) = 0;
r2map(isinf(t2map)) = 0;
t2map(isinf(t2map)) = 0;

% Return the maps
t2map_out = abs(t2map);
m0map_out = abs(m0map);    
r2map_out = abs(r2map);
    
end