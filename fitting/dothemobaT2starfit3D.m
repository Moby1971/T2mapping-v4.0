function [m0MapOut, t2MapOut] = dothemobaT2starfit3D(app, dynamic)

% ---------------------------------------------------------------------------------
% Performs a model-based T2* map fitting of 3D multi-echo gradient-echo data
%
% Gustav Strijkers
% Amsterdam UMC
% g.j.strijkers@amsterdamumc.nl
% 08/12/2022
%
% ---------------------------------------------------------------------------------


% Multicoil data
for k = 1:app.nrCoils
    kSpace(k,:,:,:,:) = squeeze(app.data{k}(:,:,:,:,dynamic)); %#ok<AGROW> 
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

clc;

disp('images')
disp(size(images))

% Do a phase correction
phaseImage = angle(images);
images = images.*exp(-1i.*phaseImage);
kSpacePics = bart(app,'fft -u 7',images);

disp('kSpacePics')
disp(size(kSpacePics))


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

bartCommand = 'moba -F -d4 -l1 -i8 -C100 -rS:0 -rT:38:0:0.001 --kfilter-1 -n';
t2Fit = abs(bart(app,bartCommand,kSpacePics,TE));



disp('t2Fit')
disp(size(t2Fit))


% Extract M0 map
m0MapOut = flip(squeeze(t2Fit(:,:,:,1,1,1,1)),2);

disp('m0MapOut')
disp(size(m0MapOut))

% Extract T2 map in ms
t2MapOut = 100./flip(squeeze(t2Fit(:,:,:,1,1,1,2)),2);
t2MapOut(isinf(t2MapOut)) = 0;
t2MapOut(isnan(t2MapOut)) = 0;

disp('t2MapOut')
disp(size(m0MapOut))

% Remove outliers
t2MapOut(t2MapOut < 0.1) = 0;
t2MapOut(t2MapOut > 1000) = 0;
m0MapOut(t2MapOut < 0.1) = 0;
m0MapOut(t2MapOut > 1000) = 0;

disp('mask')
disp(size(squeeze(app.mask(:,:,:,dynamic))));

% Masking
t2MapOut = t2MapOut.*squeeze(app.mask(:,:,:,dynamic));
m0MapOut = m0MapOut.*squeeze(app.mask(:,:,:,dynamic));


end