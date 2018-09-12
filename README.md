# AFDS First Big Data Challenge
*Mark Farrell, CSIRO Agriculture & Food*

The original Markdown syntax specification can be found [here](http://daringfireball.net/projects/markdown/syntax).
A more helpful Markdown cheat sheet is available [here] (https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet). All this was written in [MacDown](https://macdown.uranusjr.com/).

___


##Setting up the workplace environment
* Start new project in Github
* `git clone` the github project to home directory
* Get started on the `README.md`
* Make a bash script to build a sensible folder structure, called `dir.sh`, and add a `.gitignore` file which excludes the data directory, images, zips, and other files that shouldn't be tracked in github
* Push to Github in preparation for running on pearcey
* SSH into pearcey, navigate to `/flush1/far218` and `git clone`
* `rsync -vh dir/where/files/are ./the/data/structure` to copy the raw files to the appropriate folder
* Write / modify  
