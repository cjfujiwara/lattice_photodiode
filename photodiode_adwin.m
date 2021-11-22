function photodiode_adwin(pdSum,opt)

Pmax = pdSum.power_W_20V;

%%
adwin_low_slope = pdSum.low_slope_mW_per_mV;
adwin_low_intercept = pdSum.low_intercept_W + opt.Adwin0;
adwin_low_power2voltage = @(P) adwin_low_slope*P + adwin_low_intercept;

adwin_high_slope = pdSum.high_slope_mW_per_mV;
adwin_high_intercept = pdSum.high_intercept_W + opt.Adwin0;
adwin_high_power2voltage = @(P) adwin_high_slope*P + adwin_high_intercept;

P = linspace(0,Pmax,1e4);
P2= linspace(0,Pmax,100);

hF = figure;
hF.Color = 'w';
hF.Position = [100 500 400 300];

p = plot(P,pdSum.power2voltage(P) + opt.Adwin0,'k-','linewidth',2);
ylim([-10 10]);
xlim([0 Pmax]);
set(gca,'Xgrid','on','ygrid','on','box','on','linewidth',1,'fontname','times','fontsize',10);
ylabel('voltage (V)');
xlabel('power (W)');
hold on

pf1 = plot(P2,adwin_low_power2voltage(P2),'--','linewidth',2,'color','g');
pf2 = plot(P2,adwin_high_power2voltage(P2),'--','linewidth',2,'color','magenta');

s1 = ['$V(P) = ' num2str(round(adwin_low_slope,3)) '~\mathrm{mV/mW}\times P + ' ...
    num2str(round(adwin_low_intercept,3)) '~\mathrm{V}$'];

s2 = ['$V(P) = ' num2str(round(adwin_high_slope,3)) '~\mathrm{mV/mW}\times P + ' ...
    num2str(round(adwin_high_intercept,3)) '~\mathrm{V}$'];

legend([p,pf1,pf2],{'$V~{\mathrm{adwin}}$',s1,s2},...
    'location','southeast','interpreter','latex');

sT = ['$V_0~\mathrm{adwin} = ' num2str(opt.Adwin0) '~\mathrm{V}$' ...
    newline ...
    '$P_c = ' num2str(round(pdSum.power_W_10V,3)) '~\mathrm{W}$'];
text(0.04,.98,sT,'interpreter','latex','verticalalignment','top',...
    'units','normalized','fontsize',10);

%% Lattice Depth
if opt.doEr
    ErPerW = opt.ErPerW;
    
    hF2 = figure;
    hF2.Color = 'w';
    hF2.Position = [500 500 400 300];

    p = plot(P*ErPerW,pdSum.power2voltage(P) + opt.Adwin0,'k-','linewidth',2);
    ylim([-10 10]);
    xlim([0 Pmax]*ErPerW);
    set(gca,'Xgrid','on','ygrid','on','box','on','linewidth',1,'fontname','times','fontsize',10);
    ylabel('voltage (V)');
    xlabel('lattice depth (Er)');
    hold on

    pf1 = plot(P2*ErPerW,adwin_low_power2voltage(P2),'--','linewidth',2,'color','g');
    pf2 = plot(P2*ErPerW,adwin_high_power2voltage(P2),'--','linewidth',2,'color','magenta');

    s1 = ['$V(U) = U/(' num2str(round(ErPerW/adwin_low_slope,3)) '~\mathrm{Er/V}) + ' ...
        num2str(round(adwin_low_intercept,3)) '~\mathrm{V}$'];

    s2 = ['$V(U) = U/(' num2str(round(ErPerW/adwin_high_slope,3)) '~\mathrm{Er/V}) + ' ...
        num2str(round(adwin_high_intercept,3)) '~\mathrm{V}$'];

    legend([p,pf1,pf2],{'$V~{\mathrm{adwin}}$',s1,s2},...
        'location','southeast','interpreter','latex');

    sT = ['$V_0~\mathrm{adwin} = ' num2str(opt.Adwin0) '~\mathrm{V}$' ...
        newline ...
        '$U_c = ' num2str(round(ErPerW*pdSum.power_W_10V,2)) '~\mathrm{Er}$'];
    text(0.04,.98,sT,'interpreter','latex','verticalalignment','top',...
        'units','normalized','fontsize',10);
    
end


end


