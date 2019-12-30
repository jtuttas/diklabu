webpackJsonp(["main"],{

/***/ "../../../../../src/$$_gendir lazy recursive":
/***/ (function(module, exports) {

function webpackEmptyAsyncContext(req) {
	return new Promise(function(resolve, reject) { reject(new Error("Cannot find module '" + req + "'.")); });
}
webpackEmptyAsyncContext.keys = function() { return []; };
webpackEmptyAsyncContext.resolve = webpackEmptyAsyncContext;
module.exports = webpackEmptyAsyncContext;
webpackEmptyAsyncContext.id = "../../../../../src/$$_gendir lazy recursive";

/***/ }),

/***/ "../../../../../src/app/AnwesenheitsComponent.css":
/***/ (function(module, exports, __webpack_require__) {

exports = module.exports = __webpack_require__("../../../../css-loader/lib/css-base.js")(false);
// imports


// module
exports.push([module.i, ".select {\r\n  cursor: pointer;\r\n}\r\n\r\n.fehlend {\r\n  border-radius: 8px;\r\n  background: #ac2925;\r\n  padding: 1px;\r\n  color: white;\r\n  padding-left: 5px;\r\n  padding-right: 5px;\r\n}\r\n\r\n\r\n", ""]);

// exports


/*** EXPORTS FROM exports-loader ***/
module.exports = module.exports.toString();

/***/ }),

/***/ "../../../../../src/app/AnwesenheitsComponent.html":
/***/ (function(module, exports) {

module.exports = "<afilter (filterChanged)=\"filterChanged($event)\"></afilter><br/>\r\n<div class=\"ui-g ui-g-12\">\r\n  <div class=\"ui-mg-12\">\r\n<p-dataTable   scrollable=\"true\" frozenWidth=\"375px\"  unfrozenWidth=\"842px\"  [value]=\"data\" [editable]=\"true\"  on  (onEditCancel)=\"editCanceled($event)\" (onEditInit)=\"editStart($event)\" (onEditComplete)=\"edit($event)\" #dataTable>\r\n  <p-header>\r\n    <h3>Anwesenheit der Klasse {{KName}} von {{von | date: 'dd.MM.yyyy'}} bis {{bis | date: 'dd.MM.yyyy'}}</h3>\r\n  </p-header>\r\n  <ng-container *ngFor=\"let col of cols\">\r\n    <p-column  *ngIf=\"col.field.startsWith('id') && (col.header.startsWith('Sa.') || col.header.startsWith('So.'))\" [editable]=\"true\" [field]=\"col.field\" [header]=\"col.header\" class=\"wochentag\" [style]=\"{'width':'120px','height':'32px','background-color':'#cccccc'}\" >\r\n      <ng-template let-car=\"rowData\" pTemplate=\"body\" let-i=\"rowIndex\" pTemplate=\"editor\">\r\n        <input (keydown)=\"keyDown($event)\" style=\"width: 40px;\" type=\"text\" pInputText [(ngModel)]=\"editedAnwesenheit.VERMERK\" placeholder=\"Verm.\" />\r\n        <input (keydown)=\"keyDown($event)\" style=\"width: 60px;\" type=\"text\" pInputText [(ngModel)]=\"editedAnwesenheit.BEMERKUNG\" placeholder=\"Bem.\" />\r\n      </ng-template>\r\n      <ng-template let-car=\"rowData\" pTemplate=\"body\" let-i=\"rowIndex\">\r\n        <a *ngIf=\"data[i]['id'+col.field.substr(2)]\" class=\"select\" [pTooltip]=\"data[i]['idkuk'+col.field.substr(2)]\" tooltipPosition=\"top\" >{{data[i]['id'+col.field.substr(2)]}}</a>\r\n        <img *ngIf=\"data[i]['idb'+col.field.substr(2)]\" src=\"../assets/flag.png\" class=\"select\" [pTooltip]=\"data[i]['idb'+col.field.substr(2)]\" tooltipPosition=\"top\" />\r\n      </ng-template>\r\n    </p-column>\r\n    <p-column  *ngIf=\"col.field.startsWith('id') && (!col.header.startsWith('Sa.') && !col.header.startsWith('So.'))\" [editable]=\"true\" [field]=\"col.field\" [header]=\"col.header\" class=\"wochentag\" [style]=\"{'width':'120px','height':'32px'}\" >\r\n      <ng-template let-car=\"rowData\" pTemplate=\"body\" let-i=\"rowIndex\" pTemplate=\"editor\">\r\n        <input (keydown)=\"keyDown($event)\" style=\"width: 40px;\" type=\"text\" pInputText [(ngModel)]=\"editedAnwesenheit.VERMERK\" placeholder=\"Verm.\" />\r\n        <input (keydown)=\"keyDown($event)\" style=\"width: 60px;\" type=\"text\" pInputText [(ngModel)]=\"editedAnwesenheit.BEMERKUNG\" placeholder=\"Bem.\" />\r\n      </ng-template>\r\n      <ng-template let-car=\"rowData\" pTemplate=\"body\" let-i=\"rowIndex\">\r\n        <a *ngIf=\"data[i]['id'+col.field.substr(2)] && data[i]['id'+col.field.substr(2)].toLowerCase().startsWith('f')\" class=\"select fehlend\" [pTooltip]=\"data[i]['idkuk'+col.field.substr(2)]\" tooltipPosition=\"top\" >{{data[i]['id'+col.field.substr(2)]}}</a>\r\n        <a *ngIf=\"data[i]['id'+col.field.substr(2)] && !data[i]['id'+col.field.substr(2)].toLowerCase().startsWith('f')\" class=\"select\" [pTooltip]=\"data[i]['idkuk'+col.field.substr(2)]\" tooltipPosition=\"top\" >{{data[i]['id'+col.field.substr(2)]}}</a>\r\n        <img *ngIf=\"data[i]['idb'+col.field.substr(2)]\" src=\"../assets/flag.png\" class=\"select\" [pTooltip]=\"data[i]['idb'+col.field.substr(2)]\" tooltipPosition=\"top\" />\r\n      </ng-template>\r\n    </p-column>\r\n    <p-column  *ngIf=\"col.header == 'info'\" frozen=\"true\"  [id]=\"col.id\" [field]=\"\" [header]=\"\" [style]=\"{'width':'75px','text-align':'left','height':'32px'}\" >\r\n      <ng-template let-car=\"rowData\" pTemplate=\"body\" let-i=\"rowIndex\">\r\n        <img (click)=\"infoClick(data[i])\" class=\"select\" src=\"../assets/Info.png\" [pTooltip]='\"Details \"+data[i].VNAME+\" \"+data[i].NNAME' tooltipPosition=\"right\"/>\r\n        <img (click)=\"mailClick(data[i])\" class=\"select\" src=\"../assets/mail.png\" [pTooltip]='\"Mail an \"+data[i].VNAME+\" \"+data[i].NNAME' tooltipPosition=\"right\"/>\r\n      </ng-template>\r\n    </p-column>\r\n    <p-column  *ngIf=\"col.header == 'empty'\" [field]=\"\" [header]=\"\" [style]=\"{'text-align':'left'}\" >\r\n      <ng-template let-car=\"rowData\" pTemplate=\"body\">\r\n      </ng-template>\r\n    </p-column>\r\n    <p-column  *ngIf=\"col.field == 'VNAME'\" [id]=\"col.id\" frozen=\"true\" [field]=\"col.field\" [header]=\"col.header\" [style]=\"{'width':'150px','height':'32px','text-align':'left'}\" ></p-column>\r\n    <p-column  *ngIf=\"col.field == 'NNAME'\" [id]=\"col.id\" frozen=\"true\"  [field]=\"col.field\" [header]=\"col.header\" [style]=\"{'width':'150px','height':'32px','text-align':'left'}\" ></p-column>\r\n  </ng-container>\r\n</p-dataTable>\r\n  </div>\r\n</div>\r\n<sendmail #mailDialog [mail]=\"mailObject\"></sendmail>\r\n<pupildetails #infoDialog ></pupildetails>\r\n\r\n\r\n\r\n"

/***/ }),

/***/ "../../../../../src/app/AnwesenheitsComponent.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return AnwesenheitsComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__services_SharedService__ = __webpack_require__("../../../../../src/app/services/SharedService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__services_AnwesenheitsService__ = __webpack_require__("../../../../../src/app/services/AnwesenheitsService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4__data_CourseBook__ = __webpack_require__("../../../../../src/app/data/CourseBook.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__data_Anwesenheitseintrag__ = __webpack_require__("../../../../../src/app/data/Anwesenheitseintrag.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6_primeng_components_common_messageservice__ = __webpack_require__("../../../../primeng/components/common/messageservice.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6_primeng_components_common_messageservice___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_6_primeng_components_common_messageservice__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7__CourseSelectComponent__ = __webpack_require__("../../../../../src/app/CourseSelectComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_8__data_MailObject__ = __webpack_require__("../../../../../src/app/data/MailObject.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_9__services_DokuService__ = __webpack_require__("../../../../../src/app/services/DokuService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_10__data_Termin__ = __webpack_require__("../../../../../src/app/data/Termin.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_11__loader_loader_service__ = __webpack_require__("../../../../../src/app/loader/loader.service.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};












var AnwesenheitsComponent = (function () {
    function AnwesenheitsComponent(loaderService, service, anwesenheitsService, messageService, dokuService) {
        this.loaderService = loaderService;
        this.service = service;
        this.anwesenheitsService = anwesenheitsService;
        this.messageService = messageService;
        this.dokuService = dokuService;
        this.mailObject = new __WEBPACK_IMPORTED_MODULE_8__data_MailObject__["a" /* MailObject */]("", "", "", "");
        this.editedAnwesenheit = new __WEBPACK_IMPORTED_MODULE_5__data_Anwesenheitseintrag__["a" /* Anwesenheitseintrag */]();
        this.selectedFilter1 = new __WEBPACK_IMPORTED_MODULE_10__data_Termin__["a" /* Termin */]("alle", 0);
        this.selectedFilter2 = new __WEBPACK_IMPORTED_MODULE_10__data_Termin__["a" /* Termin */]("alle", 0);
        this.multiSortMeta = [];
    }
    AnwesenheitsComponent.prototype.ngOnInit = function () {
        var _this = this;
        console.log("INIT Anwesenheitskomponente");
        this.subscription = this.service.getCoursebook().subscribe(function (message) {
            console.log("Anwesenheits Component Model Changed !" + message.constructor.name);
            _this.update();
        });
        this.dokuService.setDisplayDoku(true, "Anwesenheit");
        this.update();
    };
    AnwesenheitsComponent.prototype.ngOnDestroy = function () {
        this.subscription.unsubscribe();
    };
    AnwesenheitsComponent.prototype.ngAfterViewInit = function () {
        console.log("After View INIT Anwesenheitskomponente");
    };
    AnwesenheitsComponent.prototype.update = function () {
        console.log("Update startet" + JSON.stringify(__WEBPACK_IMPORTED_MODULE_7__CourseSelectComponent__["a" /* CourseSelectComponent */].pupils));
        this.KName = __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME;
        this.von = __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.fromDate;
        this.bis = __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.toDate;
        this.cols = new Array();
        this.colsOrg = new Array();
        var p = __WEBPACK_IMPORTED_MODULE_7__CourseSelectComponent__["a" /* CourseSelectComponent */].pupils;
        console.log("Klasse hat " + p.length + " Schüler: Abgang[0]=(" + __WEBPACK_IMPORTED_MODULE_7__CourseSelectComponent__["a" /* CourseSelectComponent */].pupils[0].ABGANG + ")");
        p = p.filter(function (x) { return x.ABGANG == "N"; });
        console.log("Klasse gefiltert hat " + p.length + " Schüler");
        this.buildCols(__WEBPACK_IMPORTED_MODULE_7__CourseSelectComponent__["a" /* CourseSelectComponent */].pupils.filter(function (x) { return x.ABGANG == "N"; }));
        this.filterChanged({ filter1: this.selectedFilter1, filter2: this.selectedFilter2 });
        console.log("Update Ended");
        //this.applyFilter();
    };
    /**
     * Erzeigt die Spalten der Tabelle und trägt anschließend die Daten ein
     * @param {any[]} p Array mit Schülern
     */
    AnwesenheitsComponent.prototype.buildCols = function (p) {
        var _this = this;
        this.data = new Array();
        this.cols.push({ field: "info", header: "info" });
        this.cols.push({ field: "VNAME", header: "Vorname" });
        this.cols.push({ field: "NNAME", header: "Nachname" });
        this.colsOrg.push({ field: "info", header: "info" });
        this.colsOrg.push({ field: "VNAME", header: "Vorname" });
        this.colsOrg.push({ field: "NNAME", header: "Nachname" });
        var from = __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.fromDate;
        var to = __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.toDate;
        while (from <= to) {
            this.cols.push({ field: "id" + __WEBPACK_IMPORTED_MODULE_4__data_CourseBook__["a" /* CourseBook */].toSQLString(from), header: __WEBPACK_IMPORTED_MODULE_4__data_CourseBook__["a" /* CourseBook */].toReadbleString(from) });
            this.colsOrg.push({ field: "id" + __WEBPACK_IMPORTED_MODULE_4__data_CourseBook__["a" /* CourseBook */].toSQLString(from), header: __WEBPACK_IMPORTED_MODULE_4__data_CourseBook__["a" /* CourseBook */].toReadbleString(from) });
            //this.cols.push({DATUM: CourseBook.toSQLString(from)+"T00:00:00",field:"dummy"});
            from = new Date(from.getTime() + 1000 * 60 * 60 * 24);
        }
        //p[0].id20170913="a";
        this.data = p;
        this.anwesenheitsService.getAnwesenheit().subscribe(function (anwesenheit) { _this.insertAnwesenheit(anwesenheit); console.log("Insgesamt " + anwesenheit.length + " Einträge  empfangen!"); _this.cols.push({ field: "empty", header: "empty" }); }, function (error) { return _this.errorMessage = error; });
    };
    /**
     * Eintragen der Anwesenheitseinträge in die Tabelle
     * @param {Anwesenheit[]} a
     */
    AnwesenheitsComponent.prototype.insertAnwesenheit = function (a) {
        console.log("Trage Anwesenheit ein " + a.length);
        for (var i = 0; i < a.length; i++) {
            // Finde den richtigen Schüler
            var found = false;
            var j = 0;
            for (j = 0; j < this.data.length && found == false; j++) {
                if (this.data[j].id == a[i].id_Schueler) {
                    found = true;
                }
            }
            console.log("Zeile gefunden, Zeile ist " + j);
            var eintraeg = a[i].eintraege;
            console.log("Für den Schüler gibt es " + eintraeg.length + " Einträge");
            // Anwesenheitseinträge in diese Zeile als Attribut eintragen
            for (var k = 0; k < eintraeg.length; k++) {
                var eintrag = a[i].eintraege[k];
                //console.log("Vergleiche "+this.cols[s].DATUM+" mit "+eintrag.DATUM);
                this.data[j - 1]['id' + __WEBPACK_IMPORTED_MODULE_4__data_CourseBook__["a" /* CourseBook */].toSQLString(new Date(eintrag.DATUM))] = eintrag.VERMERK;
                if (eintrag.BEMERKUNG) {
                    this.data[j - 1]['bem' + __WEBPACK_IMPORTED_MODULE_4__data_CourseBook__["a" /* CourseBook */].toSQLString(new Date(eintrag.DATUM))] = eintrag.BEMERKUNG;
                }
                this.data[j - 1]['idkuk' + __WEBPACK_IMPORTED_MODULE_4__data_CourseBook__["a" /* CourseBook */].toSQLString(new Date(eintrag.DATUM))] = eintrag.ID_LEHRER;
                this.data[j - 1]['idb' + __WEBPACK_IMPORTED_MODULE_4__data_CourseBook__["a" /* CourseBook */].toSQLString(new Date(eintrag.DATUM))] = eintrag.BEMERKUNG;
            }
        }
        console.log("Data is:" + JSON.stringify(this.data));
        console.log("cols is:" + JSON.stringify(this.cols));
    };
    AnwesenheitsComponent.prototype.mailClick = function (p) {
        console.log("0Mail click! on " + JSON.stringify(p));
        this.mailObject = new __WEBPACK_IMPORTED_MODULE_8__data_MailObject__["a" /* MailObject */](__WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.email, p.EMAIL, "", "");
        this.mailDialog.showDialog("Nachricht an " + p.VNAME + " " + p.NNAME);
    };
    AnwesenheitsComponent.prototype.infoClick = function (p) {
        console.log("Info click! on " + JSON.stringify(p));
        this.infoDialog.showDialog(p);
    };
    AnwesenheitsComponent.prototype.editStart = function (event) {
        console.log("edit Start: row=" + event.index + " Column=" + event.column.field + " Inhalt:" + JSON.stringify(event.data));
        this.event_column = event.column.field;
        this.event_data = event.data;
        this.editedAnwesenheit.ID_LEHRER = __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.idLehrer;
        this.editedAnwesenheit.ID_KLASSE = __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.id;
        this.editedAnwesenheit.ID_SCHUELER = event.data.id;
        this.editedAnwesenheit.VERMERK = event.data[event.column.field];
        this.editedAnwesenheit.BEMERKUNG = event.data["bem" + event.column.field.substr(2)];
        this.editedAnwesenheit.DATUM = event.column.field.substring(2) + "T00:00:00";
    };
    AnwesenheitsComponent.prototype.editCanceled = function (event) {
        console.log("edit Canceled: row=" + event.index + " Column=" + event.column.field + " Inhalt:" + JSON.stringify(event.data));
    };
    AnwesenheitsComponent.prototype.keyDown = function (event) {
        console.log("Key Down" + event.which);
        if (event.which === 13 || event.which === 9) {
            this.submitAnwesenheit();
        }
    };
    AnwesenheitsComponent.prototype.edit = function (event) {
        console.log("edit Complete: row=" + event.index + " Column=" + event.column.field + " Inhalt:" + JSON.stringify(event.data));
    };
    AnwesenheitsComponent.prototype.submitAnwesenheit = function () {
        var _this = this;
        console.log("Sende zum Server =>" + JSON.stringify(this.editedAnwesenheit));
        if (this.editedAnwesenheit.VERMERK == "") {
            console.log("Lösche Anwesenheitseintrag!");
            this.anwesenheitsService.deleteAnwesenheit(this.editedAnwesenheit);
            delete this.event_data[this.event_column];
            delete this.event_data["bem" + this.event_column.substr(2)];
            delete this.event_data["idb" + this.event_column.substr(2)];
            this.dataTable.closeCell();
        }
        else {
            this.anwesenheitsService.setAnwesenheit(this.editedAnwesenheit).subscribe(function (anwesenheit) {
                console.log("Empfange " + JSON.stringify(anwesenheit));
                if (anwesenheit.parseError) {
                    _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: 'Formatierungfehler im Vermerk ' + anwesenheit.VERMERK });
                }
                _this.event_data[_this.event_column] = _this.editedAnwesenheit.VERMERK;
                _this.event_data["bem" + _this.event_column.substr(2)] = _this.editedAnwesenheit.BEMERKUNG;
                _this.event_data["idkuk" + _this.event_column.substr(2)] = _this.editedAnwesenheit.ID_LEHRER;
                _this.event_data["idb" + _this.event_column.substr(2)] = _this.editedAnwesenheit.BEMERKUNG;
                _this.dataTable.closeCell();
            });
        }
    };
    AnwesenheitsComponent.prototype.filterChanged = function (e) {
        var _this = this;
        console.log("Filter changed: " + JSON.stringify(e));
        this.dokuService.setDokuFilter(e.filter1, e.filter1);
        this.selectedFilter1 = e.filter1;
        this.selectedFilter2 = e.filter2;
        this.anwesenheitsService.getTermiondaten(e.filter1.id, e.filter2.id).subscribe(function (data) {
            console.log("Received Terminadaten:" + JSON.stringify(data));
            _this.termindaten = data;
            _this.applyFilter();
        }, function (err) {
            _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: 'Fehler beim Laden der Termindaten:' + err });
        });
    };
    AnwesenheitsComponent.prototype.applyFilter = function () {
        var _this = this;
        if (this.termindaten) {
            this.cols = this.colsOrg.filter(function (elements) {
                if (elements.field.startsWith("id")) {
                    for (var i = 0; i < _this.termindaten.length; i++) {
                        if (elements.field.substr(2) == _this.termindaten[i].date.substr(0, _this.termindaten[i].date.indexOf("T"))) {
                            return true;
                        }
                    }
                    return false;
                }
                else
                    return true;
            });
            console.log("Filtered cols: " + JSON.stringify(this.cols));
        }
    };
    return AnwesenheitsComponent;
}());
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('mailDialog'),
    __metadata("design:type", Object)
], AnwesenheitsComponent.prototype, "mailDialog", void 0);
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('infoDialog'),
    __metadata("design:type", Object)
], AnwesenheitsComponent.prototype, "infoDialog", void 0);
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('dataTable'),
    __metadata("design:type", Object)
], AnwesenheitsComponent.prototype, "dataTable", void 0);
AnwesenheitsComponent = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'anwesenheit',
        template: __webpack_require__("../../../../../src/app/AnwesenheitsComponent.html"),
        styles: [__webpack_require__("../../../../../src/app/AnwesenheitsComponent.css")],
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_11__loader_loader_service__["a" /* LoaderService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_11__loader_loader_service__["a" /* LoaderService */]) === "function" && _a || Object, typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_1__services_SharedService__["a" /* SharedService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_1__services_SharedService__["a" /* SharedService */]) === "function" && _b || Object, typeof (_c = typeof __WEBPACK_IMPORTED_MODULE_2__services_AnwesenheitsService__["a" /* AnwesenheitsService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_2__services_AnwesenheitsService__["a" /* AnwesenheitsService */]) === "function" && _c || Object, typeof (_d = typeof __WEBPACK_IMPORTED_MODULE_6_primeng_components_common_messageservice__["MessageService"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_6_primeng_components_common_messageservice__["MessageService"]) === "function" && _d || Object, typeof (_e = typeof __WEBPACK_IMPORTED_MODULE_9__services_DokuService__["a" /* DokuService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_9__services_DokuService__["a" /* DokuService */]) === "function" && _e || Object])
], AnwesenheitsComponent);

var _a, _b, _c, _d, _e;
//# sourceMappingURL=AnwesenheitsComponent.js.map

/***/ }),

/***/ "../../../../../src/app/AnwesenheitsFilterComponent.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return AnwesenheitsFilterComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__ = __webpack_require__("../../../../primeng/components/common/messageservice.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__services_AnwesenheitsService__ = __webpack_require__("../../../../../src/app/services/AnwesenheitsService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__data_Termin__ = __webpack_require__("../../../../../src/app/data/Termin.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};




var AnwesenheitsFilterComponent = (function () {
    function AnwesenheitsFilterComponent(anwesenheitsService, messageService) {
        this.anwesenheitsService = anwesenheitsService;
        this.messageService = messageService;
        this.filterChanged = new __WEBPACK_IMPORTED_MODULE_0__angular_core__["EventEmitter"]();
        this.filter = [];
        this.selectedFilter1 = new __WEBPACK_IMPORTED_MODULE_3__data_Termin__["a" /* Termin */]("alle", -1);
        this.selectedFilter2 = new __WEBPACK_IMPORTED_MODULE_3__data_Termin__["a" /* Termin */]("alle", -1);
    }
    AnwesenheitsFilterComponent.prototype.ngOnInit = function () {
        var _this = this;
        this.anwesenheitsService.getTermine().subscribe(function (data) {
            var t = data;
            var alle = new __WEBPACK_IMPORTED_MODULE_3__data_Termin__["a" /* Termin */]("alle", -1);
            _this.selectedFilter1 = alle;
            _this.selectedFilter2 = alle;
            _this.filter.push({ label: "alle", value: alle });
            for (var i = 0; i < t.length; i++) {
                _this.filter.push({ label: t[i].NAME, value: t[i] });
            }
        }, function (err) {
            _this.messageService.add({
                severity: 'error',
                summary: 'Fehler',
                detail: 'Fehler beim Laden der Terminliste: ' + err
            });
        });
    };
    AnwesenheitsFilterComponent.prototype.OnChangeCal = function (e) {
        console.log("Drop Down CHanged!" + JSON.stringify(e));
        console.log("Selected filter1=" + JSON.stringify(this.selectedFilter1) + " filter2=" + JSON.stringify(this.selectedFilter2));
        this.filterChanged.emit({ filter1: this.selectedFilter1, filter2: this.selectedFilter2 });
    };
    return AnwesenheitsFilterComponent;
}());
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Output"])(),
    __metadata("design:type", Object)
], AnwesenheitsFilterComponent.prototype, "filterChanged", void 0);
AnwesenheitsFilterComponent = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'afilter',
        template: '<div class="ui-g ui-g-12 special">' +
            '<div class="ui-md-1">' +
            '<strong>Filter 1</strong><br/>' +
            '<p-dropdown  (onChange)="OnChangeCal($event.value)"  [options]="filter" [(ngModel)]="selectedFilter1" placeholder="Filter"></p-dropdown>\n' +
            '</div>' +
            '<div class="ui-md-1">' +
            '<strong>Filter 2</strong><br/>' +
            '<p-dropdown (onChange)="OnChangeCal($event.value)"  [options]="filter" [(ngModel)]="selectedFilter2" placeholder="Filter"></p-dropdown>\n' +
            '</div>' +
            '</div>',
        styles: ['.special {text-align: left;}'],
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_2__services_AnwesenheitsService__["a" /* AnwesenheitsService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_2__services_AnwesenheitsService__["a" /* AnwesenheitsService */]) === "function" && _a || Object, typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__["MessageService"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__["MessageService"]) === "function" && _b || Object])
], AnwesenheitsFilterComponent);

var _a, _b;
//# sourceMappingURL=AnwesenheitsFilterComponent.js.map

/***/ }),

/***/ "../../../../../src/app/BetriebeComponent.html":
/***/ (function(module, exports) {

module.exports = "<p-dataList [value]=\"betriebe\" >\r\n  <p-header>\r\n    <h3>Übersicht Klasse {{KName}}</h3>\r\n    <div class=\"ui-g ui-fluid\">\r\n      <div class=\"ui-g-12 ui-md-2 links\" >\r\n        <strong>Name</strong>\r\n      </div>\r\n      <div class=\"ui-md-3 links\" >\r\n        <strong>Bemerkungen</strong>\r\n      </div>\r\n      <div class=\"ui-md-3 links\" >\r\n        <strong>Firma</strong>\r\n      </div>\r\n      <div class=\"ui-md-2 links\" >\r\n        <strong>Ansprechpartner</strong>\r\n      </div>\r\n      <div class=\"ui-md-1 links\" >\r\n        <strong>Telefon</strong>\r\n      </div>\r\n      <div class=\"ui-md-1 links\" >\r\n        <strong>Fax</strong>\r\n      </div>\r\n    </div>\r\n  </p-header>\r\n  <ng-template let-betrieb pTemplate=\"item\" let-i=\"index\">\r\n    <div class=\"ui-g ui-fluid\">\r\n      <div class=\"ui-g-12 ui-md-2 links\" >\r\n        <img src=\"../assets/Info.png\" (click)=\"infoClick(betrieb.id_schueler)\" />\r\n        <img src=\"../assets/mail.png\" (click)=\"mailClick(betrieb.id_schueler)\" />\r\n        <strong style=\"vertical-align: top;\">{{getName(betrieb.id_schueler)}}</strong>\r\n      </div>\r\n      <div class=\"ui-md-3 links\" >\r\n        {{getInfo(betrieb.id_schueler)}}\r\n      </div>\r\n      <div class=\"ui-md-3 links\" >\r\n        {{betrieb.name}},{{betrieb.strasse}},{{betrieb.plz}} {{betrieb.ort}}\r\n      </div>\r\n      <div class=\"ui-md-2 links\" >\r\n        <img src=\"../assets/mail.png\" (click)=\"mailClickBetrieb(betrieb)\" />\r\n        <strong style=\"vertical-align: top;\">{{betrieb.nName}}</strong>\r\n      </div>\r\n      <div class=\"ui-md-1 links\" >\r\n        {{betrieb.telefon}}\r\n      </div>\r\n\r\n      <div class=\"ui-md-1 links\" >\r\n        {{betrieb.fax}}\r\n      </div>\r\n    </div>\r\n  </ng-template>\r\n</p-dataList>\r\n<sendmail #mailDialog [mail]=\"mailObject\"></sendmail>\r\n<pupildetails #infoDialog ></pupildetails>\r\n\r\n"

/***/ }),

/***/ "../../../../../src/app/BetriebeComponent.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return BetriebeComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__services_SharedService__ = __webpack_require__("../../../../../src/app/services/SharedService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice__ = __webpack_require__("../../../../primeng/components/common/messageservice.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__services_CourseService__ = __webpack_require__("../../../../../src/app/services/CourseService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__CourseSelectComponent__ = __webpack_require__("../../../../../src/app/CourseSelectComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6__data_MailObject__ = __webpack_require__("../../../../../src/app/data/MailObject.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7__services_DokuService__ = __webpack_require__("../../../../../src/app/services/DokuService.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};








var BetriebeComponent = (function () {
    function BetriebeComponent(dokuService, courseService, service, messageService) {
        this.dokuService = dokuService;
        this.courseService = courseService;
        this.service = service;
        this.messageService = messageService;
        this.mailObject = new __WEBPACK_IMPORTED_MODULE_6__data_MailObject__["a" /* MailObject */]("", "", "", "");
    }
    BetriebeComponent.prototype.ngOnInit = function () {
        var _this = this;
        this.dokuService.setDisplayDoku(true, "Betriebe");
        this.subscription = this.service.getCoursebook().subscribe(function (message) {
            console.log("List Component Received !" + message.constructor.name);
            _this.getBetriebe();
        });
        this.getBetriebe();
    };
    BetriebeComponent.prototype.ngOnDestroy = function () {
        this.subscription.unsubscribe();
    };
    BetriebeComponent.prototype.getBetriebe = function () {
        var _this = this;
        this.KName = __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME;
        this.betriebe = [];
        this.courseService.getCompanies(__WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME).subscribe(function (data) {
            _this.betriebe = data;
            console.log("Betriebsliste: " + JSON.stringify(data));
        }, function (err) {
            _this.messageService.add({
                severity: 'error',
                summary: 'Fehler',
                detail: 'Kann Liste der Betriebe nicht laden: ' + err
            });
        });
    };
    BetriebeComponent.prototype.getName = function (id) {
        var p = __WEBPACK_IMPORTED_MODULE_5__CourseSelectComponent__["a" /* CourseSelectComponent */].getPupil(id);
        return p.VNAME + " " + p.NNAME;
    };
    BetriebeComponent.prototype.getInfo = function (id) {
        var p = __WEBPACK_IMPORTED_MODULE_5__CourseSelectComponent__["a" /* CourseSelectComponent */].getPupil(id);
        return p.INFO;
    };
    BetriebeComponent.prototype.mailClick = function (id) {
        var p = __WEBPACK_IMPORTED_MODULE_5__CourseSelectComponent__["a" /* CourseSelectComponent */].getPupil(id);
        console.log("0Mail click! on " + JSON.stringify(p));
        this.mailObject = new __WEBPACK_IMPORTED_MODULE_6__data_MailObject__["a" /* MailObject */](__WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.email, p.EMAIL, "", "");
        this.mailDialog.showDialog("Nachricht an " + p.VNAME + " " + p.NNAME);
    };
    BetriebeComponent.prototype.mailClickBetrieb = function (b) {
        console.log("0Mail Betrieb click! on " + JSON.stringify(b));
        this.mailObject = new __WEBPACK_IMPORTED_MODULE_6__data_MailObject__["a" /* MailObject */](__WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.email, b.email, "", "");
        this.mailDialog.showDialog("Nachricht an " + b.nName);
    };
    BetriebeComponent.prototype.infoClick = function (id) {
        var p = __WEBPACK_IMPORTED_MODULE_5__CourseSelectComponent__["a" /* CourseSelectComponent */].getPupil(id);
        console.log("Info click! on " + JSON.stringify(p));
        this.infoDialog.showDialog(p);
    };
    return BetriebeComponent;
}());
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('mailDialog'),
    __metadata("design:type", Object)
], BetriebeComponent.prototype, "mailDialog", void 0);
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('infoDialog'),
    __metadata("design:type", Object)
], BetriebeComponent.prototype, "infoDialog", void 0);
BetriebeComponent = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'betriebe',
        styles: ['.links {text-align: left;} img {cursor: pointer;}'],
        template: __webpack_require__("../../../../../src/app/BetriebeComponent.html")
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_7__services_DokuService__["a" /* DokuService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_7__services_DokuService__["a" /* DokuService */]) === "function" && _a || Object, typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_3__services_CourseService__["a" /* CourseService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_3__services_CourseService__["a" /* CourseService */]) === "function" && _b || Object, typeof (_c = typeof __WEBPACK_IMPORTED_MODULE_1__services_SharedService__["a" /* SharedService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_1__services_SharedService__["a" /* SharedService */]) === "function" && _c || Object, typeof (_d = typeof __WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice__["MessageService"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice__["MessageService"]) === "function" && _d || Object])
], BetriebeComponent);

var _a, _b, _c, _d;
//# sourceMappingURL=BetriebeComponent.js.map

/***/ }),

/***/ "../../../../../src/app/CourseBookComponent.html":
/***/ (function(module, exports) {

module.exports = "<div class=\"headline\">\r\n<menu></menu>\r\n<div class=\"ui-g ui-fluid ui-g-12 \">\r\n  <div class=\"ui-md-4 ui-md-offset-1\">\r\n    <duration (durationUpdated)=\"durationUpdated($event)\"></duration>\r\n  </div>\r\n  <div class=\"ui-md-5\">\r\n    <courseselect (courseUpdated)=\"courseUpdated($event)\"></courseselect>\r\n  </div>\r\n</div>\r\n<doku></doku>\r\n</div>\r\n"

/***/ }),

/***/ "../../../../../src/app/CourseBookComponent.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return CourseBookComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__data_CourseBook__ = __webpack_require__("../../../../../src/app/data/CourseBook.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__services_SharedService__ = __webpack_require__("../../../../../src/app/services/SharedService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__data_Course__ = __webpack_require__("../../../../../src/app/data/Course.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};




var CourseBookComponent = CourseBookComponent_1 = (function () {
    function CourseBookComponent(service) {
        this.service = service;
    }
    CourseBookComponent.prototype.ngAfterViewInit = function () {
    };
    CourseBookComponent.prototype.courseUpdated = function (e) {
        console.log("Course Updated!" + e.KNAME);
        CourseBookComponent_1.courseBook.course = e;
        this.service.courseBookChanged(CourseBookComponent_1.courseBook);
    };
    CourseBookComponent.prototype.durationUpdated = function (e) {
        console.log(" Duration updated!");
        CourseBookComponent_1.courseBook.fromDate = e.fromDate;
        CourseBookComponent_1.courseBook.toDate = e.toDate;
        this.service.courseBookChanged(CourseBookComponent_1.courseBook);
    };
    return CourseBookComponent;
}());
CourseBookComponent.courseBook = new __WEBPACK_IMPORTED_MODULE_1__data_CourseBook__["a" /* CourseBook */](new Date(new Date().getTime() - 6 * 24 * 60 * 60 * 1000), new Date(), new __WEBPACK_IMPORTED_MODULE_3__data_Course__["a" /* Course */](0, "NN"));
CourseBookComponent = CourseBookComponent_1 = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'coursebook',
        template: __webpack_require__("../../../../../src/app/CourseBookComponent.html"),
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_2__services_SharedService__["a" /* SharedService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_2__services_SharedService__["a" /* SharedService */]) === "function" && _a || Object])
], CourseBookComponent);

var CourseBookComponent_1, _a;
//# sourceMappingURL=CourseBookComponent.js.map

/***/ }),

/***/ "../../../../../src/app/CourseInfoDialog.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return CourseInfoDialog; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__services_CourseService__ = __webpack_require__("../../../../../src/app/services/CourseService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};



var CourseInfoDialog = (function () {
    function CourseInfoDialog(courseService) {
        this.courseService = courseService;
        this.display = false;
        this.titel = "";
        this.courseTitel = "";
        this.bem = "";
        this.lvname = "";
        this.lnname = "";
        this.lemail = "";
        this.mailto = "";
    }
    CourseInfoDialog.prototype.showDialog = function (titel, courseTitel) {
        this.titel = titel;
        this.display = true;
        this.courseTitel = courseTitel;
    };
    CourseInfoDialog.prototype.bemChanged = function () {
        this.display = false;
        this.courseService.setCourseInfo(__WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.id, this.bem).subscribe(function (data) {
            console.log("Set Course Info Responce:" + JSON.stringify(data));
        }, function (err) {
            console.log("Set Course Infoi Error:" + err);
        });
    };
    return CourseInfoDialog;
}());
CourseInfoDialog = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'courseinfo',
        styles: ['textarea{width:100%;}'],
        template: ' <p-dialog [header]="titel" [(visible)]="display" modal="modal" [closable]="true" appendTo="body">' +
            '<strong>{{courseTitel}}</strong>' +
            '<h3>Klassenlehrer</h3>' +
            '<strong>{{lvname}} {{lnname}}</strong>' +
            ' (<a [href]="mailto">{{lemail}}</a>)' +
            '<h3>Klassenbemerkung</h3>' +
            '<textarea pInputTextarea [(ngModel)]="bem"></textarea>' +
            '<p-footer>\n' +
            '            <button type="button" class="ui-button-success" pButton icon="fa-check" (click)="bemChanged()" label="Ändern"></button>\n' +
            '        </p-footer>\n' +
            '</p-dialog>'
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_1__services_CourseService__["a" /* CourseService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_1__services_CourseService__["a" /* CourseService */]) === "function" && _a || Object])
], CourseInfoDialog);

var _a;
//# sourceMappingURL=CourseInfoDialog.js.map

/***/ }),

/***/ "../../../../../src/app/CourseSelectComponent.css":
/***/ (function(module, exports, __webpack_require__) {

exports = module.exports = __webpack_require__("../../../../css-loader/lib/css-base.js")(false);
// imports


// module
exports.push([module.i, ".small {\r\n  font-size: small;\r\n}\r\n.filter {\r\n  width: 80px;\r\n}\r\n\r\nimg {\r\n  cursor: pointer;\r\n}\r\n\r\n.special {\r\n  text-align: left;\r\n  padding-top: 14px;\r\n}\r\n", ""]);

// exports


/*** EXPORTS FROM exports-loader ***/
module.exports = module.exports.toString();

/***/ }),

/***/ "../../../../../src/app/CourseSelectComponent.html":
/***/ (function(module, exports) {

module.exports = "<div class=\"ui-g ui-fluid\">\r\n  <div class=\"ui-g-12 ui-md-3 special\">\r\n\r\n    <strong>SuS:{{this.courseService.anzahl}}</strong><br/>\r\n    <p-dropdown  [filter]=\"true\" filterBy=\"label,value.name\" [autoWidth]=\"false\" (onChange)=\"updated()\" [options]=\"courses\" [(ngModel)]=\"selectedCourse\" placeholder=\"Klassen\" [disabled]=\"compDisabled\"></p-dropdown>\r\n  </div>\r\n  <div class=\"ui-md-6 special\">\r\n\r\n\r\n    <img style=\"padding-left: 10px;\" (click)=\"mailPupils()\" src=\"../assets/groupmail.png\" pTooltip=\"Klasse anschreiben\" tooltipPosition=\"top\">\r\n    <img (click)=\"mailCompanies()\" src=\"../assets/Boss.png\" pTooltip=\"Betriebe anschreiben\" tooltipPosition=\"top\">\r\n    <img (click)=\"stundenplan()\" src=\"../assets/calendar.png\" pTooltip=\"Stundenplan\" tooltipPosition=\"top\">\r\n    <img (click)=\"vertretungsplan()\" src=\"../assets/calendar.png\" pTooltip=\"Vertretungsplan\" tooltipPosition=\"top\">\r\n    <img (click)=\"courseinfo()\" src=\"../assets/infoIcon.png\" pTooltip=\"Klasseninfo\" tooltipPosition=\"top\">\r\n\r\n  </div>\r\n</div>\r\n<sendmail #mailDialog [mail]=\"mailObject\"></sendmail>\r\n<plan #planDialog ></plan>\r\n<courseinfo #courseInfoDialog></courseinfo>\r\n"

/***/ }),

/***/ "../../../../../src/app/CourseSelectComponent.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return CourseSelectComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__ = __webpack_require__("../../../../primeng/components/common/messageservice.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__services_PupilService__ = __webpack_require__("../../../../../src/app/services/PupilService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__data_MailObject__ = __webpack_require__("../../../../../src/app/data/MailObject.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__services_CourseService__ = __webpack_require__("../../../../../src/app/services/CourseService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6__services_TeacherService__ = __webpack_require__("../../../../../src/app/services/TeacherService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7__angular_router__ = __webpack_require__("../../../router/@angular/router.es5.js");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};








var CourseSelectComponent = CourseSelectComponent_1 = (function () {
    function CourseSelectComponent(router, teacherService, messageService, pupilService, courseService) {
        var _this = this;
        this.router = router;
        this.teacherService = teacherService;
        this.messageService = messageService;
        this.pupilService = pupilService;
        this.courseService = courseService;
        this.courseUpdated = new __WEBPACK_IMPORTED_MODULE_0__angular_core__["EventEmitter"]();
        this.mailObject = new __WEBPACK_IMPORTED_MODULE_3__data_MailObject__["a" /* MailObject */]("", "", "", "");
        this.compDisabled = true;
        this.teacherService.getCoursesOfTeacher(__WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.idLehrer).subscribe(function (data) {
            _this.courses = [];
            var co = data;
            for (var i = 0; i < co.length; i++) {
                var label = co[i].KNAME;
                if (co[i].ID_LEHRER) {
                    label += "(" + co[i].ID_LEHRER + ")";
                }
                _this.courses.push({ label: label, value: co[i] });
            }
            if (_this.courses.length == 0) {
                _this.messageService.add({
                    severity: 'error',
                    summary: 'Fehler',
                    detail: 'Sie sind keinen Klassen zugeordnet!'
                });
                _this.router.navigate(['/login']);
            }
            else {
                _this.selectedCourse = co[0];
                _this.compDisabled = false;
                _this.updated();
            }
        }, function (err) {
            _this.compDisabled = true;
            if (err.error instanceof Error) {
                // A client-side or network error occurred. Handle it accordingly.
                console.log('An error occurred:', err.error.message);
                _this.messageService.add({
                    severity: 'error',
                    summary: 'Fehler',
                    detail: 'Kann Klassenliste nicht vom Server laden! MSG=' + err.error.message
                });
            }
            else {
                // The backend returned an unsuccessful response code.
                // The response body may contain clues as to what went wrong,
                console.log("Backend returned code " + err.status + ", body was: " + err.error);
                _this.messageService.add({
                    severity: 'error',
                    summary: 'Fehler',
                    detail: 'Kann Klassenliste nicht vom Server laden! MSG=' + err.error.message
                });
            }
        });
    }
    CourseSelectComponent.prototype.updated = function () {
        var _this = this;
        console.log("CourseSelecComponent updated():" + this.selectedCourse);
        this.pupilService.getPupils(this.selectedCourse.id)
            .subscribe(function (data) {
            CourseSelectComponent_1.pupils = data;
            console.log("getPupils habe empfangen:" + JSON.stringify(data));
            _this.courseService.anzahl = CourseSelectComponent_1.pupils.filter(function (x) { return x.ABGANG == "N"; }).length;
            _this.courseUpdated.emit(_this.selectedCourse);
            console.log("Insgesamt " + CourseSelectComponent_1.pupils.length + " Schüler  empfangen!");
        });
    };
    CourseSelectComponent.prototype.mailPupils = function () {
        console.log("Mail Pupils click! ");
        this.mailObject = new __WEBPACK_IMPORTED_MODULE_3__data_MailObject__["a" /* MailObject */](__WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.email, __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.email, "", "");
        for (var i = 0; i < CourseSelectComponent_1.pupils.length; i++) {
            this.mailObject.addCC(CourseSelectComponent_1.pupils[i].EMAIL);
        }
        this.mailDialog.showDialog("Klasse " + __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME + " anschreiben");
    };
    CourseSelectComponent.prototype.stundenplan = function () {
        var _this = this;
        console.log("Stundenplan anfragen!");
        this.courseService.getStundenplan(__WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME).subscribe(function (data) {
            console.log("Receive Stundenplan:" + data);
            if (data.length > 0) {
                _this.planDialog.showDialog("Stundenplan f. die Klasse " + __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME, data);
            }
            else {
                _this.messageService.add({
                    severity: 'warning',
                    summary: 'Warnung',
                    detail: "Kein Stundenplan f. die Klasse " + __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME + " gefunden!"
                });
            }
        }, function (err) {
            _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: err });
        });
    };
    CourseSelectComponent.prototype.vertretungsplan = function () {
        var _this = this;
        console.log("Vertertungsplan anfragen!");
        this.courseService.getVertretungsplan(__WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME).subscribe(function (data) {
            console.log("Receive Verterungsplan:" + data);
            if (data.length > 0) {
                _this.planDialog.showDialog("Vertretungsplan f. die Klasse " + __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME, data);
            }
            else {
                _this.messageService.add({
                    severity: 'warning',
                    summary: 'Warnung',
                    detail: "Kein Vertretungsplan f. die Klasse " + __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME + " gefunden!"
                });
            }
        }, function (err) {
            _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: err });
        });
    };
    CourseSelectComponent.prototype.courseinfo = function () {
        var _this = this;
        this.courseService.getCourseInfo(__WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.id).subscribe(function (data) {
            console.log("Receive CourseInfo:" + JSON.stringify(data));
            _this.courseInfoDialog.bem = data.NOTIZ;
            _this.courseInfoDialog.lvname = data.LEHRER_VNAME;
            _this.courseInfoDialog.lnname = data.LEHRER_NNAME;
            _this.courseInfoDialog.lemail = data.LEHRER_EMAIL;
            _this.courseInfoDialog.mailto = "mailto:" + data.LEHRER_EMAIL;
            _this.courseInfoDialog.showDialog("Info f. die Klasse " + __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME, data.TITEL);
        }, function (err) {
            _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: err });
        });
    };
    CourseSelectComponent.prototype.mailCompanies = function () {
        var _this = this;
        console.log("Mail Companies click! ");
        this.mailObject = new __WEBPACK_IMPORTED_MODULE_3__data_MailObject__["a" /* MailObject */](__WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.email, __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.email, "", "");
        this.pupilService.getCompanies(__WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME).subscribe(function (data) {
            console.log("Empfange Betriebe " + JSON.stringify(data));
            for (var i = 0; i < data.length; i++) {
                _this.mailObject.addBCC(data[i].email);
            }
        }, function (err) {
            console.log("Fehler Liste Betriebe" + err);
            _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: err });
        });
        this.mailDialog.showDialog("Betriebe der Klasse " + __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME + " anschreiben");
    };
    CourseSelectComponent.getPupil = function (id) {
        for (var i = 0; i < CourseSelectComponent_1.pupils.length; i++) {
            if (this.pupils[i].id == id) {
                return this.pupils[i];
            }
        }
    };
    return CourseSelectComponent;
}());
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Output"])(),
    __metadata("design:type", Object)
], CourseSelectComponent.prototype, "courseUpdated", void 0);
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('mailDialog'),
    __metadata("design:type", Object)
], CourseSelectComponent.prototype, "mailDialog", void 0);
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('planDialog'),
    __metadata("design:type", Object)
], CourseSelectComponent.prototype, "planDialog", void 0);
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('courseInfoDialog'),
    __metadata("design:type", Object)
], CourseSelectComponent.prototype, "courseInfoDialog", void 0);
CourseSelectComponent = CourseSelectComponent_1 = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'courseselect',
        template: __webpack_require__("../../../../../src/app/CourseSelectComponent.html"),
        styles: [__webpack_require__("../../../../../src/app/CourseSelectComponent.css")]
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_7__angular_router__["Router"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_7__angular_router__["Router"]) === "function" && _a || Object, typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_6__services_TeacherService__["a" /* TeacherService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_6__services_TeacherService__["a" /* TeacherService */]) === "function" && _b || Object, typeof (_c = typeof __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__["MessageService"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__["MessageService"]) === "function" && _c || Object, typeof (_d = typeof __WEBPACK_IMPORTED_MODULE_2__services_PupilService__["a" /* PupilService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_2__services_PupilService__["a" /* PupilService */]) === "function" && _d || Object, typeof (_e = typeof __WEBPACK_IMPORTED_MODULE_5__services_CourseService__["a" /* CourseService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_5__services_CourseService__["a" /* CourseService */]) === "function" && _e || Object])
], CourseSelectComponent);

var CourseSelectComponent_1, _a, _b, _c, _d, _e;
//# sourceMappingURL=CourseSelectComponent.js.map

/***/ }),

/***/ "../../../../../src/app/DatepickerComponent.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return DatepickerComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
///<reference path="../../node_modules/@angular/core/src/metadata/directives.d.ts"/>

var DatepickerComponent = (function () {
    function DatepickerComponent() {
        this.d = new Date();
        this.d.setHours(0, 0, 0, 0);
    }
    DatepickerComponent.prototype.ngOnInit = function () {
        this.de = {
            firstDayOfWeek: 1,
            dayNames: ["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnestag", "Freitag", "Samstag"],
            dayNamesShort: ["So.", "Mo.", "Di.", "Mi.", "Do.", "Fr.", "Sa."],
            dayNamesMin: ["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"],
            monthNames: ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"],
            monthNamesShort: ["Jan", "Feb", "Mar", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"],
            today: 'Heute',
            clear: 'löschen'
        };
    };
    DatepickerComponent.prototype.onChange = function (event) {
        this.d = event;
        this.d.setHours(0, 0, 0, 0);
        console.log('changed!' + event.toString());
        console.log('d=' + this.d.toString());
    };
    return DatepickerComponent;
}());
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Input"])(),
    __metadata("design:type", String)
], DatepickerComponent.prototype, "titel", void 0);
DatepickerComponent = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'datepickerComponent',
        template: __webpack_require__("../../../../../src/app/datepickerComponent.html"),
        styles: [__webpack_require__("../../../../../src/app/datepickerComponent.css")]
    }),
    __metadata("design:paramtypes", [])
], DatepickerComponent);

//# sourceMappingURL=DatepickerComponent.js.map

/***/ }),

/***/ "../../../../../src/app/DokuComponent.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return DokuComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__data_CourseBook__ = __webpack_require__("../../../../../src/app/data/CourseBook.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__services_DokuService__ = __webpack_require__("../../../../../src/app/services/DokuService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_file_saver__ = __webpack_require__("../../../../file-saver/FileSaver.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_file_saver___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_4_file_saver__);
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};





var DokuComponent = (function () {
    function DokuComponent(dokuService) {
        this.dokuService = dokuService;
        this.type = "pdf";
        this.dokufilter1 = "alle";
        this.dokufilter2 = "alle";
        this.imgSrc = "../assets/pdf.png";
    }
    DokuComponent.prototype.ngOnInit = function () {
        var _this = this;
        this.items = [
            {
                label: 'pdf', icon: 'fa-file-pdf-o', command: function () {
                    _this.createPdf();
                }
            },
            {
                label: 'xlsx', icon: 'fa-file-excel-o', command: function () {
                    _this.createXlsx();
                }
            }
        ];
    };
    DokuComponent.prototype.createPdf = function () {
        console.log("Create PDF");
        this.imgSrc = "../assets/pdf.png";
        this.type = "pdf";
    };
    DokuComponent.prototype.createXlsx = function () {
        console.log("Create Xlsx");
        this.imgSrc = "../assets/Excel.png";
        this.type = "csv";
    };
    DokuComponent.prototype.create = function () {
        var _this = this;
        console.log("Create " + this.type);
        var body = "auth_token=" + __WEBPACK_IMPORTED_MODULE_1__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token;
        body += "&idklasse=" + __WEBPACK_IMPORTED_MODULE_1__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.id;
        body += "&idSchuljahr=" + __WEBPACK_IMPORTED_MODULE_1__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.idSchuljahr;
        body += "&from=" + __WEBPACK_IMPORTED_MODULE_2__data_CourseBook__["a" /* CourseBook */].toSQLString(__WEBPACK_IMPORTED_MODULE_1__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.fromDate);
        body += "&to=" + __WEBPACK_IMPORTED_MODULE_2__data_CourseBook__["a" /* CourseBook */].toSQLString(__WEBPACK_IMPORTED_MODULE_1__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.toDate);
        body += "&dokufilter1=" + this.dokufilter1;
        body += "&dokufilter2=" + this.dokufilter2;
        body += "&anwfilter1=" + __WEBPACK_IMPORTED_MODULE_3__services_DokuService__["a" /* DokuService */].anwFilter1;
        body += "&anwfilter2=" + __WEBPACK_IMPORTED_MODULE_3__services_DokuService__["a" /* DokuService */].anwFilter2;
        body += "&type=" + this.type;
        body += "&cmd=" + __WEBPACK_IMPORTED_MODULE_3__services_DokuService__["a" /* DokuService */].view;
        console.log("body-->" + body);
        this.dokuService.getDoku(body).subscribe(function (res) {
            if (_this.type == "pdf") {
                var blob = new Blob([res], {
                    type: 'application/pdf' // must match the Accept type
                });
                var filename = __WEBPACK_IMPORTED_MODULE_1__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME + "_" + __WEBPACK_IMPORTED_MODULE_3__services_DokuService__["a" /* DokuService */].view + "_" + __WEBPACK_IMPORTED_MODULE_2__data_CourseBook__["a" /* CourseBook */].toSQLString(__WEBPACK_IMPORTED_MODULE_1__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.fromDate) + "_" + __WEBPACK_IMPORTED_MODULE_2__data_CourseBook__["a" /* CourseBook */].toSQLString(__WEBPACK_IMPORTED_MODULE_1__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.toDate) + ".pdf";
                __WEBPACK_IMPORTED_MODULE_4_file_saver__["saveAs"](blob, filename);
            }
            else {
                var blob = new Blob([res], {
                    type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' // must match the Accept type
                });
                var filename = __WEBPACK_IMPORTED_MODULE_1__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME + "_" + __WEBPACK_IMPORTED_MODULE_3__services_DokuService__["a" /* DokuService */].view + "_" + __WEBPACK_IMPORTED_MODULE_2__data_CourseBook__["a" /* CourseBook */].toSQLString(__WEBPACK_IMPORTED_MODULE_1__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.fromDate) + "_" + __WEBPACK_IMPORTED_MODULE_2__data_CourseBook__["a" /* CourseBook */].toSQLString(__WEBPACK_IMPORTED_MODULE_1__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.toDate) + ".xlsx";
                __WEBPACK_IMPORTED_MODULE_4_file_saver__["saveAs"](blob, filename);
            }
        });
    };
    return DokuComponent;
}());
DokuComponent = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'doku',
        styles: ['p-splitButton {position: absolute; top: 4px; right: 4px;} img {position: absolute;top: 4px;right: 100px;}'],
        template: '<div *ngIf="dokuService.isVisible()" class="doku" ><img [src]="imgSrc"/>' +
            '<p-splitButton  label="Doku" icon="fa-check" (onClick)="create()" [model]="items" ></p-splitButton></div>'
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_3__services_DokuService__["a" /* DokuService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_3__services_DokuService__["a" /* DokuService */]) === "function" && _a || Object])
], DokuComponent);

var _a;
//# sourceMappingURL=DokuComponent.js.map

/***/ }),

/***/ "../../../../../src/app/DurationPickerComponent.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return DurationPickerComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__ = __webpack_require__("../../../../primeng/components/common/messageservice.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
///<reference path="../../node_modules/@angular/core/src/metadata/directives.d.ts"/>



var DurationPickerComponent = (function () {
    function DurationPickerComponent(messageService) {
        this.messageService = messageService;
        this.durationUpdated = new __WEBPACK_IMPORTED_MODULE_0__angular_core__["EventEmitter"]();
        this.fromDate = __WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.fromDate;
        this.toDate = __WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.toDate;
        this.fromDate.setHours(0, 0, 0, 0);
        this.toDate.setHours(23, 59, 59, 0);
    }
    DurationPickerComponent.prototype.ngOnInit = function () {
        this.de = {
            firstDayOfWeek: 1,
            dayNames: ["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnestag", "Freitag", "Samstag"],
            dayNamesShort: ["So.", "Mo.", "Di.", "Mi.", "Do.", "Fr.", "Sa."],
            dayNamesMin: ["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"],
            monthNames: ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"],
            monthNamesShort: ["Jan", "Feb", "Mar", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"],
            today: 'Heute',
            clear: 'löschen'
        };
    };
    DurationPickerComponent.prototype.fromChange = function (event) {
        this.fromDate = event;
        //console.log("from="+this.fromDate.getTime()+" to="+this.toDate.getTime());
        if (this.fromDate.getTime() > this.toDate.getTime()) {
            //console.log("FEHLER");
            this.messageService.add({ severity: 'warning', summary: 'Warnung', detail: 'Start-Datum muss vor dem End-Datum liegen!' });
        }
        this.durationUpdated.emit(this);
    };
    DurationPickerComponent.prototype.toChange = function (event) {
        this.toDate = event;
        this.toDate.setHours(23, 59, 59, 0);
        //console.log("from="+this.fromDate.getTime()+" to="+this.toDate.getTime());
        if (this.fromDate.getTime() > this.toDate.getTime()) {
            //console.log("FEHLER");
            this.messageService.add({ severity: 'warning', summary: 'Warnung', detail: 'Start-Datum muss vor dem End-Datum liegen!' });
        }
        this.durationUpdated.emit(this);
    };
    DurationPickerComponent.prototype.toString = function () {
        console.log(" from: " + this.fromDate + " to " + this.toDate);
    };
    return DurationPickerComponent;
}());
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Output"])(),
    __metadata("design:type", Object)
], DurationPickerComponent.prototype, "durationUpdated", void 0);
DurationPickerComponent = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'duration',
        template: __webpack_require__("../../../../../src/app/durationPickerComponent.html"),
        styles: [__webpack_require__("../../../../../src/app/durationPickerComponent.css")]
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__["MessageService"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__["MessageService"]) === "function" && _a || Object])
], DurationPickerComponent);

var _a;
//# sourceMappingURL=DurationPickerComponent.js.map

/***/ }),

/***/ "../../../../../src/app/FehlzeitenComponent.css":
/***/ (function(module, exports, __webpack_require__) {

exports = module.exports = __webpack_require__("../../../../css-loader/lib/css-base.js")(false);
// imports


// module
exports.push([module.i, ".links {text-align: left;}\r\n\r\n.select {\r\n  cursor: pointer;\r\n}\r\n\r\n.parseErrors {\r\n  border-radius: 8px;\r\n  background: #F05F40;\r\n  padding: 1px;\r\n  color: black;\r\n  margin: 5px;\r\n  font-size: 11px;\r\n  white-space:nowrap;\r\n  float: left;\r\n  cursor: pointer;\r\n}\r\n.fehltagEntschuldigt {\r\n  border-radius: 8px;\r\n  background: #009245;\r\n  padding: 1px;\r\n  padding-left: 5px;\r\n  padding-right: 5px;\r\n  margin: 5px;\r\n  font-size: 11px;\r\n  color: white;\r\n  white-space:nowrap;\r\n  float: left;\r\ncursor: pointer;\r\n}\r\n\r\n.fehltagUnentschuldigt {\r\n  border-radius: 8px;\r\n  margin: 5px;\r\n  background: #ac2925;\r\n  font-size: 11px;\r\n  padding: 1px;\r\n  color: white;\r\n  white-space:nowrap;\r\n\r\n  padding-left: 5px;\r\n  padding-right: 5px;\r\n  float: left;\r\n  cursor: pointer;\r\n}\r\n\r\n", ""]);

// exports


/*** EXPORTS FROM exports-loader ***/
module.exports = module.exports.toString();

/***/ }),

/***/ "../../../../../src/app/FehlzeitenComponent.html":
/***/ (function(module, exports) {

module.exports = "<p-dataList [value]=\"anwesenheit\">\r\n  <p-header>\r\n    <h3>Fehlzeiten der Klasse {{KName}} von {{from | date: 'dd.MM.yyyy'}} bis {{to | date: 'dd.MM.yyyy'}}</h3>\r\n    <div class=\"ui-g ui-fluid\">\r\n      <div class=\"ui-g-12 ui-md-2 links\">\r\n        <strong>Name</strong>\r\n      </div>\r\n      <div class=\"ui-md-2 links\">\r\n        <strong>Fehltage / entschuldigt</strong>\r\n      </div>\r\n      <div class=\"ui-md-3 links\">\r\n        <strong>Tage</strong>\r\n      </div>\r\n      <div class=\"ui-md-1 links\">\r\n        <strong>Verspätungen (Minuten)</strong>\r\n      </div>\r\n      <div class=\"ui-md-1 links\">\r\n        <strong>Minuten entschuldigt</strong>\r\n      </div>\r\n      <div class=\"ui-md-3 links\">\r\n        <strong>Eintragsfehler</strong>\r\n      </div>\r\n    </div>\r\n  </p-header>\r\n  <ng-template let-anwesenheit pTemplate=\"item\" let-i=\"index\">\r\n    <div class=\"ui-g ui-fluid\">\r\n      <div class=\"ui-g-12 ui-md-2 links\">\r\n        <img (click)=\"infoClick(anwesenheit)\" class=\"select\" src=\"../assets/Info.png\"/>\r\n        <img (click)=\"mailClick(anwesenheit)\" class=\"select\" src=\"../assets/mail.png\"/>\r\n        <strong style=\"vertical-align: top;\">{{getPupilName(anwesenheit.id_Schueler)}}</strong>\r\n      </div>\r\n      <div class=\"ui-md-1\">\r\n        <span  style=\"float: left;padding-top: 5px;\">{{anwesenheit.summeFehltage}}  / </span><span class=\"fehltagEntschuldigt\">{{anwesenheit.summeFehltageEntschuldigt}} </span>\r\n      </div>\r\n      <div class=\"ui-md-1\">\r\n        <button *ngIf=\"anwesenheit.summeFehltage>0\" pButton type=\"button\" (click)=\"sendReport(anwesenheit)\" iconPos=\"left\" icon=\"fa-mail-reply\" class=\"ui-button-warning\" label=\"Bericht\"></button>\r\n      </div>\r\n      <div class=\"ui-md-3 links\">\r\n        <div *ngFor=\"let ae of anwesenheit.fehltageEntschuldigt\">\r\n          <span class=\"fehltagEntschuldigt\" pTooltip='{{ae.ID_LEHRER}}' tooltipPosition=\"top\">{{ae.DATUM | date: 'dd.MM.yyyy'}}</span>\r\n        </div>\r\n        <div *ngFor=\"let ae of anwesenheit.fehltageUnentschuldigt\">\r\n          <span class=\"fehltagUnentschuldigt\" pTooltip='{{ae.ID_LEHRER}}' tooltipPosition=\"top\">{{ae.DATUM | date: 'dd.MM.yyyy'}}</span>\r\n        </div>\r\n      </div>\r\n      <div class=\"ui-md-1 links\" style=\"padding-top: 15px;\">\r\n        {{anwesenheit.anzahlVerspaetungen}} ({{anwesenheit.summeMinutenVerspaetungen}} min.)\r\n      </div>\r\n      <div class=\"ui-md-1 links\" style=\"padding-top: 15px;\">\r\n        {{anwesenheit.summeMinutenVerspaetungenEntschuldigt}} min.\r\n      </div>\r\n      <div class=\"ui-md-3 links\">\r\n        <div *ngFor=\"let ae of anwesenheit.parseErrors\">\r\n          <span class=\"parseErrors\" pTooltip='{{ae.ID_LEHRER}} ({{ae.VERMERK}})' tooltipPosition=\"top\">{{ae.DATUM | date: 'dd.MM.yyyy'}}</span>\r\n        </div>\r\n      </div>\r\n\r\n    </div>\r\n  </ng-template>\r\n</p-dataList>\r\n<sendmail #mailDialog [mail]=\"mailObject\"></sendmail>\r\n<pupildetails #infoDialog></pupildetails>\r\n\r\n\r\n"

/***/ }),

/***/ "../../../../../src/app/FehlzeitenComponent.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return FehlzeitenComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__data_CourseBook__ = __webpack_require__("../../../../../src/app/data/CourseBook.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_add_operator_startWith__ = __webpack_require__("../../../../rxjs/add/operator/startWith.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_add_operator_startWith___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_2_rxjs_add_operator_startWith__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_rxjs_add_observable_merge__ = __webpack_require__("../../../../rxjs/add/observable/merge.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_rxjs_add_observable_merge___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_3_rxjs_add_observable_merge__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_map__ = __webpack_require__("../../../../rxjs/add/operator/map.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_map___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_map__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5_rxjs_add_operator_debounceTime__ = __webpack_require__("../../../../rxjs/add/operator/debounceTime.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5_rxjs_add_operator_debounceTime___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_5_rxjs_add_operator_debounceTime__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6_rxjs_add_operator_distinctUntilChanged__ = __webpack_require__("../../../../rxjs/add/operator/distinctUntilChanged.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6_rxjs_add_operator_distinctUntilChanged___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_6_rxjs_add_operator_distinctUntilChanged__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7_rxjs_add_observable_fromEvent__ = __webpack_require__("../../../../rxjs/add/observable/fromEvent.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7_rxjs_add_observable_fromEvent___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_7_rxjs_add_observable_fromEvent__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_8__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_9__services_SharedService__ = __webpack_require__("../../../../../src/app/services/SharedService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_10_primeng_components_common_messageservice__ = __webpack_require__("../../../../primeng/components/common/messageservice.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_10_primeng_components_common_messageservice___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_10_primeng_components_common_messageservice__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_11__services_AnwesenheitsService__ = __webpack_require__("../../../../../src/app/services/AnwesenheitsService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_12__data_MailObject__ = __webpack_require__("../../../../../src/app/data/MailObject.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_13__CourseSelectComponent__ = __webpack_require__("../../../../../src/app/CourseSelectComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_14__services_DokuService__ = __webpack_require__("../../../../../src/app/services/DokuService.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};















/**
 * @title List Verlauf
 */
var FehlzeitenComponent = (function () {
    function FehlzeitenComponent(dokuService, anwesenheitsService, service, messageService) {
        this.dokuService = dokuService;
        this.anwesenheitsService = anwesenheitsService;
        this.service = service;
        this.messageService = messageService;
        this.mailObject = new __WEBPACK_IMPORTED_MODULE_12__data_MailObject__["a" /* MailObject */]("", "", "", "");
    }
    FehlzeitenComponent.prototype.ngOnInit = function () {
        var _this = this;
        this.dokuService.setDisplayDoku(true, "Fehlzeiten");
        this.subscription = this.service.getCoursebook().subscribe(function (message) {
            console.log("List Component Received !" + message.constructor.name);
            _this.getAnwesenheit();
        });
        this.getAnwesenheit();
    };
    FehlzeitenComponent.prototype.ngOnDestroy = function () {
        this.subscription.unsubscribe();
    };
    FehlzeitenComponent.prototype.getAnwesenheit = function () {
        var _this = this;
        this.KName = __WEBPACK_IMPORTED_MODULE_8__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME;
        this.from = __WEBPACK_IMPORTED_MODULE_8__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.fromDate;
        this.to = __WEBPACK_IMPORTED_MODULE_8__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.toDate;
        this.anwesenheitsService.getAnwesenheit().subscribe(function (data) {
            _this.anwesenheit = data;
            console.log("Fehlzeiten empfangen:" + _this.anwesenheit.length);
            console.log(JSON.stringify(_this.anwesenheit));
        }, function (err) {
            _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: err });
        });
    };
    FehlzeitenComponent.prototype.sendReport = function (a) {
        var _this = this;
        console.log("Send Bericht!");
        var p = __WEBPACK_IMPORTED_MODULE_13__CourseSelectComponent__["a" /* CourseSelectComponent */].getPupil(a.id_Schueler);
        this.mailDialog.mailService.getTemplate("template.txt", window.location.origin).subscribe(function (data) {
            var template = data;
            _this.anwesenheitsService.fillFehlzeitenbericht(template, a, function (content, recipient) {
                console.log("Bericht =" + content);
                _this.mailObject = new __WEBPACK_IMPORTED_MODULE_12__data_MailObject__["a" /* MailObject */](__WEBPACK_IMPORTED_MODULE_8__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.email, recipient, "", "");
                _this.mailObject.content = content;
                _this.mailDialog.dialogWidth = 800;
                _this.mailObject.addCC(__WEBPACK_IMPORTED_MODULE_8__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.email);
                _this.mailObject.subject = "Fehlzeitenbericht für " + p.VNAME + " " + p.NNAME + " vom " + __WEBPACK_IMPORTED_MODULE_1__data_CourseBook__["a" /* CourseBook */].toReadbleString(__WEBPACK_IMPORTED_MODULE_8__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.fromDate) + " bis " + __WEBPACK_IMPORTED_MODULE_1__data_CourseBook__["a" /* CourseBook */].toReadbleString(__WEBPACK_IMPORTED_MODULE_8__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.toDate);
                _this.mailDialog.showDialog("Fehlzeitenbericht für " + p.VNAME + " " + p.NNAME + " vom " + __WEBPACK_IMPORTED_MODULE_1__data_CourseBook__["a" /* CourseBook */].toReadbleString(__WEBPACK_IMPORTED_MODULE_8__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.fromDate) + " bis " + __WEBPACK_IMPORTED_MODULE_1__data_CourseBook__["a" /* CourseBook */].toReadbleString(__WEBPACK_IMPORTED_MODULE_8__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.toDate));
            });
        }, function (err) {
            _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: "Failed to load Template!" });
        });
    };
    FehlzeitenComponent.prototype.getPupilName = function (id) {
        //console.log("getPupilName von ID="+id);
        var p = __WEBPACK_IMPORTED_MODULE_13__CourseSelectComponent__["a" /* CourseSelectComponent */].getPupil(id);
        if (p) {
            return p.VNAME + " " + p.NNAME;
        }
        return "N.N.";
    };
    FehlzeitenComponent.prototype.infoClick = function (a) {
        console.log("info click:" + JSON.stringify(a));
        var p = __WEBPACK_IMPORTED_MODULE_13__CourseSelectComponent__["a" /* CourseSelectComponent */].getPupil(a.id_Schueler);
        this.infoDialog.showDialog(p);
    };
    FehlzeitenComponent.prototype.mailClick = function (a) {
        console.log("mail click:" + JSON.stringify(a));
        var p = __WEBPACK_IMPORTED_MODULE_13__CourseSelectComponent__["a" /* CourseSelectComponent */].getPupil(a.id_Schueler);
        this.mailObject = new __WEBPACK_IMPORTED_MODULE_12__data_MailObject__["a" /* MailObject */](__WEBPACK_IMPORTED_MODULE_8__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.email, p.EMAIL, "", "");
        this.mailDialog.showDialog("Nachricht an " + p.VNAME + " " + p.NNAME);
    };
    return FehlzeitenComponent;
}());
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('mailDialog'),
    __metadata("design:type", Object)
], FehlzeitenComponent.prototype, "mailDialog", void 0);
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('infoDialog'),
    __metadata("design:type", Object)
], FehlzeitenComponent.prototype, "infoDialog", void 0);
FehlzeitenComponent = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'fehlzeiten',
        template: __webpack_require__("../../../../../src/app/FehlzeitenComponent.html"),
        styles: [__webpack_require__("../../../../../src/app/FehlzeitenComponent.css")]
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_14__services_DokuService__["a" /* DokuService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_14__services_DokuService__["a" /* DokuService */]) === "function" && _a || Object, typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_11__services_AnwesenheitsService__["a" /* AnwesenheitsService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_11__services_AnwesenheitsService__["a" /* AnwesenheitsService */]) === "function" && _b || Object, typeof (_c = typeof __WEBPACK_IMPORTED_MODULE_9__services_SharedService__["a" /* SharedService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_9__services_SharedService__["a" /* SharedService */]) === "function" && _c || Object, typeof (_d = typeof __WEBPACK_IMPORTED_MODULE_10_primeng_components_common_messageservice__["MessageService"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_10_primeng_components_common_messageservice__["MessageService"]) === "function" && _d || Object])
], FehlzeitenComponent);

var _a, _b, _c, _d;
//# sourceMappingURL=FehlzeitenComponent.js.map

/***/ }),

/***/ "../../../../../src/app/KurszugehoerigkeitComponent.html":
/***/ (function(module, exports) {

module.exports = "<button *ngIf=\"role=='Admin'\" pButton type=\"button\" (click)=\"newPupil()\" icon=\"fa-plus-circle\" label=\"new\"></button>\r\n<p-pickList  (onMoveAllToTarget)=\"moveAllToTaget($event)\" (onMoveToTarget)=\"moveToTarget($event)\"  (onMoveToSource)=\"moveToSource($event)\"  [source]=\"allPupils\" [target]=\"coursePupils\" sourceHeader=\"Alle Schüler\" [targetHeader]=\"courseName\" [responsive]=\"true\" filterBy=\"NNAME,VNAME\"\r\n            dragdrop=\"true\" dragdropScope=\"cars\" sourceFilterPlaceholder=\"Search by Name\" targetFilterPlaceholder=\"Search by Name\" [sourceStyle]=\"{'height':'300px'}\" [targetStyle]=\"{'height':'300px'}\">\r\n\r\n  <ng-template let-pupil pTemplate=\"item\">\r\n    <div style=\"text-align: left;\">\r\n      <img (click)=\"editPupil(pupil)\" src=\"../assets/setting.png\" style=\"vertical-align :middle;cursor: help;\"/>\r\n      <span *ngIf=\"pupil.ABGANG=='N'\">{{pupil.VNAME}} {{pupil.NNAME}}</span>\r\n      <span *ngIf=\"pupil.ABGANG!='N'\"><i>{{pupil.VNAME}} {{pupil.NNAME}} (ABGANG)</i></span>\r\n    </div>\r\n  </ng-template>\r\n\r\n</p-pickList>\r\n<pupileditdetails #editDialog (newCompleted)=\"newCompleted($event)\" (editCompleted)=\"editCompleted($event)\"></pupileditdetails>\r\n"

/***/ }),

/***/ "../../../../../src/app/KurszugehoerigkeitComponent.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return KurszugehoerigkeitComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__data_Pupil__ = __webpack_require__("../../../../../src/app/data/Pupil.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__CourseSelectComponent__ = __webpack_require__("../../../../../src/app/CourseSelectComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__services_SharedService__ = __webpack_require__("../../../../../src/app/services/SharedService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4__services_PupilService__ = __webpack_require__("../../../../../src/app/services/PupilService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5_primeng_components_common_messageservice__ = __webpack_require__("../../../../primeng/components/common/messageservice.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5_primeng_components_common_messageservice___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_5_primeng_components_common_messageservice__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7__services_CourseService__ = __webpack_require__("../../../../../src/app/services/CourseService.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};








var KurszugehoerigkeitComponent = (function () {
    function KurszugehoerigkeitComponent(service, pupilServive, messageService, courseService) {
        var _this = this;
        this.service = service;
        this.pupilServive = pupilServive;
        this.messageService = messageService;
        this.courseService = courseService;
        this.role = __WEBPACK_IMPORTED_MODULE_6__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.role;
        this.courseName = "Schüler des Kurses " + __WEBPACK_IMPORTED_MODULE_6__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME;
        this.subscription = this.service.getCoursebook().subscribe(function (message) {
            console.log("KurszugehoerigkeitComponent Component Model Changed !" + message.constructor.name);
            _this.coursePupils = new Array();
            _this.coursePupils = __WEBPACK_IMPORTED_MODULE_2__CourseSelectComponent__["a" /* CourseSelectComponent */].pupils.map(function (x) { return Object.assign({}, x); });
            _this.coursePupils = _this.coursePupils.sort(function (obj1, obj2) {
                return obj1.NNAME.localeCompare(obj2.NNAME);
            });
            _this.orgCourse = _this.coursePupils.map(function (x) { return Object.assign({}, x); });
            _this.courseName = "Schüler des Kurses " + __WEBPACK_IMPORTED_MODULE_6__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME;
        });
        this.coursePupils = new Array();
        this.coursePupils = __WEBPACK_IMPORTED_MODULE_2__CourseSelectComponent__["a" /* CourseSelectComponent */].pupils.map(function (x) { return Object.assign({}, x); });
        this.coursePupils = this.coursePupils.sort(function (obj1, obj2) {
            return obj1.NNAME.localeCompare(obj2.NNAME);
        });
        this.orgCourse = this.coursePupils.map(function (x) { return Object.assign({}, x); });
        this.courseName = "Schüler des Kurses " + __WEBPACK_IMPORTED_MODULE_6__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME;
        this.courseName = "Schüler des Kurses " + __WEBPACK_IMPORTED_MODULE_6__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME;
    }
    KurszugehoerigkeitComponent.prototype.ngOnInit = function () {
        var _this = this;
        this.coursePupils = __WEBPACK_IMPORTED_MODULE_2__CourseSelectComponent__["a" /* CourseSelectComponent */].pupils.map(function (x) { return Object.assign({}, x); });
        this.pupilServive.getAllPupils().subscribe(function (data) {
            _this.allPupils = data;
            _this.orgAll = new Array();
            _this.allPupils = _this.allPupils.map(function (x) { return Object.assign({}, x); });
            _this.allPupils = _this.allPupils.sort(function (obj1, obj2) {
                return obj1.NNAME.localeCompare(obj2.NNAME);
            });
            _this.orgAll = _this.allPupils.map(function (x) { return Object.assign({}, x); });
        }, function (err) {
            _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: 'Fehler beim laden aller Schüler: ' + err });
        });
    };
    KurszugehoerigkeitComponent.prototype.ngOnDestroy = function () {
        this.subscription.unsubscribe();
    };
    KurszugehoerigkeitComponent.prototype.moveToTarget = function (event) {
        console.log("items.length=" + event.items.length + " all.length=" + this.allPupils.length);
        if (this.allPupils.length != 0) {
            this.allPupils = [];
            this.allPupils = this.orgAll.map(function (x) { return Object.assign({}, x); });
            console.log("Move to Traget " + JSON.stringify(event));
            for (var i = 0; i < event.items.length; i++) {
                this.addPupil(event.items[i]);
            }
            console.log("Pupils size=" + this.allPupils.length);
        }
    };
    KurszugehoerigkeitComponent.prototype.moveToSource = function (event) {
        console.log("Move to Source " + JSON.stringify(event));
        this.allPupils = [];
        this.allPupils = this.orgAll.map(function (x) { return Object.assign({}, x); });
        for (var i = 0; i < event.items.length; i++) {
            this.removePupil(event.items[i]);
        }
    };
    KurszugehoerigkeitComponent.prototype.moveAllToTaget = function (event) {
        this.messageService.add({ severity: 'error', summary: 'Fehler', detail: 'Funktion nicht zulässig!' });
        this.allPupils = [];
        this.allPupils = this.orgAll.map(function (x) { return Object.assign({}, x); });
        this.coursePupils = [];
        this.coursePupils = this.orgCourse.map(function (x) { return Object.assign({}, x); });
    };
    KurszugehoerigkeitComponent.prototype.addPupil = function (p) {
        var _this = this;
        this.pupilServive.addPupilToCourse(p, __WEBPACK_IMPORTED_MODULE_6__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course).subscribe(function (data) {
            //this.allPupils=new Array();
            //this.allPupils=this.orgAll.map(x => Object.assign({}, x));
            if (!data.success) {
                _this.messageService.add({
                    severity: 'error',
                    summary: 'Fehler',
                    detail: 'Fehler beim Hinzufügen von ' + p.VNAME + ' ' + p.NNAME + " zum Kurs " + __WEBPACK_IMPORTED_MODULE_6__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME + ':' + data.msg
                });
                _this.coursePupils = _this.orgCourse.map(function (x) { return Object.assign({}, x); });
            }
            else {
                console.log("Füge hinzu zur Liste " + JSON.stringify(p));
                __WEBPACK_IMPORTED_MODULE_2__CourseSelectComponent__["a" /* CourseSelectComponent */].pupils.push(p);
                _this.orgCourse.push(p);
                _this.courseService.anzahl = __WEBPACK_IMPORTED_MODULE_2__CourseSelectComponent__["a" /* CourseSelectComponent */].pupils.length;
            }
        }, function (err) {
            _this.messageService.add({
                severity: 'error',
                summary: 'Fehler',
                detail: 'Fehler beim Hinzufügen von ' + p.VNAME + ' ' + p.NNAME + " zum Kurs " + __WEBPACK_IMPORTED_MODULE_6__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME + ':' + err
            });
        });
    };
    KurszugehoerigkeitComponent.prototype.removePupil = function (p) {
        var _this = this;
        this.pupilServive.removePupilFromCourse(p, __WEBPACK_IMPORTED_MODULE_6__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course).subscribe(function (data) {
            _this.allPupils = new Array();
            _this.allPupils = _this.orgAll.map(function (x) { return Object.assign({}, x); });
            if (!data.success) {
                _this.messageService.add({
                    severity: 'error',
                    summary: 'Fehler',
                    detail: 'Fehler beim Entfernen von ' + p.VNAME + ' ' + p.NNAME + " zum Kurs " + __WEBPACK_IMPORTED_MODULE_6__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME + ':' + data.msg
                });
                _this.coursePupils = _this.orgCourse.map(function (x) { return Object.assign({}, x); });
            }
            else {
                __WEBPACK_IMPORTED_MODULE_2__CourseSelectComponent__["a" /* CourseSelectComponent */].pupils = __WEBPACK_IMPORTED_MODULE_2__CourseSelectComponent__["a" /* CourseSelectComponent */].pupils.filter(function (obj) { return obj.id != p.id; });
                _this.orgCourse = _this.orgCourse.filter(function (obj) { return obj.id != p.id; });
                _this.courseService.anzahl = __WEBPACK_IMPORTED_MODULE_2__CourseSelectComponent__["a" /* CourseSelectComponent */].pupils.length;
            }
        }, function (err) {
            _this.messageService.add({
                severity: 'error',
                summary: 'Fehler',
                detail: 'Fehler beim Entfernen von ' + p.VNAME + ' ' + p.NNAME + " zum Kurs " + __WEBPACK_IMPORTED_MODULE_6__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME + ':' + err
            });
        });
    };
    KurszugehoerigkeitComponent.prototype.newPupil = function () {
        this.editedPupil = new __WEBPACK_IMPORTED_MODULE_1__data_Pupil__["a" /* Pupil */]();
        this.editDialog.showDialog(this.editedPupil);
    };
    KurszugehoerigkeitComponent.prototype.editPupil = function (p) {
        this.editedPupil = p;
        console.log("Edit Pupil " + JSON.stringify(p));
        this.editDialog.showDialog(p);
    };
    KurszugehoerigkeitComponent.prototype.newCompleted = function (event) {
        this.editedPupil = event;
        console.log("Ein neuer Schüler:" + JSON.stringify(event));
        this.allPupils.push(event);
        this.orgAll.push(event);
    };
    KurszugehoerigkeitComponent.prototype.editCompleted = function (event) {
        console.log("Edit Completed: " + JSON.stringify(event));
        var p = this.allPupils.find(function (x) { return x.id == event.id; });
        p.VNAME = event.VNAME;
        p.NNAME = event.NNAME;
        p.ABGANG = event.ABGANG;
        p = this.orgAll.find(function (x) { return x.id == event.id; });
        p.VNAME = event.VNAME;
        p.NNAME = event.NNAME;
        p.ABGANG = event.ABGANG;
        p = this.coursePupils.find(function (x) { return x.id == event.id; });
        if (p) {
            p.VNAME = event.VNAME;
            p.NNAME = event.NNAME;
            p.ABGANG = event.ABGANG;
        }
        p = this.orgCourse.find(function (x) { return x.id == event.id; });
        if (p) {
            p.VNAME = event.VNAME;
            p.NNAME = event.NNAME;
            p.ABGANG = event.ABGANG;
        }
        p = __WEBPACK_IMPORTED_MODULE_2__CourseSelectComponent__["a" /* CourseSelectComponent */].pupils.find(function (x) { return x.id == event.id; });
        if (p) {
            p.VNAME = event.VNAME;
            p.NNAME = event.NNAME;
            p.ABGANG = event.ABGANG;
            this.courseService.anzahl = __WEBPACK_IMPORTED_MODULE_2__CourseSelectComponent__["a" /* CourseSelectComponent */].pupils.filter(function (x) { return x.ABGANG == "N"; }).length;
        }
    };
    return KurszugehoerigkeitComponent;
}());
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('editDialog'),
    __metadata("design:type", Object)
], KurszugehoerigkeitComponent.prototype, "editDialog", void 0);
KurszugehoerigkeitComponent = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'verwaltung',
        template: __webpack_require__("../../../../../src/app/KurszugehoerigkeitComponent.html"),
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_3__services_SharedService__["a" /* SharedService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_3__services_SharedService__["a" /* SharedService */]) === "function" && _a || Object, typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_4__services_PupilService__["a" /* PupilService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_4__services_PupilService__["a" /* PupilService */]) === "function" && _b || Object, typeof (_c = typeof __WEBPACK_IMPORTED_MODULE_5_primeng_components_common_messageservice__["MessageService"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_5_primeng_components_common_messageservice__["MessageService"]) === "function" && _c || Object, typeof (_d = typeof __WEBPACK_IMPORTED_MODULE_7__services_CourseService__["a" /* CourseService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_7__services_CourseService__["a" /* CourseService */]) === "function" && _d || Object])
], KurszugehoerigkeitComponent);

var _a, _b, _c, _d;
//# sourceMappingURL=KurszugehoerigkeitComponent.js.map

/***/ }),

/***/ "../../../../../src/app/LFSelectComponent.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return LFSelectComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__angular_common_http__ = __webpack_require__("../../../common/@angular/common/http.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice__ = __webpack_require__("../../../../primeng/components/common/messageservice.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__data_Config__ = __webpack_require__("../../../../../src/app/data/Config.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__services_SharedService__ = __webpack_require__("../../../../../src/app/services/SharedService.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};






var LFSelectComponent = (function () {
    function LFSelectComponent(http, messageService, sharedService) {
        this.http = http;
        this.messageService = messageService;
        this.sharedService = sharedService;
        this.lfLoaded = new __WEBPACK_IMPORTED_MODULE_0__angular_core__["EventEmitter"]();
        this.lfs = [];
        this.allLfs = [];
        this.selectedLF = "LF1";
        this.compDisabled = true;
        console.log("Construktor CourseSelectComponent");
    }
    LFSelectComponent.prototype.getLfNumber = function (s) {
        for (var i = 0; i < this.lfs.length; i++) {
            console.log("test (" + s + ") ist " + this.lfs[i].label);
            if (this.lfs[i].label == s) {
                return i;
            }
        }
        return -1;
    };
    LFSelectComponent.prototype.ngOnInit = function () {
        var _this = this;
        this.subscription = this.sharedService.getCoursebook().subscribe(function (message) {
            console.log("LFSelectComponent: Course Book Changed");
            _this.filterLfs();
        });
        // Make the HTTP request:
        this.http.get(__WEBPACK_IMPORTED_MODULE_3__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/noauth/lernfelder").subscribe(function (data) {
            // Read the result field from the JSON response.
            console.log("reveived lf:" + JSON.stringify(data));
            var lfd = data;
            for (var i = 0; i < lfd.length; i++) {
                //console.log("push "+lfd[i].id);
                _this.allLfs.push({ label: lfd[i].id, value: lfd[i].id });
            }
            console.log("all LFs size=" + _this.allLfs.length);
            _this.filterLfs();
        }, function (err) {
            _this.compDisabled = true;
            if (err.error instanceof Error) {
                // A client-side or network error occurred. Handle it accordingly.
                console.log('An error occurred:', err.error.message);
                _this.messageService.add({
                    severity: 'error',
                    summary: 'Fehler',
                    detail: 'Kann Lernfeldliste nicht vom Server laden! MSG=' + err.error.message
                });
            }
            else {
                // The backend returned an unsuccessful response code.
                // The response body may contain clues as to what went wrong,
                console.log("Backend returned code " + err.status + ", body was: " + err.error);
                _this.messageService.add({
                    severity: 'error',
                    summary: 'Fehler',
                    detail: 'Kann Lernfeldliste nicht vom Server laden! MSG=' + err.name
                });
            }
        });
    };
    LFSelectComponent.prototype.ngOnDestroy = function () {
        this.subscription.unsubscribe();
    };
    LFSelectComponent.prototype.filterLfs = function () {
        console.log("Course Categorie=" + __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.idKategorie);
        if (__WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.idKategorie == 1 || __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.idKategorie == 9) {
            this.lfs = this.allLfs.filter(function (lf) { return lf.label == "Kurs"; });
        }
        else {
            this.lfs = this.allLfs.filter(function (lf) { return lf.label != "Kurs"; });
        }
        console.log("Filter LFS size=" + this.lfs.length);
        this.compDisabled = false;
        this.selectedLF = this.lfs[0].value;
        this.lfLoaded.emit();
    };
    LFSelectComponent.prototype.removeLf = function (excluded) {
        console.log(" Entferne LF Eintrag " + excluded + " Da bereits Note(n) vorhanden!");
        console.log(" Bisherige einträge:" + JSON.stringify(this.lfs));
        for (var j = 0; j < this.lfs.length; j++) {
            if (this.lfs[j].label == excluded) {
                this.lfs.splice(j, 1);
                this.selectedLF = this.lfs[0].label;
                return;
            }
        }
    };
    LFSelectComponent.prototype.getSelectedLernfeld = function () {
        return this.selectedLF;
    };
    return LFSelectComponent;
}());
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Output"])(),
    __metadata("design:type", Object)
], LFSelectComponent.prototype, "lfLoaded", void 0);
LFSelectComponent = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'lfselect',
        template: '<strong>Lernfelder:</strong><br/>\n' +
            '<p-dropdown [autoWidth]="false" [options]="lfs" [(ngModel)]="selectedLF" placeholder="Lernfelder" [disabled]="compDisabled"></p-dropdown>\n',
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_1__angular_common_http__["a" /* HttpClient */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_1__angular_common_http__["a" /* HttpClient */]) === "function" && _a || Object, typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice__["MessageService"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice__["MessageService"]) === "function" && _b || Object, typeof (_c = typeof __WEBPACK_IMPORTED_MODULE_5__services_SharedService__["a" /* SharedService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_5__services_SharedService__["a" /* SharedService */]) === "function" && _c || Object])
], LFSelectComponent);

var _a, _b, _c;
//# sourceMappingURL=LFSelectComponent.js.map

/***/ }),

/***/ "../../../../../src/app/LehrerzugehoerigkeitComponent.html":
/***/ (function(module, exports) {

module.exports = "<p-pickList  (onMoveAllToTarget)=\"moveAllToTaget($event)\" (onMoveToTarget)=\"moveToTarget($event)\"  (onMoveToSource)=\"moveToSource($event)\"  [source]=\"allTeachers\" [target]=\"courseTeachers\" sourceHeader=\"Alle Lehrer\" [targetHeader]=\"courseName\" [responsive]=\"true\" filterBy=\"NNAME,VNAME,id\"\r\n            dragdrop=\"true\" dragdropScope=\"cars\" sourceFilterPlaceholder=\"Search..\" targetFilterPlaceholder=\"Search..\" [sourceStyle]=\"{'height':'300px'}\" [targetStyle]=\"{'height':'300px'}\">\r\n\r\n  <ng-template let-teacher pTemplate=\"item\">\r\n    <div style=\"text-align: left;\">\r\n      <span >{{teacher.id}}:{{teacher.VNAME}} {{teacher.NNAME}}</span>\r\n    </div>\r\n  </ng-template>\r\n</p-pickList>\r\n"

/***/ }),

/***/ "../../../../../src/app/LehrerzugehoerigkeitComponent.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return LehrerzugehoerigkeitComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__CourseSelectComponent__ = __webpack_require__("../../../../../src/app/CourseSelectComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__services_SharedService__ = __webpack_require__("../../../../../src/app/services/SharedService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice__ = __webpack_require__("../../../../primeng/components/common/messageservice.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__services_CourseService__ = __webpack_require__("../../../../../src/app/services/CourseService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6__services_TeacherService__ = __webpack_require__("../../../../../src/app/services/TeacherService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7__services_DokuService__ = __webpack_require__("../../../../../src/app/services/DokuService.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};








var LehrerzugehoerigkeitComponent = (function () {
    function LehrerzugehoerigkeitComponent(dokuService, service, teacherServive, messageService, courseService) {
        var _this = this;
        this.dokuService = dokuService;
        this.service = service;
        this.teacherServive = teacherServive;
        this.messageService = messageService;
        this.courseService = courseService;
        this.role = __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.role;
        this.courseName = "Lehrer der Klasse/des Kurses " + __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME;
        this.subscription = this.service.getCoursebook().subscribe(function (message) {
            console.log("LehrerzugehoerigkeitComponent Component Model Changed !" + message.constructor.name);
            _this.courseName = "Lehrer der Klasse/des Kurses " + __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME;
            _this.courseTeachers = new Array();
            _this.teacherServive.getTeachersOfCourse(__WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course).subscribe(function (data) {
                _this.courseTeachers = data;
                _this.courseTeachers = _this.courseTeachers.sort(function (obj1, obj2) {
                    return obj1.id.localeCompare(obj2.id);
                });
                _this.orgCourse = _this.courseTeachers.map(function (x) { return Object.assign({}, x); });
            }, function (err) {
                _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: 'Kann Lehrer der Klasse ' + __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME + ' nicht laden: ' + err });
            });
        });
        this.courseTeachers = new Array();
        this.teacherServive.getTeachersOfCourse(__WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course).subscribe(function (data) {
            _this.courseTeachers = data;
            _this.courseTeachers = _this.courseTeachers.sort(function (obj1, obj2) {
                return obj1.id.localeCompare(obj2.id);
            });
            _this.orgCourse = _this.courseTeachers.map(function (x) { return Object.assign({}, x); });
        }, function (err) {
            _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: 'Kann Lehrer der Klasse ' + __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME + ' nicht laden: ' + err });
        });
    }
    LehrerzugehoerigkeitComponent.prototype.ngOnInit = function () {
        var _this = this;
        //     this.coursePupils=CourseSelectComponent.pupils.map(x => Object.assign({}, x));
        this.dokuService.setDisplayDoku(false);
        this.teacherServive.getTeachers().subscribe(function (data) {
            _this.allTeachers = data;
            _this.orgAll = new Array();
            _this.allTeachers = _this.allTeachers.map(function (x) { return Object.assign({}, x); });
            _this.allTeachers = _this.allTeachers.sort(function (obj1, obj2) {
                return obj1.id.localeCompare(obj2.id);
            });
            _this.orgAll = _this.allTeachers.map(function (x) { return Object.assign({}, x); });
        }, function (err) {
            _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: 'Fehler beim laden aller Lehrer: ' + err });
        });
    };
    LehrerzugehoerigkeitComponent.prototype.ngOnDestroy = function () {
        this.subscription.unsubscribe();
    };
    LehrerzugehoerigkeitComponent.prototype.moveToTarget = function (event) {
        console.log("items.length=" + event.items.length + " all.length=" + this.allTeachers.length);
        if (this.allTeachers.length != 0) {
            this.allTeachers = [];
            this.allTeachers = this.orgAll.map(function (x) { return Object.assign({}, x); });
            console.log("Move to Traget " + JSON.stringify(event));
            for (var i = 0; i < event.items.length; i++) {
                this.addTeacher(event.items[i]);
            }
        }
    };
    LehrerzugehoerigkeitComponent.prototype.moveToSource = function (event) {
        console.log("Move to Source " + JSON.stringify(event));
        this.allTeachers = [];
        this.allTeachers = this.orgAll.map(function (x) { return Object.assign({}, x); });
        for (var i = 0; i < event.items.length; i++) {
            this.removeTeacher(event.items[i]);
        }
    };
    LehrerzugehoerigkeitComponent.prototype.moveAllToTaget = function (event) {
        this.messageService.add({ severity: 'error', summary: 'Fehler', detail: 'Funktion nicht zulässig!' });
        this.allTeachers = [];
        this.allTeachers = this.orgAll.map(function (x) { return Object.assign({}, x); });
        this.courseTeachers = [];
        this.courseTeachers = this.orgCourse.map(function (x) { return Object.assign({}, x); });
    };
    LehrerzugehoerigkeitComponent.prototype.addTeacher = function (p) {
        var _this = this;
        this.teacherServive.addTeacherToCourse(p, __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course).subscribe(function (data) {
            //this.allPupils=new Array();
            //this.allPupils=this.orgAll.map(x => Object.assign({}, x));
            if (!data.success) {
                _this.messageService.add({
                    severity: 'error',
                    summary: 'Fehler',
                    detail: 'Fehler beim Hinzufügen von ' + p.VNAME + ' ' + p.NNAME + " zum Kurs " + __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME + ':' + data.msg
                });
                _this.courseTeachers = _this.orgCourse.map(function (x) { return Object.assign({}, x); });
            }
            else {
                console.log("Füge hinzu zur Liste " + JSON.stringify(p));
                //          CourseSelectComponent.pupils.push(p);
                _this.orgCourse.push(p);
                _this.courseService.anzahl = __WEBPACK_IMPORTED_MODULE_1__CourseSelectComponent__["a" /* CourseSelectComponent */].pupils.length;
            }
        }, function (err) {
            _this.messageService.add({
                severity: 'error',
                summary: 'Fehler',
                detail: 'Fehler beim Hinzufügen von ' + p.VNAME + ' ' + p.NNAME + " zum Kurs " + __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME + ':' + err
            });
        });
    };
    LehrerzugehoerigkeitComponent.prototype.removeTeacher = function (p) {
        var _this = this;
        this.teacherServive.removeTeacherFromCourse(p, __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course).subscribe(function (data) {
            _this.allTeachers = new Array();
            _this.allTeachers = _this.orgAll.map(function (x) { return Object.assign({}, x); });
            if (!data.success) {
                _this.messageService.add({
                    severity: 'error',
                    summary: 'Fehler',
                    detail: 'Fehler beim Entfernen von ' + p.VNAME + ' ' + p.NNAME + " zum Kurs " + __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME + ':' + data.msg
                });
                _this.courseTeachers = _this.orgCourse.map(function (x) { return Object.assign({}, x); });
            }
            else {
                // CourseSelectComponent.pupils = CourseSelectComponent.pupils.filter(obj => obj.id != p.id);
                _this.orgCourse = _this.orgCourse.filter(function (obj) { return obj.id != p.id; });
                _this.courseService.anzahl = __WEBPACK_IMPORTED_MODULE_1__CourseSelectComponent__["a" /* CourseSelectComponent */].pupils.length;
            }
        }, function (err) {
            _this.messageService.add({
                severity: 'error',
                summary: 'Fehler',
                detail: 'Fehler beim Entfernen von ' + p.VNAME + ' ' + p.NNAME + " zum Kurs " + __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME + ':' + err
            });
        });
    };
    return LehrerzugehoerigkeitComponent;
}());
LehrerzugehoerigkeitComponent = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'verwaltung',
        template: __webpack_require__("../../../../../src/app/LehrerzugehoerigkeitComponent.html"),
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_7__services_DokuService__["a" /* DokuService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_7__services_DokuService__["a" /* DokuService */]) === "function" && _a || Object, typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_2__services_SharedService__["a" /* SharedService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_2__services_SharedService__["a" /* SharedService */]) === "function" && _b || Object, typeof (_c = typeof __WEBPACK_IMPORTED_MODULE_6__services_TeacherService__["a" /* TeacherService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_6__services_TeacherService__["a" /* TeacherService */]) === "function" && _c || Object, typeof (_d = typeof __WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice__["MessageService"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice__["MessageService"]) === "function" && _d || Object, typeof (_e = typeof __WEBPACK_IMPORTED_MODULE_5__services_CourseService__["a" /* CourseService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_5__services_CourseService__["a" /* CourseService */]) === "function" && _e || Object])
], LehrerzugehoerigkeitComponent);

var _a, _b, _c, _d, _e;
//# sourceMappingURL=LehrerzugehoerigkeitComponent.js.map

/***/ }),

/***/ "../../../../../src/app/ListVerlaufComponent.css":
/***/ (function(module, exports, __webpack_require__) {

exports = module.exports = __webpack_require__("../../../../css-loader/lib/css-base.js")(false);
// imports


// module
exports.push([module.i, "\r\n.del {\r\n  cursor: pointer;\r\n}\r\n\r\n.edit {\r\n  cursor: pointer;\r\n\r\n}\r\n\r\n.links {\r\n  text-align: left;\r\n}\r\n", ""]);

// exports


/*** EXPORTS FROM exports-loader ***/
module.exports = module.exports.toString();

/***/ }),

/***/ "../../../../../src/app/ListVerlaufComponent.html":
/***/ (function(module, exports) {

module.exports = "<p-dataList [value]=\"verlauf\" >\r\n  <p-header>\r\n    <h3>Unterrichtverlauf der Klasse {{KName}} von {{from | date: 'dd.MM.yyyy'}} bis {{to | date: 'dd.MM.yyyy'}}</h3>\r\n    <span class=\"ui-inputgroup-addon\"><i class=\"fa fa-filter\"></i></span>\r\n    <input type=\"text\" (keyup)=\"filterChanged()\"  [(ngModel)]=\"filter\" pInputText placeholder=\"Filter\">\r\n    <div class=\"ui-g ui-fluid\">\r\n      <div class=\"ui-g-12 ui-md-1 links\" >\r\n        <strong>Datum</strong>\r\n      </div>\r\n      <div class=\"ui-md-1 links\" >\r\n        <strong>Lehrer</strong>\r\n      </div>\r\n      <div class=\"ui-md-1 links\" >\r\n        <strong>Std./ LF</strong>\r\n      </div>\r\n      <div class=\"ui-md-3 links\" >\r\n        <strong>Inhalt</strong>\r\n      </div>\r\n      <div class=\"ui-md-3 links\" >\r\n        <strong>Bemerkungen</strong>\r\n      </div>\r\n      <div class=\"ui-md-3 links\" >\r\n        <strong>Lernsituation</strong>\r\n      </div>\r\n    </div>\r\n  </p-header>\r\n  <ng-template let-verlauf pTemplate=\"item\" let-i=\"index\">\r\n    <div class=\"ui-g ui-fluid\">\r\n      <div class=\"ui-g-12 ui-md-1 links\" >\r\n        {{verlauf.wochentag}}{{verlauf.DATUM |  date: 'dd.MM.yyyy'}}\r\n      </div>\r\n      <div class=\"ui-md-1 links\" >\r\n        {{verlauf.ID_LEHRER}}\r\n        <img *ngIf=\"verlauf.ID_LEHRER==IDLehrer\" (click)=\"delete(verlauf,i)\" class=\"del\" src=\"../assets/del.png\" width=\"16\" height=\"16\">\r\n        <img *ngIf=\"verlauf.ID_LEHRER==IDLehrer\" (click)=\"edit(verlauf,i)\" class=\"edit\" src=\"../assets/edit.png\" width=\"16\" height=\"16\">\r\n\r\n      </div>\r\n      <div class=\"ui-md-1 links\" >\r\n        {{verlauf.STUNDE}} / {{verlauf.ID_LERNFELD}}\r\n      </div>\r\n      <div class=\"ui-md-3 links\" >\r\n        {{verlauf.INHALT}}\r\n      </div>\r\n      <div class=\"ui-md-3 links\" >\r\n        {{verlauf.BEMERKUNG}}\r\n      </div>\r\n      <div class=\"ui-md-3 links\" >\r\n        {{verlauf.AUFGABE}}\r\n      </div>\r\n    </div>\r\n  </ng-template>\r\n</p-dataList>\r\n<deleteverlauf (deleteVerlauf)=\"confirmDelete($event)\" #deleteDialog></deleteverlauf>\r\n\r\n"

/***/ }),

/***/ "../../../../../src/app/ListVerlaufComponent.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return ListVerlaufComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__data_CourseBook__ = __webpack_require__("../../../../../src/app/data/CourseBook.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_add_operator_startWith__ = __webpack_require__("../../../../rxjs/add/operator/startWith.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_add_operator_startWith___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_2_rxjs_add_operator_startWith__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_rxjs_add_observable_merge__ = __webpack_require__("../../../../rxjs/add/observable/merge.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_rxjs_add_observable_merge___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_3_rxjs_add_observable_merge__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_map__ = __webpack_require__("../../../../rxjs/add/operator/map.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_map___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_map__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5_rxjs_add_operator_debounceTime__ = __webpack_require__("../../../../rxjs/add/operator/debounceTime.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5_rxjs_add_operator_debounceTime___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_5_rxjs_add_operator_debounceTime__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6_rxjs_add_operator_distinctUntilChanged__ = __webpack_require__("../../../../rxjs/add/operator/distinctUntilChanged.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6_rxjs_add_operator_distinctUntilChanged___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_6_rxjs_add_operator_distinctUntilChanged__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7_rxjs_add_observable_fromEvent__ = __webpack_require__("../../../../rxjs/add/observable/fromEvent.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7_rxjs_add_observable_fromEvent___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_7_rxjs_add_observable_fromEvent__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_8__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_9__services_SharedService__ = __webpack_require__("../../../../../src/app/services/SharedService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_10_primeng_components_common_messageservice__ = __webpack_require__("../../../../primeng/components/common/messageservice.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_10_primeng_components_common_messageservice___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_10_primeng_components_common_messageservice__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_11__angular_http__ = __webpack_require__("../../../http/@angular/http.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_12__services_VerlaufsService__ = __webpack_require__("../../../../../src/app/services/VerlaufsService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_13__data_Config__ = __webpack_require__("../../../../../src/app/data/Config.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};














/**
 * @title List Verlauf
 */
var ListVerlaufComponent = (function () {
    function ListVerlaufComponent(verlaufsService, service, messageService) {
        this.verlaufsService = verlaufsService;
        this.service = service;
        this.messageService = messageService;
        this.editVerlauf = new __WEBPACK_IMPORTED_MODULE_0__angular_core__["EventEmitter"]();
        this.filter = "";
        this.compDisabled = true;
        this.IDLehrer = __WEBPACK_IMPORTED_MODULE_8__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.idLehrer;
    }
    ListVerlaufComponent.prototype.ngOnInit = function () {
        var _this = this;
        console.log("!!!!List Verlauf Component ngInit CourseBook=" + __WEBPACK_IMPORTED_MODULE_8__CourseBookComponent__["a" /* CourseBookComponent */].courseBook);
        this.subscription = this.service.getCoursebook().subscribe(function (message) {
            console.log("List Component Received !" + message.constructor.name);
            _this.getVerlauf();
        });
        this.getVerlauf();
    };
    ListVerlaufComponent.prototype.ngOnDestroy = function () {
        this.subscription.unsubscribe();
    };
    ListVerlaufComponent.prototype.ngAfterViewInit = function () {
        console.log("!!!!List Verlauf Component ngAfterInit CourseBook=" + __WEBPACK_IMPORTED_MODULE_8__CourseBookComponent__["a" /* CourseBookComponent */].courseBook);
    };
    ListVerlaufComponent.prototype.filterChanged = function () {
        var _this = this;
        console.log("Filter Changed! (" + this.filter + ")");
        if (this.filter.length == 0) {
            this.verlauf = this.orgVerlauf;
        }
        else {
            this.verlauf = this.orgVerlauf.filter(function (obj) {
                var a = obj.ID_LEHRER + obj.ID_LERNFELD + obj.wochentag + obj.INHALT + obj.AUFGABE + obj.BEMERKUNG;
                return a.match(_this.filter);
            });
        }
    };
    ListVerlaufComponent.prototype.getVerlauf = function () {
        var _this = this;
        this.KName = __WEBPACK_IMPORTED_MODULE_8__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME;
        this.from = __WEBPACK_IMPORTED_MODULE_8__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.fromDate;
        this.to = __WEBPACK_IMPORTED_MODULE_8__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.toDate;
        // Make the HTTP request:
        console.log("URL=" + __WEBPACK_IMPORTED_MODULE_13__data_Config__["a" /* Config */].SERVER + "/Diklabu/api/v1/verlauf/" + __WEBPACK_IMPORTED_MODULE_8__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME + "/" + __WEBPACK_IMPORTED_MODULE_1__data_CourseBook__["a" /* CourseBook */].toSQLString(__WEBPACK_IMPORTED_MODULE_8__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.fromDate) + "/" + __WEBPACK_IMPORTED_MODULE_1__data_CourseBook__["a" /* CourseBook */].toSQLString(__WEBPACK_IMPORTED_MODULE_8__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.toDate));
        var headers = new __WEBPACK_IMPORTED_MODULE_11__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_8__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.verlaufsService.getVerlauf().subscribe(function (data) {
            console.log("Verlauf=" + JSON.stringify(data));
            _this.verlauf = data;
            _this.orgVerlauf = data;
        }, function (err) {
            _this.messageService.add({
                severity: 'error',
                summary: 'Fehler',
                detail: 'Kann Verlauf nicht vom Server laden! MSG=' + err
            });
        });
    };
    ListVerlaufComponent.prototype.addVerlauf = function (v) {
        console.log("Suche EIntrag!" + JSON.stringify(v));
        for (var i = 0; i < this.orgVerlauf.length; i++) {
            console.log("Vergleich " + JSON.stringify(this.orgVerlauf[i]));
            if (this.orgVerlauf[i].ID_LEHRER === v.ID_LEHRER && this.orgVerlauf[i].STUNDE === v.STUNDE && this.orgVerlauf[i].DATUM === v.DATUM) {
                //if (this.orgVerlauf[i].ID === v.ID) {
                console.log("EIntrag! gefunden (wird aktualisiert!) ID=" + v.ID);
                this.orgVerlauf[i].INHALT = v.INHALT;
                this.orgVerlauf[i].BEMERKUNG = v.BEMERKUNG;
                this.orgVerlauf[i].AUFGABE = v.AUFGABE;
                this.orgVerlauf[i].ID_LERNFELD = v.ID_LERNFELD;
                this.orgVerlauf[i].ID = v.ID;
                this.filterChanged();
                return;
            }
        }
        console.log(" Neuer Einrag wird eingefügt");
        this.orgVerlauf.push(v);
        console.log("Pushed " + JSON.stringify(v));
        this.orgVerlauf = this.orgVerlauf.sort(function (v1, v2) {
            console.log("Sortierung!");
            if (v1.DATUM > v2.DATUM) {
                return 1;
            }
            if (v1.DATUM < v2.DATUM) {
                return -1;
            }
            var std1 = +v1.STUNDE;
            var std2 = +v2.STUNDE;
            if (std1 > std2) {
                return 1;
            }
            ;
            if (std1 < std2) {
                return -1;
            }
            ;
            return 0;
        });
        this.filterChanged();
    };
    ListVerlaufComponent.prototype.delete = function (v, index) {
        console.log("Delete Verlauf index=" + index + " Modell=" + JSON.stringify(v));
        this.deleteDialog.showDialog("Verlaufseintrag löschen?", v);
    };
    ListVerlaufComponent.prototype.confirmDelete = function (v) {
        var _this = this;
        this.verlaufsService.deleteVerlauf(v).subscribe(function (data) {
            console.log("Delete Verlauf=" + JSON.stringify(data));
            _this.orgVerlauf = _this.orgVerlauf.filter(function (obj) { return obj.ID !== v.ID; });
            _this.filterChanged();
        }, function (err) {
            _this.messageService.add({
                severity: 'error',
                summary: 'Fehler',
                detail: 'Kann Verlaufselement nicht löschen! MSG=' + err.error.message
            });
        });
    };
    ListVerlaufComponent.prototype.edit = function (v, index) {
        this.selectedVerlauf = v;
        this.selectedIndex = index;
        console.log("edit index=" + index + " Element=" + JSON.stringify(v));
        this.editVerlauf.emit(v);
    };
    return ListVerlaufComponent;
}());
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Output"])(),
    __metadata("design:type", Object)
], ListVerlaufComponent.prototype, "editVerlauf", void 0);
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('deleteDialog'),
    __metadata("design:type", Object)
], ListVerlaufComponent.prototype, "deleteDialog", void 0);
ListVerlaufComponent = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'listverlauf',
        styles: [__webpack_require__("../../../../../src/app/ListVerlaufComponent.css")],
        template: __webpack_require__("../../../../../src/app/ListVerlaufComponent.html"),
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_12__services_VerlaufsService__["a" /* VerlaufsService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_12__services_VerlaufsService__["a" /* VerlaufsService */]) === "function" && _a || Object, typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_9__services_SharedService__["a" /* SharedService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_9__services_SharedService__["a" /* SharedService */]) === "function" && _b || Object, typeof (_c = typeof __WEBPACK_IMPORTED_MODULE_10_primeng_components_common_messageservice__["MessageService"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_10_primeng_components_common_messageservice__["MessageService"]) === "function" && _c || Object])
], ListVerlaufComponent);

var _a, _b, _c;
//# sourceMappingURL=ListVerlaufComponent.js.map

/***/ }),

/***/ "../../../../../src/app/LoginComponent.css":
/***/ (function(module, exports, __webpack_require__) {

exports = module.exports = __webpack_require__("../../../../css-loader/lib/css-base.js")(false);
// imports


// module
exports.push([module.i, ".log {\r\n\r\n}\r\n\r\n\r\nh1 {\r\n  margin: 0px;\r\n}\r\n\r\n#wrapper {\r\n  background-image: url(" + __webpack_require__("../../../../../src/assets/mmbbs.jpg") + ");\r\n  background-repeat: no-repeat;\r\n  background-size:100% auto;\r\n  padding: 0px;\r\n  margin: 0px;\r\n  height:100vh;\r\n}\r\n\r\n.content {\r\n  width: 400px;\r\n  height: 180px;\r\n  background-color: rgba(255, 255, 255, 0.7); /* Color white with alpha 0.9*/\r\n\r\n\r\n\r\n  position:absolute; /*it can be fixed too*/\r\n  left:0; right:0;\r\n  top:0; bottom:0;\r\n  margin:auto;\r\n\r\n  /*this to solve \"the content will not be cut when the window is smaller than the content\": */\r\n  max-width:100%;\r\n  max-height:100%;\r\n  overflow:auto;\r\n  border-color: black;\r\n  border-style: solid;\r\n  border-width: 1px;\r\n  border-radius: 15px;\r\n}\r\n\r\n.box {\r\n  width: 360px;\r\n}\r\n\r\n.footer {\r\n  background-color: rgba(255, 255, 255, 0.7); /* Color white with alpha 0.9*/\r\n  position: absolute;\r\n  bottom: 0px;\r\n  right: 0px;\r\n  text-align: right;\r\n  width: 100%;\r\n\r\n}\r\n\r\n", ""]);

// exports


/*** EXPORTS FROM exports-loader ***/
module.exports = module.exports.toString();

/***/ }),

/***/ "../../../../../src/app/LoginComponent.html":
/***/ (function(module, exports) {

module.exports = "<div id=\"wrapper\">\r\n  <div id=\"first\">\r\n    <h1>DiKlaBu</h1>\r\n    <h3>Digitales Klassenbuch</h3>\r\n    <strong>realisiert mit..</strong><br/><br/>\r\n    <img src=\"../assets/angular2typescript.png\">\r\n    <img src=\"../assets/primeng-2.png\">\r\n    <br/>\r\n  </div>\r\n  <div  *ngIf=\"phase==0\"  class=\"content\">\r\n    <div class=\"ui-g ui-fluid box\">\r\n      <div class=\"ui-g-12 ui-md-11 ui-md-offset-1\">\r\n        <h3>Anmeldung</h3>\r\n        <div class=\"ui-inputgroup\">\r\n          <span class=\"ui-inputgroup-addon\"><i class=\"fa fa-user\"></i></span>\r\n          <input [(ngModel)]=\"username\" type=\"text\" pInputText placeholder=\"Username\">\r\n        </div>\r\n        <br/>\r\n        <div class=\"ui-inputgroup\">\r\n          <span class=\"ui-inputgroup-addon\"><i class=\"fa fa-key\"></i></span>\r\n          <input [(ngModel)]=\"password\" type=\"password\" pInputText placeholder=\"Kennwort\">\r\n        </div>\r\n        <br/>\r\n        <br/>\r\n      </div>\r\n    </div>\r\n    <button pButton type=\"button\" (click)=\"performLogin()\" label=\"Login\" icon=\"fa-check\" ></button>\r\n  </div>\r\n  <div  *ngIf=\"phase==1\"  class=\"content\">\r\n    <div class=\"ui-g ui-fluid box\">\r\n      <div class=\"ui-g-12 ui-md-11 ui-md-offset-1\">\r\n        <h3>Anmeldung (Phase 2)</h3>\r\n        <br/>\r\n        <div class=\"ui-inputgroup\">\r\n          <span class=\"ui-inputgroup-addon\"><i class=\"fa fa-user-secret\"></i></span>\r\n          <input [(ngModel)]=\"pin\" type=\"text\" pInputText placeholder=\"PIN\">\r\n        </div>\r\n        <br/>\r\n        <br/>\r\n      </div>\r\n    </div>\r\n    <button pButton type=\"button\" (click)=\"sendPin()\" label=\"Login\" icon=\"fa-check\" ></button>\r\n  </div>\r\n\r\n</div>\r\n<div class=\"footer\">\r\n  <strong>Version {{version}} / Serverversion: {{serverVersion}}</strong>\r\n</div>\r\n"

/***/ }),

/***/ "../../../../../src/app/LoginComponent.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return LoginComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__services_LoginService__ = __webpack_require__("../../../../../src/app/services/LoginService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice__ = __webpack_require__("../../../../primeng/components/common/messageservice.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4__angular_router__ = __webpack_require__("../../../router/@angular/router.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__data_Config__ = __webpack_require__("../../../../../src/app/data/Config.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};






var LoginComponent = (function () {
    function LoginComponent(loginService, messageService, router) {
        var _this = this;
        this.loginService = loginService;
        this.messageService = messageService;
        this.router = router;
        this.username = "";
        this.password = "";
        this.version = __WEBPACK_IMPORTED_MODULE_5__data_Config__["a" /* Config */].version;
        this.serverVersion = "";
        this.twoFA = false;
        this.phase = 0;
        if (__WEBPACK_IMPORTED_MODULE_5__data_Config__["a" /* Config */].debug) {
            __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token = 1234;
            __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.idLehrer = "TU";
            __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.username = "TU";
            __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.password = "mmbbs";
            __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.email = "tuttas@mmbbs.de";
            var link = ['/diklabu'];
            this.router.navigate(link);
        }
        this.addJsToElement(__WEBPACK_IMPORTED_MODULE_5__data_Config__["a" /* Config */].SERVER + "/Diklabu/ClientConfig").onload = function () {
            console.log('ClientConfig Tag loaded');
            _this.serverVersion = VERSION;
            _this.twoFA = TWOFA;
        };
    }
    LoginComponent.prototype.addJsToElement = function (src) {
        var script = document.createElement('script');
        script.type = 'text/javascript';
        script.src = src;
        document.getElementsByTagName('head')[0].appendChild(script);
        return script;
    };
    LoginComponent.prototype.sendPin = function () {
        var _this = this;
        this.loginService.setPin(this.pin, this.uid).subscribe(function (data) {
            console.log("Received from Login2: " + JSON.stringify(data));
            if (data.success) {
                __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token = data.auth_token;
                __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.idLehrer = data.ID;
                __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.username = _this.username;
                __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.password = _this.password;
                __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.email = data.email;
                __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.role = data.role;
                __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.ID = data.ID;
                if (data.role == "Schueler") {
                    _this.router.navigate(['/schueler']);
                }
                else {
                    _this.router.navigate(['/diklabu', { outlets: { sub: 'verlauf' } }]);
                }
            }
            else {
                _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: data.msg });
                _this.phase = 0;
                delete _this.pin;
            }
        }, function (err) {
            _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: err });
        });
    };
    LoginComponent.prototype.performLogin = function () {
        var _this = this;
        console.log("Login with " + this.username + " and PW=" + this.password);
        this.loginService.performLogin(this.username, this.password).subscribe(function (data) {
            console.log("Received from Login: " + JSON.stringify(data));
            if (_this.twoFA && data.role != "Schueler") {
                if (data.success) {
                    _this.messageService.add({ severity: 'info', summary: 'Info', detail: data.msg });
                    _this.uid = data.uid;
                    _this.phase = 1;
                }
                else {
                    _this.messageService.add({ severity: 'warning', summary: 'Warnung', detail: data.msg });
                }
            }
            else {
                __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token = data.auth_token;
                __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.idLehrer = data.ID;
                __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.username = _this.username;
                __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.password = _this.password;
                __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.email = data.email;
                __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.role = data.role;
                __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.ID = data.ID;
                if (data.role == "Schueler") {
                    _this.router.navigate(['/schueler']);
                }
                else {
                    _this.router.navigate(['/diklabu', { outlets: { sub: 'verlauf' } }]);
                }
            }
        }, function (err) {
            console.log("got Error:" + JSON.stringify(err));
            var data = JSON.parse(err);
            _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: data.message });
        });
    };
    return LoginComponent;
}());
LoginComponent = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'login',
        styles: [__webpack_require__("../../../../../src/app/LoginComponent.css")],
        template: __webpack_require__("../../../../../src/app/LoginComponent.html"),
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_1__services_LoginService__["a" /* LoginService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_1__services_LoginService__["a" /* LoginService */]) === "function" && _a || Object, typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice__["MessageService"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice__["MessageService"]) === "function" && _b || Object, typeof (_c = typeof __WEBPACK_IMPORTED_MODULE_4__angular_router__["Router"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_4__angular_router__["Router"]) === "function" && _c || Object])
], LoginComponent);

var _a, _b, _c;
//# sourceMappingURL=LoginComponent.js.map

/***/ }),

/***/ "../../../../../src/app/MailDialog.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return MailDialog; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__data_MailObject__ = __webpack_require__("../../../../../src/app/data/MailObject.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__services_MailService__ = __webpack_require__("../../../../../src/app/services/MailService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice__ = __webpack_require__("../../../../primeng/components/common/messageservice.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice__);
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};




var MailDialog = (function () {
    function MailDialog(mailService, messageService) {
        this.mailService = mailService;
        this.messageService = messageService;
        this.display = false;
        this.titel = "";
        this.dialogWidth = 500;
    }
    MailDialog.prototype.showDialog = function (titel) {
        this.titel = titel;
        this.display = true;
    };
    MailDialog.prototype.getRows = function () {
        var r = this.mail.content.split("\n").length;
        if (r > 25) {
            r = 25;
        }
        ;
        if (r < 3) {
            r = 3;
        }
        return r;
    };
    MailDialog.prototype.sendMail = function () {
        var _this = this;
        this.display = false;
        this.mailService.sendMail(this.mail).subscribe(function (answer) {
            console.log("Answer from Mailservice:" + JSON.stringify(answer));
            if (answer.success == false) {
                _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: answer.msg });
                _this.display = true;
            }
            else {
                _this.messageService.add({ severity: 'info', summary: 'Info', detail: 'Mail erfolgreich versandt!' });
            }
        }, function (err) {
            console.log("Error from Mailservice:" + err);
            _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: err });
        });
    };
    return MailDialog;
}());
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Input"])(),
    __metadata("design:type", typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_1__data_MailObject__["a" /* MailObject */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_1__data_MailObject__["a" /* MailObject */]) === "function" && _a || Object)
], MailDialog.prototype, "mail", void 0);
MailDialog = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'sendmail',
        styles: ['input {' +
                'width:100%;' +
                '}' +
                'textarea{width:100%;}'
        ],
        template: ' <p-dialog [header]="titel" [(visible)]="display" modal="modal" [closable]="true" [width]="dialogWidth" appendTo="body"><br/>' +
            '<span class="ui-float-label">' +
            '<input id="to" type="text" pInputText [(ngModel)]="mail.recipientString"/>' +
            '<label for="to">An:</label>' +
            '</span><br/>' +
            '<div *ngIf="mail.cc.length>0"><br/> <span class="ui-float-label" >' +
            '<input id="cc" type="text" pInputText [(ngModel)]="mail.ccString"/>' +
            '<label for="cc">CC:</label>' +
            '</span><br/></div>' +
            '<div *ngIf="mail.bcc.length>0"><br/> <span class="ui-float-label" >' +
            '<input id="bcc" type="text"  pInputText [(ngModel)]="mail.bccString"/>' +
            '<label for="bcc">BCC:</label>' +
            '</span><br/></div>' +
            '<br/><span class="ui-float-label">' +
            '<input id="subject" type="text" pInputText [(ngModel)]="mail.subject"/>' +
            '<label for="subject">Betreff</label>' +
            '</span><br/>' +
            '<strong>Inhalt</strong><br/>' +
            '<textarea rows="{{getRows()}}" pInputTextarea [(ngModel)]="mail.content"></textarea>' +
            '<br/>' +
            '        <p-footer>\n' +
            '            <button type="button" class="ui-button-success" pButton icon="fa-check" (click)="sendMail()" label="Absenden"></button>\n' +
            '            <button type="button" pButton icon="fa-close" (click)="display=false" label="Abbrechen"></button>\n' +
            '        </p-footer>\n' +
            '</p-dialog>'
    }),
    __metadata("design:paramtypes", [typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_2__services_MailService__["a" /* MailService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_2__services_MailService__["a" /* MailService */]) === "function" && _b || Object, typeof (_c = typeof __WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice__["MessageService"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice__["MessageService"]) === "function" && _c || Object])
], MailDialog);

var _a, _b, _c;
//# sourceMappingURL=MailDialog.js.map

/***/ }),

/***/ "../../../../../src/app/MenuComponent.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return MenuComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__services_LoginService__ = __webpack_require__("../../../../../src/app/services/LoginService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__angular_router__ = __webpack_require__("../../../router/@angular/router.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_primeng_components_common_messageservice__ = __webpack_require__("../../../../primeng/components/common/messageservice.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_primeng_components_common_messageservice___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_4_primeng_components_common_messageservice__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__data_Config__ = __webpack_require__("../../../../../src/app/data/Config.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};






var MenuComponent = (function () {
    function MenuComponent(loginService, router, messageService, route) {
        this.loginService = loginService;
        this.router = router;
        this.messageService = messageService;
        this.route = route;
    }
    MenuComponent.prototype.ngOnInit = function () {
        var _this = this;
        if (__WEBPACK_IMPORTED_MODULE_1__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.role == "Verwaltung" || __WEBPACK_IMPORTED_MODULE_1__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.role == "Admin" || __WEBPACK_IMPORTED_MODULE_5__data_Config__["a" /* Config */].debug) {
            this.items = [
                { label: 'Verlauf', icon: 'fa-flash', command: function (event2) { return _this.showVerlauf(event2); } },
                {
                    label: 'Anwesenheit', icon: 'fa-check',
                    items: [
                        { label: 'Übersicht', icon: 'fa-table', command: function (event2) { return _this.showAnwesenheit(event2); } },
                        { label: 'heute', icon: 'fa-user-plus', command: function (event2) { return _this.showTodayAnwesenheit(event2); } }
                    ]
                },
                { label: 'Fehlzeiten', icon: 'fa-hotel', command: function (event2) { return _this.showFehlzeiten(event2); } },
                { label: 'Klasse/Betriebe', icon: 'fa-info-circle', command: function (event2) { return _this.showBetriebe(event2); } },
                // {label: 'Noten', icon: 'fa-graduation-cap', command: event2 => this.showGrades(event2)},
                // {label: 'Portfolio', icon: 'fa-certificate', command: event2 => this.showPortfolio(event2)},
                {
                    label: 'Verwaltung', icon: 'fa-eye',
                    items: [
                        { label: 'Schülerzugehörigkeit', icon: 'fa-table', command: function (event2) { return _this.showZugehoerigkeit(event2); } },
                        { label: 'Lehrerzugehörigkeit', icon: 'fa-book', command: function (event2) { return _this.showLehrerZugehoerigkeit(event2); } },
                    ]
                },
                { label: 'Logout', icon: 'fa-times', command: function (event2) { return _this.logout(event2); } }
            ];
        }
        else {
            this.items = [
                { label: 'Verlauf', icon: 'fa-flash', command: function (event2) { return _this.showVerlauf(event2); } },
                {
                    label: 'Anwesenheit', icon: 'fa-check',
                    items: [
                        { label: 'Übersicht', icon: 'fa-table', command: function (event2) { return _this.showAnwesenheit(event2); } },
                        { label: 'heute', icon: 'fa-user-plus', command: function (event2) { return _this.showTodayAnwesenheit(event2); } }
                    ]
                },
                { label: 'Fehlzeiten', icon: 'fa-hotel', command: function (event2) { return _this.showFehlzeiten(event2); } },
                { label: 'Klasse/Betriebe', icon: 'fa-info-circle', command: function (event2) { return _this.showBetriebe(event2); } },
                { label: 'Noten', icon: 'fa-graduation-cap', command: function (event2) { return _this.showGrades(event2); } },
                { label: 'Logout', icon: 'fa-times', command: function (event2) { return _this.logout(event2); } }
            ];
        }
    };
    MenuComponent.prototype.showVerlauf = function (e) {
        console.log("show Verlauf");
        this.router.navigate(['/diklabu', { outlets: { sub: 'verlauf' } }]);
    };
    MenuComponent.prototype.showZugehoerigkeit = function (e) {
        console.log("show Zugehörigkeit");
        this.router.navigate(['/diklabu', { outlets: { sub: 'zugehoerigkeit' } }]);
    };
    MenuComponent.prototype.showLehrerZugehoerigkeit = function (e) {
        console.log("show Lehrer Zugehörigkeit");
        this.router.navigate(['/diklabu', { outlets: { sub: 'lzugehoerigkeit' } }]);
    };
    MenuComponent.prototype.showAnwesenheit = function (e) {
        console.log("show Anwesenheit");
        this.router.navigate(['/diklabu', { outlets: { sub: 'anwesenheit' } }]);
    };
    MenuComponent.prototype.showFehlzeiten = function (e) {
        console.log("show Fehlzeiten");
        this.router.navigate(['/diklabu', { outlets: { sub: 'fehlzeiten' } }]);
    };
    MenuComponent.prototype.showPortfolio = function (e) {
        console.log("show Portfolio");
        this.router.navigate(['/diklabu', { outlets: { sub: 'portfolio' } }]);
    };
    MenuComponent.prototype.showGrades = function (e) {
        console.log("show Noten");
        this.router.navigate(['/diklabu', { outlets: { sub: 'noten' } }]);
    };
    MenuComponent.prototype.showTodayAnwesenheit = function (e) {
        console.log("show Today Anwesenheit");
        this.router.navigate(['/diklabu', { outlets: { sub: 'todayanwesenheit' } }]);
    };
    MenuComponent.prototype.showBetriebe = function (e) {
        console.log("show Betriebe");
        this.router.navigate(['/diklabu', { outlets: { sub: 'betriebe' } }]);
    };
    MenuComponent.prototype.logout = function (e) {
        var _this = this;
        console.log("logout");
        this.loginService.performLogout(__WEBPACK_IMPORTED_MODULE_1__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.username, __WEBPACK_IMPORTED_MODULE_1__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.password).subscribe(function (data) {
            delete __WEBPACK_IMPORTED_MODULE_1__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token;
            delete __WEBPACK_IMPORTED_MODULE_1__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.username;
            delete __WEBPACK_IMPORTED_MODULE_1__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.password;
            delete __WEBPACK_IMPORTED_MODULE_1__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.role;
            var link = ['/login'];
            _this.router.navigate(link);
        }, function (err) {
            console.log("got Error:" + err);
            _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: 'Logout Fehler!' });
        });
    };
    return MenuComponent;
}());
MenuComponent = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'menu',
        styles: ['.my {text-align: left;}' +
                '.topleft { position: absolute; left:4px;top:4px;'],
        template: '<div class="topleft"><p-tieredMenu #menu popup="popup" [model]="items" class="my"></p-tieredMenu>\n' +
            '<button type="button" pButton icon="fa fa-list" label="Menu" (click)="menu.toggle($event)"></button></div>'
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_2__services_LoginService__["a" /* LoginService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_2__services_LoginService__["a" /* LoginService */]) === "function" && _a || Object, typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_3__angular_router__["Router"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_3__angular_router__["Router"]) === "function" && _b || Object, typeof (_c = typeof __WEBPACK_IMPORTED_MODULE_4_primeng_components_common_messageservice__["MessageService"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_4_primeng_components_common_messageservice__["MessageService"]) === "function" && _c || Object, typeof (_d = typeof __WEBPACK_IMPORTED_MODULE_3__angular_router__["ActivatedRoute"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_3__angular_router__["ActivatedRoute"]) === "function" && _d || Object])
], MenuComponent);

var _a, _b, _c, _d;
//# sourceMappingURL=MenuComponent.js.map

/***/ }),

/***/ "../../../../../src/app/NewVerlaufComponent.css":
/***/ (function(module, exports, __webpack_require__) {

exports = module.exports = __webpack_require__("../../../../css-loader/lib/css-base.js")(false);
// imports


// module
exports.push([module.i, "input {\r\n  padding: 4px;\r\n}\r\n\r\n.box {\r\n  text-align: left;\r\n  width: 30%;\r\n}\r\n\r\n.rechts {\r\n  text-align: right;\r\n}\r\n", ""]);

// exports


/*** EXPORTS FROM exports-loader ***/
module.exports = module.exports.toString();

/***/ }),

/***/ "../../../../../src/app/NewVerlaufComponent.html":
/***/ (function(module, exports) {

module.exports = "<div class=\"ui-g ui-fluid ui-g-12\">\r\n  <div class=\"ui-md-9 ui-md-offset-1\">\r\n    <div class=\"ui-g ui-fluid\">\r\n      <div class=\"ui-g-12 ui-md-2\">\r\n        <datepickerComponent #dateComponent></datepickerComponent>\r\n      </div>\r\n      <div class=\"ui-md-3 box ui-md-offset-1\">\r\n        <lfselect #lfSelectComponent (lfLoaded)=\"lfLoaded()\"></lfselect>\r\n      </div>\r\n      <div class=\"ui-md-2 box\">\r\n        <strong>Stunde:</strong><br/>\r\n        <p-dropdown (onChange)=\"stundeChanged()\" [options]=\"stunden\" [(ngModel)]=\"selectedStunde\" placeholder=\"Stunde\"></p-dropdown>\r\n      </div>\r\n      <div class=\"ui-md-1 rechts\" >\r\n        <br/>\r\n        <button pButton (click)=\"addClick()\" icon=\"fa-plus\" label=\"Add\" class=\"ui-button-warning\"></button>\r\n      </div>\r\n    </div>\r\n    <div class=\"ui-inputgroup\">\r\n      <span class=\"ui-inputgroup-addon\"><i class=\"fa fa-edit\"></i></span>\r\n      <input pInputText placeholder=\"Lernsituation\" [(ngModel)]=\"lernsituation\" [disabled]=\"compDisabled\">\r\n    </div>\r\n    <br/>\r\n    <div class=\"ui-inputgroup\">\r\n      <span class=\"ui-inputgroup-addon\"><i class=\"fa fa-edit\"></i></span>\r\n      <input pInputText placeholder=\"Inhalt\" [(ngModel)]=\"inhalt\" [disabled]=\"compDisabled\">\r\n    </div>\r\n    <br/>\r\n    <div class=\"ui-inputgroup\">\r\n      <span class=\"ui-inputgroup-addon\"><i class=\"fa fa-edit\"></i></span>\r\n      <input pInputText placeholder=\"Bemerkungen\" [(ngModel)]=\"bemerkungen\" [disabled]=\"compDisabled\">\r\n    </div>\r\n    <br/>\r\n  </div>\r\n</div>\r\n\r\n"

/***/ }),

/***/ "../../../../../src/app/NewVerlaufComponent.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return NewVerlaufComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__data_Verlauf__ = __webpack_require__("../../../../../src/app/data/Verlauf.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice__ = __webpack_require__("../../../../primeng/components/common/messageservice.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4__services_VerlaufsService__ = __webpack_require__("../../../../../src/app/services/VerlaufsService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__services_SharedService__ = __webpack_require__("../../../../../src/app/services/SharedService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6__data_CourseBook__ = __webpack_require__("../../../../../src/app/data/CourseBook.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};







var NewVerlaufComponent = (function () {
    function NewVerlaufComponent(verlaufsService, messageService, service) {
        this.verlaufsService = verlaufsService;
        this.messageService = messageService;
        this.service = service;
        this.newVerlauf = new __WEBPACK_IMPORTED_MODULE_0__angular_core__["EventEmitter"]();
        this.compDisabled = true;
        this.lernsituation = "";
        this.inhalt = "";
        this.bemerkungen = "";
        this.selectedStundeIndex = 0;
        //private verlaufID;
        this.verlauf = new __WEBPACK_IMPORTED_MODULE_1__data_Verlauf__["a" /* Verlauf */]("", "", "", 0, "");
        this.stunden = [];
        this.stunden.push({ label: '1.(8:00-8:45)', value: '01' });
        this.stunden.push({ label: '2.(8:45-9:30)', value: '02' });
        this.stunden.push({ label: '3.(9:50-10:35)', value: '03' });
        this.stunden.push({ label: '4.(10:35-11:20)', value: '04' });
        this.stunden.push({ label: '5.(11:40-12:25)', value: '05' });
        this.stunden.push({ label: '6.(12:25-13:10)', value: '06' });
        this.stunden.push({ label: '7.(13:30-14:15)', value: '07' });
        this.stunden.push({ label: '8.(14:15-15:00)', value: '08' });
        this.stunden.push({ label: '9.(15:20-16:05)', value: '09' });
        this.stunden.push({ label: '10.(16:05-16:50)', value: '10' });
        this.stunden.push({ label: '11. ', value: '11' });
        this.stunden.push({ label: '12. ', value: '12' });
        this.stunden.push({ label: '13. ', value: '13' });
        this.stunden.push({ label: '14. ', value: '14' });
        this.stunden.push({ label: '15. ', value: '15' });
        this.selectedStundeIndex = 0;
        this.selectedStunde = this.stunden[this.selectedStundeIndex].value;
    }
    NewVerlaufComponent.prototype.ngOnInit = function () {
        var _this = this;
        this.subscription = this.service.getCoursebook().subscribe(function (message) {
            console.log("New Verlauf Component Received !" + message.constructor.name);
            delete _this.verlauf.ID;
        });
    };
    NewVerlaufComponent.prototype.ngOnDelete = function () {
        this.subscription.unsubscribe();
    };
    NewVerlaufComponent.prototype.stundeChanged = function () {
        for (var i = 0; i < this.stunden.length; i++) {
            if (this.selectedStunde == this.stunden[i].value) {
                this.selectedStundeIndex = i;
            }
        }
        console.log(" Set Selected Index to " + this.selectedStundeIndex);
    };
    NewVerlaufComponent.prototype.lfLoaded = function () {
        this.compDisabled = false;
    };
    NewVerlaufComponent.prototype.toString = function () {
        console.log("Verlauf: LS=" + this.lernsituation + " Inhalt=" + this.inhalt + " Bem:" + this.bemerkungen);
    };
    NewVerlaufComponent.prototype.setVerlauf = function (v) {
        this.lernsituation = v.AUFGABE;
        this.bemerkungen = v.BEMERKUNG;
        this.dateComponent.d = new Date(v.DATUM);
        this.dateComponent.d.setHours(0, 0, 0, 0);
        ;
        __WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.id = v.ID_KLASSE;
        this.lfSelectComponent.selectedLF = v.ID_LERNFELD;
        console.log("SET LF Number to " + this.lfSelectComponent.lfid);
        this.inhalt = v.INHALT;
        this.selectedStunde = v.STUNDE;
        this.selectedStundeIndex = +v.STUNDE - 1;
        this.verlauf = v;
        console.log("set Verlauf to " + JSON.stringify(this.verlauf));
    };
    NewVerlaufComponent.prototype.addClick = function () {
        var _this = this;
        console.log("Add click" + __WEBPACK_IMPORTED_MODULE_6__data_CourseBook__["a" /* CourseBook */].toSQLString(this.dateComponent.d));
        if (this.inhalt == "") {
            this.messageService.add({ severity: 'warning', summary: 'Warning', detail: 'Geben Sie wenigstens einen Inhalt an!' });
        }
        else {
            this.verlauf.INHALT = this.inhalt;
            this.verlauf.STUNDE = this.stunden[this.selectedStundeIndex].value;
            this.verlauf.ID_LEHRER = __WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.idLehrer;
            this.verlauf.ID_KLASSE = __WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.id;
            this.verlauf.DATUM = __WEBPACK_IMPORTED_MODULE_6__data_CourseBook__["a" /* CourseBook */].toSQLString(this.dateComponent.d) + "T00:00:00";
            this.verlauf.AUFGABE = this.lernsituation;
            this.verlauf.BEMERKUNG = this.bemerkungen;
            this.verlauf.ID_LERNFELD = this.lfSelectComponent.getSelectedLernfeld();
            delete this.verlauf.ID;
            console.log("Send to Server: " + JSON.stringify(this.verlauf));
            this.verlaufsService.newVerlauf(this.verlauf).subscribe(function (data) {
                console.log("VALUE RECEIVED: ", JSON.stringify(data));
                if (data.success == false) {
                    // alter Eintrag aktualisieren
                    _this.messageService.add({ severity: 'warning', summary: 'Warnung', detail: data.msg });
                }
                _this.newVerlauf.emit(data);
                _this.selectedStundeIndex++;
                if (_this.selectedStundeIndex > _this.stunden.length - 1) {
                    _this.selectedStundeIndex = _this.stunden.length - 1;
                }
                _this.verlauf = new __WEBPACK_IMPORTED_MODULE_1__data_Verlauf__["a" /* Verlauf */](_this.inhalt, _this.stunden[_this.selectedStundeIndex].value, __WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.idLehrer, __WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.id, _this.dateComponent.d);
                _this.verlauf.AUFGABE = _this.lernsituation;
                _this.verlauf.BEMERKUNG = _this.bemerkungen;
                _this.verlauf.ID_LERNFELD = _this.lfSelectComponent.getSelectedLernfeld().id;
                _this.selectedStunde = _this.stunden[_this.selectedStundeIndex].value;
            }, function (err) {
                _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: err });
            });
        }
    };
    NewVerlaufComponent.prototype.resetForm = function () {
        this.inhalt = "";
        this.lernsituation = "";
        this.bemerkungen = "";
        this.selectedStundeIndex = 0;
        this.selectedStunde = this.stunden[this.selectedStundeIndex].value;
        this.stunden[this.selectedStundeIndex].value;
        this.lfSelectComponent.selectedLF = this.lfSelectComponent.lfs[0].value;
    };
    return NewVerlaufComponent;
}());
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Output"])(),
    __metadata("design:type", Object)
], NewVerlaufComponent.prototype, "newVerlauf", void 0);
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('dateComponent'),
    __metadata("design:type", Object)
], NewVerlaufComponent.prototype, "dateComponent", void 0);
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('lfSelectComponent'),
    __metadata("design:type", Object)
], NewVerlaufComponent.prototype, "lfSelectComponent", void 0);
NewVerlaufComponent = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'newverlauf',
        template: __webpack_require__("../../../../../src/app/NewVerlaufComponent.html"),
        styles: [__webpack_require__("../../../../../src/app/NewVerlaufComponent.css")]
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_4__services_VerlaufsService__["a" /* VerlaufsService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_4__services_VerlaufsService__["a" /* VerlaufsService */]) === "function" && _a || Object, typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice__["MessageService"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice__["MessageService"]) === "function" && _b || Object, typeof (_c = typeof __WEBPACK_IMPORTED_MODULE_5__services_SharedService__["a" /* SharedService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_5__services_SharedService__["a" /* SharedService */]) === "function" && _c || Object])
], NewVerlaufComponent);

var _a, _b, _c;
//# sourceMappingURL=NewVerlaufComponent.js.map

/***/ }),

/***/ "../../../../../src/app/NotenComponent.html":
/***/ (function(module, exports) {

module.exports = "<p-dataTable [value]=\"data\" [editable]=\"true\" (onEditComplete)=\"edit($event)\">\r\n  <p-header><h3>Noten der Klasse {{KName}}</h3></p-header>\r\n  <ng-container *ngFor=\"let col of cols\">\r\n    <p-column *ngIf=\"col.header == 'info'\" frozen=\"true\" [id]=\"col.id\" [field]=\"\" [header]=\"\"\r\n              [style]=\"{'width':'75px','text-align':'left'}\">\r\n      <ng-template let-car=\"rowData\" pTemplate=\"body\" let-i=\"rowIndex\">\r\n        <img (click)=\"infoClick(data[i])\" class=\"select\" src=\"../assets/Info.png\"\r\n             [pTooltip]='\"Details \"+data[i].VNAME+\" \"+data[i].NNAME' tooltipPosition=\"right\"/>\r\n        <img (click)=\"mailClick(data[i])\" class=\"select\" src=\"../assets/mail.png\"\r\n             [pTooltip]='\"Mail an \"+data[i].VNAME+\" \"+data[i].NNAME' tooltipPosition=\"right\"/>\r\n      </ng-template>\r\n    </p-column>\r\n    <p-column *ngIf=\"col.field == 'VNAME'\" [id]=\"col.id\" frozen=\"true\" [field]=\"col.field\" [header]=\"col.header\"\r\n              [style]=\"{'width':'150px','height':'30px','text-align':'left'}\"></p-column>\r\n    <p-column *ngIf=\"col.field == 'NNAME'\" [id]=\"col.id\" frozen=\"true\" [field]=\"col.field\" [header]=\"col.header\"\r\n              [style]=\"{'width':'150px','height':'30px','text-align':'left'}\"></p-column>\r\n    <p-column *ngIf=\"col.field.startsWith('lf') && col.idlk==getIdTeacher()\" [editable]=\"true\" [id]=\"col.id\" [field]=\"col.field\" [header]=\"col.header\" [style]=\"{'width':'100px','height':'30px','text-align':'left'}\">\r\n      <ng-template let-car=\"rowData\" pTemplate=\"body\" let-i=\"rowIndex\">\r\n        <a *ngIf=\"data[i][col.field]\"><strong style=\"color: green;\">{{data[i][col.field]}}</strong></a>\r\n      </ng-template>\r\n    </p-column>\r\n    <p-column *ngIf=\"col.field.startsWith('lf') && col.idlk!=getIdTeacher()\" [id]=\"col.id\" [field]=\"col.field\" [header]=\"col.header\" [style]=\"{'width':'100px','height':'30px','text-align':'left'}\">\r\n      <ng-template let-car=\"rowData\" pTemplate=\"body\" let-i=\"rowIndex\">\r\n        <a *ngIf=\"data[i][col.field]\"><strong>{{data[i][col.field]}}</strong></a>\r\n      </ng-template>\r\n    </p-column>\r\n    <p-column *ngIf=\"col.header == 'empty'\" [field]=\"\" [header]=\"\" [style]=\"{'text-align':'left'}\">\r\n      <ng-template pTemplate=\"header\">\r\n        <lfselect #lfselectComponent (lfLoaded)=\"lfLoaded()\" ></lfselect>\r\n        <button type=\"button\" (click)=\"addLf($event)\" pButton icon=\"fa-plus\"></button>\r\n      </ng-template>\r\n      <ng-template let-car=\"rowData\" pTemplate=\"body\">\r\n      </ng-template>\r\n    </p-column>\r\n  </ng-container>\r\n</p-dataTable>\r\n<sendmail #mailDialog [mail]=\"mailObject\"></sendmail>\r\n<pupildetails #infoDialog></pupildetails>\r\n"

/***/ }),

/***/ "../../../../../src/app/NotenComponent.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return NotenComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__services_SharedService__ = __webpack_require__("../../../../../src/app/services/SharedService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice__ = __webpack_require__("../../../../primeng/components/common/messageservice.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4__CourseSelectComponent__ = __webpack_require__("../../../../../src/app/CourseSelectComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__data_MailObject__ = __webpack_require__("../../../../../src/app/data/MailObject.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6__services_DokuService__ = __webpack_require__("../../../../../src/app/services/DokuService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7__services_NotenService__ = __webpack_require__("../../../../../src/app/services/NotenService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_8__data_Grades__ = __webpack_require__("../../../../../src/app/data/Grades.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};









var NotenComponent = (function () {
    function NotenComponent(service, notenService, messageService, dokuService) {
        this.service = service;
        this.notenService = notenService;
        this.messageService = messageService;
        this.dokuService = dokuService;
        this.mailObject = new __WEBPACK_IMPORTED_MODULE_5__data_MailObject__["a" /* MailObject */]("", "", "", "");
    }
    NotenComponent.prototype.ngOnInit = function () {
        var _this = this;
        console.log("INIT Notenkomponente");
        this.subscription = this.service.getCoursebook().subscribe(function (message) {
            _this.update();
        });
        this.dokuService.setDisplayDoku(true, "Notenliste");
        this.update();
    };
    NotenComponent.prototype.ngOnDestroy = function () {
        this.subscription.unsubscribe();
    };
    NotenComponent.prototype.lfLoaded = function () {
        for (var i = 0; i < this.cols.length; i++) {
            if (this.cols[i].field.startsWith("lf")) {
                this.lfSelectComponent.removeLf(this.cols[i].field.substr(2));
            }
        }
    };
    NotenComponent.prototype.addLf = function (e) {
        console.log("Add LF:" + JSON.stringify(e));
        console.log("Selected LF=" + this.lfSelectComponent.getSelectedLernfeld());
        this.cols.splice(this.cols.length - 1, 0, { field: "lf" + this.lfSelectComponent.getSelectedLernfeld(), header: this.lfSelectComponent.getSelectedLernfeld() + " (" + __WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.idLehrer + ")", idlk: __WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.idLehrer });
        this.lfSelectComponent.removeLf(this.lfSelectComponent.getSelectedLernfeld());
    };
    NotenComponent.prototype.getIdTeacher = function () {
        return __WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.idLehrer;
    };
    NotenComponent.prototype.update = function () {
        var _this = this;
        this.KName = __WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME;
        this.cols = new Array();
        this.buildCols(__WEBPACK_IMPORTED_MODULE_4__CourseSelectComponent__["a" /* CourseSelectComponent */].pupils);
        this.notenService.getCurrentYear().subscribe(function (data) {
            var sj = data;
            __WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.idSchuljahr = sj.ID;
            _this.notenService.getGrades(__WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME, sj.ID).subscribe(function (data) {
                console.log("Folgende Noten empfange: " + JSON.stringify(data));
                _this.insertNoten(data);
            }, function (err) {
                _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: 'Fehler beim Laden der Noten f. die Klasse ' + __WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME });
            });
        }, function (err) {
            _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: 'Kann kein aktuelles Schuljahr laden!' });
        });
    };
    /**
     * Eintragen der Noten in die Tabelle
     * @param {Anwesenheit[]} a
     */
    NotenComponent.prototype.insertNoten = function (g) {
        for (var i = 0; i < g.length; i++) {
            // Finde den richtigen Schüler
            var found = false;
            var j = 0;
            for (j = 0; j < this.data.length && found == false; j++) {
                if (this.data[j].id == g[i].schuelerID) {
                    found = true;
                }
            }
            if (found) {
                console.log("Zeile gefunden, Zeile ist " + j);
            }
            else {
                console.log("ACHTUNG Zeile nicht gefunden, das ist unmöglich !!");
            }
            var grade = g[i].noten;
            console.log("Für den Schüler gibt es " + grade.length + " Einträge");
            var _loop_1 = function () {
                var eintrag = g[i].noten[k];
                //console.log("Vergleiche "+this.cols[s].DATUM+" mit "+eintrag.DATUM);
                this_1.data[j - 1]['lf' + eintrag.ID_LERNFELD] = eintrag.WERT;
                if (!this_1.cols.find(function (obj) { return obj.field == "lf" + eintrag.ID_LERNFELD; })) {
                    this_1.cols.push({ field: "lf" + eintrag.ID_LERNFELD, header: eintrag.ID_LERNFELD + " (" + eintrag.ID_LK + ")", idlk: eintrag.ID_LK });
                }
            };
            var this_1 = this;
            // Noteneinträge in diese Zeile als Attribut eintragen
            for (var k = 0; k < grade.length; k++) {
                _loop_1();
            }
        }
        this.cols.push({ field: "empty", header: "empty" });
        console.log("Data is:" + JSON.stringify(this.data));
        console.log("cols is:" + JSON.stringify(this.cols));
    };
    /**
     * Erzeigt die Spalten der Tabelle und trägt anschließend die Daten ein
     * @param {any[]} p Array mit Schülern
     */
    NotenComponent.prototype.buildCols = function (p) {
        this.data = new Array();
        this.cols.push({ field: "info", header: "info" });
        this.cols.push({ field: "VNAME", header: "Vorname" });
        this.cols.push({ field: "NNAME", header: "Nachname" });
        this.data = p;
    };
    NotenComponent.prototype.mailClick = function (p) {
        console.log("0Mail click! on " + JSON.stringify(p));
        this.mailObject = new __WEBPACK_IMPORTED_MODULE_5__data_MailObject__["a" /* MailObject */](__WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.email, p.EMAIL, "", "");
        this.mailDialog.showDialog("Nachricht an " + p.VNAME + " " + p.NNAME);
    };
    NotenComponent.prototype.infoClick = function (p) {
        console.log("Info click! on " + JSON.stringify(p));
        this.infoDialog.showDialog(p);
    };
    NotenComponent.prototype.edit = function (event) {
        var _this = this;
        console.log("edit Complete: row=" + event.index + " Column=" + event.column.field + " Inhalt:" + JSON.stringify(event.data));
        var g = new __WEBPACK_IMPORTED_MODULE_8__data_Grades__["a" /* Grade */]();
        g.ID_LK = __WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.idLehrer;
        g.ID_LERNFELD = event.column.field.substring(2);
        g.ID_SCHUELER = event.data.id;
        g.WERT = event.data[event.column.field];
        console.log("Sende Note zum Server: " + JSON.stringify(g));
        if (g.WERT == "") {
            console.log("Note löschen");
            this.notenService.deleteGrade(g).subscribe(function (data) {
                if (!data.success) {
                    _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: data.msg });
                }
                for (var i = 0; i < _this.data.length; i++) {
                    if (_this.data[i].id == data.ID_SCHUELER) {
                        console.log(" Note lokal löschen!");
                        delete _this.data[i]['lf' + data.ID_LERNFELD];
                        break;
                    }
                }
            }, function (err) {
                _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: err });
            });
        }
        else {
            console.log("Note eintragen/ändern");
            this.notenService.setGrade(g, __WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.id).subscribe(function (data) {
                if (!data.success) {
                    _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: data.msg });
                    for (var i = 0; i < _this.data.length; i++) {
                        if (_this.data[i].id == data.ID_SCHUELER) {
                            console.log(" Note lokal löschen!");
                            delete _this.data[i]['lf' + data.ID_LERNFELD];
                            break;
                        }
                    }
                }
                else {
                    for (var i = 0; i < _this.data.length; i++) {
                        if (_this.data[i].id == data.ID_SCHUELER) {
                            console.log(" Note lokal eingetragen!");
                            _this.data[i]['lf' + data.ID_LERNFELD] = data.WERT;
                            break;
                        }
                    }
                }
            }, function (err) {
                _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: err });
            });
        }
    };
    return NotenComponent;
}());
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('mailDialog'),
    __metadata("design:type", Object)
], NotenComponent.prototype, "mailDialog", void 0);
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('infoDialog'),
    __metadata("design:type", Object)
], NotenComponent.prototype, "infoDialog", void 0);
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('lfselectComponent'),
    __metadata("design:type", Object)
], NotenComponent.prototype, "lfSelectComponent", void 0);
NotenComponent = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'noten',
        template: __webpack_require__("../../../../../src/app/NotenComponent.html"),
        styles: [],
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_1__services_SharedService__["a" /* SharedService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_1__services_SharedService__["a" /* SharedService */]) === "function" && _a || Object, typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_7__services_NotenService__["a" /* NotenService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_7__services_NotenService__["a" /* NotenService */]) === "function" && _b || Object, typeof (_c = typeof __WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice__["MessageService"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice__["MessageService"]) === "function" && _c || Object, typeof (_d = typeof __WEBPACK_IMPORTED_MODULE_6__services_DokuService__["a" /* DokuService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_6__services_DokuService__["a" /* DokuService */]) === "function" && _d || Object])
], NotenComponent);

var _a, _b, _c, _d;
//# sourceMappingURL=NotenComponent.js.map

/***/ }),

/***/ "../../../../../src/app/PlanDialog.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return PlanDialog; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};

var PlanDialog = (function () {
    function PlanDialog() {
        this.display = false;
        this.titel = "";
        this.content = "";
    }
    PlanDialog.prototype.showDialog = function (titel, content) {
        this.titel = titel;
        this.content = content;
        this.display = true;
    };
    return PlanDialog;
}());
PlanDialog = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'plan',
        styles: [],
        template: ' <p-dialog [header]="titel" [(visible)]="display" modal="modal" [closable]="true" appendTo="body"><br/>' +
            '<p [innerHtml]="content"></p>' +
            '</p-dialog>'
    })
], PlanDialog);

//# sourceMappingURL=PlanDialog.js.map

/***/ }),

/***/ "../../../../../src/app/PortfolioComponent.html":
/***/ (function(module, exports) {

module.exports = "<p-dataList [value]=\"coursePortfolio\">\r\n  <p-header>\r\n    <h3>Portfolios der Klasse {{KName}} </h3>\r\n    <div class=\"ui-g ui-fluid\">\r\n      <div class=\"ui-g-12 ui-md-2 links\">\r\n        <strong>Name</strong>\r\n      </div>\r\n      <div class=\"ui-md-1 links\">\r\n        <strong>Portfolio</strong>\r\n      </div>\r\n      <div class=\"ui-md-3 links\">\r\n        <strong>Einträge</strong>\r\n      </div>\r\n    </div>\r\n  </p-header>\r\n  <ng-template let-portfolio pTemplate=\"item\" let-i=\"index\">\r\n    <div class=\"ui-g ui-fluid\">\r\n      <div class=\"ui-g-12 ui-md-2 links\">\r\n        <img (click)=\"infoClick(portfolio.ID_Schueler)\" class=\"select\" src=\"../assets/Info.png\"/>\r\n        <img (click)=\"mailClick(portfolio.ID_Schueler)\" class=\"select\" src=\"../assets/mail.png\"/>\r\n        <strong style=\"vertical-align: top;\">{{getPupil(portfolio.ID_Schueler).VNAME}} {{getPupil(portfolio.ID_Schueler).NNAME}}</strong>\r\n      </div>\r\n      <div class=\"ui-md-1 links\">\r\n        <img (click)=\"downloadPortfolio(getPupil(portfolio.ID_Schueler))\" class=\"select\" src=\"../assets/pdficon.png\"/>\r\n      </div>\r\n      <div class=\"ui-md-3 links\">\r\n        {{getPortfolioList(portfolio)}}\r\n      </div>\r\n    </div>\r\n  </ng-template>\r\n</p-dataList>\r\n<sendmail #mailDialog [mail]=\"mailObject\"></sendmail>\r\n<pupildetails #infoDialog></pupildetails>\r\n\r\n\r\n"

/***/ }),

/***/ "../../../../../src/app/PortfolioComponent.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return PortfolioComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__CourseSelectComponent__ = __webpack_require__("../../../../../src/app/CourseSelectComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__services_SharedService__ = __webpack_require__("../../../../../src/app/services/SharedService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__services_PupilService__ = __webpack_require__("../../../../../src/app/services/PupilService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_primeng_components_common_messageservice__ = __webpack_require__("../../../../primeng/components/common/messageservice.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_primeng_components_common_messageservice___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_4_primeng_components_common_messageservice__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6__services_CourseService__ = __webpack_require__("../../../../../src/app/services/CourseService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7__services_DokuService__ = __webpack_require__("../../../../../src/app/services/DokuService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_8__data_MailObject__ = __webpack_require__("../../../../../src/app/data/MailObject.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_9_file_saver__ = __webpack_require__("../../../../file-saver/FileSaver.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_9_file_saver___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_9_file_saver__);
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};










var PortfolioComponent = (function () {
    function PortfolioComponent(pupilService, dokuService, service, messageService, courseService) {
        var _this = this;
        this.pupilService = pupilService;
        this.dokuService = dokuService;
        this.service = service;
        this.messageService = messageService;
        this.courseService = courseService;
        this.mailObject = new __WEBPACK_IMPORTED_MODULE_8__data_MailObject__["a" /* MailObject */]("", "", "", "");
        this.subscription = this.service.getCoursebook().subscribe(function (message) {
            console.log("LehrerzugehoerigkeitComponent Component Model Changed !" + message.constructor.name);
            _this.update();
        });
    }
    PortfolioComponent.prototype.downloadPortfolio = function (p) {
        console.log("Cretae Portfolio for " + p.id);
        this.pupilService.downloadPortfolio(p.id).subscribe(function (blob) {
            console.log("Download Portfolio reveived BLOB");
            __WEBPACK_IMPORTED_MODULE_9_file_saver__["saveAs"](blob, "Portfolio_" + p.VNAME + "_" + p.NNAME + ".pdf");
        });
    };
    PortfolioComponent.prototype.update = function () {
        var _this = this;
        this.KName = __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME;
        this.coursePortfolio = new Array();
        this.courseService.getPortfolio(__WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.id).subscribe(function (data) {
            console.log(" Receive Portolio: " + JSON.stringify(data));
            _this.coursePortfolio = data;
        }, function (err) {
            _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: 'Kann Portfolio der Klasse ' + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME + ' nicht laden: ' + err });
        });
    };
    PortfolioComponent.prototype.getPortfolioList = function (p) {
        console.log("getPortfolioList von " + JSON.stringify(p));
        var e = p.eintraege;
        var out = "";
        for (var i = 0; i < e.length; i++) {
            out = out + e[i].KName + " (" + e[i].wert + ")  ";
        }
        return out;
    };
    PortfolioComponent.prototype.ngOnInit = function () {
        this.dokuService.setDisplayDoku(true, "Portfolio");
        this.update();
    };
    PortfolioComponent.prototype.ngOnDestroy = function () {
        this.subscription.unsubscribe();
    };
    PortfolioComponent.prototype.getPupil = function (pid) {
        console.log("Suche Schüler mit der ID=" + pid);
        return __WEBPACK_IMPORTED_MODULE_1__CourseSelectComponent__["a" /* CourseSelectComponent */].getPupil(pid);
    };
    PortfolioComponent.prototype.infoClick = function (pid) {
        console.log("info click: ID=" + pid);
        var p = __WEBPACK_IMPORTED_MODULE_1__CourseSelectComponent__["a" /* CourseSelectComponent */].getPupil(pid);
        this.infoDialog.showDialog(p);
    };
    PortfolioComponent.prototype.mailClick = function (pid) {
        console.log("mail click: ID=" + pid);
        var p = __WEBPACK_IMPORTED_MODULE_1__CourseSelectComponent__["a" /* CourseSelectComponent */].getPupil(pid);
        this.mailObject = new __WEBPACK_IMPORTED_MODULE_8__data_MailObject__["a" /* MailObject */](__WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.email, p.EMAIL, "", "");
        this.mailDialog.showDialog("Nachricht an " + p.VNAME + " " + p.NNAME);
    };
    return PortfolioComponent;
}());
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('mailDialog'),
    __metadata("design:type", Object)
], PortfolioComponent.prototype, "mailDialog", void 0);
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('infoDialog'),
    __metadata("design:type", Object)
], PortfolioComponent.prototype, "infoDialog", void 0);
PortfolioComponent = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'portfolio',
        template: __webpack_require__("../../../../../src/app/PortfolioComponent.html"),
        styles: ['.links {text-align: left;}.select {cursor: pointer;}']
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_3__services_PupilService__["a" /* PupilService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_3__services_PupilService__["a" /* PupilService */]) === "function" && _a || Object, typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_7__services_DokuService__["a" /* DokuService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_7__services_DokuService__["a" /* DokuService */]) === "function" && _b || Object, typeof (_c = typeof __WEBPACK_IMPORTED_MODULE_2__services_SharedService__["a" /* SharedService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_2__services_SharedService__["a" /* SharedService */]) === "function" && _c || Object, typeof (_d = typeof __WEBPACK_IMPORTED_MODULE_4_primeng_components_common_messageservice__["MessageService"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_4_primeng_components_common_messageservice__["MessageService"]) === "function" && _d || Object, typeof (_e = typeof __WEBPACK_IMPORTED_MODULE_6__services_CourseService__["a" /* CourseService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_6__services_CourseService__["a" /* CourseService */]) === "function" && _e || Object])
], PortfolioComponent);

var _a, _b, _c, _d, _e;
//# sourceMappingURL=PortfolioComponent.js.map

/***/ }),

/***/ "../../../../../src/app/PupilDetailDialog.html":
/***/ (function(module, exports) {

module.exports = " <p-dialog [header]=\"titel\" [(visible)]=\"display\" modal=\"modal\" [closable]=\"true\" [width]=\"600\" appendTo=\"body\">\r\n   <div class=\"ui-g ui-fluid ui-g-12\">\r\n     <div class=\"ui-md-5\">\r\n      <pupilimage #pimage ></pupilimage>\r\n       <strong>Bemerkungen</strong>\r\n       <textarea pInputTextarea [(ngModel)]=\"pupilDetails.info\"></textarea>\r\n       <button pButton type=\"button\" (click)=\"updateBem()\" icon=\"fa-check\" label=\"Aktualisieren\" class=\"ui-button-success\"></button>\r\n     </div>\r\n     <div class=\"ui-md-7\">\r\n       <strong>Geburtsdatum {{pupilDetails.gebDatum}}</strong>\r\n       <h3>Ausbilder</h3>\r\n       <p> {{pupilDetails.ausbilder.NNAME}} <a href='mailto:{{pupilDetails.ausbilder.EMAIL}}'>{{pupilDetails.ausbilder.EMAIL}}</a></p>\r\n       <p>Tel: {{pupilDetails.ausbilder.TELEFON}}</p>\r\n       <p>Fax: {{pupilDetails.ausbilder.FAX}}</p>\r\n       <h3>Betrieb</h3>\r\n       <p> {{pupilDetails.betrieb.NAME}}</p>\r\n       <p> {{pupilDetails.betrieb.STRASSE}}</p>\r\n       <p> {{pupilDetails.betrieb.PLZ}} {{pupilDetails.betrieb.NAME}}</p>\r\n       <h3>Klassen/Kurse</h3>\r\n       <ul>\r\n         <li *ngFor=\"let c of pupilDetails.klassen; let j = index\" [value]=\"j\">\r\n           {{c.KNAME}}\r\n         </li>\r\n       </ul>\r\n\r\n     </div>\r\n   </div>\r\n </p-dialog>\r\n"

/***/ }),

/***/ "../../../../../src/app/PupilDetailDialog.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return PupilDetailDialog; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__ = __webpack_require__("../../../../primeng/components/common/messageservice.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__data_PupilDetails__ = __webpack_require__("../../../../../src/app/data/PupilDetails.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__services_PupilDetailService__ = __webpack_require__("../../../../../src/app/services/PupilDetailService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4__PupilImageComponent__ = __webpack_require__("../../../../../src/app/PupilImageComponent.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};





var PupilDetailDialog = (function () {
    function PupilDetailDialog(pupilDetailService, messageService) {
        this.pupilDetailService = pupilDetailService;
        this.messageService = messageService;
        this.display = false;
        this.titel = "";
        this.pupilDetails = new __WEBPACK_IMPORTED_MODULE_2__data_PupilDetails__["c" /* PupilDetails */]();
    }
    PupilDetailDialog.prototype.showDialog = function (p) {
        var _this = this;
        this.pimage.getImage(p);
        this.titel = p.VNAME + " " + p.NNAME;
        this.display = true;
        this.pupilDetailService.getPupilDetails(p.id).subscribe(function (data) {
            _this.pupilDetails = data;
            if (!_this.pupilDetails.ausbilder) {
                _this.pupilDetails.ausbilder = new __WEBPACK_IMPORTED_MODULE_2__data_PupilDetails__["a" /* Ausbilder */]();
            }
            if (!_this.pupilDetails.betrieb) {
                _this.pupilDetails.betrieb = new __WEBPACK_IMPORTED_MODULE_2__data_PupilDetails__["b" /* Betrieb */]();
            }
        }, function (err) {
            console.log("Error Details: +err");
            _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: err });
        });
    };
    PupilDetailDialog.prototype.updateBem = function () {
        this.display = false;
        this.pupilDetailService.setInfo(this.pupilDetails.id, this.pupilDetails.info).subscribe(function (data) {
            console.log("Recieved:" + JSON.stringify(data));
        }, function (err) {
            console.log("ERR Recieved:" + JSON.stringify(err));
        });
    };
    return PupilDetailDialog;
}());
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('pimage'),
    __metadata("design:type", typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_4__PupilImageComponent__["a" /* PupilImageComponent */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_4__PupilImageComponent__["a" /* PupilImageComponent */]) === "function" && _a || Object)
], PupilDetailDialog.prototype, "pimage", void 0);
PupilDetailDialog = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'pupildetails',
        styles: ['input {' +
                'width:100%;' +
                '}' +
                'textarea{width:100%;}'
        ],
        template: __webpack_require__("../../../../../src/app/PupilDetailDialog.html"),
    }),
    __metadata("design:paramtypes", [typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_3__services_PupilDetailService__["a" /* PupilDetailService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_3__services_PupilDetailService__["a" /* PupilDetailService */]) === "function" && _b || Object, typeof (_c = typeof __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__["MessageService"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__["MessageService"]) === "function" && _c || Object])
], PupilDetailDialog);

var _a, _b, _c;
//# sourceMappingURL=PupilDetailDialog.js.map

/***/ }),

/***/ "../../../../../src/app/PupilDetailEditDialog.html":
/***/ (function(module, exports) {

module.exports = "<p-dialog [header]=\"titel\" [(visible)]=\"display\" modal=\"modal\" [closable]=\"true\" [width]=\"600\" appendTo=\"body\">\r\n  <div class=\"ui-g ui-fluid ui-g-12\">\r\n    <div *ngIf=\"this.pupilDetails.id\" class=\"ui-md-5\">\r\n      <pupilimage   #pimage></pupilimage>\r\n      <strong>Bemerkungen</strong>\r\n      <textarea pInputTextarea [(ngModel)]=\"pupilDetails.info\"></textarea>\r\n      <button pButton type=\"button\" (click)=\"updateBem()\" icon=\"fa-check\" label=\"Bem. aktualisieren\"\r\n              class=\"ui-button-success\"></button>\r\n    </div>\r\n    <div class=\"ui-md-7\">\r\n      <h3>Schülerdaten</h3>\r\n       <p style=\"padding-top: 10px\">\r\n      <span class=\"ui-float-label\">\r\n       <input id=\"vname\" type=\"text\" [(ngModel)]=\"pupilDetails.vorname\" pInputText/>\r\n       <label for=\"vname\">Vorname</label>\r\n       </span>\r\n         </p>\r\n      <p style=\"padding-top: 10px\">\r\n      <span class=\"ui-float-label\">\r\n       <input id=\"nname\" type=\"text\" [(ngModel)]=\"pupilDetails.name\" pInputText/>\r\n       <label for=\"nname\">Name</label>\r\n       </span>\r\n      </p>\r\n      <p style=\"padding-top: 10px\">\r\n      <span class=\"ui-float-label\">\r\n       <input id=\"email\" type=\"text\" [(ngModel)]=\"pupilDetails.email\" pInputText/>\r\n       <label for=\"email\">Email</label>\r\n       </span>\r\n      </p>\r\n      <strong>Geb. Datum</strong>\r\n      <p-calendar  [(ngModel)]=\"gebDat\" [showIcon]=\"true\" [locale]=\"de\" dateFormat=\"dd.mm.yy\"></p-calendar>\r\n      <br/>\r\n      <br/>\r\n      <strong>Abgang</strong>\r\n      <br/>\r\n      <p-inputSwitch id=\"abgang\" onLabel=\"Ja\" offLabel=\"Nein\" [(ngModel)]=\"abgang\"></p-inputSwitch>\r\n      <h3>Ausbilder</h3>\r\n      <p> {{pupilDetails.ausbilder.NNAME}} <a href='mailto:{{pupilDetails.ausbilder.EMAIL}}'>{{pupilDetails.ausbilder.EMAIL}}</a>\r\n      ,Tel: {{pupilDetails.ausbilder.TELEFON}}\r\n      ,Fax: {{pupilDetails.ausbilder.FAX}}\r\n      <h3>Betrieb</h3>\r\n      {{pupilDetails.betrieb.NAME}}, {{pupilDetails.betrieb.STRASSE}},{{pupilDetails.betrieb.PLZ}} {{pupilDetails.betrieb.NAME}}\r\n      <h3>Klassen/Kurse</h3>\r\n      <ul>\r\n        <li *ngFor=\"let c of pupilDetails.klassen; let j = index\" [value]=\"j\">\r\n          {{c.KNAME}}\r\n        </li>\r\n      </ul>\r\n\r\n    </div>\r\n  </div>\r\n  <p-footer>\r\n    <button type=\"button\" pButton icon=\"fa-check\" (click)=\"setPupil()\" label=\"Aktualisieren\"></button>\r\n  </p-footer>\r\n</p-dialog>\r\n"

/***/ }),

/***/ "../../../../../src/app/PupilDetailEditDialog.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return PupilDetailEditDialog; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__ = __webpack_require__("../../../../primeng/components/common/messageservice.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__data_PupilDetails__ = __webpack_require__("../../../../../src/app/data/PupilDetails.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__services_PupilDetailService__ = __webpack_require__("../../../../../src/app/services/PupilDetailService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4__data_Pupil__ = __webpack_require__("../../../../../src/app/data/Pupil.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__PupilImageComponent__ = __webpack_require__("../../../../../src/app/PupilImageComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6__services_PupilService__ = __webpack_require__("../../../../../src/app/services/PupilService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7__services_DokuService__ = __webpack_require__("../../../../../src/app/services/DokuService.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};








var PupilDetailEditDialog = (function () {
    function PupilDetailEditDialog(dokuService, pupilDetailService, messageService, pupilService) {
        this.dokuService = dokuService;
        this.pupilDetailService = pupilDetailService;
        this.messageService = messageService;
        this.pupilService = pupilService;
        this.editCompleted = new __WEBPACK_IMPORTED_MODULE_0__angular_core__["EventEmitter"]();
        this.newCompleted = new __WEBPACK_IMPORTED_MODULE_0__angular_core__["EventEmitter"]();
        this.display = false;
        this.titel = "Neuen Schüler anlegen";
        this.pupilDetails = new __WEBPACK_IMPORTED_MODULE_2__data_PupilDetails__["c" /* PupilDetails */]();
        this.abgang = false;
    }
    PupilDetailEditDialog.prototype.ngOnInit = function () {
        this.dokuService.setDisplayDoku(false);
        this.de = {
            firstDayOfWeek: 1,
            dayNames: ["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnestag", "Freitag", "Samstag"],
            dayNamesShort: ["So.", "Mo.", "Di.", "Mi.", "Do.", "Fr.", "Sa."],
            dayNamesMin: ["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"],
            monthNames: ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"],
            monthNamesShort: ["Jan", "Feb", "Mar", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"],
            today: 'Heute',
            clear: 'löschen'
        };
    };
    PupilDetailEditDialog.prototype.showDialog = function (p) {
        var _this = this;
        this.display = true;
        if (p.id) {
            this.pupilDetails.id = p.id;
            this.titel = p.VNAME + " " + p.NNAME;
            this.pupilDetailService.getPupilDetails(p.id).subscribe(function (data) {
                _this.pupilDetails = data;
                if (_this.pupilDetails.gebDatum) {
                    _this.gebDat = new Date(_this.pupilDetails.gebDatum);
                    _this.gebDat.setMinutes(0);
                    _this.gebDat.setHours(0);
                    _this.gebDat.setSeconds(0);
                    if (!_this.pupilDetails.ausbilder) {
                        _this.pupilDetails.ausbilder = new __WEBPACK_IMPORTED_MODULE_2__data_PupilDetails__["a" /* Ausbilder */]();
                    }
                    if (!_this.pupilDetails.betrieb) {
                        _this.pupilDetails.betrieb = new __WEBPACK_IMPORTED_MODULE_2__data_PupilDetails__["b" /* Betrieb */]();
                    }
                }
                else {
                    _this.gebDat = null;
                }
                if (_this.pupilDetails.abgang == "J") {
                    _this.abgang = true;
                }
                else {
                    _this.abgang = false;
                }
                _this.pimage.getImage(p);
            }, function (err) {
                console.log("Error Details: +err");
                _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: err });
            });
        }
        else {
            this.pupilDetails = new __WEBPACK_IMPORTED_MODULE_2__data_PupilDetails__["c" /* PupilDetails */]();
            this.titel = "Neuen Schüler anlegen..";
            this.gebDat = null;
            this.pupilDetails.id = null;
        }
    };
    PupilDetailEditDialog.prototype.updateBem = function () {
        this.pupilDetailService.setInfo(this.pupilDetails.id, this.pupilDetails.info).subscribe(function (data) {
            console.log("Recieved:" + JSON.stringify(data));
        }, function (err) {
            console.log("ERR Recieved:" + JSON.stringify(err));
        });
    };
    PupilDetailEditDialog.prototype.setPupil = function () {
        var _this = this;
        var pupil = new __WEBPACK_IMPORTED_MODULE_4__data_Pupil__["a" /* Pupil */]();
        pupil.id = this.pupilDetails.id;
        if (this.pupilDetails.vorname) {
            pupil.VNAME = this.pupilDetails.vorname;
        }
        else {
            this.messageService.add({ severity: 'warning', summary: 'Warnung', detail: "Der Schüler muss einen Vornamen haben!" });
            return;
        }
        if (this.pupilDetails.name) {
            pupil.NNAME = this.pupilDetails.name;
        }
        else {
            this.messageService.add({ severity: 'warning', summary: 'Warnung', detail: "Der Schüler muss einen Nachnamen haben!" });
            return;
        }
        if (this.pupilDetails.email) {
            pupil.EMAIL = this.pupilDetails.email;
        }
        if (this.abgang) {
            pupil.ABGANG = "J";
        }
        else {
            pupil.ABGANG = "N";
        }
        if (this.gebDat) {
            pupil.GEBDAT = this.gebDat;
            console.log("Eingestellt ist " + this.gebDat);
        }
        else {
            this.messageService.add({ severity: 'warning', summary: 'Warnung', detail: "Der Schüler muss ein Geburtsdatum haben!" });
            return;
        }
        this.display = false;
        if (pupil.id) {
            this.pupilService.setPupil(pupil).subscribe(function (data) {
                console.log("Received: " + JSON.stringify(data));
                _this.editCompleted.emit(pupil);
            }, function (err) {
                _this.messageService.add({
                    severity: 'error',
                    summary: 'Fehler beim Ändern der Daten von ' + pupil.VNAME + ' ' + pupil.NNAME + ':' + err
                });
            });
        }
        else {
            this.pupilService.newPupil(pupil).subscribe(function (data) {
                console.log("New Pupil Received: " + JSON.stringify(data));
                _this.newCompleted.emit(data);
                _this.messageService.add({ severity: 'info', summary: 'Information', detail: "Neuen Schüler " + pupil.VNAME + " " + pupil.NNAME + " angelegt!" });
            }, function (err) {
                _this.messageService.add({
                    severity: 'error',
                    summary: 'Fehler beim hinzufügen von ' + pupil.VNAME + ' ' + pupil.NNAME + ':' + err
                });
            });
        }
    };
    return PupilDetailEditDialog;
}());
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('pimage'),
    __metadata("design:type", typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_5__PupilImageComponent__["a" /* PupilImageComponent */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_5__PupilImageComponent__["a" /* PupilImageComponent */]) === "function" && _a || Object)
], PupilDetailEditDialog.prototype, "pimage", void 0);
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Output"])(),
    __metadata("design:type", Object)
], PupilDetailEditDialog.prototype, "editCompleted", void 0);
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Output"])(),
    __metadata("design:type", Object)
], PupilDetailEditDialog.prototype, "newCompleted", void 0);
PupilDetailEditDialog = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'pupileditdetails',
        styles: ['input {' +
                'width:100%;' +
                '}' +
                'textarea{width:100%;}'
        ],
        template: __webpack_require__("../../../../../src/app/PupilDetailEditDialog.html"),
    }),
    __metadata("design:paramtypes", [typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_7__services_DokuService__["a" /* DokuService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_7__services_DokuService__["a" /* DokuService */]) === "function" && _b || Object, typeof (_c = typeof __WEBPACK_IMPORTED_MODULE_3__services_PupilDetailService__["a" /* PupilDetailService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_3__services_PupilDetailService__["a" /* PupilDetailService */]) === "function" && _c || Object, typeof (_d = typeof __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__["MessageService"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__["MessageService"]) === "function" && _d || Object, typeof (_e = typeof __WEBPACK_IMPORTED_MODULE_6__services_PupilService__["a" /* PupilService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_6__services_PupilService__["a" /* PupilService */]) === "function" && _e || Object])
], PupilDetailEditDialog);

var _a, _b, _c, _d, _e;
//# sourceMappingURL=PupilDetailEditDialog.js.map

/***/ }),

/***/ "../../../../../src/app/PupilImageComponent.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return PupilImageComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__ = __webpack_require__("../../../../primeng/components/common/messageservice.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__services_PupilDetailService__ = __webpack_require__("../../../../../src/app/services/PupilDetailService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4__data_Config__ = __webpack_require__("../../../../../src/app/data/Config.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};





var PupilImageComponent = (function () {
    function PupilImageComponent(pupilDetailService, messageService) {
        this.pupilDetailService = pupilDetailService;
        this.messageService = messageService;
        this.imgSrc = "../assets/anonym.gif";
        this.uploadUrl = __WEBPACK_IMPORTED_MODULE_4__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/schueler/bild/";
    }
    PupilImageComponent.prototype.getImage = function (p) {
        var _this = this;
        this.currentPupil = p;
        this.imgSrc = "../assets/anonym.gif";
        if (p.id) {
            this.uploadUrl = __WEBPACK_IMPORTED_MODULE_4__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/schueler/bild/" + p.id;
            this.pupilDetailService.getPupilImage(p.id).subscribe(function (data) {
                if (data) {
                    console.log("Bild vorhanden");
                    var base64 = data.base64;
                    var patt = /(?:\r\n|\r|\n)/g;
                    base64 = base64.replace(patt, "");
                    _this.imgSrc = "data:image/png;base64," + base64;
                }
            }, function (err) {
                console.log("Error Image: +err");
                _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: err });
            });
        }
    };
    PupilImageComponent.prototype.onBeforeSend = function (event) {
        console.log("On BeforeSend!");
        event.xhr.setRequestHeader("auth_token", "" + __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
    };
    PupilImageComponent.prototype.onBasicUpload = function (e) {
        console.log("onBaiscUpload:" + JSON.stringify(e));
        this.getImage(this.currentPupil);
    };
    return PupilImageComponent;
}());
PupilImageComponent = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'pupilimage',
        styles: ['#adapt {' +
                'text-align: center;' +
                'padding: 5px;' +
                '}'],
        template: ' <img width="200" alt="Pupil Image" [src]="imgSrc">' +
            '<div id="adapt">' +
            '<p-fileUpload  name="file"  mode="basic" accept="image/*" (onBeforeSend)="onBeforeSend($event)" (onUpload)="onBasicUpload($event)" [url]="uploadUrl"></p-fileUpload>' +
            '</div>',
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_2__services_PupilDetailService__["a" /* PupilDetailService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_2__services_PupilDetailService__["a" /* PupilDetailService */]) === "function" && _a || Object, typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__["MessageService"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_1_primeng_components_common_messageservice__["MessageService"]) === "function" && _b || Object])
], PupilImageComponent);

var _a, _b;
//# sourceMappingURL=PupilImageComponent.js.map

/***/ }),

/***/ "../../../../../src/app/PupilLoginComponent.html":
/***/ (function(module, exports) {

module.exports = "<div class=\"jumbotron>\">\r\n<h1>{{pupilDetails.vorname}} {{pupilDetails.name}}</h1>\r\n  <button pButton type=\"button\" (click)=\"logout()\" icon=\"fa-check\"  label=\"Logout\"  class=\"ui-button-danger\"></button>\r\n</div>\r\n<div class=\"ui-g ui-g-12\">\r\n  <div class=\"ui-md-4\">\r\n    <img width=\"200\" alt=\"Pupil Image\" [src]=\"imgSrc\" />\r\n  </div>\r\n  <div class=\"ui-md-7 left\">\r\n    <strong>Geburtsdatum:</strong> {{pupilDetails.gebDatum}}<br/><br/>\r\n    <strong>Email:</strong>{{pupilDetails.email}}<br/>\r\n    <hr/>\r\n    <h3>Ausbilder</h3>\r\n    <p> {{pupilDetails.ausbilder.NNAME}} <a href='mailto:{{pupilDetails.ausbilder.EMAIL}}'>{{pupilDetails.ausbilder.EMAIL}}</a></p>\r\n    <p>Tel: {{pupilDetails.ausbilder.TELEFON}}</p>\r\n    <p>Fax: {{pupilDetails.ausbilder.FAX}}</p>\r\n    <hr/>\r\n    <h3>Betrieb</h3>\r\n    <p> {{pupilDetails.betrieb.NAME}}</p>\r\n    <p> {{pupilDetails.betrieb.STRASSE}}</p>\r\n    <p> {{pupilDetails.betrieb.PLZ}} {{pupilDetails.betrieb.NAME}}</p>\r\n    <hr/>\r\n    <h3>Klassen/Kurse</h3>\r\n    <ul>\r\n      <li *ngFor=\"let c of pupilDetails.klassen; let j = index\" [value]=\"j\">\r\n        {{c.KNAME}}\r\n      </li>\r\n    </ul>\r\n  </div>\r\n</div>\r\n"

/***/ }),

/***/ "../../../../../src/app/PupilLoginComponent.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return PupilLoginComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__services_PupilDetailService__ = __webpack_require__("../../../../../src/app/services/PupilDetailService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice__ = __webpack_require__("../../../../primeng/components/common/messageservice.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__data_PupilDetails__ = __webpack_require__("../../../../../src/app/data/PupilDetails.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__services_LoginService__ = __webpack_require__("../../../../../src/app/services/LoginService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6__angular_router__ = __webpack_require__("../../../router/@angular/router.es5.js");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};







var PupilLoginComponent = (function () {
    function PupilLoginComponent(router, loginService, pupilDetailService, messageService) {
        this.router = router;
        this.loginService = loginService;
        this.pupilDetailService = pupilDetailService;
        this.messageService = messageService;
        this.pupilDetails = new __WEBPACK_IMPORTED_MODULE_3__data_PupilDetails__["c" /* PupilDetails */]();
        this.imgSrc = "../assets/anonym.gif";
    }
    PupilLoginComponent.prototype.ngOnInit = function () {
        var _this = this;
        this.pupilDetailService.getSPupilDetails(+__WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.ID).subscribe(function (data) {
            _this.pupilDetails = data;
            console.log("Eempfange: " + JSON.stringify(data));
        }, function (err) {
            console.log("Error Details: +err");
            _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: err });
        });
        this.imgSrc = "../assets/anonym.gif";
        this.pupilDetailService.getSPupilImage(+__WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.ID).subscribe(function (data) {
            if (data) {
                console.log("Bild vorhanden");
                var base64 = data.base64;
                var patt = /(?:\r\n|\r|\n)/g;
                base64 = base64.replace(patt, "");
                _this.imgSrc = "data:image/png;base64," + base64;
            }
        }, function (err) {
            console.log("Error Image: +err");
            _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: err });
        });
    };
    PupilLoginComponent.prototype.logout = function () {
        var _this = this;
        this.loginService.performLogout(__WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.username, __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.password).subscribe(function (data) {
            delete __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token;
            delete __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.username;
            delete __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.password;
            delete __WEBPACK_IMPORTED_MODULE_4__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.role;
            var link = ['/login'];
            _this.router.navigate(link);
        }, function (err) {
            console.log("got Error:" + err);
            _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: 'Logout Fehler!' });
        });
    };
    return PupilLoginComponent;
}());
PupilLoginComponent = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'pupilLogin',
        template: __webpack_require__("../../../../../src/app/PupilLoginComponent.html"),
        styles: ['.left {text-align: left;} .neben {float: left;}']
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_6__angular_router__["Router"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_6__angular_router__["Router"]) === "function" && _a || Object, typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_5__services_LoginService__["a" /* LoginService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_5__services_LoginService__["a" /* LoginService */]) === "function" && _b || Object, typeof (_c = typeof __WEBPACK_IMPORTED_MODULE_1__services_PupilDetailService__["a" /* PupilDetailService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_1__services_PupilDetailService__["a" /* PupilDetailService */]) === "function" && _c || Object, typeof (_d = typeof __WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice__["MessageService"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice__["MessageService"]) === "function" && _d || Object])
], PupilLoginComponent);

var _a, _b, _c, _d;
//# sourceMappingURL=PupilLoginComponent.js.map

/***/ }),

/***/ "../../../../../src/app/Routing.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return routing; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_router__ = __webpack_require__("../../../router/@angular/router.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__LoginComponent__ = __webpack_require__("../../../../../src/app/LoginComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__diklabuComponent__ = __webpack_require__("../../../../../src/app/diklabuComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__authentication_guard__ = __webpack_require__("../../../../../src/app/authentication.guard.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4__VerlaufComponent__ = __webpack_require__("../../../../../src/app/VerlaufComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__AnwesenheitsComponent__ = __webpack_require__("../../../../../src/app/AnwesenheitsComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6__TodayAnwesenheitsComponente__ = __webpack_require__("../../../../../src/app/TodayAnwesenheitsComponente.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7__FehlzeitenComponent__ = __webpack_require__("../../../../../src/app/FehlzeitenComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_8__NotenComponent__ = __webpack_require__("../../../../../src/app/NotenComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_9__BetriebeComponent__ = __webpack_require__("../../../../../src/app/BetriebeComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_10__PupilLoginComponent__ = __webpack_require__("../../../../../src/app/PupilLoginComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_11__KurszugehoerigkeitComponent__ = __webpack_require__("../../../../../src/app/KurszugehoerigkeitComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_12__LehrerzugehoerigkeitComponent__ = __webpack_require__("../../../../../src/app/LehrerzugehoerigkeitComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_13__PortfolioComponent__ = __webpack_require__("../../../../../src/app/PortfolioComponent.ts");














var appRoutes = [
    {
        path: '',
        pathMatch: 'full',
        redirectTo: 'login'
    },
    { path: 'login', component: __WEBPACK_IMPORTED_MODULE_1__LoginComponent__["a" /* LoginComponent */] },
    {
        path: 'diklabu', component: __WEBPACK_IMPORTED_MODULE_2__diklabuComponent__["a" /* diklabuComponent */], canActivate: [__WEBPACK_IMPORTED_MODULE_3__authentication_guard__["a" /* AuthenticationGuard */]], data: { roles: ['Admin', 'Lehrer', "Verwaltung"] },
        children: [
            { path: 'verlauf', component: __WEBPACK_IMPORTED_MODULE_4__VerlaufComponent__["a" /* VerlaufComponent */], outlet: 'sub' },
            { path: 'anwesenheit', component: __WEBPACK_IMPORTED_MODULE_5__AnwesenheitsComponent__["a" /* AnwesenheitsComponent */], outlet: 'sub' },
            { path: 'todayanwesenheit', component: __WEBPACK_IMPORTED_MODULE_6__TodayAnwesenheitsComponente__["a" /* TodayAnwesenheitsComponente */], outlet: 'sub' },
            { path: 'fehlzeiten', component: __WEBPACK_IMPORTED_MODULE_7__FehlzeitenComponent__["a" /* FehlzeitenComponent */], outlet: 'sub' },
            { path: 'noten', component: __WEBPACK_IMPORTED_MODULE_8__NotenComponent__["a" /* NotenComponent */], outlet: 'sub' },
            { path: 'portfolio', component: __WEBPACK_IMPORTED_MODULE_13__PortfolioComponent__["a" /* PortfolioComponent */], outlet: 'sub' },
            { path: 'betriebe', component: __WEBPACK_IMPORTED_MODULE_9__BetriebeComponent__["a" /* BetriebeComponent */], outlet: 'sub' },
            { path: 'zugehoerigkeit', component: __WEBPACK_IMPORTED_MODULE_11__KurszugehoerigkeitComponent__["a" /* KurszugehoerigkeitComponent */], outlet: 'sub' },
            { path: 'lzugehoerigkeit', component: __WEBPACK_IMPORTED_MODULE_12__LehrerzugehoerigkeitComponent__["a" /* LehrerzugehoerigkeitComponent */], outlet: 'sub' }
        ]
    },
    {
        path: 'schueler', component: __WEBPACK_IMPORTED_MODULE_10__PupilLoginComponent__["a" /* PupilLoginComponent */], canActivate: [__WEBPACK_IMPORTED_MODULE_3__authentication_guard__["a" /* AuthenticationGuard */]], data: { roles: ['Schueler'] },
    },
    {
        path: "**",
        redirectTo: 'login'
    }
];
var routing = __WEBPACK_IMPORTED_MODULE_0__angular_router__["RouterModule"].forRoot(appRoutes);
//# sourceMappingURL=Routing.js.map

/***/ }),

/***/ "../../../../../src/app/TodayAnwesenheitsComponente.html":
/***/ (function(module, exports) {

module.exports = "<p-dataGrid [value]=\"pupils\" >\r\n  <p-header>\r\n    <h3>Anwesenheit am {{today| date: 'dd.MM.yyyy'}}</h3>\r\n  </p-header>\r\n  <ng-template let-pupil pTemplate=\"item\">\r\n    <div style=\"padding:3px\" class=\"ui-g-12 ui-md-3\">\r\n      <p-panel [header]=\"pupil.VNAME+' '+pupil.NNAME\" [style]=\"{'text-align':'center'}\">\r\n        <img [style.border-color]=\"getImageBorder(pupil)\" [src]=\"pupil.imageSrc\" height=\"100\" style=\"cursor:pointer\" (click)=\"changeAnwesenheit(pupil)\">\r\n        <hr class=\"ui-widget-content\" style=\"border-top:0\">\r\n        <div class=\"car-detail\">\r\n          <div class=\"ui-inputgroup\">\r\n            <span class=\"ui-inputgroup-addon\" ><i class=\"fa fa-user\"></i></span>\r\n            <input (focusout)=\"vermerkFokusChanged(pupil)\" (keydown)=\"vermekChanged($event,pupil)\" [(ngModel)]=\"pupil.vermerk\" type=\"text\" pInputText placeholder=\"Vermerk\">\r\n          </div>\r\n            <div class=\"ui-inputgroup\">\r\n            <span class=\"ui-inputgroup-addon\"><i class=\"fa fa-comment\"></i></span>\r\n            <input (focusout)=\"bemerkungFokusChanged(pupil)\" (keydown)=\"bemerkungChanged($event,pupil)\"  [(ngModel)]=\"pupil.vermerkBemerkung\" type=\"text\" pInputText placeholder=\"Bemerkung\">\r\n          </div>\r\n        </div>\r\n        <i class=\"fa fa-search\" (click)=\"selectPupil(pupil)\" style=\"cursor:pointer\"></i>\r\n      </p-panel>\r\n    </div>\r\n  </ng-template>\r\n</p-dataGrid>\r\n<pupildetails #infoDialog ></pupildetails>\r\n"

/***/ }),

/***/ "../../../../../src/app/TodayAnwesenheitsComponente.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return TodayAnwesenheitsComponente; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__services_SharedService__ = __webpack_require__("../../../../../src/app/services/SharedService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__services_AnwesenheitsService__ = __webpack_require__("../../../../../src/app/services/AnwesenheitsService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice__ = __webpack_require__("../../../../primeng/components/common/messageservice.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4__CourseSelectComponent__ = __webpack_require__("../../../../../src/app/CourseSelectComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__services_CourseService__ = __webpack_require__("../../../../../src/app/services/CourseService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7__data_CourseBook__ = __webpack_require__("../../../../../src/app/data/CourseBook.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_8__services_DokuService__ = __webpack_require__("../../../../../src/app/services/DokuService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_9__data_Anwesenheitseintrag__ = __webpack_require__("../../../../../src/app/data/Anwesenheitseintrag.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};










var TodayAnwesenheitsComponente = (function () {
    // Injizieren der notwendigen Services
    function TodayAnwesenheitsComponente(service, anwesenheitsService, messageService, courseService, dokuService) {
        this.service = service;
        this.anwesenheitsService = anwesenheitsService;
        this.messageService = messageService;
        this.courseService = courseService;
        this.dokuService = dokuService;
        this.today = new Date();
        this.vermerke = ['a', 'f', 'e'];
        console.log(" TodayAnwesenheits Component constructor");
        this.pupils = __WEBPACK_IMPORTED_MODULE_4__CourseSelectComponent__["a" /* CourseSelectComponent */].pupils.filter(function (x) { return x.ABGANG == "N"; });
        for (var i = 0; i < this.pupils.length; i++) {
            this.pupils[i].imageSrc = "../assets/anonym.gif";
            this.pupils[i].vermerkIndex = 0;
        }
        this.updateAnwesenheit();
        this.updateImages();
    }
    TodayAnwesenheitsComponente.prototype.ngOnInit = function () {
        var _this = this;
        // Doku Component unsichtbar schalten, da es hierzu keine Dokumentation gibt.
        this.dokuService.setDisplayDoku(false);
        // Beim CourseBook unterschreiben (Observer), um über Änderung am Klassenbuch (Klasse, Zeitbereit) informiert zu werden
        this.subscription = this.service.getCoursebook().subscribe(function (message) {
            console.log("TodayAnwesenheits Component new Data !" + message.constructor.name);
            _this.pupils = __WEBPACK_IMPORTED_MODULE_4__CourseSelectComponent__["a" /* CourseSelectComponent */].pupils.filter(function (x) { return x.ABGANG == "N"; });
            for (var i = 0; i < _this.pupils.length; i++) {
                _this.pupils[i].imageSrc = "../assets/anonym.gif";
                _this.pupils[i].vermerkIndex = 0;
            }
            _this.updateAnwesenheit();
            _this.updateImages();
        });
    };
    TodayAnwesenheitsComponente.prototype.ngOnDestroy = function () {
        // Beim CourseBook (Obbserver abmelden !)
        this.subscription.unsubscribe();
    };
    TodayAnwesenheitsComponente.prototype.vermekChanged = function (event, p) {
        console.log(event.keyCode);
        if (event.keyCode == 13 || event.keyCode == 9) {
            console.log("Vermek Changed for " + JSON.stringify(p));
            this.sendAnwesenheit(p);
        }
    };
    TodayAnwesenheitsComponente.prototype.bemerkungChanged = function (event, p) {
        if (event.keyCode == 13 || event.keyCode == 9) {
            console.log("Bemerkung Changed for " + JSON.stringify(p));
            this.sendAnwesenheit(p);
        }
    };
    TodayAnwesenheitsComponente.prototype.vermerkFokusChanged = function (p) {
        console.log("Vermek Changed for " + JSON.stringify(p));
        this.sendAnwesenheit(p);
    };
    TodayAnwesenheitsComponente.prototype.bemerkungFokusChanged = function (p) {
        console.log("Bemerkung Changed for " + JSON.stringify(p));
        this.sendAnwesenheit(p);
    };
    TodayAnwesenheitsComponente.prototype.sendAnwesenheit = function (p) {
        var _this = this;
        var a = new __WEBPACK_IMPORTED_MODULE_9__data_Anwesenheitseintrag__["a" /* Anwesenheitseintrag */]();
        a.DATUM = __WEBPACK_IMPORTED_MODULE_7__data_CourseBook__["a" /* CourseBook */].toSQLString(this.today) + "T00:00:00";
        a.ID_KLASSE = __WEBPACK_IMPORTED_MODULE_6__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.id;
        a.ID_LEHRER = __WEBPACK_IMPORTED_MODULE_6__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.idLehrer;
        a.ID_SCHUELER = p.id;
        a.VERMERK = p.vermerk;
        a.BEMERKUNG = p.vermerkBemerkung;
        if (a.VERMERK == "") {
            this.anwesenheitsService.deleteAnwesenheit(a);
        }
        else {
            this.anwesenheitsService.setAnwesenheit(a).subscribe(function (data) {
                console.log("Recieved" + JSON.stringify(data));
                if (data.parseError) {
                    _this.messageService.add({
                        severity: 'warning',
                        summary: 'Warnung',
                        detail: "Formatierungsfehler im Eintrag " + a.VERMERK
                    });
                }
            }, function (err) {
                console.log("Recieved err" + err);
                _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: err });
            });
        }
    };
    TodayAnwesenheitsComponente.prototype.updateAnwesenheit = function () {
        var _this = this;
        this.anwesenheitsService.getTodaysAnwesenheit().subscribe(function (data) {
            var anw = data;
            console.log("Recieved todays Anwesenheit " + JSON.stringify(data));
            for (var i = 0; i < anw.length; i++) {
                var id = anw[i].id_Schueler;
                for (var j = 0; j < _this.pupils.length; j++) {
                    if (_this.pupils[j].id == id) {
                        _this.pupils[j].vermerk = anw[i].eintraege[0].VERMERK;
                        _this.pupils[j].vermerkBemerkung = anw[i].eintraege[0].BEMERKUNG;
                        break;
                    }
                }
            }
        }, function (err) {
            _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: err });
        });
    };
    TodayAnwesenheitsComponente.prototype.updateImages = function () {
        var _this = this;
        this.courseService.getCoursePictures(__WEBPACK_IMPORTED_MODULE_6__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME, 100).subscribe(function (data) {
            var imgData = data;
            //console.log("Received Course Images! Nubmer="+imgData.length);
            for (var i = 0; i < imgData.length; i++) {
                var id = imgData[i].id;
                if (imgData[i].base64) {
                    var base64 = imgData[i].base64;
                    var patt = /(?:\r\n|\r|\n)/g;
                    base64 = base64.replace(patt, "");
                    console.log("Image for ID=" + id + " ist " + base64);
                    for (var j = 0; j < _this.pupils.length; j++) {
                        if (_this.pupils[j].id == id) {
                            _this.pupils[j].imageSrc = "data:image/png;base64," + base64;
                        }
                    }
                }
                else {
                    console.log("No Image for ID=" + id);
                }
            }
        }, function (err) {
            _this.messageService.add({ severity: 'error', summary: 'Fehler', detail: err });
        });
    };
    TodayAnwesenheitsComponente.prototype.selectPupil = function (p) {
        console.log("Details Pupil:" + JSON.stringify(p));
        this.infoDialog.showDialog(p);
    };
    TodayAnwesenheitsComponente.prototype.getImageBorder = function (p) {
        if (p.vermerk == undefined) {
            return "gray";
        }
        if (p.vermerk.startsWith('ag')) {
            return "red";
        }
        if (p.vermerk.startsWith('a')) {
            return "green";
        }
        if (p.vermerk.startsWith('v')) {
            return "green";
        }
        if (p.vermerk.startsWith('e')) {
            return "yellow";
        }
        if (p.vermerk.startsWith('f')) {
            return "red";
        }
        return "gray";
    };
    TodayAnwesenheitsComponente.prototype.changeAnwesenheit = function (p) {
        if (p.vermerkIndex == undefined) {
            p.vermerkIndex = 0;
        }
        p.vermerk = this.vermerke[p.vermerkIndex];
        this.sendAnwesenheit(p);
        console.log("Change Anwenheit to:" + p.vermerk + " Index=" + p.vermerkIndex + " Vermerke=" + this.vermerke);
        p.vermerkIndex++;
        if (p.vermerkIndex >= this.vermerke.length) {
            p.vermerkIndex = 0;
        }
    };
    return TodayAnwesenheitsComponente;
}());
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('infoDialog'),
    __metadata("design:type", Object)
], TodayAnwesenheitsComponente.prototype, "infoDialog", void 0);
TodayAnwesenheitsComponente = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'todayanwesenheit',
        styles: ['input {width:100%;}img {border-style: solid;border-width: 4px;border-color: gray}'],
        template: __webpack_require__("../../../../../src/app/TodayAnwesenheitsComponente.html")
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_1__services_SharedService__["a" /* SharedService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_1__services_SharedService__["a" /* SharedService */]) === "function" && _a || Object, typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_2__services_AnwesenheitsService__["a" /* AnwesenheitsService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_2__services_AnwesenheitsService__["a" /* AnwesenheitsService */]) === "function" && _b || Object, typeof (_c = typeof __WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice__["MessageService"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_3_primeng_components_common_messageservice__["MessageService"]) === "function" && _c || Object, typeof (_d = typeof __WEBPACK_IMPORTED_MODULE_5__services_CourseService__["a" /* CourseService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_5__services_CourseService__["a" /* CourseService */]) === "function" && _d || Object, typeof (_e = typeof __WEBPACK_IMPORTED_MODULE_8__services_DokuService__["a" /* DokuService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_8__services_DokuService__["a" /* DokuService */]) === "function" && _e || Object])
], TodayAnwesenheitsComponente);

var _a, _b, _c, _d, _e;
//# sourceMappingURL=TodayAnwesenheitsComponente.js.map

/***/ }),

/***/ "../../../../../src/app/VerlaufComponent.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return VerlaufComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__data_Verlauf__ = __webpack_require__("../../../../../src/app/data/Verlauf.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__services_DokuService__ = __webpack_require__("../../../../../src/app/services/DokuService.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};



/**
 * @title Basic tabs
 */
var VerlaufComponent = (function () {
    function VerlaufComponent(dokuService) {
        this.dokuService = dokuService;
        console.log("construktor verlaufkomponente");
    }
    VerlaufComponent.prototype.ngOnInit = function () {
        this.dokuService.setDisplayDoku(true, "Verlauf");
    };
    VerlaufComponent.prototype.newVerlauf = function (v) {
        //console.log("Neuer Verlauf eintragen "+v.INHALT);
        this.listVerlaufComponent.addVerlauf(v);
    };
    VerlaufComponent.prototype.editVerlauf = function (v) {
        console.log(v.constructor.name);
        console.log("editVerlauf Revices:" + JSON.stringify(v));
        var ve = new __WEBPACK_IMPORTED_MODULE_1__data_Verlauf__["a" /* Verlauf */](v.INHALT, v.STUNDE, v.ID_LEHRER, v.ID_KLASSE, v.DATUM);
        ve.BEMERKUNG = v.BEMERKUNG;
        ve.AUFGABE = v.AUFGABE;
        ve.wochentag = v.wochentag;
        ve.ID_LERNFELD = v.ID_LERNFELD;
        ve.kw = v.kw;
        this.verlaufComponent.setVerlauf(ve);
    };
    return VerlaufComponent;
}());
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('newVerlaufComponent'),
    __metadata("design:type", Object)
], VerlaufComponent.prototype, "verlaufComponent", void 0);
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('listVerlaufComponent'),
    __metadata("design:type", Object)
], VerlaufComponent.prototype, "listVerlaufComponent", void 0);
VerlaufComponent = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'verlauf',
        template: '<newverlauf #newVerlaufComponent (newVerlauf)="newVerlauf($event)"></newverlauf>' +
            '    <listverlauf #listVerlaufComponent (editVerlauf)="editVerlauf($event)"></listverlauf>',
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_2__services_DokuService__["a" /* DokuService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_2__services_DokuService__["a" /* DokuService */]) === "function" && _a || Object])
], VerlaufComponent);

var _a;
//# sourceMappingURL=VerlaufComponent.js.map

/***/ }),

/***/ "../../../../../src/app/VerlaufDeleteDialog.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return VerlaufDeleteDialog; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__data_Verlauf__ = __webpack_require__("../../../../../src/app/data/Verlauf.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};


var VerlaufDeleteDialog = (function () {
    function VerlaufDeleteDialog() {
        this.deleteVerlauf = new __WEBPACK_IMPORTED_MODULE_0__angular_core__["EventEmitter"]();
        this.display = false;
        this.titel = "";
        this.verlauf = new __WEBPACK_IMPORTED_MODULE_1__data_Verlauf__["a" /* Verlauf */]("", "", "", 0, "");
    }
    VerlaufDeleteDialog.prototype.showDialog = function (titel, v) {
        this.verlauf = v;
        this.titel = titel;
        this.display = true;
    };
    VerlaufDeleteDialog.prototype.delete = function () {
        this.display = false;
        this.deleteVerlauf.emit(this.verlauf);
    };
    return VerlaufDeleteDialog;
}());
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Output"])(),
    __metadata("design:type", Object)
], VerlaufDeleteDialog.prototype, "deleteVerlauf", void 0);
VerlaufDeleteDialog = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'deleteverlauf',
        styles: [],
        template: ' <p-dialog [header]="titel" [(visible)]="display" modal="modal" [closable]="true" [width]="300" appendTo="body"><br/>' +
            '<strong>Datum: </strong>{{verlauf.DATUM |  date: "dd.MM.yyyy"}}<br/>' +
            '<strong>Stunde: </strong>{{verlauf.STUNDE}}<br/>' +
            '<strong>Lernfeld: </strong>{{verlauf.ID_LERNFELD}}<br/>' +
            '<strong>Inhalt: </strong>{{verlauf.INHALT}}<br/>' +
            '<br/>' +
            '        <p-footer>\n' +
            '            <button type="button" class="ui-button-success" pButton icon="fa-check" (click)="delete()" label="Löschen"></button>\n' +
            '            <button type="button" pButton icon="fa-close" (click)="display=false" label="Abbrechen"></button>\n' +
            '        </p-footer>\n' +
            '</p-dialog>'
    }),
    __metadata("design:paramtypes", [])
], VerlaufDeleteDialog);

//# sourceMappingURL=VerlaufDeleteDialog.js.map

/***/ }),

/***/ "../../../../../src/app/app.component.css":
/***/ (function(module, exports, __webpack_require__) {

exports = module.exports = __webpack_require__("../../../../css-loader/lib/css-base.js")(false);
// imports


// module
exports.push([module.i, "", ""]);

// exports


/*** EXPORTS FROM exports-loader ***/
module.exports = module.exports.toString();

/***/ }),

/***/ "../../../../../src/app/app.component.html":
/***/ (function(module, exports) {

module.exports = "<!--The content below is only a placeholder and can be replaced.-->\r\n<p-growl [(value)]=\"msgs\"></p-growl>\r\n<angular-loader></angular-loader>\r\n<div style=\"text-align:center\" >\r\n\r\n  <router-outlet ></router-outlet>\r\n\r\n</div>\r\n\r\n"

/***/ }),

/***/ "../../../../../src/app/app.component.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return AppComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__services_SharedService__ = __webpack_require__("../../../../../src/app/services/SharedService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice__ = __webpack_require__("../../../../primeng/components/common/messageservice.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__services_PupilDetailService__ = __webpack_require__("../../../../../src/app/services/PupilDetailService.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};




var AppComponent = (function () {
    function AppComponent(service, pupilDetailService, messageService) {
        this.service = service;
        this.pupilDetailService = pupilDetailService;
        this.messageService = messageService;
    }
    AppComponent.prototype.ngOnDestroy = function () {
    };
    return AppComponent;
}());
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('courseBookComponent'),
    __metadata("design:type", Object)
], AppComponent.prototype, "courseBookComponent", void 0);
__decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["ViewChild"])('tabcomponent'),
    __metadata("design:type", Object)
], AppComponent.prototype, "tabComponent", void 0);
AppComponent = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'app-root',
        template: __webpack_require__("../../../../../src/app/app.component.html"),
        styles: [__webpack_require__("../../../../../src/app/app.component.css")],
        providers: [__WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice__["MessageService"]]
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_1__services_SharedService__["a" /* SharedService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_1__services_SharedService__["a" /* SharedService */]) === "function" && _a || Object, typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_3__services_PupilDetailService__["a" /* PupilDetailService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_3__services_PupilDetailService__["a" /* PupilDetailService */]) === "function" && _b || Object, typeof (_c = typeof __WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice__["MessageService"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_2_primeng_components_common_messageservice__["MessageService"]) === "function" && _c || Object])
], AppComponent);

var _a, _b, _c;
//# sourceMappingURL=app.component.js.map

/***/ }),

/***/ "../../../../../src/app/app.module.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return AppModule; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_platform_browser__ = __webpack_require__("../../../platform-browser/@angular/platform-browser.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__ng_bootstrap_ng_bootstrap__ = __webpack_require__("../../../../@ng-bootstrap/ng-bootstrap/index.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__angular_forms__ = __webpack_require__("../../../forms/@angular/forms.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4__app_component__ = __webpack_require__("../../../../../src/app/app.component.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__DatepickerComponent__ = __webpack_require__("../../../../../src/app/DatepickerComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6__angular_platform_browser_animations__ = __webpack_require__("../../../platform-browser/@angular/platform-browser/animations.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7__CourseSelectComponent__ = __webpack_require__("../../../../../src/app/CourseSelectComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_8__DurationPickerComponent__ = __webpack_require__("../../../../../src/app/DurationPickerComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_9__angular_common_http__ = __webpack_require__("../../../common/@angular/common/http.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_10__LFSelectComponent__ = __webpack_require__("../../../../../src/app/LFSelectComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_11__NewVerlaufComponent__ = __webpack_require__("../../../../../src/app/NewVerlaufComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_12__angular_http__ = __webpack_require__("../../../http/@angular/http.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_13__ListVerlaufComponent__ = __webpack_require__("../../../../../src/app/ListVerlaufComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_14_hammerjs__ = __webpack_require__("../../../../hammerjs/hammer.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_14_hammerjs___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_14_hammerjs__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_15__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_16__services_SharedService__ = __webpack_require__("../../../../../src/app/services/SharedService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_17__AnwesenheitsComponent__ = __webpack_require__("../../../../../src/app/AnwesenheitsComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_18__services_PupilService__ = __webpack_require__("../../../../../src/app/services/PupilService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__ = __webpack_require__("../../../../primeng/primeng.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_19_primeng_primeng___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_19_primeng_primeng__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_20__services_AnwesenheitsService__ = __webpack_require__("../../../../../src/app/services/AnwesenheitsService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_21__LoginComponent__ = __webpack_require__("../../../../../src/app/LoginComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_22__services_LoginService__ = __webpack_require__("../../../../../src/app/services/LoginService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_23__Routing__ = __webpack_require__("../../../../../src/app/Routing.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_24__diklabuComponent__ = __webpack_require__("../../../../../src/app/diklabuComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_25__authentication_guard__ = __webpack_require__("../../../../../src/app/authentication.guard.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_26__services_VerlaufsService__ = __webpack_require__("../../../../../src/app/services/VerlaufsService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_27__services_MailService__ = __webpack_require__("../../../../../src/app/services/MailService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_28__MailDialog__ = __webpack_require__("../../../../../src/app/MailDialog.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_29__services_PupilDetailService__ = __webpack_require__("../../../../../src/app/services/PupilDetailService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_30__PupilDetailDialog__ = __webpack_require__("../../../../../src/app/PupilDetailDialog.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_31__PupilImageComponent__ = __webpack_require__("../../../../../src/app/PupilImageComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_32__DokuComponent__ = __webpack_require__("../../../../../src/app/DokuComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_33__services_DokuService__ = __webpack_require__("../../../../../src/app/services/DokuService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_34__services_CourseService__ = __webpack_require__("../../../../../src/app/services/CourseService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_35__PlanDialog__ = __webpack_require__("../../../../../src/app/PlanDialog.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_36__CourseInfoDialog__ = __webpack_require__("../../../../../src/app/CourseInfoDialog.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_37__MenuComponent__ = __webpack_require__("../../../../../src/app/MenuComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_38__VerlaufComponent__ = __webpack_require__("../../../../../src/app/VerlaufComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_39_primeng_components_dropdown_dropdown__ = __webpack_require__("../../../../primeng/components/dropdown/dropdown.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_39_primeng_components_dropdown_dropdown___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_39_primeng_components_dropdown_dropdown__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_40__VerlaufDeleteDialog__ = __webpack_require__("../../../../../src/app/VerlaufDeleteDialog.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_41__TodayAnwesenheitsComponente__ = __webpack_require__("../../../../../src/app/TodayAnwesenheitsComponente.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_42__FehlzeitenComponent__ = __webpack_require__("../../../../../src/app/FehlzeitenComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_43__NotenComponent__ = __webpack_require__("../../../../../src/app/NotenComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_44__services_NotenService__ = __webpack_require__("../../../../../src/app/services/NotenService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_45__AnwesenheitsFilterComponent__ = __webpack_require__("../../../../../src/app/AnwesenheitsFilterComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_46__BetriebeComponent__ = __webpack_require__("../../../../../src/app/BetriebeComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_47__PupilLoginComponent__ = __webpack_require__("../../../../../src/app/PupilLoginComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_48__loader_loader_component__ = __webpack_require__("../../../../../src/app/loader/loader.component.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_49__loader_loader_service__ = __webpack_require__("../../../../../src/app/loader/loader.service.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_50__loader_HttpService__ = __webpack_require__("../../../../../src/app/loader/HttpService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_51__loader_http_service_factory__ = __webpack_require__("../../../../../src/app/loader/http-service.factory.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_52__KurszugehoerigkeitComponent__ = __webpack_require__("../../../../../src/app/KurszugehoerigkeitComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_53__PupilDetailEditDialog__ = __webpack_require__("../../../../../src/app/PupilDetailEditDialog.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_54__LehrerzugehoerigkeitComponent__ = __webpack_require__("../../../../../src/app/LehrerzugehoerigkeitComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_55__services_TeacherService__ = __webpack_require__("../../../../../src/app/services/TeacherService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_56__PortfolioComponent__ = __webpack_require__("../../../../../src/app/PortfolioComponent.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};

























































var AppModule = (function () {
    function AppModule() {
    }
    return AppModule;
}());
AppModule = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_1__angular_core__["NgModule"])({
        declarations: [
            __WEBPACK_IMPORTED_MODULE_4__app_component__["a" /* AppComponent */], __WEBPACK_IMPORTED_MODULE_5__DatepickerComponent__["a" /* DatepickerComponent */], __WEBPACK_IMPORTED_MODULE_7__CourseSelectComponent__["a" /* CourseSelectComponent */], __WEBPACK_IMPORTED_MODULE_8__DurationPickerComponent__["a" /* DurationPickerComponent */], __WEBPACK_IMPORTED_MODULE_10__LFSelectComponent__["a" /* LFSelectComponent */], __WEBPACK_IMPORTED_MODULE_11__NewVerlaufComponent__["a" /* NewVerlaufComponent */],
            __WEBPACK_IMPORTED_MODULE_13__ListVerlaufComponent__["a" /* ListVerlaufComponent */], __WEBPACK_IMPORTED_MODULE_15__CourseBookComponent__["a" /* CourseBookComponent */], __WEBPACK_IMPORTED_MODULE_17__AnwesenheitsComponent__["a" /* AnwesenheitsComponent */], __WEBPACK_IMPORTED_MODULE_21__LoginComponent__["a" /* LoginComponent */],
            __WEBPACK_IMPORTED_MODULE_24__diklabuComponent__["a" /* diklabuComponent */], __WEBPACK_IMPORTED_MODULE_28__MailDialog__["a" /* MailDialog */], __WEBPACK_IMPORTED_MODULE_30__PupilDetailDialog__["a" /* PupilDetailDialog */], __WEBPACK_IMPORTED_MODULE_31__PupilImageComponent__["a" /* PupilImageComponent */], __WEBPACK_IMPORTED_MODULE_32__DokuComponent__["a" /* DokuComponent */], __WEBPACK_IMPORTED_MODULE_35__PlanDialog__["a" /* PlanDialog */], __WEBPACK_IMPORTED_MODULE_37__MenuComponent__["a" /* MenuComponent */],
            __WEBPACK_IMPORTED_MODULE_36__CourseInfoDialog__["a" /* CourseInfoDialog */], __WEBPACK_IMPORTED_MODULE_38__VerlaufComponent__["a" /* VerlaufComponent */], __WEBPACK_IMPORTED_MODULE_40__VerlaufDeleteDialog__["a" /* VerlaufDeleteDialog */], __WEBPACK_IMPORTED_MODULE_41__TodayAnwesenheitsComponente__["a" /* TodayAnwesenheitsComponente */],
            __WEBPACK_IMPORTED_MODULE_42__FehlzeitenComponent__["a" /* FehlzeitenComponent */], __WEBPACK_IMPORTED_MODULE_43__NotenComponent__["a" /* NotenComponent */], __WEBPACK_IMPORTED_MODULE_45__AnwesenheitsFilterComponent__["a" /* AnwesenheitsFilterComponent */], __WEBPACK_IMPORTED_MODULE_46__BetriebeComponent__["a" /* BetriebeComponent */], __WEBPACK_IMPORTED_MODULE_47__PupilLoginComponent__["a" /* PupilLoginComponent */],
            __WEBPACK_IMPORTED_MODULE_48__loader_loader_component__["a" /* LoaderComponent */], __WEBPACK_IMPORTED_MODULE_52__KurszugehoerigkeitComponent__["a" /* KurszugehoerigkeitComponent */], __WEBPACK_IMPORTED_MODULE_53__PupilDetailEditDialog__["a" /* PupilDetailEditDialog */], __WEBPACK_IMPORTED_MODULE_54__LehrerzugehoerigkeitComponent__["a" /* LehrerzugehoerigkeitComponent */], __WEBPACK_IMPORTED_MODULE_56__PortfolioComponent__["a" /* PortfolioComponent */]
        ],
        imports: [
            __WEBPACK_IMPORTED_MODULE_0__angular_platform_browser__["BrowserModule"], __WEBPACK_IMPORTED_MODULE_2__ng_bootstrap_ng_bootstrap__["a" /* NgbModule */].forRoot(), __WEBPACK_IMPORTED_MODULE_3__angular_forms__["FormsModule"],
            __WEBPACK_IMPORTED_MODULE_6__angular_platform_browser_animations__["a" /* BrowserAnimationsModule */],
            __WEBPACK_IMPORTED_MODULE_9__angular_common_http__["b" /* HttpClientModule */], __WEBPACK_IMPORTED_MODULE_12__angular_http__["d" /* HttpModule */], __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__["DataTableModule"], __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__["SharedModule"],
            __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__["GrowlModule"], __WEBPACK_IMPORTED_MODULE_23__Routing__["a" /* routing */], __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__["DialogModule"], __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__["ButtonModule"], __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__["InputTextModule"],
            __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__["InputTextareaModule"], __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__["FileUploadModule"], __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__["SplitButtonModule"], __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__["TooltipModule"], __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__["MenuModule"], __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__["PasswordModule"], __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__["CalendarModule"], __WEBPACK_IMPORTED_MODULE_39_primeng_components_dropdown_dropdown__["DropdownModule"],
            __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__["DataListModule"], __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__["OrderListModule"], __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__["TieredMenuModule"], __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__["DataGridModule"], __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__["PanelModule"], __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__["ProgressSpinnerModule"], __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__["ProgressSpinnerModule"],
            __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__["PickListModule"], __WEBPACK_IMPORTED_MODULE_19_primeng_primeng__["InputSwitchModule"],
        ],
        exports: [],
        providers: [
            __WEBPACK_IMPORTED_MODULE_16__services_SharedService__["a" /* SharedService */], __WEBPACK_IMPORTED_MODULE_4__app_component__["a" /* AppComponent */], __WEBPACK_IMPORTED_MODULE_18__services_PupilService__["a" /* PupilService */], __WEBPACK_IMPORTED_MODULE_20__services_AnwesenheitsService__["a" /* AnwesenheitsService */], __WEBPACK_IMPORTED_MODULE_22__services_LoginService__["a" /* LoginService */], __WEBPACK_IMPORTED_MODULE_25__authentication_guard__["a" /* AuthenticationGuard */], __WEBPACK_IMPORTED_MODULE_26__services_VerlaufsService__["a" /* VerlaufsService */],
            __WEBPACK_IMPORTED_MODULE_27__services_MailService__["a" /* MailService */], __WEBPACK_IMPORTED_MODULE_29__services_PupilDetailService__["a" /* PupilDetailService */], __WEBPACK_IMPORTED_MODULE_33__services_DokuService__["a" /* DokuService */], __WEBPACK_IMPORTED_MODULE_34__services_CourseService__["a" /* CourseService */], __WEBPACK_IMPORTED_MODULE_44__services_NotenService__["a" /* NotenService */], __WEBPACK_IMPORTED_MODULE_55__services_TeacherService__["a" /* TeacherService */],
            __WEBPACK_IMPORTED_MODULE_49__loader_loader_service__["a" /* LoaderService */],
            {
                provide: __WEBPACK_IMPORTED_MODULE_50__loader_HttpService__["a" /* HttpService */],
                useFactory: __WEBPACK_IMPORTED_MODULE_51__loader_http_service_factory__["a" /* httpServiceFactory */],
                deps: [__WEBPACK_IMPORTED_MODULE_12__angular_http__["i" /* XHRBackend */], __WEBPACK_IMPORTED_MODULE_12__angular_http__["e" /* RequestOptions */], __WEBPACK_IMPORTED_MODULE_49__loader_loader_service__["a" /* LoaderService */]]
            }
        ],
        entryComponents: [],
        bootstrap: [__WEBPACK_IMPORTED_MODULE_4__app_component__["a" /* AppComponent */]]
    })
], AppModule);

//# sourceMappingURL=app.module.js.map

/***/ }),

/***/ "../../../../../src/app/authentication.guard.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return AuthenticationGuard; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_router__ = __webpack_require__("../../../router/@angular/router.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};



var AuthenticationGuard = (function () {
    function AuthenticationGuard(router) {
        this.router = router;
    }
    AuthenticationGuard.prototype.canActivate = function (route, state) {
        var roles = route.data["roles"];
        console.log("AuthGuard canActivate! roles=" + JSON.stringify(roles));
        if (__WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token) {
            console.log("AuthGuard canActivate! Result " + (roles == null || roles.indexOf("Admin") != -1));
            return (roles == null || roles.indexOf("Admin") != -1 || roles.indexOf("Schueler") != -1);
        }
        this.router.navigate(['/login']);
        return false;
    };
    return AuthenticationGuard;
}());
AuthenticationGuard = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_1__angular_core__["Injectable"])(),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_0__angular_router__["Router"] !== "undefined" && __WEBPACK_IMPORTED_MODULE_0__angular_router__["Router"]) === "function" && _a || Object])
], AuthenticationGuard);

var _a;
//# sourceMappingURL=authentication.guard.js.map

/***/ }),

/***/ "../../../../../src/app/data/Anwesenheitseintrag.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return Anwesenheitseintrag; });
var Anwesenheitseintrag = (function () {
    function Anwesenheitseintrag() {
    }
    return Anwesenheitseintrag;
}());

//# sourceMappingURL=Anwesenheitseintrag.js.map

/***/ }),

/***/ "../../../../../src/app/data/Config.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return Config; });
var Config = (function () {
    function Config() {
    }
    return Config;
}());

Config.debug = false;
Config.version = "2.11";
Config.SERVER = "http://" + window.location.hostname + ":8080/";
//# sourceMappingURL=Config.js.map

/***/ }),

/***/ "../../../../../src/app/data/Course.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return Course; });
var Course = (function () {
    function Course(id, name) {
        this.KNAME = "NoCourse";
        this.id = -1;
        this.ID_LEHRER = "NN";
        this.idKategorie = -1;
        this.id = id;
        this.KNAME = name;
        this.toString();
    }
    Course.prototype.toString = function () {
        console.log(" > Coursename:" + this.KNAME + " ID=" + this.id);
    };
    return Course;
}());

//# sourceMappingURL=Course.js.map

/***/ }),

/***/ "../../../../../src/app/data/CourseBook.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return CourseBook; });
var CourseBook = (function () {
    function CourseBook(from, to, course) {
        console.log("Constructed new Coursebook!");
        this.fromDate = from;
        this.toDate = to;
        this.course = course;
    }
    CourseBook.prototype.toString = function () {
        console.log("from=" + this.fromDate + " to=" + this.toDate + " Course:" + this.course.KNAME + "  ID=" + this.course.id);
    };
    CourseBook.toSQLString = function (d) {
        var m = "00";
        var t = "00";
        if ((d.getMonth() + 1) < 10) {
            m = "0" + (d.getMonth() + 1);
        }
        else {
            m = "" + (d.getMonth() + 1);
        }
        if (d.getDate() < 10) {
            t = "0" + d.getDate();
        }
        else {
            t = "" + d.getDate();
        }
        return d.getFullYear() + "-" + m + "-" + t;
    };
    CourseBook.toIDString = function (d) {
        var m = "00";
        var t = "00";
        if ((d.getMonth() + 1) < 10) {
            m = "0" + (d.getMonth() + 1);
        }
        else {
            m = "" + (d.getMonth() + 1);
        }
        if (d.getDate() < 10) {
            t = "0" + d.getDate();
        }
        else {
            t = "" + d.getDate();
        }
        return d.getFullYear() + m + t;
    };
    CourseBook.toReadbleString = function (d) {
        return CourseBook.wochentage[d.getDay()] + " " + d.getDate() + "." + (d.getMonth() + 1) + "." + d.getFullYear();
    };
    return CourseBook;
}());

CourseBook.wochentage = ["So.", "Mo.", "Di.", "Mi.", "Do.", "Fr.", "Sa."];
//# sourceMappingURL=CourseBook.js.map

/***/ }),

/***/ "../../../../../src/app/data/Grades.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return Grade; });
/* unused harmony export Grades */
var Grade = (function () {
    function Grade() {
    }
    return Grade;
}());

var Grades = (function () {
    function Grades() {
        this.msg = "";
        this.success = true;
        this.schuelerID = 0;
    }
    return Grades;
}());

//# sourceMappingURL=Grades.js.map

/***/ }),

/***/ "../../../../../src/app/data/MailObject.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return MailObject; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__angular_http__ = __webpack_require__("../../../http/@angular/http.es5.js");


var MailObject = (function () {
    function MailObject(from, to, subject, body) {
        this.to = new Array();
        this.cc = new Array();
        this.bcc = new Array();
        this.recipientString = "";
        this.ccString = "";
        this.bccString = "";
        this.from = from;
        this.to.push(to);
        this.recipientString = to;
        this.subject = subject;
        this.content = body;
    }
    MailObject.prototype.addCC = function (s) {
        this.cc.push(s);
        this.ccString = this.cc.join(",");
    };
    MailObject.prototype.addBCC = function (s) {
        this.bcc.push(s);
        this.bccString = this.bcc.join(",");
    };
    MailObject.prototype.getBody = function () {
        var urlSearchParams = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["h" /* URLSearchParams */]();
        urlSearchParams.append('fromMail', this.from);
        urlSearchParams.append('subjectMail', this.subject);
        urlSearchParams.append('emailBody', this.content);
        urlSearchParams.append('auth_token', __WEBPACK_IMPORTED_MODULE_0__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        if (this.recipientString.length != 0) {
            var recipientBodyString = this.recipientString.replace(" ", "");
            var find = ',';
            var re = new RegExp(find, 'g');
            recipientBodyString = recipientBodyString.replace(re, ";");
            urlSearchParams.append('toMail', recipientBodyString);
        }
        if (this.ccString.length != 0) {
            var ccBodyString = this.ccString.replace(" ", "");
            var find = ',';
            var re = new RegExp(find, 'g');
            ccBodyString = ccBodyString.replace(re, ";");
            urlSearchParams.append('cc', ccBodyString);
        }
        if (this.bccString.length != 0) {
            var bccBodyString = this.bccString.replace(" ", "");
            var find = ',';
            var re = new RegExp(find, 'g');
            bccBodyString = bccBodyString.replace(re, ";");
            urlSearchParams.append('bcc', bccBodyString);
        }
        return urlSearchParams;
    };
    return MailObject;
}());

//# sourceMappingURL=MailObject.js.map

/***/ }),

/***/ "../../../../../src/app/data/Pupil.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return Pupil; });
var Pupil = (function () {
    function Pupil() {
        this.GEBDAT = null;
        this.NNAME = "";
        this.VNAME = "";
    }
    return Pupil;
}());

//# sourceMappingURL=Pupil.js.map

/***/ }),

/***/ "../../../../../src/app/data/PupilDetails.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return Ausbilder; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "b", function() { return Betrieb; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "c", function() { return PupilDetails; });
var Ausbilder = (function () {
    function Ausbilder() {
        this.EMAIL = "";
        this.FAX = "";
        this.ID = -1;
        this.ID_BETRIEB = -1;
        this.NNAME = "";
        this.TELEFON = "";
    }
    return Ausbilder;
}());

var Betrieb = (function () {
    function Betrieb() {
        this.ID = -1;
        this.NAME = "";
        this.ORT = "";
        this.PLZ = "";
        this.STRASSE = "";
    }
    return Betrieb;
}());

var PupilDetails = (function () {
    function PupilDetails() {
        this.ID_MMBBS = -1;
        this.abgang = "";
        this.ausbilder = new Ausbilder();
        this.betrieb = new Betrieb();
        this.email = "";
        this.gebDatum = "";
        this.id = -1;
        this.klassen = new Array();
        this.name = "";
        this.vorname = "";
        this.info = "";
    }
    return PupilDetails;
}());

//# sourceMappingURL=PupilDetails.js.map

/***/ }),

/***/ "../../../../../src/app/data/Termin.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return Termin; });
/* unused harmony export Termindaten */
var Termin = (function () {
    function Termin(name, id) {
        this.NAME = name;
        this.id = id;
    }
    return Termin;
}());

var Termindaten = (function () {
    function Termindaten() {
    }
    return Termindaten;
}());

//# sourceMappingURL=Termin.js.map

/***/ }),

/***/ "../../../../../src/app/data/Verlauf.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return Verlauf; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");

var Verlauf = (function () {
    function Verlauf(inhalt, stunde, id_lehrer, id_klasse, d) {
        this.AUFGABE = "";
        this.BEMERKUNG = "";
        this.DATUM = "";
        this.ID_KLASSE = -1;
        this.ID_LEHRER = "";
        this.ID_LERNFELD = "";
        this.INHALT = "";
        this.STUNDE = "";
        this.kw = 0;
        this.wochentag = "";
        this.success = true;
        this.INHALT = inhalt;
        this.STUNDE = stunde;
        this.ID_LEHRER = id_lehrer;
        this.ID_KLASSE = id_klasse;
        this.DATUM = d;
        this.wochentag = Verlauf.wochentage[new Date(d).getDay()];
        console.log("Neuer Verlauf  Wochentag=" + this.wochentag);
    }
    Verlauf.prototype.isOwnEntry = function () {
        if (this.ID_LEHRER == __WEBPACK_IMPORTED_MODULE_0__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.idLehrer) {
            return true;
        }
        return false;
    };
    return Verlauf;
}());

Verlauf.wochentage = ["So.", "Mo.", "Di.", "Mi.", "Do.", "Fr.", "Sa."];
//# sourceMappingURL=Verlauf.js.map

/***/ }),

/***/ "../../../../../src/app/datepickerComponent.css":
/***/ (function(module, exports, __webpack_require__) {

exports = module.exports = __webpack_require__("../../../../css-loader/lib/css-base.js")(false);
// imports


// module
exports.push([module.i, ".special {\r\n  text-align: left;\r\n}\r\n", ""]);

// exports


/*** EXPORTS FROM exports-loader ***/
module.exports = module.exports.toString();

/***/ }),

/***/ "../../../../../src/app/datepickerComponent.html":
/***/ (function(module, exports) {

module.exports = "<div class=\"special\">\r\n<strong>am..</strong>\r\n<p-calendar onchange=\"onChange($event)\" [(ngModel)]=\"d\" [showIcon]=\"true\" [locale]=\"de\" dateFormat=\"dd.mm.yy\"></p-calendar>\r\n</div>\r\n"

/***/ }),

/***/ "../../../../../src/app/diklabuComponent.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return diklabuComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};

var diklabuComponent = (function () {
    function diklabuComponent() {
    }
    return diklabuComponent;
}());
diklabuComponent = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'diklabu',
        template: '<coursebook #courseBookComponent></coursebook>\n' +
            '  <hr/>\n' +
            '  <router-outlet name=\"sub\"></router-outlet>',
    })
], diklabuComponent);

//# sourceMappingURL=diklabuComponent.js.map

/***/ }),

/***/ "../../../../../src/app/durationPickerComponent.css":
/***/ (function(module, exports, __webpack_require__) {

exports = module.exports = __webpack_require__("../../../../css-loader/lib/css-base.js")(false);
// imports


// module
exports.push([module.i, ".special {\r\n  text-align: left;\r\n\r\n}\r\n\r\n", ""]);

// exports


/*** EXPORTS FROM exports-loader ***/
module.exports = module.exports.toString();

/***/ }),

/***/ "../../../../../src/app/durationPickerComponent.html":
/***/ (function(module, exports) {

module.exports = "<div class=\"ui-g special ui-g-12\">\r\n  <div class=\"ui-md-5 \">\r\n    <strong>von:</strong><br/>\r\n    <p-calendar (onSelect)=\"fromChange($event)\" [(ngModel)]=\"fromDate\" [locale]=\"de\" [showIcon]=\"true\"\r\n                dateFormat=\"dd.mm.yy\"></p-calendar>\r\n  </div>\r\n  <div class=\"ui-md-5 \">\r\n    <strong>bis:</strong><br/>\r\n    <p-calendar (onSelect)=\"toChange($event)\" [(ngModel)]=\"toDate\" [locale]=\"de\" [showIcon]=\"true\" dateFormat=\"dd.mm.yy\"></p-calendar>\r\n  </div>\r\n</div>\r\n"

/***/ }),

/***/ "../../../../../src/app/loader/HttpService.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return HttpService; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_rxjs_Observable__ = __webpack_require__("../../../../rxjs/Observable.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_rxjs_Observable___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_1_rxjs_Observable__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_Rx__ = __webpack_require__("../../../../rxjs/Rx.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_Rx___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_2_rxjs_Rx__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__angular_http__ = __webpack_require__("../../../http/@angular/http.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4__angular_redux_request_options__ = __webpack_require__("../../../../../src/app/loader/angular-redux-request.options.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__loader_service__ = __webpack_require__("../../../../../src/app/loader/loader.service.ts");
var __extends = (this && this.__extends) || (function () {
    var extendStatics = Object.setPrototypeOf ||
        ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
        function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};






var HttpService = (function (_super) {
    __extends(HttpService, _super);
    function HttpService(backend, defaultOptions, loaderService) {
        var _this = _super.call(this, backend, defaultOptions) || this;
        _this.loaderService = loaderService;
        return _this;
    }
    HttpService.prototype.get = function (url, options) {
        var _this = this;
        this.showLoader();
        return _super.prototype.get.call(this, this.getFullUrl(url), this.requestOptions(options))
            .catch(this.onCatch)
            .do(function (res) {
            _this.onSuccess(res);
        }, function (error) {
            _this.onError(error);
        })
            .finally(function () {
            _this.onEnd();
        });
    };
    HttpService.prototype.requestOptions = function (options) {
        if (options == null) {
            options = new __WEBPACK_IMPORTED_MODULE_4__angular_redux_request_options__["a" /* AngularReduxRequestOptions */]();
        }
        if (options.headers == null) {
            options.headers = new __WEBPACK_IMPORTED_MODULE_3__angular_http__["b" /* Headers */]();
        }
        return options;
    };
    HttpService.prototype.getFullUrl = function (url) {
        return url;
    };
    HttpService.prototype.onCatch = function (error, caught) {
        return __WEBPACK_IMPORTED_MODULE_1_rxjs_Observable__["Observable"].throw(error);
    };
    HttpService.prototype.onSuccess = function (res) {
        console.log('Request successful');
    };
    HttpService.prototype.onError = function (res) {
        console.log('Error, status code: ' + res.status);
    };
    HttpService.prototype.onEnd = function () {
        this.hideLoader();
    };
    HttpService.prototype.showLoader = function () {
        console.log("SHOW LOADER..");
        this.loaderService.show();
    };
    HttpService.prototype.hideLoader = function () {
        console.log("HIDE LOADER..");
        this.loaderService.hide();
    };
    return HttpService;
}(__WEBPACK_IMPORTED_MODULE_3__angular_http__["c" /* Http */]));
HttpService = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Injectable"])(),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_3__angular_http__["i" /* XHRBackend */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_3__angular_http__["i" /* XHRBackend */]) === "function" && _a || Object, typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_4__angular_redux_request_options__["a" /* AngularReduxRequestOptions */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_4__angular_redux_request_options__["a" /* AngularReduxRequestOptions */]) === "function" && _b || Object, typeof (_c = typeof __WEBPACK_IMPORTED_MODULE_5__loader_service__["a" /* LoaderService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_5__loader_service__["a" /* LoaderService */]) === "function" && _c || Object])
], HttpService);

var _a, _b, _c;
//# sourceMappingURL=HttpService.js.map

/***/ }),

/***/ "../../../../../src/app/loader/angular-redux-request.options.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return AngularReduxRequestOptions; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_http__ = __webpack_require__("../../../http/@angular/http.es5.js");
var __extends = (this && this.__extends) || (function () {
    var extendStatics = Object.setPrototypeOf ||
        ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
        function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();

var AngularReduxRequestOptions = (function (_super) {
    __extends(AngularReduxRequestOptions, _super);
    function AngularReduxRequestOptions(angularReduxOptions) {
        var _this = _super.call(this) || this;
        var user = JSON.parse(localStorage.getItem('user'));
        _this.token = user && user.token;
        _this.headers.append('Content-Type', 'application/json');
        _this.headers.append('Authorization', 'Bearer ' + _this.token);
        if (angularReduxOptions != null) {
            for (var option in angularReduxOptions) {
                var optionValue = angularReduxOptions[option];
                _this[option] = optionValue;
            }
        }
        return _this;
    }
    return AngularReduxRequestOptions;
}(__WEBPACK_IMPORTED_MODULE_0__angular_http__["a" /* BaseRequestOptions */]));

//# sourceMappingURL=angular-redux-request.options.js.map

/***/ }),

/***/ "../../../../../src/app/loader/http-service.factory.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return httpServiceFactory; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__HttpService__ = __webpack_require__("../../../../../src/app/loader/HttpService.ts");

function httpServiceFactory(backend, options, loaderService) {
    return new __WEBPACK_IMPORTED_MODULE_0__HttpService__["a" /* HttpService */](backend, options, loaderService);
}

//# sourceMappingURL=http-service.factory.js.map

/***/ }),

/***/ "../../../../../src/app/loader/loader.component.css":
/***/ (function(module, exports, __webpack_require__) {

exports = module.exports = __webpack_require__("../../../../css-loader/lib/css-base.js")(false);
// imports


// module
exports.push([module.i, ".loader-hidden {\n    visibility: hidden;\n}\n\n\n.content {\n  text-align: center;\n  height: 250px;\n}\n", ""]);

// exports


/*** EXPORTS FROM exports-loader ***/
module.exports = module.exports.toString();

/***/ }),

/***/ "../../../../../src/app/loader/loader.component.html":
/***/ (function(module, exports) {

module.exports = "<p-dialog header=\"Loading....\" [(visible)]=\"show\" [closable]=\"false\" [width]=\"300\" [height]=\"250\" [resizable]=\"false\">\n  <div [class.loader-hidden]=\"!show\" class=\"content\" >\n    <p-progressSpinner *ngIf=\"show\"></p-progressSpinner>\n  </div>\n\n</p-dialog>\n"

/***/ }),

/***/ "../../../../../src/app/loader/loader.component.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return LoaderComponent; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__loader_service__ = __webpack_require__("../../../../../src/app/loader/loader.service.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};


var LoaderComponent = (function () {
    function LoaderComponent(loaderService) {
        this.loaderService = loaderService;
        this.show = false;
    }
    LoaderComponent.prototype.ngOnInit = function () {
        var _this = this;
        this.subscription = this.loaderService.loaderState
            .subscribe(function (state) {
            _this.show = state.show;
        });
    };
    LoaderComponent.prototype.ngOnDestroy = function () {
        this.subscription.unsubscribe();
    };
    return LoaderComponent;
}());
LoaderComponent = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Component"])({
        selector: 'angular-loader',
        template: __webpack_require__("../../../../../src/app/loader/loader.component.html"),
        styles: [__webpack_require__("../../../../../src/app/loader/loader.component.css")]
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_1__loader_service__["a" /* LoaderService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_1__loader_service__["a" /* LoaderService */]) === "function" && _a || Object])
], LoaderComponent);

var _a;
//# sourceMappingURL=loader.component.js.map

/***/ }),

/***/ "../../../../../src/app/loader/loader.service.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return LoaderService; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_rxjs_Subject__ = __webpack_require__("../../../../rxjs/Subject.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_rxjs_Subject___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_1_rxjs_Subject__);
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};


var LoaderService = (function () {
    function LoaderService() {
        this.loaderSubject = new __WEBPACK_IMPORTED_MODULE_1_rxjs_Subject__["Subject"]();
        this.loaderState = this.loaderSubject.asObservable();
    }
    LoaderService.prototype.show = function () {
        this.loaderSubject.next({ show: true });
    };
    LoaderService.prototype.hide = function () {
        this.loaderSubject.next({ show: false });
    };
    return LoaderService;
}());
LoaderService = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Injectable"])(),
    __metadata("design:paramtypes", [])
], LoaderService);

//# sourceMappingURL=loader.service.js.map

/***/ }),

/***/ "../../../../../src/app/services/AnwesenheitsService.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return AnwesenheitsService; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__angular_http__ = __webpack_require__("../../../http/@angular/http.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__ = __webpack_require__("../../../../rxjs/Observable.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_rxjs_add_operator_catch__ = __webpack_require__("../../../../rxjs/add/operator/catch.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_rxjs_add_operator_catch___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_3_rxjs_add_operator_catch__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_map__ = __webpack_require__("../../../../rxjs/add/operator/map.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_map___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_map__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6__data_CourseBook__ = __webpack_require__("../../../../../src/app/data/CourseBook.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7__data_Config__ = __webpack_require__("../../../../../src/app/data/Config.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_8__PupilDetailService__ = __webpack_require__("../../../../../src/app/services/PupilDetailService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_9__loader_HttpService__ = __webpack_require__("../../../../../src/app/loader/HttpService.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};










var AnwesenheitsService = AnwesenheitsService_1 = (function () {
    function AnwesenheitsService(http, pupilDetailService) {
        this.http = http;
        this.pupilDetailService = pupilDetailService;
    }
    AnwesenheitsService.prototype.getAnwesenheit = function () {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_7__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/anwesenheit/" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME + "/" + __WEBPACK_IMPORTED_MODULE_6__data_CourseBook__["a" /* CourseBook */].toSQLString(__WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.fromDate) + "/" + __WEBPACK_IMPORTED_MODULE_6__data_CourseBook__["a" /* CourseBook */].toSQLString(__WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.toDate); // URL to web API
        console.log("URL=" + this.url);
        return this.http.get(this.url, { headers: headers })
            .map(function (data) { AnwesenheitsService_1.anwesenheit = data.json(); return data.json(); })
            .catch(this.handleError);
    };
    AnwesenheitsService.prototype.getTodaysAnwesenheit = function () {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_7__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/anwesenheit/" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME; // URL to web API
        console.log("URL=" + this.url);
        return this.http.get(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    AnwesenheitsService.prototype.getTermiondaten = function (idFilter1, idFilter2) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_7__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/noauth/termine/" + __WEBPACK_IMPORTED_MODULE_6__data_CourseBook__["a" /* CourseBook */].toSQLString(__WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.fromDate) + "/" + __WEBPACK_IMPORTED_MODULE_6__data_CourseBook__["a" /* CourseBook */].toSQLString(__WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.toDate) + "/" + idFilter1 + "/" + idFilter2; // URL to web API
        console.log("URL=" + this.url);
        return this.http.get(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    AnwesenheitsService.prototype.getTermine = function () {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_7__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/noauth/termine/";
        console.log("URL=" + this.url);
        return this.http.get(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    AnwesenheitsService.prototype.extractData = function (res) {
        console.log("Receive Anwesenheit: " + JSON.stringify(res.json()));
        var body = res.json();
        return body;
    };
    AnwesenheitsService.prototype.handleError = function (error) {
        // In a real world app, you might use a remote logging infrastructure
        var errMsg;
        if (error instanceof __WEBPACK_IMPORTED_MODULE_1__angular_http__["f" /* Response */]) {
            var body = error.json() || '';
            var err = body.error || JSON.stringify(body);
            errMsg = error.status + " - " + (error.statusText || '') + " " + err;
        }
        else {
            errMsg = error.message ? error.message : error.toString();
        }
        console.error(errMsg);
        return __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__["Observable"].throw(errMsg);
    };
    AnwesenheitsService.prototype.setAnwesenheit = function (anwesenheit) {
        console.log("set Anwesneheit: " + JSON.stringify(anwesenheit));
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_7__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/anwesenheit/"; // URL to web API
        console.log("URL=" + this.url);
        return this.http.post(this.url, anwesenheit, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    AnwesenheitsService.prototype.deleteAnwesenheit = function (anwesenheit) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_7__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/anwesenheit/" + anwesenheit.ID_SCHUELER + "/" + anwesenheit.DATUM.substring(0, anwesenheit.DATUM.indexOf("T")); // URL to web API
        console.log("DELETE URL=" + this.url);
        return this.http.delete(this.url, { headers: headers }).subscribe(function (res) {
        });
    };
    AnwesenheitsService.prototype.fillFehlzeitenbericht = function (template, a, filledOut) {
        var content = "";
        this.pupilDetailService.getPupilDetails(a.id_Schueler).subscribe(function (data) {
            content = template;
            var pd = data;
            content = content.replace("[[BETRIEB_NAME]]", pd.betrieb.NAME);
            content = content.replace("[[BETRIEB_STRASSE]]", pd.betrieb.STRASSE);
            content = content.replace("[[BETRIEB_PLZ]]", pd.betrieb.PLZ);
            content = content.replace("[[BETRIEB_ORT]]", pd.betrieb.ORT);
            content = content.replace("[[AUSBILDER_NNAME]]", pd.ausbilder.NNAME);
            content = content.replace("[[SCHUELER_NAME]]", pd.vorname + " " + pd.name);
            content = content.replace("[[SCHUELER_KLASSE]]", __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME);
            content = content.replace("[[START_DATUM]]", __WEBPACK_IMPORTED_MODULE_6__data_CourseBook__["a" /* CourseBook */].toReadbleString(__WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.fromDate));
            content = content.replace("[[END_DATUM]]", __WEBPACK_IMPORTED_MODULE_6__data_CourseBook__["a" /* CourseBook */].toReadbleString(__WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.toDate));
            content = content.replace("[[ANZAHL_FEHLTAGE]]", "" + a.summeFehltage);
            var eintraege = "";
            for (var i = 0; i < a.fehltageEntschuldigt.length; i++) {
                eintraege += __WEBPACK_IMPORTED_MODULE_6__data_CourseBook__["a" /* CourseBook */].toReadbleString(new Date(a.fehltageEntschuldigt[i].DATUM));
                if (i != a.fehltageEntschuldigt.length - 1) {
                    eintraege += ", ";
                }
            }
            content = content.replace("[[DATUM_ENTSCHULDIGT]]", eintraege);
            eintraege = "";
            for (var i = 0; i < a.fehltageUnentschuldigt.length; i++) {
                eintraege += __WEBPACK_IMPORTED_MODULE_6__data_CourseBook__["a" /* CourseBook */].toReadbleString(new Date(a.fehltageUnentschuldigt[i].DATUM)) + " ";
                if (i != a.fehltageUnentschuldigt.length - 1) {
                    eintraege += ", ";
                }
            }
            content = content.replace("[[DATUM_UNENTSCHULDIGT]]", eintraege);
            content = content.replace("[[LEHRER_NNAME]]", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.username);
            content = content.replace("[[LEHRER_EMAIL]]", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.email);
            filledOut(content, pd.ausbilder.EMAIL);
        }, function (err) {
            console.log("Fehler beim Laden der Details von Schüler mit ID=" + a.id_Schueler);
        });
    };
    return AnwesenheitsService;
}());
AnwesenheitsService = AnwesenheitsService_1 = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Injectable"])(),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_9__loader_HttpService__["a" /* HttpService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_9__loader_HttpService__["a" /* HttpService */]) === "function" && _a || Object, typeof (_b = typeof __WEBPACK_IMPORTED_MODULE_8__PupilDetailService__["a" /* PupilDetailService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_8__PupilDetailService__["a" /* PupilDetailService */]) === "function" && _b || Object])
], AnwesenheitsService);

var AnwesenheitsService_1, _a, _b;
//# sourceMappingURL=AnwesenheitsService.js.map

/***/ }),

/***/ "../../../../../src/app/services/CourseService.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return CourseService; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__angular_http__ = __webpack_require__("../../../http/@angular/http.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__ = __webpack_require__("../../../../rxjs/Observable.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_catch__ = __webpack_require__("../../../../rxjs/add/operator/catch.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_catch___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_catch__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5_rxjs_add_operator_map__ = __webpack_require__("../../../../rxjs/add/operator/map.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5_rxjs_add_operator_map___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_5_rxjs_add_operator_map__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6__data_Config__ = __webpack_require__("../../../../../src/app/data/Config.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};







var CourseService = (function () {
    function CourseService(http) {
        this.http = http;
        this.anzahl = 0;
    }
    CourseService.prototype.getStundenplan = function (kname) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/noauth/plan/stundenplan/" + kname; // URL to web API
        console.log("get stundenplan URL=" + this.url);
        return this.http.get(this.url, { headers: headers })
            .map(this.extractPlainData)
            .catch(this.handleError);
    };
    CourseService.prototype.getVertretungsplan = function (kname) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/noauth/plan/vertertungsplan/" + kname; // URL to web API
        console.log("get Vertretungsplan  URL=" + this.url);
        return this.http.get(this.url, { headers: headers })
            .map(this.extractPlainData)
            .catch(this.handleError);
    };
    CourseService.prototype.getPortfolio = function (idKlasse) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/portfolio/" + idKlasse; // URL to web API
        console.log("get Portfolio  URL=" + this.url);
        return this.http.get(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    CourseService.prototype.getCourseInfo = function (idKlasse) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/klasse/details/" + idKlasse; // URL to web API
        console.log("get CourseInfo  URL=" + this.url);
        return this.http.get(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    CourseService.prototype.getCompanies = function (kname) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/klasse/betriebe/" + kname; // URL to web API
        console.log("get Companies  URL=" + this.url);
        return this.http.get(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    CourseService.prototype.getCoursePictures = function (kname, height) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/klasse/" + kname + "/bilder64/" + height; // URL to web API
        console.log("get CoursePictures  URL=" + this.url);
        return this.http.get(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    CourseService.prototype.getCourses = function () {
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/noauth/klassen";
        console.log("get Courses  URL=" + this.url);
        return this.http.get(this.url)
            .map(this.extractData)
            .catch(this.handleError);
    };
    CourseService.prototype.setCourseInfo = function (idKlasse, notiz) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/klasse/details/" + idKlasse; // URL to web API
        console.log("set CourseInfo  URL=" + this.url);
        var body = { "NOTIZ": notiz };
        return this.http.post(this.url, JSON.stringify(body), { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    CourseService.prototype.extractData = function (res) {
        console.log("URL=" + this.url);
        console.log("Receive Data: " + JSON.stringify(res.json()));
        var body = res.json();
        return body;
    };
    CourseService.prototype.extractPlainData = function (res) {
        return res.text();
    };
    CourseService.prototype.handleError = function (error) {
        // In a real world app, you might use a remote logging infrastructure
        var errMsg;
        if (error instanceof __WEBPACK_IMPORTED_MODULE_1__angular_http__["f" /* Response */]) {
            var body = error.json() || '';
            var err = body.error || JSON.stringify(body);
            errMsg = error.status + " - " + (error.statusText || '') + " " + err;
        }
        else {
            errMsg = error.message ? error.message : error.toString();
        }
        console.error(errMsg);
        return __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__["Observable"].throw(errMsg);
    };
    return CourseService;
}());
CourseService = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Injectable"])(),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_1__angular_http__["c" /* Http */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_1__angular_http__["c" /* Http */]) === "function" && _a || Object])
], CourseService);

var _a;
//# sourceMappingURL=CourseService.js.map

/***/ }),

/***/ "../../../../../src/app/services/DokuService.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return DokuService; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__angular_http__ = __webpack_require__("../../../http/@angular/http.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__data_Config__ = __webpack_require__("../../../../../src/app/data/Config.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};




var DokuService = DokuService_1 = (function () {
    function DokuService(http) {
        this.http = http;
    }
    DokuService.prototype.setDisplayDoku = function (b, view) {
        DokuService_1.displayDoku = b;
        DokuService_1.view = view;
    };
    DokuService.prototype.setDokuFilter = function (t1, t2) {
        DokuService_1.anwFilter1 = t1.id;
        DokuService_1.anwFilter2 = t2.id;
    };
    DokuService.prototype.isVisible = function () {
        return DokuService_1.displayDoku;
    };
    DokuService.prototype.getDoku = function (body) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_2__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/x-www-form-urlencoded;  charset=UTF-8");
        var options = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["e" /* RequestOptions */]({ headers: headers });
        // Ensure you set the responseType to Blob.
        options.responseType = __WEBPACK_IMPORTED_MODULE_1__angular_http__["g" /* ResponseContentType */].Blob;
        return this.http.post(__WEBPACK_IMPORTED_MODULE_3__data_Config__["a" /* Config */].SERVER + "Diklabu/DokuServlet", body, options)
            .map(function (res) {
            console.log("-->" + JSON.stringify(res));
            var fileBlob = res.blob();
            return fileBlob;
        });
    };
    return DokuService;
}());
DokuService.displayDoku = false;
DokuService.view = "Verlauf";
DokuService.anwFilter1 = 0;
DokuService.anwFilter2 = 0;
DokuService = DokuService_1 = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Injectable"])(),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_1__angular_http__["c" /* Http */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_1__angular_http__["c" /* Http */]) === "function" && _a || Object])
], DokuService);

var DokuService_1, _a;
//# sourceMappingURL=DokuService.js.map

/***/ }),

/***/ "../../../../../src/app/services/LoginService.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return LoginService; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__angular_http__ = __webpack_require__("../../../http/@angular/http.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__ = __webpack_require__("../../../../rxjs/Observable.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_rxjs_add_operator_catch__ = __webpack_require__("../../../../rxjs/add/operator/catch.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_rxjs_add_operator_catch___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_3_rxjs_add_operator_catch__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_rxjs_add_observable_throw__ = __webpack_require__("../../../../rxjs/add/observable/throw.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_rxjs_add_observable_throw___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_4_rxjs_add_observable_throw__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5_rxjs_Rx__ = __webpack_require__("../../../../rxjs/Rx.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5_rxjs_Rx___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_5_rxjs_Rx__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7__data_Config__ = __webpack_require__("../../../../../src/app/data/Config.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};









var LoginService = (function () {
    function LoginService(http) {
        this.http = http;
    }
    LoginService.prototype.performLogin = function (user, password) {
        this.url = __WEBPACK_IMPORTED_MODULE_7__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/auth/login/"; // URL to web API
        console.log("LoginURL:" + this.url);
        var body = { benutzer: user, kennwort: password };
        return this.http.post(this.url, body)
            .map(this.extractData)
            .catch(this.handleError);
    };
    LoginService.prototype.setPin = function (pin, uid) {
        this.url = __WEBPACK_IMPORTED_MODULE_7__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/auth/setpin/"; // URL to web API
        console.log("LoginURL:" + this.url);
        var body = { pin: pin, uid: uid };
        console.log(" Sende zum Server: " + JSON.stringify(body));
        return this.http.post(this.url, body)
            .map(this.extractData)
            .catch(this.handleError);
    };
    LoginService.prototype.extractData = function (res) {
        console.log("URL=" + this.url);
        console.log("Receive Login: " + JSON.stringify(res.json()));
        var body = res.json();
        return body;
    };
    LoginService.prototype.handleError = function (error) {
        // In a real world app, you might use a remote logging infrastructure
        var errMsg;
        if (error instanceof __WEBPACK_IMPORTED_MODULE_1__angular_http__["f" /* Response */]) {
            var body = error.json() || '';
            var err = body.error || JSON.stringify(body);
            errMsg = err;
        }
        else {
            errMsg = error.message ? error.message : error.toString();
        }
        console.error(errMsg);
        return __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__["Observable"].throw(errMsg);
    };
    LoginService.prototype.performLogout = function (user, password) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_6__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_7__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/auth/logout/"; // URL to web API
        console.log("LooutURL:" + this.url);
        var body = { benutzer: user, kennwort: password };
        return this.http.post(this.url, body, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    return LoginService;
}());
LoginService = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Injectable"])(),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_1__angular_http__["c" /* Http */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_1__angular_http__["c" /* Http */]) === "function" && _a || Object])
], LoginService);

var _a;
//# sourceMappingURL=LoginService.js.map

/***/ }),

/***/ "../../../../../src/app/services/MailService.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return MailService; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__angular_http__ = __webpack_require__("../../../http/@angular/http.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__ = __webpack_require__("../../../../rxjs/Observable.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_catch__ = __webpack_require__("../../../../rxjs/add/operator/catch.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_catch___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_catch__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5_rxjs_add_operator_map__ = __webpack_require__("../../../../rxjs/add/operator/map.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5_rxjs_add_operator_map___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_5_rxjs_add_operator_map__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6__data_Config__ = __webpack_require__("../../../../../src/app/data/Config.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7__loader_HttpService__ = __webpack_require__("../../../../../src/app/loader/HttpService.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};








var MailService = (function () {
    function MailService(http) {
        this.http = http;
    }
    MailService.prototype.extractData = function (res) {
        try {
            console.log("Receive Mail Servlet: " + JSON.stringify(res.json()));
            var body = res.json();
            return body;
        }
        catch (e) {
            console.log("Antwort vom Mail Servlet ist kein JSON");
            return "";
        }
    };
    MailService.prototype.handleError = function (error) {
        // In a real world app, you might use a remote logging infrastructure
        var errMsg;
        if (error instanceof __WEBPACK_IMPORTED_MODULE_1__angular_http__["f" /* Response */]) {
            var body = error.json() || '';
            var err = body.error || JSON.stringify(body);
            errMsg = error.status + " - " + (error.statusText || '') + " " + err;
        }
        else {
            errMsg = error.message ? error.message : error.toString();
        }
        console.error(errMsg);
        return __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__["Observable"].throw(errMsg);
    };
    MailService.prototype.sendMail = function (mail) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/x-www-form-urlencoded;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/MailServlet"; // URL to web API
        console.log("body=" + mail.getBody());
        return this.http.post(this.url, mail.getBody(), { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    MailService.prototype.getTemplate = function (s, url) {
        url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + s; // URL to web API
        return this.http.get(url)
            .map(function (res) { return res.text(); })
            .catch(this.handleError);
    };
    return MailService;
}());
MailService = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Injectable"])(),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_7__loader_HttpService__["a" /* HttpService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_7__loader_HttpService__["a" /* HttpService */]) === "function" && _a || Object])
], MailService);

var _a;
//# sourceMappingURL=MailService.js.map

/***/ }),

/***/ "../../../../../src/app/services/NotenService.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return NotenService; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__angular_http__ = __webpack_require__("../../../http/@angular/http.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__ = __webpack_require__("../../../../rxjs/Observable.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4__data_Config__ = __webpack_require__("../../../../../src/app/data/Config.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5_rxjs_add_operator_catch__ = __webpack_require__("../../../../rxjs/add/operator/catch.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5_rxjs_add_operator_catch___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_5_rxjs_add_operator_catch__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6_rxjs_add_operator_map__ = __webpack_require__("../../../../rxjs/add/operator/map.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6_rxjs_add_operator_map___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_6_rxjs_add_operator_map__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7__loader_HttpService__ = __webpack_require__("../../../../../src/app/loader/HttpService.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};








var NotenService = (function () {
    function NotenService(http) {
        this.http = http;
    }
    NotenService.prototype.getCurrentYear = function () {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_4__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/schuljahr"; // URL to web API
        return this.http.get(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    NotenService.prototype.getGrades = function (kname, idSchuljahr) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_4__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/noten/" + kname + "/" + idSchuljahr; // URL to web API
        console.log("get Grades  URL=" + this.url);
        return this.http.get(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    NotenService.prototype.setGrade = function (grade, idCourse) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_4__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/noten/" + idCourse; // URL to web API
        console.log("get Grades  URL=" + this.url);
        return this.http.post(this.url, JSON.stringify(grade), { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    NotenService.prototype.deleteGrade = function (grade) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_4__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/noten/" + grade.ID_LERNFELD + "/" + grade.ID_SCHUELER; // URL to web API
        console.log("get Grades  URL=" + this.url);
        return this.http.delete(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    NotenService.prototype.extractData = function (res) {
        console.log("URL=" + this.url);
        console.log("Receive Data: " + JSON.stringify(res.json()));
        var body = res.json();
        return body;
    };
    NotenService.prototype.extractPlainData = function (res) {
        return res.text();
    };
    NotenService.prototype.handleError = function (error) {
        // In a real world app, you might use a remote logging infrastructure
        var errMsg;
        if (error instanceof __WEBPACK_IMPORTED_MODULE_1__angular_http__["f" /* Response */]) {
            var body = error.json() || '';
            var err = body.error || JSON.stringify(body);
            errMsg = error.status + " - " + (error.statusText || '') + " " + err;
        }
        else {
            errMsg = error.message ? error.message : error.toString();
        }
        console.error(errMsg);
        return __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__["Observable"].throw(errMsg);
    };
    return NotenService;
}());
NotenService = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Injectable"])(),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_7__loader_HttpService__["a" /* HttpService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_7__loader_HttpService__["a" /* HttpService */]) === "function" && _a || Object])
], NotenService);

var _a;
//# sourceMappingURL=NotenService.js.map

/***/ }),

/***/ "../../../../../src/app/services/PupilDetailService.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return PupilDetailService; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__angular_http__ = __webpack_require__("../../../http/@angular/http.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__ = __webpack_require__("../../../../rxjs/Observable.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_rxjs_add_operator_catch__ = __webpack_require__("../../../../rxjs/add/operator/catch.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_rxjs_add_operator_catch___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_3_rxjs_add_operator_catch__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_map__ = __webpack_require__("../../../../rxjs/add/operator/map.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_map___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_map__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6__data_Config__ = __webpack_require__("../../../../../src/app/data/Config.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7__loader_HttpService__ = __webpack_require__("../../../../../src/app/loader/HttpService.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};








var PupilDetailService = (function () {
    function PupilDetailService(http) {
        this.http = http;
    }
    PupilDetailService.prototype.extractData = function (res) {
        console.log("Receive Pupil Details: " + JSON.stringify(res.json()));
        var body = res.json();
        return body;
    };
    PupilDetailService.prototype.handleError = function (error) {
        // In a real world app, you might use a remote logging infrastructure
        var errMsg;
        if (error instanceof __WEBPACK_IMPORTED_MODULE_1__angular_http__["f" /* Response */]) {
            var body = error.json() || '';
            var err = body.error || JSON.stringify(body);
            errMsg = error.status + " - " + (error.statusText || '') + " " + err;
        }
        else {
            errMsg = error.message ? error.message : error.toString();
        }
        console.error(errMsg);
        return __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__["Observable"].throw(errMsg);
    };
    PupilDetailService.prototype.getSPupilDetails = function (id) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/x-www-form-urlencoded;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/sauth/" + id; // URL to web API
        return this.http.get(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    PupilDetailService.prototype.getSPupilImage = function (id) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/x-www-form-urlencoded;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/sauth/bild64/" + id; // URL to web API
        return this.http.get(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    PupilDetailService.prototype.getPupilDetails = function (id) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/x-www-form-urlencoded;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/schueler/" + id; // URL to web API
        return this.http.get(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    PupilDetailService.prototype.getPupilImage = function (id) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/x-www-form-urlencoded;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/schueler/bild64/" + id; // URL to web API
        return this.http.get(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    PupilDetailService.prototype.setInfo = function (id, bem) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json; charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/schueler/" + id; // URL to web API
        var body = { id: id, info: bem };
        return this.http.post(this.url, JSON.stringify(body), { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    return PupilDetailService;
}());
PupilDetailService = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Injectable"])(),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_7__loader_HttpService__["a" /* HttpService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_7__loader_HttpService__["a" /* HttpService */]) === "function" && _a || Object])
], PupilDetailService);

var _a;
//# sourceMappingURL=PupilDetailService.js.map

/***/ }),

/***/ "../../../../../src/app/services/PupilService.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return PupilService; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__angular_http__ = __webpack_require__("../../../http/@angular/http.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__ = __webpack_require__("../../../../rxjs/Observable.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_rxjs_add_operator_catch__ = __webpack_require__("../../../../rxjs/add/operator/catch.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_rxjs_add_operator_catch___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_3_rxjs_add_operator_catch__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_map__ = __webpack_require__("../../../../rxjs/add/operator/map.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_map___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_map__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6__data_Config__ = __webpack_require__("../../../../../src/app/data/Config.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7__loader_HttpService__ = __webpack_require__("../../../../../src/app/loader/HttpService.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_8__data_CourseBook__ = __webpack_require__("../../../../../src/app/data/CourseBook.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};









var PupilService = (function () {
    function PupilService(http) {
        this.http = http;
    }
    PupilService.prototype.getPupils = function (id) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/klasse/member/" + id; // URL to web API
        console.log("get pupils URL=" + this.url);
        return this.http.get(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    PupilService.prototype.getAllPupils = function () {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/schueler/"; // URL to web API
        console.log("get pupils URL=" + this.url);
        return this.http.get(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    PupilService.prototype.getCompanies = function (kname) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/klasse/betriebe/" + kname; // URL to web API
        console.log("get companies URL=" + this.url);
        return this.http.get(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    PupilService.prototype.setPupil = function (pupil) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/schueler/verwaltung/" + pupil.id; // URL to web API
        console.log("URL=" + this.url);
        var header;
        if (pupil.GEBDAT) {
            header = {
                ABGANG: pupil.ABGANG,
                EMAIL: pupil.EMAIL,
                NNAME: pupil.NNAME,
                VNAME: pupil.VNAME,
                GEBDAT: __WEBPACK_IMPORTED_MODULE_8__data_CourseBook__["a" /* CourseBook */].toSQLString(pupil.GEBDAT)
            };
        }
        else {
            header = {
                ABGANG: pupil.ABGANG,
                EMAIL: pupil.EMAIL,
                NNAME: pupil.NNAME,
                VNAME: pupil.VNAME,
            };
        }
        console.log("Sende zum Server: " + JSON.stringify(header));
        return this.http.post(this.url, header, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    PupilService.prototype.downloadPortfolio = function (id) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        var options = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["e" /* RequestOptions */]({ responseType: __WEBPACK_IMPORTED_MODULE_1__angular_http__["g" /* ResponseContentType */].Blob });
        options.headers = headers;
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/schueler/portfolio/" + id; // URL to web API
        console.log("URL=" + this.url);
        return this.http.get(this.url, options)
            .map(function (res) { return res.blob(); })
            .catch(this.handleError);
    };
    PupilService.prototype.newPupil = function (pupil) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/schueler/admin/"; // URL to web API
        console.log("URL=" + this.url);
        var header;
        header = {
            ABGANG: pupil.ABGANG,
            EMAIL: pupil.EMAIL,
            NNAME: pupil.NNAME,
            VNAME: pupil.VNAME,
            GEBDAT: __WEBPACK_IMPORTED_MODULE_8__data_CourseBook__["a" /* CourseBook */].toSQLString(pupil.GEBDAT)
        };
        console.log("Sende zum Server: " + JSON.stringify(header));
        return this.http.post(this.url, header, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    PupilService.prototype.addPupilToCourse = function (pupil, course) {
        console.log("Add Pupil: " + JSON.stringify(pupil) + " to course " + JSON.stringify(course));
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/klasse/verwaltung/add/"; // URL to web API
        console.log("URL=" + this.url);
        var body = { ID_SCHUELER: pupil.id, ID_KLASSE: course.id };
        return this.http.post(this.url, body, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    PupilService.prototype.removePupilFromCourse = function (pupil, course) {
        console.log("Remove Pupil: " + JSON.stringify(pupil) + " to course " + JSON.stringify(course));
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/klasse/verwaltung/" + pupil.id + "/" + course.id; // URL to web API
        console.log("URL=" + this.url);
        return this.http.delete(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    PupilService.prototype.extractData = function (res) {
        console.log("URL=" + this.url);
        console.log("Receive Pupils: " + JSON.stringify(res.json()));
        var body = res.json();
        return body;
    };
    PupilService.prototype.handleError = function (error) {
        // In a real world app, you might use a remote logging infrastructure
        var errMsg;
        if (error instanceof __WEBPACK_IMPORTED_MODULE_1__angular_http__["f" /* Response */]) {
            var body = error.json() || '';
            var err = body.error || JSON.stringify(body);
            errMsg = error.status + " - " + (error.statusText || '') + " " + err;
        }
        else {
            errMsg = error.message ? error.message : error.toString();
        }
        console.error(errMsg);
        return __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__["Observable"].throw(errMsg);
    };
    return PupilService;
}());
PupilService = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Injectable"])(),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_7__loader_HttpService__["a" /* HttpService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_7__loader_HttpService__["a" /* HttpService */]) === "function" && _a || Object])
], PupilService);

var _a;
//# sourceMappingURL=PupilService.js.map

/***/ }),

/***/ "../../../../../src/app/services/SharedService.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return SharedService; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_rxjs_Subject__ = __webpack_require__("../../../../rxjs/Subject.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_rxjs_Subject___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_1_rxjs_Subject__);
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};


var SharedService = (function () {
    function SharedService() {
        this.subject = new __WEBPACK_IMPORTED_MODULE_1_rxjs_Subject__["Subject"]();
    }
    SharedService.prototype.courseBookChanged = function (message) {
        this.subject.next(message);
    };
    SharedService.prototype.getCoursebook = function () {
        return this.subject.asObservable();
    };
    return SharedService;
}());
SharedService = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Injectable"])()
], SharedService);

//# sourceMappingURL=SharedService.js.map

/***/ }),

/***/ "../../../../../src/app/services/TeacherService.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return TeacherService; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__angular_http__ = __webpack_require__("../../../http/@angular/http.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__ = __webpack_require__("../../../../rxjs/Observable.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_rxjs_add_operator_catch__ = __webpack_require__("../../../../rxjs/add/operator/catch.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_rxjs_add_operator_catch___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_3_rxjs_add_operator_catch__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_map__ = __webpack_require__("../../../../rxjs/add/operator/map.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_map___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_4_rxjs_add_operator_map__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6__data_Config__ = __webpack_require__("../../../../../src/app/data/Config.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7__loader_HttpService__ = __webpack_require__("../../../../../src/app/loader/HttpService.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};








var TeacherService = (function () {
    function TeacherService(http) {
        this.http = http;
    }
    TeacherService.prototype.getTeachers = function () {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/lehrer/"; // URL to web API
        console.log("get Teacher URL=" + this.url);
        return this.http.get(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    TeacherService.prototype.getCoursesOfTeacher = function (tid) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/klasse/klassenlehrer/" + tid + "/false"; // URL to web API
        console.log("get Teacher URL=" + this.url);
        return this.http.get(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    TeacherService.prototype.getTeachersOfCourse = function (course) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/klasse/lehrer/" + course.id; // URL to web API
        console.log("get Teacher URL=" + this.url);
        return this.http.get(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    TeacherService.prototype.addTeacherToCourse = function (teacher, course) {
        console.log("Add Teacher: " + JSON.stringify(teacher) + " to course " + JSON.stringify(course));
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/klasse/verwaltung/lehrer/add/"; // URL to web API
        console.log("URL=" + this.url);
        var body = { ID_LEHRER: teacher.id, ID_KLASSE: course.id };
        return this.http.post(this.url, body, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    TeacherService.prototype.removeTeacherFromCourse = function (teacher, course) {
        console.log("Remove Teacher: " + JSON.stringify(teacher) + " to course " + JSON.stringify(course));
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_5__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_6__data_Config__["a" /* Config */].SERVER + "Diklabu/api/v1/klasse/verwaltung/lehrer/" + teacher.id + "/" + course.id; // URL to web API
        console.log("URL=" + this.url);
        return this.http.delete(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    TeacherService.prototype.extractData = function (res) {
        console.log("URL=" + this.url);
        console.log("Receive Pupils: " + JSON.stringify(res.json()));
        var body = res.json();
        return body;
    };
    TeacherService.prototype.handleError = function (error) {
        // In a real world app, you might use a remote logging infrastructure
        var errMsg;
        if (error instanceof __WEBPACK_IMPORTED_MODULE_1__angular_http__["f" /* Response */]) {
            var body = error.json() || '';
            var err = body.error || JSON.stringify(body);
            errMsg = error.status + " - " + (error.statusText || '') + " " + err;
        }
        else {
            errMsg = error.message ? error.message : error.toString();
        }
        console.error(errMsg);
        return __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__["Observable"].throw(errMsg);
    };
    return TeacherService;
}());
TeacherService = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Injectable"])(),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_7__loader_HttpService__["a" /* HttpService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_7__loader_HttpService__["a" /* HttpService */]) === "function" && _a || Object])
], TeacherService);

var _a;
//# sourceMappingURL=TeacherService.js.map

/***/ }),

/***/ "../../../../../src/app/services/VerlaufsService.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return VerlaufsService; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__angular_http__ = __webpack_require__("../../../http/@angular/http.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__ = __webpack_require__("../../../../rxjs/Observable.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__ = __webpack_require__("../../../../../src/app/CourseBookComponent.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4__data_CourseBook__ = __webpack_require__("../../../../../src/app/data/CourseBook.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5_rxjs_add_operator_catch__ = __webpack_require__("../../../../rxjs/add/operator/catch.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5_rxjs_add_operator_catch___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_5_rxjs_add_operator_catch__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6_rxjs_add_operator_map__ = __webpack_require__("../../../../rxjs/add/operator/map.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6_rxjs_add_operator_map___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_6_rxjs_add_operator_map__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7__data_Config__ = __webpack_require__("../../../../../src/app/data/Config.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_8__loader_HttpService__ = __webpack_require__("../../../../../src/app/loader/HttpService.ts");
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};









var VerlaufsService = (function () {
    function VerlaufsService(http) {
        this.http = http;
    }
    VerlaufsService.prototype.getVerlauf = function () {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_7__data_Config__["a" /* Config */].SERVER + "/Diklabu/api/v1/verlauf/" + __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.course.KNAME + "/" + __WEBPACK_IMPORTED_MODULE_4__data_CourseBook__["a" /* CourseBook */].toSQLString(__WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.fromDate) + "/" + __WEBPACK_IMPORTED_MODULE_4__data_CourseBook__["a" /* CourseBook */].toSQLString(__WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.toDate);
        console.log("URL=" + this.url);
        return this.http.get(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    VerlaufsService.prototype.deleteVerlauf = function (v) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_7__data_Config__["a" /* Config */].SERVER + "/Diklabu/api/v1/verlauf/" + v.ID;
        console.log("URL=" + this.url);
        return this.http.delete(this.url, { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    VerlaufsService.prototype.extractData = function (res) {
        console.log("Receive Verlauf: " + JSON.stringify(res.json()));
        var body = res.json();
        return body;
    };
    VerlaufsService.prototype.handleError = function (error) {
        // In a real world app, you might use a remote logging infrastructure
        var errMsg;
        if (error instanceof __WEBPACK_IMPORTED_MODULE_1__angular_http__["f" /* Response */]) {
            var body = error.json() || '';
            var err = body.error || JSON.stringify(body);
            errMsg = error.status + " - " + (error.statusText || '') + " " + err;
        }
        else {
            errMsg = error.message ? error.message : error.toString();
        }
        console.error(errMsg);
        return __WEBPACK_IMPORTED_MODULE_2_rxjs_Observable__["Observable"].throw(errMsg);
    };
    VerlaufsService.prototype.newVerlauf = function (v) {
        var headers = new __WEBPACK_IMPORTED_MODULE_1__angular_http__["b" /* Headers */]();
        headers.append("auth_token", "" + __WEBPACK_IMPORTED_MODULE_3__CourseBookComponent__["a" /* CourseBookComponent */].courseBook.auth_token);
        headers.append("Content-Type", "application/json;  charset=UTF-8");
        this.url = __WEBPACK_IMPORTED_MODULE_7__data_Config__["a" /* Config */].SERVER + 'Diklabu/api/v1/verlauf/';
        console.log("URL=" + this.url);
        return this.http.post(this.url, JSON.stringify(v), { headers: headers })
            .map(this.extractData)
            .catch(this.handleError);
    };
    return VerlaufsService;
}());
VerlaufsService = __decorate([
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["Injectable"])(),
    __metadata("design:paramtypes", [typeof (_a = typeof __WEBPACK_IMPORTED_MODULE_8__loader_HttpService__["a" /* HttpService */] !== "undefined" && __WEBPACK_IMPORTED_MODULE_8__loader_HttpService__["a" /* HttpService */]) === "function" && _a || Object])
], VerlaufsService);

var _a;
//# sourceMappingURL=VerlaufsService.js.map

/***/ }),

/***/ "../../../../../src/assets/mmbbs.jpg":
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__.p + "mmbbs.29c84ccc51abd71ce8c4.jpg";

/***/ }),

/***/ "../../../../../src/environments/environment.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return environment; });
// The file contents for the current environment will overwrite these during build.
// The build system defaults to the dev environment which uses `environment.ts`, but if you do
// `ng build --env=prod` then `environment.prod.ts` will be used instead.
// The list of which env maps to which file can be found in `.angular-cli.json`.
// The file contents for the current environment will overwrite these during build.
var environment = {
    production: false
};
//# sourceMappingURL=environment.js.map

/***/ }),

/***/ "../../../../../src/main.ts":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__angular_core__ = __webpack_require__("../../../core/@angular/core.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__angular_platform_browser_dynamic__ = __webpack_require__("../../../platform-browser-dynamic/@angular/platform-browser-dynamic.es5.js");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__app_app_module__ = __webpack_require__("../../../../../src/app/app.module.ts");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__environments_environment__ = __webpack_require__("../../../../../src/environments/environment.ts");




if (__WEBPACK_IMPORTED_MODULE_3__environments_environment__["a" /* environment */].production) {
    Object(__WEBPACK_IMPORTED_MODULE_0__angular_core__["enableProdMode"])();
}
Object(__WEBPACK_IMPORTED_MODULE_1__angular_platform_browser_dynamic__["a" /* platformBrowserDynamic */])().bootstrapModule(__WEBPACK_IMPORTED_MODULE_2__app_app_module__["a" /* AppModule */]);
//# sourceMappingURL=main.js.map

/***/ }),

/***/ 0:
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__("../../../../../src/main.ts");


/***/ })

},[0]);
//# sourceMappingURL=main.bundle.js.map