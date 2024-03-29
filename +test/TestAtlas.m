classdef TestAtlas < matlab.unittest.TestCase
    
    methods(TestClassSetup)
        % Shared setup for the entire test class
        function initCache(testCase)
            siibra.internal.initAtlases(false);
        end
    end
    
    methods(TestMethodSetup)
        % Setup for each test
    end
    
    methods(Test)
        % Test methods
        
        function listAtlases(testCase)
            atlases = siibra.atlases();
            testCase.verifyEqual(numel(atlases), 4);
        end
    end
    
end