%% Import and Parse Data
% Read Data Table
T = readtable('Blood_drift_data.xlsx',...
              'DataRange', 3,...
              'VariableNamesRange', '2:2',...
              'VariableUnitsRange','1:1');

% Get locations of datasets
dims = T.Properties.VariableUnits;
ind_techs = find(~cellfun(@isempty, dims));

techs = cell(1, length(ind_techs)); % Create structures to store data
% Parse data
for i=1:length(techs)
    % Get time and concentration data
    raw_time = T{:,ind_techs(i)};
    raw_conc = T{:,ind_techs(i)+1};
    
    % Find number of numeric entries
    N_time = length(raw_time(~isnan(raw_time)));
    N_conc = length(raw_time(~isnan(raw_conc)));
    N = min(N_time, N_conc);
    
    % Save data
    techs{i} = struct;
    techs{i}.name = dims{ind_techs(i)};
    techs{i}.time = raw_time(1:N);
    techs{i}.conc = raw_conc(1:N);
end

%% Fit and Save Results
% File to save results
file2save = 'fits.xlsx';

% Set smoothing parameters manually
pvals = [0.9999,0.999,0.9999];
for i=1:length(techs)
    % Data to fit
    time = techs{i}.time;
    conc = techs{i}.conc;
    
    % Fit a spline structure to the data
    pp = csaps(time,conc,pvals(i));
    yfit = fnval(pp,time);
    
    % Compute noise levels
    noise = conc-yfit;
    rmsd_val = sqrt(noise'*noise/length(noise));
    SNR = (yfit'*yfit)/(noise'*noise);
    
    % Plot resulting fit
    fig1 = figure;
    hold on
    plot(time,yfit,'r-','LineWidth',2)
    plot(time,conc,'k.','MarkerSize',10)
    xlim(time([1,end]))
    ylabel('Concentration (\mu M)')
    xlabel('Time (h)')
    
    set(gca,'box','off','TickDir','out','FontWeight','bold','FontSize',20,'FontName','Times')

    saveas(fig1, ['snr_fits_',num2str(i)],'svg')
    
    % Plot the residual distribution
    fig2 = figure;
    histogram(noise,1e2)
    xlabel('Concentration (\mu M)')
    
    set(gca,'box','off','TickDir','out','FontWeight','bold','FontSize',16)
    fprintf('Set %d, SNR = %.3e\n',i,SNR)
    fprintf('Set %d, RMSD = %.3e\n',i,rmsd_val)
    
    saveas(fig2, ['residuals_',num2str(i)],'svg')
    
    % Save fits
    T2save = table;
    T2save.Time = time;
    T2save.Concentration = conc;
    T2save.Fit = yfit;
    writetable(T2save, file2save, 'Sheet', techs{i}.name)
end