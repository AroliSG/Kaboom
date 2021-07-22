class Kab {
    Id          = null;
    store       = null;
    loadRoot    = "kaboom/";
    gravityGame = null;
    gravity     = null;
    debug       = null;
    
    myKey = {
        "38": "up"
        "40": "down"
        "39": "right"
        "37": "left"
        "32": "space"
    }

    sceneBorder     = null;
    renderTimer     = null;
    funcTimeout     = null;

    constructor(obj) {
        this.Id     = obj.id;
        this.funcTimeout = {
            callback    = null
            gIndex      = 0
            timeOut     = 0
        }

        this.store  = {
            frames      = []
            entities    = map ()
            scenes      = map ()
            draws       = map ()     
        }

        if (obj.rawin ( "debug" )) this.debug = obj.debug;
        if (obj.rawin ("addKey")) this.myKey [obj.addKey.keyId] <- obj.addKey.keyName;

        this.attachProps ();
        this.attachKey ([0x28, 0x27, 0x26, 0x25, 0x20]);
    }

    createTemplate = function (obj) {   
        if (this.getParent ()) this.getParent ().destroy ();

        local width = GUI.GetScreenSize().X / 2, height = GUI.GetScreenSize().Y / 2;      
        local origin = "center", color = Colour (255,255,255,20), c;
        
        if (obj.rawin ( "mouse" )) {
            if (obj.mouse) GUI.SetMouseEnabled(true);
            else GUI.SetMouseEnabled(false);
        }
        if (obj.rawin ("sceneBorder")) this.sceneBorder = obj.sceneBorder;

        if (obj.rawin ( "Size" )) {
            width = obj.Size.X; 
            height = obj.Size.Y;
        }
        
        if (obj.rawin ( "gravity" )) this.gravity = obj.gravity;
        else this.gravity = 10;
        
        if (obj.rawin ( "gravityGame" )) this.gravityGame = obj.gravityGame;

        if (obj.rawin ( "fullscreen" )) {
            if (obj.fullscreen) {
                width   = GUI.GetScreenSize().X; 
                height  = GUI.GetScreenSize().Y;  
            }
        }      
 
        if (obj.rawin ( "origin" )) {
            origin = obj.origin;
        }

        if (obj.rawin ("bgcolor")) {
            local alpha = 255;
            if (obj.bgcolor.len () == 4) alpha = obj.bgcolor [3];

            color = Colour (obj.bgcolor [0], obj.bgcolor [1], obj.bgcolor [2], alpha);
        }

        if (obj.rawin ( "backgroundImage" )) {
            c = UI.Sprite ({
                id = this.Id
                file = this.loadRoot + obj.backgroundImage + ".png"
                Size = VectorScreen (width, height)
                align = origin   
            })
        }
        else {
            c = UI.Canvas({
                id = this.Id      
                Size = VectorScreen (width, height)
                Colour = color 
                align = origin   
            })
        }

        return c; 
    }    

    // scenes
    scene = function (segment, callback) {
        local context   = this;
        this.store.scenes.set (segment, { open = callback });
         return { 
            camPos = function (entityId, data = null) {
                Timer.Create (::UI, function (context) {
                    local entity = UI.Canvas (entityId) ? UI.Canvas (entityId) : UI.Sprite (entityId);
                    local parent = context.getParent ();

                    if (context.store.entities.has (entity)) {
                        if (parent && entity) {
                            /*if (!context.camPos.X) {
                             // parent.Pos.X        = 0;
                                context.camPos.X    = true;
                            } */
  
                            // when canvas is almost reaching the horizontal end, make the effect to stop.
                            local direction = context.store.entities.get (entity).physics.Heading;
                        
                            if (direction == "left" || direction == "right") {
                                 
                            // if (entity.Pos.X < (parent.Size.X - (GUI.GetScreenSize().X/2)) ) parent.Pos.X = -(entity.Pos.X-entity.Size.X); 
                            // Console.Print ( parent.Size.X/2 - GUI.GetScreenSize().X/2 )
                            
                            if ((parent.Size.X / GUI.GetScreenSize().X) - entity.Pos.X == 0) {
                                
                            }  
                            else { 
                                    local stopLeft = data && data.rawin ( "stopLeft" ) && data.stopLeft, stopRight = data && data.rawin ( "stopRight" ) && data.stopLeft, event = context.store.entities.get (entity).physics.onKey.Event == "down";
                                    local right = (event && direction == "right" && !stopRight), left = (event && direction && !stopLeft);
   
                                    if (right && context.store.entities.has (entity) && (GUI.GetScreenSize().X/2) - entity.Pos.X <= 0 && entity.props ().getBumpHeading () != "hitRightEnd") parent.Pos.X -= 5;
                                    if (left && (GUI.GetScreenSize().X/2) - entity.Pos.X <= 0 && entity.props ().getBumpHeading () != "hitLeftEnd") parent.Pos.X += 5;
                                }
                            } 
                            
                            if (direction == "up" || direction == "bottom") { 
                            }

                            // when canvas is almost reaching the verticcal end, make the effect of stopping. 
                            if (data && data.rawin ("gravityEffect") && gravityIsEnabled) { 
                                // moving Y position up.               
                                if (entity.props ().getIsJumpingStatus () && !context.camPos.Y) { 
                                    parent.Pos.Y        = parent.Pos.Y - 35; 
                                    context.camPos.Y    = true;
                                } 

                                // returning canvas back to Y position when entity is grounded. 
                                if (entity.props ().getIsGroundedStatus () && context.camPos.Y) { 
                                    parent.Pos.Y        = parent.Pos.Y + 35;
                                    context.camPos.Y    = false;
                                }
                            }
                        }
                    }
                }, 1,0, context);
            }    
        }  
    }
    
    // start 
    start = function (segment) {
        if (!this.store.scenes.has ("start")) {
            if (this.store.scenes.has (segment)) this.store.scenes.get (segment).open.acall ([this]);
            this.store.scenes.set ("start", true);
        }
    }

    // go
    go = function (segment) {
        // clearing timers.
        if (Timer.Exists (this.renderTimer)) Timer.Destroy (this.renderTimer);
        
        // clearing up the Timeout.
        this.funcTimeout = {
            callback    = null
            gIndex      = 0
        }

        // entering the stage provided.
        if (this.store.scenes.has ("start") && this.store.scenes.has (segment)) {
            this.every (function (e) { e.destroy2d (); });
            this.store.scenes.get (segment).open.acall ([this]);
        }
    }

    // config the canvas
    config = function (data) {
        this.createTemplate (data);
    }

    // level creator
    addLevel = function  (map, obj) {
        if (!this.getParent ()) {
            if (this.debug) throw "components outside of scene. all components must be inside a scene.";
            else return 1;
        }

        local parent = this.getParent ()
        local height = 0, index = 0, empty = 0;

        foreach (horizontal in map) {
            // frames
            this.store.frames.push ([]);

            // vertical frames.
            height ++;
            
            local proportions = VectorScreen (parent.Size.X / horizontal.len (), parent.Size.Y / map.len ()), sheet;
            foreach (getId in horizontal) {
                getId = getId.tochar ();
                if (index != 0) empty += proportions.X //- 0.2;
                if (horizontal.len () == index) {
                    index = 0;
                    empty = 0;
                }

                // storing frames
                this.store.frames [height-1].push (VectorScreen (proportions.X * index, ([height-1] == 0 ? 0 : proportions.Y) * (height-1)));
                
                if (obj.rawin (getId)) {  
                    local alias = null, solid = false, gravity = false, e, rgb = Colour (255,255,255);

                    if (obj [getId].rawin ("Colour")) rgb = obj [getId].Colour;
                    if (obj [getId].rawin ("square") && obj [getId].square) {
                        e = UI.Canvas({
                            id      = height + "|" + index
                            Colour  = rgb
                        })
                    }
                    else {
                        e = ::UI.Sprite({ 
                            id      =  height + "|" + index
                            file    = this.loadRoot + obj [getId].spriteId + ".png"     
                            Colour  = rgb
                        });
                    }

                    if (obj [getId].rawin ("alias")) alias = obj [getId].alias;
                    if (obj [getId].rawin ("solid")) solid = obj [getId].solid;
                    if (obj [getId].rawin ("gravity")) gravity = obj [getId].gravity;
                    if (obj [getId].rawin ("hide")) e.hide ();

                    if (obj [getId].rawin ("spritesheet")) {
                        sheet = SpriteSheet (e, obj [getId].spritesheet.UV.X, obj [getId].spritesheet.UV.Y, obj [getId].spritesheet.Id).define ( "block", obj [getId].spritesheet.X, obj [getId].spritesheet.Y);  
                    } 

                    this.store.entities.set (e, {
                        index       = index 
                        height      = height
                        repeats     = 0 
                        
                            // animations
                        animFrames  = 0
                        anims       = sheet
                        stopAnim    = false

                            // physics
                        physics     = Physics (this, {
                            Alias   = alias
                            Solid   = solid
                            Gravity = gravity
                            Ignore  = null
                            Player  = false

                            store   = this.store.entities
                        })
                    });
                    if (gravity) this.store.entities.get (e).physics.entityFrame ();

                    local entity = UI.Sprite (height + "|" + (index-1));
                    local prev =  entity ? entity : UI.Canvas (height + "|" + (index-1));
                    if (prev) e.Pos.X += prev.Size.X + prev.Pos.X;
                    else e.Pos.X = empty;

                    // positioning sprites vertically
                    e.Pos.Y = (parent.Size.Y / map.len()) * (height-1);
 
                    // addchilds
                    this.attachToParent (e);

                    e.Size = proportions;
                    if (obj [getId].rawin ("Size")) { 
                        local s = obj [getId].Size;
                        e.Size = s;
                        if (s.Y == 0) e.Size.Y = proportions.Y;
                        if (s.X == 0) e.Size.X = proportions.X;
                    }
                } 

                // horizontal frames.
                index++;
            }
        }
    }

    // entity
    addEntity = function (obj) {
        if (!this.getParent ()) {
            if (this.debug) throw "components outside of scene. all components must be inside a scene.";
            else return 1;
        }

        local compatibily = "normal", parent = this.getParent (), e;
        local alias = false, origin = null, solid = false, gravity = false, player = false, sheet = null, Ignore = null;
 
        if (obj.rawin ("origin")) origin = obj.origin;
        if (obj.rawin ("draw")) {
            local bg = Colour (255,255,255), data = obj.draw, algorimths = "square";
            if (data.rawin ("bg")) bg = data.bg;
            if (data.rawin ("algorimths")) algorimths = data.algorimths;

            if (algorimths == "square") {
                e = UI.Canvas ({
                    id = data.Id
                    Colour = bg
                    align = origin
                });
            }
            else {
                local radius = 20, pos = VectorScreen (0,0);
                if (data.rawin ("radius")) radius = data.radius;
                if (obj.rawin ("Pos")) pos = obj.Pos;
 
                e = UI.Circle ({
                    id = data.Id
                    color = bg
                    align = origin
                    radius = radius
                    Position = pos
                })
                if (data.rawin ("fill") && data.fill) e.fill (bg);

                // removing some compatibilities to circle.
                compatibily = "circle";
            }
        }
        else {
            local getId = function () {
                if (obj.rawin ("uniqueId")) return obj.uniqueId;
                else return obj.spriteId;
            }

            e = ::UI.Sprite ({
                id =  getId ()
                file = this.loadRoot + obj.spriteId + ".png"     
                align = origin
            }); 
        }

        // sprite sheet for anims.
        if (obj.rawin ("spritesheet")) {
            sheet = SpriteSheet (e, obj.spritesheet.UV.X, obj.spritesheet.UV.Y, obj.spritesheet.Id).define ( "block", obj.spritesheet.X, obj.spritesheet.Y);
        }

        // elements for table.
        if (obj.rawin ("player")) player = obj.player;
        if (obj.rawin ("solid")) solid = obj.solid;
        if (obj.rawin ("gravity")) gravity = obj.gravity;
        if (obj.rawin ("alias")) alias = obj.alias;
        if (obj.rawin ("Ignore")) Ignore = obj.Ignore;
  
        // elements for sprite
        if (obj.rawin ("Pos") && compatibily == "normal") e.Pos = obj.Pos;
        if (obj.rawin ("Size") && compatibily == "normal") e.Size = obj.Size;
        if (obj.rawin ("rotate") && compatibily == "normal") {
            e.RotationCentre = obj.centre;
            e.Rotation = obj.rotation;
        }
        if (obj.rawin ("Colour")) e.Colour = obj.Colour;

        this.store.entities.set (e, {
                // animations
            anims           = sheet
            animFrames      = 0
            stopAnim        = false
            prevAnim        = null
            collection      = map ()
            
                // Nulls
            actionTimer = null
            Scale       = null

                // physics
            physics = Physics (this, {
                Alias   = alias
                Player  = player
                Solid   = solid
                Gravity = gravity
                Ignore  = Ignore
                store   = this.store.entities
            })
        });
 
            // collision, solid, gravity etc.
        this.store.entities.get (e).physics.entityFrame ();

            // adding new child to parent
        this.attachToParent (e);
        
            // return entity
        return e;
    }   

    // distance
    getDistance = function (x1, y1, x2, y2) {
            local dist = sqrt(((x2 - x1)*(x2 - x1)) + ((y2 - y1)*(y2 - y1)));
            return {
                radius = function (rad) {
                    return dist < rad;
                }

                dist = dist
            };
    }     

    // cam shake
    camShake = function (secs, Intensity = 5) { 
        if (!this.getParent ()) {
            if (this.debug) throw "components outside of scene. all components must be inside a scene.";
            else return 1;
        }

        local parent = this.getParent ();
        // only will work when canvas is smaller than ScreenSize.
        
        if (parent && parent.Size.X <= GUI.GetScreenSize().X && parent.Size.Y <= GUI.GetScreenSize().Y) {
            // assigning the camera where It was before.
            if (this.stopIndex == secs) parent.realign ();  
            if (this.stopIndex < secs) {
                // delta time
                local dt    = ::Script.GetTicks ();
                local dx    = (cos (dt * 0.05) + sin ( dt * 0.05)) * Intensity, dy =   (cos (dt * 0.05) + sin (dt * 0.05) ) * Intensity;

                parent.Pos = VectorScreen (parent.Pos.X + dx + 0.5, parent.Pos.Y + dy + 0.5);
                this.stopIndex ++; 
            }
        }
    }  

    // every
    every = function (...) {
        if (!this.getParent ()) {
            if (this.debug) throw "components outside of scene. all components must be inside a scene.";
            else return 1;
        }
        
        local callback = null, alias = null; 
        if (vargv.len () == 2) {
            callback    = vargv [1];
            alias       = vargv [0];
        }
        else callback = vargv [0];

        this.store.entities.forEach (function (e, obj) {
            // if string.
            if (alias == obj.physics.Alias) callback (e);

            // looping table results
            if (typeof alias == "array" && alias.find (obj.physics.Alias) != null) callback (e);
            
            // looping all alias.
            if (alias == null) callback (e); 
        })
    }

    // get canvas
    getParent = function () {
        return UI.Canvas (this.Id) ? UI.Canvas (this.Id) : UI.Sprite (this.Id);
    }
     
    // getPos by frames
    getPos = function (height, width) { 
        return this.store.frames [height] [width];
    }

    // render event
    render = function (callback) {
        this.renderTimer = Timer.Create (::UI, function (context) {
            if (context.funcTimeout.callback) {
                if (context.funcTimeout.gIndex > context.funcTimeout.timeOut) {
                    context.funcTimeout.callback ();

                    context.funcTimeout.callback    = null;
                    context.funcTimeout.gIndex      = 0;
                    context.funcTimeout.timeOut     = 0;
                }
                context.funcTimeout.gIndex ++;
            }
            callback.acall ([context]); 
        }, 1, 0, this); 
    }   

    // timeout event
    Timeout = function (callback, number) {
        if (!this.funcTimeout.callback) {
            this.funcTimeout.callback   = callback;
            this.funcTimeout.timeOut    = number;
        }
    }

    // draw
    drawLabel = function (obj) {
        if (!this.getParent ()) {
            if (this.debug) throw "components outside of scene. all components must be inside a scene.";
            else return 1;
        }

        local Pos = VectorScreen (0,0), proportions = null, rgb = Colour (0,0,0), align = "top-lef";
        if (obj.rawin ("Pos")) Pos = obj.Pos;
        if (obj.rawin ("FontSize")) proportions = obj.FontSize;
        if (obj.rawin ("TextColour")) rgb = obj.TextColour;
        if (obj.rawin ("origin")) align = obj.origin;

        local arg = UI.Label({
            id = obj.id  
            Text = obj.Text 
            Pos = Pos
            TextColor = rgb
            align = align

            onClick = function () {
                if (obj.rawin ("onClick")) obj.onClick ();
            }
        });
        if (proportions) arg.FontSize = proportions;

        this.attachToParent (arg);
    } 

    drawImage = function (obj) {
        if (!this.getParent ()) {
            if (this.debug) throw "components outside of scene. all components must be inside a scene.";
            else return 1;
        }
 
        local Pos = VectorScreen (0,0), proportions = null, rgb = null, align = "top-lef";
        if (obj.rawin ("Pos")) Pos = obj.Pos;
        if (obj.rawin ("Size")) proportions = obj.Size;
        if (obj.rawin ("Colour")) rgb = obj.Colour;
        if (obj.rawin ("origin")) align = obj.origin;

        local arg = UI.Sprite({
            id      = obj.spriteId
            file    = this.loadRoot + obj.spriteId + ".png"
            Pos     = Pos
            align   = align

            onClick = function () {
                if (obj.rawin ("onClick")) obj.onClick ();
            }
        });

        if (proportions) arg.Size = proportions;
        if (rgb) arg.Colour = rgb;

        this.attachToParent (arg);
    } 

    attachToParent = function (child) {
        if (typeof this.getParent () == "GUICanvas") this.getParent ().add (child, false);
        else this.getParent ().AddChild (child);
    }

    attachKey = function (list) {
        foreach (Key in list) {
            ::UI.registerKeyBind({
                name = Key + "2dgames" + this
                kp= KeyBind(Key)
                context = this
                onKeyUp = function() { 
                    local b = context.myKey [this.name.slice (0,2)], context = context;
                    context.store.entities.forEach (function (e, obj) {
                        if (context.store.entities.has (e) && context.store.entities.get (e).physics.Player) {
                            local player = context.store.entities.get (e).physics;

                                // keys
                            player.onKey.Heading    = b; 
                            player.onKey.Event      = "up";

                                // stop animation.
                            if (context.store.entities.get (e).prevAnim != null) context.store.entities.get (e).prevAnim (e);

                                // movements
                            if (player.Heading != null) player.Moving = false;
                        }
                    });
                } 
  
                onKeyDown = function() {
                    local b = context.myKey [this.name.slice (0,2)], context = context;
                    context.store.entities.forEach (function (e, obj) {
                        if (context.store.entities.has (e) && context.store.entities.get (e).physics.Player) {
                            local player = context.store.entities.get (e).physics;

                                // keys
                            player.onKey.Heading    = b; 
                            player.onKey.Event      = "down";
                                
                                // movements
                            if (player.Heading != null) player.Moving = true;
                        }
                    });
                } 
            });
        }
    }  

    attachProps = function () {
        foreach (e in [GUISprite, GUICanvas]) {
            local context = this; 

                // attach data
            e.rawnewmember ("collect", function () { if (context.store.entities.has (this)) return context.store.entities.get (this).collection }, null, false);

                // render
            e.rawnewmember ("render", function () {
                if (context.store.entities.has (this)) {
                    local player = context.store.entities.get (this);

                    if (player.actionTimer) player.actionTimer (this);
                    if (player.physics.preTimer) player.physics.preTimer (this, context, player.physics);
                }
            }, null, false);

                // anim
            e.rawnewmember("playAnim", function(anim, data = null) { 
                local parent = context.getParent (), entity = this;
                if (context.store.entities.has (this)) {
                    local obj = context.store.entities.get (this), rate = 1;
                    if (obj && !obj.stopAnim && obj.anims) {
                        // mirror mode.
                        if (data && data.rawin ( "mirror" ) && data.mirror) obj.anims.mirror = -1;
                        else  obj.anims.mirror = 1;
                        
                        // flip mode.
                        if (data && data.rawin ( "flip" ) && data.flip) obj.anims.flip = -1;
                        else obj.anims.flip = 1;

                        if (data && data.rawin ( "rotate" ) && data.rotate == "up") obj.anims.rotateAround = 1;
                        else if (data && data.rawin ( "rotate" ) && data.rotate == "down") obj.anims.rotateAround = -1;
                        else obj.anims.rotateAround = null;
                        
                        // updating anim
                        if (obj.animFrames >= anim.len ()) obj.animFrames = 0;
                        obj.anims.playFrames (this, anim [obj.animFrames]);

                        // anim speed
                        if (data && data.rawin ("animSpeed")) rate = data.animSpeed;
                        
                        // when anim is immobilized.
                        if (data && data.rawin ("Immobilized")) {
                            context.store.entities.get (this).prevAnim = function (e) {
                              obj.anims.playFrames (e, data.Immobilized);
                            };
                        } 
                        obj.animFrames += rate;
                    }
                } 

                // pausing  anim.
                return {
                    pause = function () {
                        if (context.store.entities.has (entity))  context.store.entities.get (entity).stopAnim = true;
                    }
                };
            }, null, false);

                // collision 
            e.rawnewmember("collides", function(collisionType, callback = null) {
                if (context.store.entities.has (this) && !context.store.entities.get (this).physics.collisionEvent.rawin (collisionType)) context.store.entities.get (this).physics.collisionEvent.rawset (collisionType, callback);
            }, null, false);  

                // Jump
            e.rawnewmember("Jump", function(rate = 20) {
                if (context.store.entities.has (this)) {
                    local player = context.store.entities.get (this).physics;
                    if (player.Grounding) {    
                            // toggles 
                        player.Jumping      = true;  
                        player.Grounding    = false;

                            // Jump Rate
                        player.JumpRate     = rate;
                    }           
                }
            }, null, false); 
            
                // move2d
            e.rawnewmember("move2d", function(x, y) {
                local parent = context.getParent ();
                if (context.store.entities.has (this)) {
                    local player = context.store.entities.get (this).physics;
                    if (x != 0) {
                        local direction = (x.tostring ().slice (0,1) == "-" ? "left" : "right");

                            // this is needed for collisions horizontally 'no-gravity'.
                        player.onKey.Heading = direction;

                            // heading 
                        player.Heading = direction;               

                            // moving the object 
                        this.Pos.X += x;
                    } 
                    
                    // vertical
                    if (y != 0) {
                        local direction = (y.tostring ().slice (0,1) == "-" ? "up" : "down");

                            // this is needed for collisions vertically 'no-gravity'.
                        player.onKey.Heading = direction;

                            // heading 
                        player.Heading = direction;               

                            // moving the object 
                        this.Pos.Y += y;
                    }

                        // left end of canvas and world border
                    if (this.Pos.X <= 0) {
                        player.bumpHeading = "hitLeftEnd"; 
                        if (context.sceneBorder) this.Pos.X = 0;
                    }

                        // right end of canvas and world border
                    if (this.Pos.X >= parent.Size.X - this.Size.X) {
                        player.bumpHeading = "hitRightEnd";
                        if (context.sceneBorder) this.Pos.X = parent.Size.X - this.Size.X;
                    }

                        // top end of canvas and world border
                    if (this.Pos.Y <= 0) {
                        player.bumpHeading = "hitTopEnd";
                        if (context.sceneBorder) this.Pos.Y = 0;
                    }

                        // bottom end of canvas and world border
                    if (this.Pos.Y >= parent.Size.Y - this.Size.Y) {
                        player.bumpHeading = "hitBottomEnd";
                        if (context.sceneBorder) this.Pos.Y = parent.Size.Y - this.Size.Y;
                    }    
                }
            }, null, false);  

                // props
            e.rawnewmember ("props", function() {
                local parent = context.getParent (), p = this;
                return {
                    getIsOutOfWorld = function () {
                        if (context.store.entities.has (p)) {
                                // horizontally 
                            local boundaries = false;
                            if (p.Pos.X < (-p.Size.X)) boundaries = true;
                            if ((p.Pos.X-p.Size.X) > parent.Size.X - p.Size.X) boundaries = true;

                                // vertically
                            if (p.Pos.Y < 0) boundaries = true;
                            if (p.Pos.Y > parent.Size.Y - p.Size.Y) boundaries = true;
                            
                            return boundaries;
                        }
                    }          
                        // receiving  data
                    getBumpHeading  = function () {if (context.store.entities.has (p)) return context.store.entities.get (p).physics.bumpHeading;}
                    getHeading      = function () {if (context.store.entities.has (p)) return context.store.entities.get (p).physics.Heading;}
                    getDistance     = function (entity = null) {if (entity) return getDistance (this.Pos.X, this.Pos.Y, entity.Pos.X, entity.Pos.Y);}

                        // Booleans
                    getIsScaledStatus   = function () {if (context.store.entities.has (p)) return context.store.entities.get (p).Scale;}
                    getIsJumpingStatus  = function () {if (context.store.entities.has (p)) return context.store.entities.get (p).physics.Jumping;}
                    getIsMovingStatus   = function () {if (context.store.entities.has (p)) return context.store.entities.get (p).physics.Moving;}
                    getIsFallingStatus  = function () {if (context.store.entities.has (p)) return context.store.entities.get (p).physics.Falling;}
                    getIsGroundedStatus = function () {if (context.store.entities.has (p)) return context.store.entities.get (p).physics.Grounding;}
                    getIsExists         = function () {return context.store.entities.has (p);}
                    
                        // editing data
                    spin    = function (spin = 0) { return p.Rotation = spin}
                    Scale   = function (x, y = null) {
                        if (context.store.entities.has (p)) {
                            p.Size.X *= x;
                            p.Size.Y *= (y == null ? x : y);   

                            context.store.entities.get (p).Scale = true;                         
                        }
                    }
                } 
            }, null, false);       

                // action render
            e.rawnewmember("action", function(callback) {
                if (context.store.entities.has (this)) { 
                    if (context.store.entities.get (this).actionTimer==null){
                        context.store.entities.get (this).actionTimer = function  (p) {  
                            if (context.store.entities.has (p)) { 
                                callback.acall ([{
                                    entity      = p
                                    game        = context
                                    Key         = function (key, callback) {
                                        if (context.store.entities.has (p)) { 
                                            local keys = context.store.entities.get (p).physics.onKey;
                                            if (key == keys.Heading) callback.acall ([{ entity = p, event = keys.Event }]); 
                                        }
                                    } 

                                    mousePos        = GUI.GetMousePos ()
                                    mouseIsEnabled  = GUI.GetMouseEnabled ()
                                    screenSize      = GUI.GetScreenSize ()
                                }]); 

                                    // when Event is 'up', will be set to null.
                                if (context.store.entities.has (p) && context.store.entities.get (p).physics.onKey.Event == "up") context.store.entities.get (p).physics.onKey.Event = null;
                            }
                        }
                    }
                }  
            }, null, false);  

                // destroy entity
            e.rawnewmember("destroy2d", function() {
                if (context.store.entities.has (this)) {
                        // destroy timer
                    if (context.store.entities.get (this).rawin ("actionTimer")) Timer.Destroy (context.store.entities.get (this).actionTimer);
                    
                        // destroying the entity
                    context.store.entities.remove (this);
 
                    this.destroy ();
                    this.hide ();
                }
            }, null, false);  
        }
    }

}

foreach (dir in [ "spritesheets", "physics" ,"map" ]) dofile ( "kaboom/components/" +dir+ ".nut" );