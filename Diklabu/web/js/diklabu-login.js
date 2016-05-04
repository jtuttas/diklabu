console.log("found token:" + sessionStorage.auth_token);
$("#login").click(function () {
    performLogin();
});

$("#version").text(VERSION);
/**
 * 
 * -------------------------------------------------------------------------
 * 
 * AJAX Server Routinen 
 * 
 * -------------------------------------------------------------------------
 * 
 */
/**
 * Entfernt deutsche Umlaute aus einem String
 * @param {type} name Der String
 * @returns {String|out}Der String ohne deutsche Umlaute
 */
function removeGerman(name) {
    out = "";
    for (i = 0; i < name.length; i++) {
        c = name.charAt(i);
        switch (c) {
            case 'ö':
                out += "oe";
                break;
            case 'ä':
                out += "ae";
                break;
            case 'ü':
                out += "ue";
                break;
            case 'ß':
                out += "ss";
                break;
            case 'Ä':
                out += "AE";
                break;
            case 'Ö':
                out += "OE";
                break;
            case 'Ü':
                out += "UE";
                break;
            default:
                out += c;
                break;
        }
    }
    return out;
}

/**
 * Login durchführen
 */
function performLogin() {
    console.log("perform Login");
    if (sessionStorage.auth_token == undefined || sessionStorage.auth_token == "undefined") {
        idplain = removeGerman($("#benutzername").val());
        var myData = {
            "benutzer": idplain,
            "kennwort": $("#kennwort").val()
        };
        console.log("idplain = " + idplain + " send data=" + JSON.stringify(myData));
        sessionStorage.service_key = idplain + "f80ebc87-ad5c-4b29-9366-5359768df5a1";
        console.log("Service key =" + sessionStorage.service_key);

        $.ajax({
            cache: false,
            contentType: "application/json; charset=UTF-8",
            headers: {
                "service_key": sessionStorage.service_key
            },
            dataType: "json",
            url: "/Diklabu/api/v1/auth/login/",
            type: "POST",
            data: JSON.stringify(myData),
            success: function (jsonObj, textStatus, xhr) {

                sessionStorage.auth_token = jsonObj.auth_token;
                console.log("Thoken = " + jsonObj.auth_token);
                console.log("Recieve " + JSON.stringify(jsonObj));
                toastr["success"]("Login erfolgreich", "Info!");
                sessionStorage.myselfplain = idplain;
                sessionStorage.myself = jsonObj.ID;
                sessionStorage.myemail = jsonObj.email;
                if (jsonObj.role == "Admin" || jsonObj.role == "Lehrer") {
                    window.location.replace("buch.html");
                }
                else {
                    window.location.replace("sbuch.html");
                }
            },
            error: function (xhr, textStatus, errorThrown) {
                toastr["error"]("Login fehlgeschlagen", "Fehler!");
                console.log("HTTP Status: " + xhr.status);
                console.log("Error textStatus: " + textStatus);
                console.log("Error thrown: " + errorThrown);
            }
        });
    }
    else {
        sessionStorage.clear();

    }
}

