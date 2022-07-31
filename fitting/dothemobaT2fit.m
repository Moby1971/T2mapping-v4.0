function [m0MapOut, t2MapOut] = dothemobaT2fit(app, slice)

% ------------------------------------------------------
% Performs a model-based T2 map fitting for 1 slice
% ------------------------------------------------------


% Multicoil data
for k = 1:app.nrCoils
    kSpace(k,:,:,:) = squeeze(app.data{k}(:,:,:,slice)); %#ok<AGROW> 
end


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
TE(1,1,1,1:app.nrCoils,1,:) = app.tes*0.001;


% Moba reco
picscommand = 'moba -F -l1 -rT:38:0:0.01 --kfilter-2';
t2FitCoils = bart(app,picscommand,kSpacePics,TE);


% Sum of squares reconstruction over the coil dimension
t2Fit = abs(bart(app,'rss 16', t2FitCoils));


% Extract M0 map
m0MapOut = flip(squeeze(t2Fit(1,:,:,1,1,1,1)),2);


% Extract T2 map
% Somewhere in the function T2fun.c of Bart I noticed a scaling factor of 10
t2MapOut = 100./flip(squeeze(t2Fit(1,:,:,1,1,1,2)),2);
t2MapOut(isinf(t2MapOut)) = 0;
t2MapOut(isnan(t2MapOut)) = 0;


% Masking
t2MapOut = t2MapOut.*squeeze(app.mask(:,:,slice));
m0MapOut = m0MapOut.*squeeze(app.mask(:,:,slice));


end