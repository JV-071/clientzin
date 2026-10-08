# Recovered resource branch

Based on main, replacing assets/mods/modules with current recovered resources. Uses readable Lua directly; no original protected executables, bytecodes, profiles or extraction tools are included.

Public RSA and local login configuration match main. Previous product service hosts now point to http://127.0.0.1; the local HTTP backend must provide the corresponding routes.

Native crash, Lua traceback and protocol diagnostics remain those of main. No speculative packet parsing or graphics changes were applied. Unresolved runtime binding candidates are not proof of bugs and require verification.

Some recovered Lua names remain inferred or missing. Success with the protected original engine does not certify compatibility with this external source. Validate against local Crystalserver using GitHub builds; no local C++ build is performed.

Local announcements use /game_announcements_clientzin.php. The template tools/web/game_announcements.php has been installed under this route on the test machine, leaving the existing feed unchanged. On another machine, deploy the same template under that route.
