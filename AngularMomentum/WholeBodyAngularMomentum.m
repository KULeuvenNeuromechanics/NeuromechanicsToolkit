%% WholeBodyAngularMomentum.m
% Computes the whole body angular momentum based on a OpenSim model and
% its % kinematics (based on  Herr et al. 2008, Control of angular momentum
% during walking and Bishop et al., 2021 Science Advances)
%
% V1
% Original by Maarten Afschrift, VU/KU Leuven
% Wrote the functions OpenSim_BodyKinematics.m and
% OpenSim_get_angular_momentum_from_body_kin_new.m
% 
% V1.1
% Edited by Tom Buurke, UMCG/KU Leuven
% Corrected the original functions based on the code in Bishop et al., 2021
% Science Advances, Supplementary info.

%% Initiate
clear;
close all;
clc;

%% Settings
% Set model file, results directory and .mot file
model_file='subject1_mtpPin.osim';
results_dir=cd;
kinematics_file= 'example.mot';
% Set average velocity (m/s)
v = 0.8;

%% Run body kinematics
[body_kin] = OpenSim_BodyKinematics(model_file,results_dir,kinematics_file,[],'true');

%% Calculate whole body angular momentum
[whole_body_L,data_out,headers,time,body_mass] = OpenSim_get_angular_momentum_from_body_kin_new(model_file,body_kin);

%% Normalize whole body angular momentum
% Calculate average center of mass height
index_COM=find(strcmp(body_kin.header,'center_of_mass_Y'));
COM_height = mean(body_kin.Pos(:,index_COM));

% Normalize whole body angular momentum to mass, height and velocity
whole_body_L_norm = whole_body_L/(body_mass*COM_height*v);

%% Plot stuff
figure('Color','White');
hold on
plot(whole_body_L_norm(1:100,:),'LineWidth',2)
ylabel('Wholy body angular momentum (kg*m^2/s)')
xlabel('Gait cycle (%)')
set(gca,'YLim',[-.1 .1])
legend('Roll','Yaw','Pitch')

%% Save results to file for later use
save('AngularMomentumResults.mat');