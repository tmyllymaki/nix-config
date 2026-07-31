{
  flake.hjemModules.rider-config = {
    config,
    lib,
    pkgs,
    ...
  }: let
    intellimacs = pkgs.fetchgit {
      url = "https://github.com/tmyllymaki/intellimacs.git";
      rev = "116e566bafb4c7fe9a2962a746281053e59b1f49";
      sha256 = "Aomn1sS2ZlruWy8UMKkPLn1bOX3kLThRTgLgzFUo/yk=";
    };
  in {
    options.custom.home.rider-config.enable = lib.mkEnableOption "home.rider-config";

    config = lib.mkIf config.custom.home.rider-config.enable {
      files = {
        ".ideavimrc".text = ''
          set shellcmdflag=-lic
          set shellxquote=

          " My own vim commands
          nnoremap Y y$

          " Add/edit actions
          nnoremap <leader>gl <Action>(Vcs.Show.Log)

          let mapleader=" "

          """ Common settings -------------------------
          set showmode
          set smartcase
          set so=5
          set incsearch
          set rnu
          set visualbell
          set noerrorbells

          """ Plugins  --------------------------------
          set argtextobj
          set textobj-entire
          set ReplaceWithRegister
          set easymotion
          set surround
          set multiple-cursors
          set commentary
          set NERDTree
          set exchange
          set highlightedyank
          set textobj-indent
          packadd matchit
          set which-key
          set peekaboo
          set functiontextobj
          Plug 'justinmk/vim-sneak'

          """ Plugin settings -------------------------
          let g:argtextobj_pairs="[:],(:),<:>"

          map <leader>jw <Plug>(easymotion-bd-w)
          map <leader>jl <Plug>(easymotion-bd-jk)
          "map <leader>fp :action SelectInProjectView<CR>
          "map <leader>ga :action Annotate<CR>
          map <leader>ej <Action>(ReSharperGotoNextErrorInSolution)

          " Reformat the current line only
          map <leader>cf V:action ReformatCode<CR>
          map <leader>ca <Action>(ShowIntentionActions)

          map <leader>mrr <Action>(RenameElement)

          map gq :action com.andrewbrookins.idea.wrap.WrapAction<CR><Esc>

          map <leader>th <Action>(ToggleInlayHintsGloballyAction)
          map gt <Action>(GotoTypeDeclaration)
          map gi <Action>(GotoImplementation)


          map <leader>dt vat<Esc>da>`<da>
          map <leader>dm vaBo{x

          map <leader>me <Action>(EmmetUpdateTag)
          map <leader>mse <Action>(SurroundWithEmmet)
          map <leader>mss <Action>(SurroundWithLiveTemplate)


          " Just makes me nervous
          map H h

          source ~/.intellimacs/spacemacs.vim
          source ~/.intellimacs/extra.vim
          source ~/.intellimacs/major.vim
          source ~/.intellimacs/hybrid.vim
          source ~/.intellimacs/which-key.vim

          map <leader>mi <Action>(ShowIntentionActions)

          set timeoutlen=1000
          set ideajoin

          nmap <C-o> <Action>(Back)
          nmap <C-i> <Action>(Forward)
          noremap gV `[v`]
          let g:surround_{char2nr('o')} = "["\r"]"

          map gh <Action>(ShowErrorDescription)

          """ Map ctrl J and ctrl K to go to next and previous difference
          map <leader>gj <Action>(NextDiff)
          map <leader>gk <Action>(PreviousDiff)

          """ Map ctrl shift J and ctrl K to go to next and previous difference
          map <C-S-j> <Action>(Diff.NextChange)
          map <C-S-k> <Action>(Diff.PrevChange)

          map <leader>gr <Action>(Vcs.RollbackChangedLines)
          map <leader>gn <Action>(VcsShowNextChangeMarker)
          nmap <leader>gp <Action>(VcsShowPrevChangeMarker)

          nmap <leader>hm <action>(HarpoonerQuickMenu)
          nmap <leader>ha <action>(HarpoonerAddFile)

          nmap <leader>hn <action>(HarpoonerNextFileAction)
          nmap <leader>hp <action>(HarpoonerPreviousFileAction)

          vmap J <action>(MoveLineDown)
          vmap K <action>(MoveLineUp)
          nmap <C-j> <action>(MoveLineDown)
          nmap <C-k> <action>(MoveLineUp)

          nnoremap H 0
          nnoremap L $

          map <leader>sn <Action>(NextOccurence)
          map <leader>sp <Action>(PreviousOccurence)
          map <leader>rl <Action>(RecentLocations)

          map <leader>ma <Action>(EfCore.Features.Migrations.AddMigrationAction)

          """ Function to search for the latest EF core migration file in the current project and open it
          function! SearchLatestMigrationFile()
              let l:latest_migration_file = system('git status | grep -E "Migrations/[0-9].*\.cs" | sort -V | tail -n 1')
              if !empty(l:latest_migration_file)
                  execute 'edit' l:latest_migration_file
              else
                  echo "No migration files found."
              endif
          endfunction

          nnoremap <leader>ml :call SearchLatestMigrationFile()<CR>

          let g:WhichKeyDesc_Windows_CloseAllOtherWindows = "<leader>wm close-all-other-windows"
          nnoremap <leader>wm    :action HideAllWindows<CR>
          vnoremap <leader>wm    :action HideAllWindows<CR>

          map <Leader>pf <action>(com.mituuz.fuzzier.Fuzzier)
          map <Leader>mf <action>(com.mituuz.fuzzier.FuzzyMover)
          map <Leader>gx <action>(com.mituuz.fuzzier.FuzzierVCS)
          map <Leader>ff <action>(com.mituuz.fuzzier.FuzzyGrep)
        '';

        ".intellimacs".source = intellimacs;
      };
    };
  };
}
