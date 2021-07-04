# kaboom.nut
kaboom.nut based on kaboom.js. Its a vc-mp library that helps you to create any 2d game on your server. (client-side)

# Installation Guide
  - Pre-requisite: https://github.com/newk5/decui
 ```js
    dofile("decui/decui.nut"); 
    dofile("kaboom/kaboom.nut"); 
    
    local Kaboom = Kaboom ({
        id = "myfirst2dgame"
        Size = VectorScreen (3000,500)
        loadRoot = "kaboom/blocks/"
        gravityGame = true // activate a gravity game
        gravity = 10 // set the gravity
        
        // fullscreen = true // fullscreen
        // origin = "center" // alignment
        // bgcolor = [0,0,0] // background colour
        // debug = true  // debug mode
        // plugins = {} // trigger functions to kabooom to use later on with your game.
        // Key = {Id = "50", name = "p"} // add new keys
    });
    
    Kaboom.scene ("game", function () {
    });
    
    Kaboom.start ("game");
 ```
 
 
