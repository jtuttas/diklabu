var webSocket;
var chatServer = SERVER.substring(SERVER.indexOf("//") + 2);
console.log("Chat Server " + chatServer);

function chatConnect() {
    // TODO ws für normal wss für secure
    webSocket = new WebSocket("wss://" + chatServer + "/Diklabu/chat");
    webSocket.onmessage = function (event) {
        console.log("receive CHAT:" + event.data);
        var chatLine = JSON.parse(event.data);
        if (chatLine.from == "System") {
            send(chatLine.from, sessionStorage.myself);
            $("#chatLines").prepend('<small><span class="chatSystem"> ' + chatLine.from + ' </span><span class="chatLine">  ' + sessionStorage.myself + " ist beigetreten!" + '</span></small><br></br>');
        }
        else {
            $("#chatLines").prepend('<small><span class="chatFrom"> ' + chatLine.from + ' </span><span class="chatLine">  ' + chatLine.msg + '</span></small><br></br>');
            if (!chatLine.notoast) {
                toastr["info"](chatLine.msg, "Chat from " + chatLine.from);
            }
        }


    };
}

function chatDisconnect() {
    webSocket.close();
}



$('#newChatLine').keyup(function (e) {
    if (e.keyCode == 13)
    {
        if ($("#newChatLine").val() != "") {
            $("#chatLines").prepend('<small><span class="chatMeFrom"> ' + "me" + ' </span><span class="chatLine">  ' + escapeHtml($("#newChatLine").val()) + '</span></small><br></br>');
            send(sessionStorage.myself, $("#newChatLine").val());
            $("#newChatLine").val("");
        }
    }
});

$("#sendChatLine").click(function () {
    if ($("#newChatLine").val() != "") {
        $("#chatLines").prepend('<small><span class="chatMeFrom"> ' + "me" + ' </span><span class="chatLine">  ' + escapeHtml($("#newChatLine").val()) + '</span></small><br></br>');
        send(sessionStorage.myself, $("#newChatLine").val());
        $("#newChatLine").val("");
    }
})

function send(from, msg) {
    var chatline = {
        from: from,
        msg: msg
    };
    console.log("Send " + JSON.stringify(chatline));
    webSocket.send(JSON.stringify(chatline));
}

var entityMap = {
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': '&quot;',
    "'": '&#39;',
    "/": '&#x2F;'
};

function escapeHtml(string) {
    return String(string).replace(/[&<>"'\/]/g, function (s) {
        return entityMap[s];
    });
}


