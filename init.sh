#!/bin/sh

# Create variables
WORK_DIR=/home/onyxia/work/senegal_littoral
REPO_URL=https://${GIT_PERSONAL_ACCESS_TOKEN}@github.com/fBedecarrats/senegal_littoral.git

# Git
git clone $REPO_URL $WORK_DIR

# copy heavy data sources
mc cp -r s3/fbedecarrats/diffusion/mapme_biodiversity/chirps $WORK_DIR/data

# Grant permission for the created folders/files
chown -R ${USERNAME}:${GROUPNAME} $WORK_DIR

# launch RStudio in the right project
# Copied from InseeLab UtilitR
    echo \
    "
    setHook('rstudio.sessionInit', function(newSession) {
        if (newSession && !identical(getwd(), \"'$WORK_DIR'\"))
        {
            message('On charge directement le bon projet :-) ')
            rstudioapi::openProject('$WORK_DIR')
            # For a slick dark theme
            rstudioapi::applyTheme('Merbivore')
            # Console where it should be
            rstudioapi::executeCommand('layoutConsoleOnRight')
            }
            }, action = 'append')
            " >> /home/onyxia/work/.Rprofile
