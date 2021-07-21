class map {
    store       = null;
    
    constructor () {
        this.store      = {};
    }

    set = function (name, data) {
        this.store.rawset (name, data);
    }

    get = function (entity) {
        return this.store.rawget (entity);
    }

    has = function (name) {
        return this.store.rawin (name);
    }
 
    remove = function (entity) {
        /*
            local data = {};
            foreach (e, Items in this.store) {
                if (e == entity) continue;
                else data.rawset (e, Items);
            }
            
                // assigning new data.
            this.store = data;
        */
        
        this.store.rawdelete (entity)
    }

    size = function () {
        return this.store.len ();
    }

    filter = function () {
        return this.store
    }

    forEach = function (callback) {
        foreach (e, obj in this.store) {
            callback (e, obj);
        }
    }
} 

