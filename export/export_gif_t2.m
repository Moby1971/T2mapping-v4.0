function export_gif_t2(gifexportpath,t2map,m0map,tag,T2MapScale,t2cmap,aspect)

% Exports t2maps and m0maps to animated gif

[number_of_images,dimx,dimy] = size(t2map);

% increase the size of the matrix to make the exported images bigger

numrows = 2*dimx;
numcols = 2*round(dimy/aspect);

delay_time = 2/number_of_images;  % show all gifs in 2 seconds


% Export the T2 maps to gifs

for idx = 1:number_of_images
    
    % because the color maps are arrays of size 64
    % the t2map needs to be mapped onto the range of [0, 63] and cast in an
    % unsigned integer 8 for gif export
    image = uint8(round((63/T2MapScale)*resizem(squeeze(t2map(idx,:,:)),[numrows numcols])));
    
    if idx == 1
        imwrite(image,t2cmap,[gifexportpath,filesep,'t2map-',tag,'.gif'],'DelayTime',delay_time,'LoopCount',inf);
    else
        imwrite(image,t2cmap,[gifexportpath,filesep,'t2map-',tag,'.gif'],'WriteMode','append','DelayTime',delay_time);
    end
end
        

% Export the M0 maps to GIF

for idx = 1:number_of_images
    
    % determine a convenient scale to display M0 maps (same as in the app)
    m0scale = round(2*mean(nonzeros(squeeze(m0map(idx,:,:)))));
    if isnan(m0scale) m0scale = 100; end
    
    % automatic grayscale mapping is used for the gif export
    % the m0map therefore needs to be mapped onto the range of [0 255]
    image = uint8(round((255/m0scale)*resizem(squeeze(m0map(idx,:,:)),[numrows numcols])));
    
    if idx == 1
        imwrite(image,[gifexportpath,filesep,'m0map-',tag,'.gif'],'DelayTime',delay_time,'LoopCount',inf);
    else
        imwrite(image,[gifexportpath,filesep,'m0map-',tag,'.gif'],'WriteMode','append','DelayTime',delay_time);
    end
end
         


end                 