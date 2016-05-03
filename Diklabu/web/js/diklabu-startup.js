/**
 * 
 * Globale Variablen
 */
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
// Betriebliste
var betriebe;
// Notenliste
var notenliste;

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

getKlassenliste(function () {
    getLernfelder(function () {
        if (sessionStorage.auth_token != undefined) {
            console.log("Build gui for logged in user");
            $("#dokumentationContainer").show();
            getLehrerData(sessionStorage.myself);
            loggedIn();
            updateCurrentView();
        }
        else {
            showContainer(false);
        }
    })
})
getFilter();

/**
 * Event Handler
 */

$("#print").click(function () {
    currentView = getCurrentView();
    if (currentView == "Stundenplan Klasse") {
        $("#stundenplan").printThis({
            debug: false,
            printContainer: true,
            pageTitle: "Stundenplan " + nameKlasse,
            removeInline: false
        });
    }
    else if (currentView == "Vertretungsplan Klasse") {
        $("#vertertungsplan").printThis({
            debug: false,
            printContainer: true,
            pageTitle: "Stundenplan " + nameKlasse,
            removeInline: false
        });
    }
     else if (currentView == "Vertretungsplan Lehrer") {
        $("#lvertertungsplan").printThis({
            debug: false,
            printContainer: true,
            pageTitle: "Stundenplan " + nameKlasse,
            removeInline: false
        });
    }
     else if (currentView == "Stundenplan Lehrer") {
        $("#lstundenplan").printThis({
            debug: false,
            printContainer: true,
            pageTitle: "Stundenplan " + nameKlasse,
            removeInline: false
        });
    }
    else if (currentView == "Bilder") {
        $("#tabAnwesenheitBilder").printThis({
            debug: false,
            printContainer: true,
            loadCSS: [SERVER + "/Diklabu/css/bootstrap.min.css", SERVER + "/Diklabu/css/buch.css"],
            pageTitle: "Bilder Klasse " + nameKlasse,
            removeInline: false
        });

    }
    else if (currentView == "Noteneintrag") {
        $("#tabNoteneintrag").printThis({
            debug: false,
            printContainer: true,
            importCSS: true,
            loadCSS: SERVER + "/Diklabu/css/bootstrap.min.css",
            pageTitle: "Noteneintrag Klasse " + nameKlasse,
            formValues: true
        });

    }
    else if (currentView == "Mail") {
        $("#mailContainer").printThis({
            debug: false,
            printContainer: true,
            importCSS: true,
            loadCSS: SERVER + "/Diklabu/css/bootstrap.min.css",
            pageTitle: "Mail ",
            formValues: true
        });

    }
    else if (currentView == "Schülerbemerkungen") {
        $("#bemerkungContainer").printThis({
            debug: false,
            printContainer: true,
            importCSS: true,
            loadCSS: SERVER + "/Diklabu/css/bootstrap.min.css",
            pageTitle: "Schülerbemerkungen Klasse " + nameKlasse,
            formValues: true
        });

    }
    else if (currentView == "Betriebe anschreiben") {
        $("#emailBetriebeSubjectContainer").printThis({
            debug: false,
            printContainer: true,
            importCSS: true,
            loadCSS: SERVER + "/Diklabu/css/bootstrap.min.css",
            pageTitle: "nachricht an Betribe der Klasse " + nameKlasse,
            formValues: true
        });

    }


});

$("#eigeneEintraege").click(function () {
   console.log("Eigene Einträge Click");
    refreshVerlauf(nameKlasse);
});

$("#lernfelderFilter").change(function () {
    console.log("Filter Lernfelder =" + $(this).val());
    refreshVerlauf(nameKlasse);
});

$("#emailZurueck").click(function () {
    var found = false;
    console.log("email zurück index=" + indexFehlzeiten);
    for (var i = indexFehlzeiten - 1; i >= 0 && !found; i--) {
        var anwesenheitEintrag = anwesenheit[i];
        if (anwesenheitEintrag.summeFehltage != undefined && anwesenheitEintrag.summeFehltage != 0) {
            console.log("Summe Fehltage = " + anwesenheitEintrag.summmeFehltag);
            generateMailForm(anwesenheitEintrag);
            indexFehlzeiten = i;
            found = true;
        }
    }
    console.log("Found a Item:" + found);

    if (!found) {
        toastr["warning"]("kein weiterer Fehlzeiteneintrag gefunden!", "Warnung!");

    }
})
$("#emailWeiter").click(function () {
    var found = false;
    console.log("email weiter index=" + indexFehlzeiten);
    for (var i = indexFehlzeiten + 1; i < anwesenheit.length && !found; i++) {
        var anwesenheitEintrag = anwesenheit[i];
        if (anwesenheitEintrag.summeFehltage != undefined && anwesenheitEintrag.summeFehltage != 0) {
            console.log("Summe Fehltage = " + anwesenheitEintrag.summmeFehltag);
            generateMailForm(anwesenheitEintrag);
            indexFehlzeiten = i;
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
    console.log("--> Hochladen des Bildes für Schüler id=" + idSchueler);
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
                getSchuelerBild(idSchueler, "#infoBild");
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

$("#filter1").change(function () {
    console.log("Filter change ID=" + $('option:selected', this).attr('filter_id'));
    refreshAnwesenheit(nameKlasse);
});

$("#filter2").change(function () {
    console.log("Filter change ID=" + $('option:selected', this).attr('filter_id'));
    refreshAnwesenheit(nameKlasse);
});


$('#anwesenheitTabs').on('shown.bs.tab', function (e) {
    console.log("anwesenheitsTab shown " + $(e.target).text());
    updateCurrentView();
});
$('#fehlzeitenTab').on('shown.bs.tab', function (e) {
    console.log("fehlzeitenTab shown " + $(e.target).text());
    updateCurrentView();
});
$('#plaene').on('shown.bs.tab', function (e) {
    console.log("plaene shown " + $(e.target).text());
    updateCurrentView();
});
$('#klassenTabs').on('shown.bs.tab', function (e) {
    console.log("KlassenTab shown " + $(e.target).text());
    updateCurrentView();
});
$("#updateKlassenBem").click(function () {
    setKlassenBemerkungen(idKlasse);
});

$('#notenTabs').on('shown.bs.tab', function (e) {
    console.log("New NavNoten Target =" + $(e.target).text());
    updateCurrentView();
});

$('#navTabs').on('shown.bs.tab', function (e) {
    console.log("New Nav Target =" + $(e.target).text());
    updateCurrentView();
});


$("#absendenEMailBetrieb").click(function () {
    console.log("subject mail  length =" + $("#emailBetriebInhalt").val().length + " from " + $("#fromLehrerBetriebMail").val() + " to:" + $("#toBetriebMail").val());
    mails = $("#emailsBetrieb").val().split(";");
    error = false;
    for (i = 0; i < mails.length - 1; i++) {
        console.log("Teste email:" + mails[i]);
        if (!isValidEmailAddress(mails[i])) {
            toastr["warning"]("Keine gültige EMail Adresse!" + mails[i], "Mail Service");
            error = true;
        }
    }
    if (error == true) {

    }
    else if (!isValidEmailAddress($("#fromLehrerBetriebMail").val())) {
        toastr["warning"]("Keine gültige Absender EMail Adresse!" + $("#fromLehrerBetriebMail").val(), "Mail Service");
        //event.preventDefault();
    }
    else if (!isValidEmailAddress($("#toBetriebMail").val())) {
        toastr["warning"]("Keine gültige Adress EMail Adresse!" + $("#toBetriebMail").val(), "Mail Service");
        //event.preventDefault();
    }

    else if ($("#emailBetriebBetreff").val().length == 0) {
        toastr["warning"]("Kein Betreff angegeben!", "Mail Service");
        //event.preventDefault();
    }
    else if ($("#emailBetriebInhalt").val().length == 0) {
        toastr["warning"]("Kein EMail Inhalt angegeben!", "Mail Service");
        //event.preventDefault();
    }
    else {
        toastr["success"]("EMail wird versendet via BCC an Betriebe", "Mail Service");
        $.post('../MailServlet', $('#emailFormBetriebe').serialize());
        $("#emailBetriebBetreff").val("");
        $("#emailBetriebInhalt").val("");
    }

});

$("#absendenEMailSchueler").click(function (event) {
    console.log("subject mail  length =" + $("#emailSchuelerInhalt").val().length + " from " + $("#fromLehrerMail").val() + " to:" + $("#toSchuelerMail").val());
    if (!isValidEmailAddress($("#fromLehrerMail").val())) {
        toastr["warning"]("Keine gültige Absender EMail Adresse!" + $("#fromLehrerMail").val(), "Mail Service");
        //event.preventDefault();
    }
    else if (!isValidEmailAddress($("#toSchuelerMail").val())) {
        toastr["warning"]("Keine gültige Adress EMail Adresse!" + $("#toSchuelerMail").val(), "Mail Service");
        //event.preventDefault();
    }
    else if ($("#emailSchuelerBetreff").val().length == 0) {
        toastr["warning"]("Kein Betreff angegeben!", "Mail Service");
        //event.preventDefault();
    }
    else if ($("#emailSchuelerInhalt").val().length == 0) {
        toastr["warning"]("Kein EMail Inhalt angegeben!", "Mail Service");
        //event.preventDefault();
    }
    else {
        toastr["success"]("EMail wird versendet an " + $("#toSchuelerMail").val(), "Mail Service");
        $('#mailSchueler').modal('hide');
        //$("#emailFormSchueler").ajaxSubmit({url: '/Diklabu/MailServlet', type: 'post'})
        $.post('../MailServlet', $('#emailFormSchueler').serialize());
    }
});

$("#emailForm").submit(function (event) {
    console.log("subject mail length =" + $("#subjectMail").val().length);

    if (!isValidEmailAddress($("#fromMail").val())) {
        toastr["warning"]("Keine gültige Absender EMail Adresse!", "Mail Service");
        event.preventDefault();
    }
    else if (!isValidEmailAddress($("#toMail").val())) {
        toastr["warning"]("Keine gültige Adress EMail Adresse!", "Mail Service");
        event.preventDefault();
    }
    else if ($("#subjectMail").val().length == 0) {
        toastr["warning"]("Kein Betreff angegeben!", "Mail Service");
        event.preventDefault();
    }
    else if ($("#emailBody").val().length == 0) {
        toastr["warning"]("Kein EMail Inhalt angegeben!", "Mail Service");
        event.preventDefault();
    }
    else {
        toastr["success"]("EMail wird versendet an " + $("#toMail").val() + "! Bitte warten auf den Bericht.", "Mail Service");
        return;
    }

});


$('body').on('keydown', "#kennwort", function (e) {
    var keyCode = e.keyCode || e.which;
    //console.log("key Pressed" + keyCode);
    if (keyCode == 13) {
        console.log("key Down Kennwort");
        performLogin();
    }
});
$("#login").click(function () {
    performLogin();
});


/*
 * Bemerkungen eintragen
 */
$('body').off('keydown', ".bemerkung");
$("body").on('keydown', ".bemerkung", function (e) {
    var keyCode = e.keyCode || e.which;
    if (keyCode == 13) {
        var sid = $(this).attr("sid");
        var eintr = {
            "id": parseInt(sid),
            "info": $(this).val()
        };
        console.log("Sende Bemerkung " + JSON.stringify(eintr));
        $.ajax({
            url: SERVER + "/Diklabu/api/v1/schueler/" + sid,
            type: "POST",
            cache: false,
            data: JSON.stringify(eintr),
            headers: {
                "service_key": sessionStorage.service_key,
                "auth_token": sessionStorage.auth_token
            },
            contentType: "application/json; charset=UTF-8",
            success: function (data) {
                console.log("Empfange " + JSON.stringify(data));
                $("#bem" + data.id).val(data.info);
            },
            error: function (xhr, textStatus, errorThrown) {
                toastr["error"]("kann Bemerkungen nicht Eintragen! Status Code=" + xhr.status, "Fehler!");
            }
        });
    }
});




var oldText = "";


/**
 * Je nach eingaben in der Tabelle werden andere Elemente aktiviert bzw. die 
 * Daten zum Server übertrageb (z.B. bei TAB)
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
            if (inputTd.attr("bem") != undefined) {
                inputTd.append('<a href="#" data-toggle="tooltip" title="' + sessionStorage.myself + ' - ' + inputTd.attr("bem") + '">' + txt + '&nbsp;<img src="../img/flag.png"></a>');
            }
            else {
                inputTd.append('<a href="#" data-toggle="tooltip" title="' + sessionStorage.myself + '">' + txt + '</a>');
            }
            anwesenheitsEintrag(inputTd, txt);
        }
        else {
            if (inputTd.attr("bem") != undefined) {
                inputTd.append('<a href="#" data-toggle="tooltip" title="' + sessionStorage.myself + ' - ' + inputTd.attr("bem") + '">' + oldText + '&nbsp;<img src="../img/flag.png"></a>');
            }
            else {
                inputTd.append('<a href="#" data-toggle="tooltip" title="' + sessionStorage.myself + '">' + oldText + '</a>');
            }
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



// Neues Lernfeld für Noteneintrag
$("#notenlernfelder").change(function () {
    lfid = $('option:selected', this).attr("lfid");
    console.log("Noten Lernfelder changed to " + $("#notenlernfelder").val() + " id=" + lfid);
    getNoten(nameKlasse, function (data) {
        for (k = 0; k < schueler.length; k++) {
            sch = schueler[k];
            note = findNote(sch.id, lfid);
            if (note != undefined) {
                $("#No" + sch.id).val(note.WERT);
                if (note.ID_LK == sessionStorage.myself) {
                    $("#No" + sch.id).removeAttr("disabled");
                }
                else {
                    $("#No" + sch.id).attr("disabled", "disabled");
                }

            }
            else {
                $("#No" + sch.id).removeAttr("disabled");
                $("#No" + sch.id).val("");
            }
        }

    });
});

// Neue Note Eintragen
$('body').on('keydown', ".notenTextfeld", function (e) {
    var keyCode = e.keyCode || e.which;
    console.log("keycode=" + keyCode);
    if (keyCode == 13 || keyCode == 9) {
        $(this).blur();
    }
});
$('body').on('focusout', ".notenTextfeld", function (e) {
    console.log("focus out");
    if ($(this).val() != "") {
        submitNote(lfid, $(this).attr("sid"), $(this).val());
    }
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

function getKlassenliste(callback) {
// Klassenliste vom Server laden
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
            callback();
        },
        error: function () {
            toastr["error"]("kann Klassenliste nicht vom Server laden", "Fehler!");
        }
    });
}

function getFilter(callback) {
// Klassenliste vom Server laden
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/noauth/termine",
        type: "GET",
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            $("#filter1").empty();
            $("#filter2").empty();
            $("#filter1").append('<option filter_id="0">alle</option');
            $("#filter2").append('<option filter_id="0">alle</option');
            for (i = 0; i < data.length; i++) {
                $("#filter1").append('<option filter_id="' + data[i].id + '">' + data[i].NAME + '</option');
                $("#filter2").append('<option filter_id="' + data[i].id + '">' + data[i].NAME + '</option');
            }
            if (callback != undefined) {
                callback(data);
            }
        },
        error: function () {
            toastr["error"]("kann Filter nicht vom Server laden", "Fehler!");
        }
    });
}

function getLernfelder(callback) {
// Lernfelder vom Server laden
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/noauth/lernfelder",
        type: "GET",
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            $("#lernfelder").empty();
            $("#lernfelderFilter").empty();
            $("#lernfelderFilter").append("<option lfid='-1'>alle</option>");
            for (i = 0; i < data.length; i++) {
                if (data[i].BEZEICHNUNG != undefined) {
                    $("#lernfelder").append("<option dbid='" + data[i].id + "'>" + data[i].BEZEICHNUNG + "</option>");
                    $("#notenlernfelder").append("<option lfid='" + data[i].id + "'>" + data[i].BEZEICHNUNG + "</option>");
                    $("#lernfelderFilter").append("<option lfid='" + data[i].id + "'>" + data[i].BEZEICHNUNG + "</option>");

                }
            }
            callback();
        },
        error: function () {
            toastr["error"]("kann Lernfelder nicht vom Server laden", "Fehler!");
        }
    });
}


/**
 * Noten der Klassen vom Server laden
 * @param {type} kl Name der Klasse
 * @param {type} callback optionales Callback
 */
function getNoten(kl, callback) {
    console.log("--> Noten der Klasse kl=" + kl + " laden!");
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/noten/" + kl,
        type: "GET",
        cache: false,
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            console.log("Noten empfangen!");
            notenliste = data;

            if (callback != undefined) {
                callback(data);
            }

        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("Kann Noten der Klasse " + kl + " nicht vom Server laden!", "Fehler!");
        }
    });
}


/**
 * Details zu einem Lehrer abfragen
 * @param {type} id die Lehrer ID
 */
function getLehrerData(id, callback) {
    console.log("Get LehrerData " + id);
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
            if (callback != undefined) {
                callback(data);
            }
        },
        error: function () {
            toastr["error"]("kann Lehrerdaten nicht vom Server laden", "Fehler!");
        }
    });
}


/**
 * Sendet einen Anwesenheitseintrag zum Server
 * @param {type} eintr Der Anwesenheitseintrag
 * @param {type} success Callback für Success 
 */
function submitAnwesenheit(eintr, success) {
    console.log("--> Sende Anwesenheit zum Server:" + JSON.stringify(eintr));
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
            if (success != undefined) {
                success(data);
            }
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("kann Anwesenheitseintrag nicht zum Server senden! Status Code=" + xhr.status, "Fehler!");
        }
    });

}

/**
 * Verlauf einer Klasse vom Server laden und eintragen
 * @param {type} kl die Klassenbezeichnung
 */
function refreshVerlauf(kl) {
    console.log("--> Refresh Verlauf f. Klasse " + kl + " von " + $("#startDate").val() + " bis " + $("#endDate").val());
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
            console.log("Filter eigene Einträege="+$("#eigeneEintraege").is(':checked'));
            for (i = 0; i < data.length; i++) {
                var datum = data[i].wochentag + " " + data[i].DATUM;
                datum = datum.substring(0, datum.indexOf('T'));
                if (data[i].ID_LEHRER == sessionStorage.myself) {
                    if ($("#lernfelderFilter").val()=="alle" || $("#lernfelderFilter").val()==data[i].ID_LERNFELD) {
                        $("#tabelleVerlauf").append("<tr dbid='" + data[i].ID + "' index='" + i + "' class='success'><td>" + datum + "</td><td>" + data[i].ID_LEHRER + "</td><td>" + data[i].ID_LERNFELD + "</td><td>" + data[i].STUNDE + "</td><td>" + data[i].INHALT + "</td><td>" + data[i].BEMERKUNG + "</td><td>" + data[i].AUFGABE + "</td></tr>");
                    }
                }
                else {
                    if ($("#eigeneEintraege").is(':checked')) {
                        
                    }
                    else {
                        if ($("#lernfelderFilter").val()=="alle" || $("#lernfelderFilter").val()==data[i].ID_LERNFELD) {
                            $("#tabelleVerlauf").append("<tr dbid='" + data[i].ID + "' index='" + i + "' ><td>" + datum + "</td><td>" + data[i].ID_LEHRER + "</td><td>" + data[i].ID_LERNFELD + "</td><td>" + data[i].STUNDE + "</td><td>" + data[i].INHALT + "</td><td>" + data[i].BEMERKUNG + "</td><td>" + data[i].AUFGABE + "</td></tr>");
                        }
                    }
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


/**
 * Bemerkungen einer Klasse abfragen
 * @param {type} klid Die id der Klasse
 */
function getKlassenBemerkungen(klid) {
    console.log("--> get Klassenbemerkungen f. Klasse " + klid);

    $.ajax({
        url: SERVER + "/Diklabu/api/v1/klasse/details/" + klid,
        type: "GET",
        cache: false,
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            $("#klassenbem").val(data.NOTIZ);
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("kann Bemerkungen der Klasse " + kl + " nicht vom Server laden! Status Code=" + xhr.status, "Fehler!");
        }
    });
}

/**
 * Klassenbemerkungen einer Klasse eintragen
 * @param {type} klid die ID der Klasse
 */
function setKlassenBemerkungen(klid) {
    console.log("--> set Klassenbemerkungen f. Klasse " + klid);

    var eintr = {
        "NOTIZ": $("#klassenbem").val()
    }

    $.ajax({
        url: SERVER + "/Diklabu/api/v1/klasse/details/" + klid,
        type: "POST",
        data: JSON.stringify(eintr),
        cache: false,
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            toastr["info"]("Bemerkung aktualisiert!", "Info!");
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("kann Bemerkungen der Klasse " + kl + " nicht vom Server laden! Status Code=" + xhr.status, "Fehler!");
        }
    });
}

/**
 * Schülerbemerkungen eine Klasse laden
 * @param {type} kl Der Name der Klasse
 */
function refreshBemerkungen(kl) {
    console.log("-->  Bemerkungen f. Klasse " + kl);

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
            for (i = 0; i < data.length; i++) {
                $("#bem" + data[i].ID_SCHUELER).val(data[i].INFO);
            }
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("kann Bemerkungen der Klasse " + kl + " nicht vom Server laden! Status Code=" + xhr.status, "Fehler!");
        }
    });
}

/**
 * Eintragen einer Note
 * @param {type} lf Lernfeld
 * @param {type} ids Schüler ID
 * @param {type} wert Wert des Eintrages (z.B. Note)
 */
function submitNote(lf, ids, wert) {
    console.log("--> SubmitNote lf=" + lf + " ID_Schueler=" + ids + " Wert=" + wert);
    var eintr = {
        "ID_LERNFELD": lf,
        "ID_LK": sessionStorage.myself,
        "ID_SCHUELER": ids,
        "WERT": wert
    }

    $.ajax({
        url: SERVER + "/Diklabu/api/v1/noten",
        type: "POST",
        data: JSON.stringify(eintr),
        cache: false,
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {

        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("Kann Note nicht eintragen! Status Code=" + xhr.status, "Fehler!");
        }
    });
}

function getTermindaten(callback) {
    console.log("--> Get Termindaten Filter1 ID=" + $('option:selected', "#filter1").attr('filter_id') + " Filter2 ID=" + $('option:selected', "#filter2").attr('filter_id'));
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/noauth/termine/" + $("#startDate").val() + "/" + $("#endDate").val() + "/" + $('option:selected', "#filter1").attr('filter_id') + "/" + $('option:selected', "#filter2").attr('filter_id'),
        type: "GET",
        cache: false,
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            if (callback != undefined) {
                callback(data);
            }
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("kann Termindaten nicht vom Server laden! Status Code=" + xhr.status, "Fehler!");
        }
    });
}

/**
 * Anwesenheitstabelle aktualisieren
 * @param {type} kl die Klasse
 * @param {type} callback optional ein Callback
 */
function refreshAnwesenheit(kl, callback) {

    console.log("--> Refresh Anwesenheit f. Klasse " + kl + " von " + $("#startDate").val() + " bis " + $("#endDate").val());
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
            console.log("anwesenheit empfangen!");
            buildeAnwesenheitstabelle(data);
            // Eventhandler auf einen anwesenheitseintrag
            $(".anwesenheitsPopup").hover(function () {
                //alert("popup anzeigen");
            }, function () {

            });

            if (callback != undefined) {
                callback();
            }

        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("kann Anwesenheit der Klasse " + kl + " nicht vom Server laden! Status Code=" + xhr.status, "Fehler!");
        }
    });
}

/**
 * Laden und Anzeigen eines Schülerbildes vom Server
 * @param {type} id id des Schülers
 * @param {type} elem Element im dem das Bild angezeigt werden soll (als attr 'src')
 */
function getSchuelerBild(id, elem) {
    console.log("--> Lade Schülerbild vom Schüler mit der id=" + id);
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/schueler/bild/" + id,
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
                        url: SERVER + "/Diklabu/api/v1/schueler/bild64/" + id,
                        type: "GET",
                        headers: {
                            "service_key": sessionStorage.service_key,
                            "auth_token": sessionStorage.auth_token
                        },
                        success: function (data) {
                            console.log("Bild Daten geladen:" + data.id + " elem=" + elem);
                            data = data.base64.replace(/(?:\r\n|\r|\n)/g, '');
                            $(elem).attr('src', "data:image/png;base64," + data);

                        },
                        error: function () {
                            toastr["error"]("kann Schülerbild ID=" + id + " nicht vom Server laden", "Fehler!");
                        }
                    });

                }
    });
}

/**
 * Betriebsliste einer Klasse vom Server laden
 * @param {type} kl Der Name der Klasse
 * @param {type} callback optionales Callback
 */
function getBetriebe(kl, callback) {
    console.log("--> Get Betriebe f. Klasse " + kl);
    nameKlasse = kl;
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/klasse/betriebe/" + kl,
        type: "GET",
        cache: false,
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            $("#tabelleBetriebe").empty();
            betriebe = data;
            console.log("<--- empfangen: Betriebe!");
            for (k = 0; k < data.length; k++) {
                var s = findSchueler(data[k].id_schueler);
                $("#tabelleBetriebe").append('<tr><td><img src="../img/Info.png" ids="' + data[k].id_schueler + '" class="infoIcon"> ' + s.VNAME + " " + s.NNAME + '</td><td>' + data[k].name + '</td><td>' + data[k].nName + '</td><td><a href="mailto:"' + data[k].email + '>' + data[k].email + '</a>&nbsp;<img aemail="' + data[k].email + '" aname="' + data[k].nName + '" src="../img/mail.png" class="mailBetrieb"></td><td>' + data[k].telefon + '</td><td>' + data[k].fax + '</td></tr>');
            }
            if (callback != undefined) {
                callback(data);
            }
            getSchuelerInfo();

        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("kann SBetriebe der Klasse " + kl + " nicht vom Server laden! Status Code=" + xhr.status, "Fehler!");
        }
    });

}

/**
 * Schülerdaten vom Server laden
 * @param {type} id ID des Schülers
 * @param {type} callback Callback
 */
function loadSchulerDaten(id, callback) {
    console.log("--> loadSchuelerData id=" + id);
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
 * Schülerbilder eine Klasse las Base64 laden
 * @param {type} kl der Klassenname
 */
function getBildKlasse(kl) {
    console.log("--> Lade Bider der Klasse " + kl);
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/klasse/" + kl + "/bilder64/150",
        cache: false,
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        type: 'GET',
        error: function () {
            toastr["error"]("kann Bilder der Klasse " + kl + " nicht vom Server laden", "Fehler!");
        },
        success:
                function (data) {
                    console.log("Bilder der Klasse " + kl + " geladen");

                    for (i = 0; i < data.length; i++) {
                        b64 = data[i].base64;
                        if (b64 != undefined) {
                            b64 = b64.replace(/(?:\r\n|\r|\n)/g, '');
                            $("#bild" + data[i].id).attr('src', "data:image/png;base64," + b64);
                        }
                    }
                }
    });
}



/**
 * Ermittelt welchet Tab gerade geöffnet ist (nur diese Daten müssen nachgeladen werden!)
 * @returns Name des Tabs
 */
function getCurrentView() {
    target = $("ul#navTabs li.active").text();
    console.log("get Current View Base target=(" + target + ")");
    if (target == "Anwesenheit") {
        sub = $("ul#anwesenheitTabs li.active").text();
        return sub;
    }
    if (target == "Fehlzeiten") {
        sub = $("ul#fehlzeitenTab li.active").text();
        return sub;
    }
    if (target == "Noten") {
        sub = $("ul#notenTabs li.active").text();
        return sub;
    }
    if (target == "Klasse") {
        sub = $("ul#klassenTabs li.active").text();
        return sub;
    }
    if (target == "Pläne") {
        sub = $("ul#plaene li.active").text();
        return sub;
    }
    return target;
}

/**
 * Suchen einer Note
 * @param {type} ids ID des Schülers
 * @param {type} idlf ID des Lernfeldes
 * @returns {note|no} Note oder undefined wenn nichts gefunden wurde
 */
function findNote(ids, idlf) {
    for (n = 0; n < notenliste.length; n++) {
        eintr = notenliste[n];
        if (eintr.schuelerID == ids) {
            no = eintr.noten;
            for (m = 0; m < no.length; m++) {
                note = no[m];
                if (note.ID_LERNFELD == idlf) {
                    return note;
                }
            }
        }
    }
    return undefined;
}

/**
 * Stundenplan (HTML) der Klasse Abfragen und anzeigen
 */
function loadStundenPlan() {
    console.log("Lade Stundenplan der Klasse " + nameKlasse);
    $("#stundenplan").load(SERVER + "/Diklabu/api/v1/noauth/plan/stundenplan/" + nameKlasse, function (response, status, xhr) {
        console.log("Stundenplan Status=" + status);
        if (status == "nocontent") {
            console.log("Kann Stundenplan der Klasse " + nameKlasse + " nicht laden!")
            $("#stundenplan").empty();
            $("#stundenplan").append('<div><center><h1>Kann Stundenplan der Klasse ' + nameKlasse + ' nicht finden</h1></center></div>');
        }
    });
}

/**
 * Vertretungsplan (HTML) der Klasse Abfragen und anzeigen
 */
function loadVertertungsPlan() {
    console.log("Lade Vertretungsplan der Klasse " + nameKlasse);
    $("#vertertungsplan").load(SERVER + "/Diklabu/api/v1/noauth/plan/vertertungsplan/" + nameKlasse, function (response, status, xhr) {
        console.log("Vertretungsplan Status=" + status);
        if (status == "nocontent") {
            console.log("Kann Vertertungsplan der Klasse " + nameKlasse + " nicht laden!")
            $("#vertertungsplan").empty();
            $("#vertertungsplan").append('<div><center><h1>Kann Vertertungsplan der Klasse ' + nameKlasse + ' nicht finden</h1></center></div>');
        }
    });
}

/**
 * Stundenplan des Lehrers anzeigen
 */
function loadStundenPlanLehrer() {
    console.log("Lade Stundenplan für " + sessionStorage.lehrerNNAME);
    getLehrerData(sessionStorage.myself, function (data) {
        $("#lstundenplan").load(SERVER + "/Diklabu/api/v1/noauth/plan/stundenplanlehrer/" + sessionStorage.lehrerNNAME, function (response, status, xhr) {
            console.log("Stundenplan Lehere Status=" + status);
            if (status == "nocontent") {
                console.log("Kann Stundenplan für Lehrer nicht laden");
                $("#lstundenplan").empty();
                $("#lstundenplan").append('<div><center><h1>Kann Stundenplan für ' + sessionStorage.lehrerNNAME + ' nicht finden</h1></center></div>');
            }
        });

    });
}

/**
 * Vertretungsplan des Lehrers anzeigen
 */
function loadVertretungsPlanLehrer() {
    console.log("Lade Vertretungsplan für " + sessionStorage.lehrerNNAME);
    getLehrerData(sessionStorage.myself, function (data) {
        $("#lvertertungsplan").load(SERVER + "/Diklabu/api/v1/noauth/plan/vertretungsplanlehrer/" + sessionStorage.lehrerNNAME, function (response, status, xhr) {
            console.log("Vertretungsplan Lehrer Status=" + status);
            if (status == "nocontent") {
                console.log("Kann Stundenplan für Lehrer nicht laden");
                $("#lvertertungsplan").empty();
                $("#lvertertungsplan").append('<div><center><h1>Kann Vertretungsplan für ' + sessionStorage.lehrerNNAME + ' nicht finden</h1></center></div>');
            }
        });

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

function showContainer(b) {
    if (b) {
        $("#kuerzelContainer").hide();
        $("#kennwortContainer").hide();
        $("#tabelle").show();
        $("#inputVerlaufContainer").show();
        $("#tabelleKlasse").show();
        $("#tabelleAnwesenheit").show();
        $("#tabelleFehlzeiten").show();
        $("#chatContainer").show();
        $("#tabChat").show();
        $("#bemerkungContainer").show();
        $("#betriebeContainer").show();
        $("#klassenTabs").show();
        $("#fehlzeitenTab").show();
        $("#anwesenheitTabs").show();
        $("#notenTabs").show();
        $("#tabNoteneintrag").show();
        $("#emailBetriebeContainer").show();
        $("#klassenBemerkungContainer").show();
        $("#plaene").show();
        $("#lvertertungsplan").show();
        $("#lstundenplan").show();
        $("#stundenplan").show();
        $("#vertertungsplan").show();
    }
    else {
        $("#kuerzelContainer").show();
        $("#kennwortContainer").show();
        $("#tabelle").hide();
        $("#inputVerlaufContainer").hide();
        $("#tabelleKlasse").hide();
        $("#tabelleAnwesenheit").hide();
        $("#tabelleFehlzeiten").hide();
        $("#chatContainer").hide();
        $("#tabChat").hide();
        $("#bemerkungContainer").hide();
        $("#betriebeContainer").hide();
        $("#klassenTabs").hide();
        $("#fehlzeitenTab").hide();
        $("#anwesenheitTabs").hide();
        $("#notenTabs").hide();
        $("#tabNoteneintrag").hide();
        $("#emailBetriebeContainer").hide();
        $("#klassenBemerkungContainer").hide();
        $("#tabMail").hide();
        $("#plaene").hide();
        $("#lvertertungsplan").hide();
        $("#lstundenplan").hide();
        $("#stundenplan").hide();
        $("#vertertungsplan").hide();
    }
}

/**
 * GUI Vorbereiten wenn Nutzer ausgeloggt ist
 */
function loggedOut() {
    showContainer(false);
    $('#startDate').datepicker().off('changeDate');
    $('#endDate').datepicker().off('changeDate');
    $("#klassen").unbind();
    $("#dokumentation").unbind();
    $("#login").removeClass("btn-danger");
    $("#login").addClass("btn-success");
    $("#login").text("Login");
    $("#dokumentation").addClass("disabled");
    chatDisconnect();
    $("tbody").empty();
    sessionStorage.clear();
    schueler = undefined;
    $("#trNoten").empty();
}

/**
 * GUI vorbereiten wenn Nutzer eingeloggt ist 
 */
function loggedIn() {
    showContainer(true);
    $("#login").removeClass("btn-success");
    $("#login").addClass("btn-danger");
    $("#login").text("Logout " + sessionStorage.myself);
    $("#dokumentation").removeClass("disabled");
    $('#startDate').datepicker().on('changeDate', function (ev) {
        $("#from").val($("#startDate").val());
        updateCurrentView();
    });
    $('#endDate').datepicker().on('changeDate', function (ev) {
        $("#to").val($("#endDate").val());
        updateCurrentView();
    });
    $("#klassen").change(function () {
        console.log("Klassen change ID=" + $('option:selected', this).attr('dbid') + " KNAME=" + $("#klassen").val());
        console.log("Current View =" + getCurrentView());
        idKlasse = $('option:selected', this).attr('dbid');
        nameKlasse = $("#klassen").val();
        $("#idklasse").val(idKlasse);
        updateCurrentView();
    });
    //$("#klassen").val(nameKlasse);
    $("#auth_token").val(sessionStorage.auth_token);
    $("#service_key").val(sessionStorage.service_key);
    $("#idklasse").val(idKlasse);
    $("#from").val($("#startDate").val());
    $("#to").val($("#endDate").val());
    chatConnect();
}

/**
 * Anwesenheit eintragen
 * @param {type} td das gewählte td Element
 * @param {type} txt Der Text für den Vermerk
 */
function anwesenheitsEintrag(td, txt) {
    var id = td.attr("id");
    var dat = id.substring(id.indexOf("_") + 1);
    var sid = id.substring(0, id.indexOf("_"));
    if (td.attr("bem") != undefined) {
        var eintr = {
            "DATUM": dat + "T00:00:00",
            "ID_LEHRER": sessionStorage.myself,
            "ID_SCHUELER": parseInt(sid),
            "VERMERK": txt,
            "BEMERKUNG": td.attr("bem")
        };
    }
    else {
        var eintr = {
            "DATUM": dat + "T00:00:00",
            "ID_LEHRER": sessionStorage.myself,
            "ID_SCHUELER": parseInt(sid),
            "VERMERK": txt
        };

    }

    submitAnwesenheit(eintr, function (data) {
        if (data.parseError) {
            toastr["warning"]("Der Eintrag enthält Formatierungsfehler!", "Warnung!");
            td.addClass("parseError");
        }
        else {
            td.removeClass("parseError");
        }

    });
}

/**
 * Erzeugen der Anwesenheitstabelle
 */
function generateAnwesenheitsTable(termine) {
    var tab = "";
    for (var i = 0; i < schueler.length; i++) {
        tab += "<tr>";

        for (j = 0; j < termine.length; j++) {
            termin = new Date(termine[j].milliseconds);
            if (termin.getDay() == 0 || termin.getDay() == 6) {
                tab += "<td class=\"anwesenheit wochenende\" align=\"center\" index=\"" + i + "\" id=\"" + schueler[i].id + "_" + toSQLString(termin) + "\" >&nbsp;</td>";
            }
            else {
                tab += "<td class=\"anwesenheit\" align=\"center\" index=\"" + i + "\" id=\"" + schueler[i].id + "_" + toSQLString(termin) + "\" >&nbsp;</td>";
            }
        }
        tab += '</tr>';
    }
    $("#tabelleAnwesenheit").append(tab);
    $(".anwesenheit").click(function () {
        console.log("input Visible=" + inputVisible);
        oldText = $(this).text();
        if (!inputVisible) {
            inputTd = $(this);
            console.log("Bemerkung = " + inputTd.attr("bem"));
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
 * Erzeugen der Fehlzeitentabelle 
 */
function generateVerspaetungen() {
    console.log("Generate Verspaetungen");
    $("#verspaetungenTabelle").empty();
    for (var i = 0; i < anwesenheit.length; i++) {
        if (anwesenheit[i].summeFehltage != 0 || anwesenheit[i].anzahlVerspaetungen != 0 || anwesenheit[i].parseErrors.length != 0) {
            var tr = "<tr>";
            tr += "<td><img src=\"../img/Info.png\" ids=\"" + anwesenheit[i].id_Schueler + "\" class=\"infoIcon\"> " + getNameSchuler(anwesenheit[i].id_Schueler) + "</td>";
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


    getSchuelerInfo();

}

function createMailForm() {
    // Mail Form f. Fehltage aktualisieren
    console.log("Create Mail Form anwesenheit.length=" + anwesenheit.length);
    var found = false;
    for (var i = 0; i < anwesenheit.length && !found; i++) {
        var anwesenheitEintrag = anwesenheit[i];
        if (anwesenheitEintrag.summeFehltage != undefined && anwesenheitEintrag.summeFehltage != 0) {
            console.log("Summe Fehltage = " + anwesenheitEintrag.summmeFehltage);
            generateMailForm(anwesenheitEintrag);
            indexFehlzeiten = i;
            found = true;
        }
    }
    console.log("Found a Item:" + found);

    if (!found)
        emptyMailForm();
}


/**
 * Schülernamen anhand seiner ID ermitteln
 * @param {type} id die Schüler ID
 * @returns {String} Der  Vor und Nachname des Schülers
 */
function getNameSchuler(id) {
    for (var i = 0; i < schueler.length; i++) {
        if (schueler[i].id == id) {
            console.log("Found Name for ID " + id + " " + schueler[i].VNAME + " " + schueler[i].NNAME)
            return schueler[i].VNAME + " " + schueler[i].NNAME;
        }
    }
    return "unknown ID " + id;
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
        console.log("lade Schuler ID=" + idSchueler);
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
        console.log("mail to Schüler with id=" + $(this).attr("ids"));
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
        console.log("mail to Betrieb to=" + $(this).attr("aemail"));
        $("#mailName").text($(this).attr("aname"));
        $("#mailSAdr").text($(this).attr("aemail"));
        $("#fromLehrerMail").val(sessionStorage.myemail)
        $("#toSchuelerMail").val($(this).attr("aemail"));
        $("#emailSchuelerBetreff").val('');
        $("#emailSchuelerInhalt").val('');
        $('#mailSchueler').modal('show');
    });
}

/**
 * Noten in Noteneintrag eintragen
 * @param {type} data NotenObjekt
 */
function buildNoteneintrag(data) {
    console.log("Build Noteneintrag schueler.length=" + schueler.length);
    $("#tbodyNoteneintrag").empty();
    lfid = $('option:selected', "#notenlernfelder").attr("lfid");
    console.log("lfid=" + lfid);
    for (i = 0; i < schueler.length; i++) {
        $("#tbodyNoteneintrag").append('<tr><td><img src="../img/Info.png" ids="' + schueler[i].id + '" class="infoIcon"> ' + schueler[i].VNAME + " " + schueler[i].NNAME + '</td><td><input type="text" name="No' + schueler[i].id + '" id="No' + schueler[i].id + '" sid="' + schueler[i].id + '" class="form-control notenTextfeld" disabled="disabled"/></td></tr>')
    }

    for (k = 0; k < schueler.length; k++) {
        sch = schueler[k];
        note = findNote(sch.id, lfid);
        if (note != undefined) {
            $("#No" + sch.id).val(note.WERT);
            if (note.ID_LK == sessionStorage.myself) {
                $("#No" + sch.id).removeAttr("disabled");
            }
            else {
                $("#No" + sch.id).attr("disabled", "disabled");
            }

        }
        else {
            $("#No" + sch.id).removeAttr("disabled");
            $("#No" + sch.id).val("");
        }
    }
    getSchuelerInfo();
}

/**
 * Login durchführen
 */
function performLogin() {
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

                if (jsonObj.role == "Schueler") {
                    window.location.replace("index.html");
                }
                else {

                    sessionStorage.auth_token = jsonObj.auth_token;
                    console.log("Thoken = " + jsonObj.auth_token);

                    toastr["success"]("Login erfolgreich", "Info!");
                    sessionStorage.myselfplain = idplain;
                    sessionStorage.myself = jsonObj.ID;
                    sessionStorage.myemail = jsonObj.email;
                    getLehrerData(sessionStorage.myself);
                    nameKlasse = $("#klassen").val();
                    idKlasse = $('option:selected', "#klassen").attr('dbid');
                    loggedIn();
                    updateCurrentView();
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
}


/**
 * Überprüft ob die Email eine gültige email Adresse ist
 * @param {type} emailAddress die Email Adresse
 * @returns {Boolean} true=gültig
 */
function isValidEmailAddress(emailAddress) {
    var pattern = /^([a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+(\.[a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+)*|"((([ \t]*\r\n)?[ \t]+)?([\x01-\x08\x0b\x0c\x0e-\x1f\x7f\x21\x23-\x5b\x5d-\x7e\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|\\[\x01-\x09\x0b\x0c\x0d-\x7f\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))*(([ \t]*\r\n)?[ \t]+)?")@(([a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.)+([a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.?$/i;
    return pattern.test(emailAddress);
}

/**
 * Mail Form einträge löschen
 */
function emptyMailForm() {
    $("#emailBody").val("");
    $("#toMail").val("");
    $("#subjectMail").val("");
    $("#emailZurueck").hide();
    $("#emailWeiter").hide();
    $("#emailAbsenden").hide();
}

/**
 * Mail Form erzeugen
 * @param {type} ae Anwesenheitsobjekt 
 */
function generateMailForm(ae) {
    console.log("Generate MAIL FORM");
    $("#emailZurueck").show();
    $("#emailWeiter").show();
    $("#emailAbsenden").show();
    $("#klassenName").val(nameKlasse);
    $("#lehrerId").val(sessionStorage.myself);
    $("#mailauth_token").val(sessionStorage.auth_token);
    $("#mailservice_key").val(sessionStorage.service_key);

    $("#subjectMail").val("MMBbS Fehlzeitenmeldung");

    template = $("#template").text();
    //console.log("Template="+template);
    template = template.replace("[[LEHRER_NNAME]]", sessionStorage.lehrerNNAME);
    template = template.replace("[[LEHRER_EMAIL]]", sessionStorage.lehrerEMAIL);
    template = template.replace("[[ANZAHL_FEHLTAGE]]", ae.summeFehltage);
    var entschuldigt = ae.fehltageEntschuldigt;
    var ent = "";
    for (var i = 0; i < entschuldigt.length; i++) {
        ent += getReadableDate(entschuldigt[i].DATUM) + ",";
    }
    template = template.replace("[[DATUM_ENTSCHULDIGT]]", ent);

    var unentschuldigt = ae.fehltageUnentschuldigt;
    ent = "";
    for (var i = 0; i < unentschuldigt.length; i++) {
        ent += getReadableDate(unentschuldigt[i].DATUM) + ",";
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


/**
 * Laden der Schülerliste (Namensliste) einer Klasse 
 * @param {type} kl die Klasse
 * @param {type} callback Callbackfunktion
 */
function refreshKlassenliste(kl, callback) {
    console.log("--> Refresh Schüler Liste f. Klasse " + kl);
    if (schueler != undefined && schueler.klasse == kl) {
        console.log("Daten bereits vorhanden, kein erneutes Laden!")
        if (callback != undefined) {
            callback(schueler);
        }
    }
    else {
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
                schueler.klasse = kl;
                $("#tabelleKlasse").empty();
                $("#tabelleBemerkungen").empty();
                $("#tabelleKlasse").append('<thead><tr><th ><h3>Name</h3></th></tr></thead>');
                $("#tabelleKlasse").append("<tbody>");
                for (i = 0; i < data.length; i++) {
                    $("#tabelleKlasse").append('<tr><td><img src="../img/Info.png" ids="' + data[i].id + '" class="infoIcon"> ' + data[i].VNAME + " " + data[i].NNAME + '&nbsp;<img src="../img/mail.png" ids="' + data[i].id + '" class="mailIcon"></td></tr>');
                    if (data[i].INFO != undefined) {
                        $("#tabelleBemerkungen").append('<tr><td><img src="../img/Info.png" ids="' + data[i].id + '" class="infoIcon"> ' + data[i].VNAME + " " + data[i].NNAME + '</td><td><input id="bem' + data[i].id + '" sid="' + data[i].id + '" name="' + data[i].id + '" type="text" class="form-control bemerkung" value="' + data[i].INFO + '"></td></tr>');
                    }
                    else {
                        $("#tabelleBemerkungen").append('<tr><td><img src="../img/Info.png" ids="' + data[i].id + '" class="infoIcon"> ' + data[i].VNAME + " " + data[i].NNAME + '</td><td><input id="bem' + data[i].id + '" sid="' + data[i].id + '" name="' + data[i].id + '" type="text" class="form-control bemerkung" value=""></td></tr>');
                    }
                }
                $("#tabelleKlasse").append("</tbody>");
                $("#tabelleBemerkungen").append("</tbody>");
                /*
                 refreshAnwesenheit(nameKlasse, function (data) {
                 renderBilder();
                 });
                 */
                getSchuelerInfo();
                if (callback != undefined) {
                    callback(data);
                }


            },
            error: function (xhr, textStatus, errorThrown) {
                toastr["error"]("kann Schüler der Klasse " + kl + " nicht vom Server laden! Status Code=" + xhr.status, "Fehler!");
            }
        });
    }
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
    console.log("Update Current View = " + view);
    switch (view) {
        case "Verlauf":
            refreshVerlauf(nameKlasse);
            $("#dokumentationType").val("Verlauf");
            $("#dokumentationContainer").show();
            $("#printContainer").hide();
            break;
            // Anwesenheit
        case "Details":
            refreshKlassenliste(nameKlasse, function (data) {
                refreshAnwesenheit(nameKlasse);
            });
            $("#dokumentationType").val("Anwesenheit");
            $("#dokumentationContainer").show();
            $("#printContainer").hide();
            break;
        case "Bilder":
            refreshKlassenliste(nameKlasse, function (data) {
                refreshAnwesenheit(nameKlasse, function () {
                    renderBilder();
                });
            });
            $("#dokumentationContainer").hide();
            $("#printContainer").show();
            break;
            // Fehlzeiten
        case "Übersicht":
            refreshKlassenliste(nameKlasse, function (data) {
                refreshAnwesenheit(nameKlasse, function () {
                    generateVerspaetungen();

                });
            });
            $("#tabMail").hide();
            $("#tabUebersicht").show();
            $("#dokumentationType").val("Fehlzeiten");
            $("#dokumentationContainer").show();
            $("#printContainer").hide();
            break;
        case "Mail":
            refreshKlassenliste(nameKlasse, function (data) {
                refreshAnwesenheit(nameKlasse, function () {
                    createMailForm();
                });
            });
            $("#tabMail").show();
            $("#tabUebersicht").hide();
            $("#dokumentationContainer").hide();
            $("#printContainer").show();
            break;
            // Noten
        case "Notenliste":
            refreshKlassenliste(nameKlasse, function (data) {
                getNoten(nameKlasse, function (data) {
                    buildNotenliste(data);
                });
            });
            $("#tabNoteneintrag").hide();
            $("#tabNotenliste").show();
            $("#dokumentationType").val("Notenliste");
            $("#dokumentationContainer").show();
            $("#printContainer").hide();
            break;
        case "Noteneintrag":
            refreshKlassenliste(nameKlasse, function (data) {
                getNoten(nameKlasse, function (data) {
                    buildNoteneintrag(data);
                });
            });
            $("#tabNoteneintrag").show();
            $("#tabNotenliste").hide();
            $("#dokumentationContainer").hide();
            $("#printContainer").show();
            break;
            // Klasse
        case "Schülerbemerkungen":
            refreshKlassenliste(nameKlasse, function (data) {
                refreshBemerkungen(nameKlasse);
            });
            $("#dokumentationContainer").hide();
            $("#printContainer").show();
            break;
        case "Klassenbemerkung":
            getKlassenBemerkungen(idKlasse);
            $("#dokumentationContainer").hide();
            $("#printContainer").hide();
            break;
        case "Betriebe":
            refreshKlassenliste(nameKlasse, function (data) {
                getBetriebe(nameKlasse);
            });
            $("#dokumentationType").val("Betriebe");
            $("#dokumentationContainer").show();
            $("#printContainer").hide();
            break;
        case "Betriebe anschreiben":
            refreshKlassenliste(nameKlasse, function (data) {
                getBetriebe(nameKlasse, function (data) {
                    updateBetriebeMails();
                });
            });
            $("#dokumentationContainer").hide();
            $("#printContainer").show();
            break;
        case "Pläne":
            loadStundenPlan();
            $("#dokumentationContainer").hide();
            $("#printContainer").show();
            break;
        case "Stundenplan Klasse":
            loadStundenPlan();
            $("#dokumentationContainer").hide();
            $("#printContainer").show();
            break;
        case "Vertretungsplan Klasse":
            loadVertertungsPlan();
            $("#dokumentationContainer").hide();
            $("#printContainer").show();
            break;
        case "Stundenplan Lehrer":
            loadStundenPlanLehrer();
            $("#dokumentationContainer").hide();
            $("#printContainer").show();
            break;
        case "Vertretungsplan Lehrer":
            loadVertretungsPlanLehrer();
            $("#dokumentationContainer").hide();
            $("#printContainer").show();
            break;
        case "Chat":
            $("#dokumentationContainer").hide();
            $("#printContainer").hide();
            break;
    }

}

/**
 * Mail Formular zum Anschreiben der Betriebe aktualisieren
 */
function updateBetriebeMails() {
    var adr = "";
    if (betriebe == undefined) {
        getBetriebe(nameKlasse, function (data) {
            for (i = 0; i < betriebe.length; i++) {
                adr = adr + betriebe[i].email + ";";
            }
            $("#emailsBetrieb").val(adr);
        });
    }
    else {
        //console.log("Betriebe=" + betriebe)
        for (i = 0; i < betriebe.length; i++) {
            adr = adr + betriebe[i].email + ";";
        }
        $("#emailsBetrieb").val(adr);
    }
}

/**
 * Anwesenheit führen über Bilder Liste 
 */
function renderBilder() {
    // refreshAnwesenheit(nameKlasse, function () {
    $("#klassenBilder").empty();
    console.log("lade Bilder:");
    var tr = "<tr>";
    for (i = 1; i <= schueler.length; i++) {
        var status = anwesenheitHeute(schueler[i - 1].id);
        var bemerkung = bemerkungHeute(schueler[i - 1].id);
        if (status.charAt(0) == "a" || status.charAt(0) == "v") {
            tr += '<td align="center" class="anwesend" id="atd' + schueler[i - 1].id + '" ><div><h4>' + schueler[i - 1].VNAME + " " + schueler[i - 1].NNAME + '</h4><div>';
            tr += '<div class="row"><div class="col-sm-4"><label for="ex1' + schueler[i - 1].id + '">Vermerk</label><input class="form-control anwesenheitTextFeld" id="ex1' + schueler[i - 1].id + '" type="text" value="' + status + '"></div><div class="col-sm-8">  <label for="ex2' + schueler[i - 1].id + '">Bemerkung</label>  <input class="form-control bemerkungTextFeld" id="ex2' + schueler[i - 1].id + '" type="text" value="' + bemerkung + '"></div></div>';
            tr += '<div class="row"><br/><img width="150" id="bild' + schueler[i - 1].id + '" src="../img/anonym.gif"></div></td>';
        }
        else if (status.charAt(0) == "f" || status.charAt(0) == "e") {
            tr += '<td align="center" class="fehlend" id="atd' + schueler[i - 1].id + '"><div><h4>' + schueler[i - 1].VNAME + " " + schueler[i - 1].NNAME + '</h4><div>';
            tr += '<div class="row"><div class="col-sm-4"><label for="ex1' + schueler[i - 1].id + '">Vermerk</label><input class="form-control anwesenheitTextFeld" id="ex1' + schueler[i - 1].id + '" type="text" value="' + status + '"></div><div class="col-sm-8">  <label for="ex2' + schueler[i - 1].id + '">Bemerkung</label>  <input class="form-control bemerkungTextFeld" id="ex2' + schueler[i - 1].id + '" type="text" value="' + bemerkung + '"></div></div>';
            tr += '<div class="row"><br/><img  width="150" id="bild' + schueler[i - 1].id + '" src="../img/anonym.gif"></div></td>';
        }
        else {
            tr += '<td align="center" class="unbekannt" id="atd' + schueler[i - 1].id + '"><div><h4>' + schueler[i - 1].VNAME + " " + schueler[i - 1].NNAME + '</h4><div>';
            tr += '<div class="row"><div class="col-sm-4"><label for="ex1' + schueler[i - 1].id + '">Vermerk</label><input class="form-control anwesenheitTextFeld" id="ex1' + schueler[i - 1].id + '" type="text" value="' + status + '"></div><div class="col-sm-8">  <label for="ex2' + schueler[i - 1].id + '">Bemerkung</label>  <input class="form-control bemerkungTextFeld" id="ex2' + schueler[i - 1].id + '" type="text" value="' + bemerkung + '"></div></div>';
            tr += '<div class="row"><br/><img  width="150" id="bild' + schueler[i - 1].id + '" src="../img/anonym.gif"></div></td>';
        }
        if (i % 5 == 0) {
            tr += "</tr></tr>";
        }
    }
    tr += "</tr>";
    $("#klassenBilder").append(tr);
    getBildKlasse(nameKlasse);
    //$("#tabAnwesenheitBilder").fadeIn();
    $('body').off('keydown', ".bemerkungTextFeld");
    $('body').on('keydown', ".bemerkungTextFeld", function (e) {
        var keyCode = e.keyCode || e.which;
        //console.log("key Code="+keyCode);
        if (keyCode == 13 || keyCode == 9) {
            $(this).blur()
            sid = $(this).attr("id");
            sid = sid.substring(3);
            txt = $("#ex1" + sid).val();
            console.log("key Pressed bemerkungTextFeld keyCode=" + keyCode + " Schüler ID=" + sid + " txt=" + txt + " bem=" + $(this).val());
            var eintr = {
                "DATUM": $("#endDate").val() + "T00:00:00",
                "ID_LEHRER": sessionStorage.myself,
                "ID_SCHUELER": parseInt(sid),
                "VERMERK": txt,
                "BEMERKUNG": $(this).val()
            };
            submitAnwesenheit(eintr, function (data) {
                if (data.parseError) {
                    toastr["warning"]("Der Eintrag enthält Formatierungsfehler!", "Warnung!");
                }
                else {
                }
                refreshAnwesenheit(nameKlasse, function () {
                    updateRenderBilder();
                });
            });
        }
    });

    $('body').off('keydown', ".anwesenheitTextFeld");
    $('body').on('keydown', ".anwesenheitTextFeld", function (e) {
        var keyCode = e.keyCode || e.which;
        if (keyCode == 13 || keyCode == 9) {
            $(this).blur()
            sid = $(this).attr("id");
            sid = sid.substring(3);
            txt = $("#ex2" + sid).val();
            console.log("key Pressed AnwesenheitTextFeld keyCode=" + keyCode + " Schüler ID=" + sid);
            if (txt != "") {
                var eintr = {
                    "DATUM": $("#endDate").val() + "T00:00:00",
                    "ID_LEHRER": sessionStorage.myself,
                    "ID_SCHUELER": parseInt(sid),
                    "VERMERK": $(this).val(),
                    "BEMERKUNG": txt
                };
            }
            else {
                var eintr = {
                    "DATUM": $("#endDate").val() + "T00:00:00",
                    "ID_LEHRER": sessionStorage.myself,
                    "ID_SCHUELER": parseInt(sid),
                    "VERMERK": $(this).val()
                };

            }
            submitAnwesenheit(eintr, function (data) {
                if (data.parseError) {
                    toastr["warning"]("Der Eintrag enthält Formatierungsfehler!", "Warnung!");
                }
                else {
                }
                refreshAnwesenheit(nameKlasse, function () {
                    updateRenderBilder();
                });
            });
        }
    });

    $('body').on('keydown', ".bemerkungTextFeld", function (e) {
        var keyCode = e.keyCode || e.which;
        console.log("key Pressed bemerkungTextFeld" + keyCode);
    });

}

/**
 * Update der Bilderansicht beim Führen der Anwesenheit über Bilder
 */
function updateRenderBilder() {
    console.log("Update Render Bilder !");
    for (i = 1; i <= schueler.length; i++) {
        var status = anwesenheitHeute(schueler[i - 1].id);
        var bemerkung = bemerkungHeute(schueler[i - 1].id);
        $("#atd" + schueler[i - 1].id).removeClass("anwesend");
        $("#atd" + schueler[i - 1].id).removeClass("fehlend");
        $("#atd" + schueler[i - 1].id).removeClass("unbekannt");
        if (status.charAt(0) == "a" || status.charAt(0) == "v") {
            $("#atd" + schueler[i - 1].id).addClass("anwesend");
        }
        else if (status.charAt(0) == "f" || status.charAt(0) == "e") {
            $("#atd" + schueler[i - 1].id).addClass("fehlend");
        }
        else {
            $("#atd" + schueler[i - 1].id).addClass("unbekannt");
        }
        $("#ex1" + schueler[i - 1].id).val(status);
        $("#ex2" + schueler[i - 1].id).val(bemerkung);

    }
}

/**
 * Anwesenheits-Vermerk für den Schüler am Tag endDate
 * @param {type} id Schülerid
 * @returns {String} Vermerk der Anwesenheit oder "" wenn kein Vermerk
 */
function anwesenheitHeute(id) {
    var ds = $("#endDate").val();
    for (k = 0; k < anwesenheit.length; k++) {
        if (anwesenheit[k].id_Schueler == id) {
            eintraege = anwesenheit[k].eintraege;
            for (j = 0; j < eintraege.length; j++) {
                var datum = eintraege[j].DATUM;
                datum = datum.substring(0, datum.indexOf('T'));
                if (datum == ds) {
                    return eintraege[j].VERMERK;
                }
            }
            return "";
        }
    }
    return "";
}

/**
 * Vermerk zur Anwesenheit zum heutigen Tag
 * @param {type} id Schülerid
 * @returns {String} Anwesenheitsbemerkungen des Schülers
 */
function bemerkungHeute(id) {
    var ds = $("#endDate").val();
    for (k = 0; k < anwesenheit.length; k++) {
        if (anwesenheit[k].id_Schueler == id) {
            eintraege = anwesenheit[k].eintraege;
            for (j = 0; j < eintraege.length; j++) {
                var datum = eintraege[j].DATUM;
                datum = datum.substring(0, datum.indexOf('T'));
                if (datum == ds) {
                    //console.log("bemerkung Heute Schüler gefunden mit ID="+id+" einträge="+JSON.stringify(eintraege))
                    if (eintraege[j].BEMERKUNG == undefined) {
                        return "";
                    }
                    return eintraege[j].BEMERKUNG;
                }
            }
            return "";
        }
    }
    return "";
}

/**
 * Erzeugen der Notenlisten
 * @param {type} data Notenlisten Objekt
 */
function buildNotenliste(data) {
    var lernfelder = {};
    console.log("buildNotenliste() schueler.length=" + schueler.length);
    for (j = 0; j < data.length; j++) {
        noten = data[j].noten;
        //console.log("Teste Lernfelder in "+JSON.stringify(noten));
        for (k = 0; k < noten.length; k++) {

            if (!findKeyinMap(noten[k].ID_LERNFELD, lernfelder)) {
                lernfelder[noten[k].ID_LERNFELD] = noten[k].ID_LERNFELD;
                console.log("Neues Lernfeld:" + noten[k].ID_LERNFELD);
            }
        }
    }
    // Tabelle aufbauen
    $("#trNoten").empty();
    $("#trNoten").append('<th width="20%"><h3>Name</h3></th>');
    for (lf in lernfelder) {
        $("#trNoten").append('<th>' + lf + '</th>')
    }
    $("#tbodyNotenliste").empty();
    var out = "";
    for (k = 0; k < schueler.length; k++) {
        out = '<tr id="n' + schueler[k].id + '"><td><img src="../img/Info.png" ids="' + schueler[k].id + '" class="infoIcon">&nbsp;' + schueler[k].VNAME + " " + schueler[k].NNAME + '</td>';
        for (lf in lernfelder) {
            out += '<td id="' + schueler[k].id + lf + '"></td>';
        }
        out += '</tr>';
        $("#tbodyNotenliste").append(out);
    }
    // Noten eintragen
    for (j = 0; j < data.length; j++) {
        noten = data[j].noten;
        for (k = 0; k < noten.length; k++) {
            $("#" + data[j].schuelerID + noten[k].ID_LERNFELD).append('<a href="#" data-toggle="tooltip" title="' + noten[k].ID_LK + '">' + noten[k].WERT + '</a>');
        }
    }

    getSchuelerInfo();
}

function buildeAnwesenheitstabelle(data) {

    getTermindaten(function (termine) {
        $("#tabelleAnwesenheit").empty();
        // Leere Anwesenheitstabelle erzeugen
        console.log("Termine = " + JSON.stringify(termine));
        var tab = "";
        tab += '<thead><tr>';
        for (i = 0; i < termine.length; i++) {
            console.log("Add Termin: i=" + i);
            current = new Date(termine[i].milliseconds);
            if (current.getDay() == 0 || current.getDay() == 6) {
                tab += '<th class="wochenende">&nbsp; ' + days[current.getDay()] + "<br>" + current.getDate() + "." + (current.getMonth() + 1) + "." + current.getFullYear() + '&nbsp; </th>';
            }
            else {
                tab += '<th>&nbsp; ' + days[current.getDay()] + "<br>" + current.getDate() + "." + (current.getMonth() + 1) + "." + current.getFullYear() + '&nbsp; </th>';
            }
        }
        tab += '</tr></thead>';
        $("#tabelleAnwesenheit").append(tab);
        $("#tabelleAnwesenheit").append('<tbody>');
        generateAnwesenheitsTable(termine);
        $("#tabelleAnwesenheit").append('</tbody>');
        // Daten in die Tabelle Eintragen
        for (var i = 0; i < anwesenheit.length; i++) {
            var eintraege = anwesenheit[i].eintraege;
            for (var j = 0; j < eintraege.length; j++) {
                var dat = eintraege[j].DATUM;
                dat = dat.substring(0, dat.indexOf("T"));
                var id = eintraege[j].ID_SCHUELER + "_" + dat;
                //console.log("suche html id " + id);
                //$("#" + id).text(eintraege[j].VERMERK);
                if (eintraege[j].BEMERKUNG != undefined) {
                    $("#" + id).append('<a href="#" data-toggle="tooltip" title="' + eintraege[j].ID_LEHRER + ' - ' + eintraege[j].BEMERKUNG + '">' + eintraege[j].VERMERK + '&nbsp;<img src="../img/flag.png"></a>');
                }
                else {
                    $("#" + id).append('<a href="#" data-toggle="tooltip" title="' + eintraege[j].ID_LEHRER + '">' + eintraege[j].VERMERK + '</a>');
                }

                $("#" + id).attr("id_lehrer", eintraege[j].ID_LEHRER);
                if (eintraege[j].BEMERKUNG != undefined) {
                    $("#" + id).attr("bem", eintraege[j].BEMERKUNG);
                }

                $("#" + id).addClass("anwesenheitsPopup");
                if (eintraege[j].parseError) {
                    $("#" + id).addClass("parseError");
                }
            }
        }
    });

}