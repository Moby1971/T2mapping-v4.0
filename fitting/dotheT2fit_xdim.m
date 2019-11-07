function [m0map_out,t2map_out] = dotheT2fit_xdim(input_images,mask,tes)

% performs the T2 map fitting for 1 slice

[ne,dimx] = size(input_images);
m0map = zeros(dimx,1);
t2map = zeros(dimx,1);

% fit options
opt = optimoptions('lsqcurvefit','Diagnostics','off','Display','off','MaxIterations',50);

% fitting function
F = @(x,xdata)x(1)*exp(-xdata/x(2));

% for fast initial estimation of T2
x0 = tes(round(ne/2));

parfor j=1:dimx
    % for all x-coordinates
    
    if mask(j) == 1
        % only fit when mask value indicates valid data point
        
        % pixel value as function of TE
        ydata = squeeze(input_images(:,j));
        
        % starting value y0
        y0 = ydata(1);
        
        % do the fit
        x = lsqcurvefit(F,[y0,x0],tes,ydata,[1 1],[Inf Inf],opt);
        
        % make the maps
        m0map(j)=x(1);
        t2map(j)=x(2);
        
    end
    
    
end


t2map_out = t2map;
m0map_out = m0map;    
    
end