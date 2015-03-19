# Shortened drush sql-sync; drops all tables of destination environment,
#  then syncs a non-cached version of the source environment
_dss () {
  local timestamp=$(date "+%Y%m%d-%H%M%S")
  local site=${1//[@]/}
  local source=${2:-prod}
  local dest=${3:-local}
  if [ -z "$4" ]; then dump_path=../..; else dump_path=$4; fi
 
  time {
    if [ $dest == "local" ]
    then
      drush @${dest}.${site} sql-drop --result-file=${dump_path}/${site}.${dest}--${timestamp}.sql --yes
      drush sql-sync --no-cache @${site}.${source} @${dest}.${site} --yes
    else
      drush @${site}.${dest} sql-drop --result-file=${dump_path}/${site}.${dest}--${timestamp}.sql --yes
      drush sql-sync --no-cache @${site}.${source} @${site}.${dest} --yes
    fi
  }
}
 
## Usage: dss @site source destination
## Ex: dss @oedit prod local
##   If source is prod and destination is local, just run dss @site
##   If source is not prod but destination is local, run dss @site source
##   If you want the sql-drop to dump the destination db somewhere other than
##     two directories above the site root (e.g. docroot -> ../../), a 4th
##     argument can be passed.
##   Ex. dss @oedit prod local ~/db-dumps
alias dss='_dss'
 
# Shortened drush rsync; similar to the above, but less potentially destructive
_drs () {
  local timestamp=$(date "+%Y%m%d-%H%M%S")
  local site=${1//[@]/}
  local source=${2:-prod}
  local dest=${3:-local}
 
  time {
    if [ $dest == "local" ]
    then
      drush rsync -rvy @${site}.${source}:%files @${dest}.${site}:%files
    else
      drush rsync -rvy @${site}.${source}:%files @${site}.${dest}:%files
    fi
  }
}
 
# Usage: drs @site
##  If source is not prod, do drs @site source instead
##  Similarly, if destination is not local, do drs @site source destination
alias drs='_drs'
