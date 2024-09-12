# Git specific
alias gpo "git push origin"
funcsave gpo
alias gpoh "git push origin HEAD"
funcsave gpoh
alias gp "git pull origin HEAD"
funcsave gp
alias gf "git fetch --all"
funcsave gf
function fxap --wraps='coder port-forward fxa2 --tcp 3030,3031,3035,9299,9090,37255,9000,1111,8290' --description 'alias fxap coder port-forward fxa --tcp 3030,3031,9299,9090,37255,9000,1111,8290'
  coder port-forward fxa2 --tcp 3030,3031,3035,9299,9090,37255,9000,1111,8290 $argv
        
end
funcsave fxap
function setupstream
git branch --set-upstream-to=origin/(git rev-parse --abbrev-ref HEAD) (git rev-parse --abbrev-ref HEAD)
end
funcsave setupstream
alias gc "git commit"
funcsave gc
alias gca "git add .; and git commit"
funcsave gca
alias gs "git status"
funcsave gs
alias ga "git add"
funcsave ga
alias gaa "git add ."
funcsave gaa
alias gcb "git checkout"
funcsave gcb
alias gl "git log"
funcsave gl
alias gd "git diff"
funcsave gd
alias dc "docker-compose"
funcsave dc
alias k "kubectl"
funcsave k
