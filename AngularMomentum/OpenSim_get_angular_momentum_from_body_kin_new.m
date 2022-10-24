function [whole_body_L,data_out,headers,time,bodymass] = OpenSim_get_angular_momentum_from_body_kin_new(model_path,BodyKin)
% OPENSIM_GET_ANGULAR_MOMENTUM Computes the angular momentum for each
% segment based on a OpenSim model and his kinematics (based on paper Herr
% et al. 2008, Control of angular momentum during walking)
%
%   Input Arguments:
%       -1. model_path => path to the musculoskeletal model
%       -2. ik_filepath => path to the file with the kinematics
%       -3. results_path => path to the results
%
%   Output Arguments:
%       -1. whole_body_L => whole body angular momentum (x,y,z)
%       -2. data_out => angular momentum of each segment( x,y,z)
%       -3. headers => headers of the data out
%       -4. time => time array
%       -5. bodymass => total body mass (kg)
%
%   Information:
%       -L(i)= (COM(i)-COM_bodies) x  (mass(i) * (COM_dot(i)-COM_dot_bodies))+I*w
%               - i=> segment
%               - COM(i)=> center of mass of the segment
%               - COM_bodies => whole body center of mass
%               - mass(i)=> mass of the segment
%               - I=> inertia tensor of the segment
%               - w=> angular velocity of the segment

% load the OpenSim libraries
import org.opensim.modeling.*;
Pos = BodyKin.Pos;
Vel = BodyKin.Vel;
colheaders = BodyKin.header;

time=Pos(:,1);

% get the OpenSim Model
osimModel=Model(model_path);
bodies=osimModel.getBodySet();
nbodies=bodies.getSize();
bodymass = 0;

% get the COM info
index_COM=find(strcmp(colheaders,'center_of_mass_X'));
COM=Pos(:,index_COM:index_COM+2);
COM_dot=Vel(:,index_COM:index_COM+2);

% loop over each segment to compute the angular momentum
counter=1;
[rows, ~]=size(Pos);
Angular_momentum_body=zeros(rows,nbodies*3);
whole_body_L=zeros(rows,3);
headers=cell(1,nbodies*3);

for i=0:nbodies-1
    % get the body information
    mass=bodies.get(i).getMass();
    name=char(bodies.get(i).getName());
    headers{counter*3-2}=[name '_Lx'];
    headers{counter*3-1}=[name '_Ly'];
    headers{counter*3}=[name '_Lz'];

    % get the position and velocity info
    index_d_segment=find(strcmp(colheaders,[name '_X']));
    Pos_segm=Pos(:,index_d_segment:index_d_segment+2);
    Pos_dot_segm=Vel(:,index_d_segment:index_d_segment+2);

    % get the angular velocity info
    O_segm=Pos(:,index_d_segment+3:index_d_segment+5);
    O_dot_segm=Vel(:,index_d_segment+3:index_d_segment+5)*pi/180; %deg -> rad

    % get the inertia tensor
    I_osim_Mom = bodies.get(i).getInertia().getMoments;
    I=zeros(3,3);
    I(1,1)=I_osim_Mom.get(0);
    I(2,2)=I_osim_Mom.get(1);
    I(3,3)=I_osim_Mom.get(2);

    % compute the angular momentum
    for t=1:length(time)
        % express inertia tensor in world coordinate system
        T_Body = transform(O_segm(t,1),...  %gives the orientation of the body
            O_segm(t,2),...  %with respect to the global frame,
            O_segm(t,3));    %i.e., T_(local|glob
        I_world = T_Body'*I*T_Body;
        Angular_momentum_body(t,counter*3-2:counter*3) = cross((Pos_segm(t,:) - COM(t,:)),(mass*(Pos_dot_segm(t,:) - COM_dot(t,:)))) + (I_world * O_dot_segm(t,:)')';
    end

    % get the whole body angular momentum
    whole_body_L(:,1:3)=whole_body_L+Angular_momentum_body(:,counter*3-2:counter*3);

    % Calculate total body mass
    bodymass = bodymass + mass;

    % loop variables
    counter=counter+1;
end

headers{counter*3-2}='whole_body_Lx';
headers{counter*3-1}='whole_body_Ly';
headers{counter*3}='whole_body_Lz';
data_out=[Angular_momentum_body whole_body_L];

%% Helper function %%
    function R = transform(Rx,Ry,Rz)
        %Compute transformation matrix for x-y'-z" intrinsic Euler rotations
        %(the OpenSim convention)
        R11=cosd(Ry)*cosd(Rz);
        R12=-cosd(Ry)*sind(Rz);
        R13=sind(Ry);
        R21=cosd(Rx)*sind(Rz)+sind(Rx)*sind(Ry)*cosd(Rz);
        R22=cosd(Rx)*cosd(Rz)-sind(Rx)*sind(Ry)*sind(Rz);
        R23=-sind(Rx)*cosd(Ry);
        R31=sind(Rx)*sind(Rz)-cosd(Rx)*sind(Ry)*cosd(Rz);
        R32=sind(Rx)*cosd(Rz)+cosd(Rx)*sind(Ry)*sind(Rz);
        R33=cosd(Rx)*cosd(Ry);

        R=[R11 R12 R13;...
            R21 R22 R23;...
            R31 R32 R33];
    end
end