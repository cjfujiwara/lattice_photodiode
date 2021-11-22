% 2021/11/12
% [pdOut_X,pdSum_X] = photodiode_P2V(pdX,optX);

% power (mW), PD1(V),PD2(V), Monitor (V), PD1 + PD2
data = [3.7	0.03	0.003	0.008	0.033;
    11.3	0.85	0.08	0.03	0.93;
    23.2	1.72	0.14	0.064	1.86;
    49.9	3.67	0.29	0.14	3.96;
    87.3	6.39	0.49	0.244	6.88;
    132.5	9.67	0.76	0.374	10.43;
    92.7	6.82	0.54	0.261	7.36;
    63.8	4.68	0.37	0.179	5.05;
    180.9	10.89	1.04	0.511	11.93;
    232.6	10.89	1.33	0.66	12.22;
    348.9	10.89	1.99	0.995	12.88;
    478.7	10.89	2.73	1.363	13.62;
    674     10.89	3.82	1.928	14.71;
    1290	10.89	7.28	3.7	18.17;
    1540	10.89	8.68	4.41	19.57;
    1833	10.89	10.2	5.23	21.09;
    2070	10.89	10.85	5.95	21.74;
    1040	10.89	5.85	2.97	16.74;
    1979	10.89	10.72	5.61	21.61];

doublePDcalibrate(data(:,1),1e3*data(:,5));

P = linspace(0,4,1000);

hF = figure;
hF.Position(3:4) = [1400 400];
co = get(gca,'colororder');
clf
hF.Color = 'w';

subplot(141)
pD = plot(data(:,1),data(:,2),'o','markerfacecolor',co(1,:),...
    'linewidth',1,'markeredgecolor',co(1,:)*.5);
set(gca,'Xgrid','on','ygrid','on','box','on','linewidth',1,...
    'fontname','times','fontsize',10);
hold on
pT = plot(P*1e3,pdOut_X(1).power2voltage(P),'k--','linewidth',2);
xlim([0 2000]);
xlabel('input power (mW)');
ylabel('voltage (V)');

subplot(142)
pD = plot(data(:,1),data(:,3),'o','markerfacecolor',co(2,:),...
    'linewidth',1,'markeredgecolor',co(2,:)*.5);
set(gca,'Xgrid','on','ygrid','on','box','on','linewidth',1,...
    'fontname','times','fontsize',10);
hold on
pT = plot(P*1e3,pdOut_X(2).power2voltage(P),'k--','linewidth',2);
xlim([0 2000]);
xlabel('input power (mW)');
ylabel('voltage (V)');

subplot(143)
pD = plot(data(:,1),data(:,5),'o','markerfacecolor',co(4,:),...
    'linewidth',1,'markeredgecolor',co(4,:)*.5);
set(gca,'Xgrid','on','ygrid','on','box','on','linewidth',1,...
    'fontname','times','fontsize',10);
hold on
% pT = plot(P*1e3,pdS_X(2).power2voltage(P),'k--','linewidth',2);
xlim([0 2000]);
xlabel('input power (mW)');
ylabel('voltage (V)');

subplot(144)
pD = plot(data(:,1),data(:,4),'o','markerfacecolor',co(3,:),...
    'linewidth',1,'markeredgecolor',co(3,:)*.5);
set(gca,'Xgrid','on','ygrid','on','box','on','linewidth',1,...
    'fontname','times','fontsize',10);
hold on
pT = plot(P*1e3,pdOut_X(3).power2voltage(P),'k--','linewidth',2);
xlim([0 2000]);
xlabel('input power (mW)');
ylabel('voltage (V)');