class map {
    store       = null;
    
    constructor () {
        this.store      = {};
    }

    set = function (name, data) {
        this.store.rawset (name, data);
    }

    get = function (key) {
        if (this.store.rawin (key)) return this.store.rawget (key);
        return null;
    }

    has = function (name) {
        return this.store.rawin (name);
    }
 
    remove = function (key) {
        this.store.rawdelete (key)
    }

    clear = function () {
        this.store.clear ();
    }

    size = function () {
        return this.store.len ();
    }

    forEach = function (callback) {
        foreach (e, obj in this.store) {
            callback (e, obj);
        }
    }
} 

