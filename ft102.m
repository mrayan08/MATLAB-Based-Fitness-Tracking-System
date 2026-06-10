%% MATLAB HACKATHON: FITPULSE INTELLIGENT TRACKER (FIXED EDITION)
clc; close all;

% --- RESET SESSION ---
if exist('m', 'var') && isa(m, 'mobiledev')
    try, if isvalid(m), m.Logging = 0; delete(m); end; catch, end
end
clear mobiledev; clear; 

% User Config
weight_kg = 75;       
recDuration = 10; 
historyFile = 'fitness_history_v5.mat';

% =========================================================================
% STAGE 1: DATA COLLECTION AND SENSOR INTEGRATION
% =========================================================================
fprintf('\n--- STAGE 1: INITIALIZING SENSORS ---\n');
phone_connected = false;
try
    m = mobiledev; 
    if m.Connected
        m.AccelerationSensorEnabled = 1; m.PositionSensorEnabled = 1;
        pause(1); 
        fprintf('STATUS: Phone Sensors Integrated. ACTION: RECORDING...\n');
        m.Logging = 1; pause(recDuration); m.Logging = 0;
        
        [accel, t_raw] = accellog(m);
        [lat, lon, t_g, spd_g] = poslog(m);
        t = t_raw - t_raw(1); fs = 1/mean(diff(t));
        mag = sqrt(sum(accel.^2, 2));
        phone_connected = true;
    else, error('No Phone'); end
catch
    fprintf('STATUS: No Sensor Detected. Using Simulation Fallback.\n');
    fs = 50; t = (0:1/fs:recDuration)';
    mag = 9.8 + 2.5*sin(2*pi*1.8*t) + randn(size(t))*0.5;
    spd_g = 1.4 + randn(size(t))*0.1; 
    lat = 17.385 + (0:0.0001:0.0001*(length(t)-1))'; lon = 78.486 * ones(size(lat));
end

% =========================================================================
% STAGE 2: FEATURE EXTRACTION AND METRIC CALCULATION
% =========================================================================
fprintf('\n--- STAGE 2: EXTRACTING FEATURES ---\n');
mag_f = smoothdata(detrend(mag), 'movmean', floor(fs/6));

% --- FIX 1: ADAPTIVE STEP DETECTION ---
% We set threshold to 15% of the max signal, or a minimum of 0.2 to avoid noise
threshold = max(0.2, 0.15 * max(mag_f)); 
pks = []; locs = [];
if max(mag_f) > threshold
    [pks, locs] = findpeaks(mag_f, 'MinPeakHeight', threshold, 'MinPeakDistance', floor(fs/3.5));
end
stepCount = length(locs);

% --- FIX 2: IMPROVED DISTANCE LOGIC ---
avg_spd_ms = mean(spd_g, 'omitnan');
% If GPS is 0 but we detected steps, use a walking cadence estimate
% If no steps AND no GPS speed, distance is 0.
if (isnan(avg_spd_ms) || avg_spd_ms < 0.2)
    if stepCount > 0
        avg_spd_ms = 1.2; % Realistic walking speed fallback only if steps exist
    else
        avg_spd_ms = 0;   % Truly standing still
    end
end
dist_m = avg_spd_ms * recDuration;
avg_spd_kph = avg_spd_ms * 3.6;

fprintf('STAGE 2 COMPLETE: Steps=%d, Dist=%.1fm\n', stepCount, dist_m);

% =========================================================================
% STAGE 3: MACHINE LEARNING & PERSONALIZED HEALTH STATUS
% =========================================================================
% Activity Classification
intensity = std(mag_f);
if intensity > 1.0 % Lowered threshold for "Running" detection sensitivity
    act = "Running"; met = 8.0; 
elseif stepCount > 0
    act = "Walking"; met = 3.5;
else
    act = "Idle"; met = 1.2;
end
cals_current = met * weight_kg * (recDuration/3600);

% History Loading
if exist(historyFile, 'file')
    load(historyFile); 
else
    sz = [0 5];
    varTypes = {'datetime', 'double', 'double', 'double', 'string'};
    varNames = {'Time', 'Steps', 'Dist_m', 'Kcal', 'Activity'};
    histTable = table('Size', sz, 'VariableTypes', varTypes, 'VariableNames', varNames);
end

% Health Status Logic
if height(histTable) > 0
    avgStepsHistory = mean(histTable.Steps);
    if stepCount > 1.1 * avgStepsHistory
        healthStatus = "EXCELLENT"; statusColor = [0.2 1 0.2];
    elseif stepCount >= 0.8 * avgStepsHistory
        healthStatus = "AVERAGE"; statusColor = 'y';
    else
        healthStatus = "BELOW AVERAGE"; statusColor = [1 0.2 0.2];
    end
else
    healthStatus = "GOOD (Start)"; statusColor = 'cyan';
end

% Save Session
histTable(end+1, :) = {datetime('now'), stepCount, round(dist_m,1), round(cals_current,2), string(act)};
save(historyFile, 'histTable');

% =========================================================================
% FINAL VISUALIZATION
% =========================================================================
fig = figure('Name', 'FitPulse PRO', 'Color', [0.1 0.1 0.1], 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8]);
tlay = tiledlayout(4,2, 'TileSpacing', 'Compact');

nexttile(1);
if ~isempty(lat), geoplot(lat, lon, 'cyan', 'LineWidth', 2); geobasemap streets; end
title('STAGE 1: GPS Path', 'Color', 'w');

nexttile(2);
plot(histTable.Kcal, '-o', 'Color', 'y', 'LineWidth', 2);
title('STAGE 3: Progress History (Kcal)', 'Color', 'w');
set(gca, 'Color', [0.15 0.15 0.15], 'XColor', 'w', 'YColor', 'w'); grid on;

nexttile([1 2]);
plot(t, mag_f, 'Color', [0.6 0.6 0.6]); hold on;
if ~isempty(locs), plot(t(locs), mag_f(locs), 'ro', 'MarkerFaceColor', 'r'); end
title('STAGE 2: Processed Motion Signal (Adaptive Threshold)', 'Color', 'w');
set(gca, 'Color', [0.15 0.15 0.15], 'XColor', 'w', 'YColor', 'w'); grid on;

nexttile([1 2]); axis off;
rectangle('Position', [0, 0.05, 1, 0.9], 'Curvature', 0.2, 'EdgeColor', 'w');
text(0.05, 0.80, 'INTELLIGENT HEALTH REPORT', 'FontSize', 18, 'FontWeight', 'bold', 'Color', 'cyan');
text(0.05, 0.50, sprintf('Steps: %d', stepCount), 'FontSize', 14, 'Color', 'w');
text(0.05, 0.25, sprintf('Activity: %s', act), 'FontSize', 14, 'Color', 'w');
text(0.35, 0.50, sprintf('Dist: %.1f m', dist_m), 'FontSize', 14, 'Color', 'w');
text(0.35, 0.25, sprintf('Calories: %.2f kcal', cals_current), 'FontSize', 14, 'Color', 'w');
text(0.65, 0.60, 'HEALTH STATUS:', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
text(0.65, 0.35, healthStatus, 'FontSize', 22, 'FontWeight', 'bold', 'Color', statusColor);

nexttile([1 2]);
uitable(fig, 'Data', histTable, 'Units', 'Normalized', 'Position', [0.05, 0.05, 0.9, 0.18], ...
    'BackgroundColor', [0.2 0.2 0.2], 'ForegroundColor', 'w');
shg;