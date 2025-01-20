# Ray2D
2D raycasting using GuiObjects

## Example

```lua
local screengui = script.Parent
local start = screengui.Start
local finish = screengui.Finish

local ray2d = require(game.ReplicatedStorage.Ray2D)
local ray = ray2d.new(screengui, start.Position, finish.Position, {
	FilterType = Enum.RaycastFilterType.Exclude,
	FilterDescendantInstances = {start, finish}
} :: ray2d.RaycastParams2D)

ray:Cast()
```
