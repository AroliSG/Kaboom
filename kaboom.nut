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
    collisionEvent = null;
    
    constructor (obj) {
        this.id = obj.id;
        this.className = "Kaboom"; 
        this.entities  = {};
        this.collisionEvent = {};
        
        this.Size = obj.Size;
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

        this.loadRoot = obj.loadRoot;
        this.attachPropToEntity ();

        this.addKey ();
    }

    start = function (obj) {
    }

    scene = function () {

    }   

    addLevel = function  (map, obj) {
        local height = 0, index = 0, empty = 0, IsMoved = false;
        this.frames = [];
        foreach (map_design in map) {
            
            height++;
            this.frames.push ([]);

            this.SpriteSize = VectorScreen (this.Size.X/map_design.len()+1, this.Size.Y/map.len ());
            local h = 1;
            foreach (map_constr in map_design) {
                // placing frames

                // creating map
                //h=0;
                empty += this.SpriteSize.X;
                if (map_design.len () == index) {
                    index = 0;
                    empty = 0;
                    h = 1;
                }
                this.frames [height-1].push (VectorScreen (this.SpriteSize.X * index, this.SpriteSize.Y * height));

                if (obj.rawin (map_constr.tochar ())) {  
                    local hidden = false;
                    if (obj [map_constr.tochar ()].len () == 4) hidden = obj [map_constr.tochar ()]; 
                    local c = ::UI.Sprite({
                        id =  height +"|"+ index
                        file = this.loadRoot + obj [map_constr.tochar ()] [0] + ".png"     
                        Size = this.SpriteSize   
                    })

                    this.entities.rawset (c, {
                        solid = obj [map_constr.tochar ()] [1], 
                        alias = obj [map_constr.tochar ()] [2]
                        index = index
                        height = height
                        body = false
                        repeats = 0
                    });

                    if (obj [map_constr.tochar ()].len () == 4) c.hide ();
                    else c.show ();
/*
                    if (obj [map_constr.tochar ()].len () == 4) c.hide ();
                    else c.show ();
          
                    
                    local newId = obj [1], Solid = obj [map_constr.tochar ()] [1];
                    local raw = {
                        element = c,  
                        solid = Solid, 
                        Id = newId
                        index = index
                        height = height
                    }
                    
                    // saving data in local
                    this.localStore.push (raw)*/

                    if (IsMoved) {
                        c.Pos.X = empty;
                        IsMoved = false;
                    }

                    if (index > 0) { 
                        local prev = UI.Sprite (height +"|"+ (index-1))
                        if (prev) c.Pos.X += prev.Size.X + prev.Pos.X;
                    }
                    c.Pos.Y = (this.Size.Y/map.len()) * (height-1);
                    this.canvas.add (c, false);
                } 
                else IsMoved = true;
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
            IsBumped = null
        });

        this.Enhancements (entity);
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
                        if (obj.rawin ("onKey")) {
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
                        if (obj.rawin ("onKey")) {
                            context.entities.rawget (e).onKey.Heading = b;
                            context.entities.rawget (e).onKey.Event = "down";
                        }
                    }
                }
            });
        }
    } 
    
    //make the player to has gravity on empty spaces
    Enhancements = function (p) {
        if (this.entities.rawin (p)) {
            if (this.entities.rawget (p).EnhanTimer ==null){
                this.entities.rawget (p).EnhanTimer = Timer.Create (::UI, function  (p, context) {
                    if (!context.entities.rawget (p).IsGrounded) p.Pos.Y += 3;
                    foreach (e,items in context.entities) {
                        if (context.entities.rawget (p).alias != items.alias) {
                            local person = { x = p.Pos.X, y = p.Pos.Y, width = p.Size.X, height = p.Size.Y };
                            local obj = { x = e.Pos.X, y = e.Pos.Y, width = e.Size.X, height= e.Size.Y }; 
                            // events for objs
                            local TempObj = {
                                context = context
                                changeImageTo = function (fileName) {
                                    e.SetTexture(context.loadRoot + fileName + ".png");
                                }  
                                
                                spawn = function (data = null) {
                                    local s = ::UI.Sprite((items.height-1) +"|"+ (items.index));  
                                    if (s) {
                                        local objSpawned = context.entities.rawget (s), repeat = 0;
                                        if (data) {
                                        repeat = data.rawget ("repeat");
                                        }

                                        s.show ();
                                        if (objSpawned.repeats  >= repeat) { 
                                            context.entities.rawdelete (s);
                                            s.destroy ();
                                        }
                                        else  objSpawned.repeats ++;
                                    }
                                    return {
                                        fadeIn = function () { if (s) s.fadeIn ()}
                                        fadeOut = function () { if (s) s.fadeOut ()}
                                    }
                                }

                                is = function (arg) {
                                    if (arg == items.alias) return true;
                                } 

                                exists = function (spawn = null) {
                                    if (spawn == "spawn") {
                                        local s = ::UI.Sprite((items.height-1) +"|"+ (items.index));  

                                        if (s) return true;
                                        else return false;
                                    }
                                    else {
                                        if (e) return true;
                                        else return false;
                                    }
                                }

                                remove = function () {
                                // Console.Print (context.entities.rawdelete) 
                                    // e.destroy ()
                                // if (context.entities.rawin (e)) context.entities.rawdelete (e);  
                                    //e.destroy ();
                                    ////if (context.entities.rawin (e)) context.entities.rawdelete (e);
                                    //return
                                }
                            }
                           // items.height
/*
                            foreach (h in context.frames) {
                                foreach (f in h) {
                                    Console.Print (f.X + " " + e.Pos.X)
                                }
                            }*/
                            if (items.rawin ("height")) {
                                context.frames [items.height-1] [items.index]
                            }
                            else {
                                //context.entities.rawget (p).IsGrounded = false;
                            }

                            if (person.x < obj.x + obj.width && person.x + person.width > obj.x && person.y < obj.y + obj.height && person.y + person.height > obj.y) {
                                if (context.collisionEvent.rawin ("bumpBody")) context.collisionEvent.rawget ("bumpBody").acall ([e, TempObj]); 

                                // sides, headbump collision 
                                if (obj.y < person.y) {
                                       
                                    if (context.entities.rawget (p).onKey.Heading == "right" || !context.entities.rawget (p).player) {
                                        if (!context.entities.rawget (p).player) context.entities.rawget (p).IsBumped = "right";
                                        else p.Pos.X = obj.x-obj.width;

                                        if (context.collisionEvent.rawin ("bumpRight")) context.collisionEvent.rawget ("bumpRight").acall ([e, TempObj]);
                                    } 
                                    if (context.entities.rawget (p).onKey.Heading == "left" || !context.entities.rawget (p).player) {
                                        if (!context.entities.rawget (p).player) context.entities.rawget (p).IsBumped = "left";
                                        else p.Pos.X = obj.x+obj.width;                          
                                        
                                        if (context.collisionEvent.rawin ("bumpLeft")) context.collisionEvent.rawget ("bumpLeft").acall ([e, TempObj]);
                                    }

                                    // faces down of obj
                                    if (context.entities.rawget (p).onKey.Heading == "space" || !context.entities.rawget (p).player) {
                                        p.Pos.Y = obj.y+obj.height;
                                        if (context.collisionEvent.rawin ("bumpHead")) context.collisionEvent.rawget ("bumpHead").acall ([e, TempObj]);
                                    } 

                                    context.entities.rawget (p).onKey.Heading = null;
                                    context.entities.rawget (p).onKey.Event = "up";
                                }  

                                // grounded collision
                                else { 
                                    if (!context.entities.rawget (p).IsGrounded) {
                                        if (context.collisionEvent.rawin ("bumpFoot")) context.collisionEvent.rawget ("bumpFoot").acall ([e, TempObj]);
                                        p.Pos.Y = obj.y-p.Size.Y;

                                        context.entities.rawget (p).IsGrounded = true;
                                    }
                                } 
                            }  
                        }
                    }
                }, 1, 0, p, this);   
            }
        } 
    }    

    // attaching new props to entities
    attachPropToEntity = function () {
        local context = this;

        GUISprite.rawnewmember("on", function(collisionType, callback = null) {
            if (collisionType == "IsBumped") {
                return context.entities.rawget (this).IsBumped;
            }
            if (!context.collisionEvent.rawin (collisionType)) context.collisionEvent.rawset (collisionType, callback);
        }, null, false); 

        GUISprite.rawnewmember("move2d", function(speed) {
            if (this.Pos.X <= 0) this.Pos.X = 0;
            if (this.Pos.X >= context.canvas.Size.X - this.Size.X) this.Pos.X = context.canvas.Size.X - this.Size.X;
            
            this.Pos.X += speed;
        }, null, false); 

        local upIndex = 0;
        GUISprite.rawnewmember("action", function(callback) {
            if (context.entities.rawin (this)) {
                if (context.entities.rawget (this).actionTimer==null){
                    context.entities.rawget (this).actionTimer = Timer.Create (::UI, function  (p) {    
                        callback.acall ([p, {
                            createKey = function (key, callback) {
                               if (key == context.entities.rawget (p).onKey.Heading) callback.acall ([p, context.entities.rawget (p).onKey.Event])
                            }
                        }]); 
                        if (context.entities.rawget (p).onKey.Event == "up") context.entities.rawget (p).onKey.Event = null;
                    }, 1, 0, this); 
                }
            } 
        }, null, false); 
        
        local JumpTimer = 0;
        GUISprite.rawnewmember("Jump", function(speed, lasting) {
             if (context.entities.rawget (this).IsGrounded) {
                if (JumpTimer == lasting) {
                    JumpTimer = 0; 
                }
                else { 
                    this.Pos.Y -= speed; 
                    JumpTimer ++;      
                     
                    context.entities.rawget (this).IsGrounded = false; // Player is on ground 
                }
            }
        }, null, false); 

        GUISprite.rawnewmember ("props", function() {
            local p = this;
            return {
                OutOfWorld = function () {
                    // out x
                    local GetReturn = false;
                    if (p.Pos.X < (-p.Size.X)) GetReturn = true;
                    if ((p.Pos.X-p.Size.X) > context.canvas.Size.X - p.Size.X) GetReturn = true;

                    // falling y
                    if (p.Pos.Y < 0) GetReturn = true;
                    if (p.Pos.Y > context.canvas.Size.Y - p.Size.X) GetReturn = true;
                    
                    return GetReturn;
                }

                preOutOfWorld = function () {
                    // out x
                    local GetReturn = false;
                    if (p.Pos.X < 0) GetReturn = true;
                    if (p.Pos.X > context.canvas.Size.X - p.Size.X) GetReturn = true;

                    // falling y
                    if (p.Pos.Y < 0) GetReturn = true;
                    if (p.Pos.Y > context.canvas.Size.Y - p.Size.X) GetReturn = true;
                    
                    return GetReturn;
                }                
            } 
        }, null, false);         

        GUISprite.rawnewmember("Kill", function() {
            context.entities.rawdelete (this);
        }, null, false); 

    }
} 

