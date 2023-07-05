classdef TestRegions < matlab.unittest.TestCase
    
    methods(Test)
        % Test methods
        
        function getContinuousMapForRegion(testCase)
            julich = siibra.getParcellation("human", "julich 2.9");
            v1l = julich.decodeRegion('Area hoc1 V1 17 left');
            v1lContinuousMap = v1l.continuousMap("MNI152 2009c nonl asym").fetch();
            % TODO this continuous map does not comply with the new shape
            % of 289   361   271, right?
            testCase.verifyEqual(size(v1lContinuousMap.loadData), [193   229   193]);

            whiteMatterBundles = siibra.getParcellation("human", "white matter bundles");
            mlr = whiteMatterBundles.decodeRegion('MediumLongitudinal Right');
            % Test region that has no statistical map
            testCase.verifyError(@() mlr.continuousMap("mni").fetch(), 'StatisticalMap:NotFound');

            difumo64 = siibra.getParcellation("human", "difumo 64");
            spl = difumo64.decodeRegion('Superior parietal lobule');
            % Test region that has no statistical map
            testCase.verifyError(@() spl.continuousMap("mni").fetch(), 'StatisticalMap:NotFound');
        end


        function getMaskForRegion(testCase)
            julich = siibra.getParcellation("human", "julich 2.9");
            v1r = julich.decodeRegion('Area hoc1 V1 17 right');
            v1rMask = v1r.getMask("MNI152 2009c nonl asym").fetch();
            testCase.verifyEqual(size(v1rMask.loadData), [193   229   193]);

            v1ParentMask = v1r.Parent.getMask("MNI152 2009c nonl asym").fetch();
            % make sure the parent mask contains the mask of the child
            testCase.verifyEqual(v1rMask.loadData & v1ParentMask.loadData, logical(v1rMask.loadData))

        end
    end
    
end