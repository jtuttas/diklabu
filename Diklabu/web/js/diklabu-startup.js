// ID der gewählten Klasse
var idKlasse;
var nameKlasse;

$("#eintragDatum").datepicker("setDate", "+0");
var today = new Date();
$("#startDate").datepicker("setDate", new Date(today.getFullYear(), today.getMonth(), today.getDate() - 7));
$("#endDate").datepicker("setDate", new Date());

console.log("found token:"+sessionStorage.auth_token);
if (sessionStorage.auth_token!="undefined") {
    console.log("Build gui for logged in user");
    loggedIn();
}
$("#login").click(function () {
    if (sessionStorage.auth_token==undefined || sessionStorage.auth_token=="undefined") {
        var myData = {
            "benutzer": $("#lehrer").val(),
            "kennwort": $("#kennwort").val()
        };

        $.ajax({
            cache: false,
            contentType: "application/json; charset=UTF-8",
            headers: {
                "service_key": $("#lehrer").val() + "f80ebc87-ad5c-4b29-9366-5359768df5a1"
            },
            dataType: "json",
            url: "/Diklabu/api/v1/auth/login/",
            type: "POST",
            data: JSON.stringify(myData),
            success: function (jsonObj, textStatus, xhr) {
                sessionStorage.auth_token = jsonObj.auth_token;
                console.log("Thoken = " + jsonObj.auth_token);
                toastr["success"]("Login erfolgreich", "Info!");
                sessionStorage.myself = $("#lehrer").val();
                loggedIn();
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
                "service_key": sessionStorage.myself + "f80ebc87-ad5c-4b29-9366-5359768df5a1",
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
                toastr["error"]("Logout fehlgeschlagen", "Fehler!");
                console.log("HTTP Status: " + xhr.status);
                console.log("Error textStatus: " + textStatus);
                console.log("Error thrown: " + errorThrown);
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
            $("#lehrer").append("<option >" + data[i].id + "</option>");
        }
    },
    error: function () {
        toastr["error"]("kann Lehrerliste nicht vom Server laden", "Fehler!");
    }
});

function refreshVerlauf(kl) {
    console.log("Refresh Verlauf f. Klasse " + kl + " von " + $("#startDate").val() + " bis " + $("#endDate").val());
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/verlauf/" + kl + "/" + $("#startDate").val() + "/" + $("#endDate").val(),
        type: "GET",
        headers: {
            "service_key": sessionStorage.myself + "f80ebc87-ad5c-4b29-9366-5359768df5a1",
             "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            verlauf = data;
            $("#tabelleVerlauf").empty();
            for (i = 0; i < data.length; i++) {
                var datum = data[i].DATUM;
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
        error: function () {
            toastr["error"]("kann Verlauf nicht vom Server laden", "Fehler!");
        }
    });
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
                });
                $('#endDate').datepicker().on('changeDate', function (ev) {
                    refreshVerlauf($("#klassen").val());
                });
                $("#klassen").change(function () {
                    console.log("Klasse ID=" + $('option:selected', this).attr('dbid') + " KNAME=" + $("#klassen").val());
                    idKlasse = $('option:selected', this).attr('dbid');
                    refreshVerlauf($("#klassen").val());
                });

                $("#dokumentation").click(function () {
                    var from = $("#startDate").val();
                    var to = $("#endDate").val();
                    window.open('/Diklabu/DokuServlet?cmd=verlauf&idklasse=' + idKlasse + '&from=' + from + '&to=' + to);
                });
                refreshVerlauf(nameKlasse);

}