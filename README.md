# Frequency-splitting Dynamic MRI Reconstruction using Multi-scale 3D Convolutional Sparse Coding and Automatic Parameter Selection
----------

This repository holds the original code for CSMRI-3DCSC (Medical Image Analysis), 

![](./README_resource/overview.png "")
*Overview of the proposed method: this proposed method recovers high-frequency information using a shared 3D convolution-based dictionary built progressively during the reconstruction process in an unsupervised manner, while low-frequency information is recovered using a total variation-based energy minimization method that leverages temporal coherence in dynamic MRI.
Additionally, the proposed 3D dictionary is built across three different scales to more efficiently adapt to various feature sizes, and elastic net regularization is employed to promote a better approximation to the sparse input data.
We also propose an automatic parameter selection technique based on a genetic algorithm to find optimal parameters for our numerical solver which is a variant of the alternating direction method of multipliers (ADMM).*

----------

It is developed for research purposes only. 
If you use our code, please refer to our work. 

    @article{NGUYENDUC2019179,
    title = "Frequency-splitting dynamic MRI reconstruction using multi-scale 3D convolutional sparse coding and automatic parameter selection",
    journal = "Medical Image Analysis",
    volume = "53",
    pages = "179 - 196",
    year = "2019",
    issn = "1361-8415",
    doi = "https://doi.org/10.1016/j.media.2019.02.001",
    url = "http://www.sciencedirect.com/science/article/pii/S1361841519300155",
    author = "Thanh Nguyen-Duc and Tran Minh Quan and Won-Ki Jeong"
    }
    
----------
Directory structure of data:

     tree data
     data/
    ├── brain
    │   ├── db_train
    │   └── db_valid
    ├── knees
    │   ├── db_train
    │   └── db_valid
    └── mask
        ├── cartes
        │   ├── mask_1
        │   ├── mask_2
        │   ├── ...
        │   └── mask_9
        ├── gauss
        │   ├── mask_1
        │   ├── mask_2
        │   ├── ...
        │   └── mask_9
        ├── radial
        │   ├── mask_1
        │   ├── mask_2
        │   ├── ...
        │   └── mask_9
        └── spiral
            ├── mask_1
            ├── mask_2
            ├── ...
            └── mask_9

    
    
Brain data is used for magnitude-value experiment, it is extracted from http://brain-development.org/ixi-dataset/ 

Knees data is used for complex-value experiment, it is extracted from http://mridata.org 

----------

Prerequisites

    sudo pip install tensorflow_gpu==1.4.0
	sudo pip install tensorpack==0.8.2
	sudo pip install scikit-image==0.13.0
	sudo pip install whatever-missing_libraries

----------


To begin, the template for such an experiment  is provided in `exp_dset_RefineGAN_mask_strategy_rate.py`

For example, if you want to run the training and testing for case knees data, mask radial 10%, please make a soft link to the experiment name, like this

    ln -s exp_dset_RefineGAN_mask_strategy_rate.py 	 \
		  exp_knees_RefineGAN_mask_radial_1.py

----------

To train the model

    python exp_knees_RefineGAN_mask_radial_1.py  	 \
		    --gpu='0'				 \
		    --imageDir='data/knees/db_train/'    \
		    --labelDir='data/knees/db_train/'    \
		    --maskDir='data/mask/radial/mask_1/' 
		    
Checkpoint of training will be save to directory `train_log`

----------

To test the model

    mkdir result 


    python exp_knees_RefineGAN_mask_radial_1.py  	 \
		    --gpu='0' 				 \
		    --imageDir='data/knees/db_valid/' 	 \
		    --labelDir='data/knees/db_valid/' 	 \
		    --maskDir='data/mask/radial/mask_1/' \
		    --sample='result/exp_knees_RefineGAN_mask_radial_1/' \
		    --load='train_log/exp_knees_RefineGAN_mask_radial_1/max-validation_PSNR_boost_A.data-00000-of-00001'   


----------
The authors would like to thank Dr. Yoonho Nam for the helpful discussion and MRI data, and Yuxin Wu for the help on Tensorpack.