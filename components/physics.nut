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
    Ignore      = null;
    tableIgnore = null;

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
        this.Ignore     = data.Ignore;
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
        this.tableIgnore    = {};
        
        this.JumpRate   = 20;
    }

    entityFrame = function () {
        local FallingIndex = 0, JumpRate = 0, gravityTop = false, menu = this;
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
                    local groupTemp  = function (p, e, debug = null) {
                            // debugging purpose.
                        local getIs = obj.physics.Alias;
                        if (debug) {
                            getIs = context.Alias;
                        }

                        return {
                            entity      = p
                            game        = context
                            hit         = {
                                entity  = e
                                Is      = function (arg) { if (arg == getIs) return true;  } 
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
                    }
                    
                        // verifying that class Alias is not equal of Items alias. 
                    if (menu.getAlias (context, obj.physics)) {
                        local r1 = { x = p.Pos.X, y = p.Pos.Y, w = p.Size.X, h = p.Size.Y }, r2 = { x = e.Pos.X, y = e.Pos.Y, w = e.Size.X, h = e.Size.Y };
                        if (!(r1.x>r2.x+r2.w || r1.x+r1.w<r2.x || r1.y>r2.y+r2.h || r1.y+r1.h<r2.y) && context.Solid && !e.hidden) {
                                // body collision!
                            if (context.collisionEvent.rawin (obj.physics.Alias)) context.collisionEvent.rawget (obj.physics.Alias).acall ([groupTemp (p, e)]); 
                            if (context.collisionEvent.rawin ("bumpBody")) context.collisionEvent.rawget ("bumpBody").acall ([groupTemp (p, e)]);   

                                // checking whether if obj is player or not for collision debug :>.
                            if (obj.physics.Player || !obj.physics.Player) {
                                if (obj.physics.collisionEvent.rawin (context.Alias)) obj.physics.collisionEvent.rawget (context.Alias).acall ([groupTemp (e, p, true)]); 
                                if (obj.physics.collisionEvent.rawin ("bumpBody")) obj.physics.collisionEvent.rawget ("bumpBody").acall ([groupTemp (e, p, true)]);   
                                
                                local bumpSides = null;
                                if (context.Heading == "left") bumpSides = "bumpLeft";
                                if (context.Heading == "right") bumpSides = "bumpRight";
                                if (context.Heading == "up") bumpSides = "bumpTop";
                                if (context.Heading == "down") bumpSides = "bumpBottom";

                                if (bumpSides) {
                                    if (context.collisionEvent.rawin (bumpSides)) context.collisionEvent.rawget (bumpSides).acall ([groupTemp (e, p, true)]);  
                                    if (context.collisionEvent.rawin ("bumpSides")) context.collisionEvent.rawget ("bumpSides").acall ([groupTemp (e, p, true)]);
                                }
                            }


                            // there's a wild behaviour which doesn't allow me to use the same right and left collision code.
                            local getIsIntersected = r1.y > r2.y || r1.y < r2.y;
                            if (game.gravityGame) getIsIntersected = r1.y >= r2.y;

                            // right collision
                            if (context.onKey.Heading == "right" && getIsIntersected && context.Solid && obj.physics.Solid) {                      
                                // difining space between obj and entity. - assigning bumpHeading
                                p.Pos.X = p.Pos.X - 5;
                                context.bumpHeading = "right"; // bump heading
                                
                                // calling callbacks.
                                if (context.collisionEvent.rawin ("bumpRight")) context.collisionEvent.rawget ("bumpRight").acall ([groupTemp (p, e)]);  
                                if (context.collisionEvent.rawin ("bumpSides")) context.collisionEvent.rawget ("bumpSides").acall ([groupTemp (p, e)]);
                            }
                                //  left collision                         
                            if (context.onKey.Heading == "left" && getIsIntersected && context.Solid && obj.physics.Solid) {
                                // difining space between obj and entity. - assigning bumpHeading
                                p.Pos.X = p.Pos.X + 5;
                                context.bumpHeading = "left";

                                // calling callbacks.
                                if (context.collisionEvent.rawin ("bumpLeft")) context.collisionEvent.rawget ("bumpLeft").acall ([groupTemp (p, e)]);  
                                if (context.collisionEvent.rawin ("bumpSides")) context.collisionEvent.rawget ("bumpSides").acall ([groupTemp (p, e)]);
                            } 

                                // gravity game
                            if (game.gravityGame && context.Solid && obj.physics.Solid) {
                                    // up collision
                                if (r2.y <= r1.y) {
                                    gravityTop = true;

                                    if (context.collisionEvent.rawin ("bumpHead")) context.collisionEvent.rawget ("bumpHead").acall ([groupTemp (p, e)]); 
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

                                    if (context.collisionEvent.rawin ("bumpFoot")) context.collisionEvent.rawget ("bumpFoot").acall ([groupTemp (p, e)]); 
                                }
                            }
                                // without gravity game
                            else {
                                local middleof = r1.x > r2.x || r1.x < r2.x;
                                if (context.onKey.Heading == "up" && middleof && r1.y >= r2.y && context.Solid && obj.physics.Solid) {  
                                                       
                                    // difining space between obj and entity. - assigning bumpHeading
                                    p.Pos.Y = p.Pos.Y + 5; 
                                    context.bumpHeading = "up"; // bump heading
                                    
                                    // calling callbacks.
                                    if (context.collisionEvent.rawin ("bumpTop")) context.collisionEvent.rawget ("bumpTop").acall ([groupTemp (p, e)]);  
                                    if (context.collisionEvent.rawin ("bumpSides")) context.collisionEvent.rawget ("bumpSides").acall ([groupTemp (p, e)]);
                                }
                                    //  left collision                         
                                if (context.onKey.Heading == "down" && r1.y <= r2.y && middleof &&context.Solid && obj.physics.Solid) {
                                    // difining space between obj and entity. - assigning bumpHeading
                                    p.Pos.Y = p.Pos.Y - 5; 
                                    context.bumpHeading = "down";
  
                                    // calling callbacks.
                                    if (context.collisionEvent.rawin ("bumpBottom")) context.collisionEvent.rawget ("bumpBottom").acall ([groupTemp (p, e)]);  
                                    if (context.collisionEvent.rawin ("bumpSides")) context.collisionEvent.rawget ("bumpSides").acall ([groupTemp (p, e)]);
                                } 
                            }
                        }
                    }
                }
            });
        }
    }

    getAlias = function (p, obj) {
        if (p.Ignore && p.Ignore.find (obj.Alias) != null) return false;
        if (p.Alias == null) return true;

        if (p.Alias != obj.Alias) return true;
    }
}