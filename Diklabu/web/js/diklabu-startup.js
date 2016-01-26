// ID der gewählten Klasse
var idKlasse;
var nameKlasse;
// Schueler der gewählten Klasse
var schueler;
// Anwesenheit der gewählten Klasse und des gewählten Zeitraums
var anwesenheit;
// ID eines ausgewählten Schülers
var idSchueler;
// Index für email Form Fehlzeiten
var indexFehlzeiten;

var inputVisible = false;
var days = ['So.', 'Mo.', 'Di.', 'Mi.', 'Do.', 'Fr.', 'Sa.'];
$("#eintragDatum").datepicker("setDate", "+0");
var today = new Date();
$("#startDate").datepicker("setDate", new Date(today.getFullYear(), today.getMonth(), today.getDate() - 6));
$("#endDate").datepicker("setDate", new Date());
// Tooltip Aktivieren
$('[data-toggle="tooltip"]').tooltip();
$("#uploadBildButton").hide();
$(".infoIcon").unbind();
$("#template").load(SERVER + "/Diklabu/template.txt", function () {
    console.log("Load Template")
});
console.log("found token:" + sessionStorage.auth_token);
if (sessionStorage.auth_token != undefined && sessionStorage.auth_token != "undefined") {
    console.log("Build gui for logged in user");
    getLehrerData(sessionStorage.myself);
    loggedIn();
}

$("#emailZurueck").click(function() {
    var found = false;
    console.log("email zurück index="+indexFehlzeiten);
    for (var i = indexFehlzeiten-1; i >=0 && !found; i--) {
        var anwesenheitEintrag = anwesenheit[i];
        if (anwesenheitEintrag.summeFehltage!=undefined && anwesenheitEintrag.summeFehltage != 0) {
            console.log("Summe Fehltage = "+anwesenheitEintrag.summmeFehltag);
            generateMailForm(anwesenheitEintrag);
            indexFehlzeiten=i;
            found = true;
        }
    }
    console.log("Found a Item:" + found);

    if (!found) {
        toastr["warning"]("kein weiterer Fehlzeiteneintrag gefunden!", "Warnung!");
        
    }
})
$("#emailWeiter").click(function() {
     var found = false;
    console.log("email weiter index="+indexFehlzeiten);
    for (var i = indexFehlzeiten+1; i <anwesenheit.length && !found; i++) {
        var anwesenheitEintrag = anwesenheit[i];
        if (anwesenheitEintrag.summeFehltage!=undefined && anwesenheitEintrag.summeFehltage != 0) {
            console.log("Summe Fehltage = "+anwesenheitEintrag.summmeFehltag);
            generateMailForm(anwesenheitEintrag);
            indexFehlzeiten=i;
            found = true;
        }
    }
    console.log("Found a Item:" + found);

    if (!found) {
        toastr["warning"]("kein weiterer Fehlzeiteneintrag gefunden!", "Warnung!");
        
    }
})

// Ändern der Fileauswahl beim Bild Upload
$(document).on('change', '.btn-file :file', function () {

    var input = $(this),
            numFiles = input.get(0).files ? input.get(0).files.length : 1,
            label = input.val().replace(/\\/g, '/').replace(/.*\//, '');
    console.log("Ausgewählt wurde " + label);
    input.trigger('fileselect', [numFiles, label]);
    $("#bildWahl").text(label);
    $("#uploadBildButton").show();
});

// Bild Upload Button gedrückt
$('#bildUploadForm').on('submit', (function (e) {
    e.preventDefault();
    var formData = new FormData(this);
    $("#uploadBildButton").hide();
    $.ajax({
        type: 'POST',
        url: SERVER + "/Diklabu/api/v1/schueler/bild/" + idSchueler,
        data: formData,
        cache: false,
        contentType: false,
        processData: false,
        success: function (data) {
            console.log("success");
            if (data.success) {
                toastr["success"](data.msg, "Info!");
                getSchuelerBild(idSchueler);
                $("#fileBild").replaceWith($("#fileBild").val('').clone(true));
                $("#bildWahl").text("");
            }
            else {
                toastr["error"](data.msg, "Fehler!");
                $("#uploadBildButton").show();
            }
        },
        error: function (data) {
            console.log("error");
            toastr["error"]("Fehler beim Hochladen des Bildes!", "Fehler!");
            $("#uploadBildButton").show();
        }
    });
}));

$('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
//show selected tab / active
    console.log($(e.target).text());
    $("#dokumentationType").val($(e.target).text());

    // Bei Verspätungen neu vom Server laden
    if ($(e.target).text() == "Fehlzeiten") {
        console.log("Erneuere Fehlzeiten f. Klasse " + nameKlasse);
        $.ajax({
            // anwesenheit/FISI13A/2015-09-08/2015-09-15
            url: SERVER + "/Diklabu/api/v1/anwesenheit/" + nameKlasse + "/" + $("#startDate").val() + "/" + $("#endDate").val(),
            type: "GET",
            cache: false,
            headers: {
                "service_key": sessionStorage.service_key,
                "auth_token": sessionStorage.auth_token
            },
            contentType: "application/json; charset=UTF-8",
            success: function (data) {
                anwesenheit = data;
                console.log("anwesenheit=" + JSON.stringify(data));
                generateVerspaetungen();
            }
        });
    }
});

function emptyMailForm() {
    $("#emailBody").val("");
    $("#toMail").val("");
    $("#subjectMail").val("");
    $("#emailZurueck").hide();
    $("#emailWeiter").hide();
    $("#emailAbsenden").hide();    
}
function generateMailForm(ae) {
    console.log("Generate MAIL FORM");
        $("#emailZurueck").show();
    $("#emailWeiter").show();
    $("#emailAbsenden").show();

    $("#subjectMail").val("MMBbS Fehlzeitenmeldung");

    template = $("#template").text();
    //console.log("Template="+template);
    template = template.replace("[[LEHRER_NNAME]]", sessionStorage.lehrerNNAME);
    template = template.replace("[[LEHRER_EMAIL]]", sessionStorage.lehrerEMAIL);
    template = template.replace("[[ANZAHL_FEHLTAGE]]", ae.summeFehltage);
    var entschuldigt = ae.fehltageEntschuldigt;
    var ent = "";
    for (var i = 0; i < entschuldigt.length; i++) {
        ent += getReadableDate(entschuldigt[i].DATUM) + " ";
    }
    template = template.replace("[[DATUM_ENTSCHULDIGT]]", ent);

    var unentschuldigt = ae.fehltageUnentschuldigt;
    ent = "";
    for (var i = 0; i < unentschuldigt.length; i++) {
        ent += getReadableDate(unentschuldigt[i].DATUM) + " ";
    }
    template = template.replace("[[DATUM_UNENTSCHULDIGT]]", ent);
    template = template.replace("[[SCHUELER_NAME]]", getNameSchuler(ae.id_Schueler));
    template = template.replace("[[SCHUELER_KLASSE]]", nameKlasse);

    loadSchulerDaten(ae.id_Schueler, function (data) {

        template = template.replace("[[BETRIEB_NAME]]", data.betrieb.NAME);
        template = template.replace("[[BETRIEB_STRASSE]]", data.betrieb.STRASSE);
        template = template.replace("[[BETRIEB_PLZ]]", data.betrieb.PLZ);
        template = template.replace("[[BETRIEB_ORT]]", data.betrieb.ORT);

        template = template.replace("[[AUSBILDER_NNAME]]", data.ausbilder.NNAME);
        template = template.replace("[[START_DATUM]]", getReadableDate($("#startDate").val()));
        template = template.replace("[[END_DATUM]]", getReadableDate($("#endDate").val()));
        $("#toMail").val(data.ausbilder.EMAIL);

        $("#emailBody").val(template);
    });


}

function getReadableDate(d) {
    var date = new Date(d);
    return "" + date.getDate() + "." + (date.getMonth() + 1) + "." + date.getFullYear();
}

$("#login").click(function () {
    if (sessionStorage.auth_token == undefined || sessionStorage.auth_token == "undefined") {
        var myData = {
            "benutzer": $('#lehrer').find(":selected").attr("idplain"),
            "kennwort": $("#kennwort").val()
        };
        console.log("idplain = " + $('#lehrer').find(":selected").attr("idplain"));
        sessionStorage.service_key = $('#lehrer').find(":selected").attr("idplain") + "f80ebc87-ad5c-4b29-9366-5359768df5a1";
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

                toastr["success"]("Login erfolgreich", "Info!");
                sessionStorage.myselfplain = $('#lehrer').find(":selected").attr("idplain");
                sessionStorage.myself = $('#lehrer').val();
                getLehrerData(sessionStorage.myself);
                loggedIn();
                nameKlasse = $("#klassen").val();
                refreshVerlauf(nameKlasse);
                refreshKlassenliste(nameKlasse);
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
                console.log("HTTP Status: " + xhr.status);
                console.log("Error textStatus: " + textStatus);
                console.log("Error thrown: " + errorThrown);
                if (xhr.status = 401) {
                    loggedOut();
                }
            }
        });

    }
});


$.ajax({
    url: SERVER + "/Diklabu/api/v1/noauth/klassen",
    type: "GET",
    contentType: "application/json; charset=UTF-8",
    success: function (data) {
        $("#klassen").empty();
        for (i = 0; i < data.length; i++) {
            $("#klassen").append("<option dbid='" + data[i].id + "'>" + data[i].KNAME + "</option>");
        }
        nameKlasse = data[0].KNAME;
        idKlasse = data[0].id;
        $("#idklasse").val(idKlasse);
        if (sessionStorage.auth_token != undefined && sessionStorage.auth_token != "undefined") {
            refreshVerlauf(nameKlasse);
            refreshKlassenliste(nameKlasse)
        }
    },
    error: function () {
        toastr["error"]("kann Klassenliste nicht vom Server laden", "Fehler!");
    }
});
$.ajax({
    url: SERVER + "/Diklabu/api/v1/noauth/lernfelder",
    type: "GET",
    contentType: "application/json; charset=UTF-8",
    success: function (data) {
        $("#lernfelder").empty();
        for (i = 0; i < data.length; i++) {
            if (data[i].BEZEICHNUNG != undefined)
                $("#lernfelder").append("<option dbid='" + data[i].id + "'>" + data[i].BEZEICHNUNG + "</option>");
        }
    },
    error: function () {
        toastr["error"]("kann Lernfelder nicht vom Server laden", "Fehler!");
    }
});
$.ajax({
    url: SERVER + "/Diklabu/api/v1/noauth/lehrer",
    type: "GET",
    contentType: "application/json; charset=UTF-8",
    success: function (data) {
        $("#lehrer").empty();
        for (i = 0; i < data.length; i++) {
            $("#lehrer").append("<option idplain=" + data[i].idplain + ">" + data[i].id + "</option>");
        }
    },
    error: function () {
        toastr["error"]("kann Lehrerliste nicht vom Server laden", "Fehler!");
    }
});


function getLehrerData(id) {
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/lehrer/" + id + "/",
        type: "GET",
        cache: false,
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            sessionStorage.lehrerNNAME = data.NNAME;
            sessionStorage.lehrerEMAIL = data.EMAIL;
            sessionStorage.lehrerVNAME = data.VNAME;
            $("#fromMail").val(data.EMAIL);
        },
        error: function () {
            toastr["error"]("kann Lehrerdaten nicht vom Server laden", "Fehler!");
        }
    });
}

function refreshVerlauf(kl) {
    console.log("Refresh Verlauf f. Klasse " + kl + " von " + $("#startDate").val() + " bis " + $("#endDate").val());
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/verlauf/" + kl + "/" + $("#startDate").val() + "/" + $("#endDate").val(),
        type: "GET",
        cache: false,
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            verlauf = data;
            $("#tabelleVerlauf").empty();
            for (i = 0; i < data.length; i++) {
                var datum = data[i].wochentag + " " + data[i].DATUM;
                datum = datum.substring(0, datum.indexOf('T'));
                if (data[i].ID_LEHRER == sessionStorage.myself) {
                    $("#tabelleVerlauf").append("<tr dbid='" + data[i].ID + "' index='" + i + "' class='success'><td>" + datum + "</td><td>" + data[i].ID_LEHRER + "</td><td>" + data[i].ID_LERNFELD + "</td><td>" + data[i].STUNDE + "</td><td>" + data[i].INHALT + "</td><td>" + data[i].BEMERKUNG + "</td><td>" + data[i].AUFGABE + "</td></tr>");
                }
                else {
                    $("#tabelleVerlauf").append("<tr dbid='" + data[i].ID + "' index='" + i + "' ><td>" + datum + "</td><td>" + data[i].ID_LEHRER + "</td><td>" + data[i].ID_LERNFELD + "</td><td>" + data[i].STUNDE + "</td><td>" + data[i].INHALT + "</td><td>" + data[i].BEMERKUNG + "</td><td>" + data[i].AUFGABE + "</td></tr>");
                }
            }
            $(".success").click(function () {
                console.log("Auswahl Verlaufseintrag ID=" + $(this).attr("dbid"));
                idVerlauf = $(this).attr("dbid");
                index = $(this).attr("index");
                $("#lernsituationVerlauf").val(verlauf[index].AUFGABE);
                $("#bemerkungVerlauf").val(verlauf[index].BEMERKUNG);
                $("#inhaltVerlauf").val(verlauf[index].INHALT);
                var dat = verlauf[index].DATUM;
                dat = dat.substring(0, dat.indexOf('T'));
                $("#eintragDatum").val(dat);
                var lf = verlauf[index].ID_LERNFELD;
                lf = lf.trim();
                console.log("Setze Lernfeld auf (" + lf + ")");
                $("#lernfelder").val(lf);
                $("#stunde").val(verlauf[index].STUNDE);
                $("#updateVerlauf").removeClass("disabled");
                $("#deleteVerlauf").removeClass("disabled");
            });
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("kann Verlauf nicht vom Server laden! Status Code=" + xhr.status, "Fehler!");
        }
    });
}

function refreshKlassenliste(kl) {
    console.log("Refresh Klassenliste f. Klasse " + kl);
    nameKlasse = kl;
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/klasse/" + kl,
        type: "GET",
        cache: false,
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            schueler = data;
            $("#tabelleKlasse").empty();

            $("#tabelleKlasse").append('<thead><tr><th ><h3>Name</h3></th></tr></thead>');
            $("#tabelleKlasse").append("<tbody>");
            for (i = 0; i < data.length; i++) {
                $("#tabelleKlasse").append('<tr><td><img src="img/Info.png" id="S' + data[i].id + '" class="infoIcon"> ' + data[i].VNAME + " " + data[i].NNAME + '</td></tr>');
            }
            $("#tabelleKlasse").append("</tbody>");

            refreshAnwesenheit(nameKlasse);
            getSchuelerInfo();



        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("kann Schüler der Klasse " + kl + " nicht vom Server laden! Status Code=" + xhr.status, "Fehler!");
        }
    });
}

function getSchuelerInfo() {
    $(".infoIcon").unbind();
    $(".infoIcon").click(function () {
        var id = $(this).attr("id");
        idSchueler = id.substring(1);
        console.log("lade Schuler ID=" + idSchueler);
        loadSchulerDaten(idSchueler, function (data) {
            $("#infoName").text(data.vorname + " " + data.name);
            $("#infoGeb").text("Geburtsdatum " + data.gebDatum);
            $("#infoAusbilderName").text(data.ausbilder.NNAME);
            $("#infoAusbilderMail").text(data.ausbilder.EMAIL);
            $("#infoAusbilderMail").attr("href", "mailto://" + data.ausbilder.EMAIL);
            $("#infoAusbilderTel").text("Tel.:" + data.ausbilder.TELEFON);
            $("#infoAusbilderFax").text("Fax :" + data.ausbilder.FAX);

            $("#infoBetriebName").text(data.betrieb.NAME);
            $("#infoBetriebStrasse").text(data.betrieb.STRASSE);
            $("#infoBetriebOrt").text(data.betrieb.PLZ + " " + data.betrieb.ORT);

            $("#infoKlassen").empty();
            for (var i = 0; i < data.klassen.length; i++) {
                var kl = data.klassen[i];
                $("#infoKlassen").append('<li>' + kl.KNAME + " (" + kl.ID_LEHRER + ")" + '</li>');
            }

            $('#schuelerinfo').modal('show');
            getSchuelerBild(idSchueler);

        });
    });
}

function loadSchulerDaten(id, callback) {
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/schueler/" + id,
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
        }
    });
}

/**
 * Anzeige des Schülerbiles einer Schülers
 * @param {type} id
 * @returns {undefined}
 */
function getSchuelerBild(id) {
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/schueler/bild/" + id,
        type: 'HEAD',
        error:
                function () {
                    $("#infoBild").attr("src", "img/anonym.gif");
                },
        success:
                function () {
                    $("#infoBild").attr("src", SERVER + "/Diklabu/api/v1/schueler/bild/" + id);
                }
    });
}
function refreshAnwesenheit(kl) {
    console.log("Refresh Anwesenheit f. Klasse " + kl + " von " + $("#startDate").val() + " bis " + $("#endDate").val());
    var url = SERVER + "/Diklabu/api/v1/anwesenheit/" + kl + "/" + $("#startDate").val() + "/" + $("#endDate").val();
    console.log("URL=" + url);
    $.ajax({
        // anwesenheit/FISI13A/2015-09-08/2015-09-15
        url: SERVER + "/Diklabu/api/v1/anwesenheit/" + kl + "/" + $("#startDate").val() + "/" + $("#endDate").val(),
        type: "GET",
        cache: false,
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            anwesenheit = data;
            console.log("anwesenheit=" + JSON.stringify(data));
            generateVerspaetungen();
            $("#tabelleAnwesenheit").empty();
            var dateStart = new Date($("#startDate").val());
            var dateEnde = new Date($("#endDate").val());
            var current = new Date(dateStart);
            console.log("startDate=" + dateStart + " endeDate=" + dateEnde);
            // Leere Anwesenheitstabelle erzeugen
            var tab = "";
            tab += '<thead><tr>';
            while (current <= dateEnde) {
                if (current.getDay() == 0 || current.getDay() == 6) {
                    tab += '<th class="wochenende">&nbsp; ' + days[current.getDay()] + "<br>" + current.getDate() + "." + (current.getMonth() + 1) + "." + current.getFullYear() + '&nbsp; </th>';
                }
                else {
                    tab += '<th>&nbsp; ' + days[current.getDay()] + "<br>" + current.getDate() + "." + (current.getMonth() + 1) + "." + current.getFullYear() + '&nbsp; </th>';
                }
                current.setDate(current.getDate() + 1);
            }
            tab += '</tr></thead>';
            $("#tabelleAnwesenheit").append(tab);
            $("#tabelleAnwesenheit").append('<tbody>');
            generateAnwesenheitsTable();
            $("#tabelleAnwesenheit").append('</tbody>');
            // Daten in die Tabelle Eintragen
            for (var i = 0; i < anwesenheit.length; i++) {
                var eintraege = anwesenheit[i].eintraege;
                for (var j = 0; j < eintraege.length; j++) {
                    var dat = eintraege[j].DATUM;
                    dat = dat.substring(0, dat.indexOf("T"));
                    var id = eintraege[j].ID_SCHUELER + "_" + dat;
                    console.log("suche html id " + id);
                    //$("#" + id).text(eintraege[j].VERMERK);
                    $("#" + id).append('<a href="#" data-toggle="tooltip" title="' + eintraege[j].ID_LEHRER + '">' + eintraege[j].VERMERK + '</a>');
                    $("#" + id).attr("id_lehrer", eintraege[j].ID_LEHRER);
                    $("#" + id).addClass("anwesenheitsPopup");
                    if (eintraege[j].parseError) {
                        $("#" + id).addClass("parseError");
                    }
                }
            }
            // Eventhandler auf einen anwesenheitseintrag
            $(".anwesenheitsPopup").hover(function () {
                //alert("popup anzeigen");
            }, function () {

            });


        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("kann Anwesenheit der Klasse " + kl + " nicht vom Server laden! Status Code=" + xhr.status, "Fehler!");
        }
    });
}


function generateVerspaetungen() {
    console.log("Generate Verspaetungen");
    $("#verspaetungenTabelle").empty();
    for (var i = 0; i < anwesenheit.length; i++) {
        if (anwesenheit[i].summeFehltage != 0 || anwesenheit[i].anzahlVerspaetungen != 0 || anwesenheit[i].parseErrors.length != 0) {
            var tr = "<tr>";
            tr += "<td><img src=\"img/Info.png\" id=\"S" + anwesenheit[i].id_Schueler + "\" class=\"infoIcon\"> " + getNameSchuler(anwesenheit[i].id_Schueler) + "</td>";
            tr += "<td><strong>" + anwesenheit[i].summeFehltage + "</strong>&nbsp;";
            tr += "<span class=\"fehltagEntschuldigt\">" + anwesenheit[i].summeFehltageEntschuldigt + "</span></td>";
            tr += "<td>";
            var entschuldigt = anwesenheit[i].fehltageEntschuldigt;
            console.log("Fehltage Entschuldigt size=" + entschuldigt.length);
            for (var j = 0; j < entschuldigt.length; j++) {
                var dat = entschuldigt[j].DATUM;
                dat = dat.substr(0, dat.indexOf("T"));
                tr += "<span class=\"fehltagEntschuldigt\">" + dat + "</span> &nbsp;";
            }
            var unentschuldigt = anwesenheit[i].fehltageUnentschuldigt;
            console.log("Fehltage UnEntschuldigt size=" + unentschuldigt.length);
            for (var j = 0; j < unentschuldigt.length; j++) {
                var dat = unentschuldigt[j].DATUM;
                dat = dat.substr(0, dat.indexOf("T"));
                tr += "<span class=\"fehltagUnentschuldigt\">" + dat + "</span> &nbsp;";
            }
            tr += "</td>";


            tr += "<td>" + anwesenheit[i].anzahlVerspaetungen + " (" + anwesenheit[i].summeMinutenVerspaetungen + " min)</td>";
            tr += "<td>" + anwesenheit[i].summeMinutenVerspaetungenEntschuldigt + " min</td>";
            var fehler = anwesenheit[i].parseErrors;
            tr += "<td>";
            console.log("Fehler size=" + fehler.length);
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
    // Mail Form f. Fehltage aktualisieren
    var found = false;
    for (var i = 0; i < anwesenheit.length && !found; i++) {
        var anwesenheitEintrag = anwesenheit[i];
        if (anwesenheitEintrag.summeFehltage!=undefined && anwesenheitEintrag.summeFehltage != 0) {
            console.log("Summe Fehltage = "+anwesenheitEintrag.summmeFehltag);
            generateMailForm(anwesenheitEintrag);
            indexFehlzeiten=i;
            found = true;
        }
    }
    console.log("Found a Item:" + found);

    if (!found)
        emptyMailForm();

    getSchuelerInfo();

}

function getNameSchuler(id) {
    for (var i = 0; i < schueler.length; i++) {
        if (schueler[i].id == id) {
            console.log("Found Name for ID " + id + " " + schueler[i].VNAME + " " + schueler[i].NNAME)
            return schueler[i].VNAME + " " + schueler[i].NNAME;
        }
    }
    return "unknown ID " + id;
}

var oldText = "";
function generateAnwesenheitsTable() {
    var dateStart = new Date($("#startDate").val());
    var dateEnde = new Date($("#endDate").val());
    var tab = "";
    console.log("startDate=" + dateStart + " endeDate=" + dateEnde);
    for (var i = 0; i < schueler.length; i++) {
        tab += "<tr>";
        var dateStart = new Date($("#startDate").val());
        while (dateStart <= dateEnde) {
            if (dateStart.getDay() == 0 || dateStart.getDay() == 6) {
                tab += "<td class=\"anwesenheit wochenende\" align=\"center\" index=\"" + i + "\" id=\"" + schueler[i].id + "_" + toSQLString(dateStart) + "\" >&nbsp;</td>";
            }
            else {
                tab += "<td class=\"anwesenheit\" align=\"center\" index=\"" + i + "\" id=\"" + schueler[i].id + "_" + toSQLString(dateStart) + "\" >&nbsp;</td>";
            }
            dateStart.setDate(dateStart.getDate() + 1);
        }
        tab += '</tr>';
    }
    $("#tabelleAnwesenheit").append(tab);
    $(".anwesenheit").click(function () {
        console.log("input Visible=" + inputVisible);
        oldText = $(this).text();
        if (!inputVisible) {
            inputTd = $(this);
            inputVisible = true;
            $('body').off('keydown', "#anwesenheitsInput");
            var t = $(this).text();
            $(this).empty();
            $(this).append('<input class="inputAnwesenheit" id="anwesenheitsInput" maxlength="12" size="4" type="text" value="' + t + '"></input>');
            $("#anwesenheitsInput").focus();
            $("#anwesenheitsInput")[0].setSelectionRange(t.length - 1, t.length - 1);
            $('body').on('keydown', "#anwesenheitsInput", handelKeyEvents);
        }
        else {
            inputVisible = true;
            $('body').off('keydown', "#anwesenheitsInput");
            var txt = $("#anwesenheitsInput").val();
            console.log("eingegeben wurde (" + txt + ")");
            $("#anwesenheitsInput").remove();
            //inputTd.text(txt);
            inputTd.append('<a href="#" data-toggle="tooltip" title="' + sessionStorage.myself + '">' + txt + '</a>');
            if (txt != undefined && txt != "" && txt.charCodeAt(0) != 160)
                anwesenheitsEintrag(inputTd, txt);
            inputTd = $(this);
            var t = $(this).text();
            $(this).empty();
            $(this).append('<input class="inputAnwesenheit" id="anwesenheitsInput" maxlength="12" size="4" type="text" value="' + t + '"></input>');
            $("#anwesenheitsInput").focus();
            $("#anwesenheitsInput")[0].setSelectionRange(t.length - 1, t.length - 1);
            $('body').on('keydown', "#anwesenheitsInput", handelKeyEvents);
        }
    });

}

/**
 * Je nach eingaben in der Tabelle werden andere Elemente aktiviert bzw. die 
 * Daten zum Server übertrageb (z.B. bei TAB)
 * @returns {undefined}
 */
function handelKeyEvents(e) {
    var keyCode = e.keyCode || e.which;
    //console.log("key Pressed" + keyCode);
    if (keyCode == 13 || keyCode == 9 || keyCode == 27) {
        var txt = $(this).val();
        console.log("eingegeben wurde " + txt);
        $(this).remove();
        if (keyCode != 27) {
            //inputTd.text(txt);            
            inputTd.append('<a href="#" data-toggle="tooltip" title="' + sessionStorage.myself + '">' + txt + '</a>');
            anwesenheitsEintrag(inputTd, txt);
        }
        else {
            inputTd.append('<a href="#" data-toggle="tooltip" title="' + sessionStorage.myself + '">' + oldText + '</a>');
        }
        inputVisible = false;
        var index = inputTd.index();
        var tr = inputTd.parent();

        /*
         console.log("index=" + index);
         console.log("Nachbar-Element hat Text " + $(inputTd).next().text());
         console.log("Vorheriges-Element hat Text " + $(inputTd).prev().text());
         console.log("Oberhalb hat den Wert " + tr.prev().find('td').eq(index).text());
         console.log("Unterhalb hat den Wert " + tr.next().find('td').eq(index).text());
         */
        // unteres Element auswählen
        if (keyCode == 13) {
            // nicht letzte Zeile
            if (tr.next().index() != -1) {
                inputVisible = true;
                inputTd = tr.next().find('td').eq(index);
                t = inputTd.text();
                oldText = inputTd.text();
                inputTd.empty();
                inputTd.append('<input class="inputAnwesenheit" id="anwesenheitsInput" maxlength="12" size="4" type="text" value="' + t + '"></input>');
                $("#anwesenheitsInput").focus();
            }
            else {
                $('body').off('keydown', "#anwesenheitsInput");
            }
        }
        // bei TAB oder ESC
        if (keyCode == 9 || keyCode == 27) {
            $('body').off('keydown', "#anwesenheitsInput");
        }
    }
}

function anwesenheitsEintrag(td, txt) {
    var id = td.attr("id");
    var dat = id.substring(id.indexOf("_") + 1);
    var sid = id.substring(0, id.indexOf("_"));
    var eintr = {
        "DATUM": dat + "T00:00:00",
        "ID_LEHRER": sessionStorage.myself,
        "ID_SCHUELER": parseInt(sid),
        "VERMERK": txt
    };

    console.log("Sende zum Server:" + JSON.stringify(eintr));
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/anwesenheit/",
        type: "POST",
        cache: false,
        data: JSON.stringify(eintr),
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            if (data.parseError) {
                toastr["warning"]("Der Eintrag enthält Formatierungsfehler!", "Warnung!");
                td.addClass("parseError");
            }
            else {
                td.removeClass("parseError");
            }
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("kann Anwesenheitseintrag nicht zum Server senden! Status Code=" + xhr.status, "Fehler!");
        }
    });
}

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

function loggedOut() {
    $("#kuerzelContainer").show();
    $("#kennwortContainer").show();
    $("#login").removeClass("btn-danger");
    $("#login").addClass("btn-success");
    $("#login").text("Login");
    $("#dokumentation").addClass("disabled");
    $("#tabelle").hide();
    $("#inputVerlaufContainer").hide();
    $("#klassen").unbind();
    $("#dokumentation").unbind();
    $('#startDate').datepicker().off('changeDate');
    $('#endDate').datepicker().off('changeDate');
    sessionStorage.auth_token = undefined;
    sessionStorage.myself = undefined;
    $("#tabelleKlasse").empty();
    $("#tabelleKlasse").hide();
    $("#tabelleAnwesenheit").empty();
    $("#tabelleAnwesenheit").hide();
    $("#tabelleFehlzeiten").hide();
    $("#verspaetungenTabelle").empty();
    $("#chatContainer").hide();
    $("#tabFehlzeiten").hide();
    chatDisconnect();
}
function loggedIn() {

    $("#kuerzelContainer").hide();
    $("#kennwortContainer").hide();
    $("#login").removeClass("btn-success");
    $("#login").addClass("btn-danger");
    $("#login").text("Logout " + sessionStorage.myself);
    $("#dokumentation").removeClass("disabled");
    $("#tabelle").show();
    $("#inputVerlaufContainer").show();
    $('#startDate').datepicker().on('changeDate', function (ev) {
        refreshVerlauf($("#klassen").val());
        refreshAnwesenheit($("#klassen").val());
        $("#from").val($("#startDate").val());

    });
    $('#endDate').datepicker().on('changeDate', function (ev) {
        refreshVerlauf($("#klassen").val());
        refreshAnwesenheit($("#klassen").val());
        $("#to").val($("#endDate").val());
    });
    $("#klassen").change(function () {
        console.log("Klasse ID=" + $('option:selected', this).attr('dbid') + " KNAME=" + $("#klassen").val());
        idKlasse = $('option:selected', this).attr('dbid');
        nameKlasse = $("#klassen").val();
        refreshVerlauf($("#klassen").val());
        refreshKlassenliste($("#klassen").val());
        $("#idklasse").val(idKlasse);

    });
    $("#auth_token").val(sessionStorage.auth_token);
    $("#service_key").val(sessionStorage.service_key);
    $("#idklasse").val(idKlasse);
    $("#tabFehlzeiten").show();
    $("#from").val($("#startDate").val());
    $("#to").val($("#endDate").val());
    $("#tabelleKlasse").show();
    $("#tabelleAnwesenheit").show();
    $("#tabelleFehlzeiten").show();
    $("#chatContainer").show();
    chatConnect();
}