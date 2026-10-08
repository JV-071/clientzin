# Resource integration validation

Source baseline: main at ebf86a6f6ca25ec390552cef39021145f5e8e6e0. The src tree and init.lua are unchanged from that baseline. Runtime resources are replaced with the current recovered assets, mods and modules.

Verified locally without compiling C++: 263 Lua sources compile; no Lua bytecode files remain; all 84 module manifests resolve their scripts; required bootstrap files and catalog resources exist; both packaging tests pass. The public RSA constants match main. Former product service hosts point to loopback; port 80 serves HTTP and the local game server listens on 7171/7172. The announcement route returns HTTP 200 with the expected clientzin envelope.

A GET probe of login.php timed out; no credentials were submitted. This is not validation of the actual POST login flow. Native builds and login against the local server remain necessary.

The existing runtime audit reports 66 unresolved binding candidates. Some are Lua-defined globals or guarded optional capabilities; others may require source integration. No compatibility stubs or speculative protocol changes were applied. Run tools/audit_runtime.py for the detailed candidate list.

Diagnostics use the existing main implementations: clientzin.log for general and Lua errors, packet.log for unknown opcodes and protocol parse errors, crashreport.log for native exceptions/assertions. These files are generated when their respective events occur; absence of packet/crash reports is not itself a failure. Keep the matching PDB from the GitHub artifact when investigating native failures. No external protected-engine collector is included or required by this source-based branch.
