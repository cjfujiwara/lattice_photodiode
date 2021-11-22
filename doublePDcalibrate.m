function doublePDcalibrate(P,Vtot)

myfit = fittype('(x*m1 + b1).*(x<xC) + (x*m2 + xC*m1 + b1 - xC*m2).*(x>=xC)',...
    'independent','x','coefficients',{'m1','b1','m2','xC'});
fitopt = fitoptions(myfit);


fitopt.StartPoint = [57 0 4 .181];


% Do the fit
fout = fit(P,Vtot,myfit,fitopt);

% Process output
xC = fout.xC;
m1 = fout.m1;
m2 = fout.m2;
b1 = fout.b1;
b2 = fout.xC*fout.m1 + fout.b1 - fout.xC*fout.m2;

fitStr = ['$V(P) = P\cdot' num2str(round(m1,4)) '~\mathrm{V/W} + ' ...
    num2str(round(b1,4)) '~\mathrm{V}~(<' num2str(round(xC,4)) '~\mathrm{W})$' ...
    newline ...
    '$V(P) = P\cdot' num2str(round(m2,4)) '~\mathrm{V/W} + ' ...
    num2str(round(b2,4)) '~\mathrm{V}~(>' num2str(round(xC,4)) '~\mathrm{W})$'];

% Make simple fit function
fitfunc = @(x) (x*m1+b1).*(x<xC) + (x*m2+b2).*(x>=xC);


x = linspace(0,max(P),1000);
hF = figure;
hF.Color='w';
hF.Position = [100 100 600 300];
plot(x,fitfunc(x),'r-','linewidth',2)
hold on
pT=plot(P,Vtot,'ko','markerfacecolor','k','markersize',8);
hold on
xlabel('power (W)');
ylabel('voltage (V)');
set(gca,'Xgrid','on','ygrid','on','box','on',...
    'linewidth',1,'fontsize',12);
ylim([-.05 23]);

legend(pT,fitStr,'interpreter','latex');
end

