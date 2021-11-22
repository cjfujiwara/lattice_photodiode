
% Load the data
pd_data = load('phototiode.mat');
data2=pd_data.data2;
data=pd_data.data;

figure(1)
clf
co=get(gca,'colororder');
set(gcf,'color','w');
subplot(121);
plot(data(:,1),data(:,2),'o','markerfacecolor',co(1,:));
hold on
plot(data(:,1),data(:,3),'o','markerfacecolor',co(2,:));
xlabel('power (mW)');
ylabel('photodiode (mV)');

legend({'feedback','monitor'},'location','northwest');

xlim([0 300]);
ylim([0 1200]);

subplot(122);
plot(data2(:,1),data2(:,2),'o','markerfacecolor',co(1,:));
hold on
plot(data2(:,1),data2(:,3),'o','markerfacecolor',co(3,:));
plot(data2(:,1),data2(:,4),'o','markerfacecolor',co(2,:));

xlabel('power (mW)');
ylabel('photodiode (mV)');

xlim([0 300]);
ylim([0 1200]);

R_PDA20CS2 = mean([0.5701681 0.5870871]);
R_PDA36A2 = mean([0.404 0.329]);

pvec = linspace(0,1,10);

V2 = 1.32/228*pvec*R_PDA20CS2*1.51E3;
V1 = 1.1/228*pvec*R_PDA20CS2*1.51E3;
V3 = 1.03/288 *pvec* R_PDA36A2*1.51E3;

m1 = 1.1/228*R_PDA20CS2*1.51E3;
m2 = 1.32/228*R_PDA20CS2*4.75E3;
m3 = 1.03/288* R_PDA36A2*1.51E3;

% figure
plot(pvec*1000,1000*V1,'-','color',co(1,:))
plot(pvec*1000,1000*V2,'-','color',co(3,:))
plot(pvec*1000,1000*V3,'-','color',co(2,:))

legend({'fb1 0dB','fb2 0dB','monitor 0dB'},'location','northwest');
