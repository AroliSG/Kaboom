//https://imgur.com/a/F8Jkryq
function errorHandling(err) {
    local stackInfos = getstackinfos(2);

    if (stackInfos) { 
        local locals = "";

        foreach(index, value in stackInfos.locals) {
            if (index != "this")
                locals = locals + "[" + index + "] " + value + "\n";
        }

        local callStacks = "";
        local level = 2;
        do {
            callStacks += "*FUNCTION [" + stackInfos.func + "()] " + stackInfos.src + " line [" + stackInfos.line + "]\n";
            level++;
        } while ((stackInfos = getstackinfos(level)));

        local errorMsg = "AN ERROR HAS OCCURRED [" + err + "]\n";
        errorMsg += "\nCALLSTACK\n";
        errorMsg += callStacks; 
        errorMsg += "\nLOCALS\n";
        errorMsg += locals;

        Console.Print(errorMsg);
    }    
}   

seterrorhandler(errorHandling);

dofile("decui/decui.nut"); 
GUI.SetMouseEnabled(false);

local plugins = {
    Timer = function () {
        return 2;
    }
}

local c = UI.Kaboom ({
    id = "game1"
    Size = VectorScreen (700,500)
    loadRoot = "kaboom/blocks/"
    plugins = plugins
});

// Console.Print (c.prop.Timer ()) //calling the prop Timer

c.scene ("game", function () {
    // map
    local map = [
        "                  "
        "                  "
        "    $             "
        "    #   =*=       "
        "                  "
        "  =        &      "
        "============  ===="
    ] 

    // objets
    local obj = {
        // Id | sprite | solid | Id 
        "=": ["pogC9x5", 1, "block"]
        "#": ["gesQ1KP", 1, "surprise"]
        "*": ["gesQ1KP", 1, "mushroom-surprise"]
        "&": [ "rl3cTER", 1, "pipe" ]
        "$": ["wbKxhcd", 1, "coins", true]
    }


    c.addLevel (map, obj);

    // enemy
    local enemy = c.addEntity ([ "KPO3fR9", {
        height = (-40)
        width = (-10)
        Solid = true 
        alias = "enemy" 
        Pos = VectorScreen (315,300)
    }]);

    local index = 0;
    enemy.action (function () {
        if (enemy.props ().getBumpHeading () == "left") // mushroom hit left side of an obj, it should return back to other side
            enemy.move2d (1);
        else enemy.move2d (-1); // going to the left 
    })

    local enemy2 = c.addEntity ([ "KPO3fR9g", {
        height = (-40)
        width = (-10)
        Solid = true
        alias = "enemy"
        Pos = VectorScreen (200,300)
    }]);

    enemy2.action (function () {
        if (enemy2.props ().getBumpHeading () == "left") // mushroom hit left side of an obj, it should return back to other side
            enemy2.move2d (1)
        else enemy2.move2d (-1) // going to the left  
    })

    local mushroom = c.addEntity ([ "0wMd92p", {
        height = (-20)
        width = (-5)
        Solid = true
        alias = "mushroom"
        Pos = VectorScreen (315,155)
    }]);
    mushroom.hide ();

    mushroom.action (function () {
        if (!mushroom.hidden) {
            if (mushroom.props ().getBumpHeading () == "left") mushroom.move2d (1);
            else mushroom.move2d (-1); // going to the left 
        }
    })

    /*
        @{player} Non-bot
        .action - assigning to keys player
        .collides - giving to player collision events and what to when that happens
    */

    local player = c.addEntity ([ "mario", {
        height = (-40) 
        width = (-10) 
        Solid = true   
        alias = "mario"
        Pos = VectorScreen (20,200)
        player = true 
    }]);

    // runs every frame when obj exists
    player.action (function () {
        Key ("right", function () {
            if (event == "down") 
                entity.move2d (5); 
        });
    
        Key ("left", function () {
            if (event == "down") 
                entity.move2d (-5); 
        });
        
        Key ("space", function () { 
            if (event == "up") 
                entity.Jump (150);  
        });    
    });

    // Is called when body bumps an object.
    player.collides ("bumpBody", function (obj) {
        if (obj.Is ("mushroom") && obj.exists ()) {
            obj.remove ();

            player.Scale (10); 
        }
    });
    
    // Is called when head bumps an object.
    player.collides ("bumpHead", function (obj) {
        if (obj.Is ("surprise") && obj.exists ()) {
            // only fadeOut its repeatable.
            if (obj.exists ("hidden")) obj.spawn ({
                repeat = 5
            }).fadeOut ();

            else 
            obj.changeImageTo ("bdrLpi6");
        } 

        // checking is mushroom is not destroyed.
        if (obj.Is ("mushroom-surprise") && !mushroom.props ().getIsDestroyedStatus ()) {
            obj.changeImageTo ("bdrLpi6");
            mushroom.fadeIn ();
        }    
    });
    
    // Is called when foot bumps an object.
    player.collides ("bumpFoot", function (obj) {
        if (obj.Is ("enemy") && obj.exists ()) {
        this.Size.Y = this.Size.Y/2;
                                                                    
            obj.remove ();       
        }
    }); 

    // Is called when right bumps an object.
    player.collides ("bumpRight", function (obj) {
        if (obj.Is ("enemy") && obj.exists ()) {
            player.Size.Y = player.Size.Y/2;
            player.remove ();
        }
    }); 

    // Is called when left bumps an object.
    player.collides ("bumpLeft", function (obj) {
        if (obj.Is ("enemy") && obj.exists ()) {
            player.Size.Y = player.Size.Y/2;
            player.remove ();
        }
    });
})

c.scene ("lose", function () {
    local h = UI.Label({
        id = "lose2d"  
        Text = "Game Over"
        align = "center" 
        TextColour = Colour (255,255,255)
    })
    parent.add (h, false);
})

c.start ("lose");
//c.go ("lose")