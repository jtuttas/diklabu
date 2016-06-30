
var courseList;
var wuensche = new Array(3);
if (debug) {
    $("#version").text(VERSION+" (Debug)");
    }
    else {
        $("#version").text(VERSION);
    }
getCourseList();

$("#btnAbfragen").click(function () {
    if ($("#benutzername2").val() == "" || $("#kennwort2").val() == "") {
        toastr["info"]("Bitte die Anmeldedaten vollständig ausfüllen!", "Information");
    }
    else {

        performLogin($("#benutzername2").val(), $("#kennwort2").val(), function (data) {
            log("--> Empfange:" + JSON.stringify(data));
            sessionStorage.auth_token = data.auth_token;
            sessionStorage.myself = data.ID;
            sessionStorage.myemail = data.email;
            sessionStorage.VNAME = data.VNAME;
            sessionStorage.NNAME = data.NNAME;
            if (data.role == "Admin" || data.role == "Lehrer") {

            }
            else {
                sessionStorage.kname = data.nameKlasse;
                sessionStorage.idKlasse = data.idKlasse;
                log("kname=" + sessionStorage.kname + " idKlasse=" + sessionStorage.idKlasse);
                getKurswunsch(function (data) {
                    if (data.courseList != undefined && data.courseList.length != 0) {
                        $("#erstWunschAbfragen").text(data.courseList[0].TITEL + " (" + data.courseList[0].ID_LEHRER + ")");
                        $("#zweitWunschAbfragen").text(data.courseList[1].TITEL + " (" + data.courseList[1].ID_LEHRER + ")");
                        $("#drittWunschAbfragen").text(data.courseList[2].TITEL + " (" + data.courseList[2].ID_LEHRER + ")");
                        if (data.selectedCourse != undefined) {
                            $("#zuteilung").text(data.selectedCourse.TITEL + " (" + data.selectedCourse.ID_LEHRER + ")");
                            toastr["success"]("Kurs zugeteilt!", "Information");
                        }
                        else {
                            $("#zuteilung").text("Ihnen wurde noch kein Kurs zugeteilt");
                            toastr["info"]("Ihnen wurde noch kein Kurs zugeteilt!", "Information");

                        }
                    }
                    else {
                        $("#erstWunschAbfragen").text("kein Kurs gewählt");
                        $("#zweitWunschAbfragen").text("kein Kurs gewählt");
                        $("#drittWunschAbfragen").text("kein Kurs gewählt");
                        $("#zuteilung").text("Ihnen wurde noch kein Kurs zugeteilt");
                        //window.location.href = "#kurswahl";
                        toastr["warning"]("Sie haben noch keinen Kurs gewählt!", "Information");
                        $("#benutzername").val($("#benutzername2").val());
                        $("#kennwort").val($("#kennwort2").val());
                        $("#lnkKurswahl").trigger("click");
                    }
                    perfromLogout($("#benutzername2").val(), $("#kennwort2").val());
                });
            }
        }, function () {
            $("#erstWunschAbfragen").text("?");
            $("#zweitWunschAbfragen").text("?");
            $("#drittWunschAbfragen").text("?");
            $("#zuteilung").text("?");
        });
    }
});

function perfromLogout(benutzer, kennwort, callback) {
    var myData = {
        "benutzer": benutzer,
        "kennwort": kennwort
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
            sessionStorage.clear();
            log("--> Logout: " + JSON.stringify(jsonObj));
            if (callback != undefined) {
                callback(jsonObj);
            }
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("Logout fehlgeschlagen!Status Code=" + xhr.status, "Fehler!");
            log("HTTP Status: " + xhr.status);
            log("Error textStatus: " + textStatus);
            log("Error thrown: " + errorThrown);
        }
    });
}

function performLogin(benutzer, kennwort, callback, error) {
    log("perform Login benutzer=" + benutzer + " kennwort=" + kennwort);

    var myData = {
        "benutzer": benutzer,
        "kennwort": kennwort
    };
    $.ajax({
        cache: false,
        contentType: "application/json; charset=UTF-8",
        dataType: "json",
        url: "/Diklabu/api/v1/auth/login/",
        type: "POST",
        data: JSON.stringify(myData),
        success: function (jsonObj, textStatus, xhr) {
            callback(jsonObj);
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("Login fehlgeschlagen", "Fehler!");
            log("HTTP Status: " + xhr.status);
            log("Error textStatus: " + textStatus);
            log("Error thrown: " + errorThrown);
            if (error != undefined) {
                log("call error Handler!");
                error();
            }
        }
    });
}


$("#btnWaehlen").click(function () {
    if ($("#benutzername").val() == "" || $("#kennwort").val() == "") {
        toastr["info"]("Bitte die Anmeldedaten vollständig ausfüllen!", "Information");
    }
    else {
        if (wuensche[0] == undefined || wuensche[1] == undefined || wuensche[2] == undefined) {
            toastr["info"]("Bitte drei Kurse Wünschen!", "Information");
        }
        else {
            performLogin($("#benutzername").val(), $("#kennwort").val(), function (data) {
                log("--> Empfange:" + JSON.stringify(data));
                sessionStorage.auth_token = data.auth_token;
                sessionStorage.myself = data.ID;
                sessionStorage.myemail = data.email;
                sessionStorage.VNAME = data.VNAME;
                sessionStorage.NNAME = data.NNAME;
                if (data.role == "Admin" || data.role == "Lehrer") {

                }
                else {
                    sessionStorage.kname = data.nameKlasse;
                    sessionStorage.idKlasse = data.idKlasse;
                    log("kname=" + sessionStorage.kname + " idKlasse=" + sessionStorage.idKlasse);
                    submitKurswunsch(function (data) {
                        log("buchen finished" + JSON.stringify(data));
                        if (data.success == false) {
                            toastr["error"](data.msg, "Fehler!");
                            $("#erstWunschAbfragen").text(data.courseList[0].TITEL + " (" + data.courseList[0].ID_LEHRER + ")");
                            $("#zweitWunschAbfragen").text(data.courseList[1].TITEL + " (" + data.courseList[1].ID_LEHRER + ")");
                            $("#drittWunschAbfragen").text(data.courseList[2].TITEL + " (" + data.courseList[2].ID_LEHRER + ")");
                            if (data.selectedCourse != undefined) {
                                $("#zuteilung").text(data.selectedCourse.TITEL + " (" + data.selectedCourse.ID_LEHRER + ")");
                            }
                            else {
                                $("#zuteilung").text("Ihnen wurde noch kein Kurs zugeteilt");

                            }
                            //window.location.href = "#results";
                            $("#benutzername2").val($("#benutzername").val());
                            $("#kennwort2").val($("#kennwort").val());
                            $("#lnkResults").trigger("click");
                        }
                        else {
                            toastr["success"](data.msg, "OK!");

                            $("li").removeClass("disabled");
                            $("#erstWunsch").text("kein Kurs gewählt");
                            $("#zweitWunsch").text("kein Kurs gewählt");
                            $("#drittWunsch").text("kein Kurs gewählt");
                            $("#erstWunschAbfragen").text(wuensche[0].TITEL + " (" + wuensche[0].ID_LEHRER + ")");
                            $("#zweitWunschAbfragen").text(wuensche[1].TITEL + " (" + wuensche[1].ID_LEHRER + ")");
                            $("#drittWunschAbfragen").text(wuensche[2].TITEL + " (" + wuensche[2].ID_LEHRER + ")");
                            //window.location.href = "#results";
                            $("#benutzername2").val($("#benutzername").val());
                            $("#kennwort2").val($("#kennwort").val());
                            $("#lnkResults").trigger("click");
                        }
                        perfromLogout($("#benutzername").val(), $("#kennwort").val(), function (data) {
                            $("#benutzername").val("");
                            $("#kennwort").val("");
                        });
                    });
                }
            });
        }
    }
});

function submitKurswunsch(callback) {
    log("Wunsche=" + JSON.stringify(wuensche));

    var ticketing = {
        courseList: wuensche
    };
    log("ticketing=" + JSON.stringify(ticketing));
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/sauth/kursbuchung/" + sessionStorage.myself,
        type: "POST",
        contentType: "application/json; charset=UTF-8",
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        dataType: "json",
        data: JSON.stringify(ticketing),
        success: function (data) {
            callback(data);
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("Kursbuchung fehlgeschlagen", "Fehler!");
            log("HTTP Status: " + xhr.status);
            log("Error textStatus: " + textStatus);
            log("Error thrown: " + errorThrown);
        }
    });

}

function getKurswunsch(callback) {
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/sauth/kursbuchung/" + sessionStorage.myself,
        type: "GET",
        headers: {
            "service_key": sessionStorage.service_key,
            "auth_token": sessionStorage.auth_token
        },
        contentType: "application/json; charset=UTF-8",
        dataType: "json",
        success: function (data) {
            callback(data);
        },
        error: function (xhr, textStatus, errorThrown) {
            toastr["error"]("Kursbuchungsabfrage fehlgeschlagen", "Fehler!");
            log("HTTP Status: " + xhr.status);
            log("Error textStatus: " + textStatus);
            log("Error thrown: " + errorThrown);
        }
    });
}

function getCourseList() {
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/noauth/getcourses",
        type: "GET",
        contentType: "application/json; charset=UTF-8",
        dataType: "json",
        error: function () {
            toastr["error"]("Kann Kursliste nicht vom Server laden!", "Fehler!");
        },
        success: function (data) {
            log("receive Course List" + JSON.stringify(data));
            courseList = data;
            wuensche = new Array(3);
            $("#erstWunschDropdown").empty();
            $("#zweitWunschDropdown").empty();
            $("#drittWunschDropdown").empty();
            for (var i = 0; i < courseList.length; i++) {
                $("#erstWunschDropdown").append('<li  id="w1' + i + '" role="presentation" ><a kursid="' + i + '" role="menuitem" tabindex="-1" href="#f">' + courseList[i].TITEL + '</a></li>')
                $("#zweitWunschDropdown").append('<li  id="w2' + i + '" role="presentation" ><a kursid="' + i + '" role="menuitem" tabindex="-1" href="#f">' + courseList[i].TITEL + '</a></li>')
                $("#drittWunschDropdown").append('<li  id="w3' + i + '" role="presentation" ><a kursid="' + i + '"role="menuitem" tabindex="-1" href="#f">' + courseList[i].TITEL + '</a></li>')
            }
            $('#erstWunschDropdown li > a').click(function (e) {
                var index = $(this).attr('kursid');
                log("index = " + index + " class=" + $("#w1" + index).attr("class"));
                if ($("#w1" + index).attr("class") != "disabled") {
                    $('#erstWunsch').text(this.innerHTML);
                    if (wuensche[0] != undefined) {
                        log("Es existierte bereits ein Erstwunsch mit id=" + wuensche[0].id);
                        var i = findWunschbyId(wuensche[0].id);
                        log("Dieser hat den index " + i);
                        $("#w1" + i).removeClass("disabled");
                        $("#w2" + i).removeClass("disabled");
                        $("#w3" + i).removeClass("disabled");
                    }
                    var course = courseList[index];
                    log("Gewählt wurde:" + course.TITEL);
                    wuensche[0] = course;
                    $("#w1" + index).addClass("disabled");
                    $("#w2" + index).addClass("disabled");
                    $("#w3" + index).addClass("disabled");
                }
            });
            $('#zweitWunschDropdown li > a').click(function (e) {
                var id = $(this).attr('kursid');
                if ($("#w2" + id).attr("class") != "disabled") {
                    $('#zweitWunsch').text(this.innerHTML);
                    if (wuensche[1] != undefined) {
                        log("Es existierte bereits ein Zweitwunsch mit id=" + wuensche[1].id);
                        var i = findWunschbyId(wuensche[1].id);
                        log("Dieser hat den index " + i);
                        $("#w1" + i).removeClass("disabled");
                        $("#w2" + i).removeClass("disabled");
                        $("#w3" + i).removeClass("disabled");
                    }
                    var course = courseList[id];
                    log("Gewählt wurde:" + course.TITEL);
                    wuensche[1] = course;
                    $("#w1" + id).addClass("disabled");
                    $("#w2" + id).addClass("disabled");
                    $("#w3" + id).addClass("disabled");
                }
            });
            $('#drittWunschDropdown li > a').click(function (e) {
                var id = $(this).attr('kursid');
                if ($("#w3" + id).attr("class") != "disabled") {
                    $('#drittWunsch').text(this.innerHTML);
                    if (wuensche[2] != undefined) {
                        log("Es existierte bereits ein Drittwunsch mit id=" + wuensche[2].id);
                        var i = findWunschbyId(wuensche[2].id);
                        log("Dieser hat den index " + i);
                        $("#w1" + i).removeClass("disabled");
                        $("#w2" + i).removeClass("disabled");
                        $("#w3" + i).removeClass("disabled");
                    }
                    var course = courseList[id];
                    log("Gewählt wurde:" + course.TITEL);
                    wuensche[2] = course;
                    $("#w1" + id).addClass("disabled");
                    $("#w2" + id).addClass("disabled");
                    $("#w3" + id).addClass("disabled");
                }
            });

        }
    });



}

/**
 * An welcher Stelle der coursliste findet sich welcher Kurs (ID)
 * @param {type} id die Id des Kurses
 * @returns {Number|j} die Position in der Kursliste
 */
function findWunschbyId(id) {
    for (j = 0; j < courseList.length; j++) {
        if (courseList[j].id == id) {
            return j;
        }
    }
}

toastr.options = {
    "closeButton": false,
    "debug": false,
    "newestOnTop": false,
    "progressBar": false,
    "positionClass": "toast-top-right",
    "preventDuplicates": false,
    "onclick": null,
    "showDuration": "300",
    "hideDuration": "1000",
    "timeOut": "5000",
    "extendedTimeOut": "1000",
    "showEasing": "swing",
    "hideEasing": "linear",
    "showMethod": "fadeIn",
    "hideMethod": "fadeOut"
}

function log(msg) {
    //if (debug) {
        console.log(msg);
    //}
}