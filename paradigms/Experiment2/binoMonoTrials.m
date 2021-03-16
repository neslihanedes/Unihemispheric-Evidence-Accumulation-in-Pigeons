function binoMonoTrials1(par)
% Neslihan's experiment called Helmet Project

%% Init variables
shutter = Shutter;

%% Compute buffers
par = computeBuffer(par);

%% Init screen and load images
% Init screen
initWindow(2);
bIO(5,1)


% Load stimuli
stim.init	= loadImage([par.stimuli 'white.jpg']);
stim.bad	= loadImage([par.stimuli 'red.jpg']);
stim.good   = loadImage([par.stimuli 'green.jpg']);

%% Start main loop
j = 1;
k = 1;

for i=1:par.num
    % Get trail type
    if(ismember(par.buffer(1,i), [7 8 11]))
        % Start probe trial
        res2(k)	= startProbeTrial(par, stim, i, shutter);
        k       = k+1;
    else
        res1(j)	= startBinoMonoTrial(par, stim, i, shutter);
        j       = j+1;
    end
end

%% Compute results
clc

try
    if not(exist('res1', 'var'))
        res1 = -1;
    end
    
    if not(exist('res2', 'var'))
        res2 = -1;
    end
    
    [mono, bino, probe] = computeResult(par, res1, res2);
catch error
    dumpFilename = strcat(pwd, '\dump_', datestr(now,'yyyymmdd_HHMMSS'), '.mat');
    disp(['Saving current memory state to ' dumpFilename ' for further debugging.'])
    save(dumpFilename)
    rethrow(error)
end

%% Save result
save2File(par, res1, res2, probe, mono, bino, 'subject', par.subject, 'path', par.savePath);

%% Clean up
closeWindow;
disp('See results above!');
