var anwesenheit;
sessionStorage.myself = "TU";

var toast=function(msg){
	$("<div class='ui-loader ui-overlay-shadow ui-body-e ui-corner-all'><h3>"+msg+"</h3></div>")
	.css({ display: "block", 
		opacity: 0.90, 
		position: "fixed",
		padding: "7px",
		"text-align": "center",
		width: "270px",
		left: ($(window).width() - 284)/2,
		top: $(window).height()/2 })
	.appendTo( $.mobile.pageContainer ).delay( 1500 )
	.fadeOut( 400, function(){
		$(this).remove();
	});
}

$("#version").text(VERSION);
$("#btnAnwesend").click(function () {
    $("#anwesenheitText").val("a");
    $("#anwesenheitDetails").popup("close");
    sid = $("#anwName").attr("sid");
    console.log("Übertrage Anwesenheit f. " + sid);
    commitAnwesenheit(sid, $("#anwesenheitText").val());
});
$("#btnFehlend").click(function () {
    $("#anwesenheitText").val("f");
    $("#anwesenheitDetails").popup("close");
    sid = $("#anwName").attr("sid");
    console.log("Übertrage Anwesenheit f. " + sid);
    commitAnwesenheit(sid, $("#anwesenheitText").val());
});
$("#btnEntschuldigt").click(function () {
    $("#anwesenheitText").val("e");
    $("#anwesenheitDetails").popup("close");
    sid = $("#anwName").attr("sid");
    console.log("Übertrage Anwesenheit f. " + sid);
    commitAnwesenheit(sid, $("#anwesenheitText").val());
});
$("#btnOkAnwesenheit").click(function () {
    $("#anwesenheitDetails").popup("close");
    sid = $("#anwName").attr("sid");
    console.log("Übertrage Anwesenheit f. " + sid);
    commitAnwesenheit(sid, $("#anwesenheitText").val());
});
 $('body').on('keydown', "#anwesenheitText", function(e) {
     var keyCode = e.keyCode || e.which;
    //console.log("key Pressed" + keyCode);
    if (keyCode == 13) {
        $("#anwesenheitDetails").popup("close");
        sid = $("#anwName").attr("sid");
    console.log("Übertrage Anwesenheit f. " + sid);
    commitAnwesenheit(sid, $("#anwesenheitText").val());
    }  
 });


function commitAnwesenheit(sid, txt) {
    dat = toSQLString(new Date());
    var eintr = {
        "DATUM": dat + "T00:00:00",
        "ID_LEHRER": sessionStorage.myself,
        "ID_SCHUELER": sid,
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
            setAnwesenheitsEintrag(sid, txt,data.parseError);
            if (data.parseError) {
                toast("Der Eintrag enthält Formatierungsfehler");                
            }
            
            renderAnwesenheit(anwesenheit);
        },
        error: function (xhr, textStatus, errorThrown) {
            $.mobile.toast({
                message: "kann Anwesenheitseintrag nicht zum Server senden!" + textStatus
            });
        }
    });
}


$("#btnAddVerlauf").click(function () {
    console.log("Close Add Verlauf!");
    $("#addVerlauf").popup("close");
});
$("#btnLogout").click(function () {
    console.log("Lösche sessionStorage!");
    sessionStorage.clear();
});


console.log("Load Klassenliste");

$(document).on("pagebeforeshow", "#anwesenheit", function () {
    console.log("Seite Anwesenheit wurde aktualisiert");
    refreshKlassenliste(sessionStorage.nameKlasse);
});

$("#btnRefresh").click(function () {
    console.log("Ansicht Klasse aktualisieren");
    refreshKlassenliste(sessionStorage.nameKlasse);   
});

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
        $("#klassenListView").append('<li><a href="#" class="selectKlasse ui-btn ui-btn-icon-right ui-icon-carat-r">' + data[i].KNAME + '</a></li>');
        //console.log("append " + data[i].KNAME);
    }
    /*
     * Eine Klasse wird ausgewählt
     */
    $(".selectKlasse").click(function () {
        kl = $(this).text();
        console.log("nameKlasse=" + kl);
        $("#anwesenheitKlassenName").text(kl);
        refreshKlassenliste(kl);
        $.mobile.changePage("#anwesenheit", {transition: "fade"});
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
    console.log("Refresh Klassenliste f. Klasse " + kl + " alte Klassenbezeichnung==" + sessionStorage.nameKlasse);

    if (sessionStorage.nameKlasse == kl && sessionStorage.schueler != undefined) {
        console.log("Schülerdaten schon geladen !");
        data = JSON.parse(sessionStorage.schueler);
        buildNamensliste(data);
        refreshBilderKlasse(kl);
        buildAnwesenheit(kl);
    }
    else {
        console.log("Schülerdaten vom Server geladen !");
        sessionStorage.nameKlasse = kl;
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
                sessionStorage.schueler = JSON.stringify(data);
                schueler = data;
                buildNamensliste(data);
                refreshBilderKlasse(kl);
                buildAnwesenheit(kl);
            },
            error: function (xhr, textStatus, errorThrown) {
                toast("kann Klassenliste f. Klasse " + kl + " nicht vom Server laden");
            }
        });
    }
}

function buildNamensliste(data) {
    $("#namensListView").empty();
    for (i = 0; i < data.length; i++) {
        //console.log("Füge Listview " + data[i].NNAME + " an");
        $("#namensListView").append('<li class="ui-li-has-alt ui-li-has-thumb "> <a href="#schuelerdetails" class="schueler ui-btn" sid="' + data[i].id + '"><img id="bild' + data[i].id + '" src="img/anonym.gif" ><h3>' + data[i].VNAME + " " + data[i].NNAME + '</h3><small id="anw' + data[i].id + '"></small></a><a sid="' + data[i].id + '" href="#anwesenheitDetails" data-rel="popup" data-position-to="window" data-transition="popup" aria-haspopup="true" aria-owns="anwesenheitDetails" aria-expanded="false" class="ui-btn ui-btn-icon-notext ui-icon-gear ui-btn-a setAnwesenheit" title="Edit"></a></li>')
    }
    $(".setAnwesenheit").click(function () {
        sid = $(this).attr("sid");
        console.log("klick Anwesenheitsetails id=" + sid);
        $("#anwName").text(getNameSchuler(sid));
        $("#anwName").attr("sid", sid);
        eintrag = getAnwesenheitsEintrag(sid);
        console.log("Vermekr=" + eintrag.VERMERK);
        $("#anwesenheitText").val(eintrag.VERMERK);
    });


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
}

function buildAnwesenheit(kl) {
    console.log("Abfrage Anwesenheit f. Klasse " + kl + " vom Server!");
    d = new Date();
    $("#currentDate").text(getReadableDate(d) + " " + d.getHours() + ":" + d.getMinutes() + ":" + d.getSeconds());
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/anwesenheit/" + kl,
        type: "GET",
        cache: false,
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        success: function (data) {
            console.log("Anwesenheit geladen!");
            anwesenheit = data;
            renderAnwesenheit(data);

        },
        error: function (xhr, textStatus, errorThrown) {
            toast("kann Anwesenheit d. Klasse " + kl + " nicht vom Server laden");
        }
    });

}

function renderAnwesenheit(data) {
    for (i = 0; i < data.length; i++) {
        $("#anw" + data[i].id_Schueler).removeClass("anwesend");
        $("#anw" + data[i].id_Schueler).removeClass("fehlend");
        $("#anw" + data[i].id_Schueler).removeClass("entschuldigt");
        $("#anw" + data[i].id_Schueler).removeClass("parseError");
        var v = data[i].eintraege[0].VERMERK;
        console.log("VERMERK = " + v + " id=" + data[i].id_Schueler);
        $("#anw" + data[i].id_Schueler).text(v);
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

    }
}
function refreshBilderKlasse(kl) {
    console.log("lade Bilder f. Klasse " + kl + " vom Server!");
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/klasse/" + kl + "/bilder64/80",
        type: "GET",
        cache: false,
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
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
        },
        error: function (xhr, textStatus, errorThrown) {
            toast("kann Bilder d. Klasse " + kl + " nicht vom Server laden");
        }
    });

}

function getNameSchuler(id) {
    var schueler = JSON.parse(sessionStorage.schueler);
    for (var i = 0; i < schueler.length; i++) {
        if (schueler[i].id == id) {
            console.log("Found Name for ID " + id + " " + schueler[i].VNAME + " " + schueler[i].NNAME)
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

function setAnwesenheitsEintrag(id, txt,err) {

    for (var i = 0; i < anwesenheit.length; i++) {
        if (anwesenheit[i].id_Schueler == id) {
            anwesenheit[i].eintraege[0].parseError=err;
            anwesenheit[i].eintraege[0].VERMERK = txt;
            anwesenheit[i].eintraege[0].ID_LEHRER = sessionStorage.myself;
            anwesenheit[i].eintraege[0].DATUM = toSQLString(new Date()) + "T00:00:00+01:00";
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
            toast("kann Schülerinfo ID=" + idSchueler + " nicht vom Server laden");
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

