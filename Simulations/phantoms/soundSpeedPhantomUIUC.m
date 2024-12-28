function [C, c_bkgnd] = soundSpeedPhantom2D(Yi, Zi, X, id)
%SOUNDSPEEDPHANTOM Outputs Sound Speed Phantom
% [C, c_bkgnd] = soundSpeedPhantom(Xi, Yi, option)
% INPUTS:
%   Yi, Zi -- meshgrid of points over which sound speed is defined
%   X -- vertically slice 3D MRI image here. 0 is typically furthest away
%   from the patient (background only).
%   id -- id of UCIC breast phantom
% OUTPUTS:
%   C -- sound speed map on grid [m/s]
%   c_bkgnd -- background sound speed [m/s]

%% Load in the MRI image
% Set dimensions
switch id
    case 7
        Nx = 616; Ny = 485; Nz = 719;
    case 35
        Nx = 284; Ny = 411; Nz = 722;
    case 47
       Nx = 495; Ny = 615; Nz = 752;
end

% Load in optical and acoustic phantoms
fid = fopen(sprintf('./phantoms/uiuc/%d.DAT', id), 'r');
phan = fread(fid, 'uint8=>uint8'); phan = reshape(phan, [Nx, Ny, Nz]);
fclose(fid);

% Select a slice of MRI image
slice = squeeze(phan(X, :, :));
c = double(slice);

%% Convert MRI image into speed map
% Convert slice into sound speed map
% Using values provided here: https://pmc.ncbi.nlm.nih.gov/articles/PMC5282404/table/t001/
c_bkgnd = single(1500); % 0 - background (water)
c_tissue = single(1515); % 2 - fibroglandular tissue
c_fat = single(1470); % 3 - fat
c_skin = single(1650); % 4 - skin
c_vessel = single(1584); % 5 0 - blood vessel

% Create Sound Speed Image [m/s]
c(c==0) = c_bkgnd;
c(c==2) = c_tissue;
c(c==3) = c_fat;
c(c==4) = c_skin;
c(c==5) = c_vessel;

%% Interpolate speed map onto Input Meshgrid
% Create Input Meshgrid
dy = 0.0004; dz = dy; % Grid Spacing [m]
y = ((-(Ny-1)/2):((Ny-1)/2))*dy; 
z = ((-(Nz-1)/2):((Nz-1)/2))*dz;
[Y, Z] = meshgrid(z,y);

% Put Sound Speed Map on Input Meshgrid
R = sqrt(Yi.^2 + Zi.^2); 
rotAngle = 2.85*pi; % Angle [radians] to Rotate the Breast 
T = atan2(Zi, Yi) - rotAngle; % Apply Rotation
C = interp2(Y, Z, c, R.*cos(T), R.*sin(T), 'linear', c_bkgnd);
end