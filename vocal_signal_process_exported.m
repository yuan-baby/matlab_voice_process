classdef vocal_signal_process_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        Label_7                  matlab.ui.control.Label
        Button_reductNoise_2     matlab.ui.control.Button
        Button_play_addNoise     matlab.ui.control.Button
        Button_addNoise          matlab.ui.control.Button
        tone                     matlab.ui.control.Spinner
        Label_6                  matlab.ui.control.Label
        Button_play_reductNoise  matlab.ui.control.Button
        Button_play_tone         matlab.ui.control.Button
        Button_play_speed        matlab.ui.control.Button
        Speed                    matlab.ui.control.Spinner
        Label_5                  matlab.ui.control.Label
        Label_3                  matlab.ui.control.Label
        Button_recResume         matlab.ui.control.Button
        Button_recPause          matlab.ui.control.Button
        Button_recStop           matlab.ui.control.Button
        Button_recOn             matlab.ui.control.Button
        Name                     matlab.ui.control.Label
        Button_off               matlab.ui.control.Button
        Button_reductNoise       matlab.ui.control.Button
        Button_play              matlab.ui.control.Button
        UIAxes5_2                matlab.ui.control.UIAxes
        UIAxes_5                 matlab.ui.control.UIAxes
        UIAxes4_2                matlab.ui.control.UIAxes
        UIAxes_4                 matlab.ui.control.UIAxes
        UIAxes3_2                matlab.ui.control.UIAxes
        UIAxes_3                 matlab.ui.control.UIAxes
        UIAxes2_2                matlab.ui.control.UIAxes
        UIAxes2                  matlab.ui.control.UIAxes
        UIAxes_2                 matlab.ui.control.UIAxes
        UIAxes                   matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        recObj % 录入的原始信号
        speedData % 变速信号
        toneData % 变调信号
        addNoiseData % 加噪信号
        reductNoiseData % 降噪信号
        fs % 采样频率
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: Button_recOn
        function Button_recOnPushed(app, event)
            app.fs = 44100;
            app.recObj = audiorecorder(app.fs,16,1);
            record(app.recObj);
        end

        % Button pushed function: Button_recPause
        function Button_recPausePushed(app, event)
            pause(app.recObj);
        end

        % Button pushed function: Button_recResume
        function Button_recResumePushed(app, event)
            resume(app.recObj);
        end

        % Callback function: Button_recStop, UIAxes, UIAxes_2
        function Button_recStopPushed(app, event)
            stop(app.recObj);
            audioData = getaudiodata(app.recObj);
            % 时域图
            t = (1:length(audioData))/app.fs;
            plot(app.UIAxes, t, audioData);
            %频域图
            n = length(audioData);
            f = (0:n-1)*(app.fs/n);
            Y = fft(audioData);
            P2 = abs(Y/n);
            P1 = P2(1:n/2+1);
            P1(2:end-1) = 2*P1(2:end-1);
            plot(app.UIAxes_2, f(1:n/2+1), P1);
            %保存数据
            filename = 'MySpeech.wav';
            audiowrite(filename, audioData, app.recObj.SampleRate);
        end

        % Button pushed function: Button_play
        function Button_playPushed(app, event)
            audioData = getaudiodata(app.recObj);
            sound(audioData, app.recObj.SampleRate);
        end

        % Button pushed function: Button_off
        function Button_offPushed(app, event)
            delete(app.UIFigure);
        end

        % Value changed function: Speed
        function SpeedValueChanged(app, event)
            alpha = app.Speed.Value;
            audioData = getaudiodata(app.recObj);
            app.speedData = stretchAudio(audioData,alpha);
        end

        % Value changed function: tone
        function toneValueChanged(app, event)
            semitones = app.tone.Value;
            audioData = getaudiodata(app.recObj);
            app.toneData = shiftPitch(audioData,semitones);
        end

        % Button pushed function: Button_reductNoise
        function Button_reductNoisePushed(app, event)
            % 谱减法
            noise_estimated=app.addNoiseData(1:1*app.fs,1);              %将前1秒的信号作为估计的噪声
            fft_addNoise=fft(app.addNoiseData);        %对加噪语音进行FFT
            phase_fft_addNoise=angle(fft_addNoise);       %取带噪语音的相位作为最终相位
            fft_noise_estimated=fft(noise_estimated);      %对噪声进行FFT
            mag_signal=abs(fft_addNoise)-sum(abs(fft_noise_estimated))/length(fft_noise_estimated);    %恢复出来的幅度
            mag_signal(mag_signal<0)=0;         %将小于0的部分置为0
             % 恢复语音信号
            fft_s = mag_signal .* exp(1i.*phase_fft_addNoise);
            s = ifft(fft_s);
            app.reductNoiseData = real(s);
        end

        % Callback function: Button_play_speed, UIAxes2, UIAxes2_2
        function Button_play_speedPushed(app, event)
            sound(app.speedData, app.recObj.SampleRate);
            % 时域图
            t = (1:length(app.speedData))/app.fs;
            plot(app.UIAxes2, t,app.speedData);
            %频域图
            n = length(app.speedData);
            f = (0:n-1)*(app.fs/n);
            Y = fft(app.speedData);
            P2 = abs(Y/n);
            P1 = P2(1:n/2+1);
            P1(2:end-1) = 2*P1(2:end-1);
            plot(app.UIAxes2_2, f(1:n/2+1), P1);
        end

        % Callback function: Button_play_tone, UIAxes3_2, UIAxes_3
        function Button_play_tonePushed(app, event)

            sound(app.toneData, app.recObj.SampleRate);
            % 时域图
            t = (1:length(app.toneData))/app.fs;
            plot(app.UIAxes_3, t,app.toneData);
            %频域图
            n = length(app.toneData);
            f = (0:n-1)*(app.fs/n);
            Y = fft(app.toneData);
            P2 = abs(Y/n);
            P1 = P2(1:n/2+1);
            P1(2:end-1) = 2*P1(2:end-1);
            plot(app.UIAxes3_2, f(1:n/2+1), P1);
        end

        % Callback function: Button_play_reductNoise, UIAxes4_2, UIAxes_4
        function Button_play_noisePushed(app, event)

            sound(app.reductNoiseData, app.fs);
            % 时域图
            t = (1:length(app.reductNoiseData))/app.fs;
            plot(app.UIAxes_4, t,app.reductNoiseData);
            %频域图
            n = length(app.reductNoiseData);
            f = (0:n-1)*(app.fs/n);
            Y = fft(app.reductNoiseData);
            P2 = abs(Y/n);
            P1 = P2(1:n/2+1);
            P1(2:end-1) = 2*P1(2:end-1);
            plot(app.UIAxes4_2, f(1:n/2+1), P1);
        end

        % Button pushed function: Button_addNoise
        function Button_addNoisePushed(app, event)
            audioData = getaudiodata(app.recObj);
            % 正态分布的噪声
            noise1 = 10 * randn(size(audioData));
            noise1(noise1>0.1) = 0;
            noise1(noise1<-0.1) = 0;
            % 正弦噪声
            Fs = app.fs;
            t = (0:length(audioData)-1)/Fs; % 时间轴
            t = t';
            f = 440; % 正弦噪声的频率
            A = 0.01; % 正弦噪声的振幅
            noise2 = A*sin(2*pi*f*t); % 生成正弦噪声
            noise = noise1 + noise2;
            % 加噪
            SNR=20;                 %信噪比大小
            noise=noise/norm(noise,2).*10^(-SNR/20)*norm(audioData);     
            app.addNoiseData = audioData + noise;          %产生固定信噪比的带噪语音
        end

        % Callback function: Button_play_addNoise, UIAxes5_2, UIAxes_5
        function Button_play_addNoisePushed(app, event)
            sound(app.addNoiseData, app.fs);
            % 时域图
            t = (1:length(app.addNoiseData))/app.fs;
            plot(app.UIAxes_5, t,app.addNoiseData);
            %频域图
            n = length(app.addNoiseData);
            f = (0:n-1)*(app.fs/n);
            Y = fft(app.addNoiseData);
            P2 = abs(Y/n);
            P1 = P2(1:n/2+1);
            P1(2:end-1) = 2*P1(2:end-1);
            plot(app.UIAxes5_2, f(1:n/2+1), P1);
        end

        % Button pushed function: Button_reductNoise_2
        function Button_reductNoise_2Pushed(app, event)
            % 设计低通滤波器
            fcut = 8000; % 截止频率
            Fs = 44100;
            Wn = fcut / (Fs/2); % 归一化截止频率
            [b,a] = butter(6,Wn,'low'); % 设计6阶低通巴特沃斯滤波器
            % 过滤
            audioData = getaudiodata(app.recObj);
            app.reductNoiseData = filter(b,a,audioData);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 647 494];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, '原信号时域图')
            xlabel(app.UIAxes, 't(s)')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.FontName = '黑体';
            app.UIAxes.FontSize = 14;
            app.UIAxes.ButtonDownFcn = createCallbackFcn(app, @Button_recStopPushed, true);
            app.UIAxes.Position = [1 379 153 116];

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.UIFigure);
            title(app.UIAxes_2, '原信号频域图')
            xlabel(app.UIAxes_2, 'f(Hz)')
            zlabel(app.UIAxes_2, 'Z')
            app.UIAxes_2.FontName = '黑体';
            app.UIAxes_2.FontSize = 14;
            app.UIAxes_2.ButtonDownFcn = createCallbackFcn(app, @Button_recStopPushed, true);
            app.UIAxes_2.Position = [168 379 153 116];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.UIFigure);
            title(app.UIAxes2, '变速信号时域图')
            xlabel(app.UIAxes2, 't(s)')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontName = '黑体';
            app.UIAxes2.FontSize = 14;
            app.UIAxes2.ButtonDownFcn = createCallbackFcn(app, @Button_play_speedPushed, true);
            app.UIAxes2.Position = [1 257 153 116];

            % Create UIAxes2_2
            app.UIAxes2_2 = uiaxes(app.UIFigure);
            title(app.UIAxes2_2, '变速信号频域图')
            xlabel(app.UIAxes2_2, 'f(Hz)')
            zlabel(app.UIAxes2_2, 'Z')
            app.UIAxes2_2.FontName = '黑体';
            app.UIAxes2_2.FontSize = 14;
            app.UIAxes2_2.ButtonDownFcn = createCallbackFcn(app, @Button_play_speedPushed, true);
            app.UIAxes2_2.Position = [168 257 153 116];

            % Create UIAxes_3
            app.UIAxes_3 = uiaxes(app.UIFigure);
            title(app.UIAxes_3, '变调信号时域图')
            xlabel(app.UIAxes_3, 't(s)')
            zlabel(app.UIAxes_3, 'Z')
            app.UIAxes_3.FontName = '黑体';
            app.UIAxes_3.FontSize = 14;
            app.UIAxes_3.ButtonDownFcn = createCallbackFcn(app, @Button_play_tonePushed, true);
            app.UIAxes_3.Position = [1 139 153 116];

            % Create UIAxes3_2
            app.UIAxes3_2 = uiaxes(app.UIFigure);
            title(app.UIAxes3_2, '变调信号频域图')
            xlabel(app.UIAxes3_2, 'f(Hz)')
            zlabel(app.UIAxes3_2, 'Z')
            app.UIAxes3_2.FontName = '黑体';
            app.UIAxes3_2.FontSize = 14;
            app.UIAxes3_2.ButtonDownFcn = createCallbackFcn(app, @Button_play_tonePushed, true);
            app.UIAxes3_2.Position = [168 139 153 116];

            % Create UIAxes_4
            app.UIAxes_4 = uiaxes(app.UIFigure);
            title(app.UIAxes_4, '去噪信号时域图')
            xlabel(app.UIAxes_4, 't(s)')
            zlabel(app.UIAxes_4, 'Z')
            app.UIAxes_4.FontName = '黑体';
            app.UIAxes_4.FontSize = 14;
            app.UIAxes_4.ButtonDownFcn = createCallbackFcn(app, @Button_play_noisePushed, true);
            app.UIAxes_4.Position = [1 18 153 116];

            % Create UIAxes4_2
            app.UIAxes4_2 = uiaxes(app.UIFigure);
            title(app.UIAxes4_2, '去噪信号频域图')
            xlabel(app.UIAxes4_2, 'f(Hz)')
            zlabel(app.UIAxes4_2, 'Z')
            app.UIAxes4_2.FontName = '黑体';
            app.UIAxes4_2.FontSize = 14;
            app.UIAxes4_2.ButtonDownFcn = createCallbackFcn(app, @Button_play_noisePushed, true);
            app.UIAxes4_2.Position = [168 18 153 116];

            % Create UIAxes_5
            app.UIAxes_5 = uiaxes(app.UIFigure);
            title(app.UIAxes_5, '加噪信号时域图')
            xlabel(app.UIAxes_5, 't(s)')
            zlabel(app.UIAxes_5, 'Z')
            app.UIAxes_5.FontName = '黑体';
            app.UIAxes_5.FontSize = 14;
            app.UIAxes_5.ButtonDownFcn = createCallbackFcn(app, @Button_play_addNoisePushed, true);
            app.UIAxes_5.Position = [320 18 153 116];

            % Create UIAxes5_2
            app.UIAxes5_2 = uiaxes(app.UIFigure);
            title(app.UIAxes5_2, '加噪信号频域图')
            xlabel(app.UIAxes5_2, 'f(Hz)')
            zlabel(app.UIAxes5_2, 'Z')
            app.UIAxes5_2.FontName = '黑体';
            app.UIAxes5_2.FontSize = 14;
            app.UIAxes5_2.ButtonDownFcn = createCallbackFcn(app, @Button_play_addNoisePushed, true);
            app.UIAxes5_2.Position = [487 18 153 116];

            % Create Button_play
            app.Button_play = uibutton(app.UIFigure, 'push');
            app.Button_play.ButtonPushedFcn = createCallbackFcn(app, @Button_playPushed, true);
            app.Button_play.FontName = '黑体';
            app.Button_play.FontSize = 14;
            app.Button_play.Position = [372 240 100 27];
            app.Button_play.Text = '播放原音频';

            % Create Button_reductNoise
            app.Button_reductNoise = uibutton(app.UIFigure, 'push');
            app.Button_reductNoise.ButtonPushedFcn = createCallbackFcn(app, @Button_reductNoisePushed, true);
            app.Button_reductNoise.FontName = '黑体';
            app.Button_reductNoise.FontSize = 14;
            app.Button_reductNoise.Position = [476 280 56 26];
            app.Button_reductNoise.Text = '谱减法';

            % Create Button_off
            app.Button_off = uibutton(app.UIFigure, 'push');
            app.Button_off.ButtonPushedFcn = createCallbackFcn(app, @Button_offPushed, true);
            app.Button_off.BackgroundColor = [1 1 0.0667];
            app.Button_off.FontName = '黑体';
            app.Button_off.FontSize = 14;
            app.Button_off.Position = [570 453 46 26];
            app.Button_off.Text = '退出';

            % Create Name
            app.Name = uilabel(app.UIFigure);
            app.Name.FontName = '黑体';
            app.Name.FontSize = 24;
            app.Name.Position = [356 453 198 33];
            app.Name.Text = '语音信号处理系统';

            % Create Button_recOn
            app.Button_recOn = uibutton(app.UIFigure, 'push');
            app.Button_recOn.ButtonPushedFcn = createCallbackFcn(app, @Button_recOnPushed, true);
            app.Button_recOn.FontName = '黑体';
            app.Button_recOn.FontSize = 14;
            app.Button_recOn.Position = [372 412 100 26];
            app.Button_recOn.Text = '开始';

            % Create Button_recStop
            app.Button_recStop = uibutton(app.UIFigure, 'push');
            app.Button_recStop.ButtonPushedFcn = createCallbackFcn(app, @Button_recStopPushed, true);
            app.Button_recStop.FontName = '黑体';
            app.Button_recStop.FontSize = 14;
            app.Button_recStop.Position = [514 412 100 26];
            app.Button_recStop.Text = '结束';

            % Create Button_recPause
            app.Button_recPause = uibutton(app.UIFigure, 'push');
            app.Button_recPause.ButtonPushedFcn = createCallbackFcn(app, @Button_recPausePushed, true);
            app.Button_recPause.FontName = '黑体';
            app.Button_recPause.FontSize = 14;
            app.Button_recPause.Position = [372 375 100 26];
            app.Button_recPause.Text = '暂停';

            % Create Button_recResume
            app.Button_recResume = uibutton(app.UIFigure, 'push');
            app.Button_recResume.ButtonPushedFcn = createCallbackFcn(app, @Button_recResumePushed, true);
            app.Button_recResume.FontName = '黑体';
            app.Button_recResume.FontSize = 14;
            app.Button_recResume.Position = [513 375 100 26];
            app.Button_recResume.Text = '继续录制';

            % Create Label_3
            app.Label_3 = uilabel(app.UIFigure);
            app.Label_3.FontName = '黑体';
            app.Label_3.FontSize = 14;
            app.Label_3.Position = [335 398 33 22];
            app.Label_3.Text = '录音';

            % Create Label_5
            app.Label_5 = uilabel(app.UIFigure);
            app.Label_5.HorizontalAlignment = 'right';
            app.Label_5.FontName = '黑体';
            app.Label_5.FontSize = 14;
            app.Label_5.Position = [359 330 33 22];
            app.Label_5.Text = '速度';

            % Create Speed
            app.Speed = uispinner(app.UIFigure);
            app.Speed.Step = 0.1;
            app.Speed.Limits = [0.1 Inf];
            app.Speed.ValueChangedFcn = createCallbackFcn(app, @SpeedValueChanged, true);
            app.Speed.FontName = '黑体';
            app.Speed.FontSize = 14;
            app.Speed.Position = [407 330 59 22];
            app.Speed.Value = 1;

            % Create Button_play_speed
            app.Button_play_speed = uibutton(app.UIFigure, 'push');
            app.Button_play_speed.ButtonPushedFcn = createCallbackFcn(app, @Button_play_speedPushed, true);
            app.Button_play_speed.FontName = '黑体';
            app.Button_play_speed.FontSize = 14;
            app.Button_play_speed.Position = [513 240 102 27];
            app.Button_play_speed.Text = '播放变速音频';

            % Create Button_play_tone
            app.Button_play_tone = uibutton(app.UIFigure, 'push');
            app.Button_play_tone.ButtonPushedFcn = createCallbackFcn(app, @Button_play_tonePushed, true);
            app.Button_play_tone.FontName = '黑体';
            app.Button_play_tone.FontSize = 14;
            app.Button_play_tone.Position = [371 195 102 27];
            app.Button_play_tone.Text = '播放变调音频';

            % Create Button_play_reductNoise
            app.Button_play_reductNoise = uibutton(app.UIFigure, 'push');
            app.Button_play_reductNoise.ButtonPushedFcn = createCallbackFcn(app, @Button_play_noisePushed, true);
            app.Button_play_reductNoise.FontName = '黑体';
            app.Button_play_reductNoise.FontSize = 14;
            app.Button_play_reductNoise.Position = [513 195 100 27];
            app.Button_play_reductNoise.Text = '播放降噪音频';

            % Create Label_6
            app.Label_6 = uilabel(app.UIFigure);
            app.Label_6.HorizontalAlignment = 'right';
            app.Label_6.FontName = '黑体';
            app.Label_6.FontSize = 14;
            app.Label_6.Position = [507 330 33 22];
            app.Label_6.Text = '音调';

            % Create tone
            app.tone = uispinner(app.UIFigure);
            app.tone.ValueChangedFcn = createCallbackFcn(app, @toneValueChanged, true);
            app.tone.FontName = '黑体';
            app.tone.FontSize = 14;
            app.tone.Position = [555 330 60 22];

            % Create Button_addNoise
            app.Button_addNoise = uibutton(app.UIFigure, 'push');
            app.Button_addNoise.ButtonPushedFcn = createCallbackFcn(app, @Button_addNoisePushed, true);
            app.Button_addNoise.FontName = '黑体';
            app.Button_addNoise.FontSize = 14;
            app.Button_addNoise.Position = [372 280 46 26];
            app.Button_addNoise.Text = '加噪';

            % Create Button_play_addNoise
            app.Button_play_addNoise = uibutton(app.UIFigure, 'push');
            app.Button_play_addNoise.ButtonPushedFcn = createCallbackFcn(app, @Button_play_addNoisePushed, true);
            app.Button_play_addNoise.FontName = '黑体';
            app.Button_play_addNoise.FontSize = 14;
            app.Button_play_addNoise.Position = [372 150 102 27];
            app.Button_play_addNoise.Text = '播放加噪音频';

            % Create Button_reductNoise_2
            app.Button_reductNoise_2 = uibutton(app.UIFigure, 'push');
            app.Button_reductNoise_2.ButtonPushedFcn = createCallbackFcn(app, @Button_reductNoise_2Pushed, true);
            app.Button_reductNoise_2.FontName = '黑体';
            app.Button_reductNoise_2.FontSize = 14;
            app.Button_reductNoise_2.Position = [543 280 72 26];
            app.Button_reductNoise_2.Text = '低通滤波';

            % Create Label_7
            app.Label_7 = uilabel(app.UIFigure);
            app.Label_7.FontName = '黑体';
            app.Label_7.FontSize = 14;
            app.Label_7.Position = [437 282 33 22];
            app.Label_7.Text = '降噪';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = vocal_signal_process_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end