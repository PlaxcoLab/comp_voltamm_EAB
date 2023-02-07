T = readtable('Blood_drift_data.xlsx', 'VariableNamingRule', 'modify');

times = cell(1,3);
Concs = cell(1,3);
times{1} = T.Time_h_;
Concs{1} = T.Concentration_uM_;
times{2} = T.Time_h__1;
Concs{2} = T.Concentration_uM__1;
times{3} = T.Time_h__2;
Concs{3} = T.Concentration_uM__2;
for i=1:3
    times{i} = times{i}(~isnan(times{i}));
    Concs{i} = Concs{i}(~isnan(Concs{i}));
end
Concs{2}(end) = [];
%%
pvals = [0.9999,0.999,0.9999];
for i=1:size(times,2)
    pp = csaps(times{i},Concs{i},pvals(i));
    yfit = fnval(pp,times{i});
    
    noise = Concs{i}-yfit;
    rmsd_val = sqrt(noise'*noise/length(noise));
    SNR = (yfit'*yfit)/(noise'*noise);
    
    fig1 = figure;
    hold on
    plot(times{i},yfit,'r-','LineWidth',2)
    plot(times{i},Concs{i},'k.','MarkerSize',10)
    xlim(times{i}([1,end]))
    ylabel('Concentration (\mu M)')
    xlabel('Time (h)')
    
    set(gca,'box','off','TickDir','out','FontWeight','bold','FontSize',20,'FontName','Times')

    saveas(fig1, ['snr_fits_',num2str(i)],'svg')
    
    
    fig2 = figure;
    histogram(noise,1e2)
    xlabel('Concentration (\mu M)')
    
    set(gca,'box','off','TickDir','out','FontWeight','bold','FontSize',16)
    fprintf('Set %d, SNR = %.3e\n',i,SNR)
    fprintf('Set %d, RMSD = %.3e\n',i,rmsd_val)
    
    saveas(fig2, ['residuals_',num2str(i)],'svg')
end