% All possible experimental settings within this file;
%
% Produces stim structure which contains all stimuli settings and trial
% definitions


if ~isfield (expsetup.general, 'human_exp')
    expsetup.general.human_exp=1;
end


%% Different training stages have different stim durations

stim.training_stage_matrix = {...
    'lever hold training',...
    'release lever on long ring', 'release lever on big ring',...
    'single target same orientation one ring', ...
    'single target same orientation two rings', ...
    'single target orientation change one ring',...
    'single target orientation change two rings',...
    'single target interleaved',...
    'introduce gabor phase change',...
    'reduce target size',...
    'introduce distractors', 'distractor contrast stable', ...
    'add background texture',...
    'decrease att cue length', 'increase probe isi',...
    'introduce probe angle difference',...
    'final version'};

stim.training_stage_matrix_numbers = 1:numel(stim.training_stage_matrix);

%% Select current training stage

if expsetup.general.debug>0
    stim.exp_version_temp = 'single target orientation change one ring'; % Version you want to run
else
    a = input ('Select training stage by number. Enter 0 if you want to see the list: ');
    if a==0
        for i=1:numel(stim.training_stage_matrix)
            fprintf ('%d - %s\n', i, stim.training_stage_matrix{i})
        end
        b = input ('Select training stage by number: ');
        if b>numel(stim.training_stage_matrix)
            stim.exp_version_temp = stim.training_stage_matrix{end};
        else
            stim.exp_version_temp = stim.training_stage_matrix{b};
        end
    else
        stim.exp_version_temp = stim.training_stage_matrix{a};
    end
end

% In case code wont work, just un-comment and over-write:
% stim.exp_version_temp = 'single target same orientation one ring'; % Version you want to run

%% Variables for different training stages

% 'lever hold training' - train to hold the lever till object of given color appears
% 'lever release on long ring' - release lever when ring appears (ring duration gets shorter)
% 'lever release on big ring' - release lever when ring appears (ring gets smaller)
% 'single target same orientation' - only trials with probe orientation same. Both rings.
% 'single target orientation change' - only trials with probe orientation changes
% 'single target interleaved' - interleave change and no change
% 'introduce gabor phase change' - make phase of the targets change on each rep
% 'reduce target size'
% 'distractor contrast change' - distractor contrast increases
% 'distractor contrast stable' - distractor contrast stable - evaluate performance whether to go to next stage
% 'add background texture'
% 'decrease att cue length' - att cue gets shorter length
% 'increase probe soa' - it becomes a memory task
% 'introduce probe angle difference' - varies probe angle difference
% 'final version'. No changes to the code.

% 'lever hold training'
stim.train_trial_duration_ini = 0.01;
stim.train_trial_duration_ini_step = 0.1;
stim.train_trial_duration = 3;

% 'lever release on long ring'
stim.response_ring_duration_ini = 5;
stim.response_ring_duration_ini_step = -1;

% 'lever release on big ring'
stim.response_ring_size_start_ini = 10;
stim.response_ring_size_start_ini_step = -2;

% 'big target same orientation'
stim.att_stim_size_ini = 12;
stim.att_stim_size_ini_step = -1;

% 'distractor contrast change'
stim.distractor_contrast_ini = 0.01;
stim.distractor_contrast_ini_step = 0.05;

% 'decrease att cue length
stim.att_cue_length_ini = 7; % dva
stim.att_cue_length_ini_step = -1; % decrease

% 'increase probe isi'
stim.att_cue_fix_soa_ini = 1.5;
stim.att_cue_fix_soa_ini_step = -0.1; % Decrease fix soa
stim.probe_isi_ini = 0.05;
stim.probe_isi_ini_step = 0.1; % Increase probe isi

% 'introduce probe angle difference'
stim.probe_angle_diff_ini = 45;


%% Stimuli

%==============
% Noise stimulus
stim.noise_background_position = [0,0];
stim.noise_background_size = [0,0,20,15]; 
stim.noise_background_texture_on = [1,1,1,1,0]; % Probability of texture

%==============
% Fixation

stim.fixation_size = [0,0,0.5,0.5]; % Size of fixation (degrees)
stim.fixation_position = [0,0]; % Degrees, position on a circle
stim.fixation_color_baseline = [20,20,200]; % Color of fixation or text on the screen
stim.fixation_shape_baseline = 'circle';
stim.fixation_pen = 4; % Fixation outline thickness (pixels)
stim.fixation_blink_frequency = 2; % How many time blinks per second;

% Fixation duration
stim.fixation_acquire_duration = [30]; % How long to show fixation before it is acquired
stim.fixation_maintain_duration = [0.5]; % Time to maintain target before stuff starts happening

%==============
% Attention cue
stim.att_cue_fix_soa = 0.5; % Soa between fix acquired and att cue
stim.att_cue_duration = 0.3;
stim.att_cue_length = 1.25; % dva
stim.att_cue_pen = 7; % pixels; For some reason more than 7 pixels crashes the code


%===================
% Attention stimuli

stim.att_stim_number_ini = 1; % Start training with single Gabor patch
stim.att_stim_number_max = 4; % Max number of Gabor patches in the setup
stim.att_stim_arc = [45:90:360];
stim.att_stim_reps = 2; % How many att stim repetitions
stim.att_stim_reps_probe = 2; % On which repetition probe appears
stim.att_stim_radius = 7;
stim.att_stim_size = 4; % Only ~half size will be visible due to gaussian mask
stim.att_stim_angle = [-20:10:20];

%====================
% Probes

stim.probe_cue_isi = [0.3]; % Time from cue onset to probe onset
stim.probe_duration = [0.5]; % Duration
stim.probe_isi = 1; % Time between two probe repetitions
stim.probe_to_response_isi = [0.5];

stim.probe_size = stim.att_stim_size;
stim.probe_radius = stim.att_stim_radius;
stim.probe_angle_diff = [-50, -40, -30, 30, 40, 50];
stim.probe_change = [1, 2]; % 1 is no change; 2 is change
stim.probe_change_meaning = {'1 is same', '2 is change'};

% Contrast of probes and distractors
stim.probe_contrast = 1;
stim.distractor_contrast = 1;

%==============
% Gabors

stim.gabor_frequency = 0.8;
% stim.gabor_contrast = 1; % range is 0-1;
stim.gabor_phase = []; % Phase of the grating (0:1)
stim.gabor_bgluminance = 0.5; % Background luminace (as stimuli are shown on gray)
stim.gabor_sigma_period_factor = 5; % Freq*size periods covered by one STD of gausian


%==============
% Response ring

stim.response_ring_duration = 0.9; % Seconds to give response
stim.response_ring_isi = 0.1; % Time interval between two rings
stim.response_ring_size_start = 4; % How many degrees is ring size
stim.response_ring_size_end = 0; % How many degrees is ring size
stim.response_ring_pen = 4; % How wide the ring is (pixels)

stim.response_ring_arc = [0]; % Angle, on a circle
stim.response_ring_radius = [0]; % Radius
stim.response_ring_sequence = [1,2]; % Different ring colors
stim.response_ring_sequence_meaning = {'1 is same', '2 is change'};
% Response ring color
% 1 is no change
% 2 is change
c1 = [255, 255, 255];
c2 = [20, 255, 20];

if strcmp(expsetup.general.subject_id, 'aq')
    stim.response_ring_color1 = c2;
    stim.response_ring_color2 = c1;
elseif strcmp(expsetup.general.subject_id, 'hb')
    stim.response_ring_color1 = c1;
    stim.response_ring_color2 = c2;
elseif strcmp(expsetup.general.subject_id, 'jw')
    stim.response_ring_color1 = c2;
    stim.response_ring_color2 = c1;
else
    % For human subjects, even numbers and odd numbers get diff stim
    % conditons:
    a = expsetup.general.subject_id(end);
    b = str2double(a);
    if isnan(b)
        stim.response_ring_color1 = c1;
        stim.response_ring_color2 = c2;
    elseif b==1 || b==3 || b==5 || b==7 || b==9
        stim.response_ring_color1 = c1;
        stim.response_ring_color2 = c2;
    elseif b==2 || b==4 || b==6 || b==8 || b==0
        stim.response_ring_color1 = c2;
        stim.response_ring_color2 = c1;
    end
    
end

%==============
% Screen colors
stim.background_color = [127, 127, 127];

%===============
% Duration of trials
if expsetup.general.human_exp == 1
    stim.trial_dur_intertrial = 0.5; % Blank screen at the end
    stim.trial_dur_intertrial_error = 3; % Blank screen at the end
else
    stim.trial_dur_intertrial = 2; % Blank screen at the end
    stim.trial_dur_intertrial_error = 3; % Blank screen at the end
end
stim.trial_error_repeat = 0; % 1 - repeats same trial if error occured immediatelly; 0 - no repeat
stim.trial_abort_counter = 30; % Quit experiment if trials in a row are aborted


%===============
% Updating task

% Updating task with staircase
stim.trial_online_counter_gradual = 3; % How many trials to count for updating task difficulty
stim.trial_correct_goal_up = 3; % What is accuracy to make task harder
stim.trial_correct_goal_down = 2; % What is accuracy to make task harder

% Updating task without staircase
if expsetup.general.human_exp == 1
    stim.trial_online_counter_single_step = 50;
    stim.trial_online_counter_single_step_tn = 0.8; % Proportion of trials needed for updating performance
else
    stim.trial_online_counter_single_step = 100;
    stim.trial_online_counter_single_step_tn = 0.8; % Proportion of trials needed for updating performance
end
stim.trial_online_counter_single_step_goal_up = 0.8; % Proportion of trials correct

%===============
% Other

stim.lever_press_penalty = 1000; % How long to wait for the release of the lever

%=============
% Trial numbers
stim.final_version_trial_number = 1000; % When to terminate experiment in the final version of the task


%%  Reward

% stim.reward_coeff1 = [460.0749   64.8784]; % Mount rack reward, measure as of 03.08.2016
stim.reward_coeff1 = [881.4887   -3.3301]; % Pump reward measure as of 10.19.2016

if isfield(expsetup.general, 'subject_id') && strcmp(expsetup.general.subject_id, 'aq')
    stim.reward_size_ml = 0.28; % Typical reward to start with
elseif isfield(expsetup.general, 'subject_id') && strcmp(expsetup.general.subject_id, 'hb')
    stim.reward_size_ml = 0.16; % Typical reward to start with
elseif isfield(expsetup.general, 'subject_id') && strcmp(expsetup.general.subject_id, 'jw')
    stim.reward_size_ml = 0.25; % Typical reward to start with
else
    stim.reward_size_ml = 0.18;
end
stim.reward_size_ms = round(polyval(stim.reward_coeff1, stim.reward_size_ml));
stim.reward_feedback = 2; % If 1 - show feedback;  2 - play audio feedback; 3 - audio feedback via arduino
stim.reward_feedback_audio_dur = 0.2; % How long to wait to give reward feedback
stim.reward_pic_size = [0, 0, 5, 5]; % If reward pic is shown, thats the size



%% Do not forget to update for each epxeriment: 

% Specify column names for expmatrix
stim.esetup_exp_version{1} = NaN; % Which task version participant is doing
stim.esetup_block_no = NaN; % Which block number (1:number of blocks)
stim.esetup_block_cond = NaN; % Which blocked condition is presented

stim.esetup_fix_coord(1:2) = NaN;  % Fixation x position
stim.esetup_lever_acquire_duration = NaN;
stim.esetup_lever_maintain_duration = NaN;

% Training to hold a lever
stim.esetup_train_trial_duration = NaN;

% Initialize gabor patch properties
t1 = stim.att_stim_number_max;
t2 = stim.att_stim_reps; 
stim.esetup_att_stim_arc(1, 1:t1, 1:t2) = NaN;
stim.esetup_att_stim_radius(1, 1:t1, 1:t2) = NaN;
stim.esetup_att_stim_size(1, 1:t1, 1:t2) = NaN;
stim.esetup_att_stim_angle(1, 1:t1, 1:t2) = NaN;
stim.esetup_att_stim_phase(1, 1:t1, 1:t2) = NaN;
stim.esetup_att_stim_contrast(1, 1:t1, 1:t2) = NaN;

stim.esetup_probe_arc = NaN;
stim.esetup_probe_radius = NaN;
stim.esetup_probe_angle = NaN; 
stim.esetup_probe_change = NaN; % Angle changes or not
stim.esetup_probe_duration = NaN;
stim.esetup_probe_isi = NaN;

stim.esetup_probe_contrast = NaN;
stim.esetup_distractor_contrast = NaN;

stim.esetup_att_stim_number = NaN; 

stim.esetup_att_cue_fix_soa = NaN;
stim.esetup_att_cue_arc = NaN; 
stim.esetup_att_cue_length = NaN; 

stim.esetup_response_ring_arc = NaN;  
stim.esetup_response_ring_radius = NaN;  
stim.esetup_response_ring_sequence(1,1:2) = NaN; % Which color of the ring shown first
stim.esetup_response_ring_duration = NaN;
stim.esetup_response_ring_size_start = NaN;
stim.esetup_response_ring_size_end = NaN;

esetup_noise_background_texture_on = NaN;

stim.edata_first_display = NaN; 
stim.edata_texture_on = NaN;

stim.edata_lever_on = NaN;
stim.edata_lever_off = NaN;
stim.edata_lever_acquired = NaN;
stim.edata_lever_duration = NaN;
stim.edata_lever_response = NaN;

stim.edata_fixation_on = NaN; % Stimulus time
stim.edata_probe_on = NaN; % Stimulus confirmation
stim.edata_probe_off = NaN; % Stimulus time
stim.edata_att_cue_on = NaN; % Stimulus confirmation

stim.edata_response_ring1_on = NaN;
stim.edata_response_ring2_on = NaN;
stim.edata_response_rings_off = NaN;

% Reward
stim.edata_reward_image_on = NaN;
stim.edata_reward_on = NaN;
stim.edata_reward_size_ms = NaN; % How much reward animal was given
stim.edata_reward_size_ml = NaN; % How much reward animal was given

stim.edata_loop_over = NaN; % Stimulus time

% Monitoring performance
stim.edata_error_code{1} = NaN;
stim.edata_trial_abort_counter = NaN;
stim.edata_trial_online_counter = NaN; % Error code


%%  Initialize frames matrices (one trial - one cell; one row - one frame onscreen)

% Timing and eye position
stim.eframes_time{1}(1) = NaN;
stim.eframes_eye_x{1}(1) = NaN;
stim.eframes_eye_y{1}(1) = NaN;
stim.eframes_eye_target{1}(1) = NaN;

% Background & fixation
stim.eframes_fixation{1}(1) = NaN;
stim.eframes_fixation_stops_blinking{1}(1)=NaN;
stim.eframes_texture_on{1}(1) = NaN;

% Central cue
stim.eframes_att_cue_on_temp{1}(1) = NaN;
stim.eframes_att_cue_on{1}(1) = NaN;
stim.eframes_att_cue_off_temp{1}(1) = NaN;
stim.eframes_att_cue_off{1}(1) = NaN;

% Gabor patches
stim.eframes_att_stim_on_temp{1}(1) = NaN;
stim.eframes_att_stim_on{1}(1) = NaN;

% Probe on/off
stim.eframes_probe_on_temp{1}(1) = NaN;
stim.eframes_probe_on{1}(1) = NaN;
stim.eframes_probe_off_temp{1}(1) = NaN;
stim.eframes_probe_off{1}(1) = NaN;

% Response ring on/off
stim.eframes_response_ring_size_temp{1}(1) = NaN;
stim.eframes_response_ring_size{1}(1) = NaN;
stim.eframes_response_ring_on_temp{1}(1) = NaN;
stim.eframes_response_ring_on{1}(1) = NaN;
stim.eframes_response_ring_off_temp{1}(1) = NaN;
stim.eframes_response_ring_off{1}(1) = NaN;


%% Save into expsetup

expsetup.stim=stim;


