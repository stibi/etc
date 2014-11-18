printLargestCachedPkgs() {
    local pkgCachePath="/var/cache/pacman/pkg"
    local printedPkgsCount=10
    du -ah ${pkgCachePath} | sort -hr | head -n ${printedPkgsCount}
}

removeLargestCachedPkgs() {
    local howManyToDelete=$1
    local defaultNumberOfDeletedPkgs=10
    # pokud neni zadano kolik, tak default=10
    # TODO finish the function
}

# Kudos to: https://github.com/tejr/dotfiles/blob/master/bash/bashrc.d/scr.bash
#
# Create a temporary directory and change into it, to stop me putting stray
# files into $HOME, and making the system do cleanup for me
takeMeToTempDir() {
    pushd -- "$(mktemp -d)"
}
