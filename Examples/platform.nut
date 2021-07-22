local Kaboom = Kaboom ({
    id = "myfirst2dgame"
    Size = VectorScreen (700,300)
    loadRoot = "kaboom/blocks/"
    gravityGame = true // activate a gravity game
    gravity = 5 // set the gravity
});

local map = [
    "============================"
    "============================"
    "                            "
    "                            "
    "                            "
    "                            "
    "                            " 
]

local obj = {
    "=": {
        spriteId = "pogC9x5"
        alias = "block"
        solid = true
    } 
}

Kaboom.scene ("game", function () {
    addLevel (map, obj)

    local circle = addEntity ({
        spriteId = "circle"
        Pos = Kaboom.getPos (3,13)
        body = true
        gravity = true
        alias = "circle"
    })

    local platform = addEntity ({
        spriteId = "square"
        Pos = Kaboom.getPos (6,13)
        Scale = VectorScreen (80,-20)
        body = true
        player = true
        alias = "square"
    })

    circle.collides ( "block", function (obj) {
        this.remove ();
    })


    platform.action (function () { 
        if (circle.props ().getIsGroundedStatus ()){ 
            circle.Pos.X -= cos (Script.GetTicks ()) * 100;
 
            circle.Jump (30)
        }

        Key ("right", function () { if (event == "down" && entity.props ().getBumpHeading () != "hitRightEnd" ) entity.move2d (5); });  
        Key ("left", function () { if (event == "down" && entity.props ().getBumpHeading () != "hitLeftEnd" ) entity.move2d (-5); }); 
    }); 
})

 

Kaboom.start ("game"); 