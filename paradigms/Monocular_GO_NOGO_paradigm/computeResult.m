function [mono, bino] = computeResult(par, res1)
% This function computes the results of this experiment

% Tobias Otto
% 1.0
% 25.04.2018

%% Init variables
trialType   = [res1.trialType];
%trialType2  = [res2.trialType];
% 1 --> bino trial good
% 2 --> bino trial bad
% 3 --> mono trial left good
% 4 --> mono trial left bad
% 5 --> mono trial right good
% 6 --> mono trial right bad
% 7 --> probe trial left
% 8 --> probe trial right
% 9 --> catch trial good
% 10--> catch trial bad

%% Compute result for probe trials
% probeLeft       = res2(trialType2 == 7);
% probeRight      = res2(trialType2 == 8);
% probeLeftTime1  = probeLeft([probeLeft.delay] == par.probeDelay(1));
% probeLeftTime2  = probeLeft([probeLeft.delay] == par.probeDelay(2));
% probeLeftTime3  = probeLeft([probeLeft.delay] == par.probeDelay(3));
% probeLeftTime4  = probeLeft([probeLeft.delay] == par.probeDelay(4));
% probeLeftTime5  = probeLeft([probeLeft.delay] == par.probeDelay(5));
% probeLeftTime6  = probeLeft([probeLeft.delay] == par.probeDelay(6));
% 
% probeRightTime1	= probeRight([probeRight.delay] == par.probeDelay(1));
% probeRightTime2	= probeRight([probeRight.delay] == par.probeDelay(2));
% probeRightTime3	= probeRight([probeRight.delay] == par.probeDelay(3));
% probeRightTime4	= probeRight([probeRight.delay] == par.probeDelay(4));
% probeRightTime5 = probeRight([probeRight.delay] == par.probeDelay(5));
% probeRightTime6	= probeRight([probeRight.delay] == par.probeDelay(6));
% 
% probe.totalLeft             = sum(trialType2 == 7);
% probe.totalRight            = sum(trialType2 == 8);
% probe.correctInitLeft       = sum([probeLeft.initDone]);
% probe.correctInitRight      = sum([probeRight.initDone]);
% probe.correctLeftTime100    = sum([probeLeftTime1.reward]);
% probe.correctLeftTime200    = sum([probeLeftTime2.reward]);
% probe.correctLeftTime300    = sum([probeLeftTime3.reward]);
% probe.correctLeftTime400    = sum([probeLeftTime4.reward]);
% probe.correctLeftTime500    = sum([probeLeftTime5.reward]);
% probe.correctLeftTime600    = sum([probeLeftTime6.reward]);
% probe.correctRightTime100 	= sum([probeRightTime1.reward]);
% probe.correctRightTime200	= sum([probeRightTime2.reward]);
% probe.correctRightTime300 	= sum([probeRightTime3.reward]);
% probe.correctRightTime400 	= sum([probeRightTime4.reward]);
% probe.correctRightTime500 	= sum([probeRightTime5.reward]);
% probe.correctRightTime600 	= sum([probeRightTime6.reward]);

%% Compute results monocular
monoLeftGo      = res1(trialType == 3);
monoLeftNogo    = res1(trialType == 4);
monoRightGo     = res1(trialType == 5);
monoRightNogo	= res1(trialType == 6);

mono.totalTrialLeftGo       = sum(trialType == 3);
mono.totalTrialLeftNogo     = sum(trialType == 4);
mono.totalTrialRightGo      = sum(trialType == 5);
mono.totalTrialRightNogo	= sum(trialType == 6);
mono.correctLeftGo          = sum([monoLeftGo.correct]);
mono.correctLeftNogo        = sum([monoLeftNogo.correct]);
mono.correctRightGo         = sum([monoRightGo.correct]);
mono.correctRightNogo    	= sum([monoRightNogo.correct]);
mono.correctInitLeft        = sum([[monoLeftGo.initDone] [monoLeftNogo.initDone]]);
mono.correctInitRight       = sum([[monoRightGo.initDone] [monoRightNogo.initDone]]);

correctLeftPecks = monoLeftGo(logical([monoLeftGo.correct]));
if isempty(correctLeftPecks)
    mono.meanRTLeftGo = -1; 
else
    tmp = [correctLeftPecks.resp];
    mono.meanRTLeftGo = mean([tmp.rt]);
end

correctRightPecks = monoRightGo(logical([monoRightGo.correct]));
if isempty(correctRightPecks)
    mono.meanRTRightGo = -1; 
else
    tmp = [correctRightPecks.resp];
    mono.meanRTRightGo = mean([tmp.rt]);
end
    

%% Compute results binocular
binoGoTrials	= res1(trialType == 1);
binoNogoTrials  = res1(trialType == 2);
binoGoCatch     = res1(trialType == 9);
binoNogoCatch   = res1(trialType == 10);

bino.totalTrials        = sum(ismember(trialType, [1 2 9 10]));
bino.totalGoTrials      = sum(trialType == 1);
bino.totalNogoTrials    = sum(trialType == 2);
bino.totalGoCatch       = sum(trialType == 9);
bino.totalNogoCatch   	= sum(trialType == 10);
bino.correctGo          = sum([binoGoTrials.correct]);
bino.correctNogo        = sum([binoNogoTrials.correct]);
bino.correctCatchGo     = sum([binoGoCatch.correct]);
bino.correctCatchNogo 	= sum([binoNogoCatch.correct]);


correctBinoGoTrials = binoGoTrials(logical([binoGoTrials.correct]))
if isempty(correctBinoGoTrials)
    bino.meanRTGo = -1; 
else
    tmp = [correctBinoGoTrials.resp];
    bino.meanRTGo = mean([tmp.rt]);
end


%% Display results - binocular
 disp(' -----------------------------------------------------------------');
 disp(' --- Binorcular results ---');
 disp(bino);
disp(' -----------------------------------------------------------------');
 disp(' --- Monocular results ---');
 disp(mono);
 disp(' -----------------------------------------------------------------');
%disp(' --- Probe results ---');
%disp(probe);
