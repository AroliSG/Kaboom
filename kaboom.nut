class kaboom extends Component  {
    className = null;
    id = null;
    Size = null;
    loadRoot = null;
    canvas = null;
    entities = null;
    prop = null;
    frames = null;

    SpriteSize = null;
    scenebox = null;
    
    constructor (obj) {
        this.id = obj.id;
        this.className = "Kaboom"; 
        this.entities  = {};
        this.Size = obj.Size;
        this.scenebox = {}

        this.prop = {};
        if (obj.rawin ( "plugins" )) {
            this.prop = obj.plugins;
        }

        base.constructor(this.id,obj);
        this.metadata.list ="kabooms";

        this.canvas = UI.Canvas({
            id = this.id         
            Size = this.Size
            Colour = Colour (0,0,0)    
            align = "center"   
        })
        this.canvas.hide ();

        this.loadRoot = obj.loadRoot;
        this.attachPropToEntity ();

        this.addKey ();
    }

    start = function (segment) {
        if (this.scenebox.rawin (segment)) {
            this.scenebox.rawget (segment).open.acall ([{context = this, parent = this.canvas }]);
            this.canvas.show ();
        }
    }

    scene = function (segment, callback) {
        this.scenebox.rawset (segment, { open = callback })
    }

    go = function (segment) {
        Console.Print (this.scenebox.rawin (segment))
        if (this.scenebox.rawin (segment)) {
            this.scenebox.rawget (segment).acall ([{context = this}]);
        }
    }

    addLevel = function  (map, obj) {
        local height = 0, index = 0, empty = 0, IsMoved = false;
        this.frames = [];
        foreach (map_design in map) {
            this.frames.push ([]);
            height++;
            

            this.SpriteSize = VectorScreen (this.Size.X/map_design.len()+1, this.Size.Y/map.len ());
            foreach (map_constr in map_design) {
                empty += this.SpriteSize.X;
                if (map_design.len () == index) {
                    index = 0;
                    empty = 0;
                }
                local tempy = [height-1] == 0 ? 0 : this.SpriteSize.Y;
                this.frames [height-1].push (VectorScreen (this.SpriteSize.X * index, tempy * (height-1)));


                if (obj.rawin (map_constr.tochar ())) {  
                    local hidden = false;
                    if (obj [map_constr.tochar ()].len () == 4) hidden = obj [map_constr.tochar ()]; 
    
                    local wrapper = ::UI.Sprite({
                                id =  height +"|"+ index
                                file = this.loadRoot + obj [map_constr.tochar ()] [0] + ".png"     
                                Size = this.SpriteSize   
                            })

 
                    this.entities.rawset (wrapper, {
                        solid = obj [map_constr.tochar ()] [1], 
                        alias = obj [map_constr.tochar ()] [2]
                        index = index
                        height = height
                        body = false
                        repeats = 0
                    });

                    if (obj [map_constr.tochar ()].len () == 4) wrapper.hide ();

                    if (IsMoved) {
                        wrapper.Pos.X = empty;
                        IsMoved = false;
                    }

                    if (index > 0) { 
                        local prev = UI.Sprite (height +"|"+ (index-1))
                        if (prev) wrapper.Pos.X += prev.Size.X + prev.Pos.X+1;
                    }
                    wrapper.Pos.Y = (this.Size.Y/map.len()) * (height-1);
                    this.canvas.add (wrapper, false);
                } 
                else {
                    IsMoved = true;
                }
                index++;
            }
        }

    }

    //new entities    
    addEntity = function (obj) {
        local solidity = false, callback = null, alias = null, player = false;
        local entity = ::UI.Sprite({
            id =  obj [0]
            file = this.loadRoot + obj [0] + ".png"     
            Size = this.SpriteSize  
        }); 

        foreach (data in obj) {
            if (typeof data == "table") {
                if (data.rawin ("height")) entity.Size.Y += data.height;
                if (data.rawin ("width")) entity.Size.X += data.width;
                if (data.rawin ("Solid")) solidity = data.Solid;
                if (data.rawin ("collision")) callback = data.collision;
                if (data.rawin ("alias")) alias = data.alias
                if (data.rawin ("Pos")) entity.Position = data.Pos;
                if (data.rawin ("player")) player = data.player;
                break;
            }
        }
        this.entities.rawset (entity, {
            IsGrounded = false
            Solid = solidity
            Callback = callback
            alias = alias
            move2d = null
            body = true
            actionTimer = null
            EnhanTimer = null
            onKey = {Heading = null, Event = null}
            player = player
            bumpHeading = null
            IsMoving = false
            IsJumping = false
            IsFalling = true
            collisionEvent = {}
            IsDetroyed = false
            Scale = null
        });

        this.objBody (entity);
        this.canvas.add (entity, false);

        return entity;
    }

    // register keys
    addKey = function () {
        foreach (Key in [0x27, 0x25, 0x20]) {
            ::UI.registerKeyBind({
                name = Key + "2dgames" + this
                kp= KeyBind(Key)
                context = this
                onKeyUp = function() { 
                    local b = "space"
                    if (this.name.slice (0,3) == "392") b = "right";
                    if (this.name.slice (0,3) == "372") b = "left";

                    foreach (e,obj in context.entities) {
                        if (obj && obj.rawin ("onKey")) {
                            context.entities.rawget (e).onKey.Heading = b;
                            context.entities.rawget (e).onKey.Event = "up";
                        }
                    }
                }

                onKeyDown = function() {
                    local b = "space"
                    if (this.name.slice (0,3) == "392") b = "right";
                    if (this.name.slice (0,3) == "372") b = "left";

                    foreach (e,obj in context.entities) {
                        if (obj && obj.rawin ("onKey")) {
                            context.entities.rawget (e).onKey.Heading = b;
                            context.entities.rawget (e).onKey.Event = "down";
                        }
                    }
                }
            });
        }
    } 

    objBody = function (p) {
        if (this.entities.rawin (p)) {
            if (this.entities.rawget (p).EnhanTimer ==null){
                this.entities.rawget (p).EnhanTimer = Timer.Create (::UI, function  (p, context) {
                    if (!context.entities.rawget (p).IsGrounded) p.Pos.Y += 3;
                    foreach (e, Items in context.entities) {
                        if (context.entities.rawget (p).alias != Items.alias) {
                            local person = { x = p.Pos.X, y = p.Pos.Y, width = p.Size.X, height = p.Size.Y };
                            local obj = { x = e.Pos.X, y = e.Pos.Y, width = e.Size.X, height= e.Size.Y };
                            local distance = context.getDistance (person.x, person.y, obj.x, obj.y) < 60;
                            
                            local objTemp = {
                                context = context
                                changeImageTo = function (fileName) {
                                    e.SetTexture(context.loadRoot + fileName + ".png");
                                }  
                                 
                                spawn = function (data = null) {
                                    local wrapper = ::UI.Sprite ((Items.height-1) +"|"+ (Items.index));  
                                    if (wrapper) {
                                        local spriteObj = context.entities.rawget (wrapper), repeat = 0;
                                        if (data) repeat = data.rawget ("repeat");
                                       
                                        if (spriteObj.repeats == repeat) { 
                                            context.entities.rawdelete (wrapper);
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
                                    if (!context.entities.rawget (e).IsDetroyed) {
                                        e.Detach ();
                                        e.Pos = VectorScreen (0,0);
                                        e.hide ();
                                        context.entities.rawget (e).IsDetroyed = true;
                                      
                                        Timer.Destroy (context.entities.rawget (e).EnhanTimer);
                                        Timer.Destroy (context.entities.rawget (e).actionTimer);  
                                    } 
                                }
                            }

                            // IsMoving Event
                            if (context.entities.rawget (p).IsMoving || !context.entities.rawget (p).player) context.entities.rawget (p).IsGrounded = false;

                            // distance event
                            if (distance) {
                                if (context.entities.rawget (p).collisionEvent.rawin ("bumpBody")) 
                                    context.entities.rawget (p).collisionEvent.rawget ("bumpBody").acall ([e, objTemp]);
                            } 
                        
                             // collision Event
                            if (person.x < obj.x + obj.width && person.x + person.width > obj.x && person.y < obj.y + obj.height && person.y + person.height > obj.y) {
                                if (obj.y < person.y) { 
                                    if (!context.entities.rawget (p).player) { 
                                        if (context.entities.rawget (p).onKey.Heading == "right") {
                                            context.entities.rawget (p).bumpHeading = "right";

                                            if (context.entities.rawget (p).collisionEvent.rawin ("bumpRight")) context.entities.rawget (p).collisionEvent.rawget ("bumpRight").acall ([e, objTemp]);
                                            
                                            // debugging purpose.
                                            if (context.entities.rawget (e).rawin ("collisionEvent") && context.entities.rawget (e).collisionEvent.rawin ("bumpLeft")) {
                                                objTemp.Is <- function (args) { if (args == context.entities.rawget (p).alias) return true; }
                                                objTemp.exists <- function () { if (p) return true; };

                                                context.entities.rawget (e).collisionEvent.rawget ("bumpLeft").acall ([p, objTemp]);
                                            } 
                                        } 
                                        else {
                                            context.entities.rawget (p).bumpHeading = "left";
                                            if (context.entities.rawget (p).collisionEvent.rawin ("bumpLeft")) context.entities.rawget (p).collisionEvent.rawget ("bumpLeft").acall ([e, objTemp]);
                           
                                            // debugging purpose.
                                            if (context.entities.rawget (e).rawin ("collisionEvent") && context.entities.rawget (e).collisionEvent.rawin ("bumpRight")) {
                                                objTemp.Is <- function (args) { if (args == context.entities.rawget (p).alias) return true; }
                                                objTemp.exists <- function () { if (p) return true; };

                                                context.entities.rawget (e).collisionEvent.rawget ("bumpRight").acall ([p, objTemp]);
                                            }
                                        } 
                                    }

                                    // player collision events 
                                    else {                                      
                                        if (context.entities.rawget (p).onKey.Heading == "right") {
                                            context.entities.rawget (p).bumpHeading = "right";
                                            p.Pos.X = obj.x - obj.width; 

                                            if (context.entities.rawget (p).collisionEvent.rawin ("bumpRight")) context.entities.rawget (p).collisionEvent.rawget ("bumpRight").acall ([e, objTemp]);
                                        } 
                                        if (context.entities.rawget (p).onKey.Heading == "left") {
                                            context.entities.rawget (p).bumpHeading = "left";
                                            p.Pos.X = obj.x + obj.width;    
                                        
                                            if (context.entities.rawget (p).collisionEvent.rawin ("bumpLeft")) context.entities.rawget (p).collisionEvent.rawget ("bumpLeft").acall ([e, objTemp]);                      
                                        }

                                        if (context.entities.rawget (p).onKey.Heading == "space") {
                                            p.Pos.Y = obj.y + obj.height;
  
                                            if (context.entities.rawget (p).collisionEvent.rawin ("bumpHead")) context.entities.rawget (p).collisionEvent.rawget ("bumpHead").acall ([e, objTemp]);
                                        }
                                    }
                                }
                                else {
                                    if (!context.entities.rawget (p).IsGrounded) {
                                        if (context.entities.rawget (p).collisionEvent.rawin ("bumpFoot") && context.entities.rawget (p).player) context.entities.rawget (p).collisionEvent.rawget ("bumpFoot").acall ([e, objTemp]);
                                        p.Pos.Y = obj.y - person.height; 

                                        context.entities.rawget (p).IsJumping = false;
                                        context.entities.rawget (p).IsGrounded = true;

                                        context.entities.rawget (p).IsFalling = false;
                                    }
                                }
                            }
                        } 
                    }
                }, 1, 0, p, this);   
            }
        } 
    }    

    getTag = function (tag) {
        local list = [];
        foreach (e, Items in this.entities) {
            if (Items.alias == tag) list.push (this.entities.rawget (e));
        }
        return list;
    }

    getDistance = function (x1, y1, x2, y2) {
        local x = x2 - x1, y = y2 - y1;
        return sqrt(pow (x, 2) + pow (y, 2));
    }

    // attaching new props to entities
    attachPropToEntity = function () {
        local context = this; 

        GUISprite.rawnewmember("collides", function(collisionType, callback = null) {
            if (context.entities.rawin (this)) {
                if (!context.entities.rawget (this).collisionEvent.rawin (collisionType)) context.entities.rawget (this).collisionEvent.rawset (collisionType, callback);
            }
        }, null, false); 

        GUISprite.rawnewmember("move2d", function(speed) {
            if (context.entities.rawin (this)) {
                context.entities.rawget (this).onKey.Heading = (speed.tostring ().slice (0,1) == "-" ? "left" : "right");
 
                if (this.Pos.X <= 0) this.Pos.X = 0;
                if (this.Pos.X >= context.canvas.Size.X - this.Size.X) this.Pos.X = context.canvas.Size.X - this.Size.X;
                
                this.Pos.X += speed;
                context.entities.rawget (this).IsMoving = true;
            }
        }, null, false); 

        GUISprite.rawnewmember("action", function(callback) {
            if (context.entities.rawin (this)) { 
                if (context.entities.rawget (this).actionTimer==null){
                    context.entities.rawget (this).actionTimer = Timer.Create (::UI, function  (p) {  
                        callback.acall ([{
                            entity = p
                            context = context
                            Key = function (key, callback) {
                                if (key == context.entities.rawget (p).onKey.Heading) callback.acall ([{
                                    entity = p 
                                    event = context.entities.rawget (p).onKey.Event
                                }]);
                            } 
                        }]); 

                        if (context.entities.rawget (p).onKey.Event == "up") {
                            context.entities.rawget (p).onKey.Event = null;
                        }
                        if (context.entities.rawget (p).onKey.Event == null) context.entities.rawget (p).IsMoving = false; 
                        
                    }, 1, 0, this);  
                }
            } 
        }, null, false);  
        
        GUISprite.rawnewmember("Jump", function(speed) {
            if (context.entities.rawin (this)) {
                if (context.entities.rawget (this).IsGrounded) {
                    this.Pos.Y -= speed;    
                    
                    context.entities.rawget (this).IsJumping = true; // Entity is jumping
                    context.entities.rawget (this).IsGrounded = false; // Entity is on ground 
                }
                context.entities.rawget (this).IsFalling = true;
            }
        }, null, false); 
        
        GUISprite.rawnewmember ("props", function() {
            if (context.entities.rawin (this)) {
                local p = this;
                return {
                    IsOutWorld = function () {
                        // horizontally 
                        local GetReturn = false;
                        if (p.Pos.X < (-p.Size.X)) GetReturn = true;
                        if ((p.Pos.X-p.Size.X) > context.canvas.Size.X - p.Size.X) GetReturn = true;

                        // vertically
                        if (p.Pos.Y < 0) GetReturn = true;
                        if (p.Pos.Y > context.canvas.Size.Y - p.Size.Y) GetReturn = true;
                        
                        return GetReturn;
                    }         

                    getBumpHeading = function () {return context.entities.rawget (p).bumpHeading;}
                    getHeading = function () {return context.entities.rawget (p).onKey.Heading;}
                    getScale = function () {return context.entities.rawget (p).Scale;}
                    getDistance = function (entity = null) {if (entity) return getDistance (p.Pos.X, p.Pos.Y, entity.Pos.X, entity.Pos.Y);}

                    getIsJumpingStatus = function () {return context.entities.rawget (p).IsJumping;}
                    getIsMovingStatus = function () {return context.entities.rawget (p).IsMoving;}
                    getIsDestroyedStatus = function () {return context.entities.rawget (p).IsDetroyed;}
                    getIsFallingStatus = function () {return context.entities.rawget (p).IsFalling;}
                    getIsGroundedStatus = function () {return context.entities.rawget (p).IsGrounded;}
                } 
            }
        }, null, false);          

        GUISprite.rawnewmember("Scale", function(scaleTo) {
            if (context.entities.rawin (this)) {
                this.Size.X += 0.8 * scaleTo; 
                this.Size.Y += 0.8 * scaleTo;

                context.entities.rawget (this).Scale = this.Size;
            }
        }, null, false); 

        GUISprite.rawnewmember("remove", function() {
            if (context.entities.rawin (this)) {
                if (!context.entities.rawget (this).IsDetroyed) {
                    this.Detach ();
                    this.Pos = VectorScreen (0,0);
                    this.hide ();
                    context.entities.rawget (this).IsDetroyed = true;

                    Timer.Destroy (context.entities.rawget (this).EnhanTimer); 
                    Timer.Destroy (context.entities.rawget (this).actionTimer);
                }
            }
        }, null, false); 
    }
} 

