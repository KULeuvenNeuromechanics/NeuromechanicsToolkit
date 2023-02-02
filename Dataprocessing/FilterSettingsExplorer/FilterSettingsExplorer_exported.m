classdef FilterSettingsExplorer_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        LeftPanel                       matlab.ui.container.Panel
        ItemListBox                     matlab.ui.control.ListBox
        ItemListBoxLabel                matlab.ui.control.Label
        LowpassfiltersettingsLabel      matlab.ui.control.Label
        RectifydataButtonGroup          matlab.ui.container.ButtonGroup
        NoButton                        matlab.ui.control.RadioButton
        YesButton                       matlab.ui.control.RadioButton
        BandpassfiltersettingsLabel     matlab.ui.control.Label
        CutofffrequencySlider           matlab.ui.control.Slider
        CutofffrequencySliderLabel      matlab.ui.control.Label
        HighcutofffrequencySlider       matlab.ui.control.Slider
        HighcutofffrequencySliderLabel  matlab.ui.control.Label
        ButtterworthorderSpinner        matlab.ui.control.Spinner
        ButtterworthorderSpinnerLabel   matlab.ui.control.Label
        LowcutofffrequencySlider        matlab.ui.control.Slider
        LowcutofffrequencySliderLabel   matlab.ui.control.Label
        RightPanel                      matlab.ui.container.Panel
        LoadfileButton                  matlab.ui.control.Button
        UIAxes2                         matlab.ui.control.UIAxes
        UIAxes                          matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    
    properties (Access = private)
        raw_file % raw_file
        raw_data % struct containing the struct that has the data
        fn % fieldname containing the data
        freq;
    end
    
    methods (Access = private)
                
        function update_figure(app)
                load(app.raw_file);
                app.raw_data = load(app.raw_file);
                app.fn = fieldnames(app.raw_data);


                order = app.ButtterworthorderSpinner.Value;
                cutoff_band = [app.LowcutofffrequencySlider.Value app.HighcutofffrequencySlider.Value];
                cutoff_low = app.CutofffrequencySlider.Value;
                item = app.ItemListBox.Value;

                col = find(strcmp(app.raw_data.(app.fn{1}).colheaders,item));

                data = app.raw_data.(app.fn{1}).data(:,col);
                
                [a,b] = butter(order,cutoff_band./(app.freq/2),'bandpass');
                data_band = filtfilt(a,b,data);

                if app.YesButton.Value
                    data_rect = abs(data_band);
                else
                    data_rect = data_band;
                end

                [a,b] = butter(order,cutoff_low/(app.freq/2),'low');
                data_low = filtfilt(a,b,data_rect);

                % emg plot
                cla(app.UIAxes);
                hold(app.UIAxes, 'on'); % Keep previous plots in the figure
                plot(app.UIAxes,data,'DisplayName','Raw data')
                plot(app.UIAxes,data_band,'DisplayName','Bandpass filtered',LineStyle='--',LineWidth=2)
                plot(app.UIAxes,data_low,'DisplayName','Low pass filtered','LineWidth',3)
                hold(app.UIAxes, 'off');
                legend(app.UIAxes, 'show','Location','NorthEast');

                % Plot the power spectral density estimate
                cla(app.UIAxes2);
                hold(app.UIAxes2, 'on');
                linetype = {'-','--','-'};
                lineweight = [2 2 3];
                make_freq_spec(app,data,app.freq,app.UIAxes2,linetype(1),lineweight(1))
                make_freq_spec(app,data_band,app.freq,app.UIAxes2,linetype(2),lineweight(2))
                make_freq_spec(app,data_low,app.freq,app.UIAxes2,linetype(3),lineweight(3))
    
                hold(app.UIAxes2, 'off');

        end
        
        function make_freq_spec(app,data,freq,fighandle,linetype,lineweight)
            
            ftx = fft(data);
            N = length(data);
            ff= fix(N/2) + 1;
            f = [0:N-1] * freq/N;

            p = abs(ftx)/(N/2);

            plot(fighandle,f(1:ff)', abs(ftx(1:ff)/N*2),'LineStyle',linetype,'LineWidth',lineweight);

        end

    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Callback function: ButtterworthorderSpinner, 
        % ButtterworthorderSpinner, CutofffrequencySlider, 
        % CutofffrequencySlider, HighcutofffrequencySlider, 
        % HighcutofffrequencySlider, ItemListBox, 
        % LowcutofffrequencySlider, LowcutofffrequencySlider, 
        % RectifydataButtonGroup, RectifydataButtonGroup, 
        % RectifydataButtonGroup
        function ButtonPushed(app, event)
            update_figure(app);
        end

        % Button pushed function: LoadfileButton
        function LoadfileButtonPushed(app, event)
            app.raw_file = uigetfile('*.mat');
            app.raw_data = load(app.raw_file);
            app.fn = fieldnames(app.raw_data);

            app.ItemListBox.Items = {app.raw_data.(app.fn{1}).colheaders{1,2:end}};

            app.freq = 1/(app.raw_data.(app.fn{1}).data(2,1)-app.raw_data.(app.fn{1}).data(1,1));
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {604, 604};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {272, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 941 604];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {272, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create LowcutofffrequencySliderLabel
            app.LowcutofffrequencySliderLabel = uilabel(app.LeftPanel);
            app.LowcutofffrequencySliderLabel.HorizontalAlignment = 'right';
            app.LowcutofffrequencySliderLabel.Position = [86 268 116 22];
            app.LowcutofffrequencySliderLabel.Text = 'Low cutoff frequency';

            % Create LowcutofffrequencySlider
            app.LowcutofffrequencySlider = uislider(app.LeftPanel);
            app.LowcutofffrequencySlider.Limits = [10 50];
            app.LowcutofffrequencySlider.ValueChangedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.LowcutofffrequencySlider.ValueChangingFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.LowcutofffrequencySlider.Position = [46 256 200 3];
            app.LowcutofffrequencySlider.Value = 10;

            % Create ButtterworthorderSpinnerLabel
            app.ButtterworthorderSpinnerLabel = uilabel(app.LeftPanel);
            app.ButtterworthorderSpinnerLabel.HorizontalAlignment = 'right';
            app.ButtterworthorderSpinnerLabel.FontSize = 16;
            app.ButtterworthorderSpinnerLabel.FontWeight = 'bold';
            app.ButtterworthorderSpinnerLabel.Position = [70 452 147 22];
            app.ButtterworthorderSpinnerLabel.Text = 'Buttterworth order';

            % Create ButtterworthorderSpinner
            app.ButtterworthorderSpinner = uispinner(app.LeftPanel);
            app.ButtterworthorderSpinner.ValueChangingFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.ButtterworthorderSpinner.Limits = [2 50];
            app.ButtterworthorderSpinner.ValueChangedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.ButtterworthorderSpinner.Position = [94 418 100 22];
            app.ButtterworthorderSpinner.Value = 2;

            % Create HighcutofffrequencySliderLabel
            app.HighcutofffrequencySliderLabel = uilabel(app.LeftPanel);
            app.HighcutofffrequencySliderLabel.HorizontalAlignment = 'right';
            app.HighcutofffrequencySliderLabel.Position = [88 343 119 22];
            app.HighcutofffrequencySliderLabel.Text = 'High cutoff frequency';

            % Create HighcutofffrequencySlider
            app.HighcutofffrequencySlider = uislider(app.LeftPanel);
            app.HighcutofffrequencySlider.Limits = [50 499];
            app.HighcutofffrequencySlider.ValueChangedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.HighcutofffrequencySlider.ValueChangingFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.HighcutofffrequencySlider.Position = [46 329 201 3];
            app.HighcutofffrequencySlider.Value = 50;

            % Create CutofffrequencySliderLabel
            app.CutofffrequencySliderLabel = uilabel(app.LeftPanel);
            app.CutofffrequencySliderLabel.HorizontalAlignment = 'right';
            app.CutofffrequencySliderLabel.Position = [98 78 93 22];
            app.CutofffrequencySliderLabel.Text = 'Cutoff frequency';

            % Create CutofffrequencySlider
            app.CutofffrequencySlider = uislider(app.LeftPanel);
            app.CutofffrequencySlider.Limits = [2 100];
            app.CutofffrequencySlider.ValueChangedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.CutofffrequencySlider.ValueChangingFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.CutofffrequencySlider.Position = [40 58 200 3];
            app.CutofffrequencySlider.Value = 50;

            % Create BandpassfiltersettingsLabel
            app.BandpassfiltersettingsLabel = uilabel(app.LeftPanel);
            app.BandpassfiltersettingsLabel.HorizontalAlignment = 'center';
            app.BandpassfiltersettingsLabel.FontSize = 16;
            app.BandpassfiltersettingsLabel.FontWeight = 'bold';
            app.BandpassfiltersettingsLabel.Position = [53 378 187 22];
            app.BandpassfiltersettingsLabel.Text = 'Bandpass filter settings';

            % Create RectifydataButtonGroup
            app.RectifydataButtonGroup = uibuttongroup(app.LeftPanel);
            app.RectifydataButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.RectifydataButtonGroup.TitlePosition = 'centertop';
            app.RectifydataButtonGroup.Title = 'Rectify data?';
            app.RectifydataButtonGroup.SizeChangedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.RectifydataButtonGroup.ButtonDownFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.RectifydataButtonGroup.FontWeight = 'bold';
            app.RectifydataButtonGroup.FontSize = 16;
            app.RectifydataButtonGroup.Position = [78 144 123 73];

            % Create YesButton
            app.YesButton = uiradiobutton(app.RectifydataButtonGroup);
            app.YesButton.Text = 'Yes';
            app.YesButton.Position = [37 25 58 22];
            app.YesButton.Value = true;

            % Create NoButton
            app.NoButton = uiradiobutton(app.RectifydataButtonGroup);
            app.NoButton.Text = 'No';
            app.NoButton.Position = [38 1 65 22];

            % Create LowpassfiltersettingsLabel
            app.LowpassfiltersettingsLabel = uilabel(app.LeftPanel);
            app.LowpassfiltersettingsLabel.HorizontalAlignment = 'center';
            app.LowpassfiltersettingsLabel.FontSize = 16;
            app.LowpassfiltersettingsLabel.FontWeight = 'bold';
            app.LowpassfiltersettingsLabel.Position = [52 109 183 22];
            app.LowpassfiltersettingsLabel.Text = 'Low pass filter settings';

            % Create ItemListBoxLabel
            app.ItemListBoxLabel = uilabel(app.LeftPanel);
            app.ItemListBoxLabel.HorizontalAlignment = 'right';
            app.ItemListBoxLabel.FontSize = 16;
            app.ItemListBoxLabel.FontWeight = 'bold';
            app.ItemListBoxLabel.Position = [125 574 38 22];
            app.ItemListBoxLabel.Text = 'Item';

            % Create ItemListBox
            app.ItemListBox = uilistbox(app.LeftPanel);
            app.ItemListBox.Items = {};
            app.ItemListBox.ValueChangedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.ItemListBox.Position = [92 490 100 74];
            app.ItemListBox.Value = {};

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            title(app.UIAxes, 'Data')
            xlabel(app.UIAxes, 'Time')
            ylabel(app.UIAxes, 'Amplitude')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.FontSize = 12;
            app.UIAxes.TitleFontSizeMultiplier = 1.5;
            app.UIAxes.Position = [29 241 582 320];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.RightPanel);
            title(app.UIAxes2, 'Spectrum analysis')
            xlabel(app.UIAxes2, 'Frequency (Hz)')
            ylabel(app.UIAxes2, 'Power')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.XLim = [0 250];
            app.UIAxes2.TitleFontSizeMultiplier = 1.5;
            app.UIAxes2.Position = [30 28 581 199];

            % Create LoadfileButton
            app.LoadfileButton = uibutton(app.RightPanel, 'push');
            app.LoadfileButton.ButtonPushedFcn = createCallbackFcn(app, @LoadfileButtonPushed, true);
            app.LoadfileButton.Position = [512 563 100 22];
            app.LoadfileButton.Text = 'Load file';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = FilterSettingsExplorer_exported

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