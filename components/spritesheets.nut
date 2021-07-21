// credits to DMWarrior
// adaptation by AroliS^ for Kaboom.nut

class SpriteSheet {
    image       = null;
    width       = null;
    height      = null;
    Id          = null; 
    animations  = null;

    mirror      = null;
    flip        = null;
    columns     = null;
    rows        = null;

    constructor(image, width, height, Id) {
        // assigning data to variables
        this.image      = image;
        this.width      = width;
        this.height     = height;
        this.Id         = Id;

        // pre-defined variables
        this.animations = [];
        this.flip       = 1;
        this.mirror     = 1;

        this.columns    = 1; // columns
        this.rows       = 1; // rows
    }

    define = function (name, x, y) {
        // Rows and columns of spritesheet:
        this.rows     = this.image.Size.Y / this.height;
        this.columns  = this.image.Size.X / this.width;

        // Iterate through rows and columns...
        for(local row = 0; row < this.rows; row += 1) {
            for(local column = 0; column < this.columns; column += 1) {
                this.animations.push({
                    // Initial cut position (unit value).
                    topLeft = {
                        x = x * column,
                        y = y * row
                    },

                    // Final cut position (unit value).
                    bottomRight = {
                        x = (x * column) + x,
                        y = (y * row) + y   
                    }
                });
            }
        }
        this.image.Size = VectorScreen (this.width, this.height);
        this.playFrames (this.image, this.Id);

        return this;
    }

    playFrames = function (image, index) {
        // mirroring entity
        if (this.mirror == -1) index += ((this.columns - 1) - (index % this.columns)) - (index % this.columns);
        
        // flipping entity
        if (this.flip == -1) {
            index = (this.animations.len() - 1) - index;
            index += ((this.columns - 1) - (index % this.columns)) - (index % this.columns);
        }

        // frames
        local frames = this.animations [index];
        
        // cutting the spritesheet
        image.TopLeftUV.X = frames.topLeft.x * this.mirror; 
        image.TopLeftUV.Y = frames.topLeft.y * this.flip; 

        image.BottomRightUV.X = frames.bottomRight.x * this.mirror; 
        image.BottomRightUV.Y = frames.bottomRight.y * this.flip; 
    }    
}

 