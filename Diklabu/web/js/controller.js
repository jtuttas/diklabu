

var courseList;
var wunsch;
var wuensche = new Array(3);
var courseList;
$(document).ready(function () {
    $("#btnzurueck").click(function () {
        log("btnzurueck Click");
        performLogout(sessionStorage.benutzer,sessionStorage.kennwort, function() {
            sessionStorage.clear();
            $("#benutzername").val("");
            $("#kennwort").val("");
            $.mobile.changePage('#login');
        });

    });

    $("#btnLogin").click(function () {
        if ($("#benutzername").val() == "" || $("#kennwort").val() == "") {
            toast("Bitte füllen Sie das Formular komplett aus!");
        }
        else {
            performLogin($("#benutzername").val(), $("#kennwort").val(), function (data) {
                sessionStorage.myself = data.ID;
                sessionStorage.benutzer=$("#benutzername").val();
                sessionStorage.kennwort=$("#kennwort").val();
                
                getKurswunsch(function (data) {
                    if (data.courseList != undefined) {
                        courseList=data;
                        $.mobile.changePage('#results');
                    }
                    else {
                        getCourseList();
                    }
                });
            }, function () {
                toast("Anmeldedaten ungültig");
            });
        }
    });

    $("#btnErstwunsch").click(function () {
        wunsch = 0;
        $.mobile.changePage('#wpks');
    });
    $("#btnZweitwunsch").click(function () {
        wunsch = 1;
        $.mobile.changePage('#wpks');
    });
    $("#btnDrittwunsch").click(function () {
        wunsch = 2;
        $.mobile.changePage('#wpks');
    });

    $("#btnCommit").click(function () {
        if (wuensche[0] == undefined || wuensche[1] == undefined || wuensche[2] == undefined) {
            toast("Bitte drei Kurse wählen!");
        }
        else {
            log("Wunsche ==" + JSON.stringify(wuensche));
            var ticketing = {
                courseList: wuensche
            };
            log("ticketing=" + JSON.stringify(ticketing));
            $.ajax({
                url: SERVER + "/Diklabu/api/v1/sauth/kursbuchung/"+sessionStorage.myself,
                type: "POST",
                contentType: "application/json; charset=UTF-8",
                dataType: "json",
                data: JSON.stringify(ticketing),
                success: function (data) {
                    log("buchen finished" + JSON.stringify(data));
                    toast(data.msg);
                    if (data.success) {
                        $("#benutzername").val("");
                        $("#kennwort").val("");
                        $.mobile.changePage('#login');
                        performLogout(sessionStorage.benutzer,sessionStorage.kennwort);
                    }
                }
            });

        }
    });

   

    $("#btnWaehlen").click(function () {
        log("btnWaehnlen click");
        var count = 0;
        $("input[name*=slot]:checked").each(function () {
            count = 1;
            var id = $(this).attr('id');
            log("Gewählt wurde ID=" + id);
            var course = courseList[id];
            log("Gewählt wurde:" + course.TITEL);
            wuensche[wunsch] = course;
            log("Wuensche=" + JSON.stringify(wuensche));

        });
        if (count == 0) {
            toast("Bitte einen Kurs wählen!");
        }
        else {
            $.mobile.changePage('#wuensche');
        }
    });

    $("#about").on("pagebeforeshow", function (e) {
        $("#version").text(VERSION);
    });

    $("#results").on("pagebeforeshow", function (event) {
        log("Anzeige der Wünsche:");
        $("#erstwunschresult").text("1. Wunsch: " + courseList.courseList[0].TITEL + " (" + courseList.courseList[0].ID_LEHRER + ")");
        $("#zweitwunschresult").text("2. Wunsch: " + courseList.courseList[1].TITEL + " (" + courseList.courseList[1].ID_LEHRER + ")");
        $("#drittwunschresult").text("3. Wunsch: " + courseList.courseList[2].TITEL + " (" + courseList.courseList[2].ID_LEHRER + ")");

        if (courseList.selectedCourse != undefined) {
            $("#zugeteilt").text("Ihnen wurde der Kurs '" + courseList.selectedCourse.TITEL + "' zugewiesen!");
        }
        else {
            $("#zugeteilt").text("Ihnen wurde noch kein Kurs zugeteilt!");
        }
        
        
    });

    $("#wuensche").on("pagebeforeshow", function (event) {
        if (courseList == undefined)
            $.mobile.changePage('#login');
        else {
            log("wuensche show");
            if (wuensche[0] != null) {
                $("#erstwunsch").text(wuensche[0].TITEL + " (" + wuensche[0].ID_LEHRER + ")");
            }
            else {
                $("#erstwunsch").text("kein Kurs gewählt");
            }
            if (wuensche[1] != null) {
                $("#zweitwunsch").text(wuensche[1].TITEL + " (" + wuensche[1].ID_LEHRER + ")");
            }
            else {
                $("#zweitwunsch").text("kein Kurs gewählt");
            }
            if (wuensche[2] != null) {
                $("#drittwunsch").text(wuensche[2].TITEL + " (" + wuensche[2].ID_LEHRER + ")");
            }
            else {
                $("#drittwunsch").text("kein Kurs gewählt");
            }
        }
    });
    $("#wpks").on("pagebeforeshow", function (event) {
        if (courseList == undefined)
            $.mobile.changePage('#login');
        else {
            log("wpks show");
            $("#wpklist").empty();
            $('#wpklist').append('<fieldset data-role="controlgroup" id="cgrp">');
            log("Wuensche sind:" + JSON.stringify(wuensche));
            for (i = 0; i < courseList.length; i++) {
                $('#wpklist').append('<input type="radio" name="slot" id="' + i + '" value="' + courseList[i].TITEL + '" /><label for="' + i + '">' + courseList[i].TITEL + '  (' + courseList[i].ID_LEHRER + ')</label>');
                for (j = 0; j <= 2; j++) {
                    if (wuensche[j] != undefined) {
                        if (courseList[i].id == wuensche[j].id) {
                            $('#' + i).attr('disabled', true);
                        }

                    }
                }
            }
            $('#wpklist').append('</fieldset>');
            $("#wpklist").trigger('create');
        }
    });
});

function getCourseList() {
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/noauth/getcourses",
        type: "GET",
        contentType: "application/json; charset=UTF-8",
        dataType: "json",
        success: function (data) {
            log("receive Course List" + JSON.stringify(data));
            courseList = data;
            wuensche = new Array(3);
            $.mobile.changePage('#wuensche');
        }
    });
}

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
};

function performLogout(benutzer, kennwort, callback) {
     log("perform Logout benutzer=" + benutzer + " kennwort=" + kennwort);
    var myData = {
        "benutzer": benutzer,
        "kennwort": kennwort
    };

    $.ajax({
        cache: false,
        contentType: "application/json; charset=UTF-8",
        headers: {
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
            
             if (jsonObj.success) {
                sessionStorage.auth_token=jsonObj.auth_token;
                callback(jsonObj);
            }
            else {
                toast(jsonObj.msg);                
            }
            
        },
        error: function (xhr, textStatus, errorThrown) {            
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
        dataType: "json",
        data: JSON.stringify(ticketing),
        success: function (data) {
            callback(data);
        },
        error: function (xhr, textStatus, errorThrown) {
            toast("Kursbuchung fehlgeschlagen");
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
        contentType: "application/json; charset=UTF-8",
        dataType: "json",
        success: function (data) {
            callback(data);
        },
        error: function (xhr, textStatus, errorThrown) {
            toast("Kursbuchungsabfrage fehlgeschlagen");
            log("HTTP Status: " + xhr.status);
            log("Error textStatus: " + textStatus);
            log("Error thrown: " + errorThrown);
        }
    });
}

function log(msg) {
    if (debug) {
        console.log(msg);
    }
}



