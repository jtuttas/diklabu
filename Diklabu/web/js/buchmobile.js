


var nameKlasse;
var schueler;
var schuelerBilder;

$("#version").text(VERSION);
$("#btnAnwesend").click(function () {
    $("#anwesenheitText").val("a");
    $("#anwesenheitDetails").popup("close");
    console.log("close");
});
$("#btnFehlend").click(function () {
    $("#anwesenheitText").val("f");
    $("#anwesenheitDetails").popup("close");
});
$("#btnEntschuldigt").click(function () {
    $("#anwesenheitText").val("e");
    $("#anwesenheitDetails").popup("close");
});
$("#btnOkAnwesenheit").click(function () {
    $("#anwesenheitDetails").popup("close");

});
$("#btnAddVerlauf").click(function () {
    console.log("Close Add Verlauf!");
    $("#addVerlauf").popup("close");
});
console.log("Load Klassenliste");


$.ajax({
    url: SERVER + "/Diklabu/api/v1/noauth/klassen",
    type: "GET",
    contentType: "application/json; charset=UTF-8",
    success: function (data) {
        $("#klassenListView").empty();

        for (i = 0; i < data.length; i++) {
            $("#klassenListView").append('<li><a href="#" class="selectKlasse ui-btn ui-btn-icon-right ui-icon-carat-r">' + data[i].KNAME + '</a></li>');
            console.log("append " + data[i].KNAME);
        }
        /*
         * Eine Klasse wird ausgewählt
         */
        $(".selectKlasse").click(function () {
            nameKlasse = $(this).text();
            console.log("nameKlasse=" + nameKlasse);
            $("#anwesenheitKlassenName").text($(this).text());
            refreshKlassenliste(nameKlasse);
            $.mobile.changePage("#anwesenheit", {transition: "fade"});
        });
    },
    error: function () {
        $.mobile.toast({
            message: "kann Klassenliste nicht vom Server laden"
        });
    }
});

$.ajax({
    url: SERVER + "/Diklabu/api/v1/noauth/lernfelder",
    type: "GET",
    contentType: "application/json; charset=UTF-8",
    success: function (data) {
        $("#lernfelder").empty();
        for (i = 0; i < data.length; i++) {
            $("#lernfelder").append('<option value="' + data[i].id + '">' + data[i].id + '</option>');
        }
    },
    error: function () {
        $.mobile.toast({
            message: "kann Lernfelder nicht vom Server laden"
        });


    }
});

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
            $("#namensListView").empty();
            for (i = 0; i < data.length; i++) {
                console.log("Füge Listview "+data[i].NNAME+" an");
                $("#namensListView").append('<li class="ui-li-has-alt ui-li-has-thumb "> <a href="#schuelerdetails" class="schueler ui-btn" sid="' + data[i].id + '"><img id="bild' + data[i].id +'" src="img/anonym.gif" ><h3>' + data[i].VNAME + " " + data[i].NNAME + '</h3><small>V60e</small></a><a href="#anwesenheitDetails" data-rel="popup" data-position-to="window" data-transition="popup" aria-haspopup="true" aria-owns="anwesenheitDetails" aria-expanded="false" class="ui-btn ui-btn-icon-notext ui-icon-gear ui-btn-a" title="Edit"></a></li>')
            }
            

            $(".schueler").click(function () {
                sid = $(this).attr("sid");
                console.log("klick auf Schueler mit id =" + sid);
                $("#detailName").text(getNameSchuler(sid));
                loadSchulerDaten(sid, function (data) {
                    $("#detailGeb").text(data.gebDatum);
                    if (data.ausbilder != undefined) {
                        $("#ausbilderName").text(data.ausbilder.NNAME);
                        $("#ausbilderTel").text("Tel.:" + data.ausbilder.TELEFON);
                        $("#ausbilderFax").text("Fax:" + data.ausbilder.FAX);
                        $("#ausbilderEmail").text("EMail:" + data.ausbilder.EMAIL);
                    }
                    if (data.betrieb != undefined) {
                        $("#betriebName").text(data.betrieb.NAME);
                        $("#betriebStrasse").text(data.betrieb.STRASSE);
                        $("#betriebOrt").text(data.betrieb.PLZ + " " + data.betrieb.ORT);
                    }
                    kurse = data.klassen;
                    for (i = 0; i < kurse.length; i++) {

                    }
                });
            });
            refreshBilderKlasse(kl);

        },
        error: function (xhr, textStatus, errorThrown) {
            $.mobile.toast({
                message: "kann Klassenliste f. Klasse " + kl + " nicht vom Server laden"
            });
        }
    });
}

function refreshBilderKlasse(kl) {
    console.log("Refresh Bilder f. Klasse " + kl);
    
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/klasse/" + kl+"/bilder64/80",
        type: "GET",
        cache: false,
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            console.log("bilder geldane!");
            schuelerBilder = data;
            for (i = 0; i < data.length; i++) {
                if (data[i].base64!=undefined) {
                $("#bild"+data[i].id).attr('src', "data:image/png;base64," + data[i].base64);
            }
                        
            }
        },
        error: function (xhr, textStatus, errorThrown) {
            $.mobile.toast({
                message: "kann Bilder d. Klasse " + kl + " nicht vom Server laden"
            });
        }
    });
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
            $.mobile.toast({
                message: "kann Schülerinfo ID=" + idSchueler + " nicht vom Server laden"
            });
        }
    });
}


