classdef TestParcellations < matlab.unittest.TestCase
    
    methods(TestClassSetup)
        % Shared setup for the entire test class
    end
    
    methods(TestMethodSetup)
        % Setup for each test
    end
    
    methods(Test)
        % Test methods
        
        function selectParcellation(testCase)

            julich = siibra.getParcellation("human", "julich 2.9");
            testCase.verifyEqual(julich.Name, "Julich-Brain Cytoarchitectonic Maps 2.9");

            whiteMatterBundles = siibra.getParcellation("human", "white matter bundles");
            testCase.verifyEqual(whiteMatterBundles.Name, "Long White Matter Bundles");

            primate = siibra.getParcellation("monkey", "primate");
            testCase.verifyEqual(primate.Name, "Non-human primate");

            primate = siibra.getParcellation("mouse", "2017");
            testCase.verifyEqual(primate.Name, "Allen Mouse Common Coordinate Framework v3 2017");

        end

        function getParcellationMap(testCase)
            julich = siibra.getParcellation("human", "julich 2.9");
            labeledMapMNI = julich.parcellationMap("MNI Colin 27").fetch();
            labeledMap152 = julich.parcellationMap("MNI152 2009c nonl asym").fetch();
            % The julich brain has two hemispheres.
            testCase.verifyEqual(numel(labeledMapMNI), 2);
            testCase.verifyEqual(numel(labeledMap152), 2);
            % Assert the shape of the first hemisphere.
            testCase.verifyEqual(size(labeledMap152(1).loadData), [193   229   193])


            whiteMatterBundles = siibra.getParcellation("human", "white matter bundles");
            labeledMap152 = whiteMatterBundles.parcellationMap("MNI152 2009c nonl asym").fetch();   
            % White matter bundles has one volume
            testCase.verifyEqual(numel(labeledMap152), 1)
            testCase.verifyEqual(size(labeledMap152.loadData), [193   229   193])
            
            difumo64 = siibra.getParcellation("human", "difumo 64");
            probabilityMap = difumo64.parcellationMap("MNI152 2009c nonl asym").fetch();

            % testCase.verfyEqual(size(probabilityMap), 4)

        end
    end
    
end