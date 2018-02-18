classdef FileNodeData < mprojectnavigator.internal.NodeData

    properties
        % The path to the file on disk (not the node TreePath)
        path        char
        isDummy     logical
        isDir       logical
        isFile      logical
    end
    
    methods
        function this = FileNodeData(path, isDir)
            if nargin >= 1;   this.path = path;  end
            if nargin >= 2;   this.isDir = isDir;  end
        end
        
        function WHATEVER(foo)
        end
    end
end