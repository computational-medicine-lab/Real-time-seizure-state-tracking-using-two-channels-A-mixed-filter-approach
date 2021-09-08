aaa=figure('units','normalized','outerposition',[0 0 0.97 0.3]);
% subplot(2,1,1);
ax=gca;ax.Position=[0.08,0.29,0.9,0.67];
line(TS.Time,TS.Z,'Color','k','LineWidth',1);
ax1 = gca;
ax1.YColor = 'k';
yticks([-1 0 1])
ylabel(ax1,{'NCF'},'Color','k')
set(gca,'FontSize',25)
set(gca,'FontWeight','Bold')
set(gca,'LineWidth',3)
xlabel('Time (Sec)')
hold on;
xlim([min(TS.Time), max(TS.Time)]);
ax1_pos = ax1.Position;
ax2 = axes('Position',ax1_pos,...
'XAxisLocation','top',...
'YAxisLocation','right',...
'Color','none');
tline=line(TS.Time,ones(length(TS.Time),1)); tline.Color(4)=0;
hold on;
tempylim=ylim;
samples=1:length(TS.Z); ccc=samples(TS.N==1);
a1=scatter(TS.Time(ccc),tempylim(2).*ones(length(ccc),1),50.*ones(length(ccc),1),'filled', 'MarkerFaceColor',[0 .7 .7]);
seizuretime=TS.Time(find(TS.Labels==1));
ttime=[seizuretime, fliplr(seizuretime)];
inbetween=[tempylim(1).*ones(1,length(seizuretime)),fliplr(tempylim(2).*ones(1,length(seizuretime)))];
h=fill(ttime,inbetween,[0.5,0.5,0.5]);
set(h, 'edgecolor','none')
set(h,'facealpha',.3)
set(gca,'FontSize',25)
set(gca,'FontWeight','Bold')
set(gca,'LineWidth',3)
legend([a1],{'Binary Feature'},'Location','northwest','FontName','Times New Roman','FontWeight','Bold')
xlim([min(TS.Time), max(TS.Time)]);
xticks([]); yticks([]);

aaa=figure('units','normalized','outerposition',[0 0 0.97 0.3]);
% subplot(2,1,1);
ax=gca;ax.Position=[0.08,0.29,0.85,0.67];
ccc=[]; samples=[];
yticks([-1 0 1 2])
samples=1:length(Z); ccc=samples(N==1);
% ax=gca;ax.Position=[0.08,0.12,0.84,0.39];
l1=line(time,Z,'Color','k','LineWidth',1);
xlim([min(time) max(time)])
ax1 = gca;
xlabel(ax1,'Time (Sec)','Color','k','FontName','Times New Roman')
ylabel(ax1,{'Normalized' ,'Continuous', 'Feature (Unitless)'},'Color','k','FontName','Times New Roman')
set(gca,'FontSize',25)
set(gca,'FontWeight','Bold')
set(gca,'LineWidth',3)
ax1.YColor = 'k';
ax1_pos = ax1.Position;
ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');
l2=line(time,MES,'Parent',ax2,'Color','r','LineWidth',1);
ax2.YColor = 'r';
ylabel(ax2,{'Estimated Seizure', 'State (Unitless)'},'Color','r','FontName','Times New Roman')
set(gca,'FontSize',25)
set(gca,'FontWeight','Bold')
set(gca,'LineWidth',3)
xticks([])
xlim([min(time) max(time)])
hold on;
tempylim=ylim;
seizuretime=time(find(Data.labels==1));
ttime=[seizuretime, fliplr(seizuretime)];
inbetween=[tempylim(1).*ones(1,length(seizuretime)),fliplr(tempylim(2).*ones(1,length(seizuretime)))];
h=fill(ttime,inbetween,[0.5,0.5,0.5]);
set(h, 'edgecolor','none')
set(h,'facealpha',.3)
l3=scatter(time(ccc),tempylim(2).*ones(length(ccc),1),50.*ones(length(ccc),1),'filled', 'MarkerFaceColor',[0 .7 .7],'LineWidth',1);
% text('FontWeight','bold','FontSize',25,'Rotation',90,...
% 'String','Normalized Continuous Feature (Unitless)',...
% 'Position',[-160 -19 0]);
% text('FontWeight','bold','FontSize',40,'String','B)',...
% 'FontName','Times New Roman','Position',[-340 20 0]);
% text('FontWeight','bold','FontSize',40,'String','A)',...
% 'FontName','Times New Roman','Position',[-340 68 0]);
legend([l3],{'Binary Feature'},'Location','northeast','FontName','Times New Roman','FontWeight','Bold')