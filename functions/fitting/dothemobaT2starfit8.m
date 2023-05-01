function [m0MapOut, t2MapOut] = dothemobaT2starfit8(app, slice, firstDynamic, lastDynamic)

% ---------------------------------------------------------------------------------
% Performs a model-based T2* map fitting of multi-gradient-echo data for 1 slice
% ---------------------------------------------------------------------------------


% Multicoil data
for k = 1:app.nrCoils
    kSpace(k,:,:,:,:) = squeeze(app.data{k}(:,:,:,slice,firstDynamic:lastDynamic)); %#ok<AGROW> 
end


% Remove the TEs that are deselected in the app
delements = app.teSelection==0;
tes = app.tes;
tes(delements) = [];
kSpace(:,delements,:,:,:) = [];

clc;

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
kSpacePics = permute(kSpace,[6 ,3 ,4 ,1 ,7 ,2 ,8 ,9 ,10,11,12,5, 13,14]);


% Do a simple bart reconstruction of the individual images first
sensitivities = ones(size(kSpacePics));
picsCommand = 'pics -RW:6:0:0.001 ';
images = bart(app,picsCommand,kSpacePics,sensitivities);


% Do a phase correction
phaseImage = angle(images);
images = images.*exp(-1i.*phaseImage);
kSpacePics = bart(app,'fft -u 6',images);

disp(size(kSpacePics))


% Prepare the echo times matrix
% In the test files in Bart the TE's are mulitplied by 0.01, not 0.001
% There seems to be a scaling factor of 10
for dynamic = 1:size(kSpacePics,12)
    TE(1,1,1,1,1,:,1,1,1,1,1,dynamic) = tes*0.001; %#ok<AGROW> 
end

disp(size(TE))

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

bartCommand = 'moba -F -d4 -l1 -i8 -C100 -rS:0 -J -rT:38:0:0.001 --kfilter-1 -n';
t2Fit = abs(bart(app,bartCommand,kSpacePics,TE));

disp(size(t2Fit))


% Extract M0 map
m0MapOut = flip(squeeze(t2Fit(1,:,:,1,1,1,1)),2);


% Extract T2 map in ms
t2MapOut = 100./flip(squeeze(t2Fit(1,:,:,1,1,1,2)),2);
t2MapOut(isinf(t2MapOut)) = 0;
t2MapOut(isnan(t2MapOut)) = 0;


% Remove outliers
t2MapOut(t2MapOut < 0.1) = 0;
t2MapOut(t2MapOut > 500) = 0;
m0MapOut(t2MapOut < 0.1) = 0;
m0MapOut(t2MapOut > 500) = 0;


% Masking
t2MapOut = t2MapOut.*squeeze(app.mask(:,:,slice,dynamic));
m0MapOut = m0MapOut.*squeeze(app.mask(:,:,slice,dynamic));


end