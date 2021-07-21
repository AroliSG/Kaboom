class Physics {
    Falling     = null;
    Grounding   = null;
    Jumping     = null;
    Moving      = null;
    Gravity     = null;
    Solid       = null;
    JumpRate    = null;
    Player      = null;
    Alias       = null;
    preTimer    = null;
    bumpHeading = null;
    Heading     = null;

    collisionEvent  = null;
    context         = null;
    store           = null;
    onKey           = null;

    constructor (context, data) {
            // pre-defined
        this.context    = context;
        this.Alias      = data.Alias; 
        this.Player     = data.Player;
        this.Solid      = data.Solid;
        this.Gravity    = data.Gravity;
        this.store      = data.store;
        
            // booleans
        this.Falling        = false;
        this.Grounding      = false;
        this.Jumping        = false;
        this.Moving         = false;

            // Array
        this.onKey          = {
            Heading = null
            Event   = null
        }
        this.collisionEvent = {};
        
        this.JumpRate   = 20;
    }

    entityFrame = function () {
        local FallingIndex = 0, JumpRate = 0, gravityTop = false;
        this.preTimer = function (p, game, context) { 
            if (game.gravityGame && context.Jumping && context.Gravity) {
                // Jumping and Gravity methods.
                if (JumpRate < context.JumpRate && !gravityTop) {
                    p.Pos.Y -= game.gravity;
                }
                else {
                    context.Jumping     = false;
                    context.Falling     = true;
                }
                JumpRate++;
            }  
            else {
                if (game.gravityGame && context.Gravity) {
                    if (p.Pos.Y != FallingIndex) {
                        context.Falling        = true;
                        context.Grounding      = false;
                    }

                    FallingIndex = p.Pos.Y
                    p.Pos.Y += game.gravity;
                }
            }

            context.store.forEach (function (e, obj) {
                    // firstly checking if player and obj exists.
                if (context.store.has (p) && context.store.has (e)) {
                    local groupTemp  = {
                        entity      = p
                        game        = context
                        hit         = {
                            entity  = e
                            Is      = function (arg) { if (arg == obj.physics.Alias) return true;  } 
                            spawn   = function (data = null) {
                                local wrapper = ::UI.Sprite ((obj.height-1) +"|"+ (obj.index));  
                                if (wrapper) {
                                    local repeat = 0;
                                    if (data && data.rawin ("repeat")) repeat = data.rawget ("repeat");
                                    
                                    if (obj.repeats == repeat) wrapper.destroy ();
                                    else obj.repeats ++;
                                }
                                else return false;

                                return {
                                    fadeOut = function () { 
                                        if (wrapper) {
                                            wrapper.show ();
                                            wrapper.fadeOut ();                                           
                                        }
                                    } 

                                    fadeIn = function () { 
                                        if (wrapper) {
                                            wrapper.hide ();
                                            wrapper.fadeIn ();                                           
                                        }
                                    } 
                                };
                            }
                        }
                    }

                    // get distance
                    local distance = game.getDistance (p.Pos.X, p.Pos.Y, e.Pos.X, e.Pos.Y);
                    if (distance < 50 && !p.hidden && !e.hidden && obj.physics.Solid && context.Solid) {

                            // collisions callback
                        if (context.collisionEvent.rawin (obj.physics.Alias)) context.collisionEvent.rawget (obj.physics.Alias).acall ([groupTemp]); 
                        if (context.collisionEvent.rawin ("bumpBody")) context.collisionEvent.rawget ("bumpBody").acall ([groupTemp]);  
                    }
                    
                        // verifying that class Alias is not equal of Items alias.
                    if (context.Alias != obj.physics.Alias) {
                        local r1 = { x = p.Pos.X, y = p.Pos.Y, w = p.Size.X, h = p.Size.Y }, r2 = { x = e.Pos.X, y = e.Pos.Y, w = e.Size.X, h = e.Size.Y };
                        if (!(r1.x>r2.x+r2.w || r1.x+r1.w<r2.x || r1.y>r2.y+r2.h || r1.y+r1.h<r2.y) && context.Solid && !e.hidden) {
                             if (context.onKey.Heading == "right" && r1.y >= r2.y && context.Solid && obj.physics.Solid) {                      
                                // difining space between obj and entity. - assigning bumpHeading
                                p.Pos.X = p.Pos.X - 5;
                                context.bumpHeading = "right"; // bump heading
                                
                                // calling callbacks.
                                if (context.collisionEvent.rawin ("bumpRight")) context.collisionEvent.rawget ("bumpRight").acall ([groupTemp]);  
                                if (context.collisionEvent.rawin ("bumpSides")) context.collisionEvent.rawget ("bumpSides").acall ([groupTemp]);
                            }
                                //  left collision                         
                            if (context.onKey.Heading == "left" && r1.y >= r2.y && context.Solid && obj.physics.Solid) {
                                // difining space between obj and entity. - assigning bumpHeading
                                p.Pos.X = p.Pos.X + 5;
                                context.bumpHeading = "left";

                                // calling callbacks.
                                if (context.collisionEvent.rawin ("bumpLeft")) context.collisionEvent.rawget ("bumpLeft").acall ([groupTemp]);  
                                if (context.collisionEvent.rawin ("bumpSides")) context.collisionEvent.rawget ("bumpSides").acall ([groupTemp]);
                            } 

                                // gravity game
                            if (game.gravityGame && context.Solid && obj.physics.Solid) {
                                    // up collision
                                if (r2.y <= r1.y) {
                                    gravityTop = true;

                                    if (context.collisionEvent.rawin ("bumpHead")) context.collisionEvent.rawget ("bumpHead").acall ([groupTemp]); 
                                    if (context.bumpHeading == null) p.Pos.Y = (r2.y + r2.h); 
                                }

                                    // bottom collision 
                                if (r2.y >= r1.y) { 
                                    if (p.Pos.Y >= (r2.y - r1.h)) p.Pos.Y = (r2.y - r1.h); 
                                
                                    context.Grounding   = true;
                                    context.Jumping     = false;
                                    context.Falling     = false;

                                    JumpRate    = 0;
                                    gravityTop  = false

                                    if (context.collisionEvent.rawin ("bumpFoot")) context.collisionEvent.rawget ("bumpFoot").acall ([groupTemp]); 
                                }
                            }
                                // without gravity game
                            else {
                                
                            }
                        }
                    }
                }
            });
        }
    }

    destroy = function () { Timer.Destroy (this.preTimer); }
}