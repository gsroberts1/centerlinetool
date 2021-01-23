function saving_data(timeres, nframes, directory, handles, area, diam, flowPerHeartCycle,  flowPulsatile, ...
    maxVel, wss_simple, wss_simple_avg, meanVel, PI )
%SAVING_DATA: Saves flow data from GUI to .dat and .xls files
val = get(handles.save_name, 'Value');
str = get(handles.save_name, 'String');
str = cellstr(str);
savename = str{val};

while ischar(savename) == 0
    error('Need to input name for vessel');
end
saving_location = strcat(directory,'\',savename,'_data');
mkdir(saving_location);
cd(saving_location);

val = get(handles.savedata, 'Value');
str = get(handles.savedata, 'String');
switch str{val}
    case 'Time-averaged flow'
        store = 1;
    case 'Time-resolved flow'
        store = 2;
    case 'Everything'
        store = 3;
end

% get save locations
        save_start = str2double(get(handles.start_save,'String'));
        save_end = str2double(get(handles.end_save,'String'));
        if isnan(save_end)
            save_end = length(area);
        else
            save_end = save_end;
        end

switch store
    case 1

        % save time-averaged
        col_header = ({'Point along Vessel', 'Area (cm^2)', 'Diameter (cm)', 'Mean Velocity (cm/s)', 'Max Velocity (cm/s)',...
           'Mean Volumetric Flow Rate (mL/s)', 'WSS (Pa)','Pulsatility Index'});
        time_avg = vertcat(col_header,num2cell(real(horzcat(linspace(1,length(area),length(area))',area',diam',meanVel',...
            maxVel',flowPerHeartCycle',wss_simple_avg',PI'))));
        save('averaged.mat','time_avg');
        fprintf('Time-averaged flow data saved to ')
        disp(saving_location)
        fprintf(' as averaged.mat\n')
        
        save_xls = vertcat(time_avg(1,:),time_avg(save_start+1:save_end+1,:));
        xlswrite([directory '\Summary.xls'],save_xls,[savename '_time_averaged']);
    case 2
         % save time-resolved
         spaces = repmat({''},1,nframes-1);
        col_header2 = ({'Cardiac Time (ms)'});
        col_header3 = horzcat({'Point along Vessel','Flow (mL/s)'},spaces);
        col_header2 = horzcat(col_header2, num2cell(real(timeres/1000*linspace(1,nframes,nframes))));
        time_resolve = vertcat(col_header2, col_header3, num2cell(real(horzcat(linspace(1,length(area),length(area))',flowPulsatile))));
        save('resolved.mat','time_resolve');
        
        
        save_xls = vertcat(time_resolve(1:2,:),time_resolve(save_start+2:save_end+2,:));
        xlswrite([directory '\Summary.xls'],save_xls,[savename '_time_resolved']);
        
        fprintf('Time-resolved flow data saved to ')
        disp(saving_location)
        fprintf(' as resolved.mat\n')
        fprintf('Time-resolved flow data saved to ')
        disp(saving_location)
        fprintf(' as resolved.mat\n')
    case 3
        
        % save time-averaged
        col_header = ({'Point along Vessel', 'Area (cm^2)', 'Diameter (cm)', 'Mean Velocity (cm/s)', 'Max Velocity (cm/s)',...
            'Mean Volumetric Flow Rate (mL/s)', 'WSS (Pa)','Pulsatility Index'});
        time_avg = vertcat(col_header,num2cell(real(horzcat(linspace(1,length(area),length(area))',area',diam',meanVel',...
            maxVel',flowPerHeartCycle',wss_simple_avg',PI'))));
        save('averaged.mat','time_avg');
        fprintf('Time-averaged flow data saved to ')
        disp(saving_location)
        fprintf(' as averaged.mat\n')
        
        save_xls = vertcat(time_avg(1,:),time_avg(save_start+1:save_end+1,:));
        xlswrite([directory '\Summary.xls'],save_xls,[savename '_time_averaged']);
        
        % save time-resolved
        spaces = repmat({''},1,nframes-1);
        col_header2 = ({'Cardiac Time (ms)'});
        col_header3 = horzcat({'Point along Vessel','Flow (mL/s)'},spaces);
        col_header2 = horzcat(col_header2, num2cell(real(timeres/1000*linspace(1,nframes,nframes))));
        time_resolve = vertcat(col_header2, col_header3, num2cell(real(horzcat(linspace(1,length(area),length(area))',flowPulsatile))));
        save('resolved.mat','time_resolve');
        
        
        save_xls = vertcat(time_resolve(1:2,:),time_resolve(save_start+2:save_end+2,:));
        xlswrite([directory '\Summary.xls'],save_xls,[savename '_time_resolved']);
        
        fprintf('Time-resolved flow data saved to ')
        disp(saving_location)
        fprintf(' as resolved.mat\n')

end

end

