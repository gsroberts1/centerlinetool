function txt = myupdatefcn_RI(empt,event_obj)
% Customizes text of data tips
count = 1;
global RI_vol branchList plot_flowWaveform flowPulsatile_vol res

pos = get(event_obj,'Position');
pos  = floor(pos);
x = pos(2); y = pos(1); z = pos(3);

blah = find(branchList(:,1) == x);
blah2 = find(branchList(blah,2) ==y);
blah3 = find(branchList(blah(blah2),3) ==z);
index = blah(blah2(blah3));
x2 = branchList(index-2:index+2,1);
y2 = branchList(index-2:index+2,2);
z2 = branchList(index-2:index+2,3);

value = RI_vol(x,y,z);
for i = 1:2*count+1
    average(i) = RI_vol(x2(i),y2(i),z2(i));
end

txt = {['Resistance Index: ',sprintf('%0.3f',value), sprintf('\n'), ...
    'Average: ',sprintf('%0.3f',mean(average))]};

if  plot_flowWaveform == 1
    index = sub2ind([res res res],x,y,z);
    subplot(2,1,2)
    plot(5:5:100,smooth(flowPulsatile_vol(index,:)),'-w','LineWidth',5)
    set(gca,'Color','k','YColor','w','XColor','w','LineWidth',3)
    xlabel('Cardiac Time (%)','FontSize',16); ylabel('Flow (mL/s)','FontSize',16); xlim([0 105])
    subplot(2,1,1)
end

end