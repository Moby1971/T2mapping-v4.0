function [m0map_out,t2map_out] = dotheT2fit_xdim_opt(input_images,mask,tes)

% performs the T2 map fitting for 1 slice

[~,dimx] = size(input_images);
m0map = zeros(dimx,1);
t2map = zeros(dimx,1);

x = [ones(length(tes),1),tes];

parfor j=1:dimx
    % for all x-coordinates
    
    if mask(j) == 1
        % only fit when mask value indicates valid data point
        
        % pixel value as function of TE
        y = log(squeeze(input_images(:,j)));
              
        % do the linear regression
        b = x\y;
      
        % make the maps
        m0map(j) = exp(b(1));
        t2map(j) = -1/b(2);
        
    end
    
end

t2map_out = t2map;
m0map_out = m0map;    
    
end