# Local announcements

Copy `game_announcements.php` next to the site's `login.php` (currently
`C:\UniServerZ\www`). The client requests
`http://127.0.0.1/game_announcements_clientzin.php` and expects a JSON object with a `clientzin`
array. An empty array means there are currently no announcements.

Edit the endpoint's `$announcements` array to publish announcements. Follow the
fields consumed by `modules/game_announcements/announcements_data.lua` and
`game_announcements.lua`; each announcement needs a unique `id`.

This endpoint is installed separately from the executable/PDB artifacts.
