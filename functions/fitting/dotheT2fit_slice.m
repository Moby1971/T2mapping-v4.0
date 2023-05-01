function [m0map_out,t2map_out,r2map_out] = dotheT2fit_slice(inputImages,mask,tes,rSquare,teSelection)

% performs the T2 map fitting for 1 slice


% image dimensions
[~,dimx,dimy] = size(inputImages);
m0map = zeros(dimx,dimy);
t2map = zeros(dimx,dimy);
r2map = zeros(dimx,dimy);


% drop the TEs that are deselected in the app
delements = find(teSelection==0);
tes(delements) = [];
inputImages(delements,:,:) = [];

x = [ones(length(tes),1),tes];


parfor j=1:dimx
    % for all x-coordinates
    
    for k=1:dimy
        % for all y-coordinates
        
        if mask(j,k) == 1
            % only fit when mask value indicates valid data point
            
            % logarithm of pixel value as function of TE
            y = log(squeeze(inputImages(:,j,k)));
            
            % do the linear regression
            b = x\y;
            
            % make the maps
            m0map(j,k) = exp(b(1));
            t2map(j,k) = -1/b(2);
            
            % R2 map
            yCalc2 = x * b;
            r2map(j,k) = 1 - sum((y - yCalc2).^2)/sum((y - mean(y)).^2);
            
            % check for low R-square
            if r2map(j,k) < rSquare
                m0map(j,k) = 0;
                t2map(j,k) = 0;
                r2map(j,k) = 0;
            end
            
        end
        
    end
    
end

t2map_out = t2map;
m0map_out = m0map;    
r2map_out = r2map;
    
end