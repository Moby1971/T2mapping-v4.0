function export_gif_t2(gifexportpath,t2map,m0map,r2map,tag,T2MapScale,t2cmap,m0cmap,r2cmap,aspect,parameters,rsquare)

% Exports t2maps and m0maps to animated gif


% Dimensions
[dimx,dimy,dimz] = size(t2map);

% Increase the size of the matrix to make the exported images bigger
numrows = 2*dimx;
numcols = 2*round(dimy/aspect);

% Animated gif delay time
delay_time = 2/dimz;  % 2 seconds in total


% Export the T2 maps to gifs

for idx = 1:dimz
    
    image = uint8(round((255/T2MapScale)*resizem(squeeze(t2map(:,:,idx)),[numrows numcols])));
    
    if isfield(parameters, 'PHASE_ORIENTATION')
        if parameters.PHASE_ORIENTATION
            image = rot90(image,-1);
        end
    end
    
    if idx == 1
        imwrite(rot90(image),t2cmap,[gifexportpath,filesep,'t2map-',tag,'.gif'],'DelayTime',delay_time,'LoopCount',inf);
    else
        imwrite(rot90(image),t2cmap,[gifexportpath,filesep,'t2map-',tag,'.gif'],'WriteMode','append','DelayTime',delay_time);
    end
end
        

% Export the M0 maps to GIF

for idx = 1:dimz
    
    % determine a convenient scale to display M0 maps (same as in the app)
    m0scale = round(2*mean(nonzeros(squeeze(m0map(:,:,idx)))));
    if isnan(m0scale) m0scale = 100; end
    
    % automatic grayscale mapping is used for the gif export
    % the m0map therefore needs to be mapped onto the range of [0 255]
    image = uint8(round((255/m0scale)*resizem(squeeze(m0map(:,:,idx)),[numrows numcols])));
    
    if isfield(parameters, 'PHASE_ORIENTATION')
        if parameters.PHASE_ORIENTATION
            image = rot90(image,-1);
        end
    end
    
    if idx == 1
        imwrite(rot90(image),m0cmap,[gifexportpath,filesep,'m0map-',tag,'.gif'],'DelayTime',delay_time,'LoopCount',inf);
    else
        imwrite(rot90(image),m0cmap,[gifexportpath,filesep,'m0map-',tag,'.gif'],'WriteMode','append','DelayTime',delay_time);
    end
end
         

% Rescale r2 map from rsquare..1 range to 0..1 
r2map = r2map - rsquare;
r2map(r2map<0) = 0;
r2map = r2map*(1/(1-rsquare));

% Export the R2 maps to GIF
for idx = 1:dimz
    
    % scale R-square map from 0 - 100
    r2scale = 100;

    image = uint8(round((255/r2scale)*resizem(squeeze(100*r2map(:,:,idx)),[numrows numcols])));
    
    if isfield(parameters, 'PHASE_ORIENTATION')
        if parameters.PHASE_ORIENTATION
            image = rot90(image,-1);
        end
    end
    
    if idx == 1
        imwrite(rot90(image),r2cmap,[gifexportpath,filesep,'r2map-',tag,'.gif'],'DelayTime',delay_time,'LoopCount',inf);
    else
        imwrite(rot90(image),r2cmap,[gifexportpath,filesep,'r2map-',tag,'.gif'],'WriteMode','append','DelayTime',delay_time);
    end
end



end                 