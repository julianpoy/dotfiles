#!/usr/bin/env fish

if test (count $argv) -eq 0
    echo "Usage: fish nvmInstallVersion.fish v<major>.<minor>[.<patch>]"
    exit 1
end

set target_version $argv[1]
nvm install $target_version
set installed_version (nvm list | grep -oE "$target_version(\.[0-9]+)?" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sort -Vr | head -n 1)

if test -z "$installed_version"
    echo "Could not determine installed version matching $target_version"
    exit 1
end

for ver in (nvm list | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+')
    if test "$ver" != "$installed_version"
        echo "Uninstalling $ver"
        nvm uninstall $ver
    end
end

