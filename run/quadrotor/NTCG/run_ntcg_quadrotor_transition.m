% Script to run the ntcg model on the dubin (Initial and final transition)

clear;
clc;

% Adding the required paths
addpath(genpath('../../../data/'));
addpath(genpath('../../../dynamics/'));
addpath(genpath('../../../environments/'));
addpath(genpath('../../../integration/'));
addpath(genpath('../../../models/'));
addpath(genpath('../../../params/'));
addpath(genpath('../../../trajectory_optimization/'));
addpath(genpath('../../../tools/'));

filepath = '';
filename = 'quadrotor_data_1.mat';
load(strcat(filepath, filename));

nx = size(x{1}, 1);
nu = size(u{1}, 1);

% Generating the graph
[tg, ug] = generate_ntcg(x, u);

% Specify trajectory to be visualized. Can be varied from 1:50.
traj_n = 1;

% Flag to vary initial and goal positions for system.
%  If flag is set, random initial and final positions will be assigned,
%  else they will be extraced from trajectory data.
random_flag = 1;

%% Specify initial and final states based on random_flag
if random_flag
% Initial and final states assigned randomly
    x_start_query = [lrandom(5, 25);...
                     lrandom(5, 25);...
                     lrandom(5, 25);...
                     lrandom(-pi/6, pi/6);...
                     lrandom(-pi/6, pi/6);...
                     lrandom(-pi/6, pi/6);...
                     lrandom(-1,1); ...
                     lrandom(-1,1); ...
                     lrandom(-1,1);...
                     lrandom(-0.05,0.05);...
                     lrandom(-0.05,0.05);...
                     lrandom(-0.05,0.05)];

else
    x_start_query = x{traj_n}(:, 1);

end

x_goal_query = x_start_query;
x_goal_query(4:12) = zeros(9,1);

p = 2;

[min_distance_goal, min_distance_goal_ind, x_goal, trajectory_index] = ...
    query_state(x_goal_query, x, p);

[min_distance_start, min_distance_start_ind, x_start] = ...
    query_state_in_trajectory(...
    x_start_query, x, p, trajectory_index);

[x_traverse, u_traverse] = traverse_subgraph(...
    min_distance_start_ind, min_distance_goal_ind, tg, ug, x);


% Solving the optimization problem with the transition
Nt_start = 15;
Nt_goal = 15;
N = size(x_traverse, 2);

N_sol = Nt_start + N + Nt_goal;

% T = 8;
% Dt = T/(Nt + N);

xf = x_goal_query;

fprintf('Regular optimization\n');
z_regular = direct_collocation_main(...
    x_start_query, x_goal_query, nu, 60, Dt, @dynamics_quadrotor, -30, 30, 1:nx);


fprintf('NTCG optimization\n');
z_start_transition = direct_collocation_main(...
    x_start_query, x_start, nu, Nt_start, Dt, @dynamics_quadrotor, -30, 30, 1:nx);

z_goal_transition = direct_collocation_main(...
   x_goal, x_goal_query, nu, Nt_goal, Dt, @dynamics_quadrotor, -30, 30, 1:nx);

z_start_transition = reshape(z_start_transition, nx+nu, []);
z_goal_transition = reshape(z_goal_transition, nx+nu, []);
x_start_transition = z_start_transition(1:end-nu, :);
u_start_transition = z_start_transition(end-nu+1:end, :);
x_goal_transition = z_goal_transition(1:end-nu, :);
u_goal_transition = z_goal_transition(end-nu+1:end, :);

x_sol = [x_start_transition, x_traverse, x_goal_transition];
u_sol = [u_start_transition, u_traverse, u_goal_transition];


% Simulation 

% Get figure and set size and position. Also setting equal aspect ratio
% [fig, ax] = initializeFigure3D('Quadrotor', 'GridOn', [0, 30], [0, 30], [0, 30]);
% set(gcf, 'Position', [400, 100, 1200, 800]);
% daspect(ax, [1, 1, 1]);
% 
% simulate_trajectory_position(...
%     x_sol, linspace(0, (N_sol - 1)*Dt, N_sol), @draw_quadrotor, ax);



