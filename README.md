# siibraLab - a MATLAB toolbox for working with brain atlases using the siibra toolsuite

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=FZJ-INM1-BDA/siibralab&file=walkthrough.mlx)
[![View siibralab on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://de.mathworks.com/matlabcentral/fileexchange/121148-siibralab)

``siibra`` is a toolsuite for working with brain atlases that integrate parcellations and reference spaces at different spatial scales, covering multiple aspects of brain organization, and linking features from different data modalitites to brain structures. It aims to facilitate the programmatic and reproducible incorporation of brain region features from different sources into reproducible neuroscience workflows.  siibraLab is a Matlab® toolbox for accessing functions provided in siibra. 

siibra provides structured acccess to parcellation schemes in different brain reference spaces, including volumetric reference templates at both macroscopic and microscopic resolutions as well as surface representations. It supports both discretely labelled and continuous (probabilistic) parcellation maps, which can be used to assign brain regions to spatial locations and image signals, to retrieve region-specific neuroscience datasets from multiple online repositories, and to sample information from high-resolution image data. Among the datasets anchored to brain regions are many different modalities from in-vivo and post mortem studies, including regional information about cell and transmitter receptor densties, structural and functional connectivity, gene expressions, and more.

The main implementation of siibra is the Python client [siibra-python](https://github.com/FZJ-INM1-BDA/siibra-python). To understand the scope, please refer to the [documentation](https://siibra-python.readthedocs.io). There is also an interactive web application built around a 3D viewer, [siibra-explorer](https://github.com/FZJ-INM1-BDA/siibra-explorer), which is [hosted as part of the EBRAINS infrastructure](https://atlases.ebrains.eu/viewer). 

The toolbox is in very early development. Its API is not yet stable and the set of supported features is still basic. We share releases of the toolbox on [matlab file exchange](https://www.mathworks.com/matlabcentral/fileexchange). If you are interested in the ongoing development and future releases, [drop us a note](mailto:info@siibra.eu).

# Getting started

The `walkthrough.mlx` live script gives a tour through the already existing functionality.

It shows how to:
* navigate and access information
* visualize brain regions and parcellations
* how to assign brain regions to volumes of interest.
  
Try it here: [![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=FZJ-INM1-BDA/siibralab&file=walkthrough.mlx)

![image001](https://github.com/scalableminds/siibra-matlab/assets/2582395/457b3162-beb4-4458-bcf9-58df9d9cc740)
