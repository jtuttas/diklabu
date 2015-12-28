// ID der gewählten Klasse
var idKlasse;
// Eingeloggter Lehrer
var myself = "TU";


$("#eintragDatum").datepicker("setDate", "+0");
var today = new Date();
$("#startDate").datepicker("setDate", new Date(today.getFullYear(), today.getMonth(), today.getDate() - 7));
$("#endDate").datepicker("setDate", new Date());

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
    window.open('/Diklabu/DokuServlet?cmd=verlauf&idklasse='+idKlasse+'&from='+from+'&to='+to);
});


$.ajax({
    url: SERVER + "/Diklabu/api/v1/klasse",
    type: "GET",
    contentType: "application/json; charset=UTF-8",
    success: function (data) {
        $("#klassen").empty();
        for (i = 0; i < data.length; i++) {
            $("#klassen").append("<option dbid='" + data[i].id + "'>" + data[i].KNAME + "</option>");
        }
        refreshVerlauf(data[0].KNAME);
        idKlasse = data[0].id;
    },
    error: function () {
        toastr["error"]("kann Klassenliste nicht vom Server laden", "Fehler!");
    }
});
$.ajax({
    url: SERVER + "/Diklabu/api/v1/lernfelder",
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
    url: SERVER + "/Diklabu/api/v1/lehrer",
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
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            verlauf=data;
            $("#tabelleVerlauf").empty();
            for (i = 0; i < data.length; i++) {
                var datum = data[i].DATUM;
                datum = datum.substring(0, datum.indexOf('T'));
                if (data[i].ID_LEHRER==myself) {
                    $("#tabelleVerlauf").append("<tr dbid='"+data[i].ID+"' index='"+i+"' class='success'><td>" + datum + "</td><td>" + data[i].ID_LEHRER + "</td><td>" + data[i].ID_LERNFELD + "</td><td>" + data[i].STUNDE + "</td><td>" + data[i].INHALT + "</td><td>" + data[i].BEMERKUNG + "</td><td>" + data[i].AUFGABE + "</td></tr>");
                }
                else {
                    $("#tabelleVerlauf").append("<tr dbid='"+data[i].ID+"' index='"+i+"' ><td>" + datum + "</td><td>" + data[i].ID_LEHRER + "</td><td>" + data[i].ID_LERNFELD + "</td><td>" + data[i].STUNDE + "</td><td>" + data[i].INHALT + "</td><td>" + data[i].BEMERKUNG + "</td><td>" + data[i].AUFGABE + "</td></tr>");                    
                }
            }
            $(".success").click(function () {
                console.log("Auswahl Verlaufseintrag ID="+$(this).attr("dbid"));
                idVerlauf=$(this).attr("dbid");
                index = $(this).attr("index");
                $("#lernsituationVerlauf").val(verlauf[index].AUFGABE);
                $("#bemerkungVerlauf").val(verlauf[index].BEMERKUNG);
                $("#inhaltVerlauf").val(verlauf[index].INHALT);
                var dat = verlauf[index].DATUM;
                dat=dat.substring(0,dat.indexOf('T'));
                $("#eintragDatum").val(dat);
                var lf = verlauf[index].ID_LERNFELD;
                lf=lf.trim();
                console.log("Setze Lernfeld auf ("+lf+")");
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