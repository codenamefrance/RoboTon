% MATLAB Script: Determine Solar Array Configuration using the Two-Diode Model
% Hackathon: Microgrid on Mars - Task 2

clear; clc; close all;

%% 1. Extract Parameters from Simulink (You must verify these!)
% The screenshot shows Rs=0, N=1.5. You will need to look inside the 
% Simulink block's underlying code or documentation for the remaining constants.
% I have provided standard placeholder values for the missing ones.

Voc = 0.61;       % Open-circuit voltage (V)
Isc = 10.6;       % Short-circuit current (A)

% --- Hidden Two-Diode Parameters (Replace with exact values from block) ---
Iph = 10.6;       % Solar-generated current (~equal to Isc) (A)
Is  = 1e-10;      % Diode 1 saturation current (A)
Is2 = 1e-8;       % Diode 2 saturation current (A)
N   = 1.5;        % Quality factor 1 (From screenshot)
N2  = 2.0;        % Quality factor 2
Rp  = 1000;       % Parallel resistance (Ohms)
Rs  = 0;          % Series resistance (Ohms) - From screenshot
Vt  = 0.02585;    % Thermal voltage at 25C (V)

%% 2. Define Target Array Requirements
P_target = 50000; % Target Power = 50,000 W (50 kW)
V_target = 500;   % Target Voltage = 500 V

%% 3. Generate the V-I and P-V Curves for a Single Cell
% Create a voltage array from 0 to Voc with 1000 points
V_cell = linspace(0, Voc, 1000);

% Calculate Current using the provided formula (Simplified because Rs = 0)
I_cell = Iph - Is.*(exp(V_cell./(N*Vt)) - 1) - Is2.*(exp(V_cell./(N2*Vt)) - 1) - (V_cell./Rp);

% Ensure current doesn't drop below zero for plotting purposes
I_cell(I_cell < 0) = 0;

% Calculate Power (P = V * I)
P_cell = V_cell .* I_cell;

%% 4. Find the True Maximum Power Point (MPP) of the Single Cell
[P_max_cell, mpp_index] = max(P_cell);
V_mp = V_cell(mpp_index);
I_mp = I_cell(mpp_index);

%% 5. Calculate Final Array Configuration
% Calculate Ns to hit 500V at the Maximum Power Voltage (Vmp), not Voc
Ns = ceil(V_target / V_mp); 

% Calculate required total current, then find Np to hit it at Imp, not Isc
I_req_total = P_target / V_target;
Np = ceil(I_req_total / I_mp);

%% 6. Output Results
fprintf('\n========================================\n');
fprintf('   TWO-DIODE MODEL CONFIGURATION\n');
fprintf('========================================\n');
fprintf('Single Cell MPP: Vmp = %.3f V, Imp = %.3f A, Pmax = %.2f W\n', V_mp, I_mp, P_max_cell);
fprintf('----------------------------------------\n');
fprintf('Target Array: %.2f kW at %.2f V\n', P_target/1000, V_target);
fprintf('-> Series Cells per String (Ns): %d\n', Ns);
fprintf('-> Parallel Strings (Np):        %d\n', Np);
fprintf('========================================\n\n');

%% 7. Plotting the Curves
figure;

% Plot I-V Curve
yyaxis left;
plot(V_cell, I_cell, 'b-', 'LineWidth', 2);
ylabel('Current (A)');
hold on;
plot(V_mp, I_mp, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'b'); % Mark MPP

% Plot P-V Curve
yyaxis right;
plot(V_cell, P_cell, 'r-', 'LineWidth', 2);
ylabel('Power (W)');
plot(V_mp, P_max_cell, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'r'); % Mark MPP

% Formatting
title('Single Solar Cell I-V and P-V Characteristics');
xlabel('Voltage (V)');
grid on;
legend('I-V Curve', 'MPP (Current)', 'P-V Curve', 'MPP (Power)', 'Location', 'southwest');