//Script.Load
class Kaboom {
    Id          = null;
    loadRoot    = null;
    gravityGame = null;
    gravity     = null;
   
    store       = null;
    camPos      = null;
    rate=0;
    anim =null
    
    myKey = {
        "38": "up"
        "40": "down"
        "39": "right"
        "37": "left"
        "32": "space"
    }

    constructor (obj) {
        this.Id = obj.id;
        this.camPos = {
            Y   = null,
            X   = null
        };
        this.store = {
            entities    = {}, 
            scenes      = {}, 
            frames      = [],
            proportions = null
            obj         = obj
        };

        if (obj.rawin ( "plugins" )) {
            this.store.props <- obj.plugins;
        }

        if (obj.rawin ( "gravityGame" )) {
            this.gravityGame = obj.gravityGame;
        }
        
        if (obj.rawin ( "gravity" )) {
            this.gravity = obj.gravity;
        }        
        
        if (obj.rawin ( "loadRoot" )) {
            this.loadRoot = obj.loadRoot;
        }

        if (obj.rawin ("Key")) this.myKey [obj.Key.Id] <- obj.Key.name;

        this.createTemplate (obj);
        this.createKey ([0x28, 0x27, 0x26, 0x25, 0x20]);
 
        this.attachPropToEntity ();
    }

    createTemplate = function (obj) {  
        if (::UI.Canvas (this.Id)) UI.Canvas (this.Id).destroy ();

        local width = GUI.GetScreenSize().X / 2, height = GUI.GetScreenSize().Y / 2;      
        local origin = "center", color = Colour (255,255,255,20);

        if (obj.rawin ( "Size" )) {
            width = obj.Size.X;
            height = obj.Size.Y;
        }

        if (obj.rawin ( "fullscreen" )) {
            if (obj.fullscreen) {
                width = GUI.GetScreenSize().X;
                height = GUI.GetScreenSize().Y;  
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
 
        local c = UI.Canvas({
            id = this.Id      
            Size = VectorScreen (width, height)
            Colour = color 
            align = origin   
        })

        this.store.pos <- c.Pos;
 
        return c;
    }

    scene = function (segment, callback) {
        local parent = ::UI.Canvas (this.Id), context = this;
        this.store.scenes.rawset (segment, { open = callback, shakeTimer = null, prev = parent.Pos }); 

        parent.hide ();
        return {
            setCamShake = function (secs) {
                local stopIndex = 0;
                if (parent) {
                    context.store.scenes.rawget (segment).shakeTimer = Timer.Create (::UI, function (context) {
                        local dt =   ::Script.GetTicks ();
                        local dx =   (cos(dt * 0.05) + cos( dt * 0.05) ) * 15;
                        local dy =   (sin(dt * 0.05) + sin (dt * 0.05) ) * 15;
                
                        parent.Pos.X += dx;
                        parent.Pos.Y += dy;
 
                        if (stopIndex >= secs) {
                            // destroy timer for the specified segment.
                            local obj = context.store.scenes.rawget (segment); 
                            Timer.Destroy (obj.shakeTimer);

                            // locating scene where, It was before dramatic shaking.
                            parent.realign (); 
                            parent.resetMoves ()
                        }
                        stopIndex += 0.5; 
                    }, 1, 0, context);  
                }
            }  
        }
    }
    
    start = function (segment) {
        local parent = ::UI.Canvas (this.Id); 
        
        local context = this;
        if (this.store.scenes.rawin (segment)) {
            this.store.scenes.rawget (segment).open.acall ([this]);

            if (parent.hidden) parent.show ();
        }
    }
 
    go = function (segment) {
        this.every (function (e) { e.remove (); });

        this.store.frames       = null;
        this.store.entities     = null;

        local parent = this.createTemplate (this.store.obj);
 
        if (this.store.scenes.rawin (segment)) {
            this.store.scenes.rawget (segment).open.acall ([this]);

            if (parent.hidden) parent.show ();
        }
    }
 
    addLevel = function  (map, obj) {
        local parent = ::UI.Canvas (this.Id);
        local height = 0, index = 0, empty = 0;

        foreach (horizontal in map) {
            this.store.frames.push ([]);

            // vertical frames.
            height ++;
            
            local proportions = VectorScreen (parent.Size.X / horizontal.len (), parent.Size.Y / map.len ());
            this.store.proportions = proportions;
            foreach (getId in horizontal) {
                getId = getId.tochar ();
                if (index != 0) empty += proportions.X;
                if (horizontal.len () == index) {
                    index = 0;
                    empty = 0;
                }

                // storing frames
                this.store.frames [height-1].push (VectorScreen (proportions.X * index, ([height-1] == 0 ? 0 : proportions.Y) * (height-1)));
                
                if (obj.rawin (getId)) {  
                    local e = ::UI.Sprite({ 
                        id =  height + "|" + index
                        file = this.loadRoot + obj [getId].spriteId + ".png"     
                        Size = proportions
                    })
                    
                    local alias = null, solid = false;
                    if (obj [getId].rawin ("alias")) alias = obj [getId].alias;
                    if (obj [getId].rawin ("solid")) solid = obj [getId].solid;
                    if (obj [getId].rawin ("hide")) e.hide ();

                    this.store.entities.rawset (e, {
                        body = solid
                        alias = alias
                        index = index
                        height = height
                        repeats = 0 
                    });

                    local prev = UI.Sprite (height + "|" + (index-1)); 
                    if (prev) e.Pos.X += prev.Size.X + prev.Pos.X;
                    else  e.Pos.X = empty;

                    // positioning sprites vertically
                    e.Pos.Y = (parent.Size.Y / map.len()) * (height-1);
                    parent.add (e, false);
                } 

                // horizontal frames.
                index++;
            }
        }
    }

    addEntity = function (obj) {
        local compatibily = "normal";
        local parent = ::UI.Canvas (this.Id), e;
        local alias = false, origin = null, body = false, gravity = false, player = false;
 
        if (obj.rawin ("origin")) origin = obj.origin;
        if (obj.rawin ("draw")) {
            local bg = Colour (255,255,255), data = obj.draw, algorimths = "square";
            if (data.rawin ("bg")) bg = data.bg;
            if (data.rawin ("algorimths")) algorimths = data.algorimths;

            if (algorimths == "square") {
                e = UI.Canvas ({
                    id = data.Id
                    Colour = bg
                    Size = this.store.proportions  
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
            e = ::UI.Sprite ({
                id =  obj.spriteId
                file = this.loadRoot + obj.spriteId + ".png"     
                Size = this.store.proportions  
                align = origin
            }); 
        }

        // elements for table.
        if (obj.rawin ("player")) player = obj.player;
        if (obj.rawin ("body")) body = obj.body;
        if (obj.rawin ("gravity")) gravity = obj.gravity;
        if (obj.rawin ("alias")) alias = obj.alias

        // elements for sprite
        if (obj.rawin ("Pos") && compatibily == "normal") e.Pos = obj.Pos;
        if (obj.rawin ("Size") && compatibily == "normal") e.Size = obj.Size;
        if (obj.rawin ("rotate") && compatibily == "normal") {
            e.RotationCentre = obj.centre;
            e.Rotation = obj.rotation;
        }
        
        
        if (obj.rawin ("ScaleTo") && compatibily == "normal") {
            if (typeof obj.ScaleTo == "VectorScreen" ) e.Size = obj.ScaleTo;
            else  {
                e.Size.Y = obj.ScaleTo;
                e.Size.X = obj.ScaleTo;
            }
        };

        if (obj.rawin ("Scale") && compatibily == "normal") {
            if (typeof obj.Scale == "VectorScreen" ) {
                e.Size.Y += obj.Scale.Y;
                e.Size.X += obj.Scale.X;
            }
            else {
                e.Size.Y += obj.Scale;
                e.Size.X += obj.Scale;
            }
        }; 

        this.store.entities.rawset (e, {
            alias = alias
            body = body
            player = player
            gravity = gravity

            // Nulls
            move2d = null
            actionTimer = null
            EnhanTimer = null
            Scale = null
            bumpHeading = null
            
            // Array
            onKey = {
                Heading = null, 
                Event = null
            }
            collisionEvent = {}
            
            // booleans
            IsMoving    = true
            IsFalling   = true

            IsJumping   = false
            IsDetroyed  = false
            IsGrounded  = false

            // Integer
            JumpRate    = 0
        });

        this.body (e);
        parent.add (e, false);
        return e;
    }    
    
    body = function (p) {
        local parent = ::UI.Canvas (this.Id)
        local JumpRate = 0, gravityIsEnabled = false, gravity = 10, stopPlease = false, IsFalling = 0;

        if (this.gravityGame) gravityIsEnabled = this.gravityGame;
        if (this.gravity) gravity = this.gravity;

        if (this.store.entities.rawin (p)) {
            if (this.store.entities && this.store.entities.rawget (p).EnhanTimer ==null){
                this.store.entities.rawget (p).EnhanTimer = Timer.Create (::UI, function  (p, context) {
                    if (context.store.entities && gravityIsEnabled && context.store.entities.rawget (p).IsJumping && context.store.entities.rawget (p).gravity) {
                        // jump functionabily.
 
                        if (JumpRate < context.store.entities.rawget (p).JumpRate && !stopPlease) p.Pos.Y -= gravity;
                        else {
                            context.store.entities.rawget (p).IsJumping = false;
                            context.store.entities.rawget (p).IsFalling = true;
                        }
                        JumpRate++;
                    }
                    else {
                        if (context.store.entities && gravityIsEnabled && context.store.entities.rawget (p).gravity) {
                            if (p.Pos.Y != IsFalling) {
                                context.store.entities.rawget (p).IsFalling = true;
                                context.store.entities.rawget (p).IsGrounded = false;
                            }
 
                            IsFalling = p.Pos.Y
                            p.Pos.Y += gravity;
                        }
                    }
                    
                    foreach (e, Items in context.store.entities) {
                        if (context.store.entities && context.store.entities.rawget (p).alias != Items.alias) {
                        local group = {
                                context = context
                                changeImageTo = function (fileName) {
                                    e.SetTexture(context.loadRoot + fileName + ".png");
                                }  
                                 
                                spawn = function (data = null) {
                                    local wrapper = ::UI.Sprite ((Items.height-1) +"|"+ (Items.index));  
                                    if (wrapper) {
                                        local spriteObj = context.store.entities.rawget (wrapper), repeat = 0;
                                        if (data) repeat = data.rawget ("repeat");
                                       
                                        if (spriteObj.repeats == repeat) { 
                                            context.store.entities.rawdelete (wrapper);
                                            wrapper.destroy ();
                                        }
                                        else spriteObj.repeats ++;
                                    }

                                    return {
                                        fadeIn = function () { if (wrapper) { 
                                            wrapper.hide ();
                                            wrapper.fadeIn ();                                         
                                        }} 
                                        fadeOut = function () { if (wrapper) {
                                            wrapper.show ();
                                            wrapper.fadeOut ();                                           
                                        }} 
                                    }
                                }

                                Is = function (arg) { if (arg == Items.alias) return true;  } 

                                exists = function (Is = null) {
                                    if (Is == "hidden") {
                                        local wrapper = ::UI.Sprite ((Items.height-1) +"|"+ (Items.index));  
            
                                        if (wrapper) return true;
                                        else return false;
                                    }
                                    else {
                                        if (e) return true;
                                        else return false;
                                    }   
                                }  

                                remove = function () { 
                                    if (context.store.entities && !context.store.entities.rawget (e).IsDetroyed) {
                                        e.Detach ();
                                        e.Pos = VectorScreen (0,0);
                                        e.hide ();
                                        context.store.entities.rawget (e).IsDetroyed = true;
                                      
                                        Timer.Destroy (context.store.entities.rawget (e).EnhanTimer);
                                        Timer.Destroy (context.store.entities.rawget (e).actionTimer);  
                                    } 
                                }
                            }

                            local bumpSides = function () {
                                if (context.store.entities && context.store.entities.rawget (p).collisionEvent.rawin ("bumpSides")) context.store.entities.rawget (p).collisionEvent.rawget ("bumpSides").acall ([e, group]); 
                                if (context.store.entities && context.store.entities.rawget (e).rawin ("collisionEvent") && context.store.entities.rawget (e).collisionEvent.rawin ("bumpSides")) {
                                    group.Is <- function (args) { if (args == context.store.entities.rawget (p).alias) return true; }
                                    group.exists <- function () { if (p) return true; };

                                    context.store.entities.rawget (e).collisionEvent.rawget ("bumpSides").acall ([p, group]);
                                } 
                            }

                            // collision events.
                            local r1 = { x = p.Pos.X, y = p.Pos.Y, w = p.Size.X, h = p.Size.Y }, r2 = { x = e.Pos.X, y = e.Pos.Y, w = e.Size.X, h= e.Size.Y };
                            if (context.store.entities && !(r1.x>r2.x+r2.w || r1.x+r1.w<r2.x || r1.y>r2.y+r2.h || r1.y+r1.h<r2.y) && context.store.entities.rawget (p).body) {

                                // collisions callback
                                if (context.store.entities&&context.store.entities.rawget (p).collisionEvent.rawin (Items.alias)) context.store.entities.rawget (p).collisionEvent.rawget (Items.alias).acall ([e, group]); 
                                if (context.store.entities&&context.store.entities.rawget (p).collisionEvent.rawin ("bumpBody")) context.store.entities.rawget (p).collisionEvent.rawget ("bumpBudy").acall ([e, group]); 
 
                                // right collision
                                if (r2.x >= r1.x) { 
                                    if (context.store.entities && context.store.entities.rawget (p).onKey.Heading == "right" && r1.y >= r2.y && context.store.entities.rawget (e).body) {
                                        context.store.entities.rawget (p).IsMoving = false; // disabling right movement

                                        context.store.entities.rawget (p).bumpHeading = "right"; // bump heading

                                        if (context.store.entities.rawget (p).collisionEvent.rawin ("bumpRight")) context.store.entities.rawget (p).collisionEvent.rawget ("bumpRight").acall ([e, group]); // collision callback
                                        bumpSides ();
                                    }
                               }
 
                                // left collision
                                else {                              
                                    if (context.store.entities && context.store.entities.rawget (p).onKey.Heading == "left"  && r1.y >= r2.y && context.store.entities.rawget (e).body) {
                                        context.store.entities.rawget (p).IsMoving = false;

                                        context.store.entities.rawget (p).bumpHeading = "left";
                                        if (context.store.entities.rawget (p).collisionEvent.rawin ("bumpLeft")) context.store.entities.rawget (p).collisionEvent.rawget ("bumpLeft").acall ([e, group]); 
                                        bumpSides ();
                                    }
                                }
                                
                                if (gravityIsEnabled) {
                                    // gravity function for key up and down
                                    // top collision
                                    if (context.store.entities && r2.y <= r1.y && context.store.entities.rawget (e).body) {
                                        if (p.Pos.Y <= (r2.y + r1.h)) {
                                            stopPlease = true;
                                            if (context.store.entities.rawget (p).collisionEvent.rawin ("bumpHead")) context.store.entities.rawget (p).collisionEvent.rawget ("bumpHead").acall ([e, group]); 
                                        }
                                    }
                                    
                                    // bottom collision
                                    if (context.store.entities && r2.y >= r1.y && context.store.entities.rawget (e).body) {
                                        if (p.Pos.Y >= (r2.y - r1.h)) p.Pos.Y = (r2.y - r1.h); 
                                    
                                        context.store.entities.rawget (p).IsGrounded = true;
                                        context.store.entities.rawget (p).IsJumping = false;
                                        context.store.entities.rawget (p).IsFalling = false;

                                        JumpRate = 0;
                                        stopPlease = false

                                        if (context.store.entities.rawget (p).collisionEvent.rawin ("bumpFoot")) context.store.entities.rawget (p).collisionEvent.rawget ("bumpFoot").acall ([e, group]); 
                                    }
                                }
                                else {
                                    // no gravity for keys up and down 

                                }
                            }
                        }
                    }
                }, 1, 0, p, this);   
            } 
        }  
    }    

    createKey = function (list) {
        foreach (Key in list) {
            ::UI.registerKeyBind({
                name = Key + "2dgames" + this
                kp= KeyBind(Key)
                context = this
                onKeyUp = function() { 
                    if (context.store.entities) {
                        local b = context.myKey [ this.name.slice (0,2) ];
                        foreach (e,obj in context.store.entities) {
                            if (obj && obj.rawin ("player") && obj.player) {
                                context.store.entities.rawget (e).onKey.Heading = b; 
                                context.store.entities.rawget (e).onKey.Event = "up";
                            }
                        }
                    }
                }
 
                onKeyDown = function() {
                    if (context.store.entities) {
                        local b = context.myKey [ this.name.slice (0,2) ];
                        foreach (e, obj in context.store.entities) {
                            if (obj && obj.rawin ("player") && obj.player) {
                                context.store.entities.rawget (e).onKey.Heading = b;  
                                context.store.entities.rawget (e).onKey.Event = "down";
                            }
                        }
                    }
                } 
            });
        }
    }  

    // cam pos
    setCamPos = function (entity, pos) {
        if (this.store.entities && this.store.entities.rawget (entity)) {
            local parent = this.getParent ();
            if (parent) {
                if (!camPos.X) {
                    parent.Pos.X = 0;
                    camPos.X = null;
                }

                // when canvas is almost reaching the horizontal end, make the effect to stop.
                local direction = this.store.entities.rawget (entity).onKey.Heading;
                if (direction == "left" || direction == "right" ) {
                    if ((GUI.GetScreenSize().X/2)-entity.Pos.X <= 0) parent.Pos.X = -(entity.Pos.X-(GUI.GetScreenSize().X/2));
                    // if (entity.Pos.X < (parent.Size.X - (GUI.GetScreenSize().X/2)) ) parent.Pos.X = -(entity.Pos.X-entity.Size.X);
                }
 
                // when canvas is almost reaching the verticcal end, make the effect to stop.
                if (direction == "up" || direction == "bottom") {

                }
                
                // moving Y position up.               
                if (entity.props ().getIsJumpingStatus () && !camPos.Y) { 
                    parent.Pos.Y = parent.Pos.Y - 35; 
                    camPos.Y = true;
                }

                // returning canvas back to Y position when entity is grounded. 
                if (entity.props ().getIsGroundedStatus () && camPos.Y) { 
                    parent.Pos.Y = parent.Pos.Y + 35;
                    camPos.Y = false;
                }
            }
        }  
    }     
 
    // every
    every = function (callback) {
        foreach (e, Items in this.store.entities) {  
            callback (e); 
        }  
    }

    //get canvas
    getParent = function () {
        return  ::UI.Canvas (this.Id);
    }
    // getPos by frames
    getPos = function (height, width) { 
        return this.store.frames [height] [width];
    }

    // render event
    render = function (callback) {
        Timer.Create (::UI, function (context) {
            callback.acall ([context]);
        }, 1, 0, this); 
    }    

    attachPropToEntity = function () {
        foreach (e in [GUISprite, GUICanvas]) {
            local context = this; 
            e.rawnewmember("collides", function(collisionType, callback = null) {
                if (context.store.entities && context.store.entities.rawin (this)) {
                    if (!context.store.entities.rawget (this).collisionEvent.rawin (collisionType)) context.store.entities.rawget (this).collisionEvent.rawset (collisionType, callback);
                }
                return this;
            }, null, false); 
            
            e.rawnewmember("playAnim", function(anim, data) {
                local parent = ::UI.Canvas (context.Id);
                if (context.store.entities && context.store.entities.rawin (this)) {
                }
                return this;
            }, null, false); 
 
            e.rawnewmember("move2d", function(speed) {
                local parent = ::UI.Canvas (context.Id); 
                if (context.store.entities && context.store.entities.rawin (this)) {
                    // bump head to null 
                    if (context.store.entities && context.store.entities.rawget (this).player) context.store.entities.rawget (this).bumpHeading = null;

                    // heading direction
                    context.store.entities.rawget (this).onKey.Heading = (speed.tostring ().slice (0,1) == "-" ? "left" : "right");
                   
                    // left end of canvas
                    if (this.Pos.X <= 0) context.store.entities.rawget (this).bumpHeading = "hitLeftEnd"; 

                    // right end of canvas
                    if (this.Pos.X >= parent.Size.X - this.Size.X) context.store.entities.rawget (this).bumpHeading = "hitRightEnd";
                    
                    // top end of canvas
                    if (this.Pos.Y <= 0) context.store.entities.rawget (this).bumpHeading = "hitTopEnd";

                    // bottom end of canvas
                    if (this.Pos.Y >= parent.Size.Y - this.Size.Y) context.store.entities.rawget (this).bumpHeading = "hitBottomEnd";
                    
                    if (context.store.entities.rawget (this).IsMoving) this.Pos.X += speed;
                    context.store.entities.rawget (this).IsMoving = true;
                }
                return this;
            }, null, false); 

            e.rawnewmember("action", function(callback) {
                if (context.store.entities && context.store.entities.rawin (this)) { 
                    if (context.store.entities.rawget (this).actionTimer==null){
                        context.store.entities.rawget (this).actionTimer = Timer.Create (::UI, function  (p) {  
                            callback.acall ([{
                                entity = p
                                context = context
                                Key = function (key, callback) {
                                    if (context.store.entities && key == context.store.entities.rawget (p).onKey.Heading) callback.acall ([{
                                        entity = p 
                                        event = context.store.entities.rawget (p).onKey.Event
                                    }]); 
                                } 
                            }]); 

                            if (context.store.entities && context.store.entities.rawget (p).onKey.Event == "up") {
                                context.store.entities.rawget (p).onKey.Event = null;
                            }
                        }, 1, 0, this);  
                    }
                } 
                return this;
            }, null, false);  
            
            e.rawnewmember("Jump", function(rate) {
                if (context.store.entities && context.store.entities.rawin (this)) {
                    if (context.store.entities.rawget (this).IsGrounded) {    
                        context.store.entities.rawget (this).IsJumping = true;  
                        context.store.entities.rawget (this).IsGrounded = false;
                        context.store.entities.rawget (this).JumpRate = rate;
                    }           
                }
                return this;
            }, null, false); 
            
            e.rawnewmember ("props", function() {
                 local parent = ::UI.Canvas (context.Id);
                if (context.store.entities && context.store.entities.rawin (this)) {
                    local p = this;
                    return {
                        IsOutWorld = function () {
                            // horizontally 
                            local boundaries = false;
                            if (p.Pos.X < (-p.Size.X)) boundaries = true;
                            if ((p.Pos.X-p.Size.X) > parent.Size.X - p.Size.X) boundaries = true;

                            // vertically
                            if (p.Pos.Y < 0) boundaries = true;
                            if (p.Pos.Y > parent.Size.Y - p.Size.Y) boundaries = true;
                            
                            return boundaries;
                        }         

                        getBumpHeading = function () { return context.store.entities.rawget (p).bumpHeading;}
                        getHeading = function () { return context.store.entities.rawget (p).onKey.Heading;}
                        getScale = function ()  {return context.store.entities.rawget (p).Scale;}
                        getDistance = function (entity = null) { if (entity) return getDistance (p.Pos.X, p.Pos.Y, entity.Pos.X, entity.Pos.Y);}

                        getIsJumpingStatus = function () { return context.store.entities.rawget (p).IsJumping;}
                        getIsMovingStatus = function () { return context.store.entities.rawget (p).IsMoving;}
                        getIsDestroyedStatus = function () { return context.store.entities.rawget (p).IsDetroyed;}
                        getIsFallingStatus = function () { return context.store.entities.rawget (p).IsFalling;}
                        getIsGroundedStatus = function () { return context.store.entities.rawget (p).IsGrounded;}
                        
                        // rotation
                        rotate = function (e = 0) { return p.Rotation = e }
                    } 
                }
            }, null, false);          

            e.rawnewmember("Scale", function(scaleTo) {
                if (context.store.entities && context.store.entities.rawin (this)) {
                    this.Size.X += 0.8 * scaleTo; 
                    this.Size.Y += 0.8 * scaleTo;

                    context.store.entities.rawget (this).Scale = 0.8 * scaleTo;
                }
                return this;
            }, null, false); 

            e.rawnewmember("remove", function() {
                if (context.store.entities && context.store.entities.rawin (this)) {
                    this.Detach (); 
                    this.hide (); 

                    if (context.store.entities.rawget (this).rawin ("EnhanTimer")) {
                        Timer.Destroy (context.store.entities.rawget (this).EnhanTimer); 
                        Timer.Destroy (context.store.entities.rawget (this).actionTimer);
                        context.store.entities.rawget (this).IsDetroyed = true;
                    }
                }
            }, null, false);  
        }
    } 
}    