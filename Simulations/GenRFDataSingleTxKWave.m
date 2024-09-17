clear
clc

% Load Functions
addpath(genpath('../k-Wave'));
addpath(genpath(pwd));

% Load Simulation Information Created by GenKWaveSimInfo.m
option = 2; % 1 for Breast CT; 2 for Breast MRI
switch option
    case 1
        siminfo_filename = 'sim_info/SimInfo_BreastCT.mat';
    case 2
        siminfo_filename = 'sim_info/SimInfo_BreastMRI.mat';
end
load(siminfo_filename);

% Loop Through All Elements
for tx_elmt_idx = 1:numElements

% Place Transmit Signal on Array 
src = struct(); % ParFor Requires you to Explicitly Create A Struct
src.p_mask = zeros(Nzi, Nxi);
src.p_mask(ind(tx_elmt_idx)) = 1;
src.p = tx_signal;
src.p_mode = 'dirichlet'; % Enforce pressure signal as boundary condition

% Run the Simulation for Transmit
sensor_data_unordered = kspaceFirstOrder2D(kgrid, medium, src, sensor, input_args{:});

% Reorder and Assemble Assemble Sensor Data 
order_msk = zeros(Nzi, Nxi);
[~, I] = sort(ind);
sensor_data = zeros(size(sensor_data_unordered));
sensor_data(I,:) = sensor_data_unordered;
rf_data = sensor_data';

% Save Full Synthetic Aperture Data Generated by k-Wave
filename = ['scratch/rf_data_tx_elem_', num2str(tx_elmt_idx), '.mat'];
save(filename, 'rf_data', 'siminfo_filename'); % File Has Been Saved
disp(['Data for TX element ', num2str(tx_elmt_idx), ' has been saved to file']);

end
