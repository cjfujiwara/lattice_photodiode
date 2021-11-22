function doublePDcalibrate(P,Vtot,opts)

myfit = fittype('(x/m1 + b1).*(x<xC) + (x/m2 + xC/m1 + b1 - xC/m2).*(x>=xC)',...
    'independent','x','coefficients',{'m1','b1','m2','xC'});
fitopt = fitoptions(myfit);


fitopt.StartPoint = [50 0 5 181];


% Do the fit
fout = fit(P,Vtot,myfit,fitopt);

% Process output
xC = fout.xC;
m1 = fout.m1;
m2 = fout.m2;
b1 = fout.b1;
b2 = fout.xC/fout.m1 + fout.b1 - fout.xC/fout.m2;

fitStr = ['$P']

% Make simple fit function
fitfunc = @(x) (x/m1+b1).*(x<xC) + (x/m2+b2).*(x>=xC);


x = linspace(0,max(P),1000);
hF = figure;
hF.Color='w';
hF.Position = [100 100 600 300];
plot(P,Vtot,'ko');
hold on
plot(x,fitfunc(x),'r-','linewidth',2)
xlabel('power (mw)');
ylabel('voltage (mV)');
set(gca,'Xgrid','on','ygrid','on','box','on',...
    'linewidth',1,'fontname','times','fontsize',10);


end

