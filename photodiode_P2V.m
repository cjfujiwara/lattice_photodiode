function [hF,P2V_pd1,P2V_pd2,P2V_pdm]=photodiode_P2V(pd,lambda)


%% User Settings

% Photodiode 1 Settings
r1      = pd(1).rSample;        % [P1/P0] Sampling percentage
G_dB_1  = pd(1).Gain_dB;        % [dB] Gain
V1_0    = pd(1).Offset_V;       % [V] measured PD offset voltage

% Photodiode 2 Settings
r2      = pd(2).rSample;        % [P1/P0] Sampling percentage
G_dB_2  = pd(2).Gain_dB;        % [dB] Gain
V2_0    = pd(2).Offset_V;       % [V] measured PD offset voltage

% Photodiode 1 Settings
rm      = pd(3).rSample;        % [P1/P0] Sampling percentage
G_dB_m  = pd(3).Gain_dB;        % [dB] Gain
Vm_0    = pd(3).Offset_V;       % [V] measured PD offset voltage

% Adwin offset level
% This is the voltage that you will be using from the Adwin to offset
% the PD levels into the summer. Should be around -10V (don't go to the
% limits so you have some wiggle room in fine tuning)
V0_adwin = -9.8;

% Lattice Calibration
doErCalib = 0;

ErPerW = 276;

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

%% Photodiode settings and Functions

% Photodiode 1
r1      = r1;                     % Sampling percentage
R1      = R_PDA20CS2_func(lambda);      % Responsivity
G_dB_1  = G_dB_1;                           % Gain in dB
G1      = G_PDA20CS2(...
    G_PDA20CS2(:,1)==G_dB_1,2);         % Gain in V/A;
P2V_pd1 = @(P) P*r1*R1*G1 + V1_0;       % Power to Voltage

% Descriptor String
s1=['$V_1 = R(\lambda) \times G_1 \times P r_1 $' ...
    newline ...
    '$R(' num2str(lambda) '~\mathrm{nm}) = ' ...
    num2str(round(R1,3)) '~\mathrm{A/W}$' ...
    newline ...
    '$G_1 = ' num2str(G1,'%.2e') '~\mathrm{V/A}~(' num2str(G_dB_1) '~\mathrm{dB})$' ...
    newline ...
    '$r_1 = ' num2str(round(100*r1,3)) ' \%$' ...
    newline ...
    '$\mathrm{offset} = ' num2str(round(1e3*V1_0,2)) '~\mathrm{mV}$'];

% Photodiode 2
r2      = r2;
R2      = R_PDA20CS2_func(lambda);   % Responsivity
G_dB_2  = G_dB_2;                    % Gain in dB
G2      = G_PDA20CS2(...
    G_PDA20CS2(:,1)==G_dB_2,2); % Gain in V/A;
P2V_pd2 = @(P) P*r2*R2*G2 + V2_0 ;

% Descriptor String
s2=['$V_2 = R(\lambda) \times G_2 \times P r_2 $' ...
    newline ...
    '$R(' num2str(lambda) '~\mathrm{nm}) = ' ...
    num2str(round(R2,3)) '~\mathrm{A/W}$' ...
    newline ...
    '$G_2 = ' num2str(G2,'%.2e') '~\mathrm{V/A}~(' num2str(G_dB_2) '~\mathrm{dB})$' ...
    newline ...
    '$r_2 = ' num2str(round(100*r2,3)) ' \%$' ...
    newline ...
    '$\mathrm{offset} = ' num2str(round(1e3*V2_0,2)) '~\mathrm{mV}$'];

% Monitor PD
rm      = rm;
Rm      = R_PDA36A2_func(lambda);   % Responsivity
G_dB_m  = G_dB_m;                    % Gain in dB
Gm      = G_PDA36A2(...
    G_PDA36A2(:,1)==G_dB_m,2); % Gain in V/A;
P2V_pdm = @(P) P*rm*Rm*Gm + Vm_0;

% Descriptor String
sm=['$V_m = R(\lambda) \times G_m \times P r_m $' ...
    newline ...
    '$R(' num2str(lambda) '~\mathrm{nm}) = ' ...
    num2str(round(Rm,3)) '~\mathrm{A/W}$' ...
    newline ...
    '$G_m = ' num2str(Gm,'%.2e') '~\mathrm{V/A}~(' num2str(G_dB_m) '~\mathrm{dB})$' ...
    newline ...
    '$r_2 = ' num2str(round(100*rm,3)) ' \%$' ...
    newline ...
    '$\mathrm{offset} = ' num2str(round(1e3*Vm_0,2)) '~\mathrm{mV}$'];


%% Lattice depth calibration (optional)

doErCalib = 1;
Er_per_W = 276;

%% Calibration using atoms
% 
% % Lattice calirbartion Er/W
% Er_per_W=350; 
% Er_per_W=276;
% 
% % Lattice Calibration Er/V
% % adwin voltage to lattice recoils
% Er_per_V=150; 
% 
% V_per_W=Er_per_W/Er_per_V; % Watts per volt
% 
% % Sample percentage
% bs=0.4E-2;
% 
% % R(A/W)*G(V/A)*1*pow(W)
% % Vy = R_1054*G_0dB*1*bs;

%% Fitting the data

Pvec = linspace(0,4,1e3);

% PD1 Voltage
V1           = P2V_pd1(Pvec);
V1(V1>10)   = 10;
i1          = find(V1 == 10,1) - 1;
P1_limit    = Pvec(i1);

V1_fit  = polyfit(Pvec(1:(i1-5)),V1(1:(i1-5)),1);
foo1    = @(P) V1_fit(1)*P+V1_fit(2); 


% PD2 Voltage
V2       = P2V_pd2(Pvec);
V2(V2>10) = 10;
i2          = find(V2 == 10,1) - 1;
P2_limit    = Pvec(i2);

V2_fit  = polyfit(Pvec(1:(i2-5)),V2(1:(i2-5)),1);
foo2    = @(P) V2_fit(1)*P+V2_fit(2); 

% Total Voltage
Vtot = V1 + V2;

ia = min([i1 i2]);
ib = max([i1 i2]);

Vtot_fit1 =  polyfit(Pvec(1:ia),Vtot(1:ia),1);
Vtot_fit2 =  polyfit(Pvec((ia+5):(ib-5)),Vtot((ia+5):(ib-5)),1);

foot1 = @(P) Vtot_fit1(1)*P+Vtot_fit1(2);
foot2 = @(P) Vtot_fit2(1)*P+Vtot_fit2(2);

% Monitor Phototiode
Vm           = P2V_pdm(Pvec);
Vm(Vm>10)   = 10;
im          = find(Vm == 10,1) - 1;
if isempty(im); im = length(Pvec); end
Pm_limit    = Pvec(im);

Vm_fit  = polyfit(Pvec(1:(im-5)),Vm(1:(im-5)),1);
foom    = @(P) Vm_fit(1)*P+Vm_fit(2); 

%% Monitor Photodiode plot

hFm = figure(9);
clf
co=get(gca,'colororder');
hFm.Position=[100 500 300 300];
set(gcf,'color','w')

pm=plot(Pvec*1e3,Vm,'-','color',co(3,:),'linewidth',3);
hold on
pmf = plot(Pvec*1e3,foom(Pvec),':','linewidth',2,'color','k');
xlabel('power (mW)');
ylabel('voltage (V)');
xlim([0 1e3*3]);
ylim([0 11]);
set(gca,'Xgrid','on','ygrid','on','box','on','linewidth',1,'fontname','times','fontsize',10);
text(0.04,.96,sm,'interpreter','latex','verticalalignment','top',...
    'units','normalized','fontsize',10);
legend([pm pmf],...
    {'$V_\mathrm{m}$',...
    ['$' num2str(round(Vm_fit(1),3)) '~\mathrm{mV/mW},~', ...
    num2str(round(1e3*Vm_fit(2),3)) '~\mathrm{mV}$']},...
    'location','southeast','interpreter','latex');
%% Plot It
% Figure
hF=figure(10);
clf
co=get(gca,'colororder');
hF.Position=[100 100 1200 300];
set(gcf,'color','w')

% PD1 Plot
subplot(131);
p1=plot(Pvec*1e3,V1,'-','color',co(1,:),'linewidth',3);
hold on
p1f = plot(Pvec*1e3,foo1(Pvec),':','linewidth',2,'color','k');
xlabel('power (mW)');
ylabel('voltage (V)');
legend([p1 p1f],...
    {'$V_\mathrm{1}$',...
    ['$' num2str(round(V1_fit(1),3)) '~\mathrm{mV/mW},~', ...
    num2str(round(1e3*V1_fit(2),3)) '~\mathrm{mV}$']},...
    'location','southeast','interpreter','latex');

xlim([0 1e3*P1_limit*1.1]);
ylim([0 11]);
set(gca,'Xgrid','on','ygrid','on','box','on','linewidth',1,'fontname','times','fontsize',10);
text(0.04,.96,s1,'interpreter','latex','verticalalignment','top',...
    'units','normalized','fontsize',10);

% PD2 Plot
subplot(132);
p2=plot(Pvec*1e3,V2,'-','color',co(2,:),'linewidth',3);
hold on
p2f=plot(Pvec*1e3,foo2(Pvec),':','linewidth',2,'color','k');

xlabel('power (mW)');
ylabel('voltage (V)');
legend([p2 p2f],...
    {'$V_\mathrm{2}$',...
    ['$' num2str(round(V2_fit(1),3)) '~\mathrm{mV/mW},~', ...
    num2str(round(1e3*V2_fit(2),3)) '~\mathrm{mV}$']},...
    'location','southeast','interpreter','latex');
xlim([0 1e3*P2_limit*1.1]);
ylim([0 11]);
set(gca,'Xgrid','on','ygrid','on','box','on','linewidth',1,'fontname','times','fontsize',10);
text(0.04,.96,s2,'interpreter','latex','verticalalignment','top',...
    'units','normalized','fontsize',10);

% Sum
subplot(133);
pt=plot(Pvec*1e3,Vtot,'k-','linewidth',2);
hold on
ptf1=plot(Pvec(1:i1)*1e3,foot1(Pvec(1:i1)),':','linewidth',2,'color','g');
ptf2=plot(Pvec(i1+5:i2)*1e3,foot2(Pvec(i1+5:i2)),':','linewidth',2,'color','magenta');

ylim([0 21]);

xlabel('power (mW)');
ylabel('voltage (V)');
legend([pt,ptf1,ptf2],...
    {'$V_\mathrm{tot}$',
    ['$' num2str(round(Vtot_fit1(1),4)) '~\mathrm{mV/mW},~', ...
    num2str(round(Vtot_fit1(2),4)) '~\mathrm{V}$'],
    ['$' num2str(round(Vtot_fit2(1),4)) '~\mathrm{mV/mW},~', ...
    num2str(round(Vtot_fit2(2),4)) '~\mathrm{V}$']},...
    'location','southeast','interpreter','latex');

set(gca,'Xgrid','on','ygrid','on','box','on','linewidth',1,'fontname','times','fontsize',10);


end

