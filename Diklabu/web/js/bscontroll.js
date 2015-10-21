
var courseList;
var wuensche = new Array(3);

getCourseList();

$("#btnWaehlen").click(function () {
    if ($("#name").val() == "" || $("#vorName").val() == "" || $("#gebDatum").val() == "") {
        toastr["info"]("Bitte die Anmeldedaten vollständig ausfüllen!", "Information");
    }
    else {
        if (wuensche[0] == undefined || wuensche[1] == undefined || wuensche[2] == undefined) {
            toastr["info"]("Bitte drei Kurse Wünschen!", "Information");
        }
        else {
            console.log("Wunsche=" + JSON.stringify(wuensche));
            var credentials = {
                name: $("#name").val(),
                vorName: $("#vorName").val(),
                gebDatum: $("#gebDatum").val()
            };
            var ticketing = {
                credential: credentials,
                courseList: wuensche
            };
            console.log("ticketing=" + JSON.stringify(ticketing));
            $.ajax({
                url: SERVER + "/Diklabu/api/v1/courseselect/booking",
                type: "POST",
                contentType: "application/json; charset=UTF-8",
                dataType: "json",
                data: JSON.stringify(ticketing),
                success: function (data) {
                    console.log("buchen finished" + JSON.stringify(data));
                    if (data.credential.login == false) {
                        toastr["error"](data.msg, "Fehler!");
                    }
                    else {
                        if (data.success == true) {
                            toastr["success"](data.msg, "OK!");
                            $("#name").val("");
                            $("#vorName").val("");
                            $("#gebDatum").val("");
                            $("li").removeClass("disabled");
                            $("#erstWunsch").text("kein Kurs gewählt");
                            $("#zweitWunsch").text("kein Kurs gewählt");
                            $("#drittWunsch").text("kein Kurs gewählt");
                        }
                        else {
                            toastr["error"](data.msg, "Fehler!");
                        }
                    }
                }
            });
        }
    }
});



function getCourseList() {
    $.ajax({
        url: SERVER + "/Diklabu/api/v1/courseselect/booking",
        type: "GET",
        contentType: "application/json; charset=UTF-8",
        dataType: "json",
        error: function () {
            toastr["error"]("Kann Kursliste nicht vom Server laden!", "Fehler!");
        },
        success: function (data) {
            console.log("receive Course List" + JSON.stringify(data));
            courseList = data;
            wuensche = new Array(3);
            $("#erstWunschDropdown").empty();
            $("#zweitWunschDropdown").empty();
            $("#drittWunschDropdown").empty();
            for (var i = 0; i < courseList.length; i++) {
                $("#erstWunschDropdown").append('<li id="w1' + i + '" role="presentation" ><a kursid="' + i + '" role="menuitem" tabindex="-1" href="#f">' + courseList[i].TITEL + '</a></li>')
                $("#zweitWunschDropdown").append('<li id="w2' + i + '" role="presentation" ><a kursid="' + i + '" role="menuitem" tabindex="-1" href="#f">' + courseList[i].TITEL + '</a></li>')
                $("#drittWunschDropdown").append('<li id="w3' + i + '" role="presentation" ><a kursid="' + i + '"role="menuitem" tabindex="-1" href="#f">' + courseList[i].TITEL + '</a></li>')
            }
            $('#erstWunschDropdown li > a').click(function (e) {
                $('#erstWunsch').text(this.innerHTML);
                var id = $(this).attr('kursid');
                var course = courseList[id];
                console.log("Gewählt wurde:" + course.TITEL);
                wuensche[0] = course;
                $("#w1" + id).addClass("disabled");
                $("#w2" + id).addClass("disabled");
                $("#w3" + id).addClass("disabled");
            });
            $('#zweitWunschDropdown li > a').click(function (e) {
                $('#zweitWunsch').text(this.innerHTML);
                var id = $(this).attr('kursid');
                var course = courseList[id];
                console.log("Gewählt wurde:" + course.TITEL);
                wuensche[1] = course;
                $("#w1" + id).addClass("disabled");
                $("#w2" + id).addClass("disabled");
                $("#w3" + id).addClass("disabled");
            });
            $('#drittWunschDropdown li > a').click(function (e) {
                $('#drittWunsch').text(this.innerHTML);
                var id = $(this).attr('kursid');
                var course = courseList[id];
                console.log("Gewählt wurde:" + course.TITEL);
                wuensche[2] = course;
                $("#w1" + id).addClass("disabled");
                $("#w2" + id).addClass("disabled");
                $("#w3" + id).addClass("disabled");

            });

        }
    });



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