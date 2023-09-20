function [m0MapOut, t2MapOut] = dothemobaT2fit(app, slice, dynamic)

% -----------------------------------------------------------------------
% Performs a model-based T2 map fitting of multi-echo data for 1 slice
% Gustav Strijkers
% 20 Sept 2023
% -----------------------------------------------------------------------


if app.validRegFlag

    % Reconstruct the k-space back from the registered images
    for echo = 1:size(app.images,1)
        kSpace(1,echo,:,:) = ifft2reco(squeeze(app.images(echo,:,:,slice,dynamic))); %#ok<*AGROW> 
    end

else

    % Original multicoil k-space data
    for coil = 1:app.nrCoils
        kSpace(coil,:,:,:) = squeeze(app.data{coil}(:,:,:,slice,dynamic)); 
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
kSpacePics = permute(kSpace,[6 ,3 ,4 ,1 ,7 ,2 ,8 ,9 ,10,11,12,13,14,5 ]);


% Do a simple bart reconstruction of the individual images first
sensitivities = ones(size(kSpacePics));
picsCommand = 'pics -RW:6:0:0.001 ';
images = bart(app,picsCommand,kSpacePics,sensitivities);


% Do a phase correction
phaseImage = angle(images);
images = images.*exp(-1i.*phaseImage);
kSpacePics = bart(app,'fft -u 6',images);



% Prepare the echo times matrix
TE(1,1,1,1,1,:) = tes*0.001;


% Moba reco
picscommand = 'moba -F -d4 -l1 -i8 -C100 -rS:0 -rT:38:0:0.001 --kfilter-1 -n';
t2Fit = abs(bart(app,picscommand,kSpacePics,TE));


% Extract M0 map
m0MapOut = flip(squeeze(t2Fit(1,:,:,1,1,1,1)),2);


% Extract T2 map
% Somewhere in the function T2fun.c of Bart I noticed a scaling factor of 10
% The T2 value is therefore calculated as: 100/R2 instead of 1000/R2
t2MapOut = 100./flip(squeeze(t2Fit(1,:,:,1,1,1,2)),2);
t2MapOut(isinf(t2MapOut)) = 0;
t2MapOut(isnan(t2MapOut)) = 0;


% Remove outliers
t2MapOut(t2MapOut < 1) = 0;
t2MapOut(t2MapOut > 5000) = 0;
m0MapOut(t2MapOut < 1) = 0;
m0MapOut(t2MapOut > 5000) = 0;


% Masking
t2MapOut = t2MapOut.*squeeze(app.mask(:,:,slice));
m0MapOut = m0MapOut.*squeeze(app.mask(:,:,slice));


end