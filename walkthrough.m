%% A quick walkthrough for siibralab -  Matlab interface to the siibra toolsuite 
% *siibra is a toolsuite for working with brain atlases that integrate parcellations 
% and reference spaces at different spatial scales, covering multiple aspects 
% of brain organization, and linking features from different data modalitites 
% to brain structures. It aims to facilitate the programmatic and reproducible 
% incorporation of brain region features from different sources into reproducible 
% neuroscience workflows. siibraLab is a Matlab® toolbox for accessing functions 
% provided in siibra.*
% 
% _siibra_ provides structured acccess to parcellation schemes in different 
% brain reference spaces, including volumetric reference templates at both macroscopic 
% and microscopic resolutions as well as surface representations. It supports 
% both discretely labelled and continuous (probabilistic) parcellation maps, which 
% can be used to assign brain regions to spatial locations and image signals, 
% to retrieve region-specific neuroscience datasets from multiple online repositories, 
% and to sample information from high-resolution image data. Among the datasets 
% anchored to brain regions are many different modalities from in-vivo and post 
% mortem studies, including regional information about cell and transmitter receptor 
% densties, structural and functional connectivity, gene expressions, and more. 
% 
% The main implementation of siibra is the Python client siibra-python, which 
% as of now has a much more comprehensive set of features, document in the documentation 
% at <https://siibra-python.readthedocs.io https://siibra-python.readthedocs.io>. 
% There is also an interactive web application built around a 3D viewer - siibra-explorer 
% -, which is hosted as part of the EBRAINS infrastructure at <https://atlases.ebrains.eu/viewer. 
% https://atlases.ebrains.eu/viewer.>
% 
% _siibralab_ is in very early development. Its API is not yet stable and the 
% set of supported features is still rudimentary. We share releases of the toolbox 
% on matlab file exchange (<https://www.mathworks.com/matlabcentral/fileexchange 
% https://www.mathworks.com/matlabcentral/fileexchange>). If you are interested 
% in the ongoing development and future releases, drop us a note to info@siibra.eu.
% 
% This notebook provides a brief waltkhrough the already available functionality, 
% focusing on access the Julich-Brain probabilistic cytoarchitectonic atlas. 
%% 
% 

clear all;  % uncomment rows to clear the workspace and close open figures
close all;
%% Accessing basic concepts: atlases, parcellations, and regions
% Predefined atlases
% siibralab provides access to atlases of different species. Note that on first 
% call of a siibralab function, the package will retrieve preconfiguration data 
% which might take a while. The data is then cached on your local disk for future 
% calls.

siibra.atlasOverview()
%% 
% As of now, siibra supports features of the human atlas, so let's access it.

atlas = siibra.getAtlas('human')
% Predefined parcellations
% The atlas groups a set of parcellations and reference spaces. We will work 
% with the Julich-Brain cytoarchitectonic maps here, so we access the corresponding 
% parcellation object. We can get a parcellation by providing a unique set of 
% keywords.

[atlas.Parcellations.Name].'
julichbrain = atlas.getParcellation('Julich-Brain 2.9')
%% 
% The parcellation is just a semantic object, defining a set of known regions 
% that were delineated according to specific aspects of brain organization.

julichbrain.Description
% Brain regions from a parcellation
% We can search for regions, and also decode a partial name into a concrete 
% region object which contains further information on the region.

regions = julichbrain.findRegion('V1')
v1l = julichbrain.decodeRegion('Area hoc1 V1 17 left')
%% Accessing the reference template for a given space
% Choosing a reference space
% The parcellation is just a semantic object. To obtain a parcellation map, 
% a reference space needs to be specified. Just like a parcellation, the reference 
% space can be accessed by keywords.

[julichbrain.Spaces.Name].'
mni_space = atlas.getSpace('MNI152 2009c nonl asym')
% Fetching the template as an image volume 
% The space is a semantic object, while the template actually contains a reference 
% image (vol_template). We fetch the template as a NIfTI object, which includes 
% the actual image volume as a numeric array, as well as typical metadata such 
% as an affine matrix relating the voxel space to the physical space, and various 
% other metadata fields. Refer to the NIfTI documentation on details (https://nipy.org/nibabel/manual.html#manual). 
% 
% Here we inspect some metadata from its header.

mni_template_nii = mni_space.loadTemplate
mni_template_nii.Header.ImageSize
mni_template_nii.Header.Transform.T
mni_template_nii.Header.DisplayIntensityRange
%% 
% The dimensions of the volume of the MNI152 template (mni_icbm152_nlin_asym_09c) 
% are 193x229x193 px. The origin is located at x=-96, y=-132, z=-78]. Gray values 
% range from 0 to 100 and represent the measured and callibrated T1 intensities 
% of 152 individual subjects and scans.
% 
% For the following, we explicitly extract the image volume from the NIfTI object:

mni_template_vol = mni_space.loadTemplate.loadData(); 
%% Fetching the probabilistic map of a given brain region in a given reference space
% Brain regions can be searched by name from the parcellation object.  The parcellation's 
% "findRegion" method would provide us a list of possible matches. 

julichbrain.findRegion('Fp1')
%% 
% Here we intend to specifiy a particular region directly, so we use "decodeRegion" 
% which would raise an error if the specification is not unique. In the continuous 
% maps of the Julich-Brain atlas, the intensities reflect the probabilty of being 
% this specific area, so we denote them as probability maps (probmaps).

fp1l_region = julichbrain.decodeRegion('Fp1 left');
fp1l_probmap = fp1l_region.continuousMap(mni_space.Name);
%% 
% We can now fetch the probability map as a NIfTI object, and retrieve the actual 
% image volume, just as we did for the MNI template above.

fp1l_probmap_nii = fp1l_probmap.fetch();
fp1l_probmap_vol = fp1l_probmap_nii.loadData();
% Understanding the *probabilistic maps*
% The probabilistic maps have the same size and origin and can therefore interact 
% with the template volume. The values of the volume of the probabilistic map 
% range from 0 to 1 and reflect the probability that it is the specific area. 
% 0 means that the specific area was found in 0 out of 10 brains at the specific 
% position, 1 means that the area was found in 10 out of 10 brains at this specific 
% position.

fprintf('max p value of area %s : %f ', fp1l_probmap.Name,max(fp1l_probmap_vol,[],'all'))
fprintf('min p value of area %s : %f ', fp1l_probmap.Name,min(fp1l_probmap_vol,[],'all'))
%% Visualizing parcellation maps
% Orthoslice view of the probability map superimposed with the template

z_plane = 90;
%% 
% First we extract the 2D slice from the template volume.

hf = figure;
h1 = axes;
h_template_slice = slice(double(mni_template_vol),[],[],z_plane);
h_template_slice.EdgeColor='none';
colormap(h1,'gray');
%% 
% Next we overlay it with a mask of the corresponding slice from the map.

h2 = axes;
h_map_slice = slice(fp1l_probmap_vol,[],[],90);
h_map_slice.EdgeColor = 'none';
mask = fp1l_probmap_vol(:,:,z_plane);
mask(mask>0) = 1;
h_map_slice.AlphaData = mask;    
h_map_slice.FaceAlpha = 'flat';
set(h2,'color','none','visible','off')
colormap(h2,'parula');
h1.XColor='none'; h1.YColor='none'; h1.ZColor='none';
% Plot distribution of voxel wise probabilities in the continuous map
% There is always a larger periphery with lower probabilities because this is 
% precisely the area due to the interindividual variability of brains. This is 
% why the probability information is so valuable, because every brain is different 
% in size and shape, which should be taken into account in neuroscientific analyses.

figure;
h_histo = histogram(fp1l_probmap_vol(fp1l_probmap_vol>0),100);
title('Probability distribution within the map of Fp1')
ylabel('number of voxel');
xlabel('probability of beeing specific area');
% Comparing probabilistic (continuous) map and maximum probabilistic (labelled) map
% The volume of the probability map is always larger than the volume of the 
% maximum probability map. In the maximum probability map (MPM), also called "labeld 
% map", each voxel is assigned exactly the one area label whose probability of 
% being found at the specific voxel is the highest. It is therefore a "winner 
% takes it all" model, which shrinks the volume compared to the probabilistic 
% map, since some voxels within a probability map may be covered by neighboring 
% areas with a higher probability.
% 
% The MPM thus allows the representation of sharp boundaries, but it also does 
% not represent the full degree of information of the probability map.

fprintf('The the size of the continous map (pmap) of Area Fp1 is %d voxel, or mm³, \nsince the the mni space has got a voxelsize of 1mm³.',size(find(fp1l_probmap_vol>0),1))
fp1l_mask = fp1l_region.getMask(mni_space.Name)
fp1l_mask_nii = fp1l_mask.fetch()
fp1l_mask_vol = fp1l_mask_nii.loadData;
fp1l_mask_vol_value = nnz(fp1l_mask_vol) % non zero elements in the mask
sum_pmap_voxel = 0;
for i=100:-1:1
    sum_pmap_voxel = sum_pmap_voxel+h_histo.Values(i);
    if sum_pmap_voxel > fp1l_mask_vol_value
        disp(['The mpm representation of Area Fp1 with ' num2str(fp1l_mask_vol_value) ' voxel roughly corresponds in size with a ' num2str(i) '% thresholded ' newline 'version of the probabilistic map of area Fp1 with ' num2str(sum_pmap_voxel)]);
        break;
    end
end
% Plotting MPM (labelled map) representation of area Fp1 as isosurface with orthoslice
% We plot the same slice of the template as above, but with an isosurface representation 
% of the mask.

close(gcf)
h_map_slice = slice(double(fp1l_probmap_vol),[],[],z_plane);
h_map_slice.EdgeAlpha = 0;
colormap(gca,"gray");
hold on
%% 
% The isosurface is created from the mask by specifying a treshold value, here 
% we choose 0.5 as the 50% probability.

s = isosurface(fp1l_mask_vol,0.5);
p = patch(s);
set(p,'FaceColor',[1 0 0]);  %red color
set(p,'EdgeColor','none'); 
hold off
xlim(gca,[0 size(mni_template_vol,2)]);
ylim(gca,[0 size(mni_template_vol,1)]); %changed order!!
zlim(gca,[0 size(mni_template_vol,3)]);
view([28.6 25.7])
camlight;
lighting gouraud;
% Create a surface view of all regions

julichbrain_maxprobmap_nii = julichbrain.parcellationMap(mni_space.Name).fetch;
julichbrain_maxprobmap_right_vol = julichbrain_maxprobmap_nii(1).loadData;

mpm_idx = unique(julichbrain_maxprobmap_right_vol);
cmap = colormap('lines');
hold on

for i = 2:size(mpm_idx,1)  % start with index 2 since 0 is background 
    single_mpm = julichbrain_maxprobmap_right_vol;
    single_mpm(single_mpm ~= mpm_idx(i)) = 0;
    s = isosurface(single_mpm,mpm_idx(i)-1);
    p = patch(s);
    set(p,'FaceColor',cmap(i,:));
    set(p,'EdgeColor','none'); 
end

so = slice(double(mni_template_vol),[],[],z_plane);
so.EdgeAlpha = 0;
colormap(gca,"gray");

xlim(gca,[0 size(mni_template_vol,2)]);
ylim(gca,[0 size(mni_template_vol,1)]); %changed order!!
zlim(gca,[0 size(mni_template_vol,3)]);
hold off
view([51 18])
%% Assigning brain regions to volumes of interest given in a user-specified 3D image volume
% Let's assume you bring your own 3D volume depicting a region of interest, 
% e.g. a functional activation, a segmented brain lesion, or 3D volumes of other 
% origin. For the purpose of this example, we will here just use one of the probability 
% maps (the one of Fp1 left) as a "fake activation" - just think of it as an fMRI 
% activation. To load your own NIfTI file just use Matlab's <https://de.mathworks.com/help/images/ref/niftiread.html 
% readnifti()> function (my_volume=|niftiread('brain.nii')|;). _Note that the 
% volume of interest must be in the same reference space - here the MNI 152 space._
% 
% *Question: Which map of the Jülich-Brain Atlas shows the closest spatial proximity 
% to my volume?*

% define my volume
my_volume = fp1l_probmap_vol;

% loop over all Jülich-Brain areas included in the MPM (labeld_map)
mpm_idx = unique(julichbrain_maxprobmap_right_vol); % get all unique gray values of the Julich-Brain MPM

correlation_coeff = zeros(size(mpm_idx,1)-1,2); % predefine result variable

for i=2:size(mpm_idx,1)  % start with index 2 since 0 is background 
    single_mpm = julichbrain_maxprobmap_right_vol;
    single_mpm(single_mpm ~= mpm_idx(i)) = 0; % set all voxel which do not belong to the here adressed map to 0
    r = pearson_3d_coefficient(uint16(my_volume),single_mpm); % function is located at the end of this script
    correlation_coeff(i,:) = [mpm_idx(i) r];  % store the Julich-Brain gray value and the corresponding correlation coefficiant 
end

[M,I] = max(correlation_coeff(:,2)); % find the area with the highest correlation

disp( ['The highest correlation coefficient is ' num2str(M) ', it was found with the area with gray value ' num2str(mpm_idx(I))])
%% 
% From one of the first examples, we know that _gray level 212 in the Jülich 
% Brain Atlas codes for area Fp1_. 
% 
% *Answer: Thus, it is obvious that the probability map of area Fp1 has the 
% highest spatial correlation with the MPM representation of the Fp1 map.*
%% Extract regional properties from the probability map using the image_processing_toolbox

%if license('test', 'image_toolbox') 
%    regionprops3(fp1l_mask_vol,fp1l_probmap_vol,'MinIntensity','MeanIntensity',"MaxIntensity","WeightedCentroid")
%    regionprops3(fp1l_mask_vol,'Volume','Centroid','SurfaceArea')
%end
%% Accessing multimodal data featrues
% Regional densities of neurotransmitter neuroreceptors
% Receptor densities, if available for a region, can then be retrieved using  
% the getReceptorDensities() function. We choose region V1 here. Receptor densities 
% are tabular data; they include a "fingerprint" of average densities measured 
% in multiple tissue samples for differenty transmitter receptors.

v1l_region = julichbrain.decodeRegion("Area hOc1 (V1, 17, CalcS) left");
% This is currently not supported.
% To support fetching features, the matlab client needs to support the v3
% api first.
%receptorDensities = v1l_region.getReceptorDensities()
%% 
% The fingerprints are typically visualized as a polarplot.

%fingerprint_table=receptorDensities.Fingerprint;

%fingerprint_table.plusSTD=receptorDensities.Fingerprint.("Mean")+receptorDensities.Fingerprint.("Std");
%fingerprint_table.minusSTD=receptorDensities.Fingerprint.("Mean")-receptorDensities.Fingerprint.("Std");
%
%figure;
%p=polarplot(fingerprint_table,["Mean" "plusSTD" "minusSTD"]);
%p(2).LineStyle='--';p(3).LineStyle='--';
%p(2).Color='c';p(3).Color='c';
%
%title(receptorDensities.Name)
%
%thetaticks(round(linspace(0,360,size(receptorDensities.Fingerprint,1))));
%thetaticklabels(receptorDensities.Fingerprint.Row);
% Structural connectivity grouped by parcellation
% As a feature of a parcellation, siibra provides access to streamline counts 
% as a measure of structural connectivity. The connectivity has the form of a 
% matrix, where columns and rows correspond to the regions defined in the parcellation.

% This is currently not supported.
% To support fetching features, the matlab client needs to support the v3
% api first.
%sc = julichbrain.getStreamlineCounts();
%% 
% As with all datasets, descriptive meta information is part of the output of 
% siibralab

%sc(1)
%% 
% The actual streamline counts are available for 200 subjects from the HCP (range 
% 1-200) and averaged from the 1000brains study (index 201). Here, for example, 
% for subject number 1.

%head(sc(1).Matrix)
%% 
% Plot the first 20 extracted streamline counts for "Area hOc1 (V1, 17, CalcS) 
% right" as bar plot

%bar(sc(1).Matrix.("Area hOc1 (V1, 17, CalcS) right"))
%set(gca,'xticklabel',sc(1).Matrix.Properties.VariableNames)
%set(gca,'xtick',[1:size(sc(1).Matrix,1)])
%xlim([1 20])
%% Function definitions

function r = pearson_3d_coefficient(volume1,volume2)
    A = volume1 - mean(volume1, 'all');
    B = volume2 - mean(volume2, 'all');
    
    num = sum(A  .* B, 'all');
    den1 = sum(A.^2, 'all');
    den2 = sum(B.^2, 'all');
    r = num ./ (den1 .* den2)^0.5;
end