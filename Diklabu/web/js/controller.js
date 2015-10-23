

var courseList;
var wunsch;
var wuensche = new Array(3);
var credentials;
$(document).ready(function () {
    
    $("#btnLogin").click(function () {
        if ($("#name").val()=="" ||$("#vorname").val()=="" || $("#gebdatum").val()=="") {
           toast("Bitte füllen Sie das Formular komplett aus!");
       } 
       else {
        var pupil = {
            name: $("#name").val(),
            vorName: $("#vorname").val(),
            gebDatum: $("#gebdatum").val()
        };
        console.log(JSON.stringify(pupil));
        $.ajax({
            url: SERVER + "/Diklabu/api/v1/courseselect/login",
            type: "POST",
            data: JSON.stringify(pupil),
            contentType: "application/json; charset=UTF-8",
            dataType: "json",
            success: function (data) {
                console.log("receive" + JSON.stringify(data));
                if (data.login) {
                    credentials=data;
                    console.log("bisherige wünsche :"+credentials.courses);
                    if (credentials.courses!=undefined && credentials.courses.length!=0) {
                        $.mobile.changePage('#results');
                    }
                    else getCourseList();
                    
                }
                else {
                    toast(data.msg);
                }
            }
        });
    }
    });

    $("#btnErstwunsch").click(function () {
        wunsch=0;
        $.mobile.changePage('#wpks');
    });
    $("#btnZweitwunsch").click(function () {
        wunsch=1;
        $.mobile.changePage('#wpks');
    });
    $("#btnDrittwunsch").click(function () {
        wunsch=2;
        $.mobile.changePage('#wpks');
    });
    
    $("#btnCommit").click(function () {
       if (wuensche[0]==undefined || wuensche[1]==undefined || wuensche[2]==undefined) {
           toast("Bitte drei Kurse wählen!");
       } 
       else {
           console.log("Wunsche=" + JSON.stringify(wuensche));
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
                toast(data.msg);
                $("#name").val("");
                $("#vorname").val("");
                $("#gebdatum").val("");
                $.mobile.changePage('#login');
                credentials="";
            }
        });
           
       }
    });
    
    $("#btnzuruck").click( function () {
         credentials=undefined;
 
    });
    
    $("#btnWaehlen").click(function () {
        console.log("btnWaehnlen click");
        var count=0;
        $("input[name*=slot]:checked").each(function () {
            count=1;
            var id = $(this).attr('id');
            console.log("Gewählt wurde ID="+id);
            var course = courseList[id];
            console.log("Gewählt wurde:"+course.TITEL);
            wuensche[wunsch]=course;
            console.log("Wuensche="+JSON.stringify(wuensche));
            
        });
        if (count==0) {
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
         console.log("Anzeige der Wünsche:");
         $("#erstwunschresult").text("1. Wunsch: "+credentials.courses[0].TITEL+" ("+credentials.courses[0].ID_LEHRER+")");
         $("#zweitwunschresult").text("2. Wunsch: "+credentials.courses[1].TITEL+" ("+credentials.courses[1].ID_LEHRER+")");
         $("#drittwunschresult").text("3. Wunsch: "+credentials.courses[2].TITEL+" ("+credentials.courses[2].ID_LEHRER+")");
         
         if (credentials.selectedCourse!=undefined) {
             $("#zugeteilt").text("Ihnen wurde der Kurs '"+credentials.selectedCourse.TITEL+"' zugewiesen!");
         }
         else {
             $("#zugeteilt").text("Ihnen wurde noch kein Kurs zugeteilt!");
         }
     });
     
    $("#wuensche").on("pagebeforeshow", function (event) {
        if (courseList==undefined) $.mobile.changePage('#login');
        else {console.log("wuensche show");
        if (wuensche[0]!=null) {
            $("#erstwunsch").text(wuensche[0].TITEL+ " ("+wuensche[0].ID_LEHRER+")");
        }
        else {
            $("#erstwunsch").text("kein Kurs gewählt");
        }
        if (wuensche[1]!=null) {
            $("#zweitwunsch").text(wuensche[1].TITEL+ " ("+wuensche[1].ID_LEHRER+")");
        }
        else {
            $("#zweitwunsch").text("kein Kurs gewählt");
        }
        if (wuensche[2]!=null) {
            $("#drittwunsch").text(wuensche[2].TITEL+ " ("+wuensche[2].ID_LEHRER+")");
        }
        else {
            $("#drittwunsch").text("kein Kurs gewählt");
        }
    }
    });
    $("#wpks").on("pagebeforeshow", function (event) {
        if (courseList==undefined) $.mobile.changePage('#login');
        else {
        console.log("wpks show");
        $("#wpklist").empty();
        $('#wpklist').append('<fieldset data-role="controlgroup" id="cgrp">');
        console.log("Wuensche sind:"+JSON.stringify(wuensche));
        for (i = 0; i < courseList.length; i++) {
            $('#wpklist').append('<input type="radio" name="slot" id="' + i + '" value="' + courseList[i].TITEL +'" /><label for="' + i + '">' + courseList[i].TITEL + '  ('+courseList[i].ID_LEHRER+')</label>');
            for (j=0;j<=2;j++) {
                if (wuensche[j]!=undefined) {
                    if (courseList[i].id==wuensche[j].id) {
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
        url: SERVER + "/Diklabu/api/v1/courseselect/booking",
        type: "GET",
        contentType: "application/json; charset=UTF-8",
        dataType: "json",
        success: function (data) {
            console.log("receive Course List" + JSON.stringify(data));
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


