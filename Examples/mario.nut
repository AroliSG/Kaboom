
local Kaboom = Kab ({
    id = "myfirst2dgame"
    loadRoot = "kaboom/"

    // plugins = {} // trigger functions to kabooom to use later on with your game.
    // addKey = { keyId = "50", keyName = "p" } // add new keys to game.
    // debug = true
}); 

local map = [ 
    "                                                                                                                                                                                                              "
    "                                                                                                                                                                                                              "
    "                                                                                                                                                                                                              "
    "                   $                                                                                                                                                                                          "
    "                   -                                                            $               $                                                                                      %%%                    "
    "                                                         @@@@@@@@@@@@@@@@@@@ @@@-               #            @@@@    @--@                                                             %%%%                    "
    "                                                                                                                                                                                     %%%%%                    "
    "                  $                                                                          $  $  $                             %    %                                             %%%%%%                    " 
    "             @   @#@*@                                @-@                       @     @@@    -  -  -      @           @@        %%    %%         %%   %%              @@-@         %%%%%%%                    "  
    "                                  &      &                                                                                     %%%    %%%       %%%   %%%                       & %%%%%%%%                    "
    "                             &    +      +                                                                                    %%%%    %%%%     %%%%   %%%%       &              +%%%%%%%%%          %         " 
    "===========  ==================================  ===============   ================================================================================   ========================================================" 
] 


local obj = {
    "%": {
        spriteId    = "tiles"
        alias       = "block-2"
        solid       = true

        spritesheet = { Id  = 33, UV  = VectorScreen (16, 16), X   = 0.03035, Y   = 0.035 }
    }

    "@": {
        spriteId    = "tiles"
        alias       = "block-1"
        solid       = true

        spritesheet = { Id  = 1, UV  = VectorScreen (16, 16), X   = 0.03035, Y   = 0.035 }
    }

    "=": {
        spriteId    = "tiles"
        alias       = "block"
        solid       = true

        spritesheet = { Id  = 0, UV  = VectorScreen (16, 16), X   = 0.03035, Y   = 0.035 }
    }

    // surprise box for repeatables.
    "#": {
        spriteId    = "tiles"
        alias       = "surprise-repeat" 
        solid       = true

        spritesheet = {Id  = 24, UV  = VectorScreen (16, 16), X = 0.03035, Y = 0.035 }        
    }

    // surprise box for mushroom.
    "*": {
        spriteId    = "tiles"
        alias       = "mushroom-surprise"
        solid       = true

        spritesheet = {Id  = 24, UV  = VectorScreen (16, 16), X = 0.03035, Y = 0.035 }  
    }    
    
    // surprise box for normal.
    "-": {
        spriteId    = "tiles"
        alias       = "surprise"
        solid       = true

        spritesheet = {Id  = 24, UV  = VectorScreen (16, 16), X = 0.03035, Y = 0.035 }  
    }   

    "&": {
        spriteId    = "rl3cTER"
        alias       = "pipe"
        solid       = true
    } 
    
    "+": {
        spriteId    = "rl3cTE"
        alias       = "pipe"
        solid       = true
    } 

    "$": {
        spriteId    = "wbKxhcd"
        alias       = "coins"
        hide        = true
    }     
}

Kaboom.scene ("1-1", function () {
    // config
    config ({
        Size        = VectorScreen (6500,600)
        gravityGame = true // activate a gravity game 
        gravity     = 8 // set the gravity
        origin      = "mid_left" // alignment
        bgcolor     = [4, 156, 216] // background colour
        mouse       = false
    })

    // level
    addLevel (map, obj);

    local enemy = addEntity ({
        spriteId = "KPO3fR9g" 
        Size = VectorScreen (30, 30) 
        Pos = getPos (6, 38)
        solid = true
        gravity = true
        alias = "enemy"
    }) 
 
    enemy.action (function () {
        if (enemy.props ().getBumpHeading () == "left") enemy.move2d (1, 0);
        else enemy.move2d (-1, 0);
    }) 

    local mushroom= addEntity ({
        spriteId    = "0wMd92p"
        Size     = VectorScreen (30, 30) 
        Pos         = getPos (5,20)
        solid       = true 
        gravity     = true 
        alias       = "mushroom"
    })
    mushroom.hide ();
 
    mushroom.action (function () {
        if (!mushroom.hidden) {
            if (mushroom.props ().getBumpHeading () == "left") mushroom.move2d (1, 0);
            else mushroom.move2d (-1, 0);
        }
    })

    local mario = addEntity ({
        spriteId    = "mariosheet"
        Size        = VectorScreen (30, 40) 
        Pos         = getPos (6, 2)
        solid       = true
        gravity     = true
        player      = true
        alias       = "mario"

        spritesheet = {  
            Id  = 0, // will reproduce sprite id 0 in sprite sheet
            UV  = VectorScreen (64, 64), 
            X   = 0.25, 
            Y   = 0.2 
        } 
    });   

    local startLeft = 0, startRight = 0;
    mario.action (function() {
        if (entity.props ().getIsFallingStatus ()) {
           if (entity.props ().getHeading () == "right") entity.playAnim ([0]);
           if (entity.props ().getHeading () == "left") entity.playAnim ([0], {mirror=true});
        }

        Key ("right", function () {
            if (event == "down") {  
                entity.move2d (5, 0);
                if (startLeft < 3 && entity.props ().getIsGroundedStatus ()) {
                    entity.playAnim ([16]);

                    startLeft ++;
                    startRight  = 0; 
                } 
                else {
                    // run animation
                    if (!entity.props ().getIsJumpingStatus ()) entity.playAnim ([3,2,1], { 
                        // anim speed
                        animSpeed = 0.5

                        // when player stops moving, anim frame will be set to 0.
                        Immobilized = 0
                    });
                }

                if (entity.props ().getIsFallingStatus ()) entity.playAnim ([9]); 
            }  
        });

        Key ("left", function () {  
            if (event == "down") {
                entity.move2d (-5, 0); 
                if (startRight < 3 && entity.props ().getIsGroundedStatus ()) {
                    entity.playAnim ([16], {mirror=true});

                    startLeft = 0;
                    startRight++;
                }
                else {
                    if (!entity.props ().getIsJumpingStatus ()) entity.playAnim ([3,2,1], { 
                        animSpeed = 0.5
                        Immobilized = 0 // when entity stops moving, the anim will be set to 3.
                        mirror = true
                    });
                }

                if (entity.props ().getIsFallingStatus ()) entity.playAnim ([9], {mirror = true});
            }
        });  

        Key ("space", function () { 
            if (event == "up") {
                entity.Jump (20);
                if (entity.props ().getHeading () == "right") entity.playAnim ([4]);
                if (entity.props ().getHeading () == "left") entity.playAnim ([4], {mirror = true});
            }    
        });   
        
        if (entity.props ().IsOutWorld ()) Kaboom.go ("gameover");
    });

    mario.collides ("bumpHead", function () {
        if (hit.Is ("surprise")) { 
                // will get the element above 'surprise.'
            local coins = hit.spawn ();
            if (coins) coins.fadeOut ();
            else hit.entity.playAnim([27]);
        }  

        if (hit.Is ("surprise-repeat")) { 
            // will repeat the 'entity' 5 times before destroying it.
            local coins = hit.spawn ({ repeat = 5 });    
            if (coins) coins.fadeOut ();
            else hit.entity.playAnim([27]);
        }  
 
        if (hit.Is ("mushroom-surprise")) {
             // play a frame of a spritesheet and stop it, if it have an animation.
            hit.entity.playAnim([27])
 
            // fade in animation.
            if (mushroom.props ().getIsExists ()) mushroom.fadeIn ();
        }           
    }); 

    mario.collides ("mushroom", function () { 
        hit.entity.destroy2d ();
        entity.props ().Scale (1, 1.2);
    });  

    render (function () {
        // activating timers for entities
        mario.render ();     
        mushroom.render ();
        enemy.render ();
    })
})
    
.camPos ("mariosheet", { 
    stopLeft = true // camera will only move to opposite direction.
});      

// title scene
Kaboom.scene ("title", function () {    
    config ({
        backgroundImage = "title"
        origin = "center" // alignment
        mouse = true
    })

    // welcome message
    drawLabel ({
        id      = "message"     
        Text    = "Welcome to Kaboom."
    }) 
  
    // start 
    drawLabel ({
        id      = "Start"     
        Text    = "Start game"
        FontSize = 25
        Pos = VectorScreen (400,300)
        
        onClick = function () {
            // moving to the next stage
            Kaboom.go ("1-1");
        }
    })

    drawImage ({
        spriteId = "smb" // the id of the image
        Pos = VectorScreen (150,100)
    })
});

// game over scene
Kaboom.scene ("gameover", function () { 
    config ({
        bgcolor = [0, 0, 0]
        origin  = "center" // alignment
        mouse   = true
    }); 

    drawLabel ({
        id      = "lost"     
        Text    = "You lost, try playing again.."
        TextColour = Colour (255,255,255)
    })  

    drawLabel ({
        id      = "startover"     
        Text    = "Start over"
        FontSize = 25
        TextColour = Colour (255,255,255)
        origin      = "center"
        
        onClick = function () {
            // moving to the next stage
            Kaboom.go ("1-1");
        }
    })
});

Kaboom.start ("title");