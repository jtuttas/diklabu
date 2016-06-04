/**
 * 
 * Globale Variablen
 */
// ID der gewählten Klasse
var idKlasse = sessionStorage.idKlasse;
var nameKlasse = sessionStorage.kname;
// Anwesenheit der gewählten Klasse und des gewählten Zeitraums
var anwesenheit;
// ID eines ausgewählten Schülers
var idSchueler = sessionStorage.myself;
// Index für email Form Fehlzeiten
var indexFehlzeiten;
// aktive Umfrage
var umfrage;

var days = ['Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag'];
$("#eintragDatum").datepicker("setDate", "+0");
var today = new Date();
$("#startDate").datepicker("setDate", new Date(today.getFullYear(), today.getMonth(), today.getDate() - 6));
$("#endDate").datepicker("setDate", new Date());
// Tooltip Aktivieren
$('[data-toggle="tooltip"]').tooltip();
$(".infoIcon").unbind();
$("#diklabuname").text(DIKLABUNAME);

////console.log("found token:" + sessionStorage.auth_token+" id="+sessionStorage.myself+" nameKlasse="+sessionStorage.kname+" idKlasse="+sessionStorage.idKlasse);
//console.log("Build gui for logged in user");
loggedIn();
updateCurrentView();
$("#anwesenheitName").text(sessionStorage.VNAME + " " + sessionStorage.NNAME);
$("#infoSchueler").attr("ids", sessionStorage.myself);
getSchuelerInfo();
/**
 * Event Handler
 */

$('#fehlzeitenTab').on('shown.bs.tab', function (e) {
    //console.log("fehlzeitenTab shown " + $(e.target).text());
    updateCurrentView();
});
$('#plaene').on('shown.bs.tab', function (e) {
    //console.log("plaene shown " + $(e.target).text());
    updateCurrentView();
});

$('#navTabs').on('shown.bs.tab', function (e) {
    //console.log("New Nav Target =" + $(e.target).text());
    updateCurrentView();
});
$("#login").click(function () {
    //console.log("Perform Login");
    performLogin();
});



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
 * Anwesenhietsdaten laden für einen Schüler 
 * @param {type} id des Schülers
 * @param {type} callback optional ein Callback
 */
function refreshAnwesenheit(sid, callback) {

    //console.log("--> Refresh Anwesenheit f. sid " + sid + " von " + $("#startDate").val() + " bis " + $("#endDate").val());
    var url = SERVER + "/Diklabu/api/v1/sauth/" + sid + "/" + $("#startDate").val() + "/" + $("#endDate").val();
    //console.log("URL=" + url);
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/sauth/" + sid + "/" + $("#startDate").val() + "/" + $("#endDate").val(),
        type: "GET",
        cache: false,
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            anwesenheit = data;
            //console.log("anwesenheit empfangen! ("+JSON.stringify(data))+")";
            // Eventhandler auf einen anwesenheitseintrag
            if (callback != undefined) {
                callback();
            }

        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("kann Anwesenheit für Schüler ID " + sid + " nicht vom Server laden! Status Code=" + xhr.status, "Fehler!");
            loggedOut();
        }
    });
}
/**
 * Laden und Anzeigen eines Schülerbildes vom Server
 * @param {type} id id des Schülers
 * @param {type} elem Element im dem das Bild angezeigt werden soll (als attr 'src')
 */
function getSchuelerBild(id, elem) {
    //console.log("--> Lade Schülerbild vom Schüler mit der id=" + id);
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/sauth/bild/" + id,
        cache: false,
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        type: 'HEAD',
        error:
                function () {
                    $(elem).attr("src", "../img/anonym.gif");
                },
        success:
                function () {
                    $.ajax({
                        url: SERVER + "/Diklabu/api/v1/sauth/bild64/" + id,
                        type: "GET",
                        headers: {
                            "service_key": sessionStorage.service_key,
                            "auth_token": sessionStorage.auth_token
                        },
                        success: function (data) {
                            //console.log("Bild Daten geladen:" + data.id + " elem=" + elem);
                            data = data.base64.replace(/(?:\r\n|\r|\n)/g, '');
                            $(elem).attr('src', "data:image/png;base64," + data);

                        },
                        error: function () {
                            toastr["error"]("kann Schülerbild ID=" + id + " nicht vom Server laden", "Fehler!");
                            loggedOut();
                        }
                    });

                }
    });
}

/**
 * Schülerdaten vom Server laden
 * @param {type} id ID des Schülers
 * @param {type} callback Callback
 */
function loadSchulerDaten(id, callback) {
    //console.log("--> loadSchuelerData id=" + id);
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/sauth/" + id,
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
            toastr["error"]("kann Schülerinfo ID=" + idSchueler + " nicht vom Server laden", "Fehler!");
            loggedOut();
        }
    });
}

/**
 * Active Umfrage abfragen
 * @param {type} callback Callback
 */
function getUmfrage(callback) {
    console.log("--> getUmfrage");
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/sauth/umfrage",
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
function getUmfrageFragen(id, callback) {
    console.log("--> getUmfrage id=" + id);
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/sauth/umfrage/fragen/" + id,
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
 * @param {type} uid Umfrage ID
 * @param {type} sid Schüler ID
 * @param {type} callback 
 * @returns {undefined}
 */
function getAntworten(uid,sid, callback) {
    console.log("--> getAntworten uid=" + uid+" für Schüler sid="+sid);
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/sauth/umfrage/antworten/" + uid+"/"+sid,
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
            toastr["error"]("Kann keine Fragen des Schüler mit ID="+sid+" vom Server laden!", "Fehler!");
        }
    });
}

/**
 * Ermittelt welchet Tab gerade geöffnet ist (nur diese Daten müssen nachgeladen werden!)
 * @returns Name des Tabs
 */
function getCurrentView() {
    target = $("ul#navTabs li.active").text();
    //console.log("get Current View Base target=(" + target + ")");

    if (target == "Pläne") {
        sub = $("ul#plaene li.active").text();
        return sub;
    }
    return target;
}


/**
 * Stundenplan (HTML) der Klasse Abfragen und anzeigen
 */
function loadStundenPlan() {
    //console.log("Lade Stundenplan der Klasse " + nameKlasse);
    $("#stundenplan").load(SERVER + "/Diklabu/api/v1/noauth/plan/stundenplan/" + nameKlasse, function (response, status, xhr) {
        //console.log("Stundenplan Status=" + status);
        if (status == "nocontent") {
            //console.log("Kann Stundenplan der Klasse " + nameKlasse + " nicht laden!")
            $("#stundenplan").empty();
            $("#stundenplan").append('<div><center><h1>Kann Stundenplan der Klasse ' + nameKlasse + ' nicht finden</h1></center></div>');
        }
    });
}

/**
 * Vertretungsplan (HTML) der Klasse Abfragen und anzeigen
 */
function loadVertertungsPlan() {
    //console.log("Lade Vertretungsplan der Klasse " + nameKlasse);
    $("#vertertungsplan").load(SERVER + "/Diklabu/api/v1/noauth/plan/vertertungsplan/" + nameKlasse, function (response, status, xhr) {
        //console.log("Vertretungsplan Status=" + status);
        if (status == "nocontent") {
            //console.log("Kann Vertertungsplan der Klasse " + nameKlasse + " nicht laden!")
            $("#vertertungsplan").empty();
            $("#vertertungsplan").append('<div><center><h1>Kann Vertertungsplan der Klasse ' + nameKlasse + ' nicht finden</h1></center></div>');
        }
    });
}

/**
 * Datum in eimem lesbaren Format ausgeben
 * @param {type} d Date Objekt 
 * @returns {String} lesbares Format
 */
function getReadableDate(d) {
    var date = new Date(d);
    return "" + date.getDate() + "." + (date.getMonth() + 1) + "." + date.getFullYear();
}

/**
 * Wandelt ein Datum in das SQL Datums Format
 * @param {type} d Das Date Objekt
 * @returns {String} Das SQL Datums Format
 */
function toSQLString(d) {
    var s = "";

    s += d.getFullYear() + "-";
    if (d.getMonth() + 1 > 9) {
        s += (d.getMonth() + 1);
    }
    else {
        s += "0" + (d.getMonth() + 1);
    }
    s += "-";
    if (d.getDate() > 9) {
        s += d.getDate();
    }
    else {
        s += "0" + d.getDate();
    }

    return s;
}

/**
 * GUI Vorbereiten wenn Nutzer ausgeloggt ist
 */
function loggedOut() {
    $('#startDate').datepicker().off('changeDate');
    $('#endDate').datepicker().off('changeDate');
    $("tbody").empty();
    sessionStorage.clear();
    schueler = undefined;
    window.location.replace("index.html");
}

/**
 * GUI vorbereiten wenn Nutzer eingeloggt ist 
 */
function loggedIn() {
    $('#startDate').datepicker().on('changeDate', function (ev) {
        $("#from").val($("#startDate").val());
        updateCurrentView();
    });
    $('#endDate').datepicker().on('changeDate', function (ev) {
        $("#to").val($("#endDate").val());
        updateCurrentView();
    });
}


/**
 * Erzeugen der Fehlzeitentabelle 
 */
function generateVerspaetungen() {
    //console.log("Generate Verspaetungen");
    $("#verspaetungenTabelle").empty();
    for (var i = 0; i < anwesenheit.length; i++) {
        if (anwesenheit[i].summeFehltage != 0 || anwesenheit[i].anzahlVerspaetungen != 0 || anwesenheit[i].parseErrors.length != 0) {
            var tr = "<tr>";
            tr += "<td><strong>" + anwesenheit[i].summeFehltage + "</strong>&nbsp;";
            tr += "<span class=\"fehltagEntschuldigt\">" + anwesenheit[i].summeFehltageEntschuldigt + "</span></td>";
            tr += "<td>";
            var entschuldigt = anwesenheit[i].fehltageEntschuldigt;
            //console.log("Fehltage Entschuldigt size=" + entschuldigt.length);
            for (var j = 0; j < entschuldigt.length; j++) {
                var dat = entschuldigt[j].DATUM;
                dat = dat.substr(0, dat.indexOf("T"));
                tr += "<span class=\"fehltagEntschuldigt\">" + '<a href="#" data-toggle="tooltip" title="' + entschuldigt[j].ID_LEHRER + '">' + dat + "</a></span> &nbsp;";
            }
            var unentschuldigt = anwesenheit[i].fehltageUnentschuldigt;
            //console.log("Fehltage UnEntschuldigt size=" + unentschuldigt.length);
            for (var j = 0; j < unentschuldigt.length; j++) {
                var dat = unentschuldigt[j].DATUM;
                dat = dat.substr(0, dat.indexOf("T"));
                tr += "<span class=\"fehltagUnentschuldigt\">" + '<a href="#" data-toggle="tooltip" title="' + unentschuldigt[j].ID_LEHRER + '">' + dat + "</a></span> &nbsp;";
            }
            tr += "</td>";


            tr += "<td>" + anwesenheit[i].anzahlVerspaetungen + " (" + anwesenheit[i].summeMinutenVerspaetungen + " min)</td>";
            tr += "<td>" + anwesenheit[i].summeMinutenVerspaetungenEntschuldigt + " min</td>";
            var fehler = anwesenheit[i].parseErrors;
            tr += "<td>";
            //console.log("Fehler size=" + fehler.length);
            for (var j = 0; j < fehler.length; j++) {
                var dat = fehler[j].DATUM;
                dat = dat.substr(0, dat.indexOf("T"));
                tr += "<span class=\"parseErrors\">" + fehler[j].ID_LEHRER + " (" + fehler[j].VERMERK + ") " + dat + "</span> &nbsp;";
            }
            tr += "</td>";

            tr += "</tr>";
            $("#verspaetungenTabelle").append(tr);
        }
    }
    getSchuelerInfo();

}
/**
 * Erzeugen der Fehlzeitentabelle 
 */
function generateAnwesenheit() {
    //console.log("Generate Anwesenheit");
    $("#anwesenheitsTabelle").empty();
    from = new Date($("#startDate").val());
    to = new Date($("#endDate").val());
    //console.log("from="+from+" time="+from.getTime()+" to="+to.getTime());
    while (from.getTime() <= to.getTime()) {
        var s = toSQLString(from);
        $("#anwesenheitsTabelle").append('<tr><td>' + days[from.getDay()] + ' ' + from.getDate() + '.' + (from.getMonth() + 1) + '.' + from.getFullYear() + '</td><td id="LK' + s + '"></td><td id="Verm' + s + '"></td>');
        from.setDate(from.getDate() + 1);
    }

    if (anwesenheit.length>0) {
    anw = anwesenheit[0].eintraege;
    for (var i = 0; i < anw.length; i++) {
        eintrag = anw[i];
        //console.log(eintrag);
        dat = eintrag.DATUM;
        dat = dat.substr(0, dat.indexOf("T"));
        $("#LK" + dat).text(eintrag.ID_LEHRER);
        $("#Verm" + dat).text(eintrag.VERMERK);
    }
    }



}

/**
 * Schülernamen anhand seiner ID ermitteln
 * @param {type} id die Schüler ID
 * @returns {String} Der  Vor und Nachname des Schülers
 */
function getNameSchuler() {
    return sessionStorage.VNAME + " " + sessionStorage.NNAME;
}

/**
 * Findet das Schülerobjekt in der Liste schueler
 * @param {type} id die ID des Schülers
 * @returns {data|schueler} das Schülerobjekt
 */
function findSchueler(id) {
    for (i = 0; i < schueler.length; i++) {
        if (schueler[i].id == id) {
            return schueler[i];
        }
    }
    return undefined;
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
 * Informationen zu einem Schüler einholen
 */
function getSchuelerInfo() {
    $(".infoIcon").unbind();
    $(".infoIcon").click(function () {
        idSchueler = $(this).attr("ids");
        //console.log("lade Schuler ID=" + idSchueler);
        loadSchulerDaten(idSchueler, function (data) {
            $("#infoName").text(data.vorname + " " + data.name);
            $("#infoGeb").text("Geburtsdatum " + data.gebDatum);
            if (data.ausbilder != undefined) {
                $("#infoAusbilderName").text(data.ausbilder.NNAME);
                $("#infoAusbilderMail").text(data.ausbilder.EMAIL);
                $("#infoAusbilderMail").attr("href", "mailto://" + data.ausbilder.EMAIL);
                $("#infoAusbilderTel").text("Tel.:" + data.ausbilder.TELEFON);
                $("#infoAusbilderFax").text("Fax :" + data.ausbilder.FAX);

            }
            if (data.betrieb != undefined) {
                $("#infoBetriebName").text(data.betrieb.NAME);
                $("#infoBetriebStrasse").text(data.betrieb.STRASSE);
                $("#infoBetriebOrt").text(data.betrieb.PLZ + " " + data.betrieb.ORT);
            }
            $("#infoKlassen").empty();
            for (var i = 0; i < data.klassen.length; i++) {
                var kl = data.klassen[i];
                $("#infoKlassen").append('<li>' + kl.KNAME + " (" + kl.ID_LEHRER + ")" + '</li>');
            }

            $('#schuelerinfo').modal('show');
            getSchuelerBild(idSchueler, "#infoBild");

        });
    });
    $(".mailIcon").unbind();
    $(".mailIcon").click(function () {
        //console.log("mail to Schüler with id=" + $(this).attr("ids"));
        var s = findSchueler($(this).attr("ids"));
        $("#mailName").text(s.VNAME + " " + s.NNAME);
        $("#mailSAdr").text(s.EMAIL);
        $("#fromLehrerMail").val(sessionStorage.myemail)
        $("#toSchuelerMail").val(s.EMAIL);
        $("#emailSchuelerBetreff").val('');
        $("#emailSchuelerInhalt").val('');

        $('#mailSchueler').modal('show');
    });
    $(".mailBetrieb").unbind();
    $(".mailBetrieb").click(function () {
        //console.log("mail to Betrieb to=" + $(this).attr("aemail"));
        $("#mailName").text($(this).attr("aname"));
        $("#mailSAdr").text($(this).attr("aemail"));
        $("#fromLehrerMail").val(sessionStorage.myemail)
        $("#toSchuelerMail").val($(this).attr("aemail"));
        $("#emailSchuelerBetreff").val('');
        $("#emailSchuelerInhalt").val('');
        $('#mailSchueler').modal('show');
    });
}

function submitUmfrage(uid, sid, fid, aid) {
    var eintr = {
        "idAntwort": aid,
        "idFrage": fid,
        "idSchueler": sid,
        "idUmfrage": uid,        
    }
    console.log("--> Sende:"+JSON.stringify(eintr));
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/sauth/umfrage",
        type: "POST",
        cache: false,
        data: JSON.stringify(eintr),
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            if (data!=undefined && data.success==false) {
                toastr["error"](data.msg, "Fehler!");
            }
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("Kann Eintrag zur Umfrage nicht zum Server senden! Status Code=" + xhr.status, "Fehler!");
        }
    });
}

/**
 * Login durchführen
 */
function performLogin() {
    var myData = {
        "benutzer": $("#lehrer").val(),
        "kennwort": $("#kennwort").val()
    };

    $.ajax({
        cache: false,
        contentType: "application/json; charset=UTF-8",
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        dataType: "json",
        url: "/Diklabu/api/v1/auth/logout/",
        type: "POST",
        data: JSON.stringify(myData),
        success: function (jsonObj, textStatus, xhr) {
            sessionStorage.auth_token = undefined;
            toastr["success"]("Logout erfolgreich", "Info!");
            sessionStorage.myself = undefined;
            loggedOut();
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("Logout fehlgeschlagen!Status Code=" + xhr.status, "Fehler!");
            //console.log("HTTP Status: " + xhr.status);
            //console.log("Error textStatus: " + textStatus);
            //console.log("Error thrown: " + errorThrown);
            if (xhr.status = 401) {
                loggedOut();
            }
        }
    });

}

/**
 * Über diese Methode werden Daten vom Server nachgeladen, wenn:
 * 1. Sich die Ansicht geändert hat (neuer Tab aufgemacht)
 * 2. Sich die Auswahl der Klasse geändert hat
 * 3. Wenn sich das Datum geändert hat (nur bei Fehlzeiten)
 * 4. Wenn Sich der Benutzer angemledet hat
 * 5. Wenn die Seite refreshed wurde (F5)
 */
function updateCurrentView() {
    if (sessionStorage.auth_token == undefined)
        return;

    view = getCurrentView();
    //console.log("Update Current View = " + view);
    switch (view) {
        case "Anwesenheit":
            refreshAnwesenheit(sessionStorage.myself, function () {
                generateAnwesenheit();
            });
            break;
        case "Fehlzeiten":
            refreshAnwesenheit(sessionStorage.myself, function () {
                generateVerspaetungen();
            });
            break;
        case "Pläne":
            loadStundenPlan();
            break;
        case "Stundenplan Klasse":
            loadStundenPlan();
            break;
        case "Vertretungsplan Klasse":
            loadVertertungsPlan();
            break;
        case "Befragung":

            getUmfrage(function (data) {
                umfrage = data;
                if (data.length > 1) {
                    toastr["error"]("Achtung mehr als eine Umfrage aktiv!", "Fehler!");
                }
                else if (data.length==0) {
                    $("#titelBefragung").text("Keine aktive Umfrage gefunden!");
                }
                else {
                    console.log("Aktive Umfrage id=" + data[0].id)
                    getUmfrageFragen(data[0].id, function (data) {
                        console.log("Hame empfangen" + JSON.stringify(data));
                        $("#titelBefragung").text(data.titel);
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
                                submitUmfrage(umfrage[0].id, sessionStorage.myself, $(this).attr("fid"), $(this).attr("aid"));
                            }
                        });
                        // bisherige Antworten abfragen
                        getAntworten(umfrage[0].id,sessionStorage.myself,function (data) {
                            console.log("empfange "+JSON.stringify(data));
                            if (data!=undefined) {
                            for (i=0;i<data.length;i++) {
                                antw = data[i];
                                console.log("Bearbeite Frage "+antw.frage);
                                $("#U"+antw.idFrage+"_"+antw.idAntwort).attr("src",'../img/checked1.png');
                                $("#U"+antw.idFrage+"_"+antw.idAntwort).attr("state",'1');
                                $("#U"+antw.idFrage+"_"+antw.idAntwort).removeClass("checkedfrage");
                                $("#U"+antw.idFrage+"_"+antw.idAntwort).addClass("uncheckfrage");
                            }
                        }
                        });
                        
                    });
                }
            });
            break;
    }

    function generateHeadUmfrage(antworten) {
        $("#umfrageHead").empty();
        console.log("Antworten=" + JSON.stringify(antworten));
        var html = "<tr>";
        html += '<th width="40%"><h3>Fragen</h3></th>';
        for (i = 0; i < antworten.length; i++) {
            html += '<th class="antworten">' + antworten[i].name + '</th>'
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
                if (findAntworten(antworten[j].id, fragen[i].antworten)) {
                    console.log("Antwort mit ID " + antworten[j].id + " enthalten!");
                    html += '<td><div align=\"center\"><img state="0" fid="' + fragen[i].id + '" aid="' + antworten[j].id + '" id="U' + fragen[i].id + '_' + antworten[j].id + '" class="checkfrage" src="../img/unchecked.png"></div></td>';
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

}

