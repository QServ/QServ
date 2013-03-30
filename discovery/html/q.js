ws=new WebSocket("ws://192.168.0.197:9999/");

ws.binaryType = "arraybuffer";
ws.onmessage = function(msg){
    document.getElementById("table").innerHTML=msg.data;
}

function GetDiscoveryData(){
    var userInput = document.getElementById("filter").value;
    if(!userInput){userInput="*";}
    var fun = getSelectedRadioButton();
    var request = fun + "\"" + userInput +"\"";
    ws.send(request);
}

function getSelectedRadioButton(){
    var radioButtons = document.getElementsByName("tableSelector");
    for (var i = 0; i < radioButtons.length; i++) {
	if (radioButtons[i].checked) {
            return radioButtons[i].value;
	}
    }
    return ".h.getFunctionsTable";
}

function pingWs(){
	 ws.send("");
}

ws.onopen=GetDiscoveryData;
window.setInterval(pingWs,30000);
