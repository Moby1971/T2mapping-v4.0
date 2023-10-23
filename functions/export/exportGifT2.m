function exportGifT2(app, gifexportpath)

%------------------------------------------------------------
% Exports T2 maps and M0 maps and R^2 maps to animated gif
% And water / fat maps if present
%
% Gustav Strijkers
% Amsterdam UMC
% g.j.strijkers@amsterdamumc.nl
% Oct 2023
%
%------------------------------------------------------------

% Input
t2map = app.t2map;
m0map = app.m0map;
r2map = app.r2map;
wmap = app.watermap;
fmap = app.fatmap;
tag = app.tag;
T2MapScale = app.T2ScaleEditField.Value;
t2cmap = app.t2cmap;
m0cmap = app.m0cmap;
r2cmap = app.r2cmap;
wcmap = app.watercmap;
fcmap = app.fatcmap;
aspect = app.AspectRatioViewField.Value;
parameters = app.parameters;
rsquare = app.Rsquare.Value;

% Dimensions
[dimx,dimy,dimz,dimd] = size(t2map);

% Increase the size of the matrix to make the exported images bigger
numrows = 2*dimx;
numcols = 2*round(dimy/aspect);

% Rescale r2 map from rsquare..1 range to 0..1
r2map = r2map - rsquare;
r2map(r2map<0) = 0;
r2map = r2map*(1/(1-rsquare));

% Animated gif delay time
if dimd > 1
    delay_time = 2/dimd;  % 2 seconds in total
else
    delay_time = 2/dimz;
end

if ~exist(gifexportpath, 'dir')
    mkdir(gifexportpath);
end


% ----------------------------------
% Export the maps to gifs
% ----------------------------------


if dimd > 1

    for slice = 1:dimz

        for dynamic = 1:dimd

            % T2
            T2image = uint8(round((255/T2MapScale)*imresize(squeeze(t2map(:,:,slice,dynamic)),[numrows numcols]))); %#ok<*RESZM>

            % M0
            M0image = squeeze(m0map(:,:,slice,dynamic));
            maxIm = max(M0image(:));
            window = maxIm;
            level = maxIm/2;
            M0image = (255/window)*(M0image - level + window/2);
            M0image(M0image<0) = 0;
            M0image(M0image>255) = 255;
            M0image = uint8(imresize(M0image,[numrows numcols]));

            % R2
            r2scale = 100;
            R2image = uint8(round((255/r2scale)*imresize(squeeze(100*r2map(:,:,slice,dynamic)),[numrows numcols])));

            % Water and fat
            if app.validWaterFatFlag
                Wimage = uint8(round((255/100)*imresize(squeeze(wmap(:,:,slice,dynamic)),[numrows numcols])));
                Fimage = uint8(round((255/100)*imresize(squeeze(fmap(:,:,slice,dynamic)),[numrows numcols])));
            end

            % Phase orientation
            if isfield(parameters, 'PHASE_ORIENTATION')
                if parameters.PHASE_ORIENTATION
                    T2image = rot90(T2image,-1);
                    M0image = rot90(M0image,-1);
                    R2image = rot90(R2image,-1);
                    if app.validWaterFatFlag
                        Wimage = rot90(Wimage,-1);
                        Fimage = rot90(Fimage,-1);
                    end
                end
            end

            % Export the gifs
            if dynamic == 1
                imwrite(rot90(T2image),t2cmap,strcat(gifexportpath,filesep,'t2map-slice',num2str(slice),'-',tag,'.gif'),'DelayTime',delay_time,'LoopCount',inf);
                imwrite(rot90(M0image),m0cmap,strcat(gifexportpath,filesep,'m0map-slice',num2str(slice),'-',tag,'.gif'),'DelayTime',delay_time,'LoopCount',inf);
                imwrite(rot90(R2image),r2cmap,strcat(gifexportpath,filesep,'r2map-slice',num2str(slice),'-',tag,'.gif'),'DelayTime',delay_time,'LoopCount',inf);
            else
                imwrite(rot90(T2image),t2cmap,strcat(gifexportpath,filesep,'t2map-slice',num2str(slice),'-',tag,'.gif'),'WriteMode','append','DelayTime',delay_time);
                imwrite(rot90(M0image),m0cmap,strcat(gifexportpath,filesep,'m0map-slice',num2str(slice),'-',tag,'.gif'),'WriteMode','append','DelayTime',delay_time);
                imwrite(rot90(R2image),r2cmap,strcat(gifexportpath,filesep,'r2map-slice',num2str(slice),'-',tag,'.gif'),'WriteMode','append','DelayTime',delay_time);
            end

            if app.validWaterFatFlag
                if dynamic == 1
                    imwrite(rot90(Wimage),wcmap,strcat(gifexportpath,filesep,'watermap-slice',num2str(slice),'-',tag,'.gif'),'DelayTime',delay_time,'LoopCount',inf);
                    imwrite(rot90(Fimage),fcmap,strcat(gifexportpath,filesep,'fatmap-slice',num2str(slice),'-',tag,'.gif'),'DelayTime',delay_time,'LoopCount',inf);
                else
                    imwrite(rot90(Wimage),wcmap,strcat(gifexportpath,filesep,'watermap-slice',num2str(slice),'-',tag,'.gif'),'WriteMode','append','DelayTime',delay_time);
                    imwrite(rot90(Fimage),fcmap,strcat(gifexportpath,filesep,'fatmap-slice',num2str(slice),'-',tag,'.gif'),'WriteMode','append','DelayTime',delay_time);
                end
            end

        end

    end

else

    % Animated gif per slice
    for slice = 1:dimz

        % T2
        T2image = uint8(round((255/T2MapScale)*imresize(squeeze(t2map(:,:,slice,1)),[numrows numcols])));

        % M0
        M0image = squeeze(m0map(:,:,slice,1));
        maxIm = max(M0image(:));
        window = maxIm;
        level = maxIm/2;
        M0image = (255/window)*(M0image - level + window/2);
        M0image(M0image<0) = 0;
        M0image(M0image>255) = 255;
        M0image = uint8(imresize(M0image,[numrows numcols]));

        % R2
        r2scale = 100;
        R2image = uint8(round((255/r2scale)*imresize(squeeze(100*r2map(:,:,slice,1)),[numrows numcols])));

        % Water and fat
        if app.validWaterFatFlag
            Wimage = uint8(round((255/100)*imresize(squeeze(wmap(:,:,slice,1)),[numrows numcols])));
            Fimage = uint8(round((255/100)*imresize(squeeze(fmap(:,:,slice,1)),[numrows numcols])));
        end

        % Phase orientation
        if isfield(parameters, 'PHASE_ORIENTATION')
            if parameters.PHASE_ORIENTATION
                T2image = rot90(T2image,-1);
                M0image = rot90(M0image,-1);
                R2image = rot90(R2image,-1);
                if app.validWaterFatFlag
                    Wimage = rot90(Wimage,-1);
                    Fimage = rot90(Fimage,-1);
                end
            end
        end

        % Export the gifs
        if slice == 1
            imwrite(rot90(T2image),t2cmap,strcat(gifexportpath,filesep,'t2map-',tag,'.gif'),'DelayTime',delay_time,'LoopCount',inf);
            imwrite(rot90(M0image),m0cmap,strcat(gifexportpath,filesep,'m0map-',tag,'.gif'),'DelayTime',delay_time,'LoopCount',inf);
            imwrite(rot90(R2image),r2cmap,strcat(gifexportpath,filesep,'r2map-',tag,'.gif'),'DelayTime',delay_time,'LoopCount',inf);
        else
            imwrite(rot90(T2image),t2cmap,strcat(gifexportpath,filesep,'t2map-',tag,'.gif'),'WriteMode','append','DelayTime',delay_time);
            imwrite(rot90(M0image),m0cmap,strcat(gifexportpath,filesep,'m0map-',tag,'.gif'),'WriteMode','append','DelayTime',delay_time);
            imwrite(rot90(R2image),r2cmap,strcat(gifexportpath,filesep,'r2map-',tag,'.gif'),'WriteMode','append','DelayTime',delay_time);
        end

        if app.validWaterFatFlag
            if slice == 1
                imwrite(rot90(Wimage),wcmap,strcat(gifexportpath,filesep,'watermap-',tag,'.gif'),'DelayTime',delay_time,'LoopCount',inf);
                imwrite(rot90(Fimage),fcmap,strcat(gifexportpath,filesep,'fatmap-',tag,'.gif'),'DelayTime',delay_time,'LoopCount',inf);
            else
                imwrite(rot90(Wimage),wcmap,strcat(gifexportpath,filesep,'watermap-',tag,'.gif'),'WriteMode','append','DelayTime',delay_time);
                imwrite(rot90(Fimage),fcmap,strcat(gifexportpath,filesep,'fatmap-',tag,'.gif'),'WriteMode','append','DelayTime',delay_time);
            end

        end

    end

end




end