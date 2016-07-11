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
//  Umfragen (Objektliste)
var umfragen;
// aktuelles Schuljahr
var currentSchuljahr;
// Liste der Lernfelder
var lernfelder;
// Liste der Klassen
var klassen;
// Liste der Vertretungen
var vertretungen;

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
    log("Load Template")
});
$("#diklabuname").text(DIKLABUNAME);
log("found token:" + sessionStorage.auth_token);

$(document).ajaxSend(function (event, request, settings) {
    $('#loading-indicator').show();
});

$(document).ajaxComplete(function (event, request, settings) {
    $('#loading-indicator').hide();
});

$("#btnAddVertretung").click(function () {
    log("add Vertretung");
    c=$("#vertrFirstRow").clone();
    c.find(".vertrKommentar").val("");
    $("#vertrBody").append(c);
            
    $(".btnDeleteRow").unbind();
    $(".btnDeleteRow").click(function () {
        log("delete Vertretung, Zeilen=" + $('#vertrBody >tr').length);
        if ($('#vertrBody >tr').length > 1) {
            $(this).parent("td").parent("tr").remove();
        }
    });
});

$("#btnSubmitVertretung").click(function () {
    if ($("#absLehrer").val() == "") {
        toastr["warning"]("Keinen absenten Lehrer ausgewählt!", "Warnung!");
    }
    else {
        error = false;
        $('.absStunde').each(function (i, obj) {
            if (obj.value == "") {
                toastr["warning"]("Zeile " + (i + 1) + ": keine Stunde ausgewählt!", "Warnung!");
                error = true;
                return;
            }
        });
        if (error) {
            return;
        }
        $('.vertKlassen').each(function (i, obj) {
            if (obj.value == "") {
                toastr["warning"]("Zeile " + (i + 1) + ": keine Vertretungsklasse ausgewählt ausgewählt!", "Warnung!");
                error = true;
                return;
            }
        });
        if (error) {
            return;
        }
        $('.vertAktion').each(function (i, obj) {
            if (obj.value == "") {
                toastr["warning"]("Zeile " + (i + 1) + ": Keine Vertretungsaktion ausgewählt ausgewählt!", "Warnung!");
                error = true;
                return;
            }
            else if (obj.value != "entfällt") {
                if ($("#vertrBody").find("tr").eq(i).find(".vertLehrer").val() == "") {
                    toastr["warning"]("Zeile " + (i + 1) + ": Aktion Vertretung/Betreuung gewählt aber kein Vertretungslehrer angegeben!", "Warnung!");
                    error = true;
                    return;
                }
            }
        });
        if (error) {
            return;
        }
        if ($("#absDate").val()=="") {
            toastr["warning"]("Kein Absenz Datum eingetragen!", "Warnung!");
            return;
            
        }
        var eintr = {
            "eingereichtVon": sessionStorage.myself,
            "absenzLehrer": $("#absLehrer").val(),
            "absenzAm": $("#absDate").val(),
            "eintraege": new Array(),
            "kommentar": $("#absKommentar").val()
        };

        $('#vertrBody > tr').each(function () {
            log("baue Eintrag:" + $(this).find(".absStunde").val());
            var row = {
                "stunde": $(this).find(".absStunde").val(),
                "klasse": $(this).find(".vertKlassen").val(),                
                "idKlasse": $(this).find(".vertKlassen option:selected").attr("kid"),
                "aktion": $(this).find(".vertAktion").val(),
                "vertreter": $(this).find(".vertLehrer").val(),
                "kommentar": $(this).find(".vertrKommentar").val(),
            };
            eintr.eintraege.push(row);

        });
        log("sende -> " + JSON.stringify(eintr));
         $.ajax({
            url: SERVER + "/Diklabu/api/v1/vertretung/",
            type: "POST",
            cache: false,
            data: JSON.stringify(eintr),
            headers: {
                "service_key": sessionStorage.service_key,
                "auth_token": sessionStorage.auth_token
            },
            contentType: "application/json; charset=UTF-8",
            success: function (data) {
                log("Empfange " + JSON.stringify(data));
                if (data.success) {
                    toastr["success"](data.msg, "Info!");
                    $("#absLehrer").val("");
                    $("#absDate").val("");
                    $("#absKommentar").val("");
                    r=$("#vertrFirstRow").clone();
                    $("#vertrBody").empty();
                    $("#vertrBody").append(r);
                    $(".vertrKommentar").val("");
                }
                else {
                    toastr["error"](data.msg, "Fehler!");
                }
                if (data.warning) {
                    for (i=0;i<data.warningMsg.length;i++) {
                        toastr["warning"](data.warningMsg[i], "Warnung!");
                    }
                }
            },
            error: function (xhr, textStatus, errorThrown) {
                toastr["error"]("kann Vertretung nicht Eintragen! Status Code=" + xhr.status, "Fehler!");
                if (xhr.status == 401) {
                    loggedOut();
                }
            }
        });

    }
});




getKlassenliste(function () {
    getLernfelder(function () {
        if (sessionStorage.auth_token != undefined) {
            log("Build gui for logged in user");
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
    else if (currentView == "Beteiligung") {
        $("#tabBeteiligung").printThis({
            debug: false,
            printContainer: true,
            importCSS: true,
            loadCSS: SERVER + "/Diklabu/css/bootstrap.min.css",
            pageTitle: "nachricht an Betriebe der Klasse " + nameKlasse,
            formValues: true
        });

    }
    else if (currentView == "Einreichen") {
        $("#vertrContainer").printThis({
            debug: false,
            printContainer: true,
            importCSS: true,
            loadCSS: SERVER + "/Diklabu/css/bootstrap.min.css",
            pageTitle: "Einreichen Vertertung " + nameKlasse,
            formValues: true
        });

    }
    else if (currentView == "Auswertung") {
        $("#tabAuswertung").printThis({
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
    log("Eigene Einträge Click");
    if ($("#eigeneEintraege").is(':checked')) {
        $("#dokufilter1").val("eigeneEintraege")
    }
    else {
        $("#dokufilter1").val("alle")
    }
    refreshVerlauf(nameKlasse);
});

$("#lernfelderFilter").change(function () {
    log("Filter Lernfelder =" + $(this).val());
    $("#dokufilter2").val($("#lernfelderFilter").val());
    refreshVerlauf(nameKlasse);
});

$("#emailZurueck").click(function () {
    var found = false;
    log("email zurück index=" + indexFehlzeiten);
    for (var i = indexFehlzeiten - 1; i >= 0 && !found; i--) {
        var anwesenheitEintrag = anwesenheit[i];
        if (anwesenheitEintrag.summeFehltage != undefined && anwesenheitEintrag.summeFehltage != 0) {
            log("Summe Fehltage = " + anwesenheitEintrag.summmeFehltag);
            generateMailForm(anwesenheitEintrag);
            indexFehlzeiten = i;
            found = true;
        }
    }
    log("Found a Item:" + found);

    if (!found) {
        toastr["warning"]("kein weiterer Fehlzeiteneintrag gefunden!", "Warnung!");

    }
})
$("#emailWeiter").click(function () {
    var found = false;
    log("email weiter index=" + indexFehlzeiten);
    for (var i = indexFehlzeiten + 1; i < anwesenheit.length && !found; i++) {
        var anwesenheitEintrag = anwesenheit[i];
        if (anwesenheitEintrag.summeFehltage != undefined && anwesenheitEintrag.summeFehltage != 0) {
            log("Summe Fehltage = " + anwesenheitEintrag.summmeFehltag);
            generateMailForm(anwesenheitEintrag);
            indexFehlzeiten = i;
            found = true;
        }
    }
    log("Found a Item:" + found);

    if (!found) {
        toastr["warning"]("kein weiterer Fehlzeiteneintrag gefunden!", "Warnung!");

    }
})

// Ändern der Fileauswahl beim Bild Upload
$(document).on('change', '.btn-file :file', function () {

    var input = $(this),
            numFiles = input.get(0).files ? input.get(0).files.length : 1,
            label = input.val().replace(/\\/g, '/').replace(/.*\//, '');
    log("Ausgewählt wurde " + label);
    input.trigger('fileselect', [numFiles, label]);
    $("#bildWahl").text(label);
    $("#uploadBildButton").show();
});

// Bild Upload Button gedrückt
$('#bildUploadForm').on('submit', (function (e) {
    e.preventDefault();
    var formData = new FormData(this);
    $("#uploadBildButton").hide();
    log("--> Hochladen des Bildes für Schüler id=" + idSchueler);
    $.ajax({
        type: 'POST',
        url: SERVER + "/Diklabu/api/v1/schueler/bild/" + idSchueler,
        data: formData,
        cache: false,
        contentType: false,
        processData: false,
        success: function (data) {
            log("success");
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
        error: function (xhr, textStatus, errorThrown) {
            log("error");
            toastr["error"]("Fehler beim Hochladen des Bildes!", "Fehler!");
            $("#uploadBildButton").show();
            if (xhr.status == 401) {
                loggedOut();
            }
        }
    });
}));

$("#filter1").change(function () {
    log("Filter change ID=" + $('option:selected', this).attr('filter_id'));
    $("#anwfilter1").val($('option:selected', this).attr('filter_id'));
    refreshAnwesenheit(nameKlasse);
});

$("#filter2").change(function () {
    log("Filter change ID=" + $('option:selected', this).attr('filter_id'));
    $("#anwfilter2").val($('option:selected', this).attr('filter_id'));
    refreshAnwesenheit(nameKlasse);
});


$('#anwesenheitTabs').on('shown.bs.tab', function (e) {
    log("anwesenheitsTab shown " + $(e.target).text());
    updateCurrentView();
});
$('#vertretungsTabs').on('shown.bs.tab', function (e) {
    log("vertretungsTabs shown " + $(e.target).text());
    updateCurrentView();
});
$('#fehlzeitenTab').on('shown.bs.tab', function (e) {
    log("fehlzeitenTab shown " + $(e.target).text());
    updateCurrentView();
});
$('#plaene').on('shown.bs.tab', function (e) {
    log("plaene shown " + $(e.target).text());
    updateCurrentView();
});
$('#klassenTabs').on('shown.bs.tab', function (e) {
    log("KlassenTab shown " + $(e.target).text());
    updateCurrentView();
});
$("#updateKlassenBem").click(function () {
    setKlassenBemerkungen(idKlasse);
});

$('#notenTabs').on('shown.bs.tab', function (e) {
    log("New NavNoten Target =" + $(e.target).text());
    updateCurrentView();
});
$('#umfrageTabs').on('shown.bs.tab', function (e) {
    log("New Navumfrage Target =" + $(e.target).text());
    updateCurrentView();
});

$('#navTabs').on('shown.bs.tab', function (e) {
    log("New Nav Target =" + $(e.target).text());
    updateCurrentView();
});


$("#absendenEMailBetrieb").click(function () {
    log("subject mail  length =" + $("#emailBetriebInhalt").val().length + " from " + $("#fromLehrerBetriebMail").val() + " to:" + $("#toBetriebMail").val());
    mails = $("#emailsBetrieb").val().split(";");
    error = false;
    for (i = 0; i < mails.length - 1; i++) {
        log("Teste email:" + mails[i]);
        if (!isValidEmailAddress(mails[i])) {
            toastr["warning"]("Keine gültige EMail Adresse!" + mails[i], "Mail Service");
            error = true;
        }
    }
    if (error == true) {

    }
    else if (!isValidEmailAddress($("#fromLehrerBetriebMail").val())) {
        toastr["warning"]("Keine gültige Absender EMail Adresse! (" + $("#fromLehrerBetriebMail").val() + ")", "Mail Service");
        //event.preventDefault();
    }
    else if (!isValidEmailAddress($("#toBetriebMail").val())) {
        toastr["warning"]("Keine gültige EMail Adresse! (" + $("#toBetriebMail").val() + ")", "Mail Service");
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

$("#absendenEMailKlasse").click(function () {
    log("subject mail  length =" + $("#emailKlasseInhalt").val().length + " from " + $("#fromLehrerKlasseMail").val() + " to:" + $("#toKlasseMail").val());
    mails = $("#emailsKlasse").val().split(";");
    error = false;
    for (i = 0; i < mails.length - 1; i++) {
        log("Teste email:" + mails[i]);
        if (!isValidEmailAddress(mails[i])) {
            toastr["warning"]("Keine gültige EMail Adresse!" + mails[i], "Mail Service");
            error = true;
        }
    }
    if (error == true) {

    }
    else if (!isValidEmailAddress($("#fromLehrerKlasseMail").val())) {
        toastr["warning"]("Keine gültige Absender EMail Adresse!" + $("#fromLehrerKlasseMail").val(), "Mail Service");
        //event.preventDefault();
    }

    else if ($("#emailKlasseBetreff").val().length == 0) {
        toastr["warning"]("Kein Betreff angegeben!", "Mail Service");
        //event.preventDefault();
    }
    else if ($("#emailKlasseInhalt").val().length == 0) {
        toastr["warning"]("Kein EMail Inhalt angegeben!", "Mail Service");
        //event.preventDefault();
    }
    else {
        toastr["success"]("EMail wird versendet via CC an Klasse " + nameKlasse, "Mail Service");
        $.post('../MailServlet', $('#emailFormKlasse').serialize());
        $("#emailKlasseBetreff").val("");
        $("#emailKlasseInhalt").val("");
    }

});

$("#absendenEMailSchueler").click(function (event) {
    log("subject mail  length =" + $("#emailSchuelerInhalt").val().length + " from " + $("#fromLehrerMail").val() + " to:" + $("#toSchuelerMail").val());
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
    log("subject mail length =" + $("#subjectMail").val().length);

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
    //log("key Pressed" + keyCode);
    if (keyCode == 13) {
        log("key Down Kennwort");
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
        log("Sende Bemerkung " + JSON.stringify(eintr));
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
                log("Empfange " + JSON.stringify(data));
                $("#bem" + data.id).val(data.info);
            },
            error: function (xhr, textStatus, errorThrown) {
                toastr["error"]("kann Bemerkungen nicht Eintragen! Status Code=" + xhr.status, "Fehler!");
                if (xhr.status == 401) {
                    loggedOut();
                }
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
    //log("key Pressed" + keyCode);
    if (keyCode == 13 || keyCode == 9 || keyCode == 27) {
        var txt = $(this).val();
        log("eingegeben wurde " + txt);
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
         log("index=" + index);
         log("Nachbar-Element hat Text " + $(inputTd).next().text());
         log("Vorheriges-Element hat Text " + $(inputTd).prev().text());
         log("Oberhalb hat den Wert " + tr.prev().find('td').eq(index).text());
         log("Unterhalb hat den Wert " + tr.next().find('td').eq(index).text());
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
    log("Noten Lernfelder changed to " + $("#notenlernfelder").val() + " id=" + lfid);
    getNoten(nameKlasse, currentSchuljahr.ID, function (data) {
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
    log("keycode=" + keyCode);
    if (keyCode == 13 || keyCode == 9) {
        $(this).blur();
    }
});
$('body').on('focusout', ".notenTextfeld", function (e) {
    log("focus out");
    if ($(this).val() != "") {
        submitNote(lfid, $(this).attr("sid"), $(this).val());
    }
    else {
        deleteNote(lfid, $(this).attr("sid"));
        log("Note löschen!");
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
            klassen = data;
            $("#klassen").empty();
            for (i = 0; i < data.length; i++) {
                $("#klassen").append("<option dbid='" + data[i].id + "'>" + data[i].KNAME + "</option>");
            }
            nameKlasse = data[0].KNAME;
            idKlasse = data[0].id;
            $("#idklasse").val(idKlasse);
            callback();
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("kann Klassenliste nicht vom Server laden", "Fehler!");
            if (xhr.status == 401) {
                loggedOut();
            }
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
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("kann Filter nicht vom Server laden", "Fehler!");
            if (xhr.status == 401) {
                loggedOut();
            }
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
            lernfelder = data;
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
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("kann Lernfelder nicht vom Server laden", "Fehler!");
            if (xhr.status == 401) {
                loggedOut();
            }
        }
    });
}

function getSchuljahre(callback) {

    $.ajax({
        url: SERVER + "/Diklabu/api/v1/schuljahr/all",
        type: "GET",
        contentType: "application/json; charset=UTF-8",
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        success: function (data) {
            callback(data);
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("kann Schuljahre nicht vom Server laden", "Fehler!");
            if (xhr.status == 401) {
                loggedOut();
            }
        }
    });
}

function getVertretung(callback) {
    log("get Vertertung");
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/vertretung/"+$("#startDate").val()+"/"+$("#endDate").val(),
        type: "GET",
        contentType: "application/json; charset=UTF-8",
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        success: function (data) {
            log("empfange getVertretung -> "+JSON.stringify(data));
            callback(data);
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("kann Vertretungsliste nicht vom Server laden", "Fehler!");
            if (xhr.status == 401) {
                loggedOut();
            }
        }
    });
}


/**
 * Noten einer Klasse vom Server Laden
 * @param {type} kl Name der Klasse
 * @param {type} ids ID des Schuljahres
 * @param {type} callback
 * @returns {undefined}
 */
function getNoten(kl, ids, callback) {
    log("--> Noten der Klasse kl=" + kl + " für Schuljahr ID=" + ids + "laden!");
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/noten/" + kl + "/" + ids,
        type: "GET",
        cache: false,
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            log("Noten empfangen!");
            notenliste = data;

            if (callback != undefined) {
                callback(data);
            }

        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("Kann Noten der Klasse " + kl + " nicht vom Server laden!", "Fehler!");
            if (xhr.status == 401) {
                loggedOut();
            }
        }
    });
}

function getLehrer(callback) {
    log("--> Lehrer laden!");
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/noauth/lehrer/",
        type: "GET",
        cache: false,
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            log("Lehrer empfangen!");

            if (callback != undefined) {
                callback(data);
            }
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("Kann Lehrer nicht vom Server laden!", "Fehler!");
            if (xhr.status == 401) {
                loggedOut();
            }
        }
    });
}

/**
 * Details zu einem Lehrer abfragen
 * @param {type} id die Lehrer ID
 */
function getLehrerData(id, callback) {
    log("Get LehrerData " + id);
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
            sessionStorage.myemail = data.EMAIL;
            $("#fromMail").val(data.EMAIL);
            if (callback != undefined) {
                callback(data);
            }
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("kann Lehrerdaten nicht vom Server laden", "Fehler!");
            if (xhr.status == 401) {
                loggedOut();
            }
        }
    });
}


/**
 * Sendet einen Anwesenheitseintrag zum Server
 * @param {type} eintr Der Anwesenheitseintrag
 * @param {type} success Callback für Success 
 */
function submitAnwesenheit(eintr, success) {
    log("-->! Sende Anwesenheit zum Server:" + JSON.stringify(eintr));
    log("Vermekr = (" + eintr.VERMERK + ")");
    ve = eintr.VERMERK.trim();

    if (ve == "") {
        log("Lösche Eintrag!");
        dat = eintr.DATUM;
        dat = dat.substr(0, dat.indexOf("T"));

        $.ajax({
            url: SERVER + "/Diklabu/api/v1/anwesenheit/" + eintr.ID_SCHUELER + "/" + dat,
            type: "DELETE",
            cache: false,
            headers: {
                "service_key": sessionStorage.service_key,
                "auth_token": sessionStorage.auth_token
            },
            contentType: "application/json; charset=UTF-8",
            success: function (data) {
                if (data != null) {
                    toastr["info"]("Anwesenheitseintrag gelöscht!", "Info!");
                }
                else {
                    toastr["error"]("Anwesenheitseintrag konnte nicht gelöscht werden!", "Fehler!");
                }
                success(data);
            },
            error: function (xhr, textStatus, errorThrown) {
                toastr["error"]("kann Anwesenheitseintrag nicht zum Server senden! Status Code=" + xhr.status, "Fehler!");
                if (xhr.status == 401) {
                    loggedOut();
                }
            }
        });
    }
    else {
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
                if (xhr.status == 401) {
                    loggedOut();
                }
            }
        });
    }
}

/**
 * Verlauf einer Klasse vom Server laden und eintragen
 * @param {type} kl die Klassenbezeichnung
 */
function refreshVerlauf(kl) {
    log("--> Refresh Verlauf f. Klasse " + kl + " von " + $("#startDate").val() + " bis " + $("#endDate").val());
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
            log("Filter eigene Einträege=" + $("#eigeneEintraege").is(':checked'));
            for (i = 0; i < data.length; i++) {
                var datum = data[i].wochentag + " " + data[i].DATUM;
                datum = datum.substring(0, datum.indexOf('T'));
                if (data[i].ID_LEHRER == sessionStorage.myself) {
                    if ($("#lernfelderFilter").val() == "alle" || $("#lernfelderFilter").val() == data[i].ID_LERNFELD) {
                        $("#tabelleVerlauf").append("<tr dbid='" + data[i].ID + "' index='" + i + "' class='success'><td>" + datum + "</td><td>" + data[i].ID_LEHRER + "</td><td>" + data[i].ID_LERNFELD + "</td><td>" + data[i].STUNDE + "</td><td>" + data[i].INHALT + "</td><td>" + data[i].BEMERKUNG + "</td><td>" + data[i].AUFGABE + "</td></tr>");
                    }
                }
                else {
                    if ($("#eigeneEintraege").is(':checked')) {

                    }
                    else {
                        if ($("#lernfelderFilter").val() == "alle" || $("#lernfelderFilter").val() == data[i].ID_LERNFELD) {
                            $("#tabelleVerlauf").append("<tr dbid='" + data[i].ID + "' index='" + i + "' ><td>" + datum + "</td><td>" + data[i].ID_LEHRER + "</td><td>" + data[i].ID_LERNFELD + "</td><td>" + data[i].STUNDE + "</td><td>" + data[i].INHALT + "</td><td>" + data[i].BEMERKUNG + "</td><td>" + data[i].AUFGABE + "</td></tr>");
                        }
                    }
                }
            }
            $(".success").click(function () {
                log("Auswahl Verlaufseintrag ID=" + $(this).attr("dbid"));
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
                log("Setze Lernfeld auf (" + lf + ")");
                $("#lernfelder").val(lf);
                $("#stunde").val(verlauf[index].STUNDE);
                $("#updateVerlauf").removeClass("disabled");
                $("#deleteVerlauf").removeClass("disabled");
            });
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("kann Verlauf nicht vom Server laden! Status Code=" + xhr.status, "Fehler!");
            if (xhr.status == 401) {
                loggedOut();
            }
        }
    });
}


/**
 * Bemerkungen einer Klasse abfragen
 * @param {type} klid Die id der Klasse
 */
function getKlassenBemerkungen(klid) {
    log("--> get Klassenbemerkungen f. Klasse " + klid);

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
            if (xhr.status == 401) {
                loggedOut();
            }
        }
    });
}

/**
 * Klassenbemerkungen einer Klasse eintragen
 * @param {type} klid die ID der Klasse
 */
function setKlassenBemerkungen(klid) {
    log("--> set Klassenbemerkungen f. Klasse " + klid);

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
            if (xhr.status == 401) {
                loggedOut();
            }
        }
    });
}

/**
 * Schülerbemerkungen eine Klasse laden
 * @param {type} kl Der Name der Klasse
 */
function refreshBemerkungen(kl) {
    log("-->  Bemerkungen f. Klasse " + kl);

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
            if (xhr.status == 401) {
                loggedOut();
            }
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
    log("--> SubmitNote lf=" + lf + " ID_Schueler=" + ids + " Wert=" + wert);
    var eintr = {
        "ID_LERNFELD": lf,
        "ID_LK": sessionStorage.myself,
        "ID_SCHUELER": ids,
        "WERT": wert
    }

    $.ajax({
        url: SERVER + "/Diklabu/api/v1/noten/" + idKlasse,
        type: "POST",
        data: JSON.stringify(eintr),
        cache: false,
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            if (data.success == false) {
                toastr["error"](data.msg, "Fehler!");
            }
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("Kann Note nicht eintragen! Status Code=" + xhr.status, "Fehler!");
            if (xhr.status == 401) {
                loggedOut();
            }
        }
    });
}

/**
 * Löschen einer Note
 * @param {type} lf Lernfeld
 * @param {type} ids Schüler ID 
 */
function deleteNote(lf, ids) {
    log("--> deleteNote lf=" + lf + " ID_Schueler=" + ids);

    $.ajax({
        url: SERVER + "/Diklabu/api/v1/noten/" + lf + "/" + ids,
        type: "DELETE",
        cache: false,
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            if (data.success) {
                toastr["info"](data.msg, "Info!");
            }
            else {
                toastr["error"](data.msg, "Fehler!");
            }

        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("Kann Note nicht löschen! Status Code=" + xhr.status, "Fehler!");
            if (xhr.status == 401) {
                loggedOut();
            }
        }
    });
}


function getTermindaten(callback) {
    log("--> Get Termindaten Filter1 ID=" + $('option:selected', "#filter1").attr('filter_id') + " Filter2 ID=" + $('option:selected', "#filter2").attr('filter_id'));
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
            if (xhr.status == 401) {
                loggedOut();
            }
        }
    });
}

/**
 * Anwesenheitstabelle aktualisieren
 * @param {type} kl die Klasse
 * @param {type} callback optional ein Callback
 */
function refreshAnwesenheit(kl, callback) {

    log("--> Refresh Anwesenheit f. Klasse " + kl + " von " + $("#startDate").val() + " bis " + $("#endDate").val());
    var url = SERVER + "/Diklabu/api/v1/anwesenheit/" + kl + "/" + $("#startDate").val() + "/" + $("#endDate").val();
    log("URL=" + url);
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
            log("anwesenheit empfangen!");
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
            if (xhr.status == 401) {
                loggedOut();
            }
        }
    });
}

/**
 * Laden und Anzeigen eines Schülerbildes vom Server
 * @param {type} id id des Schülers
 * @param {type} elem Element im dem das Bild angezeigt werden soll (als attr 'src')
 */
function getSchuelerBild(id, elem) {
    log("--> Lade Schülerbild vom Schüler mit der id=" + id);
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
                            log("Bild Daten geladen:" + data.id + " elem=" + elem);
                            data = data.base64.replace(/(?:\r\n|\r|\n)/g, '');
                            $(elem).attr('src', "data:image/png;base64," + data);

                        },
                        error: function (xhr, textStatus, errorThrown) {
                            toastr["error"]("kann Schülerbild ID=" + id + " nicht vom Server laden", "Fehler!");
                            if (xhr.status == 401) {
                                loggedOut();
                            }
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
    log("--> Get Betriebe f. Klasse " + kl);
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
            log("<--- empfangen: Betriebe!");
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
            if (xhr.status == 401) {
                loggedOut();
            }
        }
    });

}

/**
 * Schülerdaten vom Server laden
 * @param {type} id ID des Schülers
 * @param {type} callback Callback
 */
function loadSchulerDaten(id, callback) {
    log("--> loadSchuelerData id=" + id);
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
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("kann Schülerinfo ID=" + idSchueler + " nicht vom Server laden", "Fehler!");
            if (xhr.status == 401) {
                loggedOut();
            }
        }
    });
}

/**
 * Aktuelles Schuljahr laden
 * @param {type} callback
 * @returns {undefined}
 */
function loadSchuljahr(callback) {
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/schuljahr/",
        type: "GET",
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            log("Load Schuljahr empfangen:" + JSON.stringify(data));
            callback(data);
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("kann Schuljahr nicht vom Server laden", "Fehler!");
            if (xhr.status == 401) {
                loggedOut();
            }
        }
    });
}

/**
 * Active Umfrage abfragen
 * @param {type} callback Callback
 */
function loadUmfrage(callback) {
    log("--> getUmfrage");
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
 * alle Umfragen abfragen
 * @param {type} callback Callback
 */
function loadUmfragen(callback) {
    log("--> getUmfragen");
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/umfrage",
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
            toastr["error"]("kann Umfragen nicht vom Server laden", "Fehler!");
        }
    });
}

/**
 * Asuwertung der Umfrage abfragen
 * @param {type} id Die ID der Umfrage
 * @param {type} klassefilter der Filter (% ist Joker)
 * @param {type} callback
 * @returns {undefined}
 */
function loadResults(id, klassefilter, callback) {
    log("--> getAuswertung");
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/umfrage/auswertung/" + id + "/" + encodeURIComponent(klassefilter),
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
            toastr["error"]("kann Auswertung der Umfragen nicht vom Server laden", "Fehler!");
        }
    });
}



function loadBeteiligung(uid, kname, callback) {
    log("--> load Beteiligung Klasse=" + kname + " uid=" + uid);
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/umfrage/beteiligung/" + uid + "/" + kname,
        type: "GET",
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            log("Load Beteiligung data=" + JSON.stringify(data));
            if (callback != undefined) {
                callback(data);
            }
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("Kann Umfragebeteiligung Klasse " + kname + " nicht vom Server laden", "Fehler!");
            if (xhr.status == 401) {
                loggedOut();
            }
        }
    });
}

function loadPortfolio(id, callback) {
    log("--> loadPortfiol Klassen id=" + id);
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/portfolio/" + id,
        type: "GET",
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            log("Load Portfolio data=" + JSON.stringify(data));
            if (callback != undefined) {
                callback(data);
            }
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("Kann Portfolio für Klasse ID=" + id + " nicht vom Server laden", "Fehler!");
            if (xhr.status == 401) {
                loggedOut();
            }
        }
    });
}


/**
 * Schülerbilder eine Klasse las Base64 laden
 * @param {type} kl der Klassenname
 */
function getBildKlasse(kl) {
    log("--> Lade Bider der Klasse " + kl);
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/klasse/" + kl + "/bilder64/150",
        cache: false,
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        type: 'GET',
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("kann Bilder der Klasse " + kl + " nicht vom Server laden", "Fehler!");
            if (xhr.status == 401) {
                loggedOut();
            }
        },
        success:
                function (data) {
                    log("Bilder der Klasse " + kl + " geladen");

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
    log("get Current View Base target=(" + target + ")");
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
    if (target == "Umfrage") {
        sub = $("ul#umfrageTabs li.active").text();
        return sub;
    }
    if (target == "Vertretung") {
        sub = $("ul#vertretungsTabs li.active").text();
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
    log("Lade Stundenplan der Klasse " + nameKlasse);
    $("#stundenplan").load(SERVER + "/Diklabu/api/v1/noauth/plan/stundenplan/" + nameKlasse, function (response, status, xhr) {
        log("Stundenplan Status=" + status);
        if (status == "nocontent") {
            log("Kann Stundenplan der Klasse " + nameKlasse + " nicht laden!")
            $("#stundenplan").empty();
            $("#stundenplan").append('<div><center><h1>Kann Stundenplan der Klasse ' + nameKlasse + ' nicht finden</h1></center></div>');
        }
    });
}

/**
 * Vertretungsplan (HTML) der Klasse Abfragen und anzeigen
 */
function loadVertertungsPlan() {
    log("Lade Vertretungsplan der Klasse " + nameKlasse);
    $("#vertertungsplan").load(SERVER + "/Diklabu/api/v1/noauth/plan/vertertungsplan/" + nameKlasse, function (response, status, xhr) {
        log("Vertretungsplan Status=" + status);
        if (status == "nocontent") {
            log("Kann Vertertungsplan der Klasse " + nameKlasse + " nicht laden!")
            $("#vertertungsplan").empty();
            $("#vertertungsplan").append('<div><center><h1>Kann Vertertungsplan der Klasse ' + nameKlasse + ' nicht finden</h1></center></div>');
        }
    });
}

/**
 * Stundenplan des Lehrers anzeigen
 */
function loadStundenPlanLehrer() {
    log("Lade Stundenplan für " + sessionStorage.lehrerNNAME);
    getLehrerData(sessionStorage.myself, function (data) {
        $("#lstundenplan").load(SERVER + "/Diklabu/api/v1/noauth/plan/stundenplanlehrer/" + sessionStorage.lehrerNNAME, function (response, status, xhr) {
            log("Stundenplan Lehere Status=" + status);
            if (status == "nocontent") {
                log("Kann Stundenplan für Lehrer nicht laden");
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
    log("Lade Vertretungsplan für " + sessionStorage.lehrerNNAME);
    getLehrerData(sessionStorage.myself, function (data) {
        $("#lvertertungsplan").load(SERVER + "/Diklabu/api/v1/noauth/plan/vertretungsplanlehrer/" + sessionStorage.lehrerNNAME, function (response, status, xhr) {
            log("Vertretungsplan Lehrer Status=" + status);
            if (status == "nocontent") {
                log("Kann Stundenplan für Lehrer nicht laden");
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
        $("#verlaufsFilter").show();
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
        $("#verlaufsFilter").hide();
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
    $("#dokumentation").addClass("disabled");
    chatDisconnect();
    $("tbody").empty();
    sessionStorage.clear();
    schueler = undefined;
    $("#trNoten").empty();
    window.location.replace("index.html");
}

/**
 * GUI vorbereiten wenn Nutzer eingeloggt ist 
 */
function loggedIn() {
    showContainer(true);

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
        log("Klassen change ID=" + $('option:selected', this).attr('dbid') + " KNAME=" + $("#klassen").val());
        log("Current View =" + getCurrentView());
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
        log("input Visible=" + inputVisible);
        oldText = $(this).text();
        if (!inputVisible) {
            inputTd = $(this);
            log("Bemerkung = " + inputTd.attr("bem"));
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
            log("eingegeben wurde (" + txt + ")");
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
    log("Generate Verspaetungen");
    $("#verspaetungenTabelle").empty();
    for (var i = 0; i < anwesenheit.length; i++) {
        if (anwesenheit[i].summeFehltage != 0 || anwesenheit[i].anzahlVerspaetungen != 0 || anwesenheit[i].parseErrors.length != 0) {
            var tr = "<tr>";
            tr += "<td><img src=\"../img/Info.png\" ids=\"" + anwesenheit[i].id_Schueler + "\" class=\"infoIcon\"> " + getNameSchuler(anwesenheit[i].id_Schueler) + "</td>";
            tr += "<td><strong>" + anwesenheit[i].summeFehltage + "</strong>&nbsp;";
            tr += "<span class=\"fehltagEntschuldigt\">" + anwesenheit[i].summeFehltageEntschuldigt + "</span></td>";
            tr += "<td>";
            var entschuldigt = anwesenheit[i].fehltageEntschuldigt;
            log("Fehltage Entschuldigt size=" + entschuldigt.length);
            for (var j = 0; j < entschuldigt.length; j++) {
                var dat = entschuldigt[j].DATUM;
                dat = dat.substr(0, dat.indexOf("T"));
                tr += "<span class=\"fehltagEntschuldigt\">" + '<a href="#" data-toggle="tooltip" title="' + entschuldigt[j].ID_LEHRER + '">' + dat + "</a></span> &nbsp;";
            }
            var unentschuldigt = anwesenheit[i].fehltageUnentschuldigt;
            log("Fehltage UnEntschuldigt size=" + unentschuldigt.length);
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
            log("Fehler size=" + fehler.length);
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
    log("Create Mail Form anwesenheit.length=" + anwesenheit.length);
    var found = false;
    for (var i = 0; i < anwesenheit.length && !found; i++) {
        var anwesenheitEintrag = anwesenheit[i];
        if (anwesenheitEintrag.summeFehltage != undefined && anwesenheitEintrag.summeFehltage != 0) {
            log("Summe Fehltage = " + anwesenheitEintrag.summmeFehltage);
            generateMailForm(anwesenheitEintrag);
            indexFehlzeiten = i;
            found = true;
        }
    }
    log("Found a Item:" + found);

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
            log("Found Name for ID " + id + " " + schueler[i].VNAME + " " + schueler[i].NNAME)
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
        log("lade Schuler ID=" + idSchueler);
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
        log("mail to Schüler with id=" + $(this).attr("ids") + "abs=" + sessionStorage.myemail);
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
        log("mail to Betrieb to=" + $(this).attr("aemail"));
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
    log("Build Noteneintrag schueler.length=" + schueler.length);
    $("#tbodyNoteneintrag").empty();
    lfid = $('option:selected', "#notenlernfelder").attr("lfid");
    log("lfid=" + lfid);
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
        log("idplain = " + idplain + " send data=" + JSON.stringify(myData));
        sessionStorage.service_key = idplain + "f80ebc87-ad5c-4b29-9366-5359768df5a1";
        log("Service key =" + sessionStorage.service_key);

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
                    log("Thoken = " + jsonObj.auth_token);

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
                log("HTTP Status: " + xhr.status);
                log("Error textStatus: " + textStatus);
                log("Error thrown: " + errorThrown);
                if (xhr.status == 401) {
                    loggedOut();
                }
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
                log("HTTP Status: " + xhr.status);
                log("Error textStatus: " + textStatus);
                log("Error thrown: " + errorThrown);
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
    log("Generate MAIL FORM");
    $("#emailZurueck").show();
    $("#emailWeiter").show();
    $("#emailAbsenden").show();
    $("#klassenName").val(nameKlasse);
    $("#lehrerId").val(sessionStorage.myself);
    $("#mailauth_token").val(sessionStorage.auth_token);
    $("#mailservice_key").val(sessionStorage.service_key);

    $("#subjectMail").val("MMBbS Fehlzeitenmeldung");

    template = $("#template").text();
    //log("Template="+template);
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
    log("--> Refresh Schüler Liste f. Klasse " + kl);
    if (schueler != undefined && schueler.klasse == kl) {
        log("Daten bereits vorhanden, kein erneutes Laden!")
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
                $("#tabelleBeteiligung").empty();

                $("#tabelleKlasse").append('<thead><tr><th ><h3>Name</h3></th></tr></thead>');
                $("#tabelleKlasse").append("<tbody>");
                for (i = 0; i < data.length; i++) {
                    $("#tabelleKlasse").append('<tr><td><img src="../img/Info.png" ids="' + data[i].id + '" class="infoIcon"> ' + data[i].VNAME + " " + data[i].NNAME + '&nbsp;<img src="../img/mail.png" ids="' + data[i].id + '" class="mailIcon"></td></tr>');
                    $("#tabelleBeteiligung").append('<tr><td><img src="../img/Info.png" ids="' + data[i].id + '" class="infoIcon"> ' + data[i].VNAME + " " + data[i].NNAME + '&nbsp;<img src="../img/mail.png" ids="' + data[i].id + '" class="mailIcon"></td><td class="rowBeteiligung" id="U' + data[i].id + '"></td></tr>');
                    if (data[i].INFO != undefined) {
                        $("#tabelleBemerkungen").append('<tr><td><img src="../img/Info.png" ids="' + data[i].id + '" class="infoIcon"> ' + data[i].VNAME + " " + data[i].NNAME + '</td><td><input id="bem' + data[i].id + '" sid="' + data[i].id + '" name="' + data[i].id + '" type="text" class="form-control bemerkung" value="' + data[i].INFO + '"></td></tr>');
                    }
                    else {
                        $("#tabelleBemerkungen").append('<tr><td><img src="../img/Info.png" ids="' + data[i].id + '" class="infoIcon"> ' + data[i].VNAME + " " + data[i].NNAME + '</td><td><input id="bem' + data[i].id + '" sid="' + data[i].id + '" name="' + data[i].id + '" type="text" class="form-control bemerkung" value=""></td></tr>');
                    }
                }
                $("#tabelleKlasse").append("</tbody>");
                $("#tabelleBemerkungen").append("</tbody>");

                getSchuelerInfo();
                if (callback != undefined) {
                    callback(data);
                }


            },
            error: function (xhr, textStatus, errorThrown) {
                toastr["error"]("kann Schüler der Klasse " + kl + " nicht vom Server laden! Status Code=" + xhr.status, "Fehler!");
                if (xhr.status == 401) {
                    loggedOut();
                }
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
    log("Update Current View = " + view);
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
        case "Einreichen":
            getLehrer(function (data) {
                $("#absLehrer").empty();
                $(".vertLehrer").empty();
                for (i = 0; i < data.length; i++) {
                    l = data[i];
                    $("#absLehrer").append("<option>" + l.id + "</option>");
                    $(".vertLehrer").append("<option>" + l.id + "</option>");
                }
                $(".vertKlassen").empty();
                $(".vertKlassen").append("<option></option>");
                for (i = 0; i < klassen.length; i++) {
                    k = klassen[i];
                    
                    $(".vertKlassen").append("<option kid=\""+k.id+"\">" + k.KNAME + "</option>");
                }
            });
            $("#dokumentationContainer").hide();
            $("#printContainer").hide();
            break;
        case "Vertretungsliste":
            $("#dokumentationType").val("Vertretungsliste");
            getVertretung(function (data) {
                vertretungen=data;
                $("#vertrUbersichtBody").empty();
                for (i=0;i<data.length;i++) {
                    v=data[i];
                    $("#vertrUbersichtBody").append('<tr><td>'+v.absenzVon+'</td><td>'+getReadableDate(v.absenzAm)+'</td><td>'+v.eingereichtVon+'</td><td>'+getReadableDate(v.eingereichtAm)+'</td><td><img  index="'+i+'" class="vdetails" src="../img/Info.png"></td></tr>');
                }
                $(".vdetails").click(function () {
                    index = $(this).attr("index");
                    v = vertretungen[index];
                    $("#dvHead").text("Absenz von "+v.absenzVon+" am "+getReadableDate(v.absenzAm)+" eingetragen von "+v.eingereichtVon+" am "+getReadableDate(v.eingereichtAm));
                    $("#veKommentar").text(v.kommentar);
                    regelungen = JSON.parse(v.jsonString);
                    $("#vertrBodyDetails").empty();
                    for (i=0;i<regelungen.length;i++) {
                        r = regelungen[i];
                        $("#vertrBodyDetails").append('<tr><td>'+r.stunde+'</td><td>'+r.Klasse+'</td><td>'+r.Aktion+'</td><td>'+r.Vertreter+'</td><td>'+r.Kommentar+'</td></tr>');
                    }
                    $('#detailsVertretung').modal('show');
                });
            });
            $("#dokumentationContainer").show();
            $("#printContainer").hide();
            break;
        case "Notenliste":
            refreshKlassenliste(nameKlasse, function (data) {
                getSchuljahre(function (data) {
                    $("#schuljahre").empty();
                    for (i = 0; i < data.length; i++) {
                        $("#schuljahre").append('<option value="' + data[i].NAME + '" sid="' + data[i].ID + '">' + data[i].NAME + '</option>');
                    }
                    console.log("Setzte aktuelles Schuljahr auf " + data[i - 1].NAME);


                    $("#schuljahre").val(data[i - 1].NAME);
                    $("#idSchuljahr").val(data[i - 1].ID);
                    getNoten(nameKlasse, data[i - 1].ID, function (data) {
                        buildNotenliste(data);
                    });
                });
            });
            $("#schuljahre").unbind("change");
            $("#schuljahre").change(function () {
                sid = $('option:selected', this).attr('sid');
                log("Schuljahre changed sid=" + sid);
                $("#idSchuljahr").val(sid);
                getNoten(nameKlasse, sid, function (data) {
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
                loadSchuljahr(function (data) {
                    $("#schuljahr").text("Schuljahr " + data.NAME);
                    currentSchuljahr = data;
                    getNoten(nameKlasse, data.ID, function (data) {
                        buildNoteneintrag(data);
                    });
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
            $("#fromLehrerBetriebMail").val(sessionStorage.myemail);
            $("#toBetriebMail").val(sessionStorage.myemail);
            refreshKlassenliste(nameKlasse, function (data) {
                getBetriebe(nameKlasse, function (data) {
                    updateBetriebeMails();
                });
            });
            $("#dokumentationContainer").hide();
            $("#printContainer").show();
            break;
        case "Klasse anschreiben":
            $("#fromLehrerKlasseMail").val(sessionStorage.myemail);
            $("#toKlasseMail").val(sessionStorage.myemail);
            refreshKlassenliste(nameKlasse, function (data) {
                updateKlasseMails();
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
        case "Portfolio":
            refreshKlassenliste(nameKlasse, function (data) {
                loadPortfolio(idKlasse, function (data) {
                    updatePortfolio(data);
                });
            });
            $("#dokumentationType").val("Portfolio");
            $("#dokumentationContainer").show();
            $("#printContainer").hide();
            break;
        case "Chat":
            $("#dokumentationContainer").hide();
            $("#printContainer").hide();
            break;
        case "Beteiligung":
            $("#dokumentationContainer").hide();
            $("#printContainer").show();
            refreshKlassenliste(nameKlasse, function (data) {
                $("#beteiligungUmfrage").empty();
                loadUmfragen(function (data) {
                    for (i = 0; i < data.length; i++) {
                        $("#beteiligungUmfrage").append('<option uid="' + data[i].id + '" active="' + data[i].active + '">' + data[i].titel + '</option>');
                    }
                    if (data[0].active == 1) {
                        toastr["warning"]("Gewählte Umfrage ist noch aktiv!", "Achtung!");
                    }

                    log("empfange:" + JSON.stringify(data));
                    loadBeteiligung(data[0].id, nameKlasse, function (data) {
                        log("empfange:" + JSON.stringify(data));
                        updateBeteiligung(data);
                    });
                });
            });
            $("#beteiligungUmfrage").unbind("change");
            $("#beteiligungUmfrage").change(function () {
                $(".rowBeteiligung").text("");
                uid = $('option:selected', this).attr('uid');
                active = $('option:selected', this).attr('active');
                if (active == 1) {
                    toastr["warning"]("Gewählte Umfrage ist noch aktiv!", "Achtung!");
                }
                log("Umfrage changed id=" + $('option:selected', this).attr('uid') + " name=" + $(this).val());
                loadBeteiligung(uid, nameKlasse, function (data) {
                    log("empfange:" + JSON.stringify(data));
                    updateBeteiligung(data);
                });
            });
            break;
        case "Auswertung":
            $("#dokumentationContainer").hide();
            $("#printContainer").show();
            loadUmfragen(function (data) {
                umfragen = data;
                log("empfange:" + JSON.stringify(data));
                umfrage = data[data.length - 1];
                log("Umfrage=" + umfrage.id);
                updateAuswertungsFilter(data);


                if (umfrage.active == 1) {
                    toastr["warning"]("Gewählte Umfrage ist noch aktiv!", "Achtung!");
                }

                loadResults(umfrage.id, nameKlasse, function (data) {
                    log("empfange Results:" + JSON.stringify(data));
                    $('#loading-indicator').show();
                    updateAuswertung(data);
                    drawResults(data, 1);
                    drawResults(data, 2);

                });


            });
            break;
    }

}


function drawResults(results, col) {
    $('#loading-indicator').show();
    for (i = 0; i < results.length; i++) {
        var result = results[i];
        var antworten = results[i].skalen;
        // Create the data table.
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Topping');
        data.addColumn('number', 'Slices');
        var rows = [];
        for (j = 0; j < antworten.length; j++) {
            antwort = antworten[j];
            var row = [antwort.name, antwort.anzahl];
            // log("drawResults antwort=" + antwort.name + " Anzahl=" + antwort.anzahl);
            rows.push(row);
        }
        data.addRows(rows);
        /*
         data.addRows([
         ['Mushrooms', 3],
         ['Onions', 1],
         ['Olives', 1],
         ['Zucchini', 1],
         ['Pepperoni', 2]
         ]);
         */

        // Set chart options
        var options = {'title': result.frage,
            'width': 400,
            'height': 300,
            backgroundColor: {fill: 'transparent'}
        };

        // Instantiate and draw our chart, passing in some options.
        if ($("#chart" + col + result.id).length) {
            var chart = new google.visualization.PieChart(document.getElementById('chart' + col + result.id));
            chart.draw(data, options);
        }
        else {
            log("Container existiert nicht!");
        }
    }
    $('#loading-indicator').hide();
}


function updateAuswertungsFilter(data) {
    $("#gruppe1Filter").val(nameKlasse);
    $("#gruppe2Filter").val(nameKlasse);
    $("#gruppe1Umfrage").empty();
    $("#gruppe2Umfrage").empty();
    for (i = 0; i < data.length; i++) {
        u = data[i];
        log("Füge gruppe1Umfrage hinzu id" + u.id);
        $("#gruppe1Umfrage").append('<option uid="' + u.id + '">' + u.titel + '</option>')
        $("#gruppe2Umfrage").append('<option uid="' + u.id + '">' + u.titel + '</option>')
    }
    $("#gruppe1Umfrage").val(u.titel);
    $("#gruppe2Umfrage").val(u.titel);
    $('#gruppe1Filter').off('keypress');
    $('#gruppe1Filter').on('keypress', function (e) {
        var keyCode = e.keyCode || e.which;
        log("key Pressed gruppe1Filer" + keyCode);
        if (keyCode == 13) {
            loadResults(umfrage.id, $("#gruppe1Filter").val(), function (data) {
                log("empfange:" + JSON.stringify(data));

                drawResults(data, 1);
            });
        }
    });
    $('#gruppe2Filter').off('keypress');
    $('#gruppe2Filter').on('keypress', function (e) {
        var keyCode = e.keyCode || e.which;
        log("key Pressed gruppe2Filer" + keyCode);
        if (keyCode == 13) {
            loadResults(umfrage.id, $("#gruppe2Filter").val(), function (data) {
                log("empfange:" + JSON.stringify(data));
                drawResults(data, 2);
            });

        }
    });
    $("#gruppe1Umfrage").unbind("change");
    $("#gruppe1Umfrage").change(function () {
        uid = $('option:selected', this).attr('uid');
        log("gruppe1Umfrage changed id=" + $('option:selected', this).attr('uid') + " name=" + $(this).val());
        umfrage = getUmfrage(uid);
        log("Umfrage=" + umfrage.id);
        if (umfrage.active == 1) {
            toastr["warning"]("Gewählte Umfrage ist noch aktiv!", "Achtung!");
        }

        loadResults(uid, $('#gruppe1Filter').val(), function (data) {
            updateAuswertung(data);
            log("empfange 1:" + JSON.stringify(data));
            drawResults(data, 1);
            log("Rechte Seite id=" + $('option:selected', "#gruppe2Umfrage").attr('uid'));
            loadResults($('option:selected', "#gruppe2Umfrage").attr('uid'), $('#gruppe2Filter').val(), function (data) {
                //updateAuswertung(data);
                log("empfange 2:" + JSON.stringify(data));
                drawResults(data, 2);
            });

        });
    });
    $("#gruppe2Umfrage").unbind("change");
    $("#gruppe2Umfrage").change(function () {
        uid = $('option:selected', this).attr('uid');
        log("gruppe2Umfrage changed id=" + $('option:selected', this).attr('uid') + " name=" + $(this).val());
        umfrage = getUmfrage(uid);
        log("Umfrage=" + umfrage.id);
        $("[id^='chart2']").empty();
        if (umfrage.active == 1) {
            toastr["warning"]("Gewählte Umfrage ist noch aktiv!", "Achtung!");
        }

        loadResults(uid, $('#gruppe2Filter').val(), function (data) {
            log("empfange :" + JSON.stringify(data));
            drawResults(data, 2);
        });
    });
}

function getUmfrage(id) {
    for (m = 0; m < umfragen.length; m++) {
        u = umfragen[m];
        log("Teste Umfrage " + u.titel);
        if (u.id == id) {
            log("Umfrage mit der id=" + id + " gefunden");
            return u;
        }
    }
    log("Keine Umfrage mit der id=" + id + " gefunden");
}

function updateAuswertung(data) {
    $("#tabelleUmfrageAuswertung").empty();
    log("upodate Auswertung data=" + JSON.stringify(data));
    for (i = 0; i < data.length; i++) {
        log("Update Auswertung frage=" + data[i].frage + " id=" + data[i].id);
        $("#tabelleUmfrageAuswertung").append('<tr><td>' + data[i].frage + '</td><td><div id="chart1' + data[i].id + '"></div></td><td><div id="chart2' + data[i].id + '"></div></td></tr>')
    }
}

/**
 * Beteiligung aktualisieren
 * @param {type} data
 * @returns {undefined}
 */
function updateBeteiligung(data) {
    for (i = 0; i < data.length; i++) {
        var eintraege = data[i];
        $("#U" + eintraege.schuelerId).text(eintraege.anzahlFragenBeantwortet + "/" + eintraege.anzahlFragen);
    }
}
/** 
 * POrtfolio Tabelle erzeugen
 * @param {type} data Portfolio Einträge pro Schüler
 */
function updatePortfolio(data) {

    var years = {};

    for (i = 0; i < data.length; i++) {
        eintraege = data[i].eintraege;
        for (j = 0; j < eintraege.length; j++) {
            if (years[eintraege[j].schuljahr] == undefined) {
                var year = {
                    "name": name,
                    "spalten": 0,
                    "courses": {}
                }
                year.name = eintraege[j].schuljahrName;
                years[eintraege[j].schuljahr] = year;
            }
        }
    }

    $.each(years, function (index, value) {
        wpk = false;
        //log("Bearbeite Schuljahr "+index);
        for (j = 0; j < data.length; j++) {
            eintrag = data[j].eintraege;
            for (i = 0; i < eintrag.length; i++) {
                if (eintrag[i].schuljahr == index) {
                    //log("Schuljahr ist das zu bearbeitende");
                    if (value.courses[eintrag[i].IDKlasse] == undefined) {
                        log("Neuer Kurs im Jahr  " + index + " mit Namen " + eintrag[i].KName + " und ID=" + eintrag[i].IDKlasse);
                        var course = {
                            "kname": "",
                            "kategorie": 0
                        }
                        course.kname = eintrag[i].KName;
                        course.kategorie = eintrag[i].IDKategorie;
                        value.courses[eintrag[i].IDKlasse] = course;
                        if (course.kategorie == 1 && wpk == false) {
                            value.spalten = value.spalten + 2;
                            wpk = true;
                        }
                        else if (course.kategorie != 1) {
                            value.spalten++;
                        }
                    }
                }
            }
        }
    });

    log("years=" + JSON.stringify(years));



    $("#headPortfolio").empty();
    $("#bodyPortfolio").empty();
    var head = '<tr><th width="25%" rowspan="2">Name</th>';
    $.each(years, function (index, value) {
        log("Überschrift für Jahr =" + value.name);
        head += '<th colspan="' + value.spalten + '">' + value.name + '</th>';
    });
    head += "</tr><tr>";

    $.each(years, function (index, value) {
        cs = value.courses;
        log(" Bearbiete " + value.name);
        wpk = false;
        $.each(cs, function (index, value) {
            log("Eintrag für " + value.kname + " Kategorie=" + value.kategorie);
            if (value.kategorie == 1) {
                if (wpk == false) {
                    head += '<th>WPK</th><th>Note</th>';
                    wpk = true;
                }
            }
            else {
                head += '<th>' + value.kname + ' (Note)';
            }
        });
    });

    head += "</tr>";
    $("#headPortfolio").append(head);


    var body;
    for (i = 0; i < schueler.length; i++) {
        body += "<tr>";
        body += '<td><img src="../img/Info.png" ids="' + schueler[i].id + '" class="infoIcon">&nbsp;' + schueler[i].VNAME + " " + schueler[i].NNAME + '</td>';

        $.each(years, function (indexYear, valueYear) {
            cs = valueYear.courses;
            //log(" Bearbiete " + valueYear.name);
            wpk = false;
            $.each(cs, function (index, value) {

                if (value.kategorie == 1 && wpk == false) {
                    log('Setzte ID=NameYear' + indexYear + 'kursidwpk' + '_' + schueler[i].id);
                    body += '<td id="NameYear' + indexYear + 'kursidwpk' + '_' + schueler[i].id + '">&nbsp;</td>';
                    body += '<td id="WertYear' + indexYear + 'kursidwpk' + '_' + schueler[i].id + '">&nbsp;</td>';
                    wpk = true;
                }
                else if (value.kategorie != 1) {
                    body += '<td id="WertYear' + indexYear + 'kursid' + index + '_' + schueler[i].id + '">&nbsp;</td>';
                }
            });
        });
        body += "</tr>";

    }
    $("#bodyPortfolio").append(body);

    // Werte Eintragen

    for (i = 0; i < data.length; i++) {
        eintraege = data[i].eintraege;

        for (j = 0; j < eintraege.length; j++) {
            eintrag = eintraege[j];

            if (eintrag.IDKategorie == 1) {
                log("Suche ID=#NameYear" + eintrag.schuljahr + "kursidwpk" + "_" + data[i].ID_Schueler);
                $("#NameYear" + eintrag.schuljahr + "kursidwpk" + "_" + data[i].ID_Schueler).text(eintrag.KName);
                $("#WertYear" + eintrag.schuljahr + "kursidwpk" + "_" + data[i].ID_Schueler).text(eintrag.wert);
            }
            else {
                //log("Suche ID=#WertYear" + eintrag.schuljahr + "kursid" + eintrag.IDKlasse + "_" + data[i].ID_Schueler);
                $("#WertYear" + eintrag.schuljahr + "kursid" + eintrag.IDKlasse + "_" + data[i].ID_Schueler).text(eintrag.wert);
            }
        }
    }


    getSchuelerInfo();

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
        //log("Betriebe=" + betriebe)
        for (i = 0; i < betriebe.length; i++) {
            adr = adr + betriebe[i].email + ";";
        }
        $("#emailsBetrieb").val(adr);
    }
}

/**
 * Mail Formular zum Anschreiben der Klasse aktualisieren
 */
function updateKlasseMails() {
    var adr = "";
    for (i = 0; i < schueler.length; i++) {
        adr = adr + schueler[i].EMAIL + ";";
    }
    $("#emailsKlasse").val(adr);

}

/**
 * Anwesenheit führen über Bilder Liste 
 */
function renderBilder() {
    // refreshAnwesenheit(nameKlasse, function () {
    $("#klassenBilder").empty();
    log("lade Bilder:");
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
        //log("key Code="+keyCode);
        if (keyCode == 13 || keyCode == 9) {
            $(this).blur()
            sid = $(this).attr("id");
            sid = sid.substring(3);
            txt = $("#ex1" + sid).val();
            log("key Pressed bemerkungTextFeld keyCode=" + keyCode + " Schüler ID=" + sid + " txt=" + txt + " bem=" + $(this).val());
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
            log("key Pressed AnwesenheitTextFeld keyCode=" + keyCode + " Schüler ID=" + sid);
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
        log("key Pressed bemerkungTextFeld" + keyCode);
    });

}

/**
 * Update der Bilderansicht beim Führen der Anwesenheit über Bilder
 */
function updateRenderBilder() {
    log("Update Render Bilder !");
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
                    //log("bemerkung Heute Schüler gefunden mit ID="+id+" einträge="+JSON.stringify(eintraege))
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
    log("buildNotenliste() schueler.length=" + schueler.length);
    for (j = 0; j < data.length; j++) {
        noten = data[j].noten;
        //log("Teste Lernfelder in "+JSON.stringify(noten));
        for (k = 0; k < noten.length; k++) {

            if (!findKeyinMap(noten[k].ID_LERNFELD, lernfelder)) {
                lernfelder[noten[k].ID_LERNFELD] = noten[k].nameLernfeld;
                log("Neues Lernfeld:" + noten[k].nameLernfeld);
            }
        }
    }
    // Tabelle aufbauen
    $("#trNoten").empty();
    $("#trNoten").append('<th width="20%"><h3>Name</h3></th>');
    $.each(lernfelder, function (index, value) {
        log("Index = " + index + " value = " + value);
        $("#trNoten").append('<th>' + value + '</th>')
    })
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
        log("Termine = " + JSON.stringify(termine));
        var tab = "";
        tab += '<thead><tr>';
        for (i = 0; i < termine.length; i++) {
            log("Add Termin: i=" + i);
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
                //log("suche html id " + id);
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
function log(msg) {
    //if (debug) {
    console.log(msg);
    //}
}
// Load the Visualization API and the corechart package.
google.charts.load('current', {'packages': ['corechart']});