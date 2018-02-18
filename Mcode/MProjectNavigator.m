function MProjectNavigator(varargin)
%MProjectNavigator Viewer GUI tool for a Matlab project structure
%
% MProjectNavigator(varargin)
%
% Usage:
%
% MProjectNavigator
% MProjectNavigator -pin <path>
% MProjectNavigator -deletesettings
%
% For this to work, its JAR dependencies must be on the Java classpath. You can
% set this up by running loadMProjectNavigator(), found in this project's
% "bootstrap/" directory.
%
% Alternately, you can invoke MProjectNavigator with its hotkey, Ctrl-Shift-P.

error(javachk('awt'));

    function out = myNavigator(newVal)
        s = getappdata(0, 'MProjectNavigator');
        if isempty(s)
            s = struct;
            s.NavigatorInstance = [];
        end
        out = s.NavigatorInstance;
        if nargin > 0
            s.NavigatorInstance = newVal;
            setappdata(0, 'MProjectNavigator', s);
        end
    end

navigator = myNavigator;

if nargin == 0
    maybeInitializeGui();
    navigator.Visible = true;
    return;
end

switch varargin{1}
    case '-pin'
        if nargin < 2
            warning('MProjectNavigator: Invalid arguments: -pin requires an argument');
            return;
        end
        newPinnedPath = varargin{2};
        maybeInitializeGui();
        setPinnedPath(newPinnedPath);
    case '-hide'
        if isempty(navigator)
            return;
        end
        navigator.Visible = false;
    case '-fresh'
        disposeGui();
        maybeInitializeGui();
        navigator.Visible = true;
    case '-dispose'
        disposeGui();        
    case '-registerhotkey'
        registerGlobalHotKey();
    case '-hotkeyinvoked'
        hotKeyInvoked();
    case '-deletesettings'
        mprojectnavigator.internal.Persistence.deleteAllSettings();
        fprintf('MProjectNavigator: All settings deleted.\n');
    case '-editorfrontfile'
        editorFrontFile(varargin{2});
    case '-editorfilesaved'
        editorFileSaved(varargin{2});
    otherwise
        if isequal(varargin{1}(1), '-')
            warning('MProjectNavigator: Unrecognized option: %s', varargin{1});
        else
            warning('MProjectNavigator: Invalid arguments');
        end
end


    function disposeGui()
        if ~isempty(navigator)
            navigator.dispose();
            navigator = [];
            myNavigator(navigator);
        end
    end

    function maybeInitializeGui()
        if isempty(navigator)
            navigator = mprojectnavigator.internal.Navigator;
            myNavigator(navigator);
            registerHotKeyOnComponent(navigator.frame.getContentPane);
        end
    end

    function hotKeyInvoked()
        if isempty(navigator)
            maybeInitializeGui();
            navigator.Visible = true;
        else
            % Toggle visibility
            navigator.Visible = ~navigator.Visible;
        end
    end

    function editorFrontFile(file)
        if ~isempty(navigator)
            navigator.editorFrontFileChanged(file);
        end
    end

    function editorFileSaved(file)
        if ~isempty(navigator)
            navigator.editorFileSaved(file);
        end
    end

    function setPinnedPath(newPath)
        if ~isdir(newPath) %#ok
            warning('''%s'' is not a directory', newPath);
            return;
        end
        realPath = resolveRelativeDirPath(newPath);
        if ~isempty(realPath)
            navigator.fileNavigator.setRootPath(realPath);
        end
    end

end

function realPath = resolveRelativeDirPath(p)
% HACK: Resolve "." and Matlab-path-relative paths to real path name.
if isequal(p, '.')
    p = pwd;
end
realPath = [];
if isFolder(p)
    realPath = p;
else
    mp = strsplit(path, pathsep);
    for i = 1:numel(mp)
        candidatePath = fullfile(mp{i}, p);
        if isFolder(candidatePath)
            realPath = candidatePath;
            break;
        end
    end
    if isempty(realPath)
        warning('Could not resolve directory ''%s''', p);
        return;
    end
end
end

function registerGlobalHotKey()
mainFrame = com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame;
registerHotKeyOnComponent(mainFrame.getContentPane);
end

function registerHotKeyOnComponent(jComponent)
import net.apjanke.mprojectnavigator.swing.*
import java.awt.*
import javax.swing.*

action = FevalAction.ofStringArguments('MProjectNavigator', '-hotkeyinvoked');
action.setDisplayConsoleOutput(true);
inputMap = jComponent.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW);
actionMap = jComponent.getActionMap;
controlShiftP = KeyStroke.getKeyStroke('control shift P');
actionName = java.lang.String('MProjectNavigator-hotkey');
inputMap.put(controlShiftP, actionName);
actionMap.put(actionName, action);
end


