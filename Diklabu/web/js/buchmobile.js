var anwesenheit;
var verlaufId;
var lastAnnwesenheitUpdate;
var anwKlasse;
var verlaufData;
var verlaufDetailsIndex;

$(document).on({
    ajaxStart: function () {
        $.mobile.loading('show');
        console.log('getJSON starts...');
    },
    ajaxStop: function () {
        $.mobile.loading('hide');
        console.log('getJSON ends...');
    }


});

$(document).ready(function () {

    if (localStorage.myself != "undefined") {
        $("#benutzer").val(localStorage.myself);
    }
    if (sessionStorage.kennwort != "undefined") {
        $("#kennwort").val(sessionStorage.kennwort);
    }
    if (localStorage.auth_token != "undefined") {
        console.log("Bin eingeloggt habe auth Toke, aktualisiere Lehrer Data");
        getLehrerData(localStorage.myself);
    }
    if (navigator.userAgent.match(/Android/i)) {
        window.scrollTo(0, 1);
    }


});



var toast = function (msg) {
    $("<div class='ui-loader ui-overlay-shadow ui-body-e ui-corner-all'><h3>" + msg + "</h3></div>")
            .css({display: "block",
                opacity: 0.90,
                position: "fixed",
                padding: "7px",
                "text-align": "center",
                width: "270px",
                left: ($(window).width() - 284) / 2,
                top: $(window).height() / 2})
            .appendTo($.mobile.pageContainer).delay(1500)
            .fadeOut(400, function () {
                $(this).remove();
            });
}


$("#version").text(VERSION);





$("#btnVerlaufWeiter").click(function () {
    if (verlaufDetailsIndex < verlaufData.length - 1) {
        renderVerlaufDetails(++verlaufDetailsIndex);
    }
    else {
        console.log("kein weiterer Verlaufseintrag");
        verlaufDetailsIndex = 0;
        renderVerlaufDetails(verlaufDetailsIndex);
    }
});

$("#btnVerlaufZurueck").click(function () {
    if (verlaufDetailsIndex <= 0) {
        console.log("kein weiterer Verlaufseintrag");
        verlaufDetailsIndex = verlaufData.length - 1;
        renderVerlaufDetails(verlaufDetailsIndex);
    }
    else {
        renderVerlaufDetails(--verlaufDetailsIndex);
    }
});
$("#btnChangeBemerkung").click(function () {
    submitBemerkung($("#textBemerkung").val());
});


function submitBemerkung(bem) {
    var eintr = {
        "id": sessionStorage.idSchueler,
        "info": bem
    };

    console.log("Sende zum Server:" + JSON.stringify(eintr));

    $.ajax({
        url: SERVER + "/Diklabu/api/v1/schueler/" + sessionStorage.idSchueler,
        type: "POST",
        cache: false,
        data: JSON.stringify(eintr),
        headers: {
            "service_key": localStorage.service_key,
            "auth_token": localStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            renderSchuelerDetails(sessionStorage.idSchueler);
        },
        error: function (xhr, textStatus, errorThrown) {
            toast("kann Bemerkung nicht zum Server senden!");
            if (xhr.status == 401) {
                performLogout();
            }
        }
    });
}

function toUrlString(d) {
    std = d.getHours();
    min = d.getMinutes();
    sec = d.getSeconds();
    if (std < 10) {
        std = "0" + std;
    }
    if (min < 10) {
        min = "0" + min;
    }
    if (sec < 10) {
        sec = "0" + sec;
    }
    return toSQLString(d) + "T" + std + ":" + min + ":" + sec;
}

$("#btnAnwesend").click(function () {
    $("#anwesenheitText").val("a");
    $("#anwesenheitDetails").popup("close");
    sid = $("#anwName").attr("sid");
    console.log("Übertrage Anwesenheit f. " + sid);
    commitAnwesenheit(sid, $("#anwesenheitText").val(), $("#anwBemerkung").val());
});
$("#btnFehlend").click(function () {
    $("#anwesenheitText").val("f");
    $("#anwesenheitDetails").popup("close");
    sid = $("#anwName").attr("sid");
    console.log("Übertrage Anwesenheit f. " + sid);
    commitAnwesenheit(sid, $("#anwesenheitText").val(), $("#anwBemerkung").val());
});
$("#btnEntschuldigt").click(function () {
    $("#anwesenheitText").val("e");
    $("#anwesenheitDetails").popup("close");
    sid = $("#anwName").attr("sid");
    console.log("Übertrage Anwesenheit f. " + sid);
    commitAnwesenheit(sid, $("#anwesenheitText").val(), $("#anwBemerkung").val());
});
$("#btnOkAnwesenheit").click(function () {
    if ($("#anwesenheitText").val() == "") {
        toast("Kein Vermerk angeben!");
    }
    else {
        $("#anwesenheitDetails").popup("close");
        sid = $("#anwName").attr("sid");
        console.log("Übertrage Anwesenheit f. " + sid);
        commitAnwesenheit(sid, $("#anwesenheitText").val(), $("#anwBemerkung").val());
    }
});
$('body').on('keydown', "#anwesenheitText", function (e) {
    var keyCode = e.keyCode || e.which;
    //console.log("key Pressed" + keyCode);
    if (keyCode == 13) {
        $("#anwesenheitDetails").popup("close");
        sid = $("#anwName").attr("sid");
        console.log("Übertrage Anwesenheit f. " + sid);
        commitAnwesenheit(sid, $("#anwesenheitText").val(), $("#anwBemerkung").val());
    }
});

$("#btnLogin").click(function () {
    performLogin();
});
$("#btnLogout").click(function () {
    performLogout();
})

function getIdPlain(id) {
    out = ""
    for (i = 0; i < id.length; i++) {
        c = id.charAt(i);
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

function performLogin() {
    if (localStorage.auth_token == undefined || localStorage.auth_token == "undefined") {
        benutzer = $("#benutzer").val();
        benutzer = benutzer.toUpperCase();
        idplain = getIdPlain(benutzer);
        var myData = {
            "benutzer": idplain,
            "kennwort": $("#kennwort").val()
        };



        $.ajax({
            cache: false,
            contentType: "application/json; charset=UTF-8",
            headers: {
                "service_key": idplain + "f80ebc87-ad5c-4b29-9366-5359768df5a1"
            },
            dataType: "json",
            url: "/Diklabu/api/v1/auth/login/",
            type: "POST",
            data: JSON.stringify(myData),
            success: function (jsonObj, textStatus, xhr) {
                console.log("Login receive " + JSON.stringify(jsonObj));
                localStorage.auth_token = jsonObj.auth_token;
                console.log("Thoken = " + jsonObj.auth_token);
                console.log("idplain = " + jsonObj.idPlain);
                localStorage.service_key = jsonObj.idPlain + "f80ebc87-ad5c-4b29-9366-5359768df5a1";
                console.log("Service key =" + localStorage.service_key);
                localStorage.myself = jsonObj.ID_LEHRER;
                getLehrerData(jsonObj.ID_LEHRER);

                sessionStorage.kennwort = $('#kennwort').val();
                $.mobile.changePage("#klassenliste", {transition: "fade"});
            },
            error: function (xhr, textStatus, errorThrown) {
                toast("Login fehlgeschlagen");
                console.log("HTTP Status: " + xhr.status);
                console.log("Error textStatus: " + textStatus);
                console.log("Error thrown: " + errorThrown);
            }
        });
    }
    else {
        $.mobile.changePage("#klassenliste", {transition: "fade"});
    }
}

function performLogout() {

    var myData = {
        "benutzer": localStorage.myself,
        "kennwort": sessionStorage.lennwort
    };

    $.ajax({
        cache: false,
        contentType: "application/json; charset=UTF-8",
        headers: {
            "service_key": localStorage.service_key,
            "auth_token": localStorage.auth_token
        },
        dataType: "json",
        url: "/Diklabu/api/v1/auth/logout/",
        type: "POST",
        data: JSON.stringify(myData),
        success: function (jsonObj, textStatus, xhr) {
            sessionStorage.clear();
            localStorage.clear();
            $("#benutzer").val("");
            $("#kennwort").val("");
            $.mobile.changePage("#login", {transition: "fade"});

        },
        error: function (xhr, textStatus, errorThrown) {
            toast("Logout fehlgeschlagen! Status Code=" + xhr.status);
            sessionStorage.clear();
            localStorage.clear();
            $("#benutzer").val("");
            $("#kennwort").val("");
            $.mobile.changePage("#login", {transition: "fade"});
        }
    });

}


function commitAnwesenheit(sid, txt, bem) {
    dat = toSQLString(new Date());
    if (bem == "") {
        var eintr = {
            "DATUM": dat + "T00:00:00",
            "ID_LEHRER": localStorage.myself,
            "ID_SCHUELER": sid,
            "VERMERK": txt,
            "ID_KLASSE": sessionStorage.idKlasse
        };
    }
    else {
        var eintr = {
            "DATUM": dat + "T00:00:00",
            "ID_LEHRER": localStorage.myself,
            "ID_SCHUELER": sid,
            "VERMERK": txt,
            "BEMERKUNG": bem,
            "ID_KLASSE": sessionStorage.idKlasse
        };

    }


    console.log("Sende zum Server:" + JSON.stringify(eintr));
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/anwesenheit/",
        type: "POST",
        cache: false,
        data: JSON.stringify(eintr),
        headers: {
            "service_key": localStorage.service_key,
            "auth_token": localStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            setAnwesenheitsEintrag(sid, txt, bem, data.parseError);
            if (data.parseError) {
                toast("Der Eintrag enthält Formatierungsfehler");
            }
            buildAnwesenheit(sessionStorage.nameKlasse);

        },
        error: function (xhr, textStatus, errorThrown) {
            toast("kann Anwesenheitseintrag nicht zum Server senden!");
            if (xhr.status == 401) {
                performLogout();
            }
        }
    });
}

$("#klassenEintragAktualisieren").click(function () {
    console.log("Aktualisiere KlassenEintrag f. id =" + sessionStorage.idKlasse)
    var eintr = {
        "NOTIZ": $("#klDetailsBemerklungen").val()
    }
    commitKlassenBemerkung(eintr, sessionStorage.idKlasse);
});

function commitKlassenBemerkung(eintr, klid) {
    console.log("Sende zum Server:" + JSON.stringify(eintr));
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/klasse/details/" + klid,
        type: "POST",
        cache: false,
        data: JSON.stringify(eintr),
        headers: {
            "service_key": localStorage.service_key,
            "auth_token": localStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            $("#klassenDetails").popup("close");
        },
        error: function (xhr, textStatus, errorThrown) {
            toast("kann Klassenbemerkung nicht zum Server senden!");
            if (xhr.status == 401) {
                performLogout();
            }
            else {
                $("#klassenDetails").popup("close");
            }
        }
    });
}

$("#newVerlauf").click(function () {
    console.log("new Verlauf");
    $("#std").prop('selectedIndex', 0);
    $("#std").change();
    $("#lf").prop('selectedIndex', 0);
    $("#lf").change();

    $("#lernsituation").val("");
    $("#inhalt").val("");
    $("#bemerkungen").val("");
    verlaufId = -1;
    $("#addVerlauf").popup("open");

});

$("#btnAddVerlauf").click(function () {
    console.log(" Add Verlauf!");
    if ($("#inhalt").val() == "") {
        toast("Geben Sie eine Inhalt an!");
    }
    else {
        d = new Date();

        var verlauf = {
            "AUFGABE": $("#lernsituation").val(),
            "BEMERKUNG": $("#bemerkungen").val(),
            "DATUM": toSQLString(d) + "T00:00:00",
            "ID_KLASSE": sessionStorage.idKlasse,
            "ID_LEHRER": localStorage.myself,
            "ID_LERNFELD": $("#lf").val(),
            "INHALT": $("#inhalt").val(),
            "STUNDE": $("#std").val()
        };
        submitVerlauf(verlauf);
    }

});
$("#btnDeleteVerlauf").click(function () {
    console.log("Delete Verlauf! id=" + verlaufId);
    if (verlaufId == -1) {
        // toast("Löschen nicht möglich!");
    }
    else {
        deleteVerlauf(verlaufId);
    }
    $("#addVerlauf").popup("close");
});
$("#btnLogout").click(function () {
    console.log("Lösche sessionStorage!");
    sessionStorage.clear();
});

function deleteVerlauf(id) {

    $.ajax({
        url: SERVER + "/Diklabu/api/v1/verlauf/" + id,
        type: "DELETE",
        cache: false,
        headers: {
            "service_key": localStorage.service_key,
            "auth_token": localStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            console.log("Verlauf gelöscht success=" + data.success);
            if (!data.success) {
                toast(data.msg);
            }
            loadVerlauf();
        },
        error: function (xhr, textStatus, errorThrown) {
            toast("kann Verlauf nicht löschen!");
            if (xhr.status == 401) {
                performLogout();
            }
        }
    });
}

function submitVerlauf(verl) {

    console.log("Sende zum Server:" + JSON.stringify(verl));

    $.ajax({
        url: SERVER + "/Diklabu/api/v1/verlauf/",
        type: "POST",
        cache: false,
        data: JSON.stringify(verl),
        headers: {
            "service_key": localStorage.service_key,
            "auth_token": localStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            console.log("Verlauf eingetragedetails success=" + data.success);
            if (!data.success) {
                toast(data.msg);
            }
            loadVerlauf();
            idx = $("#std").prop('selectedIndex');
            console.log("selected INdex =" + idx);
            idx++;
            $("#std").prop('selectedIndex', idx);
            $("#std").change();

        },
        error: function (xhr, textStatus, errorThrown) {
            toast("kann Verlauf nicht zum Server senden!");
            if (xhr.status == 401) {
                performLogout();
            }
        }
    });
}

console.log("Load Klassenliste");

$(document).on("pagebeforecreate", "#anwesenheit", function () {
    if (localStorage.auth_token == undefined) {
        console.log("Habe kein auth Token");
        $.mobile.changePage("#login", {transition: "fade"});
    }
    else {
        console.log("Seite Anwesenheit wurde aktualisiert:pagebeforecreate");
        lastAnnwesenheitUpdate = undefined;
        refreshKlassenliste(sessionStorage.nameKlasse);
    }
});
$(document).on("pagebeforeshow", "#anwesenheit", function () {
    console.log("Seite Anwesenheit wurde sichtbar:pagebeforeshow");
    //buildAnwesenheit(sessionStorage.nameKlasse);
});

$(document).on("pagebeforecreate", "#login", function () {
    if (localStorage.auth_token == undefined) {
        console.log("Habe kein auth Token");

    }
    else {
        $.mobile.changePage("#klassenliste", {transition: "fade"});
    }
});
$(document).on("pagebeforeshow", "#schuelerdetails", function () {
    if (localStorage.auth_token == undefined) {
        console.log("Habe kein auth Token");
        $.mobile.changePage("#login", {transition: "fade"});
    }
    else {
        console.log("Seite schuelerdetails wurde aktualisiert");

        $("#imgSchueler").attr("src", '../img/loading.gif');
        renderSchuelerDetails(sessionStorage.idSchueler);
    }
});
$(document).on("pagebeforeshow", "#verlauf", function () {
    if (localStorage.auth_token == undefined) {
        console.log("Habe kein auth Token");
        $.mobile.changePage("#login", {transition: "fade"});
    }
    else {
        console.log("Seite verkauf wurde aktualisiert");
        loadVerlauf();
    }
});
$(document).on("pagebeforeshow", "#about", function () {
    if (localStorage.auth_token == undefined) {
        console.log("Habe kein auth Token");
        $.mobile.changePage("#login", {transition: "fade"});
    }
    else {

    }
});
$(document).on("pagebeforeshow", "#klassenliste", function () {
    if (localStorage.auth_token == undefined) {
        console.log("Habe kein auth Token");
        $.mobile.changePage("#login", {transition: "fade"});
    }
    else {
        console.log("Zeige Klassenliste aktualisieren Vertretungsplan");
        getLehrerData(localStorage.myself);
    }
});
$(document).on("pagebeforecreate", "#verlaufDetail", function () {
    if (localStorage.auth_token == undefined) {
        console.log("Habe kein auth Token");
        $.mobile.changePage("#login", {transition: "fade"});
    }
    else {
        $.mobile.changePage("#verlauf", {transition: "fade"});
    }
});


$("#btnRefresh").click(function () {
    console.log("Ansicht Klasse aktualisieren");
    lastAnnwesenheitUpdate=undefined;
    refreshKlassenliste(sessionStorage.nameKlasse);
});


$("#btnDetailsZurueck").click(function () {
    $("#imgSchueler").attr("src", '../img/loading.gif');
    sessionStorage.idSchueler = prevSchueler();
    renderSchuelerDetails(sessionStorage.idSchueler);
});
$("#btnDetailsWeiter").click(function () {
    $("#imgSchueler").attr("src", '../img/loading.gif');
    sessionStorage.idSchueler = nextSchueler();
    renderSchuelerDetails(sessionStorage.idSchueler);
});


function prevSchueler() {
    var s = JSON.parse(sessionStorage.schueler);
    prev = s[0].id;
    for (var i = 1; i < s.length; i++) {
        if (s[i].id == sessionStorage.idSchueler) {
            return prev;
        }
        prev = s[i].id;
    }
    return s[s.length - 1].id;
}

function nextSchueler() {
    var s = JSON.parse(sessionStorage.schueler);
    for (var i = 0; i < s.length - 1; i++) {
        if (s[i].id == sessionStorage.idSchueler) {
            return s[i + 1].id;
        }
    }
    return s[0].id;
}

// Bild Upload Button gedrückt
$('#bildUploadForm').on('submit', (function (e) {
    e.preventDefault();
    var formData = new FormData(this);
    if ($("#fileBild").val() == "") {
        console.log("kein Bild gewählt");
        toast("kein Bild gewählt!");
    }
    else {
        console.log("Upload Bild f. Schüler " + sessionStorage.idSchueler);
        $("#uploadBildButton").hide();
        $.ajax({
            type: 'POST',
            url: SERVER + "/Diklabu/api/v1/schueler/bild/" + sessionStorage.idSchueler,
            data: formData,
            headers: {
                "service_key": localStorage.service_key,
                "auth_token": localStorage.auth_token
            },
            cache: false,
            contentType: false,
            processData: false,
            success: function (data) {
                console.log("success");
                if (data.success) {
                    getSchuelerBild(sessionStorage.idSchueler, "#imgSchueler");
                    $("#imgSchueler").replaceWith($("#imgSchueler").val('').clone(true));
                    $("#fileBild").val("");
                }
                else {
                    toast(data.msg);

                }
            },
            error: function (xhr, textStatus, errorThrown) {
                console.log("error");
                toast("Fehler beim Hochladen des Bildes!");
                if (xhr.status == 401) {
                    performLogout();
                }
            }
        });
    }
}));


function getLehrerData(le) {
    if (le != undefined) {
        console.log("Get Lehrer Data für " + le + "service Key=" + localStorage.service_key + " auth Token=" + localStorage.auth_token);
        $.ajax({
            url: SERVER + "/Diklabu/api/v1/lehrer/" + le,
            type: "GET",
            headers: {
                "service_key": localStorage.service_key,
                "auth_token": localStorage.auth_token
            },
            contentType: "application/json; charset=UTF-8",
            success: function (data) {
                $("#lehrerShort").text(le);
                if (data.stdPlan != undefined) {
                    $("#btnStdPlanLehrer").attr("href", data.stdPlan);
                    $("#btnStdPlanLehrer").show();
                }
                else {
                    $("#btnStdPlanLehrer").hide();
                }
                if (data.vPlan != undefined) {
                    $("#btnVertrPlanLehrer").attr("href", data.vPlan);
                    $("#btnVertrPlanLehrer").show();
                }
                else {
                    $("#btnVertrPlanLehrer").hide();
                }
            },
            error: function () {
                toast("kann Daten für " + le + " nicht vom Server laden");
            }
        });
    }
}

if (sessionStorage.klassen != undefined) {
    console.log("Liste der Klassen bereits geladen!");
    data = JSON.parse(sessionStorage.klassen);
    buildKlassenListeView(data);
}
else {
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/noauth/klassen",
        type: "GET",
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            sessionStorage.klassen = JSON.stringify(data);
            buildKlassenListeView(data);
        },
        error: function () {
            toast("kann Klassenliste nicht vom Server laden");
        }
    });
}

function buildKlassenListeView(data) {
    $("#klassenListView").empty();


    for (i = 0; i < data.length; i++) {
        //$("#klassenListView").append('<li><a href="#" klname="' + data[i].KNAME + '"  klid="' + data[i].id + '" class="selectKlasse ui-btn ui-btn-icon-right ui-icon-carat-r"><p class="ui-li-aside">' + data[i].ID_LEHRER + '</p>' + data[i].KNAME + '</a></li>');
        $("#klassenListView").append('<li class="ui-li-has-alt"><a href="#" klname="' + data[i].KNAME + '"  klid="' + data[i].id + '" class="selectKlasse ui-btn ui-btn-icon-right ui-icon-carat-r"><p class="ui-li-aside">' + data[i].ID_LEHRER + '</p>' + data[i].KNAME + '</a><a href="#" klid="' + data[i].id + '" data-rel="popup" data-position-to="window" data-transition="popup" aria-haspopup="true" aria-owns="klassenDetails" aria-expanded="false" class="ui-btn ui-btn-icon-notext ui-icon-info ui-btn-a klassendetails" title="Info"></a></li>');
        //console.log("append " + data[i].KNAME);
    }
    /*
     * Eine Klasse wird ausgewählt
     */
    $(".selectKlasse").click(function () {
        kl = $(this).attr("klname");
        klid = $(this).attr("klid");
        sessionStorage.idKlasse = klid;
        console.log("nameKlasse=" + kl + "idKlasse=" + klid);
        $("#namensListView").empty();
        refreshKlassenliste(kl);
        $.mobile.changePage("#anwesenheit", {transition: "fade"});
    });

    /*
     * Details Einer Klasse wird ausgewählt
     */
    $(".klassendetails").click(function () {
        klid = $(this).attr("klid");
        sessionStorage.idKlasse = klid;
        console.log("Details der Klasse id=" + klid);
        $.ajax({
            url: SERVER + "/Diklabu/api/v1/klasse/details/" + klid,
            type: "GET",
            cache: false,
            headers: {
                "service_key": localStorage.service_key,
                "auth_token": localStorage.auth_token
            },
            contentType: "application/json; charset=UTF-8",
            success: function (data) {
                $("#klDetailsName").text(data.KNAME);
                console.log("Empfange:" + JSON.stringify(data));
                if (data.TITEL != undefined) {
                    $("#klDetailsTitel").text(data.TITEL)
                    $("#pklDetailsTitel").show();
                }
                else {
                    $("#pklDetailsTitel").hide();
                }
                if (data.ID_LEHRER != undefined) {
                    lname = "";
                    if (data.LEHRER_VNAME != undefined) {
                        lname = data.LEHRER_VNAME + " ";
                    }
                    if (data.LEHRER_NNAME != undefined) {
                        lname = lname + data.LEHRER_NNAME;
                    }
                    $("#klDetailsKlassenlehrer").text(lname);
                    $("#klDetailsKlassenlehrerKurz").text(" (" + data.ID_LEHRER + ")");
                    $("#klDetailsKlassenlehrerMail").text(data.LEHRER_EMAIL);
                    $("#klDetailsKlassenlehrerMail").attr("href", "mailto:" + data.LEHRER_EMAIL);
                    if (data.LEHRER_TELEFON != undefined && data.LEHRER_TELEFON.length >= 3) {
                        $("#klDetailsKlassenlehrerTel").text(data.LEHRER_TELEFON);
                        $("#klDetailsKlassenlehrerTel").attr("href", "tel:" + data.LEHRER_TELEFON);
                        $("#klDetailsKlassenlehrerTel").show();
                    }
                    else {
                        $("#klDetailsKlassenlehrerTel").hide();
                    }
                }
                else {
                }
                $("#klDetailsBemerklungen").val(data.NOTIZ);
                if (data.stundenplan != undefined) {
                    $("#klDetailsStundenplan").attr("href", data.stundenplan);
                    $("#klDetailsStundenplan").show();
                }
                else {
                    $("#klDetailsStundenplan").hide();
                }
                if (data.vertretungsplan != undefined) {
                    $("#klDetailsVertretungsplan").attr("href", data.vertretungsplan);
                    $("#klDetailsVertretungsplan").show();
                }
                else {
                    $("#klDetailsVertretungsplan").hide();
                }
                $("#klassenDetails").popup("open");

            },
            error: function (xhr, textStatus, errorThrown) {
                toast("Kann Details der Klasse niocht laden");
                if (xhr.status == 401) {
                    performLogout();
                }
            }
        });
    });


}

if (sessionStorage.lernfelder != undefined) {
    console.log("Liste der Lernfelder bereits geladen!");
    data = JSON.parse(sessionStorage.lernfelder);
    $("#lernfelder").empty();
    for (i = 0; i < data.length; i++) {
        $("#lernfelder").append('<option value="' + data[i].id + '">' + data[i].id + '</option>');
    }

}
else {
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/noauth/lernfelder",
        type: "GET",
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            sessionStorage.lernfelder = JSON.stringify(data);
            $("#lernfelder").empty();
            for (i = 0; i < data.length; i++) {
                $("#lernfelder").append('<option value="' + data[i].id + '">' + data[i].id + '</option>');
            }
        },
        error: function () {
            toast("kann Lernfelder nicht vom Server laden");


        }
    });
}

function refreshKlassenliste(kl) {

    $("#anwContainer").hide();
    $(".loadingContainer").show();

    console.log("Refresh Klassenliste f. Klasse " + kl + " alte Klassenbezeichnung==" + sessionStorage.nameKlasse);
    $("#anwesenheitKlassenName").text(kl);
    if (sessionStorage.nameKlasse == kl && sessionStorage.schueler != undefined) {
        console.log("Schülerdaten schon geladen !");

        data = JSON.parse(sessionStorage.schueler);
        buildNamensliste(data);
        $.mobile.loading('show');
        refreshBilderKlasse(kl);
        buildAnwesenheit(kl);
    }
    else {
        console.log("Schülerdaten vom Server geladen !");
        console.log("service_key=" + localStorage.service_key);
        console.log("auth_token=" + localStorage.auth_token);
        sessionStorage.nameKlasse = kl;
        $.ajax({
            url: SERVER + "/Diklabu/api/v1/klasse/" + kl,
            type: "GET",
            cache: false,
            headers: {
                "service_key": localStorage.service_key,
                "auth_token": localStorage.auth_token
            },
            contentType: "application/json; charset=UTF-8",
            success: function (data) {
                sessionStorage.schueler = JSON.stringify(data);
                schueler = data;
                buildNamensliste(data);
                refreshBilderKlasse(kl);
                buildAnwesenheit(kl);
            },
            error: function (xhr, textStatus, errorThrown) {
                toast("kann Klassenliste f. Klasse " + kl + " nicht vom Server laden");

                if (xhr.status == 401) {
                    performLogout();
                }
            }
        });
    }
}

function loadVerlauf() {
    $("#verlaufList").empty();
    d = new Date();
    $("#currentDateVerlauf").text(getReadableDate(d) + " " + d.getHours() + ":" + d.getMinutes() + ":" + d.getSeconds());
    $("#verlaufNameKlasse").text(sessionStorage.nameKlasse);
    console.log("Lade Verlauf für Klasse " + sessionStorage.nameKlasse);
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/verlauf/" + sessionStorage.nameKlasse,
        type: "GET",
        cache: false,
        headers: {
            "service_key": localStorage.service_key,
            "auth_token": localStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            console.log("Verlauf Empfangen");
            verlaufData = data;
            renderVerlauf(data);
            $("#addVerlauf").popup("close");
        },
        error: function (xhr, textStatus, errorThrown) {
            toast("kann Verlauf f. Klasse " + sessionStorage.nameKlasse + " nicht vom Server laden");
            if (xhr.status == 401) {
                performLogout();
            }
        }
    });
}

function renderVerlauf(data) {
    console.log("renderVerlauf eintäge=" + data.length);
    $("#datumAddVerlauf").text(getReadableDate(new Date()));

    for (i = 0; i < data.length; i++) {
        verlauf = data[i];
        console.log("appen " + verlauf.INHALT);
        $("#verlaufList").append('<li class="ui-li-has-alt"><a href="#" index="' + i + '" class="ui-btn detailVerlauf"><h1>Std. ' + verlauf.STUNDE + '</h1><small>' + verlauf.INHALT + '</small><p class="ui-li-aside"><span class="lehrer">' + verlauf.ID_LERNFELD + '</span><strong>' + verlauf.ID_LEHRER + '</strong></p></a><a href="#" index="' + i + '" verlaufId="' + data[i].ID + '" data-rel="popup" data-position-to="window" data-transition="popup" aria-haspopup="true" aria-owns="addVerlauf" aria-expanded="false" class="ui-btn ui-btn-icon-notext ui-icon-gear ui-btn-a editVerlauf" title="Edit"></a></li>');
    }
    $(".detailVerlauf").click(function () {
        index = $(this).attr("index");
        verlaufDetailsIndex = index;
        renderVerlaufDetails(index);
        console.log("Detail Verlauf index = " + index);
        $.mobile.changePage("#verlaufDetail", {transition: "fade"});
    });

    $(".editVerlauf").click(function () {
        index = $(this).attr("index");
        verlaufId = $(this).attr("verlaufId");
        console.log("Edit Verlauf index = " + index + " verlaufId=" + verlaufId);
        if (data[index].ID_LEHRER != localStorage.myself) {
            toast("Sie können nur eigene Einträge editieren!");
        }
        else {
            $("#lf").val(data[index].ID_LERNFELD);
            $("#lf").change();
            $("#std").val(data[index].STUNDE);
            $("#std").change();
            $("#lernsituation").val(data[index].AUFGABE);
            $("#inhalt").val(data[index].INHALT);
            $("#bemerkungen").val(data[index].BEMERKUNG);
            $("#addVerlauf").popup("open");
        }
    });
}

function renderVerlaufDetails(index) {
    $("#nameKlasseVerlaufDetail").text(sessionStorage.nameKlasse);
    $("#lfVerlaufDetail").text(verlaufData[index].ID_LERNFELD);
    $("#stdVerlaufDetail").text("Std. " + verlaufData[index].STUNDE);
    $("#lehrerVerlaufDetail").text(verlaufData[index].ID_LEHRER);
    $("#lsVerlaufDetail").text(verlaufData[index].AUFGABE);
    $("#inhaltVerlaufDetail").text(verlaufData[index].INHALT);
    $("#bemVerlaufDetail").text(verlaufData[index].BEMERKUNG);

}

function buildNamensliste(data) {
    $("#namensListView").empty();
    for (i = 0; i < data.length; i++) {
        //console.log("Füge Listview " + data[i].NNAME + " an");
        $("#namensListView").append('<li class="ui-li-has-alt ui-li-has-thumb "> <a sid="' + data[i].id + '" href="#anwesenheitDetails" data-rel="popup" data-position-to="window" data-transition="popup" aria-haspopup="true" aria-owns="anwesenheitDetails" aria-expanded="false" class="setAnwesenheit ui-btn" ><img id="bild' + data[i].id + '" src="../img/anonym.gif" ><p id="anwLehrer' + data[i].id + '" class="ui-li-aside anwClear"></p><h3>' + data[i].VNAME + " " + data[i].NNAME + '</h3><small id="anw' + data[i].id + '" class="anwClear"></small><span ><img id="flag' + data[i].id + '" class="flag" src="../img/flag.png"></span></a><a sid="' + data[i].id + '" href="#schuelerdetails"  class="ui-btn ui-btn-icon-notext ui-icon-info ui-btn-a schueler" title="Edit"></a></li>')
    }

    $(".setAnwesenheit").click(function () {
        sid = $(this).attr("sid");
        console.log("klick Anwesenheitsetails id=" + sid);
        $("#anwName").text(getNameSchuler(sid));
        $("#anwName").attr("sid", sid);
        eintrag = getAnwesenheitsEintrag(sid);
        console.log("Vermekr=" + eintrag.VERMERK);
        $("#anwesenheitText").val(eintrag.VERMERK);
        $("#anwBemerkung").val(eintrag.BEMERKUNG)
    });


    $(".schueler").click(function () {
        sid = $(this).attr("sid");
        console.log("klick auf Schueler mit id =" + sid);
        sessionStorage.idSchueler = sid;
        //renderSchuelerDetails(sid);
    });

}


function renderSchuelerDetails(sid) {
    $("#detailName").text(getNameSchuler(sid));
    $("#editBemerkungName").text(getNameSchuler(sid));

    loadSchulerDaten(sid, function (data) {

        $("#detailGeb").text("Geb.:" + getReadableDate(data.gebDatum));
        if (data.email != undefined) {
            $("#detailEmail").show();
            $("#detailEmail").text(data.email);
            $("#detailEmail").attr("href", "mailto:" + data.email);
        }
        else {
            $("#detailEmail").hide();
        }
        if (data.ausbilder != undefined) {
            $("#ausbilderName").text(data.ausbilder.NNAME);
            $("#ausbilderTel").text(data.ausbilder.TELEFON);
            $("#ausbilderTel").attr("href", "tel:" + data.ausbilder.TELEFON);
            $("#ausbilderFax").text("Fax:" + data.ausbilder.FAX);
            $("#ausbilderEmail").text(data.ausbilder.EMAIL);
            $("#ausbilderEmail").attr("href", "mailto:" + data.ausbilder.EMAIL);
        }
        else {
            $("#ausbilderName").text("");
            $("#ausbilderTel").text("Tel.:");
            $("#ausbilderTel").attr("href", "#");
            $("#ausbilderFax").text("Fax:");
            $("#ausbilderEmail").text("EMail:");
            $("#ausbilderEmail").attr("href", "#");

        }
        if (data.betrieb != undefined) {
            $("#betriebName").text(data.betrieb.NAME);
            $("#betriebName").attr("href", "https://www.google.de/maps/place/" + data.betrieb.STRASSE + "," + data.betrieb.PLZ + "+" + data.betrieb.ORT);
            $("#betriebStrasse").text(data.betrieb.STRASSE);
            $("#betriebOrt").text(data.betrieb.PLZ + " " + data.betrieb.ORT);
        }
        else {
            $("#betriebName").text("N.N.");
            $("#betriebName").attr("href", "#");
            $("#betriebStrasse").text("");
            $("#betriebOrt").text("");

        }
        kurse = data.klassen;
        $("#klassenCount").text(kurse.length);
        $("#detailsKlassenListView").empty();
        for (i = 0; i < kurse.length; i++) {
            $("#detailsKlassenListView").append('<li> <a href="#" kid="' + kurse[i].id + '"  kname="' + kurse[i].KNAME + '"class="ui-btn ui-btn-icon-right ui-icon-carat-r detailsKlasse"><b>' + kurse[i].KNAME + '</b></a></li>');
        }
        $(".detailsKlasse").click(function () {
            var kname = $(this).attr("kname");
            sessionStorage.idKlasse = $(this).attr("kid");
            console.log("Wechsel zu Klasse " + kname + "mit ID=" + sessionStorage.idKlasse);
            refreshKlassenliste(kname);
            $.mobile.changePage("#anwesenheit", {transition: "fade"});
        });

        $("#textBemerkung").val(data.info);
        getSchuelerBild(sid, "#imgSchueler");
    });
}
/**
 * Anzeige des Schülerbiles einer Schülers
 * @param {type} id
 * @returns {undefined}
 */
function getSchuelerBild(id, elem) {
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/schueler/bild/" + id,
        cache: false,
        headers: {
            "service_key": localStorage.service_key,
            "auth_token": localStorage.auth_token
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
                            "service_key": localStorage.service_key,
                            "auth_token": localStorage.auth_token
                        },
                        success: function (data) {
                            console.log("Bild Daten geladen:" + data.id + " elem=" + elem);
                            data = data.base64.replace(/(?:\r\n|\r|\n)/g, '');
                            $(elem).attr('src', "data:image/png;base64," + data);

                        },
                        error: function (xhr, textStatus, errorThrown) {
                            toastr["error"]("kann Schülerbild ID=" + id + " nicht vom Server laden", "Fehler!");
                            if (xhr.status == 401) {
                                performLogout();
                            }
                        }
                    });

                }
    });
}

function buildAnwesenheit(kl) {
    d = new Date();
    if (anwKlasse != kl || anwesenheit == undefined || lastAnnwesenheitUpdate == undefined || d.getTime() > lastAnnwesenheitUpdate + 1000 * 60 * 60) {
        console.log(" Aktualisierung der Anwesenheit !");
        console.log("Abfrage Anwesenheit f. Klasse " + kl + " vom Server!");

        lastAnnwesenheitUpdate = d.getTime();
        anwKlasse = kl;
        $("#currentDate").text(getReadableDate(d) + " " + d.getHours() + ":" + d.getMinutes() + ":" + d.getSeconds());
        $.ajax({
            url: SERVER + "/Diklabu/api/v1/anwesenheit/" + kl,
            type: "GET",
            cache: false,
            headers: {
                "service_key": localStorage.service_key,
                "auth_token": localStorage.auth_token
            },
            contentType: "application/json; charset=UTF-8",
            success: function (data) {
                console.log("Anwesenheit geladen!");
                anwesenheit = data;
                renderAnwesenheit(data);

            },
            error: function (xhr, textStatus, errorThrown) {
                toast("kann Anwesenheit d. Klasse " + kl + " nicht vom Server laden");
                if (xhr.status == 401) {
                    performLogout();
                }
            }
        });
    }
    else {
        console.log("Anwesenheit ist wohl aktuell !" + lastAnnwesenheitUpdate + "anwesenheit=" + anwesenheit);
        renderAnwesenheit(anwesenheit);
    }

}

function renderAnwesenheit(data) {
    $(".anwClear").text("");
    $(".anwClear").removeClass("parseError");
    $(".anwClear").removeClass("anwesend");
    $(".anwClear").removeClass("fehlend");
    $(".anwClear").removeClass("entschuldigt");

    $(".flag").hide();
    for (i = 0; i < data.length; i++) {
        $("#anw" + data[i].id_Schueler).removeClass("anwesend");
        $("#anw" + data[i].id_Schueler).removeClass("fehlend");
        $("#anw" + data[i].id_Schueler).removeClass("entschuldigt");
        $("#anw" + data[i].id_Schueler).removeClass("parseError");
        var v = data[i].eintraege[0].VERMERK;
        v=v.trim();
        console.log("VERMERK = (" + v + ") id=" + data[i].id_Schueler);
        $("#anw" + data[i].id_Schueler).text(v);
        $("#anwLehrer" + data[i].id_Schueler).text(data[i].eintraege[0].ID_LEHRER);

        if (data[i].eintraege[0].parseError) {
            $("#anw" + data[i].id_Schueler).addClass("parseError");
        }
        else if (v.charAt(0) == 'a') {
            $("#anw" + data[i].id_Schueler).addClass("anwesend");
        }
        else if (v.charAt(0) == 'f') {
            $("#anw" + data[i].id_Schueler).addClass("fehlend");
        }
        else if (v.charAt(0) == 'e') {
            $("#anw" + data[i].id_Schueler).addClass("entschuldigt");
        }
        var b = data[i].eintraege[0].BEMERKUNG;
        if (b != undefined && b != "") {
            console.log("Habe eine Bemerkung gefunden und zeige Fahne an!");
            $("#flag" + data[i].id_Schueler).show();
        }

    }
}
function refreshBilderKlasse(kl) {
    console.log("lade Bilder f. Klasse " + kl + " vom Server!");
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/klasse/" + kl + "/bilder64/80",
        type: "GET",
        cache: false,
        headers: {
            "service_key": localStorage.service_key,
            "auth_token": localStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            console.log("bilder geladee!");
            sessionStorage.schuelerBilder = data;

            for (i = 0; i < data.length; i++) {
                if (data[i].base64 != undefined) {
                    $("#bild" + data[i].id).attr('src', "data:image/png;base64," + data[i].base64);
                }

            }
            $(".loadingContainer").hide();
            $("#anwContainer").show();
        },
        error: function (xhr, textStatus, errorThrown) {
            toast("kann Bilder d. Klasse " + kl + " nicht vom Server laden");
            $(".loadingContainer").hide();
            $("#anwContainer").show();
            if (xhr.status == 401) {
                performLogout();
            }

        }
    });

}

function getNameSchuler(id) {
    var schueler = JSON.parse(sessionStorage.schueler);
    for (var i = 0; i < schueler.length; i++) {
        if (schueler[i].id == id) {
            console.log("Found Name for ID " + id + " " + schueler[i].VNAME + " " + schueler[i].NNAME);
            return schueler[i].VNAME + " " + schueler[i].NNAME;
        }
    }
    return "unknown ID " + id;
}
function getAnwesenheitsEintrag(id) {

    for (var i = 0; i < anwesenheit.length; i++) {
        if (anwesenheit[i].id_Schueler == id) {
            console.log("Found Eintrag for ID " + id + " Vermekr ist " + anwesenheit[i].eintraege[0].VERMERK);
            return anwesenheit[i].eintraege[0];
        }
    }
    return "unknown ID " + id;
}

function setAnwesenheitsEintrag(id, txt, bem, err) {
    console.log("setAnwesenheit id=" + id + " txt=" + txt + " bem=" + bem);
    for (var i = 0; i < anwesenheit.length; i++) {
        if (anwesenheit[i].id_Schueler == id) {
            anwesenheit[i].eintraege[0].parseError = err;
            anwesenheit[i].eintraege[0].VERMERK = txt;
            anwesenheit[i].eintraege[0].ID_LEHRER = localStorage.myself;
            anwesenheit[i].eintraege[0].BEMERKUNG = bem;
            anwesenheit[i].eintraege[0].DATUM = toSQLString(new Date()) + "T00:00:00+01:00";
            return;
        }
    }
    console.log("Ein neuer Eintrag!");
    var anw = {
        "id_Schueler": id,
        "eintraege": [{
                "DATUM": toSQLString(new Date()) + "T00:00:00",
                "ID_LEHRER": localStorage.myself,
                "ID_SCHUELER": id,
                "VERMERK": txt,
                "parseError": err,
                "BEMERKUNG": bem
            }]
    };
    i = anwesenheit.length;
    anwesenheit.push(anw);
    console.log("Neuen Eintrag erzeugt:" + JSON.stringify(anwesenheit[i]));
}


function loadSchulerDaten(id, callback) {
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/schueler/" + id,
        type: "GET",
        headers: {
            "service_key": localStorage.service_key,
            "auth_token": localStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            callback(data);
        },
        error: function (xhr, textStatus, errorThrown) {
            toast("kann Schülerinfo ID=" + idSchueler + " nicht vom Server laden");
            if (xhr.status == 401) {
                performLogout();
            }
        }
    });
}

function getReadableDate(d) {
    var date = new Date(d);
    return "" + date.getDate() + "." + (date.getMonth() + 1) + "." + date.getFullYear();
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

