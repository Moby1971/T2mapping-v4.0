function images = CSreco(app)

% -----------------------------------------------------------------------
%
% Performs a CS reconstruction of the raw k-space data
%
% Gustav Strijkers
% Amsterdam UMC
% g.j.strijkers@amsterdamumc.nl
% 25/08/2022
%
%------------------------------------------------------------


% Multi-receiver data
for coil = 1:app.nrCoils
    kSpace(coil,:,:,:,:,:) = app.data{coil}; %#ok<AGROW> 
end


% Bart dimensions
% 	READ_DIM,       1   z  
% 	PHS1_DIM,       2   y  
% 	PHS2_DIM,       3   x  
% 	COIL_DIM,       4   coils
% 	MAPS_DIM,       5   sense maps
% 	TE_DIM,         6   TIs / TEs
% 	COEFF_DIM,      7
% 	COEFF2_DIM,     8
% 	ITER_DIM,       9
% 	CSHIFT_DIM,     10
% 	TIME_DIM,       11  dynamics
% 	TIME2_DIM,      12  
% 	LEVEL_DIM,      13
% 	SLICE_DIM,      14  slices
% 	AVG_DIM,        15


%          1      2   3  4     5       6     
% kspace = coils, te, x, y, slices, dynamics
% 
%                            0  1  2  3  4  5  6  7  8  9  10 11 12 13
%                            1  2  3  4  5  6  7  8  9  10 11 12 13 14
kSpacePics = permute(kSpace,[7 ,3 ,4 ,1 ,8 ,2 ,9 ,10,11,12,6 ,13,14,5 ]);


% Sensitivities
sensitivities = ones(size(kSpacePics));


% Pics command
picsCommand = 'pics -RW:6:0:0.01 -RT:1024:0:0.1';


% Bart reconstruction
images = bart(app,picsCommand,kSpacePics,sensitivities);


% Sum of squares over the coil dimension
images = abs(bart(app,'rss 8', images));


% Put the dimensions back in the right order
images = ipermute(images,[7 ,3 ,4 ,1 ,8 ,2 ,9 ,10,11,12,6 ,13,14,5 ]);
images = permute(images,[2,3,4,5,6,1]);
images = flip(images,3);
images = double(images);


end