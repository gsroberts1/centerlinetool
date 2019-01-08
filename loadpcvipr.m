function [directory, nframes, res, fov, timeres, v, MAG, timeMIP,vMean] = loadpcvipr()
% Get and load input directory

directory = uigetdir;
tic

delimiter = ' ';

% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%[^\n\r]';

fid = fopen([directory '\pcvipr_header.txt'], 'r');%read header
if fid<0
    error('Could not open pcvipr_header.txt file.');
else 
    % Read columns of headerdata according to format string.
    dataArray = textscan(fid, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true,  'ReturnOnError', false);
    fclose(fid);

    % Convert string to num
    dataArray{1,2} = cellfun(@str2num,dataArray{1,2}(:),'UniformOutput', false);
    
    pcviprheader = cell2struct(dataArray{1,2}(:), dataArray{1,1}(:), 1)

    nframes = pcviprheader.frames;              % Number of reconstructed frames
    timeres = pcviprheader.timeres;             % Temporal resolution
    fov = (pcviprheader.fovx)/10 ;              % Field of view in cm
    res = pcviprheader.matrixx;                 % Number of pixels in row,col,slice (isotropic resolution)
    v = zeros(res,res,res,3,nframes, 'int16');  % Initial 4D flow matrix, three directions, 20 time frames
    disp('Loading data')

    for m = 0:nframes-1;% Looped reading of all velocity images

        fida1 = fopen([directory '/ph_' num2str(m,'%03i') '_vd_1.dat'], 'r');
        v(:,:,:,1,m+1) = reshape(fread(fida1,res^3,'short')',res,res,res);
        fclose(fida1);

        fida2 = fopen([directory '/ph_' num2str(m,'%03i') '_vd_2.dat'], 'r');
        v(:,:,:,2,m+1) = reshape(fread(fida2,res^3,'short')',res,res,res);
        fclose(fida2);

        fida3 = fopen([directory '/ph_' num2str(m,'%03i') '_vd_3.dat'], 'r');
        v(:,:,:,3,m+1) = reshape(fread(fida3,res^3,'short')',res,res,res);
        fclose(fida3);

        disp(['Completed reading frame ', num2str(m)])
    end
    v = single(v);
    disp('Reading Composite Data');
    MAG = load_dat(fullfile(directory,'MAG.dat'),[res res res]);
    vMean = single(zeros(res,res,res,3));
    vMean(:,:,:,1) = load_dat(fullfile(directory,'comp_vd_1.dat'),[res res res]);
    vMean(:,:,:,2) = load_dat(fullfile(directory,'comp_vd_2.dat'),[res res res]);
    vMean(:,:,:,3) = load_dat(fullfile(directory,'comp_vd_3.dat'),[res res res]);

    % Calculate a Polynomial
    [poly_fitx,poly_fity, poly_fitz] = background_phase_correction(MAG,vMean(:,:,:,1),vMean(:,:,:,2),vMean(:,:,:,3));


    disp('Correcting Data with Polynomial');
    xrange = single( linspace(-1,1,size(MAG,1)));
    yrange = single( linspace(-1,1,size(MAG,2)));
    zrange = single( linspace(-1,1,size(MAG,3)));
    [y,x,z] = meshgrid( yrange,xrange,zrange);

    disp('   Vx');
    back = evaluate_poly(x,y,z,poly_fitx);
    back = single(back);
    vMean(:,:,:,1) = vMean(:,:,:,1) - back;
    for m = 0 : nframes - 1
        v(:,:,:,1,m+1) = v(:,:,:,1,m+1) - back;
    end

    disp('   Vy');
    back = evaluate_poly(x,y,z,poly_fity);
    back = single(back);
    vMean(:,:,:,2) = vMean(:,:,:,2) - back;
    for m = 0 : nframes - 1
        v(:,:,:,2,m+1) = v(:,:,:,2,m+1) - back;
    end

    disp('   Vz');
    back = evaluate_poly(x,y,z,poly_fitz);
    back = single(back);
    vMean(:,:,:,3) = vMean(:,:,:,3) - back;
    for m = 0 : nframes - 1
        v(:,:,:,3,m+1) = v(:,:,:,3,m+1) - back;
    end

    % This section will be used in the future but is in the validation process
    % % Calculate Angiogram after the fact
    disp('Recalc Angio');
    timeMIP = calc_angio(MAG, vMean, pcviprheader.VENC);

    % clearvars -except directory nframes res fov timeres v MAG timeMIP

    disp('Load Data finished');
    toc
end 
return


function v = load_dat(name, res)

[fid,errmsg]= fopen(name,'r');
if fid < 0
    disp(['Error Opening Data : ',errmsg]);
end

v = single(reshape(fread(fid,'short'),res));
fclose(fid);

return


function angio = calc_angio(MAG,vMean, Venc)

angio = zeros(size(MAG),'single');
Vmag = sqrt( sum( vMean.^2,4));
idx = find( Vmag > Venc);
Vmag(idx) = Venc;

angio = 32000*MAG.*sin( pi/2*Vmag / Venc);






