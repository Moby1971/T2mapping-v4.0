function [m0map_out,t2map_out,r2map_out] = dotheT2fit_xdim_opt(input_images,mask,tes,rsquare,te_selection)

% performs the T2 map fitting for 1 slice

[~,dimx] = size(input_images);
m0map = zeros(dimx,1);
t2map = zeros(dimx,1);
r2map = zeros(dimx,1);

% drop the TEs that are deselected in the app
delements = find(te_selection==0);
tes(delements) = [];
input_images(delements,:) = [];

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
        
        % R2 map
        yCalc2 = x * b;
        r2map(j) = 1 - sum((y - yCalc2).^2)/sum((y - mean(y)).^2)
        
        if r2map(j) < rsquare
           m0map(j) = 0;
           t2map(j) = 0;
           r2map(j) = 0;
        end
        
    end
    
end

t2map_out = t2map;
m0map_out = m0map;    
r2map_out = r2map;
    
end