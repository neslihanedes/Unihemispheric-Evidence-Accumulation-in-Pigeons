function out = startProbeTrial(par, stim, i, shutter)
% This function handles probe trials (mono left/right and bino)

%% Init variables
trialType   = par.buffer(1,i);
delay       = par.buffer(2,i);
% Init response structs
nogoResp    = keyBuffer(0);
goResp      = nogoResp;

%% Start ITI
showStimuli;
bIO(5,1)
WaitSecs(par.timeITI);

%% Check helmet
if(ismember(trialType, 7))
    % probe trial left
    disp('Trial left');
    shutter.openAndClose(shutter.open, shutter.close);
elseif(ismember(trialType, 8))
    % probe trial right,
    disp('Trial right');
    shutter.openAndClose(shutter.close, shutter.open);
elseif(ismember(trialType, 11))    
    % probe trial binocular,
    disp('Bino Probe Trial');
    shutter.openAndClose(shutter.open, shutter.open);
end

%% Start init
bIO(5,1)
showStimuli(stim.init, par.posStimuli);
init = keyBuffer(par.timeITI, 'goodKey', par.posStimuli, par.peckInit);

% Clear screen
showStimuli;

%% Continue after response
if(init.goodKey == par.peckInit)
    initDone = 1;
    
    %% Wait given time
    WaitSecs(par.timeDelay);
    
    %% Show stimulus GO and wait for response
    showStimuli(stim.good, par.posStimuli);
    goResp = keyBuffer(delay, 'goodKey', par.posStimuli, par.peckStimulus);
    
    %% Show Stimulus NOGO and wait for response
    if(goResp.goodKey ~= par.peckStimulus)       
        showStimuli(stim.bad, par.posStimuli);
        nogoResp = keyBuffer(par.timeStimulus, 'badKey', par.posStimuli, par.peckStimulus);
        
        %% Punish
        if(nogoResp.badKey > 0)
            punishment(par.timePunish);
        end
    else
        %% Reward
        feeding(par.timeReward);
    end
else
    initDone = 0;
end

%% Check helmet again
disp('Trial over, open shutters');
shutter.openAndClose(shutter.open, shutter.open);

%% Store variables in output struct
out.i           = i;
out.trialType   = trialType;
out.delay       = delay;
out.init        = init;
out.respGo    	= goResp;
out.respNogo  	= nogoResp;
out.initDone    = initDone;
out.reward      = goResp.goodKey == par.peckStimulus;
out.punish      = nogoResp.badKey > 0;

