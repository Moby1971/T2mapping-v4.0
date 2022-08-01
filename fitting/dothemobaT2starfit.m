function [m0MapOut, t2MapOut] = dothemobaT2starfit(app, slice)

% ---------------------------------------------------------------------------------
% Performs a model-based T2* map fitting of multi-gradient-echo data for 1 slice
% ---------------------------------------------------------------------------------


% Multicoil data
for k = 1:app.nrCoils
    kSpace(k,:,:,:) = squeeze(app.data{k}(:,:,:,slice)); %#ok<AGROW> 
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


% Prepare the echo times matrix
% In the test files in Bart the TE's are mulitplied by 0.01, not 0.001
% There seems to be a scaling factor of 10
TE(1,1,1,1:app.nrCoils,1,:) = tes*0.01;

% ---------------------
% Moba reco
% ---------------------
% -G    = T2* mapping using model-based multiple gradient echo
% -m3   = MGRE model R2S (I assume this means: R2*)
% -rQ:1 = l2 regularization
% -rS:0 = non-negative constraint
%
picscommand = 'moba -G -m2 -rQ:1 -rS:0 -rW:3:64:1 -i10 -C100 -u0.0001 --kfilter-2 ';

picscommand = 'moba -G -m1 ';
t2FitCoils = bart(app,picscommand,kSpacePics,TE);


% Sum of squares reconstruction over the coil dimension
t2Fit = bart(app,'rss 16', t2FitCoils);

disp(size(t2Fit))

% Extract M0 map
m0MapOut = flip(squeeze(t2Fit(1,:,:,1,1,1,1)),2);


% Extract T2 map in ms
t2MapOut = 1000./flip(squeeze(t2Fit(1,:,:,1,1,1,2)),2);
t2MapOut(isinf(t2MapOut)) = 0;
t2MapOut(isnan(t2MapOut)) = 0;


% Remove outliers
t2MapOut(t2MapOut < 0.1) = 0;
t2MapOut(t2MapOut > 500) = 0;
m0MapOut(t2MapOut < 0.1) = 0;
m0MapOut(t2MapOut > 500) = 0;


% Masking
t2MapOut = t2MapOut.*squeeze(app.mask(:,:,slice));
m0MapOut = m0MapOut.*squeeze(app.mask(:,:,slice));


end