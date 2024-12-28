clear
clc

% Figure out which simulation was run
filename = 'scratch/rf_data_tx_elem_1.mat'; 
load(filename,'siminfo_filename'); 
if strcmp(siminfo_filename, 'sim_info/SimInfo_BreastCT.mat')
    option = 1; 
    suffix = 'CT';
elseif strcmp(siminfo_filename, 'sim_info/SimInfo_BreastMRI.mat')
    option = 2;
    suffix = 'MRI';
elseif strcmp(siminfo_filename, 'sim_info/SimInfo_BreastUIUC.mat')
    option = 3;
    suffix = 'UIUC';
end

% Load Simulation Information Created by GenKWaveSimInfo.m
load(siminfo_filename)

% Assemble RF Data From Individual Tx Beams Into Full Synthetic Aperture
addpath(genpath('../k-Wave'));
dwnsmp = 5; % Subsample in Time
full_dataset = zeros(numel(kgrid.t_array(1:dwnsmp:end)), ...
    numElements, numElements, 'single');
for tx_elmt_idx = 1:numElements
    filename = ['scratch/rf_data_tx_elem_', num2str(tx_elmt_idx), '.mat'];
    load(filename, 'rf_data'); % Load RF Data From This Transmit Beam
    full_dataset(:, :, tx_elmt_idx) = single(rf_data(1:dwnsmp:end,:)); % Assemble
    disp(['Assembled ' num2str(tx_elmt_idx), ' Transmit Beam']);
end
time = kgrid.t_array(1:dwnsmp:end)+t_offset; 
transducerPositionsXY = [x_circ; z_circ];
xi_orig = xi; yi_orig = zi; 
clearvars -except option time full_dataset transducerPositionsXY xi_orig yi_orig C atten; 

% Save Full Synthetic Aperture Data
save(stringf('datasets/kWave_Breast%s.mat', suffix), '-v7.3', ...
    'time', 'full_dataset', 'transducerPositionsXY', ...
    'xi_orig', 'yi_orig', 'C', 'atten');
end