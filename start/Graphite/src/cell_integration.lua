Graphite.BindRenderData("mover", {
    texture = "start/Graphite/images/mover.png",
    title = "Mover",
    description = "Moves forward",
})

Graphite.BindRenderData("generator", {
    texture = "start/Graphite/images/generator.png",
    title = "Generator",
    description = "Duplicates the cell behind it, in front of it.",
})

Graphite.BindRenderData("push", {
    texture = "start/Graphite/images/push.png",
    title = "Push",
    description = "Can be pushed from any direction",
})

Graphite.BindRenderData("slide", {
    texture = "start/Graphite/images/slide.png",
    title = "Slide",
    description = "Can be pushed only from directions parallel to the white lines",
})

Graphite.BindRenderData("enemy", {
    texture = "start/Graphite/images/enemy.png",
    title = "Enemy",
    description = "When something tries to push it, the thing pushing it and the enemy will die.",
})

Graphite.BindRenderData("trash", {
    texture = "start/Graphite/images/trash.png",
    title = "Trash",
    description = "When something tries to push it, the thing pushing it will die.",
})

Graphite.BindRenderData("wall", {
    texture = "start/Graphite/images/wall.png",
    title = "Wall",
    description = "Can't be moved",
})

Graphite.BindRenderData("empty", {
    texture = "start/Graphite/images/empty.png",
    title = "Erase",
    description = "This is pure emptyness.",
})

Graphite.BindRenderData("rotatorCW", {
    texture = "start/Graphite/images/rotatorCW.png",
    title = "Rotator CW",
    description = "Rotates adjacent cells clockwise",
})

Graphite.BindRenderData("rotatorCCW", {
    texture = "start/Graphite/images/rotatorCCW.png",
    title = "Rotator CCW",
    description = "Rotates adjacent cells counter-clockwise",
})