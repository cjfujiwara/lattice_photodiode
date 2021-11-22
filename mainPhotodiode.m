
%% X Lattice Calibrations


% Optical Properties
optX = struct;
optX.lambda     = 1054;
optX.doEr       = 1;
optX.ErPerW     = 276;
optX.Adwin0     = -9.8;

% Photodiode Properties
pdX = struct;

% Photodiode 1 Settings
pdX(1).rSample   = .830/134;       % [P1/P0] Sampling percentage
pdX(1).Gain_dB   = 20;             % [dB] Gain
pdX(1).Offset_V  = 0.0083;          % [V] measured PD offset voltage
pdX(1).PDName    = 'PDA20CS2';     % Photodiode part name    
pdX(1).Label     = 'feedback1';

% Photodiode 2 Settings
pdX(2).rSample   = 0.636/134;        % [P1/P0] Sampling percentage
% pdX(2).rSample   = 0.85/134;        % [P1/P0] Sampling percentage

pdX(2).Gain_dB   = 0;              % [dB] Gain
pdX(2).Offset_V  = 0.0132;          % [V] measured PD offset voltage
pdX(2).PDName    = 'PDA20CS2';     % Photodiode part name     
pdX(2).Label     = 'feedback2';

% Monitor Photodiode
pdX(3).rSample   = 1.03/228;       % [P1/P0] Sampling percentage
pdX(3).Gain_dB   = 0;              % [dB] Gain
pdX(3).Offset_V  = 0.000;          % [V] measured PD offset voltage
pdX(3).PDName    = 'PDA36A';       % Photodiode part name     
pdX(3).Label     = 'monitor';

% Convert power into voltage
[pdOut_X,pdSum_X] = photodiode_P2V(pdX,optX);

% Adwin voltage to power and Er
photodiode_adwin(pdSum_X,optX);

x_lattice_datavstheory;

