function export_gif_t2d(gifexportpath,t2map,m0map,r2map,tag,T2MapScale,t2cmap,m0cmap,r2cmap,aspect,parameters,rsquare)

%------------------------------------------------------------
% Exports T2 maps and M0 maps and R^2 maps to animated gif
%
%
% Gustav Strijkers
% Amsterdam UMC
% g.j.strijkers@amsterdamumc.nl
% 10/09/2022
%
%------------------------------------------------------------



% Dimensions
[dimx,dimy,dimz,dimd] = size(t2map);

% Increase the size of the matrix to make the exported images bigger
numrows = 2*dimx;
numcols = 2*round(dimy/aspect);

% Animated gif delay time
if dimd > 1
    delay_time = 2/dimd;  % 2 seconds in total
else
    delay_time = 2/dimz;
end


% ----------------------------------
% Export the T2 maps to gifs
% ----------------------------------


if dimd > 1

    for slice = 1:dimz

        for dynamic = 1:dimd

            image = uint8(round((255/T2MapScale)*resizem(squeeze(t2map(:,:,slice,dynamic)),[numrows numcols])));

            if isfield(parameters, 'PHASE_ORIENTATION')
                if parameters.PHASE_ORIENTATION
                    image = rot90(image,-1);
                end
            end

            if dynamic == 1
                imwrite(rot90(image),t2cmap,[gifexportpath,filesep,'t2map-slice',num2str(slice),'-',tag,'.gif'],'DelayTime',delay_time,'LoopCount',inf);
            else
                imwrite(rot90(image),t2cmap,[gifexportpath,filesep,'t2map-slice',num2str(slice),'-',tag,'.gif'],'WriteMode','append','DelayTime',delay_time);
            end
        end

    end

else

    % Animated gif per slice
    for slice = 1:dimz

        image = uint8(round((255/T2MapScale)*resizem(squeeze(t2map(:,:,slice,1)),[numrows numcols])));

        if isfield(parameters, 'PHASE_ORIENTATION')
            if parameters.PHASE_ORIENTATION
                image = rot90(image,-1);
            end
        end

        if slice == 1
            imwrite(rot90(image),t2cmap,[gifexportpath,filesep,'t2map-',tag,'.gif'],'DelayTime',delay_time,'LoopCount',inf);
        else
            imwrite(rot90(image),t2cmap,[gifexportpath,filesep,'t2map-',tag,'.gif'],'WriteMode','append','DelayTime',delay_time);
        end
    end

end





% ----------------------------------
% Export the M0 maps to GIF
% ----------------------------------


if dimd > 1

    % Animated gif of dynamics
    for slice = 1:dimz

        for dynamic = 1:dimd

            % determine a convenient scale to display M0 maps (same as in the app)
            m0scale = round(2*mean(nonzeros(squeeze(m0map(:,:,slice,dynamic)))));
            if isnan(m0scale) m0scale = 100; end

            % automatic grayscale mapping is used for the gif export
            % the m0map therefore needs to be mapped onto the range of [0 255]
            image = uint8(round((255/m0scale)*resizem(squeeze(m0map(:,:,slice,dynamic)),[numrows numcols])));

            if isfield(parameters, 'PHASE_ORIENTATION')
                if parameters.PHASE_ORIENTATION
                    image = rot90(image,-1);
                end
            end

            if dynamic == 1
                imwrite(rot90(image),m0cmap,[gifexportpath,filesep,'m0map-slice',num2str(slice),'-',tag,'.gif'],'DelayTime',delay_time,'LoopCount',inf);
            else
                imwrite(rot90(image),m0cmap,[gifexportpath,filesep,'m0map-slice',num2str(slice),'-',tag,'.gif'],'WriteMode','append','DelayTime',delay_time);
            end

        end

    end

else

    % Animated gif of slices
    for slice = 1:dimz

        % determine a convenient scale to display M0 maps (same as in the app)
        m0scale = round(2*mean(nonzeros(squeeze(m0map(:,:,slice)))));
        if isnan(m0scale) m0scale = 100; end

        % automatic grayscale mapping is used for the gif export
        % the m0map therefore needs to be mapped onto the range of [0 255]
        image = uint8(round((255/m0scale)*resizem(squeeze(m0map(:,:,slice)),[numrows numcols])));

        if isfield(parameters, 'PHASE_ORIENTATION')
            if parameters.PHASE_ORIENTATION
                image = rot90(image,-1);
            end
        end

        if slice == 1
            imwrite(rot90(image),m0cmap,[gifexportpath,filesep,'m0map-',tag,'.gif'],'DelayTime',delay_time,'LoopCount',inf);
        else
            imwrite(rot90(image),m0cmap,[gifexportpath,filesep,'m0map-',tag,'.gif'],'WriteMode','append','DelayTime',delay_time);
        end

    end

end


% ----------------------------------
% Export the R^2 maps to GIF
% -----------------------------------


% Rescale r2 map from rsquare..1 range to 0..1
r2map = r2map - rsquare;
r2map(r2map<0) = 0;
r2map = r2map*(1/(1-rsquare));

if dimd > 1
    
    % Animated gif of dynamics
    for slice = 1:dimz

        for dynamic = 1:dimd

            % scale R-square map from 0 - 100
            r2scale = 100;

            image = uint8(round((255/r2scale)*resizem(squeeze(100*r2map(:,:,slice,dynamic)),[numrows numcols])));

            if isfield(parameters, 'PHASE_ORIENTATION')
                if parameters.PHASE_ORIENTATION
                    image = rot90(image,-1);
                end
            end

            if dynamic == 1
                imwrite(rot90(image),r2cmap,[gifexportpath,filesep,'r2map-slice',num2str(slice),'-',tag,'.gif'],'DelayTime',delay_time,'LoopCount',inf);
            else
                imwrite(rot90(image),r2cmap,[gifexportpath,filesep,'r2map-slice',num2str(slice),'-',tag,'.gif'],'WriteMode','append','DelayTime',delay_time);
            end

        end

    end

else

    % Animated gif of slices
    for slice = 1:dimz

        % scale R-square map from 0 - 100
        r2scale = 100;

        image = uint8(round((255/r2scale)*resizem(squeeze(100*r2map(:,:,slice)),[numrows numcols])));

        if isfield(parameters, 'PHASE_ORIENTATION')
            if parameters.PHASE_ORIENTATION
                image = rot90(image,-1);
            end
        end

        if slice == 1
            imwrite(rot90(image),r2cmap,[gifexportpath,filesep,'r2map-',tag,'.gif'],'DelayTime',delay_time,'LoopCount',inf);
        else
            imwrite(rot90(image),r2cmap,[gifexportpath,filesep,'r2map-',tag,'.gif'],'WriteMode','append','DelayTime',delay_time);
        end

    end

end


end