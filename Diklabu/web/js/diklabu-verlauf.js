// ID des gwählten Verlaufs
var idVerlauf;
// Verlaufs Objekt
var verlauf;

$("#deleteVerlauf").click(function () {
    if (!$("#deleteVerlauf").hasClass("disabled")) {
        console.log(" Verlaufseintrag ID=" + idVerlauf + " löschen!");
        if (idVerlauf != undefined) {
            bootbox.confirm("Sind Sie sicher, dass Sie den Entrag löschen wollen?", function (result) {
                console.log(result);
                if (result) {
                    $.ajax({
                        url: SERVER + "/Diklabu/api/v1/verlauf/" + idVerlauf,
                        type: "DELETE",
                        headers: {
                            "service_key": sessionStorage.service_key,
                            "auth_token": sessionStorage.auth_token
                        },
                        contentType: "application/json; charset=UTF-8",
                        success: function (data) {
                            $("#lernsituationVerlauf").val("");
                            $("#bemerkungVerlauf").val("");
                            $("#inhaltVerlauf").val("");
                            $("#updateVerlauf").addClass("disabled");
                            $("#deleteVerlauf").addClass("disabled");
                            refreshVerlauf($("#klassen").val());
                        },
                        error: function (xhr, textStatus, errorThrown) {
                            toastr["error"]("kann Datensatz nicht löschen! Status Code=" + xhr.status, "Fehler!");
                        }
                    });
                }
            });
        }
    }
});
$("#addVerlauf").click(function () {
    if ($("#inhaltVerlauf").val() == "") {
        toastr["warning"]("Bitte einen Inhalt eingeben", "Hinweis!");
    }
    else {

        var myData = {
            "AUFGABE": $("#lernsituationVerlauf").val(),
            "BEMERKUNG": $("#bemerkungVerlauf").val(),
            "DATUM": $("#eintragDatum").val() + "T00:00:00",
            "ID_KLASSE": idKlasse,
            "ID_LEHRER": sessionStorage.myself,
            "ID_LERNFELD": $("#lernfelder").val(),
            "INHALT": $("#inhaltVerlauf").val(),
            "STUNDE": $("#stunde").val()
        };

        console.log("sende:" + JSON.stringify(myData));

        $.ajax({
            url: SERVER + "/Diklabu/api/v1/verlauf",
            type: "POST",
            contentType: "application/json; charset=UTF-8",
            headers: {
                "service_key": sessionStorage.service_key,
                "auth_token": sessionStorage.auth_token
            },
            data: JSON.stringify(myData),
            success: function (data) {
                refreshVerlauf($("#klassen").val());
                var i = $("#stunde").prop('selectedIndex');
                i++;
                $("#stunde").prop('selectedIndex', i);
                if (!data.success) {
                    toastr["warning"](data.msg, "Warnung!");
                }
            },
            error: function (xhr, textStatus, errorThrown) {
                toastr["error"]("kann Datensatz nicht eintragen! Status Code=" + xhr.status, "Fehler!");
            }
        });
    }
});


$("#updateVerlauf").click(function () {
    if (!$("#updateVerlauf").hasClass("disabled")) {
    if ($("#inhaltVerlauf").val() == "") {
        toastr["warning"]("Bitte einen Inhalt eingeben", "Hinweis!");
    }
    else {

        var myData = {
            "AUFGABE": $("#lernsituationVerlauf").val(),
            "BEMERKUNG": $("#bemerkungVerlauf").val(),
            "DATUM": $("#eintragDatum").val() + "T00:00:00",
            "ID_KLASSE": idKlasse,
            "ID_LEHRER": sessionStorage.myself,
            "ID_LERNFELD": $("#lernfelder").val(),
            "INHALT": $("#inhaltVerlauf").val(),
            "STUNDE": $("#stunde").val()
        };

        console.log("sende:" + JSON.stringify(myData));

        $.ajax({
            url: SERVER + "/Diklabu/api/v1/verlauf",
            type: "POST",
            contentType: "application/json; charset=UTF-8",
            headers: {
                "service_key": sessionStorage.service_key,
                "auth_token": sessionStorage.auth_token
            },
            data: JSON.stringify(myData),
            success: function (data) {
                refreshVerlauf($("#klassen").val());
            },
            error: function (xhr, textStatus, errorThrown) {
                toastr["error"]("kann Datensatz nicht eintragen! Status Code=" + xhr.status, "Fehler!");
            }
        });
    }
}
});

