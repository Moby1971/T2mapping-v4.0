function [m0map_out, t2map_out, r2map_out] = dothebartT2fit(app, input_images, mask,  tes, r2, te_selection)


% performs the model-based T2(*) map fitting for 1 slice


% size of the data
[~, dimx, dimy] = size(input_images);
m0map = zeros(dimx,dimy);
t2map = zeros(dimx,dimy);
r2map = zeros(dimx,dimy);
tes = tes * 0.001;

disp(size(input_images))


% drop the TEs that are deselected in the app
delements = find(te_selection==0);
tes(delements) = [];
input_images(delements,:) = [];

disp(size(input_images))


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
images_pics = permute(input_images,[4 ,2 ,3 ,5 ,6 ,1 ,7 ,8, 9, 10,11,12,13,14]);

disp(size(images_pics));

norma = max(images_pics(:));

images_pics = images_pics/norma;


% echo times
TE = permute(tes,[2, 3, 4, 5, 6, 1]);

% Moba reco
picscommand = 'mobafit -G -i1';
t2fit = bart(app, picscommand, TE, images_pics);

disp(size(t2fit));


% Extract T2 map
t2map_out = squeeze(abs(t2fit(1,:,:,1,1,1,1)));

imshow(t2fit,[]);


% Convert from R2 to T2
t2map_out = 1000./t2map_out;
t2map_out(isinf(t2map_out)) = 0;
t2map_out(isnan(t2map_out)) = 0;
 
% Mask
t2map_out = t2map_out.*mask;

% M0
m0map_out = squeeze(abs(t2fit(1,:,:,1,1,1,2)));
m0map_out = m0map_out.*mask;
m0map_out = m0map_out*norma;
 



r2map_out = r2map;

end