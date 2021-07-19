function [image_out, m0map_out, t2map_out, r2map_out] = dothemobaT2fit(app, kspace, mask, norm, tes, te_selection)


% performs the model-based T2(*) map fitting for 1 slice


% size of the data
[nc, ~ , dimx, dimy] = size(kspace);
m0map = zeros(dimx,dimy);
t2map = zeros(dimx,dimy);
r2map = zeros(dimx,dimy);
tes = tes * 0.001;



% Bart dimensions
% 	READ_DIM,       1   z  
% 	PHS1_DIM,       2   y  
% 	PHS2_DIM,       3   x  
% 	COIL_DIM,       4   coils
% 	MAPS_DIM,       5   sense maps
% 	TE_DIM,         6
% 	COEFF_DIM,      7
% 	COEFF2_DIM,     8
% 	ITER_DIM,       9
% 	CSHIFT_DIM,     10
% 	TIME_DIM,       11  dynamics
% 	TIME2_DIM,      12  
% 	LEVEL_DIM,      13
% 	SLICE_DIM,      14  slices
% 	AVG_DIM,        15

%                             0  1  2  3  4  5  6  7  8  9  10 11 12 13
%                             1  2  3  4  5  6  7  8  9  10 11 12 13 14
kspace_pics = permute(kspace,[5 ,4 ,3 ,1 ,6 ,2 ,7 ,8, 9, 10,11,12,13,14]);

% echo times
TE = permute(tes,[2, 3, 4, 5, 6, 1]);

% Moba reco
picscommand = 'moba -G -m0 -d4 -n ';
t2fit = bart(app,picscommand,kspace_pics,TE);

picscommand = 'moba -F -i10 -C100 -d4 -n ';
image = bart(app,picscommand,kspace_pics,TE);


imshow(squeeze(abs(t2fit(1,:,:))),[]);

% Extract images
image_out = squeeze(abs(image(1,:,:,1,1,1,:)));
image_out = permute(image_out,[3 2 1]);


% Extract T2 map
t2map_out = squeeze(abs(t2fit(1,:,:,1,1,1,2)));
t2map_out = permute(t2map_out,[2 1]);

% Convert from R2 to T2
t2map_out = 1000./t2map_out;
t2map_out(isinf(t2map_out)) = 0;
t2map_out(isnan(t2map_out)) = 0;

% Mask
t2map_out = t2map_out.*mask;

% M0
m0map_out = squeeze(abs(t2fit(1,:,:,1,1,1,1)));
m0map_out = permute(m0map_out,[2 1]);
m0map_out = m0map_out.*mask;

% Normalization
norma = 16384/max(image_out(:));
m0map_out = round(norma*m0map_out);
image_out = round(norma*image_out);


r2map_out = r2map;

end