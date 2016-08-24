var alleSchueler;
var alleKlassen;
var selectedSchueler;
var selectedMemberKlasseID;
var selectedMemberKNAME;
var selectedKlasseID;
var selectedKlasseKNAME;

log("found token:" + sessionStorage.auth_token);
if (sessionStorage.auth_token == undefined) {
    window.location.replace("index.html");
}
$("#diklabuname").text(DIKLABUNAME);
if (debug) {
    $("#version").text(VERSION + " (DEBUG)");
}
else {
    $("#version").text(VERSION);
}
$(document).ajaxSend(function (event, request, settings) {
    $('#loading-indicator').show();
});

$(document).ajaxComplete(function (event, request, settings) {
    $('#loading-indicator').hide();
});

$(document).ready(function () {
    if (sessionStorage.auth_token != undefined) {
        getPupils(function (data) {
            $("#sdata").empty();
            $('#loading-indicator').show();
            for (i = 0; i < data.length; i++) {
                s = data[i];
                $("#sdata").append('<tr sid="' + data[i].id + '" class="selectable"><td><img src="../img/Info.png" ids="' + data[i].id + '" class="infoIcon">&nbsp;' + s.NNAME + '</td><td>' + s.VNAME + '</td><td>' + s.GEBDAT + '</td></tr>')
            }
            $('#loading-indicator').hide();
            $('#filter').keyup(function () {
                var rex = new RegExp($(this).val(), 'i');
                $('.searchable tr').hide();
                $('.searchable tr').filter(function () {
                    return rex.test($(this).text());
                }).show();
                $("#stammdatenContainer").hide();
            });
            getSchuelerInfo();
            getCourses(function (data) {
                $("#klassen").empty();
                for (i = 0; i < data.length; i++) {
                    s = data[i];
                    $("#klassen").append('<a  kname="' + s.KNAME + '" kid="' + s.id + '" class="list-group-item searchableKlasses">' + s.KNAME + '</a>')
                }
                $('#filterClasses').keyup(function () {
                    var rex = new RegExp($(this).val(), 'i');
                    $('.searchableKlasses').hide();
                    $('.searchableKlasses').filter(function () {
                        return rex.test($(this).text());
                    }).show();
                    $("#btnAdd").addClass("disabled");
                    var count = 0;
                    $(".searchableKlasses").each(function () {
                        if ($(this).is(":visible")) {
                            count++;
                            selectedKNAME = $(this).attr("kname");
                            selectedKlasseID = $(this).attr("kid");
                        }
                    });
                    if (count == 1) {
                        $("#btnAdd").removeClass("disabled");
                    }

                });

            });
        });
    }
});

$('body').on('keydown', ".sinput", function (e) {
    var keyCode = e.keyCode || e.which;
    log("key Pressed" + keyCode+" id is "+$(this).attr("id"));
    if (keyCode == 13 || keyCode==9) {
        log("key Down Kennwort");
        s = {
            "ABGANG": $("#abgang").val(),
            "EMAIL": $("#email").val(),
            "GEBDAT": $("#gebdat").val(),
            "NNAME": $("#nname").val(),
            "VNAME": $("#vname").val()
        }
        log("Schueler is: "+JSON.stringify(s));
        setSchueler(selectedSchueler.id,s,function (data) {
            toastr["success"]("Daten geändert!", "Info!");
        });
    }
});

$("#abgang").change(function () {
        log("Abgang Changed" + $("#abgang").val());
        s = {
            "ABGANG": $("#abgang").val(),
            "EMAIL": $("#email").val(),
            "GEBDAT": $("#gebdat").val(),
            "NNAME": $("#nname").val(),
            "VNAME": $("#vname").val()
        }
        log("Schueler is: "+JSON.stringify(s));
        setSchueler(selectedSchueler.id,s,function (data) {
            toastr["success"]("Daten geändert!", "Info!");
        });
    });

$(document).on('click', '.selectable', function (e) {
    //alert("Klick on ID="+$(this).attr("sid"));
    $("#btnRemove").addClass("disabled");
    $("#btnAdd").addClass("disabled");
    $(".selectable").removeClass("selected");
    $(this).addClass("selected");
    loadSchulerDaten($(this).attr("sid"), function (data) {
        selectedSchueler = data;
        $("#nname").val(data.name);
        $("#vname").val(data.vorname);
        $("#email").val(data.email);
        $("#gebdat").val(data.gebDatum);
        $("#abgang").val(data.abgang);
        klassen = data.klassen;
        $("#memberklasse").empty();
        $("#stammdatenContainer").show();
        for (i = 0; i < klassen.length; i++) {
            klasse = klassen[i];
            $("#memberklasse").append(' <a kname="' + klasse.KNAME + '" mkid="' + klasse.id + '" class="list-group-item .selectable memberCourse">' + klasse.KNAME + '</a>');
        }
    });
    $("#btnAdd").addClass("disabled");
    var count = 0;
    $(".searchableKlasses").each(function () {
        if ($(this).is(":visible")) {
            count++;
        }
    });
    if (count == 1) {
        $("#btnAdd").removeClass("disabled");
    }
});
$(document).on('click', '.memberCourse', function (e) {
    //alert("Klick on ID="+$(this).attr("mkid"));
    $(".memberCourse").removeClass("selected");
    $(this).addClass("selected");
    $("#btnRemove").removeClass("disabled");
    selectedKlasseID = $(this).attr("mkid");
    selectedMemberKNAME = $(this).attr("kname");
});
$(document).on('click', '#klassen .list-group-item', function (e) {
    //alert("Klick on ID="+$(this).attr("kid"));
    $("#filterClasses").val($(this).attr("kname"));
    var rex = new RegExp($(this).attr("kname"), 'i');
    $('.searchableKlasses').hide();
    $('.searchableKlasses').filter(function () {
        return rex.test($(this).text());
    }).show();
    $("#btnAdd").removeClass("disabled");
    selectedKNAME = $(this).attr("kname");
    selectedKlasseID = $(this).attr("kid");
});
$(document).on('click', "#btnAdd", function (e) {
    bootbox.confirm("Sind Sie sicher, dass Sie den Schüler " + selectedSchueler.vorname + " " + selectedSchueler.name + " in die Klasse " + selectedKNAME + " aufnehmen wollen?", function (result) {
        if (result) {
            addCourseMember(selectedSchueler.id, selectedKlasseID, function (data) {
                if (data.success) {
                    toastr["success"]("Schüler " + selectedSchueler.vorname + " " + selectedSchueler.name + " in die Klasse " + selectedKNAME + " aufgenommen!", "Info!");
                    loadSchulerDaten(selectedSchueler.id, function (data) {
                        selectedSchueler = data;
                        $("#nname").val(data.name);
                        $("#vname").val(data.vorname);
                        $("#email").val(data.email);
                        $("#gebdat").val(data.gebDatum);
                        $("#abgang").val(data.abgang);
                        klassen = data.klassen;
                        $("#memberklasse").empty();
                        $("#stammdatenContainer").show();
                        for (i = 0; i < klassen.length; i++) {
                            klasse = klassen[i];
                            $("#memberklasse").append(' <a kname="' + klasse.KNAME + '" mkid="' + klasse.id + '" class="list-group-item .selectable memberCourse">' + klasse.KNAME + '</a>');
                        }
                    });
                }
                else {
                    toastr["error"](data.msg, "Fehler!");
                }
            });
        }
    });
});
$(document).on('click', "#login", function (e) {
    performLogout();
});
$(document).on('click', "#btnRemove", function (e) {
    bootbox.confirm("Sind Sie sicher, dass Sie den Schüler " + selectedSchueler.vorname + " " + selectedSchueler.name + " aus der Klasse " + selectedMemberKNAME + " entfernen wollen?", function (result) {
        log(result);
        if (result) {
            removeCourseMember(selectedSchueler.id, selectedKlasseID, function (data) {
                if (data.success) {
                    toastr["success"]("Schüler " + selectedSchueler.vorname + " " + selectedSchueler.name + " aus der Klasse " + selectedMemberKNAME + " entfernen!", "Info!");
                    loadSchulerDaten(selectedSchueler.id, function (data) {
                        selectedSchueler = data;
                        $("#nname").val(data.name);
                        $("#vname").val(data.vorname);
                        $("#email").val(data.email);
                        $("#gebdat").val(data.gebDatum);
                        $("#abgang").val(data.abgang);
                        klassen = data.klassen;
                        $("#memberklasse").empty();
                        $("#stammdatenContainer").show();
                        for (i = 0; i < klassen.length; i++) {
                            klasse = klassen[i];
                            $("#memberklasse").append(' <a kname="' + klasse.KNAME + '" mkid="' + klasse.id + '" class="list-group-item .selectable memberCourse">' + klasse.KNAME + '</a>');
                        }
                    });
                    $("#btnRemove").addClass("disabled");
                }
                else {
                    toastr["error"](data.msg, "Fehler!");
                }
            });

        }
    });
});

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
}

/**
 * 
 * -------------------------------------------------------------------------
 * 
 * AJAX Server Routinen 
 * 
 * -------------------------------------------------------------------------
 * 
 */

function performLogout() {
    var myData = {
        "benutzer": sessionStorage.myself,
        "kennwort": sessionStorage.kennwort
    };

    log("sende:"+JSON.stringify(myData));

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

            toastr["success"]("Logout erfolgreich", "Info!");
            delete sessionStorage.myself;
            delete sessionStorage.auth_token;
            window.location.replace("index.html");
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("Logout fehlgeschlagen!Status Code=" + xhr.status, "Fehler!");
            log("HTTP Status: " + xhr.status);
            log("Error textStatus: " + textStatus);
            log("Error thrown: " + errorThrown);
            delete sessionStorage.myself;
            delete sessionStorage.auth_token;
            window.location.replace("index.html");
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
                                performLogout();
                            }
                        }
                    });

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
                performLogout();
            }
        }
    });
}

function getCourses(callback) {
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/noauth/klassen",
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
            if (xhr.status == 401) {
                performLogout();
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
                performLogout();
            }
        }
    });
}

function removeCourseMember(idSchueler, idCourse, callback) {
    $.ajax({
        cache: false,
        contentType: "application/json; charset=UTF-8",
        dataType: "json",
        url: "/Diklabu/api/v1/klasse/verwaltung/" + idSchueler + "/" + idCourse,
        type: "DELETE",
        headers: {          
            "auth_token": sessionStorage.auth_token
        },
        success: function (jsonObj, textStatus, xhr) {
            log("Schüler gelöscht loaded");
            if (callback != undefined) {
                callback(jsonObj);
            }
        },
        error: function (xhr, textStatus, errorThrown) {
            log("HTTP Status: " + xhr.status);
            log("Error textStatus: " + textStatus);
            log("Error thrown: " + errorThrown);
            performLogout();
        }
    });
}
function addCourseMember(idSchueler, idCourse, callback) {
    var eintr = {
        "ID_SCHUELER": idSchueler,
        "ID_KLASSE": idCourse
    }
    $.ajax({
        cache: false,
        contentType: "application/json; charset=UTF-8",
        data: JSON.stringify(eintr),
        dataType: "json",
        url: "/Diklabu/api/v1/klasse/verwaltung/add",
        type: "POST",
                headers: {          
            "auth_token": sessionStorage.auth_token
        },

        success: function (jsonObj, textStatus, xhr) {
            log("Schüler add loaded");
            if (callback != undefined) {
                callback(jsonObj);
            }
        },
        error: function (xhr, textStatus, errorThrown) {
            log("HTTP Status: " + xhr.status);
            log("Error textStatus: " + textStatus);
            log("Error thrown: " + errorThrown);
            performLogout();
        }
    });
}

function setSchueler(idSchueler, data,callback) {
    $.ajax({
        cache: false,
        contentType: "application/json; charset=UTF-8",
        data: JSON.stringify(data),
        dataType: "json",
        url: "/Diklabu/api/v1/schueler/verwaltung/"+idSchueler,
        type: "POST",
                headers: {          
            "auth_token": sessionStorage.auth_token
        },

        success: function (jsonObj, textStatus, xhr) {
            if (callback != undefined) {
                callback(jsonObj);
            }
        },
        error: function (xhr, textStatus, errorThrown) {
            log("HTTP Status: " + xhr.status);
            log("Error textStatus: " + textStatus);
            log("Error thrown: " + errorThrown);
            performLogout();
        }
    });
}

function getPupils(callback) {
    log("getPupils");
    $.ajax({
        cache: false,
        contentType: "application/json; charset=UTF-8",
        headers: {
            "auth_token": sessionStorage.auth_token
        },
        dataType: "json",
        url: "/Diklabu/api/v1/schueler",
        type: "GET",
        success: function (jsonObj, textStatus, xhr) {
            log("getPupils success:" + jsonObj.length);
            if (callback != undefined) {
                callback(jsonObj);
            }
        },
        error: function (xhr, textStatus, errorThrown) {
            log("HTTP Status: " + xhr.status);
            log("Error textStatus: " + textStatus);
            log("Error thrown: " + errorThrown);
            performLogout();
        }
    });
}

function log(msg) {
    //if (debug) {
    console.log(msg);
    // }
}

