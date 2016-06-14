/**
 * 
 * Globale Variablen
 */
$(document).ajaxSend(function (event, request, settings) {
    $('#loading-indicator').show();
});

$(document).ajaxComplete(function (event, request, settings) {
    $('#loading-indicator').hide();
});

var getUrlParameter = function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName,
            i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
};
var key = getUrlParameter('ID');
if (key == undefined) {
    toastr["error"]("Keine Umfrage ID gefunden!", "Fehler!");
}
else {
    getUmfrageFragen(key, function (data) {
        console.log("Hame empfangen" + JSON.stringify(data));
        if (data==undefined) {
            toastr["error"]("Keine gültige ID!", "Fehler!");
        }
        else {
            $("#umfragename").text(data.titel);
            if (data.active == 0) {
                toastr["error"]("Die Umfrage ist nicht mehr aktiv!", "Fehler!");
            }
            else {
                generateHeadUmfrage(data.antworten);
                generateBodyUmfrage(data.fragen, data.antworten);
                $(".checkfrage").click(function () {
                    console.log("Click auf FRage id=(" + $(this).attr("fid") + ") antwort ID=" + $(this).attr("aid") + " checked=" + $(this).attr("state"));
                    if ($(this).attr("state") == 1) {
                    }
                    else {
                        $("[id^='U" + $(this).attr("fid") + "_']").attr("src", "../img/unchecked.png");
                        $("[id^='U" + $(this).attr("fid") + "_']").attr("state", "0");
                        $(this).attr("src", '../img/checked1.png');
                        $(this).attr("state", '1');
                        $(this).removeClass("checkedfrage");
                        $(this).addClass("uncheckfrage");
                        submitUmfrage(key, $(this).attr("fid"), $(this).attr("aid"));
                    }
                });
                // bisherige Antworten abfragen
                getAntworten(key, function (data) {
                    console.log("empfange " + JSON.stringify(data));
                    if (data != undefined) {
                        for (i = 0; i < data.length; i++) {
                            antw = data[i];
                            console.log("Bearbeite Frage " + antw.frage);
                            $("#U" + antw.idFrage + "_" + antw.idAntwort).attr("src", '../img/checked1.png');
                            $("#U" + antw.idFrage + "_" + antw.idAntwort).attr("state", '1');
                            $("#U" + antw.idFrage + "_" + antw.idAntwort).removeClass("checkedfrage");
                            $("#U" + antw.idFrage + "_" + antw.idAntwort).addClass("uncheckfrage");
                        }
                    }
                });
            }
        }

    });
}


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
 * Active Umfrage abfragen
 * @param {type} callback Callback
 */
function getUmfrage(callback) {
    console.log("--> getUmfrage");
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/noauth/umfrage",
        type: "GET",
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            callback(data);
        },
        error: function () {
            toastr["error"]("kann aktive Umfrage nicht vom Server laden", "Fehler!");
        }
    });
}

/**
 * Fragen und Antworten der Umfrage abfragen
 * @param {type} callback Callback
 */
function getUmfrageFragen(key, callback) {
    console.log("--> getUmfrage key=" + key);
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/noauth/umfrage/fragen/" + key,
        type: "GET",
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            callback(data);
        },
        error: function () {
            toastr["error"]("kann keine Fragen der Umfrage vom Server laden", "Fehler!");
        }
    });
}


/**
 * Bisherige Antworten abfragen
 * @param {type} key
 * @param {type} callback
 * @returns {undefined}
 */
function getAntworten(key, callback) {
    console.log("--> getAntworten key=" + key);
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/noauth/umfrage/antworten/" + key,
        type: "GET",
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            callback(data);
        },
        error: function () {
            toastr["error"]("Kann keine Fragen für KEY " + key + " vom Server laden!", "Fehler!");
        }
    });
}



/**
 * Findet des key in der Map
 * @param {type} k der Key 
 * @param {type} m die Map
 * @returns {Boolean} true=gefunden
 */
function findKeyinMap(k, m) {
    for (n1 in m) {
        if (k == n1)
            return true;
    }
    return false;
}



function submitUmfrage(key, fid, aid) {
    var eintr = {
        "idAntwort": aid,
        "idFrage": fid,
        "key": key
    }
    console.log("--> Sende:" + JSON.stringify(eintr));
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/noauth/umfrage",
        type: "POST",
        cache: false,
        data: JSON.stringify(eintr),
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            if (data != undefined && data.success == false) {
                toastr["error"](data.msg, "Fehler!");
            }
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("Kann Eintrag zur Umfrage nicht zum Server senden! Status Code=" + xhr.status, "Fehler!");
        }
    });
}



function generateHeadUmfrage(antworten) {
    $("#umfrageHead").empty();
    console.log("Antworten=" + JSON.stringify(antworten));
    var html = "<tr>";
    var width=52/antworten.length;
    html += '<th><h2>Fragen</h2></th>';
    for (i = 0; i < antworten.length; i++) {
        html += '<th class="antworten" width="'+width+'%">' + antworten[i].name + '</th>'
        console.log("Fühe Antwort hinzu" + antworten[i].name + " id=" + antworten[i].id);
    }
    html += '</tr>';
    $("#umfrageHead").append(html);
}

function generateBodyUmfrage(fragen, antworten) {
    $("#umfrageBody").empty();
    console.log("Generate Fragen cols=" + antworten.length);
    html = "";

    for (i = 0; i < fragen.length; i++) {
        html += '<tr>';
        html += '<td>' + fragen[i].frage + '</td>';
        for (j = 0; j < antworten.length; j++) {
            console.log("Teste Antworten der Frage " + fragen[i].frage + " gegen Antwort ID=" + antworten[j].id);
            if (findAntworten(antworten[j].id, fragen[i].IDantworten)) {
                console.log("Antwort mit ID " + antworten[j].id + " enthalten!");
                html += '<td><div align=\"center\"><img state="0" fid="' + fragen[i].id + '" aid="' + antworten[j].id + '" id="U' + fragen[i].id + '_' + antworten[j].id + '" class="checkfrage " src="../img/unchecked.png"></div></td>';
            }
            else {
                console.log("Antwort mit ID " + antworten[j].id + " ist NICHT enthalten!");
                html += '<td>&nbsp;</td>';
            }
        }
        html += '</tr>';
    }

    $("#umfrageBody").append(html);
}

function findAntworten(aid, map) {
    for (n = 0; n < map.length; n++) {
        console.log("Teste id=" + map[n] + " gegen " + aid);
        if (map[n] == aid) {
            return true;
        }
    }
    return false;
}



