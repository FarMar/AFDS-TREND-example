# AFDS First Big Data Challenge
*Mark Farrell, CSIRO Agriculture & Food*

The original Markdown syntax specification can be found [here](http://daringfireball.net/projects/markdown/syntax).
A more helpful Markdown cheat sheet is available [here] (https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet). All this was written in [MacDown](https://macdown.uranusjr.com/).

___

## Data management plan
It's much easier to make a start on this and consider how you will be making your data available in the longer term. The [data management plan](https://confluence.csiro.au/display/RDM/Research+Data+Planner) provides a comprehensive set of concepts that require consideration, including metadata formats, licenses and inherited licenses. Default *home* for the raw and processed data is likely [CSIRO's Data Access Portal](https://data.csiro.au/dap/home?execution=e1s1), with workflow deposited in [Github](https://github.com/).

___

## Setting up the workplace environment
* Start new project in Github
* `git clone` the github project to home directory
* Get started on the `README.md`
* Make a bash script to build a sensible folder structure, called `dir.sh`, and add a `.gitignore` file which excludes the data directory, images, zips, and other files that shouldn't be tracked in github
* Push to Github in preparation for running on pearcey
* SSH into pearcey, navigate to `/flush1/far218` and `git clone`
* `rsync -vhra dir/where/files/are/ ./the/data/structure/` to copy the raw files to the appropriate folder
* Write / modify bash script to extract metadata from the .fastq files



### Directory structure
To have an ordered workspace that is clean, easy to navigate, and ensures that code changes etc. are tracked whilst not trying to commit large data or output files to Github, it is important that a standard working structure of directories is created. This can be done in a simple bash script. 

```sh
#!/bin/bash

#***************************************************************#
#              makes directory structure                        #
#***************************************************************#

# should be run from the root of your working directory

mkdir data/
mkdir data/raw/
mkdir data/working/
mkdir data/processed
mkdir scripts/
mkdir outputs/
```
When written and saved, simply run `sh dir.sh`
___

## Pre-processing of data
A lot of technical data on the quality of the molecular data, and the factors within the run (e.g. lanes, etc) can be gleaned by some relatively simple steps. First of these is to extract the metadata. for MiSeq data,  

