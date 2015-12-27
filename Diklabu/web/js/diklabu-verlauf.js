// ID des gwählten Verlaufs
var idVerlauf;
// Verlaufs Objekt
var verlauf;

$("#deleteVerlauf").click(function () {
    console.log(" Verlaufseintrag ID=" + idVerlauf + " löschen!");
    bootbox.confirm("Sind Sie sicher, dass Sie den Entrag löschen wollen?", function (result) {
        console.log(result);
        if (result) {
            $.ajax({
                url: SERVER + "/Diklabu/api/v1/verlauf/" + idVerlauf,
                type: "DELETE",
                contentType: "application/json; charset=UTF-8",
                success: function (data) {
                    $("#lernsituationVerlauf").val("");
                    $("#bemerkungVerlauf").val("");
                    $("#inhaltVerlauf").val("");
                    $("#updateVerlauf").addClass("disabled");
                    $("#deleteVerlauf").addClass("disabled");
                    refreshVerlauf($("#klassen").val());
                },
                error: function () {
                    toastr["error"]("kann Datensatz nicht löschen", "Fehler!");
                }
            });
        }
    });
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
            "ID_LEHRER": "TU",
            "ID_LERNFELD": $("#lernfelder").val(),
            "INHALT": $("#inhaltVerlauf").val(),
            "STUNDE": $("#stunde").val()
        };

        console.log("sende:" + JSON.stringify(myData));

        $.ajax({
            url: SERVER + "/Diklabu/api/v1/verlauf",
            type: "POST",
            contentType: "application/json; charset=UTF-8",
            data: JSON.stringify(myData),
            success: function (data) {
                refreshVerlauf($("#klassen").val());
            },
            error: function () {
                toastr["error"]("kann Datensatz nicht eintragen", "Fehler!");
            }
        });
    }
});


$("#updateVerlauf").click(function () {
    if ($("#inhaltVerlauf").val() == "") {
        toastr["warning"]("Bitte einen Inhalt eingeben", "Hinweis!");
    }
    else {

        var myData = {
            "AUFGABE": $("#lernsituationVerlauf").val(),
            "BEMERKUNG": $("#bemerkungVerlauf").val(),
            "DATUM": $("#eintragDatum").val() + "T00:00:00",
            "ID_KLASSE": idKlasse,
            "ID_LEHRER": "TU",
            "ID_LERNFELD": $("#lernfelder").val(),
            "INHALT": $("#inhaltVerlauf").val(),
            "STUNDE": $("#stunde").val()
        };

        console.log("sende:" + JSON.stringify(myData));

        $.ajax({
            url: SERVER + "/Diklabu/api/v1/verlauf",
            type: "POST",
            contentType: "application/json; charset=UTF-8",
            data: JSON.stringify(myData),
            success: function (data) {
                refreshVerlauf($("#klassen").val());
            },
            error: function () {
                toastr["error"]("kann Datensatz nicht eintragen", "Fehler!");
            }
        });
    }
});

