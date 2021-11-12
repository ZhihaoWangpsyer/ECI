%after eeglab2fieldtrip.m
load('D:\ECI_ALEX\eeg_preprocess_TP9TP10\code\theta2fieldtrip.mat');

alpha_High_diff=merged_High_diff;
alpha_High_diff.avg(:,201:250)=[];
alpha_High_diff.var(:,201:250)=[];
alpha_High_diff.dof(:,201:250)=[];
alpha_High_diff.time(1:50)=[];
alpha_High_diff.trial(:,:,201:250)=[];

alpha_Low_diff = alpha_High_diff;

for i_point=1:200
    for i_sub=1:61
        alpha_High_diff.trial(i_sub,19,i_point) = High_diff_Pz_alpha(i_sub,i_point);
        alpha_Low_diff.trial(i_sub,19,i_point) = Low_diff_Pz_alpha(i_sub,i_point);
    end
end

%% Statistics
% point-to-point statsitics(paired-t-tests)
cfg = [];
cfg.channel     = 'Pz';%channel of interest
cfg.statistic   = 'depsamplesT';%statistic method
%cfg.method = 'stats';
%cfg.statistic = 'paired-ttest'
cfg.method = 'montecarlo';% correction of multiple comparison by cluster-based permutation test if needed
cfg.alpha       = 0.01;
% correction method: cluster level
cfg.correctm    = 'cluster';
%cfg.correctm = 'no';
cfg.numrandomization = 2000;
%cfg.tail=1;

% design matrix
Nsub = 61;% number of subjects
cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];%factor
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];% # of subjects
cfg.ivar                = 1; %factor variable, the corresponding row; the row one
cfg.uvar                = 2;%unit variable(i.e., subjects)

% statistics
stat_interaction = ft_timelockstatistics(cfg, alpha_High_diff, alpha_Low_diff);


figure;
%draw pictures of T values
subplot(311); plot(stat_interaction.time, stat_interaction.stat); ylabel('t-value');
subplot(312); plot(stat_interaction.time, stat_interaction.prob); ylabel('prob');%draw pictures of P values(after corrected)
subplot(313); plot(stat_interaction.time, stat_interaction.mask); ylabel('significant');axis([0 0.8 0 2]);% draw significant timepoints(stat.mask)
        
%% 
load('D:\ECI_ALEX\eeg_preprocess_TP9TP10\code\Power1_30_detrend250divide.mat');
load('D:\ECI_ALEX\eeg_preprocess_TP9TP10\code\TF_times.mat');

P_sub = P_avg_sub(:,:,find(times==0):find(times==796),:,:);
%P_div = P_avg_divid(:,:,find(times==0):find(times==796),:,:);

%P_sub_delta = squeeze(mean(P_sub(:,1:3,:,:,:),2));
%P_sub_theta = squeeze(mean(P_sub(:,4:7,:,:,:),2));
P_sub_alpha = squeeze(mean(P_sub(:,8:12,:,:,:),2));
%P_sub_beita = squeeze(mean(P_sub(:,13:30,:,:,:),2));

%P_div_delta = squeeze(mean(P_div(:,1:3,:,:,:),2));
%P_div_theta = squeeze(mean(P_div(:,4:7,:,:,:),2));
%P_div_alpha = squeeze(mean(P_div(:,8:12,:,:,:),2));
%P_div_beita = squeeze(mean(P_div(:,13:30,:,:,:),2));
toi = times(find(times==0):find(times==796));

stat_alpha=squeeze(mean(P_sub_alpha(19,68:200,:,:),2));
stat_alpha_diff(:,1)=stat_alpha(:,2)-stat_alpha(:,1);%low_diff
stat_alpha_diff(:,2)=stat_alpha(:,4)-stat_alpha(:,3);%high_diff
stat_alpha_interaction = stat_alpha_diff(:,2)-stat_alpha_diff(:,1);

%time course
figure; %新出一个画板
hold on;%不覆盖画图
%set(gca,'YDir','reverse');%负数朝上
% xlim([-500 1000]);  %% define the region of X axis
% ylim([-15 10]); %% define the region of Y axis
axis([0 800 -1 1]);%define the region to display
plot(toi, mean(Low_diff_Pz_alpha,1),'-b'); % Low diff
plot(toi, mean(High_diff_Pz_alpha,1),'-r'); % Low diff
legend('Low','High'); %图例
%title('Group-level at Pz','fontsize',16); %% specify the figure name
xlabel('Latency (ms)','fontsize',16); %% name of X axis
ylabel('alpha power [pain - nopain]','fontsize',16);  %% name of Y axis

data = P_sub_alpha;a1=68;a2=200;
%topo plot
m=2;
%squeeze(mean(mean(data(:,1,:,a1:a2),1),4))
subplot(221); topoplot(squeeze(mean(mean(data(:,a1:a2,:,1),2),3)),EEG.chanlocs,'maplimits',[-m m]); 
subplot(222); topoplot(squeeze(mean(mean(data(:,a1:a2,:,2),2),3)),EEG.chanlocs,'maplimits',[-m m]); 
subplot(223); topoplot(squeeze(mean(mean(data(:,a1:a2,:,3),2),3)),EEG.chanlocs,'maplimits',[-m m]); 
subplot(224); topoplot(squeeze(mean(mean(data(:,a1:a2,:,4),2),3)),EEG.chanlocs,'maplimits',[-m m]); 

topo_diff_low = squeeze(mean(mean(data(:,a1:a2,:,2),2),3)) - squeeze(mean(mean(data(:,a1:a2,:,1),2),3));
topo_diff_high = squeeze(mean(mean(data(:,a1:a2,:,4),2),3)) - squeeze(mean(mean(data(:,a1:a2,:,3),2),3));
m=0.5
subplot(121);topoplot(topo_diff_low,EEG.chanlocs,'maplimits',[-m m]); 
subplot(122);topoplot(topo_diff_high,EEG.chanlocs,'maplimits',[-m m]); 