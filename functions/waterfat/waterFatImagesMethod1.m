function [watermap, fatmap] = waterFatImagesMethod1(app, slice, dynamic)

image = app.complexImages(:,:,:,slice,dynamic,:); 
mask = squeeze(app.mask(:,:,slice,dynamic));

% Remove the TEs that are deselected in the app
delements = app.teSelection==0;
tes = app.tes';
tes(delements) = [];
image(delements,:,:,:,:) = [];

imDataParams.images = permute(image,[2 3 5 4 1]); % acquired k-space data, array of size[nx,ny,1,ncoils,nTE]

gamma = 42.56;
imDataParams.TE = tes;  % (in seconds)
imDataParams.FieldStrength = app.parameters.imagingFrequency(1)/gamma; % (in Tesla)

algoParams.species(1).name = 'water';
algoParams.species(1).ppm = 0;
algoParams.species(1).relAmps = 1;
algoParams.species(2).name = 'fat';
algoParams.species(2).frequency = [3.80, 3.40, 2.60, 1.94, 0.39, -0.60];
algoParams.species(2).ppm = [3.80, 3.40, 2.60, 1.94, 0.39, -0.60];
algoParams.species(2).relAmps = [0.087 0.693 0.128 0.004 0.039 0.048];

% algorithm specific parameters
algoParams.stepsize = 0.75;     % support size scaling
algoParams.min_win_size = 16;   % minimum 1D support size for B-spline
algoParams.MaxIter = 12;        % maximum iterations per scale


sizex = app.FOVViewField.Value;
sizey = app.AspectRatioViewField.Value*app.FOVViewField.Value;
sizez = app.SLTViewField.Value;
imDataParams.FOV= [sizex,sizey,sizez]; % (mm x mm x mm)
imDataParams.PrecessionIsClockwise = 0;

outParams = fw3pluspoint(imDataParams, algoParams);

W = abs(outParams.species(1).amps);
F = abs(outParams.species(2).amps);

watermap = 100*mask.*W./(W+F);
fatmap = 100*mask.*F./(W+F);

watermap(isnan(watermap)) = 0;
watermap(isinf(watermap)) = 0;
fatmap(isnan(fatmap)) = 0;
fatmap(isinf(fatmap)) = 0;

end % waterFatImages