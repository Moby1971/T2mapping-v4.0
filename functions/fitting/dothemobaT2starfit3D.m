function [m0map, t2map] = dothemobaT2starfit3D(app, dynamic)

% ---------------------------------------------------------------------------------
% Performs a model-based T2* map fitting of 3D multi-echo gradient-echo data
%
% Gustav Strijkers
% Amsterdam UMC
% g.j.strijkers@amsterdamumc.nl
% 24 sept 2023
%
% ---------------------------------------------------------------------------------


if app.validRegFlag

    % Reconstruct the k-space back from the registered images
    for echo = 1:size(app.images,1)
        kSpace(1,echo,:,:,:) = ifft3reco(squeeze(app.images(echo,:,:,:,dynamic))); %#ok<*AGROW>
    end

else

    % Original multicoil k-space data
    for coil = 1:app.nrCoils
        kSpace(coil,:,:,:,:) = squeeze(app.data{coil}(:,:,:,:,dynamic));
    end

end


% Remove the TEs that are deselected in the app
delements = app.teSelection==0;
tes = app.tes;
tes(delements) = [];
kSpace(:,delements,:,:) = [];



% Bart dimensions
% 	READ_DIM,       1   z
% 	PHS1_DIM,       2   y
% 	PHS2_DIM,       3   x
% 	COIL_DIM,       4   coils
% 	MAPS_DIM,       5   sense maps
% 	TE_DIM,         6   TEs
% 	COEFF_DIM,      7
% 	COEFF2_DIM,     8
% 	ITER_DIM,       9
% 	CSHIFT_DIM,     10
% 	TIME_DIM,       11  dynamics
% 	TIME2_DIM,      12
% 	LEVEL_DIM,      13
% 	SLICE_DIM,      14  slices
% 	AVG_DIM,        15

%                            0  1  2  3  4  5  6  7  8  9  10 11 12 13
%                            1  2  3  4  5  6  7  8  9  10 11 12 13 14
kSpacePics = permute(kSpace,[3 ,4 ,5 ,1 ,8 ,2 ,9 ,10,11,12,6 ,13,14,7 ]);


% Do a simple bart reconstruction of the individual images first
sensitivities = ones(size(kSpacePics));
picsCommand = 'pics -RW:7:0:0.001 ';
images = bart(app,picsCommand,kSpacePics,sensitivities);


% Do a phase correction
phaseImage = angle(images);
images = images.*exp(-1i.*phaseImage);
kSpacePics = bart(app,'fft -u 7',images);


% Prepare the echo times matrix
% In the test files in Bart the TE's are mulitplied by 0.01, not 0.001
% There seems to be a scaling factor of 10
TE(1,1,1,1,1,:) = tes*0.001;


% ---------------------
% Moba reco
% ---------------------
% -G    = T2* mapping using model-based multiple gradient echo
% -m3   = MGRE model R2S (I assume this means: R2*)
% -rQ:1 = l2 regularization
% -rS:0 = non-negative constraint
%

% I could not get the actual T2* fit working
% After phase-correction, I therefore used the TSE fit to extract a monoexponential decay constant


bartCommand = 'moba -F -d5 -l1 -i8 -C100 -rS:0 -rT:7:0:0.001 --kfilter-1 -n';
t2Fit = abs(bart(app,bartCommand,kSpacePics,TE));


% Extract M0 map
m0map = flip(squeeze(t2Fit(:,:,:,1,1,1,1)),2);


% Extract T2 map in ms
t2map = 100./flip(squeeze(t2Fit(:,:,:,1,1,1,2)),2);


% Remove outliers
m0map(t2map < 0) = 0;
m0map(t2map > 5000) = 0;
t2map(t2map < 0) = 0;
t2map(t2map > 5000) = 0;
m0map(isnan(t2map)) = 0;
t2map(isnan(t2map)) = 0;
m0map(isinf(t2map)) = 0;
t2map(isinf(t2map)) = 0;


% Masking
t2map = t2map.*squeeze(app.mask(:,:,:,dynamic));
m0map = m0map.*squeeze(app.mask(:,:,:,dynamic));


end