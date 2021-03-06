% Here all displays presented

window = expsetup.screen.window;


%% Training stage in the experiment

runexp_trial_update_performance_v12


%% PREPARE ALL OBJECTS AND FRAMES TO BE DRAWN:

% In this case, randomization is done on each trial. Alternatively, all exp
% mat could be preset on first trial.
if tid == 1
    u1 = sprintf('%s_trial_randomize', expsetup.general.expname); % Path to file containing trial settings
    eval (u1);
elseif tid>1
    u1 = sprintf('%s_trial_randomize', expsetup.general.expname); % Path to file containing trial settings
    eval (u1);
end

% Initialize all rectangles for the task
u1 = sprintf('%s_trial_stimuli', expsetup.general.expname); % Path to file containing trial settings
eval (u1);

% Initialize all frames for the task
u1 = sprintf('%s_trial_frames', expsetup.general.expname); % Path to file containing trial settings
eval (u1);


%% EYETRACKER INITIALIZE

% Start recording
if expsetup.general.recordeyes==1
    Eyelink('StartRecording');
    msg1=['TrialStart ', num2str(tid)];
    Eyelink('Message', msg1);
    WaitSecs(0.1);  % Record a few samples before we actually start displaying
end

% SEND MESSAGE WITH TRIAL ID TO EYELINK
if expsetup.general.recordeyes==1
    trial_current = tid; % Which trial of the current block it is?
    msg1 = sprintf('Trial %i', trial_current);
    Eyelink('Command', 'record_status_message ''%s'' ', msg1);
end


%% Before starting anything, make sure lever is not pressed

% Record what kind of button was pressed
[keyIsDown,timeSecs,keyCode] = KbCheck;
char = KbName(keyCode);
% Catch potential press of two buttons
if iscell(char)
    char=char{1};
end

if keyIsDown==1 && strcmp(char,'space') % If space bar was last key recorded
    
    timer1_now = GetSecs;
    time_start = GetSecs;
    trial_duration = expsetup.stim.lever_press_penalty;
    
    % Check whether space is pressed now
    if keyIsDown==1 && strcmp(char,'space')
        endloop_skip = 0;
    else
        endloop_skip = 1;
    end
    
    % Loop for 30 seconds before space is released
    while endloop_skip == 0
        
        % Record what kind of button was pressed
        [keyIsDown,timeSecs,keyCode] = KbCheck;
        char = KbName(keyCode);
        % Catch potential press of two buttons
        if iscell(char)
            char=char{1};
        end
        
        if keyIsDown==0
            % End loop
            endloop_skip=1;
        else
            % Check time & quit loop
            timer1_now = GetSecs;
            if timer1_now - time_start >= trial_duration
                endloop_skip=1;
            end
        end
    end
    
end

%% FIRST DISPLAY

Screen('FillRect', window, expsetup.stim.background_color);
if expsetup.general.record_plexon==1
    Screen('FillRect', window, [255, 255, 255], ph_rect, 1); % Photodiode
end
[~, time_current, ~]=Screen('Flip', window);

% Save plexon event
if expsetup.general.record_plexon==1
    a1 = zeros(1,expsetup.ni_daq.digital_channel_total);
    a1_s = expsetup.general.plex_event_start; % Channel number used for events
    a1(a1_s)=1;
    outputSingleScan(ni.session_plexon_events,a1);
    a1 = zeros(1,expsetup.ni_daq.digital_channel_total);
    outputSingleScan(ni.session_plexon_events,a1);
end

% Save eyelink and psychtoolbox events
if expsetup.general.recordeyes==1
    Eyelink('Message', 'first_display');
end
expsetup.stim.edata_first_display(tid,1) = time_current;

% Save trialmat event
c1_frame_index1 = 1;
expsetup.stim.eframes_time{tid}(c1_frame_index1, 1) = time_current; % Save in the first row during presentation of first dislapy


%%  TRIAL LOOP

loop_over = 0;

while loop_over==0
    
    
    %=================
    % Initialize new frame index
    c1_frame_index1 = c1_frame_index1+1;
    
    
    %% Update frames dependent on acquiring fixation
    
    % Changes in fixation (stop blinking)
    if ~isnan(expsetup.stim.edata_lever_acquired(tid,1)) && nansum(expsetup.stim.eframes_fixation_stops_blinking{tid}(:, 1))==0
        expsetup.stim.eframes_fixation{tid}(c1_frame_index1:end, 1) = 1;
        expsetup.stim.eframes_fixation_stops_blinking{tid}(c1_frame_index1, 1) = 1;
    end
    
    % Determine whether to show attention cue (based on timing)
    t0 = expsetup.stim.edata_lever_acquired(tid,1);
    t1 = expsetup.stim.esetup_att_cue_fix_soa(tid,1);
    if time_current - t0 >= t1
        % Update framesmat
        if nansum(expsetup.stim.eframes_att_cue_on{tid})==0
            % Copy data from trial mat
            a = expsetup.stim.eframes_att_cue_on_temp{tid};
            ind = c1_frame_index1 : size(a,1);
            expsetup.stim.eframes_att_cue_on{tid}(ind, 1) = a(1:numel(ind));
            % Copy data from trial mat
            a = expsetup.stim.eframes_att_cue_off_temp{tid};
            ind = c1_frame_index1 : size(a,1);
            expsetup.stim.eframes_att_cue_off{tid}(ind, 1) = a(1:numel(ind));
        end
    end
    
    
    % Determine whether to show gabor patches yet
    t0 = expsetup.stim.edata_att_cue_on(tid,1);
    if time_current - t0 >= expsetup.stim.probe_cue_isi
        % Update framesmat
        if nansum(expsetup.stim.eframes_att_stim_on{tid})==0
            % Copy data from trial mat
            a = expsetup.stim.eframes_att_stim_on_temp{tid};
            ind = c1_frame_index1 : size(a,1);
            expsetup.stim.eframes_att_stim_on{tid}(ind, 1) = a(1:numel(ind));
            % Copy data from trial mat
            a = expsetup.stim.eframes_probe_on_temp{tid};
            ind = c1_frame_index1 : size(a,1);
            expsetup.stim.eframes_probe_on{tid}(ind, 1) = a(1:numel(ind));
            % Copy data from trial mat
            a = expsetup.stim.eframes_probe_off_temp{tid};
            ind = c1_frame_index1 : size(a,1);
            expsetup.stim.eframes_probe_off{tid}(ind, 1) = a(1:numel(ind));
        end
    end
    
    
    % Determine whether to show response rings yet
    t0 = expsetup.stim.edata_probe_off(tid,1);
    if time_current - t0 >= expsetup.stim.probe_to_response_isi
        % Update framesmat
        if nansum(expsetup.stim.eframes_response_ring_on{tid})==0
            % Copy data from trial mat
            a = expsetup.stim.eframes_response_ring_size_temp{tid};
            ind = c1_frame_index1 : size(a,1);
            expsetup.stim.eframes_response_ring_size{tid}(ind, 1) = a(1:numel(ind));
            % Copy data from trial mat
            a = expsetup.stim.eframes_response_ring_on_temp{tid};
            ind = c1_frame_index1 : size(a,1);
            expsetup.stim.eframes_response_ring_on{tid}(ind, 1) = a(1:numel(ind));
            % Copy data from trial mat
            a = expsetup.stim.eframes_response_ring_off_temp{tid};
            ind = c1_frame_index1 : size(a,1);
            expsetup.stim.eframes_response_ring_off{tid}(ind, 1) = a(1:numel(ind));
            %================
            % Remove fixation
            expsetup.stim.eframes_fixation{tid}(c1_frame_index1:end, 1) = 0; % Fixation disappears
        end
    end
    
    
    %% Plot displays
    
    %==================
    % Noise texture
    
    if expsetup.stim.esetup_noise_background_texture_on(tid)==1
        var1 = expsetup.stim.eframes_texture_on{tid};
        if var1(c1_frame_index1,1)==1
            tex=texture_backgroud{1};
            Screen('DrawTexture', window, tex, [], background_rect, [], 0);
        end
    end
    
    %==================
    % Fixation
    if expsetup.stim.eframes_fixation{tid}(c1_frame_index1,1)==1
        sh1 = expsetup.stim.fixation_shape_baseline;
        c1 =  expsetup.stim.fixation_color_baseline;
        p1 = expsetup.stim.fixation_pen;
        r1 = fixation_rect;
        % Plot
        if strcmp(sh1,'circle')
            Screen('FillArc', window, c1, r1, 0, 360);
        elseif strcmp(sh1,'square')
            Screen('FillRect', window, c1, r1, p1);
        elseif strcmp(sh1,'empty_circle')
            Screen('FrameArc',window, c1, r1, 0, 360, p1)
        elseif strcmp(sh1,'empty_square')
            Screen('FrameRect', window, c1, r1, p1);
        end
    end
    
    %==================
    % Attention cue
    if expsetup.stim.eframes_att_cue_on{tid}(c1_frame_index1,1)==1
        % Show stimulus
        fcolor1 = expsetup.stim.fixation_color_baseline;
        Screen('DrawLine', window, fcolor1, att_cue_rect(1), att_cue_rect(2), att_cue_rect(3), att_cue_rect(4), expsetup.stim.att_cue_pen);
    end
     
    %==================
    % Plot gabor patches
    if expsetup.stim.eframes_att_stim_on{tid}(c1_frame_index1, 1) > 0
        for i = 1:size(att_stim_rect,2)
            j = expsetup.stim.eframes_att_stim_on{tid}(c1_frame_index1, 1);
            tex = texture_att_stim{1,i,j};
            Screen('DrawTexture', window, tex, [], att_stim_rect(:,i), [], 0);
        end
    end
    
    
    %=====================
    % Response object 1 or 2
    
    if expsetup.stim.eframes_response_ring_on{tid}(c1_frame_index1, 1) == 1 || expsetup.stim.eframes_response_ring_on{tid}(c1_frame_index1, 1) == 2
        
        % Response position (variable on each trial)
        pos1 = expsetup.stim.esetup_response_ring_arc(tid,1);
        rad1 = expsetup.stim.esetup_response_ring_radius(tid,1);
        [xc, yc] = pol2cart(pos1*pi/180, rad1); % Convert to cartesian
        coord1=[];
        coord1(1)=xc; coord1(2)=yc;
        % Size
        a = expsetup.stim.eframes_response_ring_size{tid}(c1_frame_index1, 1);
        sz1 = [0, 0, a, a];
        % Rect
        response_ring_rect = runexp_convert_deg2pix_rect_v10(coord1, sz1); % One column - one object;
        
        % Color
        if expsetup.stim.eframes_response_ring_on{tid}(c1_frame_index1, 1) == 1
            fcolor1 = expsetup.stim.response_ring_color1;
        elseif expsetup.stim.eframes_response_ring_on{tid}(c1_frame_index1, 1) == 2
            fcolor1 = expsetup.stim.response_ring_color2;
        end
        
        % Plot
        Screen('FillArc', window,  fcolor1, response_ring_rect, 0, 360);
        
    end
    
    
    
    %% FLIP AND RECORD TIME
    
    [~, time_current, ~]=Screen('Flip', window);
    
    % Save flip time into trialmat
    expsetup.stim.eframes_time{tid}(c1_frame_index1, 1) = time_current; % Add row to each refresh
    
    % Record texture onset
    if expsetup.stim.eframes_texture_on{tid}(c1_frame_index1,1)==1 && isnan(expsetup.stim.edata_texture_on(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'texture_on');
        end
        expsetup.stim.edata_texture_on(tid,1) = time_current;
    end
    
    % Record fixation onset
    if expsetup.stim.eframes_fixation{tid}(c1_frame_index1,1)==1 && isnan(expsetup.stim.edata_fixation_on(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'fixation_on');
        end
        expsetup.stim.edata_fixation_on(tid,1) = time_current;
    end

    % Record att cue onset
    if expsetup.stim.eframes_att_cue_on{tid}(c1_frame_index1,1)==1 && isnan(expsetup.stim.edata_att_cue_on(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'att_cue_on');
        end
        expsetup.stim.edata_att_cue_on(tid,1) = time_current;
    end
    
    % Record probe onset
    if expsetup.stim.eframes_probe_on{tid}(c1_frame_index1,1)==1 && isnan(expsetup.stim.edata_probe_on(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'probe_on');
        end
        expsetup.stim.edata_probe_on(tid,1) = time_current;
    end
    
    % Record probe offset
    if expsetup.stim.eframes_probe_off{tid}(c1_frame_index1,1)==1 && isnan(expsetup.stim.edata_probe_off(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'probe_off');
        end
        expsetup.stim.edata_probe_off(tid,1) = time_current;
    end
    
    % Record response ring 1 onset
    if expsetup.stim.eframes_response_ring_on{tid}(c1_frame_index1,1)==1 && isnan(expsetup.stim.edata_response_ring1_on(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'response_ring1_on');
        end
        expsetup.stim.edata_response_ring1_on(tid,1) = time_current;
    end
    
    % Record response ring 2 onset
    if expsetup.stim.eframes_response_ring_on{tid}(c1_frame_index1,1)==2 && isnan(expsetup.stim.edata_response_ring2_on(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'response_ring2_on');
        end
        expsetup.stim.edata_response_ring2_on(tid,1) = time_current;
    end
    
    if expsetup.stim.eframes_response_ring_off{tid}(c1_frame_index1,1)==1 && isnan(expsetup.stim.edata_response_rings_off(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'response_rings_off');
        end
        expsetup.stim.edata_response_rings_off(tid,1) = time_current;
    end
    
    %==================
    %==================
    
    
    %%  Get eyelink data sample
    
    try
        [mx,my] = runexp_eyelink_get_v11;
        expsetup.stim.eframes_eye_x{tid}(c1_frame_index1, 1)=mx;
        expsetup.stim.eframes_eye_y{tid}(c1_frame_index1, 1)=my;
    catch
        expsetup.stim.eframes_eye_x{tid}(c1_frame_index1, 1)=999999;
        expsetup.stim.eframes_eye_y{tid}(c1_frame_index1, 1)=999999;
    end
    
    
    %% Check button presses
    
    [keyIsDown, keyTime, keyCode] = KbCheck;
    char = KbName(keyCode);
    % Catch potential press of two buttons
    if iscell(char)
        char=char{1};
    end
    
    % Record what kind of button was pressed
    if strcmp(char,'c') || strcmp(char,'p') || strcmp(char,'r') || strcmp(char, expsetup.general.quit_key)
        expsetup.stim.edata_error_code{tid} = 'experimenter terminated the trial';
    end
    
    
    %%  Record whether lever/button is being pressed during the trial
    
    if expsetup.general.arduino_on == 0
        
        % Save message if lever/button was detected
        if isnan(expsetup.stim.edata_lever_on(tid,1)) && keyIsDown==1 && strcmp(char,'space')
            if expsetup.general.recordeyes==1
                Eyelink('Message', 'lever_onset');
            end
            expsetup.stim.edata_lever_on(tid,1) = keyTime;
        end
        
        % Save message if lever/button was released
        if ~isnan(expsetup.stim.edata_lever_on(tid,1)) && isnan(expsetup.stim.edata_lever_off(tid,1)) && keyIsDown==0
            if expsetup.general.recordeyes==1
                Eyelink('Message', 'lever_off');
            end
            expsetup.stim.edata_lever_off(tid,1) = keyTime;
        end
        
        % Save duration of lever/button holding
        if ~isnan(expsetup.stim.edata_lever_off(tid,1)) && ~isnan(expsetup.stim.edata_lever_on(tid,1))
            v1 = expsetup.stim.edata_lever_off(tid,1) -  expsetup.stim.edata_lever_on(tid,1);
            expsetup.stim.edata_lever_duration(tid,1) = v1;
        end
        
    end
    
    %% Monitor trial performance
    
    %===================
    % Check whether lever was acquired in time (else its error)
    %===================
    
    if isnan(expsetup.stim.edata_lever_acquired(tid,1))
        
        % Time
        timer1_now = expsetup.stim.eframes_time{tid}(c1_frame_index1, 1);
        %
        timer1_start = expsetup.stim.edata_fixation_on(tid,1);
        %
        timer1_duration = expsetup.stim.esetup_lever_acquire_duration(tid,1);
        
        if timer1_now - timer1_start < timer1_duration % Record an error
            if ~isnan(expsetup.stim.edata_lever_on(tid,1))
                expsetup.stim.edata_lever_acquired(tid,1) = GetSecs;
            elseif isnan(expsetup.stim.edata_lever_on(tid,1))
                % Proceed with trial
            end
        elseif timer1_now - timer1_start >= timer1_duration % Record an error
            expsetup.stim.edata_error_code{tid} = 'lever not acquired in time';
        end
        
    end
    
    %===================
    % Check whether lever was released too early
    %===================
    
    if ~strcmp(expsetup.stim.esetup_exp_version{tid}, 'lever hold training')
        if isnan(expsetup.stim.edata_response_ring1_on(tid,1)) && isnan(expsetup.stim.edata_response_ring2_on(tid,1)) && ~isnan(expsetup.stim.edata_lever_off(tid,1))
            expsetup.stim.edata_error_code{tid} = 'lever hold failure';
        end
    end
    
    %===================
    % Save error if lever was not released
    %===================
    
    if ~strcmp(expsetup.stim.esetup_exp_version{tid}, 'lever hold training')
        if ~isnan(expsetup.stim.edata_response_rings_off(tid,1)) && isnan(expsetup.stim.edata_lever_off(tid,1))
            expsetup.stim.edata_error_code{tid} = 'lever not released';
        end
    end
    
    
    %===================
    % Check which lever response was given after response object appeared
    %===================
    
    if ~strcmp(expsetup.stim.esetup_exp_version{tid}, 'lever hold training')
        if ~isnan(expsetup.stim.eframes_response_ring_on{tid}(c1_frame_index1,1)) && ~isnan(expsetup.stim.edata_lever_off(tid,1)) && isnan(expsetup.stim.edata_lever_response(tid,1))
            
            if expsetup.stim.eframes_response_ring_on{tid}(c1_frame_index1,1)==1 || expsetup.stim.eframes_response_ring_on{tid}(c1_frame_index1,1)==2 % Save associated target
                expsetup.stim.edata_lever_response(tid,1) = expsetup.stim.eframes_response_ring_on{tid}(c1_frame_index1,1);
            elseif expsetup.stim.eframes_response_ring_on{tid}(c1_frame_index1,1)==0
                ind = expsetup.stim.eframes_response_ring_on{tid}(1:c1_frame_index1,1);
                ind = ind(ind>0);
                expsetup.stim.edata_lever_response(tid,1) = ind(end); % Save last associated target
            end
            
            % Determine whether correct target was selected
            if expsetup.stim.edata_lever_response(tid,1) == expsetup.stim.esetup_probe_change(tid,1)
                expsetup.stim.edata_error_code{tid} = 'correct';
            elseif expsetup.stim.edata_lever_response(tid,1) ~= expsetup.stim.esetup_probe_change(tid,1)
                expsetup.stim.edata_error_code{tid} = 'probe response error';
            end
            
        end
    end
    
    %===================
    % For initial lever hold training, check whether duration was reached
    %===================
    if strcmp(expsetup.stim.esetup_exp_version{tid}, 'lever hold training')
        
        if ~isnan(expsetup.stim.edata_lever_on(tid,1))
            
            % Time
            timer1_now = expsetup.stim.eframes_time{tid}(c1_frame_index1, 1);
            %
            timer1_start = expsetup.stim.edata_lever_on(tid,1);
            %
            timer1_duration = expsetup.stim.esetup_train_trial_duration(tid,1);
            
            if timer1_now - timer1_start < timer1_duration % Record an error
                if isnan(expsetup.stim.edata_lever_off(tid,1))
                    % Proceed with trial
                elseif ~isnan(expsetup.stim.edata_lever_off(tid,1))
                    expsetup.stim.edata_error_code{tid} = 'lever hold failure';
                end
            elseif timer1_now - timer1_start >= timer1_duration % Record an error
                expsetup.stim.edata_error_code{tid} = 'correct';
            end
            
        end
    end
    
    
    %% If its the last frame, save few missing parameters & terminate
    
    % If run out of frames  - end trial (should never happen)
    if c1_frame_index1==size(expsetup.stim.eframes_time{tid},1)
        loop_over = 1;
    end
    
    % If error - end trial
    if ~isnan(expsetup.stim.edata_error_code{tid})
        loop_over = 1;
    end
    
    % If rings disappear - end trial
    if expsetup.stim.eframes_response_ring_off{tid}(c1_frame_index1,1) == 1
        loop_over = 1;
    end
    
end

% Reduce trialmat in size (save only frames that are used)
if c1_frame_index1+1<size(expsetup.stim.eframes_time{tid},1)
    f1 = fieldnames(expsetup.stim);
    ind = strncmp(f1,'eframes', 7);
    for i=1:numel(ind)
        if ind(i)==1
            if iscell(expsetup.stim.(f1{i}))
                expsetup.stim.(f1{i}){tid}(c1_frame_index1+1:end,:,:) = [];
            end
        end
    end
end

% Clear off all the screens
Screen('FillRect', window, expsetup.stim.background_color);
if expsetup.general.record_plexon==1
    Screen('FillRect', window, [0, 0, 0], ph_rect, 1);
end
[~, time_current, ~]=Screen('Flip', window);

% Close texture
if exist('tex')
    try
        Screen('Close', tex);
    end
end

% Plexon message that display is cleared
% Individual event mode (EVENT 2)
if expsetup.general.record_plexon==1
    a1 = zeros(1,expsetup.ni_daq.digital_channel_total);
    a1_s = expsetup.general.plex_event_end; % Channel number used for events
    a1(a1_s)=1;
    outputSingleScan(ni.session_plexon_events,a1);
    a1 = zeros(1,expsetup.ni_daq.digital_channel_total);
    outputSingleScan(ni.session_plexon_events,a1);
end


% Save eyelink and psychtoolbox events
if expsetup.general.recordeyes==1
    Eyelink('Message', 'loop_over');
end
expsetup.stim.edata_loop_over(tid,1) = time_current;


% Print trial duration
t1 = expsetup.stim.edata_loop_over(tid,1);
t0 = expsetup.stim.edata_first_display(tid,1);
fprintf('Trial duration (from first display to reward) was %i ms \n', round((t1-t0)*1000))
fprintf('Trial evaluation: %s\n', expsetup.stim.edata_error_code{tid})


% Clear eyelink screen
if expsetup.general.recordeyes==1
    Eyelink('command','clear_screen 0');
end

% Clear off all the screens again
Screen('FillRect', window, expsetup.stim.background_color);
[~, time_current, ~]=Screen('Flip', window);



%% Online performance tracking

% Check whether trial is counted towards online performance tracking. In
% some cases correct trials can be discounted.

% Check whether trial is counted towards online performance tracking. In
% some cases correct trials can be discounted.

if strcmp(expsetup.stim.esetup_exp_version{tid}, 'final version') ||...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'single target same orientation one ring') ||...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'single target same orientation two rings') ||...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'single target orientation change one ring') ||...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'single target orientation change two rings') ||...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'single target interleaved') ||...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'reduce target size') ||...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'introduce gabor phase change') ||...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'introduce distractors')  || ...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'distractor contrast stable') ||...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'add background texture')  || ...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'decrease att cue length') || ...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'increase probe isi') ||...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'introduce probe angle difference')
    
    
    %==========
    if strcmp(expsetup.stim.edata_error_code{tid}, 'correct')
        expsetup.stim.edata_trial_online_counter(tid,1) = 1;
    elseif strcmp(expsetup.stim.edata_error_code{tid}, 'probe response error') || strcmp(expsetup.stim.edata_error_code{tid}, 'experimenter terminated the trial')
        expsetup.stim.edata_trial_online_counter(tid,1) = 2;
    end
    %=========

elseif strcmp(expsetup.stim.esetup_exp_version{tid}, 'lever hold training')
    %==========
    if strcmp(expsetup.stim.edata_error_code{tid}, 'correct')
        expsetup.stim.edata_trial_online_counter(tid,1) = 1;
    elseif strcmp(expsetup.stim.edata_error_code{tid}, 'lever hold failure') || strcmp(expsetup.stim.edata_error_code{tid}, 'experimenter terminated the trial')
        expsetup.stim.edata_trial_online_counter(tid,1) = 2;
    end
    %=========

elseif strcmp(expsetup.stim.esetup_exp_version{tid}, 'release lever on long ring') ||...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'release lever on big ring')
    %==========
    if strcmp(expsetup.stim.edata_error_code{tid}, 'correct')
        expsetup.stim.edata_trial_online_counter(tid,1) = 1;
    elseif  strcmp(expsetup.stim.edata_error_code{tid}, 'lever not released') || ...
            strcmp(expsetup.stim.edata_error_code{tid}, 'experimenter terminated the trial')
        expsetup.stim.edata_trial_online_counter(tid,1) = 2;
    end
    %=========
    
else
    error ('Condition for correct/error trial tracking not specified')
end

%% Trial feedback

% Plot reward image onscreen
if expsetup.general.human_exp==1 || expsetup.stim.reward_feedback==1
    
    if strcmp(expsetup.stim.edata_error_code{tid}, 'correct') || strcmp(char, 'r')
        Screen('FillRect', window, tex_positive_background_color);
        Screen('DrawTexture', window, tex_positive, [], reward_rect, [], 0);
        [~, time_current, ~]=Screen('Flip', window);
    else
        Screen('FillRect', window, tex_negative_background_color);
        Screen('DrawTexture',window, tex_negative, [], reward_rect, [], 0);
        [~, time_current, ~]=Screen('Flip', window);
    end
    
    if isnan(expsetup.stim.edata_reward_image_on(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'reward_image_on');
        end
        expsetup.stim.edata_reward_image_on(tid,1) = time_current;
    end
end
    
% Auditory feedback
if expsetup.general.human_exp==1 || expsetup.stim.reward_feedback==2  
    
    if isnan(expsetup.stim.edata_reward_image_on(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'reward_image_on');
        end
        expsetup.stim.edata_reward_image_on(tid,1) = time_current;
    end
    
    if strcmp(expsetup.stim.edata_error_code{tid}, 'correct') || strcmp(char, 'r')
        b1 = MakeBeep(600, 0.05);
        b2 = MakeBeep(800, 0.05);
        beep = [b1, b2];
        Snd('Play', beep);
        WaitSecs(expsetup.stim.reward_feedback_audio_dur);
    elseif strcmp(expsetup.stim.edata_error_code{tid}, 'looked at distractor') % Wrong target selected
        b1 = MakeBeep(600, 0.05);
        b2 = MakeBeep(200, 0.05);
        beep = [b1, b2];
        Snd('Play', beep);
        WaitSecs(expsetup.stim.reward_feedback_audio_dur);
    else
        b1 = sin(0:2000);
        beep = [b1, b1];
        Snd('Play', beep);
        WaitSecs(expsetup.stim.reward_feedback_audio_dur);
    end
end

% Arduino feedback
if expsetup.stim.reward_feedback==3 && isfield (expsetup.general, 'arduino_session')
    
    if isnan(expsetup.stim.edata_reward_image_on(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'reward_image_on');
        end
        expsetup.stim.edata_reward_image_on(tid,1) = time_current;
    end
    
    if strcmp(expsetup.stim.edata_error_code{tid}, 'correct') || strcmp(char, 'r')
        playTone(expsetup.general.arduino_session, 'D10', 600, 0.05);
        playTone(expsetup.general.arduino_session, 'D10', 800, 0.05);
        WaitSecs(expsetup.stim.reward_feedback_audio_dur);
    elseif strcmp(expsetup.stim.edata_error_code{tid}, 'looked at distractor') % Wrong target selected
        playTone(expsetup.general.arduino_session, 'D10', 600, 0.05);
        playTone(expsetup.general.arduino_session, 'D10', 200, 0.1);
        WaitSecs(expsetup.stim.reward_feedback_audio_dur);
    else
        playTone(expsetup.general.arduino_session, 'D10', 100, 0.2);
        WaitSecs(expsetup.stim.reward_feedback_audio_dur);
    end
    
    
end


%% Start reward

% Prepare reward signal
if expsetup.general.human_exp~=1 && expsetup.general.reward_on==1
    if strcmp(expsetup.stim.edata_error_code{tid}, 'correct') || strcmp(char, 'r')
        % Continous reward
        reward_duration = expsetup.stim.reward_size_ms;
        signal1 = linspace(expsetup.ni_daq.reward_voltage, expsetup.ni_daq.reward_voltage, reward_duration)';
        signal1 = [0; signal1; 0; 0; 0; 0; 0];
        queueOutputData(ni.session_reward, signal1);        
    end
end

if expsetup.general.human_exp~=1 && expsetup.general.reward_on == 1
    if strcmp(expsetup.stim.edata_error_code{tid}, 'correct') || strcmp(char, 'r')
        ni.session_reward.startForeground;
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'reward_on');
        end
        expsetup.stim.edata_reward_on(tid) = GetSecs;
        % Save how much reward was given
        expsetup.stim.edata_reward_size_ms(tid,1)=expsetup.stim.reward_size_ms;
        expsetup.stim.edata_reward_size_ml(tid,1)=expsetup.stim.reward_size_ml;
    else
        % Save how much reward was given
        expsetup.stim.edata_reward_size_ms(tid,1)=0;
        expsetup.stim.edata_reward_size_ml(tid,1)=0;
    end
end

%% Make sure the space bar is released

if strcmp(char,'space') % If space bar was last key recorded
    
    timer1_now = GetSecs;
    time_start = GetSecs;
    trial_duration = expsetup.stim.lever_press_penalty;
    
    % Record what kind of button was pressed
    [keyIsDown,timeSecs,keyCode] = KbCheck;
    char = KbName(keyCode);
    % Catch potential press of two buttons
    if iscell(char)
        char=char{1};
    end
    
    % Check whether space is pressed now
    if keyIsDown==1 && strcmp(char,'space')
        endloop_skip = 0;
    else
        endloop_skip = 1;
    end
    
    % Loop for 30 seconds before space is released
    while endloop_skip == 0
        
        % Record what kind of button was pressed
        [keyIsDown,timeSecs,keyCode] = KbCheck;
        char = KbName(keyCode);
        % Catch potential press of two buttons
        if iscell(char)
            char=char{1};
        end
        
        if keyIsDown==0
            % End loop
            endloop_skip=1;
        else
            % Check time & quit loop
            timer1_now = GetSecs;
            if timer1_now - time_start >= trial_duration
                endloop_skip=1;
            end
        end
    end
    
end

%% Inter-trial interval & possibility to add extra reward

timer1_now = GetSecs;
time_start = GetSecs;
if strcmp(expsetup.stim.edata_error_code{tid}, 'correct') 
    trial_duration = expsetup.stim.trial_dur_intertrial;
else % Error trials
    trial_duration = expsetup.stim.trial_dur_intertrial_error;
end

if strcmp(char,'x') || strcmp(char,'r') || strcmp(char,'c') || strcmp(char,'p') || strcmp(char,'space')
    endloop_skip = 1;
else
    endloop_skip = 0;
end

while endloop_skip == 0
    
    % Record what kind of button was pressed
    [keyIsDown,timeSecs,keyCode] = KbCheck;
    char = KbName(keyCode);
    % Catch potential press of two buttons
    if iscell(char)
        char=char{1};
    end
    
    % Give reward
    if  strcmp(char,'r')
        
        % Prepare reward signal
        if expsetup.general.human_exp~=1 && expsetup.general.reward_on==1
            % Continous reward
            reward_duration = expsetup.stim.reward_size_ms;
            signal1 = linspace(expsetup.ni_daq.reward_voltage, expsetup.ni_daq.reward_voltage, reward_duration)';
            signal1 = [0; signal1; 0; 0; 0; 0; 0];
            queueOutputData(ni.session_reward, signal1);
        end
        
        if expsetup.general.human_exp~=1 && expsetup.general.reward_on == 1
            ni.session_reward.startForeground;
            if expsetup.general.recordeyes==1
                Eyelink('Message', 'reward_on');
            end
            expsetup.stim.edata_reward_on(tid) = GetSecs;
            % Save how much reward was given
            expsetup.stim.edata_reward_size_ms(tid,1)=expsetup.stim.reward_size_ms;
            expsetup.stim.edata_reward_size_ml(tid,1)=expsetup.stim.reward_size_ml;
        end
        
        % End loop
        endloop_skip=1;
        
    elseif strcmp(char,'x') || strcmp(char,'p') || strcmp(char,'c')
        
        % End loop
        endloop_skip=1;
        
    end
    
    % Check time & quit loop
    timer1_now = GetSecs;
    if timer1_now - time_start >= trial_duration
        endloop_skip=1;
    end
    
end


%% Trigger new trial

Screen('FillRect', window, expsetup.stim.background_color);
Screen('Flip', window);


%% Plot online data

% If plexon recording exists, get spikes
if expsetup.general.record_plexon == 1 && expsetup.general.plexon_online_spikes == 1
    att1_online_spikes;
    att1_online_plot;
end

if expsetup.general.record_plexon == 0
    att1_online_plot;
end



%% Stop experiment if too many errors in a row

if strcmp(expsetup.stim.edata_error_code{tid}, 'lever not acquired in time')
    % Trial failed
    expsetup.stim.edata_trial_abort_counter(tid,1) = 1;
end

% Add pause if trials are not accurate
if tid>=expsetup.stim.trial_abort_counter
    ind1 = tid-expsetup.stim.trial_abort_counter+1:tid;
    s1 = expsetup.stim.edata_trial_abort_counter(ind1, 1)==1;
    if sum(s1) == expsetup.stim.trial_abort_counter
        if ~strcmp(char,expsetup.general.quit_key')
            char='x';
            % Over-write older trials
            expsetup.stim.edata_trial_abort_counter(ind1, 1) = 2000;
        end
    end
end


%% STOP EYELINK RECORDING

if expsetup.general.recordeyes==1
    msg1=['TrialEnd ',num2str(tid)];
    Eyelink('Message', msg1);
    Eyelink('StopRecording');
end

fprintf('  \n')

%% End experiment (only on final training version)

if strcmp(expsetup.stim.esetup_exp_version{tid}, 'final version')
    ind1 = strcmp(expsetup.stim.esetup_exp_version, 'final version');
    if sum(ind1)>=expsetup.stim.final_version_trial_number
        expsetup.stim.end_experiment = 1;
    end
    
    
    
else
    expsetup.stim.end_experiment = 0;
end


if tid==1000
else
    expsetup.stim.end_experiment = 0;
end

        

