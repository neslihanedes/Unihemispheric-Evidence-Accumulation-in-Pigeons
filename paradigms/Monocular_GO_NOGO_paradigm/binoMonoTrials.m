function binoMonoTrials1
% Neslihans experiment called helmet project1

% Tobias Otto, 2018001
% 24.04.2018
% 1.0


%% Init toolbox
start;
bIO(5,1)
%% Init variables
experimentConditionsConfiguration;

%% Compute buffers
par = computeBuffer(par);

%% Init screen and load images
% Init screen
initWindow(2);

% Load stimuli
stim.init	= loadImage([par.stimuli 'white.jpg']);
stim.bad	= loadImage([par.stimuli 'red.jpg']);
stim.good   = loadImage([par.stimuli 'green.jpg']);

stim.initSound = audioread('./Sound/init.wav');

%% Start main loop
j = 1;
k = 1;

for i=1:par.num
    % Get trail type
    if(ismember(par.buffer(1,i), 7:8))
        % Start probe trial
        res2(k)	= startProbeTrial(par, stim, i);
        k       = k+1;
    else
        res1(j)	= startBinoMonoTrial(par, stim, i);
        j       = j+1;
    end
end

%% Compute results
clc

try
    [mono, bino] = computeResult(par, res1);
catch error
    dumpFilename = strcat(pwd, '\dump_', datestr(now,'yyyymmdd_HHMMSS'), '.mat');
    disp(['Saving current memory state to ' dumpFilename ' for further debugging.'])
    save(dumpFilename)
    rethrow(error)
end

%% Save result
res2 = 0;
probe = 0;
save2File(par, res1, res2, probe, mono, bino, 'subject', par.subject, 'path', par.savePath);

%% Clean up
closeWindow;
disp('See results above!');
