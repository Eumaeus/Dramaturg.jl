
var br = new betareader();

var oldVal = "";

updatetest($("#greekInput").val(), "#greekOutput"); 


$("#greekInput").on("change keyup paste", function() {
    var currentVal = $(this).val();
    if(currentVal == oldVal) {
        return; //check to prevent multiple simultaneous triggers
    }

    oldVal = currentVal;

    //action to be performed on textarea changed
    updatetest(currentVal, "#greekOutput"); 

    if (currentVal.length >= 3) {
        // Script in interactions.js
        searchGreek(currentVal);
    } else {
        $("ul#resultsList").html("");
    };
    
});

function updatetest(t, pId) {
    let ucgreek = br.transcodeGreek(t);
    $(pId).html(ucgreek);
}