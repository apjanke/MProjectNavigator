function MProjectNavigator(varargin)
%MProjectNavigator Viewer GUI tool for a Matlab project structure
%
% MProjectNavigator(varargin)
%
% Usage:
%
% MProjectNavigator
% MProjectNavigator -pin <path>
%
% For this to work, its JAR dependencies must be on the Java classpath. You can
% set this up by running loadMProjectNavigator(), found in this project's
% "bootstrap/" directory.
%
% Alternately, you can invoke MProjectNavigator with its hotkey, Ctrl-Shift-P.

error(javachk('awt'));

persistent pFrame pFileNavigator

if nargin == 0
    maybeInitializeGui();
    pFrame.setVisible(true);
else
    if isequal(varargin{1}, '-pin')
        if nargin < 2
            warning('MProjectNavigator: Invalid arguments: -pin requires an argument');
            return;
        end
        newPinnedPath = varargin{2};
        maybeInitializeGui();
        pFileNavigator.setRootPath(newPinnedPath);
    elseif isequal(varargin{1}, '-hide')
        if isempty(pFrame)
            return;
        end
        pFrame.setVisible(false);
    elseif isequal(varargin{1}, '-fresh')
        disposeGui();
        maybeInitializeGui();
        pFrame.setVisible(true);
    elseif isequal(varargin{1}, '-registerhotkey')
        registerHotkey();
    elseif isequal(varargin{1}, '-hotkeyinvoked')
        hotkeyInvoked();
    elseif isequal(varargin{1}(1), '-')
        warning('MProjectNavigator: Unrecognized option: %s', varargin{1});
    else
        warning('MProjectNavigator: Invalid arguments');
    end
end

    function disposeGui()
        if ~isempty(pFrame)
            pFrame.dispose();
            pFrame = [];
            pFileNavigator = [];
        end
    end

    function maybeInitializeGui()
        if isempty(pFrame)
            initializeGui();
        end
    end

    function initializeGui()
        import java.awt.*
        import javax.swing.*
        
        frame = JFrame('Project Navigator');
        frame.setSize(350, 600);
        
        tabbedPane = JTabbedPane;
        
        fileNavigator = mprojectnavigator.FileNavigatorWidget;
        tabbedPane.add('Files', fileNavigator.panel);
        codeNavigator = mprojectnavigator.CodeNavigatorWidget;
        tabbedPane.add('Definitions', codeNavigator.panel);
        
        frame.getContentPane.add(tabbedPane, BorderLayout.CENTER);
        registerHotkeyOnComponent(frame.getContentPane);
        frame.setVisible(true);
        
        pFrame = frame;
        pFileNavigator = fileNavigator;
    end

    function registerHotkey()
        mainFrame = com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame;
        registerHotkeyOnComponent(mainFrame.getContentPane);
    end

    function hotkeyInvoked()
        if isempty(pFrame)
            initializeGui();
        else
            % Toggle visibility
            pFrame.setVisible(~pFrame.isVisible);
        end
    end

end

function registerHotkeyOnComponent(jComponent)
import net.apjanke.mprojectnavigator.swing.*
import java.awt.*
import javax.swing.*

action = FevalAction.ofStringArguments('MProjectNavigator','-hotkeyinvoked');
%action.setDisplayConsoleOutput(true); % DEBUG
inputMap = jComponent.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW);
actionMap = jComponent.getActionMap;
controlShiftP = KeyStroke.getKeyStroke('control shift P');
actionName = java.lang.String('MProjectNavigator-hotkey');
inputMap.put(controlShiftP, actionName);
actionMap.put(actionName, action);
end
