function [pd,pdSum]=photodiode_P2V(pd,opt)


%% User Settings

lambda = opt.lambda;

% Photodiode 1 Settings
r1      = pd(1).rSample;        % [P1/P0] Sampling percentage
G_dB_1  = pd(1).Gain_dB;        % [dB] Gain
V1_0    = pd(1).Offset_V;       % [V] measured PD offset voltage
name1   = pd(1).PDName;

% Photodiode 2 Settings
r2      = pd(2).rSample;        % [P1/P0] Sampling percentage
G_dB_2  = pd(2).Gain_dB;        % [dB] Gain
V2_0    = pd(2).Offset_V;       % [V] measured PD offset voltage
name2   = pd(2).PDName;

% Photodiode 1 Settings
rm      = pd(3).rSample;        % [P1/P0] Sampling percentage
G_dB_m  = pd(3).Gain_dB;        % [dB] Gain
Vm_0    = pd(3).Offset_V;       % [V] measured PD offset voltage
name3   = pd(3).PDName;

%% PDA20CS2 Responsivity and Gain

% Responsitivity from ThorLabs
R_PDA20CS2=[...
    1030	0.5462463;
    1040	0.5564173;
    1050	0.5701681;
    1060	0.5870871;
    1070	0.6155493;
    1080	0.6241807;
    1090	0.6383239];

% Interpolant function for determining responsivity
R_PDA20CS2_func = @(lambda) interp1(R_PDA20CS2(:,1),R_PDA20CS2(:,2),lambda);

% Matrix of gain (dB) versus gain (V/A)
G_PDA20CS2 = [
    0 1.51e3;
    10 4.75e3;
    20 1.5e4;
    30 4.75e4;
    40 1.51e5;
    50 4.75e3;
    60 1.5e6;
    70 4.75e6];

%% PDA36A2 Responsivity and Gain    

% Responsitivity from ThorLabs
R_PDA36A2=[...
    1030	0.532;
    1040	0.473;
    1050	0.404;
    1060	0.329;
    1070	0.264;
    1080	0.216];

% Interpolant function for determining responsivity
R_PDA36A2_func = @(lambda) interp1(R_PDA36A2(:,1),R_PDA36A2(:,2),lambda);

% Matrix of gain (dB) versus gain (V/A)
G_PDA36A2 = [
    0 1.51e3;
    10 4.75e3;
    20 1.5e4;
    30 4.75e4;
    40 1.51e5;
    50 4.75e3;
    60 1.5e6;
    70 4.75e6];

%% Do it
descStrs = {};

for kk = 1 : length(pd)
    r = pd(kk).rSample;
    G_dB = pd(kk).Gain_dB;   
    offset = pd(kk).Offset_V;
    
    switch pd(kk).PDName
        case 'PDA20CS2'
             % Responsivity    
            R = R_PDA20CS2_func(lambda);   
            % Gain in V/A;
            G = G_PDA20CS2(G_PDA20CS2(:,1)==G_dB,2);     
        case 'PDA36A2'
            % Responsivity 
            R = R_PDA36A2_func(lambda);       
            % Gain in V/A;
            G = G_PDA36A2(G_PDA36A2(:,1)==G_dB,2);     
        case 'PDA36A'
            % Responsivity 
            R = R_PDA36A2_func(lambda);       
            % Gain in V/A;
            G = G_PDA36A2(G_PDA36A2(:,1)==G_dB,2);     
    end

    P10 = (10-offset)/(r*R*G);    
    m = R*G*r;
    b = offset;
    
    % Slope and y intercept
    pd(kk).slope_mW_per_mV = m;
    pd(kk).intercept_W = b;    
    
    % Power 2 voltage
    pd(kk).power2voltage = @(P) (P*r*R*G + offset).*(P < P10) + 10.*(P >= P10);
    
    % Power that leads to 10V
    pd(kk).power_W_10V = P10;
    
    % Descriptor String
    s=[pd(kk).Label newline ...
        '$V = R(\lambda) \times G \times P r $' ...
        newline ...
        '$R(' num2str(lambda) '~\mathrm{nm}) = ' ...
        num2str(round(R,3)) '~\mathrm{A/W}$' ...
        newline ...
        '$G = ' num2str(G,'%.2e') '~\mathrm{V/A}~(' num2str(G_dB) '~\mathrm{dB})$' ...
        newline ...
        '$r = ' num2str(round(100*r,3)) ' \%$' ...
        newline ...
        '$\mathrm{offset} = ' num2str(round(1e3*offset,2)) '~\mathrm{mV}$'];
    descStrs{kk} = s;
end

%% Calculate Sum Voltage

[~,iH] = max([pd(1).power_W_10V pd(2).power_W_10V]);
[~,iL] = min([pd(1).power_W_10V pd(2).power_W_10V]);

pdSum = struct;
pdSum.power2voltage = @(P) pd(1).power2voltage(P) + pd(2).power2voltage(P);

% Low power slope and intercet
pdSum.low_slope_mW_per_mV = pd(1).slope_mW_per_mV + pd(2).slope_mW_per_mV;
pdSum.low_intercept_W = pd(1).intercept_W + pd(2).intercept_W;
pdSum.low_power2voltage = @(P) pdSum.low_slope_mW_per_mV*P + pdSum.low_intercept_W;

% High power slope and intercet
pdSum.high_slope_mW_per_mV = pd(iH).slope_mW_per_mV;
pdSum.high_intercept_W = pd(iH).intercept_W + 10;
pdSum.high_power2voltage = @(P) pdSum.high_slope_mW_per_mV*P + pdSum.high_intercept_W;

pdSum.power_W_10V = pd(iL).power_W_10V;
pdSum.power_W_20V = pd(iH).power_W_10V;

%% Plot It
P = linspace(0,5,1e4);
P2 = linspace(0,5,10);

% Figure
hF=figure;
clf
co=get(gca,'colororder');
hF.Position=[100 100 1400 400];
set(gcf,'color','w')

% PD1 Plot
subplot(141);
p1=plot(P*1e3,pd(1).power2voltage(P),'-','color',co(1,:),'linewidth',3);
hold on
p1f = plot(P2*1e3,pd(1).slope_mW_per_mV*P2+pd(1).intercept_W,'--','linewidth',2,'color','k');
xlabel('power (mW)');
ylabel('voltage (V)');
legend([p1 p1f],...
    {['$V$ ' pd(1).Label],...
    ['$' num2str(round(pd(1).slope_mW_per_mV,3)) '~\mathrm{mV/mW},~', ...
    num2str(round(1e3*pd(1).intercept_W,3)) '~\mathrm{mV}$']},...
    'location','southeast','interpreter','latex');
xlim([0 1e3*pd(1).power_W_10V*1.1]);
ylim([0 11]);
set(gca,'Xgrid','on','ygrid','on','box','on','linewidth',1,'fontname','times','fontsize',10);
text(0.04,.98,descStrs{1},'interpreter','latex','verticalalignment','top',...
    'units','normalized','fontsize',10);


% PD2 Plot
subplot(142);
p2=plot(P*1e3,pd(2).power2voltage(P),'-','color',co(2,:),'linewidth',3);
hold on
p2f = plot(P2*1e3,pd(2).slope_mW_per_mV*P2+pd(2).intercept_W,'--','linewidth',2,'color','k');
xlabel('power (mW)');
ylabel('voltage (V)');
legend([p2 p2f],...
    {['$V$ ' pd(2).Label],...
    ['$' num2str(round(pd(2).slope_mW_per_mV,3)) '~\mathrm{mV/mW},~', ...
    num2str(round(1e3*pd(2).intercept_W,3)) '~\mathrm{mV}$']},...
    'location','southeast','interpreter','latex');
xlim([0 1e3*pd(2).power_W_10V*1.1]);
ylim([0 11]);
set(gca,'Xgrid','on','ygrid','on','box','on','linewidth',1,'fontname','times','fontsize',10);
text(0.04,.98,descStrs{2},'interpreter','latex','verticalalignment','top',...
    'units','normalized','fontsize',10);

% Sum
subplot(143);
pt = plot(P*1e3,pdSum.power2voltage(P),'k-','linewidth',2);
hold on
ptf1=plot(P2*1e3,pdSum.low_power2voltage(P2),'--','linewidth',2,'color','g');
ptf2=plot(P2*1e3,pdSum.high_power2voltage(P2),'--','linewidth',2,'color','magenta');

xlim([0 1e3*pdSum.power_W_20V*1.1]);
ylim([0 21]);

xlabel('power (mW)');
ylabel('voltage (V)');
legend([pt,ptf1,ptf2],...
    {'$V_\mathrm{tot}$',
    ['$' num2str(round(pdSum.low_slope_mW_per_mV,4)) '~\mathrm{mV/mW},~', ...
    num2str(round(pdSum.low_intercept_W,4)) '~\mathrm{V}$'],
    ['$' num2str(round(pdSum.high_slope_mW_per_mV,4)) '~\mathrm{mV/mW},~', ...
    num2str(round(pdSum.high_intercept_W,4)) '~\mathrm{V}$']},...
    'location','southeast','interpreter','latex');

set(gca,'Xgrid','on','ygrid','on','box','on','linewidth',1,'fontname','times','fontsize',10);

% Monitor
subplot(144);
p2=plot(P*1e3,pd(3).power2voltage(P),'-','color',co(3,:),'linewidth',3);
hold on
p2f = plot(P2*1e3,pd(3).slope_mW_per_mV*P2+pd(3).intercept_W,'--','linewidth',2,'color','k');
xlabel('power (mW)');
ylabel('voltage (V)');
legend([p2 p2f],...
    {['$V$ ' pd(3).Label],...
    ['$' num2str(round(pd(3).slope_mW_per_mV,3)) '~\mathrm{mV/mW},~', ...
    num2str(round(1e3*pd(3).intercept_W,3)) '~\mathrm{mV}$']},...
    'location','southeast','interpreter','latex');
xlim([0 1e3*pd(3).power_W_10V*1.1]);
ylim([0 11]);
set(gca,'Xgrid','on','ygrid','on','box','on','linewidth',1,'fontname','times','fontsize',10);
text(0.04,.98,descStrs{3},'interpreter','latex','verticalalignment','top',...
    'units','normalized','fontsize',10);

end

