%% X Lattice Calibrations

pdX = struct;

% Wavelength [nm]
lambda = 1054;

% Photodiode 1 Settings
pdX(1).rSample   = 1.32/228;       % [P1/P0] Sampling percentage
pdX(1).Gain_dB   = 20;             % [dB] Gain
pdX(1).Offset_V  = 0.020;          % [V] measured PD offset voltage
pdX(1).PDName    = 'PDA20CS2';     % Photodiode part name     

% Photodiode 2 Settings
pdX(2).rSample   = 1.1/228;        % [P1/P0] Sampling percentage
pdX(2).Gain_dB   = 0;              % [dB] Gain
pdX(2).Offset_V  = 0.030;          % [V] measured PD offset voltage
pdX(2).PDName    = 'PDA20CS2';     % Photodiode part name     

% Monitor Photodiode
pdX(3).rSample   = 1.03/228;       % [P1/P0] Sampling percentage
pdX(3).Gain_dB   = 0;              % [dB] Gain
pdX(3).Offset_V  = 0.040;          % [V] measured PD offset voltage
pdX(3).PDName    = 'PDA36A';       % Photodiode part name     

[hF,P2V_pd1,P2V_pd2,P2V_pdm]=photodiode_P2V(pdX,lambda);
