function out = startBinoMonoTrial(par, stim, i, shutter)
% This function handles the binocular and monocular trials completely

%% Init variables
trialType   = par.buffer(1,i);
correct     = 0;

if(ismember(trialType, 9:12))
    catchTrial = 1;
else
    catchTrial = 0;
end

% Get stimulus type
if(ismember(trialType, [1 3 5 9 11]))
    stimulus    = stim.good;
    peckStim    = par.peckStimulus;
    respType    = 'goodKey';
elseif(ismember(trialType, [2 4 6 10 12]))
    stimulus    = stim.bad;
    peckStim    = 1;
    respType    = 'badKey';
end

%% Start ITI
showStimuli;
bIO(5,1)
WaitSecs(par.timeITI);

%% Check helmet
if(ismember(trialType, 3:4))
    % mono trial left
    shutter.openAndClose(shutter.open, shutter.close);
elseif(ismember(trialType, 5:6))
    % mono trial right
    shutter.openAndClose(shutter.close, shutter.open);
else
    % bino trial
    shutter.openAndClose(shutter.open, shutter.open);
end

%% Start init
showStimuli(stim.init, par.posStimuli);
init = keyBuffer(par.timeITI, 'goodKey', par.posStimuli, par.peckInit);

% Clear screen
showStimuli;

%% Continue after response
if(init.goodKey == par.peckInit)
    initDone = 1;
    
    %% Wait given time
    WaitSecs(par.timeDelay);
    
    %% Show stimulus and wait for response
    showStimuli(stimulus, par.posStimuli);
    stimResp = keyBuffer(par.timeStimulus, respType, par.posStimuli, peckStim);
    
    % Clear screen
    showStimuli;
    
    %% Reward or punish
    if(stimResp.goodKey == par.peckStimulus && catchTrial == 0)
        feeding(par.timeReward);
    elseif(stimResp.badKey > 0 && catchTrial == 0)
        punishment(par.timePunish);
    end
else
    stimResp = keyBuffer(0);
    initDone = 0;
end

%% Compute result of trial

if strcmp(respType, 'badKey')
    % bad
    if(stimResp.badKey == 0 && initDone == 1)
        correct = 1;
    end
else
    % good
    if(stimResp.goodKey == par.peckStimulus && initDone == 1)
        correct = 1;
    end
end

%% Check helmet again
shutter.openAndClose(shutter.open, shutter.open);

%% Store variables in output struct
out.i           = i;
out.trialType   = trialType;
out.correct     = correct;
out.catchTrial  = catchTrial;
out.init        = init;
out.resp        = stimResp;
out.stim        = stimulus.filename;
out.initDone    = initDone;
out.reward      = (stimResp.goodKey == par.peckStimulus) & (catchTrial == 0);
out.punish      = (stimResp.badKey > 0) && (catchTrial == 0);

