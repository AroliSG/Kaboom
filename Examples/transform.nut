UI.Kaboom ({
    id = "transform"
    Size = VectorScreen (700,500)
    loadRoot = "kaboom/blocks/"
});


Kaboom.scene ("test", function () {
    local coin = addEntity ([ "wbKxhcd", {
        origin = "center" // centering coin
    }]);

   render (function () {
        coin.Scale (sin(Script.GetTicks ()) * 24)
        coin.props ().rotate (Script.GetTicks ()) // spining
    });

}); 

Kaboom.start ("test");