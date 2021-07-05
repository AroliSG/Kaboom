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
 
### Transform
![transform](https://user-images.githubusercontent.com/58828449/124415218-664ed100-dd22-11eb-80d4-5a33408fd2ed.gif)

### Platform game
![platform](https://user-images.githubusercontent.com/58828449/124415524-086eb900-dd23-11eb-9280-7f1c24797bf9.gif)

## Mario game
